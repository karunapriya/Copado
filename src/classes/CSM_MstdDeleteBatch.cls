public with sharing class CSM_MstdDeleteBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful{

	//Variables
	public CSM_MSTR__c mstrObj{get; set;}
	private Map<String, CSM_MSTR__c> mstrUniqueKeyMap = new Map<String, CSM_MSTR__c>();
	private Map<String, CSM_MSTR__c> mstrUniqueKeyValueMap = new Map<String, CSM_MSTR__c>();
    private Integer errorCount = 0; 
    private boolean isEmailRequired = false;
    private String errorDrtails = '';
    @TestVisible private boolean isStartFailed = false;
	

	//Schedulable method
    public void execute(SchedulableContext SC){   
        String batchprocessid = Database.executeBatch(this);
        //System.abortJob(SC.getTriggerId());
    }
    
	//For QueryLocator the governor limit for the total number of records retrieved by SOQL queries is bypassed.  A maximum of 50 million records can be returned
	public Database.queryLocator start(Database.BatchableContext BC){
		try{
			isEmailRequired = mstrObj != null;
			String queryString = CSM_MultiSelectPicklistDataAccess.getQueryForFindReports(mstrObj);
			List <CSM_MSTR__c> mstrList = Database.query(queryString);
			for(CSM_MSTR__c mstr: mstrList){
				String uniqueMapKey = mstr.CSM_Object_Name__c + ':' + mstr.CSM_Multi_Picklist_API_Name__c;
				mstrUniqueKeyMap.put(uniqueMapKey, mstr);
				mstrUniqueKeyValueMap.put(uniqueMapKey + ':' + mstr.CSM_Picklist_Value__c, mstr);
			}
			Map<ID, CSM_MSTR__c> mstrMap = new Map<ID, CSM_MSTR__c>(mstrList); 
			Set<ID> mstrSet = mstrMap.keySet();
			queryString = 'Select ID from CSM_MSTD__c WHERE CSM_MSTR__c in :mstrSet';
			CSM_Util.checkCRUD_FLS('CSM_MSTD__c', New List<String>{'id'}, CSM_Constants.DML_OPERATION_READ);
			return Database.getQueryLocator(queryString);
		}catch (Exception ex){
			isStartFailed = true;
			errorDrtails +=  '\n' + ++errorCount + '  : ' + ex.getMessage() + ' :: ' + ex.getStackTraceString();
			return Database.getQueryLocator('Select id from CSM_MSTD__c where ID = null');
		}
	}

	//Execute method
	public void execute(Database.BatchableContext BC,List<CSM_MSTD__c> recordList){
		try{
			CSM_MultiSelectPicklistDataAccess.deleteMstdRecords(recordList);
		}catch (exception ex){
    		errorDrtails +=  '\n' + ++errorCount + '  : ' + ex.getMessage() + ' :: '  + ex.getStackTraceString();
    		system.debug('exception in execute $$ ' + errorDrtails);
        }
	}
	 
	public void finish(Database.BatchableContext BC){
		if(isStartFailed || mstrUniqueKeyMap.isEmpty()){
			System.debug(errorCount + '\n\n~~~~~Error in Delete Batch: ' + errorDrtails);
			CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
			CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = (isStartFailed ? 'Error: ' + errorDrtails : 'Info: ' + String.format(Label.REN_MSG_NO_RECORD_FOUND, new String[]{'MSTR'})));
			logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CSM, CSM_BatchResultsLogger.STATUS_PENDING, Schema.SobjectType.CSM_MSTR__c.label,	BC.getJobId());
			logger.saveLogRecords();
		}else{
			CSM_MstdCreateBatch insertBatch = new CSM_MstdCreateBatch();
			insertBatch.mstrUniqueKeyMap = mstrUniqueKeyMap;
			insertBatch.mstrUniqueKeyValueMap = mstrUniqueKeyValueMap;
			insertBatch.errorCount = errorCount;
			insertBatch.errorDrtails = errorDrtails;
			insertBatch.isEmailRequired = isEmailRequired;
	        String batchprocessid = Database.executeBatch(insertBatch);
		}
		CSM_Util.notifyUserBatchFailure(BC.getJobId());
	}
}