public with sharing class REN_AsyncMetricsFieldCalBatch extends REN_AsyncMetricsFieldCalculation{
    
    public Set<ID> changedExpDateOppSet {get;set;}
    public Set<ID> failureRecordSet {get;set;}
    public Set<ID> rliToOliRecordSet {get;set;}
    //Log the results
    public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
    private List<String> crudFlsOppty = new List<String>{'Id','REN_Earliest_Expiration_Date__c','StageName', 'REN_EQ__c','REN_FY__c','REN_Is_CLM_Renewal__c', 'REN_AddsAmount__c','REN_Renewal_Target__c','REN_Renewal_Metrics_Status__c', 'REN_Metrics_Calculation_Date__c'};
	public Datetime currentExecutionTime {get;set;}
	public SchedulableContext schedulableContextObj {get;set;}
    //Constructor
    public REN_AsyncMetricsFieldCalBatch(){
        this.changedExpDateOppSet = new Set<ID>();
        this.failureRecordSet = new Set<ID>();
        this.rliToOliRecordSet = new Set<ID>();
    }
    
    
    //Start method
    public Database.queryLocator start(Database.BatchableContext batchContext) {
		currentExecutionTime = System.now().addMinutes(-2);
		String soqlStr = 'SELECT ' + String.join(new List<String>(crudFlsOppty), ',') +' FROM Opportunity WHERE CHL_QuoteSyncStatus__c NOT IN (\'Scheduled\', \'In Progress\', \'Error\' ) AND REN_Renewal_Metrics_Status__c IN (\'Not Calculated\', \'Calculating\') AND REN_Metrics_Calculation_Date__c < :currentExecutionTime AND REN_Is_Sync_Pending__c != true';

		if(!this.calculationType.equalsIgnoreCase('RLI-OLI') && (impactedOpportunitySet == null || impactedOpportunitySet.isEmpty())){
			System.debug(impactedOpportunitySet + '\n\n4-  in REN_AsyncMetricsFieldCalBatch Start: calculationType: ' + calculationType);
			CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
			batchResult.CSM_Status__c = 'Info';
			batchResult.CSM_Errors__c = false;
			batchResult.CSM_Error_Description__c = calculationType + '-REN_AsyncMetricsFieldCalBatch: Info: Some logical Error: For RLI & OLI batch impactedOpportunitySet should not be null';
			logger.addLogRecord(batchResult, system.now(), CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, 'Opportunity', batchContext.getJobId());
			logger.saveLogRecords();
			soqlStr += ' AND ID = null';
		}

		if(impactedOpportunitySet != null && !impactedOpportunitySet.isEmpty()){
			soqlStr += ' AND ID IN :impactedOpportunitySet';
		}
		System.debug(impactedOpportunitySet + '\n\n4- Call REN_AsyncMetricsFieldCalBatch Start: soqlStr: ' + soqlStr);

        try{
			CSM_Util.checkCRUD_FLS('Opportunity', new List<String>(crudFlsOppty), CSM_Constants.DML_OPERATION_READ);
            return Database.getQueryLocator(soqlStr);
            
        } catch (Exception ex) {
        	CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
            batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
            batchResult.CSM_Errors__c = true;
            batchResult.CSM_Error_Description__c = calculationType + '-REN_AsyncMetricsFieldCalBatch1: ' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString();
            logger.addLogRecord(batchResult, system.now(), CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, 'Opportunity', batchContext.getJobId());
            logger.saveLogRecords();
            return null;
        }
    }
    
    //Execute method 
    public void execute(Database.BatchableContext batchContext, List<Opportunity> impactedOpportunityList) {
        Savepoint savePoint = Database.setSavepoint();
        Map<Id, Opportunity> impactedOppMap = new Map<Id, Opportunity>(impactedOpportunityList);
        try{
        	List<Opportunity> impactedOppList = impactedOpportunityList;
        	if(SS_Constants.isSimplifiedDataModelEnabled){
        		impactedOppList = REN_OpportunityDataAccess.getOpptyWithMasterProduct(impactedOppMap.keySet());
        	}
        	impactedOppMap.putAll(impactedOppList);
            CSM_TriggerManager.disableAllTriggers();
            System.debug(impactedOppList + '\n\n5- Call REN_AsyncMetricsFieldCalBatch: execute: calculationType = ' + calculationType);
            failureRecordSet.addAll(impactedOppMap.keySet());
            List<String> crudFlsRLI = new List<String>{'REN_Renewal_Target__c', 'REN_Renewal_Target_Resolved__c', 'REN_Renewal_Target_Lost__c', 'REN_Renewal_Target_Won__c'};
            //Expiry Date changed opptys
            Map<Id, Opportunity> changedExpDateOppMap = new Map<Id, Opportunity>();
            Schema.DescribeSObjectResult oppObj = Schema.getGlobalDescribe().get(CSM_Constants.OBJ_OPPORTUNITY).getDescribe();    
            Integer addsAmountScale = CSM_Util.getFieldScaleOptimized(oppObj,(CSM_Util.getNamespace() +'REN_AddsAmount__c').toLowerCase());
            
            List<OpportunityLineItem> masterOliList = new List<OpportunityLineItem>();
            boolean isRliBatch = false;
            
            List<Opportunity> opportunityMetricCalList = new List<Opportunity>();
            if(this.calculationType.equalsIgnoreCase('RLI-OLI') || this.calculationType.equalsIgnoreCase('RLI')){
            	for(Opportunity opp : impactedOppList){
             		if(opp.StageName == 'Closed Sale' || opp.StageName == 'No Service' || opp.StageName == 'House Account' || opp.StageName == 'Open - Consolidated' ){
             	 		opportunityMetricCalList.add(opp);
             	 	}
             	 }
             }
            if(this.calculationType.equalsIgnoreCase('RLI-OLI')){
                List<Opportunity> changedExpDateOppList = new List<Opportunity>();//This declaration is no more required. 

                REN_OpportunityMetricsBusiness.rliMetricsFieldsCalculation(impactedOppList, changedExpDateOppList, CrudFlsRLI);
                if(!opportunityMetricCalList.IsEmpty()) {
                	REN_OpportunityMetricsBusiness.setRliMetricsFieldsOnOpportunity(opportunityMetricCalList);	
                }
                REN_OpportunityMetricsBusiness.setAddsAmount(impactedOppMap, addsAmountScale);
                
                changedExpDateOppMap.putAll(impactedOppList);
                for(Opportunity opp : (List<Opportunity>)impactedOppList){   
                	if(opp.REN_Is_CLM_Renewal__c == true){
                		opp.REN_Renewal_Metrics_Status__c = 'Calculating';
                	}else{
                		opp.REN_Renewal_Metrics_Status__c = 'Calculated';
                		changedExpDateOppMap.remove(opp.Id);
                	}          
					if(SS_Constants.isSimplifiedDataModelEnabled && opp.OpportunityLineItems != null && !opp.OpportunityLineItems.isEmpty()){
						masterOliList.add(opp.OpportunityLineItems[0]);
					}                    
                }
            }else if(this.calculationType.equalsIgnoreCase('RLI')){	//Process RLI metrics calculation with batch size 1		
            	isRliBatch = true;	
                List<Opportunity> changedExpDateOppList = new List<Opportunity>();
                REN_OpportunityMetricsBusiness.rliMetricsFieldsCalculation(impactedOppList, changedExpDateOppList, CrudFlsRLI);
                if(!opportunityMetricCalList.IsEmpty()) {
                	REN_OpportunityMetricsBusiness.setRliMetricsFieldsOnOpportunity(opportunityMetricCalList);	
                }
                REN_OpportunityDataAccess.UpdateExpQuarterYear(changedExpDateOppList, null);
                for(Opportunity opp : (List<Opportunity>)impactedOppList){
                    opp.REN_Renewal_Metrics_Status__c = 'Calculating';
					if(SS_Constants.isSimplifiedDataModelEnabled && opp.OpportunityLineItems != null && !opp.OpportunityLineItems.isEmpty()){
						masterOliList.add(opp.OpportunityLineItems[0]);
					}                    
                }
            }else if(this.calculationType.equalsIgnoreCase('OLI')){                
                REN_OpportunityMetricsBusiness.setAddsAmount(impactedOppMap, addsAmountScale);
                for(Opportunity opp : (List<Opportunity>)impactedOppList){
                    opp.REN_Renewal_Metrics_Status__c = 'Calculated';
                    opp.REN_Metrics_Calculation_Date__c = System.now();
                }
            }
            
            //query to check if the records are not modified during processing
            Set<Id> impOppIdSet = impactedOppMap.keySet();
            String modifiedOptys = 'SELECT ' + String.join(new List<String>(crudFlsOppty), ',') +' FROM Opportunity WHERE ID IN: impOppIdSet AND (REN_Metrics_Calculation_Date__c >= :currentExecutionTime OR REN_Is_Sync_Pending__c = true OR CHL_QuoteSyncStatus__c IN (\'Scheduled\', \'In Progress\', \'Error\' ) )';
            for(Opportunity oppModified : Database.query(modifiedOptys)){
                impactedOppMap.remove(oppModified.Id);
                changedExpDateOppMap.remove(oppModified.Id);
                failureRecordSet.remove(oppModified.Id);
            }
            impactedOppList = impactedOppMap.values();
            DateTime currentDateTime = System.now();
            if(impactedOppList != null && !impactedOppList.isEmpty()){
	            CSM_Util.checkCRUD_FLS('Opportunity', new List<String>(crudFlsOppty), CSM_Constants.DML_OPERATION_UPDATE);
	            
	            List<Database.SaveResult> updateResults = Database.update(impactedOppList, false); // Save rollup fields
	            
	            List<Opportunity> saveErrorOppList = new List<Opportunity>();
	            for(Integer i=0;i<updateResults.size();i++){
                	failureRecordSet.remove(impactedOppList.get(i).id);
	                if (updateResults.get(i).isSuccess()){
	                	if(isRliBatch){
	                		rliToOliRecordSet.add(impactedOppList.get(i).id);
	                	}
	                }else{
	                	changedExpDateOppMap.remove(impactedOppList.get(i).id);
	                    saveErrorOppList.add(new Opportunity(id = impactedOppList.get(i).id, REN_Renewal_Metrics_Status__c = 'Error', REN_Metrics_Calculation_Date__c = currentDateTime));
	                    //Add Error in Log
	                    CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = calculationType + '-REN_AsyncMetricsFieldCalBatch2: ' + impactedOppList.get(i).id + ' - ' + updateResults.get(i).getErrors().get(0));
	                    logger.addLogRecord(errObj, currentDateTime, CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, CSM_Constants.OBJ_TYPE_OPPORTUNITY, batchContext.getJobId());
	                }
	            }
	            
	            if(!saveErrorOppList.isEmpty()){
	            	String couldNotMarkedError ='';
					List<Database.SaveResult> updateErrorResults = Database.update(saveErrorOppList, false);// Stamp errors. Records will not re processed.
		            for(Integer i=0;i<updateErrorResults.size();i++){// These Opportunities could not updated at all in this transaction.
		                if (!updateErrorResults.get(i).isSuccess()){
		                	couldNotMarkedError += saveErrorOppList.get(i).id + ', ';
		                }				
		            }
					if(!String.isBlank(couldNotMarkedError)){
			        	couldNotMarkedError = couldNotMarkedError.removeEnd(', ');
			        	if(couldNotMarkedError.length() > 32000){
			        		couldNotMarkedError = couldNotMarkedError.left(32000) + '...';
			        	}
			        	couldNotMarkedError = 'Could not marked error for Opportunity ID: ' + couldNotMarkedError;
				        CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = calculationType + '-REN_AsyncMetricsFieldCalBatch2.1: ' + couldNotMarkedError);
				        logger.addLogRecord(errObj, currentDateTime, CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, CSM_Constants.OBJ_TYPE_OPPORTUNITY, batchContext.getJobId());
			        }
	            }
	            
	            if(!changedExpDateOppMap.isEmpty()){
	                changedExpDateOppSet.addAll(changedExpDateOppMap.keySet());
	            }
            }
            if(!masterOliList.isEmpty()){// Update RLI rollup on Master OLI' UnitPrice field.
            	CSM_Util.checkCRUD_FLS('OpportunityLineItem', new List<String>{'UnitPrice'}, CSM_Constants.DML_OPERATION_UPDATE);
            	List<Database.SaveResult> updateErrorResults = Database.update(masterOliList, false); // Here if any OLI get fail, may cause data issue on OLI.
            	String couldNotMarkedError ='';
	            for(Integer i=0;i<updateErrorResults.size();i++){// These Opportunities could not updated at all in this transaction.
	                if (!updateErrorResults.get(i).isSuccess()){
	                	couldNotMarkedError += masterOliList.get(i).id + ', ';
	                }				
	            }
				if(!String.isBlank(couldNotMarkedError)){
		        	couldNotMarkedError = couldNotMarkedError.removeEnd(', ');
		        	if(couldNotMarkedError.length() > 32000){
		        		couldNotMarkedError = couldNotMarkedError.left(32000) + '...';
		        	}
		        	couldNotMarkedError = 'Could not save OLI ID: ' + couldNotMarkedError;
			        CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = calculationType + '-REN_AsyncMetricsFieldCalBatch2.2: ' + couldNotMarkedError);
			        logger.addLogRecord(errObj, currentDateTime, CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, 'OpportunityLineItem', batchContext.getJobId());
		        }
            }
            logger.saveLogRecords();
        }catch (exception ex) {
            Database.rollback(savePoint);
            System.debug('\n EXCEPTION~~~~: ' + ex);
            CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
            batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
            batchResult.CSM_Errors__c = true;
            batchResult.CSM_Error_Description__c = calculationType + '-REN_AsyncMetricsFieldCalBatch3: ' + JSON.serialize(impactedOppMap.keySet()) + '\nError: ' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString();
            logger.addLogRecord(batchResult, system.now(), CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, 'Opportunity', batchContext.getJobId());
            logger.saveLogRecords();
        }
    }
    
    //FINISH method
    public void finish(Database.BatchableContext batchContext) {
        System.debug(failureRecordSet + '\n\n6- Call REN_AsyncMetricsFieldCalBatch: finish: calculationType = ' + calculationType + '\nSchedulableContextID: ' + schedulableContextObj);
        if(!changedExpDateOppSet.isEmpty() && this.calculationType.equalsIgnoreCase('RLI-OLI')){
        	Datetime scheduledDateTime = Datetime.now().addMinutes(5);
        	String timeForScheduler = scheduledDateTime.format('s m H d M \'?\' yyyy');
            REN_FiscalYearOppBatchDispatcher schedulerClass = new REN_FiscalYearOppBatchDispatcher();
            schedulerClass.impactedOppId = changedExpDateOppSet;
            String schedulerName = 'FiscalYearOnOpportunity_'+scheduledDateTime.format('yyyyMMddHHmmss');
            String jobID = System.Schedule(schedulerName, timeForScheduler, schedulerClass);
            System.debug(changedExpDateOppSet + '\n\n7- Scheduled FiscalYearOnOpportunity-jobID = ' + jobID  + ' - ' + schedulerName);
        }
        if(!failureRecordSet.isEmpty()){
            if(this.calculationType.equalsIgnoreCase('RLI-OLI')){
                REN_AsyncMetricsFCalculationDispatcher.executeMe(schedulableContextObj, 'RLI', failureRecordSet, 1, false);
            }else if(this.calculationType.equalsIgnoreCase('RLI')){
                setRenewalMetricsStatusToError(failureRecordSet);
                if(!rliToOliRecordSet.isEmpty()){
                	REN_AsyncMetricsFCalculationDispatcher.executeMe(schedulableContextObj, 'OLI', rliToOliRecordSet, 1, false);
                }else{
	                if(schedulableContextObj != null){
						System.abortJob(schedulableContextObj.getTriggerId());
					}
                }
            }else if(this.calculationType.equalsIgnoreCase('OLI')){
                //failureRecordSet Mark error
                setRenewalMetricsStatusToError(failureRecordSet);
                if(schedulableContextObj != null){
					System.abortJob(schedulableContextObj.getTriggerId());
				}
            }
        }else{
            if(this.calculationType.equalsIgnoreCase('RLI')){
                REN_AsyncMetricsFCalculationDispatcher.executeMe(schedulableContextObj, 'OLI', rliToOliRecordSet, 1, false);
            }else{
            	Boolean isDataServicesUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_DataServicesUser);
            	if(this.calculationType.equalsIgnoreCase('OLI') && !isDataServicesUser){
       				//Rescheduling should be done only for DS user
                	if(schedulableContextObj != null){
						System.abortJob(schedulableContextObj.getTriggerId());
					}
       			}else if(changedExpDateOppSet.isEmpty()){
                    REN_AsyncMetricsFCalculationDispatcher.scheduleMe(schedulableContextObj, 'RLI-OLI', null);
                }else{
                	if(schedulableContextObj != null){
						System.abortJob(schedulableContextObj.getTriggerId());
					}
                }
            }
        }
    }
    
    public void setRenewalMetricsStatusToError(Set<ID> failureRecordSet) {
        DateTime dt = System.now();
        List<Opportunity> saveErrorOppList = new List<Opportunity>();
        for(ID oppId: failureRecordSet){
            saveErrorOppList.add(new Opportunity(id = oppId, REN_Renewal_Metrics_Status__c = 'Error', REN_Metrics_Calculation_Date__c = dt));
        }
		CSM_Util.checkCRUD_FLS('Opportunity', new List<String>{'Id', 'REN_Renewal_Metrics_Status__c', 'REN_Metrics_Calculation_Date__c'}, CSM_Constants.DML_OPERATION_UPDATE);
		
		List<Database.SaveResult> updateResults = Database.update(saveErrorOppList, false);// Stamp errors. Records will not re processed.
		String markedError ='';
		DateTime currentDateTime = System.now();
        for(Integer i=0;i<updateResults.size();i++){// These Opportunities could not updated at all in this transaction.
            if (!updateResults.get(i).isSuccess()){
            	markedError += updateResults[i].id + ', ';
            }
        }
        if(!String.isBlank(markedError)){
        	markedError = markedError.removeEnd(', ');
        	if(markedError.length() > 32000){
        		markedError = markedError.left(32000) + '...';
        	}
        	markedError = 'Could not marked error for Opportunity ID: ' + markedError;
	        CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = calculationType + '-REN_AsyncMetricsFieldCalBatch5: ' + markedError);
	        logger.addLogRecord(errObj, currentDateTime, CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, CSM_Constants.OBJ_TYPE_OPPORTUNITY, (schedulableContextObj == null ? null : schedulableContextObj.getTriggerId()));
        }
        logger.saveLogRecords();
        	            
    }
}