global with sharing class CSM_CasePlayTaskCreationBatch 
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
									CSM_Constants.OBJ_CASE,
									jobId);
			
			List<String> caseFieldList = new List<String>{CHL_Constants.CASE_ACCOUNTID};
    	    CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_CASE, caseFieldList, CSM_Constants.DML_OPERATION_READ);
			
			String namespace = CSM_Util.getNameSpace(); 
			Datetime queryDate = Test.isRunningTest()?(system.now() + 1):(system.now());
			//Added for US1682
			String batchFilterQuery = CSM_Util.getBatchFilterQueryString('CSM_CaseBatchCreatePlaySchdDispatcher');
			if(!String.isBlank(batchFilterQuery)){
				queryStr = batchFilterQuery;
			}else {
			    queryStr = 'SELECT Id, AccountId FROM Case where iSClosed=false and LastModifiedDate <= :queryDate and AccountId in ( Select ' + 
								+ namespace +'CSM_AccountId__c FROM ' + namespace + 'CSM_Account_Plan__c)'; 
			}
	    	if(Test.isRunningTest()){
	    		if(CSM_CasePlayTaskCreationBatchTest.isNegative == true){
					queryStr = 'SELECT Id,';	 
	    		}   	
	    	}
			system.debug('queee' + querystr);
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
	global void execute(Database.BatchableContext batchContext, List<Case> caseList){

		String jobId = batchContext.getJobId();
		Set<Id> accountIds = new Set<Id>();
		try{
			for(Case caseObj : caseList) {
				accountIds.add(caseObj.AccountId);
			}
 			CSM_TaskCreationTriggerUtil.CreatePlayActivities(accountIds, caseList, CSM_Constants.OBJ_CASE);
 			
 			logger.updateRecordsProcessed(batchResult, caseList.size());
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