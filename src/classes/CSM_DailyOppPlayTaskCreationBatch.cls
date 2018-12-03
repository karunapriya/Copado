global with sharing class CSM_DailyOppPlayTaskCreationBatch 
					implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful {

	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	
	//Schedulable method
    global void execute(SchedulableContext schedulerContext){ 
		Integer batchSize = (Integer)CSM_Admin__c.getOrgDefaults().CSM_Batch_Size__c; 
		if(batchSize == null || batchSize == 0){
			batchSize = 4;
		} 
        String batchprocessid = Database.executeBatch(this,batchSize);
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
			Date queryDate = Test.isRunningTest()?(system.today()):(system.today() - 1);
			String batchFilterQuery = CSM_Util.getBatchFilterQueryString('CSM_DailyOppBatchCreatePlaySchdDispatchr');
			//Added for US1682
			if(!String.isBlank(batchFilterQuery)){
				queryStr = batchFilterQuery;
			}else {
				queryStr = 'SELECT Id, AccountId FROM Opportunity where isClosed = false and AccountId in ( Select ' + 
								+ namespace +'CSM_AccountId__c FROM ' + namespace + 'CSM_Account_Plan__c)';
			}
	    	if(Test.isRunningTest()){
	    		if(CSM_DailyOppPlayTaskCreationBatchTest.isNegative == true){
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