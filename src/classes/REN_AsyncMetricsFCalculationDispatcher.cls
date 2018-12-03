global with sharing class REN_AsyncMetricsFCalculationDispatcher implements Schedulable {
	public static Integer batchInterval = 15;
	global void execute(SchedulableContext sc){
		String namespace = CSM_Util.getNameSpace();
		namespace = namespace.replace('__', '.');
		Type targettype = Type.forName(namespace + 'REN_AsyncMetricsFieldCalculation');  
		if(targettype!=null) {
	   		REN_IScheduleDispatched obj = (REN_IScheduleDispatched)targettype.NewInstance();
	   		System.debug('\n1- Call REN_AsyncMetricsFCalculationDispatcher: execute: ');
	    	obj.execute(sc);
		}
	}
	
	public static void scheduleMe(SchedulableContext SC, String calculationType, Set<ID> impactedOpportunitySet) { 
		boolean isBatchAlreadyScheduled = [SELECT count() FROM AsyncApexJob WHERE JobType='ScheduledApex' AND ApexClass.name IN ('REN_AsyncMetricsFieldCalculationSchedule', 'REN_FiscalYearOppBatchDispatcher') AND Status NOT IN ('Aborted', 'Completed', 'Failed')  ] > 0 ;
		if(!isBatchAlreadyScheduled){
			//Rescheduling should be done only for DS user
			Integer batchSize = CSM_Util.getCustomListSetting('REN_AsyncMetricsFieldCalculation');
			batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;		
			REN_AsyncMetricsFCalculationDispatcher.executeMe(SC, calculationType, impactedOpportunitySet, batchSize, false);
		}
		System.debug('\n 0- Call REN_AsyncMetricsFCalculationDispatcher: scheduleMe: isBatchAlreadyScheduled = ' + isBatchAlreadyScheduled);
		
	}  
	
	//This method will be executed after 15 min.
	public static boolean executeMe(SchedulableContext SC, String calculationType, Set<ID> impactedOpportunitySet, Integer batchSize, boolean isCalledFromExecuteMethod) {   
		//if(this.calculationType.equalsIgnoreCase('RLI') || this.calculationType.equalsIgnoreCase('OLI')){batchSize = 1;}
		boolean isFlexQueueAvailable = REN_AsyncUtil.isFlexQueueAvailable();
		//if(SC != null && isCalledFromExecuteMethod && isFlexQueueAvailable){
		if(isCalledFromExecuteMethod && isFlexQueueAvailable){
			boolean isRecordPending = true;
			if(calculationType.equalsIgnoreCase('RLI-OLI')){
				isRecordPending = [SELECT count() FROM Opportunity WHERE REN_Renewal_Metrics_Status__c IN ('Not Calculated') AND CHL_QuoteSyncStatus__c NOT IN ('Scheduled', 'In Progress', 'Error') AND REN_Is_Sync_Pending__c != true LIMIT 1] > 0;
			}
			if(isRecordPending){
				REN_AsyncMetricsFieldCalBatch batchClass = new REN_AsyncMetricsFieldCalBatch();
				batchClass.schedulableContextObj = SC;
				batchClass.calculationType = calculationType;
				batchClass.impactedOpportunitySet = impactedOpportunitySet;
				batchClass.batchSize = batchSize;
				System.debug('SchedulableContextID: ' + SC + '\n\n3- Call REN_AsyncMetricsFCalculationDispatcher: executeBatch: ' + impactedOpportunitySet);
				Database.executeBatch(batchClass, batchSize);
			}else{
				//Terminate job if nothing is pending.
				if(SC != null){
					System.abortJob(SC.getTriggerId());
				}
			}
			return true;
		}else{// Schedule after 15 min.
			Datetime dt = Datetime.now().addMinutes(batchInterval);
			String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
			REN_AsyncMetricsFieldCalculationSchedule schedulerClass = new REN_AsyncMetricsFieldCalculationSchedule(); 
			schedulerClass.calculationType = calculationType;
			schedulerClass.impactedOpportunitySet = impactedOpportunitySet;
			schedulerClass.batchSize = batchSize;
			String schedulerName = 'MetricsFieldCalculation for ' + calculationType + '_' + batchSize + '_' + dt.format('yyyyMMddHHmmss');
			System.debug(impactedOpportunitySet + '\n\n2- Call REN_AsyncMetricsFCalculationDispatcher: Schedule: ' + schedulerName);
			if(SC != null){
				System.abortJob(SC.getTriggerId());
			}
			String jobID = System.Schedule(schedulerName, timeForScheduler, schedulerClass);
			System.debug('SchedulableContextID: ' + jobId + '\n\n2- Call REN_AsyncMetricsFCalculationDispatcher: Schedule-ID: ' + jobID);
			return false;
		}
	}
	
	
}