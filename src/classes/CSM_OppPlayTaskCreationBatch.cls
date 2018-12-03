global with sharing class CSM_OppPlayTaskCreationBatch 
					implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful {

	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	
	//Schedulable method
    global void execute(SchedulableContext schedulerContext){ 
        String batchprocessid = Database.executeBatch(this,1);
    }
    
	//For QueryLocator the governor limit for the total number of records retrieved by SOQL queries is bypassed.  
	//A maximum of 50 million records can be returned
	global Database.queryLocator start(Database.BatchableContext batchContext){
		String jobId = batchContext.getJobId();
		String queryStr = '';
		try{   
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CSM, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									CSM_Constants.OBJ_TYPE_OPPORTUNITY,
									jobId);
			
			String namespace = CSM_Util.getNameSpace(); 
			Datetime queryDate = Test.isRunningTest()?(system.now() + 1):(system.now());
			
			queryStr = 'SELECT Id, AccountId FROM Opportunity where LastModifiedDate <= : queryDate and AccountId in ( Select ' + 
								+ namespace +'CSM_AccountId__c FROM ' + namespace + 'CSM_Account_Plan__c)';
			
	    	if(Test.isRunningTest()){
	    		if(CSM_OppPlayTaskCreationBatchTest.isNegative == true){
					queryStr = 'SELECT Id,';	 
	    		}   	
	    	}

            CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_OPPORTUNITY, new List<String>{
    		CSM_Constants.OBJ_O_ID, CSM_Constants.OBJ_O_ACCOUNT_ID}, 
    	    CSM_Constants.DML_OPERATION_READ);
            
			return Database.getQueryLocator(queryStr);
		}catch (Exception ex){
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 
							'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			//logger.saveLogRecords();
			system.abortJob(jobId);
		}
		return null;
	}

	//Execute method
	global void execute(Database.BatchableContext batchContext, List<Opportunity> oppList){
		String jobId = batchContext.getJobId();
		Set<Id> accountIds = new Set<Id>();
		try{
			for(Opportunity oppt : oppList) {
				accountIds.add(oppt.AccountId);
			}
 			CSM_TaskCreationTriggerUtil.CreatePlayActivities(accountIds, oppList, CSM_Constants.OBJ_TYPE_OPPORTUNITY);
 			
 			logger.updateRecordsProcessed(batchResult, oppList.size());
		}
		catch (exception ex){
			logger.setErrorFieldValues(batchResult, system.now(), true, 
				'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
        }
	}
	 
	global void finish(Database.BatchableContext batchContext){
		logger.updateBatchStatus(batchResult, CSM_BatchResultsLogger.STATUS_COMPLETED, system.now());
		logger.saveLogRecords();
		CSM_Util.notifyUserBatchFailure(batchContext.getJobId());
	}
}