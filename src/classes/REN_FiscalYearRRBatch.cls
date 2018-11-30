public with sharing class REN_FiscalYearRRBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful{
	
	public String objectName = CSM_Util.getNameSpace()+ REN_Constants.OBJ_REN_RENEWS_TO;
	private String fieldName = CSM_Util.getNameSpace()+ REN_Constants.OBJ_REN_RENEWS_TO_END_DATE;
	private CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	
	//Schedulable method
    public void execute(SchedulableContext SC){  
    	Integer batchSize = CSM_Util.getCustomListSetting('REN_FiscalYearRRBatch'); 
    	batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
        String batchprocessid = Database.executeBatch(this,batchSize);
        //System.abortJob(SC.getTriggerId());
    }
    
	public Database.queryLocator start(Database.BatchableContext batchContext){
		try{  
			String queryStr = 'Select ' + fieldName + ' from '+objectName +'  WHERE REN_Is_End_Date_Modified__c = true ' + (Test.IsRunningTest() ? ' LIMIT 10 ' : '');
			List<String> fieldList = new List<String>{REN_CONSTANTS.FLD_ID, REN_CONSTANTS.OBJ_OPP_EQ,REN_CONSTANTS.OBJ_OPP_FY};
			CSM_Util.checkCRUD_FLS(objectName, fieldList, CSM_Constants.DML_OPERATION_UPDATE);
			return Database.getQueryLocator(queryStr);
		}catch (Exception ex){
			System.debug('\n' + ex);
			CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true,  CSM_Error_Description__c = 'Error: ' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
			logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_PENDING, objectName,	batchContext.getJobId());
			logger.saveLogRecords();
			system.abortJob(batchContext.getJobId());
		}
		return null;
	}
	
    public void execute(Database.BatchableContext batchContext,List<SObject> recordList){
    	CSM_TriggerManager.disableAllTriggers();
		logger = CSM_BatchResultsLogger.getInstance();
		try{  
			REN_Util.resetTriggersTo(false);
			REN_OpportunityDataAccess.calculateExpQuarterYear(recordList,fieldName);
			String endDateModifiedField = CSM_Util.getNameSpace() + 'REN_Is_End_Date_Modified__c'; 
			for(sObject newRec: recordList){
				newRec.put(endDateModifiedField, false);
			}
			List<Database.SaveResult> queryResultList = Database.update(recordList , false);
			for(Database.SaveResult result: queryResultList){
	            if (!result.isSuccess()){
	            	CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: ' + result.getId() + ' - ' + result.getErrors().get(0));
					logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_PENDING, objectName,	batchContext.getJobId());
	            }
			}
			logger.saveLogRecords();
		}catch (Exception ex){
			System.debug('\n' + ex);
			CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: ' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
			logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_RENEW, CSM_BatchResultsLogger.STATUS_PENDING, objectName,	batchContext.getJobId());
			logger.saveLogRecords();
		}
    }

	public void finish(Database.BatchableContext batchContext){
		logger.saveLogRecords();
	    CSM_Util.notifyUserBatchFailure(batchContext.getJobId());
	}

}