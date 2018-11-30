global with sharing class CSM_PlayResultBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful 
{
     public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	 public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
     
     global Integer countBatch;
     
     global CSM_PlayResultBatch()
     {
         countBatch = 0;
     }
        
     global CSM_PlayResultBatch(Integer statusNumber)
     {
         countBatch = statusNumber;
     }
     
     global Database.queryLocator start(Database.BatchableContext batchContext)
     {
     	String jobId = batchContext.getJobId();
     	try
     	{ 	
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CSM, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									CSM_Constants.OBJ_PR,
									jobId);
	        String namespace = CSM_Util.getNameSpace(); 
			
			 
				
				
				
	         String queryStr = 'SELECT ' + CSM_Constants.OBJ_PR_ID +
	                            ' FROM ' + namespace + CSM_Constants.OBJ_PR + 
	                           ' WHERE ' + namespace + CSM_Constants.OBJ_PR_PROCESSED + ' = false' +
	                            ' AND ' + namespace + CSM_Constants.OBJ_PR_FAILED + ' = false' +
	                            ' AND ' + namespace + CSM_Constants.OBJ_PR_STATUS_NUMBER + ' = ' +countBatch;	
	         
	         List<String> playResultFieldList = new List<String>{CSM_Constants.OBJ_PR_ID, 
	                 CSM_Constants.OBJ_PR_STATUS_NUMBER, CSM_Constants.OBJ_PR_PROCESSED, CSM_Constants.OBJ_PR_FAILED};
		     CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_PR, playResultFieldList, CSM_Constants.DML_OPERATION_READ);                  
	         System.debug('###start '+countBatch + ' query string ' + queryStr); 
	         return Database.getQueryLocator(queryStr);
	     }
	     catch (Exception ex){
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 
							'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			logger.saveLogRecords();
			system.abortJob(jobId);
		}
		return null;
     }
     
     global void execute(SchedulableContext SC)
     {
     	system.debug('### sc execute');
     	String batchprocessid = Database.executeBatch(this);
     }
     
     global void execute(Database.BatchableContext BC, List<sObject> playResults)
     {  
     	system.debug('### execute play results '+playResults);
     	
     	CSM_PlayResultTriggerHandler handler = new CSM_PlayResultTriggerHandler();
        handler.processAllPlayResults(playResults);
     }
     
     global void finish(Database.BatchableContext BC)
     {
        
        countBatch++;
        if (countBatch < 3)
        {   
           System.debug('###finish '+countBatch);
           Database.executeBatch(new CSM_PlayResultBatch(countBatch));
       }
       CSM_Util.notifyUserBatchFailure(BC.getJobId());   
    }
}