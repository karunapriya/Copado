public with sharing class REN_FiscalYearOppBatch implements Database.Batchable<SObject>, Database.Stateful{
    
    //public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
    public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
    public Set<ID> impactedOppId {get;set;}
    public SchedulableContext schedulableContextObj {get;set;}
    private Map<Id, Opportunity> impactedOppMap;
    private Set<ID> failureRecordSet {get;set;}
    
    private List<String> crudFlsOppty = new List<String>{'Id','REN_Earliest_Expiration_Date__c','REN_Renewal_Metrics_Status__c', 'REN_Metrics_Calculation_Date__c', 'REN_EQ__c', 'REN_FY__c'};
	public REN_FiscalYearOppBatch(){
		this.failureRecordSet = new Set<Id>();
	}
    
    public Database.queryLocator start(Database.BatchableContext batchContext){
        try{
            CSM_Util.checkCRUD_FLS('Opportunity', new List<String>(crudFlsOppty), CSM_Constants.DML_OPERATION_READ);
            String queryStr = 'SELECT '+ String.join(new List<String>(crudFlsOppty), ',') +' FROM Opportunity WHERE CHL_QuoteSyncStatus__c NOT IN (\'Scheduled\', \'In Progress\', \'Error\' ) AND REN_Renewal_Metrics_Status__c IN (\'Calculating\') AND ID IN: impactedOppId AND REN_Is_Sync_Pending__c != true';
            return Database.getQueryLocator(queryStr);
        }catch (Exception ex){
            System.debug('\n' + ex);
            CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true,  CSM_Error_Description__c = 'REN_FiscalYearOppBatch1: ' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
            logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, 'Opportunity', batchContext.getJobId());
            logger.saveLogRecords();
            system.abortJob(batchContext.getJobId());
        }
        return null;
    }
    
    public void execute(Database.BatchableContext batchContext,List<Opportunity> impactedOppList){
    	Savepoint savePoint = Database.setSavepoint();
        logger = CSM_BatchResultsLogger.getInstance();
        List<String> crudFlsRLI = new List<String>{'REN_Renewal_Target__c'};
		impactedOppMap = new Map<Id, Opportunity>(impactedOppList);
        failureRecordSet.addAll(impactedOppMap.keySet());
        try{  
            CSM_TriggerManager.disableAllTriggers();
            REN_OpportunityDataAccess.UpdateExpQuarterYear(impactedOppList, null);
            for(Opportunity opp : (List<Opportunity>)impactedOppList){
                opp.REN_Renewal_Metrics_Status__c = 'Calculated';
                opp.REN_Metrics_Calculation_Date__c = System.now();
            }
            CSM_Util.checkCRUD_FLS('Opportunity', new List<String>(crudFlsOppty), CSM_Constants.DML_OPERATION_UPDATE);
            //query to check if the records are not modified during processing
            Set<Id> impOppIdSet = impactedOppMap.keySet();
            String modifiedOptys = 'SELECT '+ String.join(new List<String>(crudFlsOppty), ',') +' FROM Opportunity WHERE ID IN: impOppIdSet AND (REN_Renewal_Metrics_Status__c NOT IN (\'Calculating\') OR REN_Is_Sync_Pending__c = true OR CHL_QuoteSyncStatus__c IN (\'Scheduled\', \'In Progress\', \'Error\' )) ';
            for(Opportunity oppModified : Database.query(modifiedOptys)){
                impactedOppMap.remove(oppModified.Id);
                failureRecordSet.remove(oppModified.Id);
            }
            impactedOppList = impactedOppMap.values();
            if(impactedOppList != null && !impactedOppList.isEmpty()){
	            List<Database.SaveResult> updateResults = Database.update(impactedOppList, false);
	            List<Opportunity> saveErrorOppList = new List<Opportunity>();
	            DateTime currentDateTime = System.now();
	            for(Integer i=0;i<updateResults.size();i++){
                	failureRecordSet.remove(impactedOppList.get(i).Id);
	                if (!updateResults.get(i).isSuccess()){
	                    saveErrorOppList.add(new Opportunity(id = impactedOppList.get(i).id, REN_Renewal_Metrics_Status__c = 'Error', REN_Metrics_Calculation_Date__c = currentDateTime));
	                    CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'REN_FiscalYearOppBatch2: ' + impactedOppList.get(i).id + ' - ' + updateResults.get(i).getErrors().get(0));
	                    logger.addLogRecord(errObj, currentDateTime, CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, CSM_Constants.OBJ_TYPE_OPPORTUNITY, batchContext.getJobId());
	                }
	            }
	            if(!saveErrorOppList.isEmpty()){
	            	String couldNotMarkedError ='';
					List<Database.SaveResult> updateErrorResults = Database.update(saveErrorOppList, false);// Stamp errors. Records will not re processed.
		            for(Integer i=0;i<updateErrorResults.size();i++){// These Opportunities could not updated at all in this transaction.
		                if (updateErrorResults.get(i).isSuccess()){
		                	failureRecordSet.remove(saveErrorOppList.get(i).Id);
		                }else{		                	
		                	couldNotMarkedError += saveErrorOppList.get(i).id + ', ';
		                }				
		            }
					if(!String.isBlank(couldNotMarkedError)){
			        	couldNotMarkedError = couldNotMarkedError.removeEnd(', ');
			        	if(couldNotMarkedError.length() > 32000){
			        		couldNotMarkedError = couldNotMarkedError.left(32000) + '...';
			        	}
			        	couldNotMarkedError = 'Could not marked error for Opportunity ID: ' + couldNotMarkedError;
				        CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'REN_FiscalYearOppBatch2.1: ' + couldNotMarkedError);
				        logger.addLogRecord(errObj, currentDateTime, CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, CSM_Constants.OBJ_TYPE_OPPORTUNITY, batchContext.getJobId());
			        }
	            }
	            logger.saveLogRecords();
            }
            //failureRecordSet.removeAll(impactedOppMap.keySet());
        }catch (Exception ex){
        	Database.rollback(savePoint);
            System.debug('\n' + ex);
            CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
            batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
            batchResult.CSM_Errors__c = true;
            batchResult.CSM_Error_Description__c = 'REN_FiscalYearOppBatch3: ' + JSON.serialize(impactedOppMap.keySet()) + '\nError: ' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString();
            //logger.setErrorFieldValues(batchResult, system.now(), true, JSON.serialize(impactedOppMap.keySet()) + '\nError: ' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
            logger.addLogRecord(batchResult, system.now(), CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, 'Opportunity', batchContext.getJobId());
            logger.saveLogRecords();
        }
    }
    
    public void finish(Database.BatchableContext batchContext){
    	System.debug('\n\n0- Call REN_FiscalYearOppBatch: Finidh: ' + 'SchedulableContextID: ' + schedulableContextObj);
        if(!failureRecordSet.isEmpty()){
            DateTime currentDateTime = System.now();
            List<Opportunity> saveErrorOppList = new List<Opportunity>();
            for(ID oppId: failureRecordSet){
                saveErrorOppList.add(new Opportunity(id = oppId, REN_Renewal_Metrics_Status__c = 'Error', REN_Metrics_Calculation_Date__c = currentDateTime));
            }
			CSM_Util.checkCRUD_FLS('Opportunity', new List<String>{'REN_Renewal_Metrics_Status__c', 'REN_Metrics_Calculation_Date__c'}, CSM_Constants.DML_OPERATION_UPDATE);
			List<Database.SaveResult> updateErrorResults = Database.update(saveErrorOppList, false);// Stamp errors. Records will not re processed.
			String couldNotMarkedError ='';
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
		        CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'REN_FiscalYearOppBatch.finish: ' + couldNotMarkedError);
		        logger.addLogRecord(errObj, currentDateTime, CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_FAILED, CSM_Constants.OBJ_TYPE_OPPORTUNITY, batchContext.getJobId());
	        }
	        logger.saveLogRecords();
 
        }
        if(schedulableContextObj != null){
			System.abortJob(schedulableContextObj.getTriggerId());
		}
        REN_AsyncMetricsFCalculationDispatcher.scheduleMe(null, 'RLI-OLI', null);
        
    }
    
}