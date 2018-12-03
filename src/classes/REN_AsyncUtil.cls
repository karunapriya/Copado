public with sharing class REN_AsyncUtil {
	
    /* This method returns true if Apex Flex Queue is not full. */
	public static Boolean isFlexQueueAvailable(){
		return [SELECT count() FROM AsyncApexJob WHERE Status =: 'Holding'] < 100;
	}
	
	public static void scheduleMetricsFieldCalculationForOLI(Set<ID> impactedOpportunitySet){
		if(impactedOpportunitySet!= null && !impactedOpportunitySet.isEmpty()){
			REN_AsyncMetricsFCalculationDispatcher.scheduleMe(null, 'OLI', impactedOpportunitySet);
		}
	} 
	public static void scheduleMetricsFieldCalculation() { 
		REN_AsyncMetricsFCalculationDispatcher.scheduleMe(null, 'RLI-OLI', null);
	}
	
	/* This method is used to get running Batch/Scheduled jobs. */
	public static List<AsyncApexJob> getRunningJobs(String className,String jobType){
		List<AsyncApexJob> runningJobs = new List<AsyncApexJob>();
		runningJobs = [SELECT Id,CreatedById FROM AsyncApexJob WHERE ApexClassId IN (SELECT Id from ApexClass WHERE Name =: className) 
								AND JobType =: jobType 
								AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued' OR Status = 'Holding')];
		return runningJobs;
	}
	
	public static void scheduleCreateQuoteAndQLIBatch(Boolean isMetricsCalcRequired, Integer batchInterval) {
		boolean isBatchAlreadyScheduled = [SELECT count() FROM AsyncApexJob WHERE JobType='ScheduledApex' AND ApexClass.name IN ('CHL_CreateQuoteAndQLIBatchDispatcher') AND Status NOT IN ('Aborted', 'Completed', 'Failed')  ] > 0 ;
		if(!isBatchAlreadyScheduled){
			Datetime dt = Datetime.now().addMinutes(batchInterval);
	        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
	        CHL_CreateQuoteAndQLIBatchDispatcher schedulerClass = new CHL_CreateQuoteAndQLIBatchDispatcher();
	        schedulerClass.isOppUpdateRequired = isMetricsCalcRequired;
	        String schedulerName = 'CreateQuoteAndQLIBatch_'+dt.format('yyyyMMddHHmmss');
	        System.debug('\n\n2- Call CHL_CreateQuoteAndQLIBatchDispatcher: Schedule: ' + schedulerName);
	        String jobID = System.Schedule(schedulerName, timeForScheduler, schedulerClass);	
		}
	}
	public static void scheduleBatchForNewQuote(Set<Id> impactedQuoteIdSet, Boolean isMetricsCalcRequired, Integer batchInterval) {
		Datetime dt = Datetime.now().addMinutes(batchInterval);
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        REN_CreateNewQuoteDispatcher schedulerClass = new REN_CreateNewQuoteDispatcher();
        schedulerClass.impactedQuoteIdSet = impactedQuoteIdSet;
        schedulerClass.isOppUpdateRequired = isMetricsCalcRequired;
        String schedulerName = 'CreateQuoteAndQLIBatch_ForNewQuote_'+dt.format('yyyyMMddHHmmss');
        System.debug(impactedQuoteIdSet + '\n\n2- Call REN_CreateNewQuoteDispatcher: Schedule: ' + schedulerName);
        String jobID = System.Schedule(schedulerName, timeForScheduler, schedulerClass);
	}
	
	public static Boolean isDispatcherNameExist(String dispatcherName){
		List<CronTrigger> cronTriggerList = new List<CronTrigger>();
		Boolean isNameExist = false;
		cronTriggerList = [SELECT Id,CronJobDetail.Name, CronJobDetail.Id,State FROM CronTrigger where CronJobDetail.Name =: dispatcherName and state != 'Deleted'];
		if(cronTriggerList != null && !cronTriggerList.isEmpty() && cronTriggerList.size() > 0){
			isNameExist = true;
		}
		return isNameExist;
	}
	
	public static Boolean isNextRunSetForScheduler(String jobId){
		List<CronTrigger> cronTriggerList = new List<CronTrigger>();
		Boolean isNextRunSet = false;
		cronTriggerList = [SELECT Id,CronJobDetail.Name, CronJobDetail.Id,State,NextFireTime FROM CronTrigger where Id =: jobId and NextFireTime != null and state != 'Deleted'];
		if(cronTriggerList != null && !cronTriggerList.isEmpty() && cronTriggerList.size() > 0){
			isNextRunSet = true;
		}
		return isNextRunSet;
	} 
}