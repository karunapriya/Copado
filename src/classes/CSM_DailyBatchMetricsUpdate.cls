global with sharing class CSM_DailyBatchMetricsUpdate 
					implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful {

	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	private Map<String, Integer> planPlayAndTotalTasksMap;
	private Map<String, Integer> planPlayAndClosedTasksMap;	
	private integer totalRecords;
	//private integer counter = 0;
	
	String namespace = CSM_Util.getNameSpace();	
	
	//Schedulable method
    global void execute(SchedulableContext schedulerContext){ 
        String batchprocessid = Database.executeBatch(this,200);
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
									CSM_Constants.OBJ_APP,
									jobId);
			
	    	if(Test.isRunningTest()){
	    		if(CSM_DailyBatchMetricsUpdateTest.isNegative == true){
					queryStr = 'SELECT Id,';
					return Database.getQueryLocator(queryStr);	 
	    		}   	
	    	}

			return Database.getQueryLocator('select id from ' + namespace +'CSM_SuccessPlan_Play__c where (' + namespace +'CSM_Play_Outcome__c = null or '  + namespace +'CSM_Play_Outcome__c = \'\') and ' + namespace + 'CSM_Status__c != \'Completed\'');
			//return CSM_TaskDataAccess.getQueryLocatorTaskBatch();
		}catch (Exception ex){
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 
							'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			//logger.saveLogRecords(); 
			system.abortJob(jobId);
		}
		return null;
	}


	
	global void execute(Database.BatchableContext batchContext, List<Task> taskList){
	
	}

	//Execute method
	global void execute(Database.BatchableContext batchContext, List<SObject> spplList){
		Map<ID, CSM_SuccessPlan_Play__c> spPlayMap = new Map<ID,CSM_SuccessPlan_Play__c>((List<CSM_SuccessPlan_Play__c>)spplList);
        Map<ID,Integer> openTaskMap = new Map<ID,Integer>();
        Map<ID,Integer> closedTaskMap = new Map<ID,Integer>();
        try{
            for(Task playTask: [select Id, isClosed, CSM_SuccessPlan_Play__c from 
                                Task where CSM_SuccessPlan_Play__c IN :spPlayMap.keySet()]){
                
                if(!openTaskMap.containsKey(playTask.CSM_SuccessPlan_Play__c)){
                    openTaskMap.put(playTask.CSM_SuccessPlan_Play__c, 0);
                    closedTaskMap.put(playTask.CSM_SuccessPlan_Play__c, 0);
                }
                if(playTask.isClosed != null && playTask.isClosed){
                    closedTaskMap.put(playTask.CSM_SuccessPlan_Play__c, closedTaskMap.get(playTask.CSM_SuccessPlan_Play__c) + 1);
                }
                else{
                    openTaskMap.put(playTask.CSM_SuccessPlan_Play__c, openTaskMap.get(playTask.CSM_SuccessPlan_Play__c) + 1);
                }
            
            } 
            for(CSM_SuccessPlan_Play__c spp:spPlayMap.values()){
                if(openTaskMap.containsKey(spp.id)){
                   spp.CSM_Number_of_Closed_Tasks__c = closedTaskMap.get(spp.id);
                   spp.CSM_Total_number_of_Tasks__c = spp.CSM_Number_of_Closed_Tasks__c + openTaskMap.get(spp.id);
                }else{
                   spp.CSM_Number_of_Closed_Tasks__c = 0;
                   spp.CSM_Total_number_of_Tasks__c = 0;
                }
            }
            
            CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;
            update spPlayMap.values();

 			logger.updateRecordsProcessed(batchResult, spplList.size()); // + closedTaskList.size()
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