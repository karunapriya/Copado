@isTest
private class CSM_BatchResultsLoggerTest {
    
    static testMethod void Test_BatchLogger() {
    	CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
    	system.assert(logger != null);
    	CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
    	logger.addLogRecord(batchResult, system.now(), 
    							CSM_BatchResultsLogger.MODULE_CSM, 
    							CSM_BatchResultsLogger.STATUS_PENDING, 
    							CSM_Constants.OBJ_ACCOUNT,
    							'');
    	system.assert(batchResult.CSM_Batch_Start_Time__c != null);
    	system.assert(batchResult.CSM_Module__c != null);
    	system.assert(batchResult.CSM_Status__c != null);
    	system.assert(batchResult.CSM_Objects_Processed__c != null);
    	
    	logger.setErrorFieldValues(batchResult, system.now(), true, 'Test Description');
    	system.assert(batchResult.CSM_Batch_Completion_Time__c != null);
    	system.assertEquals(batchResult.CSM_Errors__c, true);
    	system.assert(batchResult.CSM_Error_Description__c != null);
    	
    	logger.setErrorFieldValues(batchResult, system.now(), true, 'Test Description');
    	system.assert(batchResult.CSM_Error_Description__c != null);
    	
    	logger.updateRecordsProcessed(batchResult, 200);
    	system.assertEquals(batchResult.CSM_Records_Processed__c, 200);
    	
    	logger.updateRecordsProcessed(batchResult, 200);
    	system.assertEquals(batchResult.CSM_Records_Processed__c, 400);
    	
    	logger.updateBatchStatus(batchResult, CSM_BatchResultsLogger.STATUS_COMPLETED, system.now());
    	system.assert(batchResult.CSM_Batch_Completion_Time__c != null);
    	system.assertEquals(batchResult.CSM_Status__c, CSM_BatchResultsLogger.STATUS_COMPLETED);
    	
    	logger.addLogRecord(null, system.now(), 
						CSM_BatchResultsLogger.MODULE_CSM, 
						CSM_BatchResultsLogger.STATUS_PENDING, 
						CSM_Constants.OBJ_ACCOUNT,
						'');
    	
    	logger.saveLogRecords();
    	system.assert(batchResult.Id != null);
    	
    }
}