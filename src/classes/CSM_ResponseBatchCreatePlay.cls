global with sharing class  CSM_ResponseBatchCreatePlay 
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
									CSM_Constants.OBJ_RESPONSE,
									jobId);
			
			List<String> responseFieldList = new List<String>{CSM_Constants.OBJ_RID,CSM_Constants.OBJ_RESPONSE_OBJECT_ID};
    	    CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_RESPONSE, responseFieldList, CSM_Constants.DML_OPERATION_READ);
			
			String namespace = CSM_Util.getNameSpace(); 
			//Datetime queryDate = Test.isRunningTest()?(system.now() + 1):(system.now() - 1);
			Date queryDate = Test.isRunningTest()?(system.today()):(system.today());			
			
			/*List<String> acctIds = new List<String>();
			List<String> acctIdsTrunc = new List<String>();
						
			List<CSM_Account_Plan__c> acctPlans = [Select CSM_AccountId__c FROM CSM_Account_Plan__c limit 10000];
			if(acctPlans != null){
				for(CSM_Account_Plan__c acctPlan: acctPlans){
					if(acctPlan.CSM_AccountId__c != null){
						acctIds.add(acctPlan.CSM_AccountId__c);
						acctIdsTrunc.add(String.ValueOf(acctPlan.CSM_AccountId__c).subString(0,15));					
					}
				}
			}
			system.debug('lueee' + acctIdsTrunc + '        ' + acctIds);*/	
			//Added for US1682
			String batchFilterQuery = CSM_Util.getBatchFilterQueryString('CSM_ResponseBatchCreatePlaySchdDispatchr');
			if(!String.isBlank(batchFilterQuery)){
				queryStr = batchFilterQuery;
			}else {
			    //queryStr = 'SELECT Id, ' + namespace + 'CSM_Account__c FROM ' + namespace + 'CSM_Survey_Response__c where  DAY_ONLY(LastModifiedDate) = :queryDate and ' + namespace + 'CSM_Account__c  in  (Select CSM_AccountId__c FROM CSM_Account_Plan__c) limit 10000';
			    queryStr = 'SELECT Id, ' + namespace + 'CSM_Account__c FROM ' + namespace + 'CSM_Survey_Response__c where  LastModifiedDate < :queryDate and ' + namespace + 'CSM_Account__c  in  (Select CSM_AccountId__c FROM CSM_Account_Plan__c) limit 10000';							 
                //queryStr = 'SELECT Id, ' + namespace + 'CSM_Object_Id__c FROM ' + namespace + 'CSM_Survey_Response__c where  DAY_ONLY(LastModifiedDate) = :queryDate and (' + namespace + 'CSM_Object_Id__c  in: acctIds or ' + namespace + 'CSM_Object_Id__c  in: acctIdsTrunc)  ';
			}
	    	if(Test.isRunningTest()){
	    		if(CSM_ResponseBatchCreatePlayTest.isNegative == true){
					queryStr = 'SELECT Id,';	 
	    		}  	
	    	}
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
	global void execute(Database.BatchableContext batchContext, List<CSM_Survey_Response__c> responseList){
		system.debug('reeeeesp  -' + responseList);
		String jobId = batchContext.getJobId();
		Set<Id> accountIds = new Set<Id>();
		try{
			for(CSM_Survey_Response__c responseObj : responseList) {
				accountIds.add(responseObj.CSM_Account__c);
			}
 			CSM_TaskCreationTriggerUtil.CreatePlayActivities(accountIds, responseList, CSM_Constants.OBJ_RESPONSE); //CSM_Constants.OBJ_RESPONSE
 			
 			logger.updateRecordsProcessed(batchResult, responseList.size());
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