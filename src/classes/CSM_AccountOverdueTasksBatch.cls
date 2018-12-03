global with sharing class CSM_AccountOverdueTasksBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful{

	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	
	//Schedulable method
    global void execute(SchedulableContext schedulerContext){   
        String batchprocessid = Database.executeBatch(this);
        //System.abortJob(schedulerContext.getTriggerId());
    }
    
	// For QueryLocator the governor limit for the total number of records retrieved by SOQL queries is bypassed.  
	// A maximum of 50 million records can be returned
	global Database.queryLocator start(Database.BatchableContext batchContext){
		
		String jobId = batchContext.getJobId();
		//jobId = jobId.substring(0,15);
		try{   
			logger.addLogRecord(batchResult, system.now(), 
									CSM_BatchResultsLogger.MODULE_CSM, 
									CSM_BatchResultsLogger.STATUS_PENDING, 
									CSM_Constants.OBJ_ACCOUNT,jobId);
			return CSM_AccountPlanDataAccess.getQueryLocatorAccountPlanBatch();
			
		}catch (Exception ex){
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 
							'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			logger.saveLogRecords();
			
			System.abortJob(jobId);
		}
		return null;
	}

	//Execute method
	global void execute(Database.BatchableContext batchContext, List<CSM_Account_Plan__c> accountPlanList){
		//String jobId = batchContext.getJobId();
		try{
			//system.debug('accplnlist - ' + accountPlanList);
			Set<Id> accountNoOverdueTasksSet = new Set<Id>();			
			List<Task> taskList = CSM_TaskDataAccess.getOverdueTasksByAccountPlan(accountPlanList);
			Map<Id, Integer> accountPlanToOverdueTaskMap = countOverdueTasksForAccountPlan(taskList);
			List<Account> updateAccountList = setAccountOverdueTaskCount(accountPlanList, 
													accountPlanToOverdueTaskMap, accountNoOverdueTasksSet);
			resetOverdueTaskOnAccount(updateAccountList, accountNoOverdueTasksSet);
			CSM_AccountDataAccess.updateOverdueTasks(updateAccountList);	
 			logger.updateRecordsProcessed(batchResult, accountPlanList.size());
		}
		catch (exception ex){
			logger.setErrorFieldValues(batchResult, system.now(), true, 
				'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			logger.saveLogRecords();				
        }
	}
	
	private void resetOverdueTaskOnAccount(List<Account> updateAccountList, Set<Id> accountNoOverdueTasksSet){
		if(accountNoOverdueTasksSet != null && !accountNoOverdueTasksSet.isEmpty()){
			List<Account> listAccount = CSM_AccountDataAccess.getOverdueTaskCountAcct(accountNoOverdueTasksSet);
			for(Account accountNoOverdueTask : listAccount){
				if(accountNoOverdueTask.CSM_Overdue_Tasks_Count__c > 0){
					accountNoOverdueTask.CSM_Overdue_Tasks_Count__c = null;	
					updateAccountList.add(accountNoOverdueTask);									
				}
			}
		}
	}
	
	private Map<Id, Integer> countOverdueTasksForAccountPlan(List<Task> taskList){
		Map<Id, Integer> accountPlanToOverdueTaskMap = new Map<Id, Integer>();
		if(taskList != null){
			for(Task task : taskList){
				if(accountPlanToOverdueTaskMap.containsKey(task.CSM_Account_Plan__c)){
					Integer count = accountPlanToOverdueTaskMap.get(task.CSM_Account_Plan__c);
					count++;
					accountPlanToOverdueTaskMap.put(task.CSM_Account_Plan__c, count);
				}else{
					accountPlanToOverdueTaskMap.put(task.CSM_Account_Plan__c, 1);
				}
			}
		}
		return accountPlanToOverdueTaskMap;
	}
	
	private List<Account> setAccountOverdueTaskCount(List<CSM_Account_Plan__c> accountPlanList, 
														Map<Id, Integer> accountToOverdueTaskMap,
														Set<Id> accountNoOverdueTasksSet){
		List<Account> updateAccountList = new List<Account>();
		for(CSM_Account_Plan__c accountPlan : accountPlanList){
			if(accountToOverdueTaskMap.containsKey(accountPlan.Id)){
				updateAccountList.add(new Account(Id=accountPlan.CSM_AccountId__c, 
						CSM_Overdue_Tasks_Count__c=accountToOverdueTaskMap.get(accountPlan.Id)));
			}else{
				accountNoOverdueTasksSet.add(accountPlan.CSM_AccountId__c);
			}
		}
		return updateAccountList;
	}
	 
	global void finish(Database.BatchableContext batchContext){
		batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_COMPLETED;
		batchResult.CSM_Batch_Completion_Time__c = system.now();
		logger.saveLogRecords();
		CSM_Util.notifyUserBatchFailure(batchContext.getJobId());
	}
}