global with sharing class CSM_BatchUpdateTaskWithSPPL 
					implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful {

	public CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	public CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	private Map<Id, String> templateAndPlaybookMap;
	private integer totalRecords;
	private integer counter = 0;
	
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
									CSM_Constants.OBJ_APP,
									jobId);
			
			return Database.getQueryLocator('select Id, CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__c, CSM_Play__c, CSM_SuccessPlan_Playbook__r.CSM_Playbook__c '+
											'FROM CSM_SuccessPlan_Play__c Where CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__c != NULL');

		}catch (Exception ex){
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 
							'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			system.abortJob(jobId);
		}
		return null;
	}
	
	global void execute(Database.BatchableContext batchContext, List<CSM_Task_Processing__c> taskProcessingList){}

	//Execute method
	global void execute(Database.BatchableContext batchContext, List<SObject> sObjectList){
		List<String> fieldListOfTask = new List<String>{CSM_Constants.OBJ_T_SUCCESS_PLAN_PLAY};
		String jobId = batchContext.getJobId();
		try{
			List<CSM_SuccessPlan_Play__c> spPlayList = (List<CSM_SuccessPlan_Play__c>)sObjectList;
			Map<String,Id> planPlayMap = new Map<String,String>();
			Set<Id> playIds = new Set<Id>();
			for(CSM_SuccessPlan_Play__c spPlay : spPlayList){
				playIds.add(spPlay.CSM_Play__c);
				planPlayMap.put(spPlay.CSM_SuccessPlan_Playbook__r.CSM_Account_Plan__c + ':' + spPlay.CSM_Play__c, spPlay.Id);
			}		
			
			List<CSM_Task_Processing__c> taskProcessingList = [Select Id, CSM_Success_Plan__c, CSM_Play__c, 
																CSM_Task_Id__c 
																From CSM_Task_Processing__c 
																Where CSM_Play__c IN:playIds AND CSM_Play__r.CSM_Automated__c = false Limit 10000];
				
			List<Task> taskList = new List<Task>();
			for(CSM_Task_Processing__c taskProcessing: taskProcessingList){
				Id successPlanPlayId = planPlayMap.get(taskProcessing.CSM_Success_Plan__c + ':' +  taskProcessing.CSM_Play__c);
				if(successPlanPlayId != null){
					taskProcessing.CSM_SuccessPlan_Play__c = successPlanPlayId;
					Task tsk = new Task(Id = taskProcessing.CSM_Task_Id__c );
					tsk.CSM_SuccessPlan_Play__c = successPlanPlayId;
					taskList.add(tsk);
				}
			}
			CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, fieldListOfTask, CSM_Constants.DML_OPERATION_UPDATE);
			update taskProcessingList;
			update taskList;
 			logger.updateRecordsProcessed(batchResult, sObjectList.size() );
		}
		catch (exception ex){
			logger.setErrorFieldValues(batchResult, system.now(), true, 
				'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
        }
	}
	 
	global void finish(Database.BatchableContext batchContext){

		logger.updateBatchStatus(batchResult, CSM_BatchResultsLogger.STATUS_COMPLETED, system.now());
		logger.saveLogRecords();
	}
	
}