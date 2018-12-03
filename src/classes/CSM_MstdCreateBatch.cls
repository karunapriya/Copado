public with sharing class CSM_MstdCreateBatch implements Database.Batchable<SObject>, Database.Stateful{

	//Variables
	private CSM_MSTR__c mstrObj{get; set;}
	public Map<String, CSM_MSTR__c> mstrUniqueKeyMap = new Map<String, CSM_MSTR__c>();
	public Map<String, CSM_MSTR__c> mstrUniqueKeyValueMap = new Map<String, CSM_MSTR__c>();
	
    public String errorDrtails = '';
    public Integer errorCount = 0; 
    public boolean isEmailRequired = false;
	

    private String lookupFieldName = '';

	public Database.queryLocator start(Database.BatchableContext BC){
		try{
			mstrObj = mstrUniqueKeyMap.values()[0];
			lookupFieldName = CSM_MultiSelectPicklistReportHandler.getLookupFieldName(mstrObj);
			String queryString = '';
			if(String.isBlank(lookupFieldName)){
				queryString = 'Select id from CSM_MSTD__c where ID = null';
				errorDrtails +=  '\n' + ++errorCount + '  : ' +  String.format(Label.REN_MSG_FIELD_IS_NOT_CREATED, new String[]{Schema.SObjectType.CSM_MSTD__c.label, mstrObj.CSM_Object_Name__c});
			}else{
				queryString = CSM_MultiSelectPicklistDataAccess.getQueryForFindDetailReportRecords(mstrObj);
			}
			System.debug(lookupFieldName + '\nCSM_MstdCreateBatch--------queryString:' + queryString);
			return Database.getQueryLocator(queryString);
		}catch (Exception ex){
			errorDrtails +=  '\n' + ++errorCount + '  : ' + ex.getMessage() + ' :: ' + ex.getStackTraceString();
			return Database.getQueryLocator('Select id from CSM_MSTD__c where ID = null');
		}
	}

	//Execute method
	public void execute(Database.BatchableContext BC,List<sObject> recordList){
		try{
			CSM_MultiSelectPicklistReportHandler.createDetailRecords(recordList, lookupFieldName, mstrUniqueKeyValueMap, mstrObj);
		}
		catch (exception ex){
    		errorDrtails +=  '\n' + ++errorCount + '  : ' + ex.getMessage() + ' :: '  + ex.getStackTraceString();
            system.debug('exception in execute $$ ' + errorDrtails);
        }
	}
	 
	public void finish(Database.BatchableContext BC){
		String uniqueMapKey = mstrObj.CSM_Object_Name__c + ':' + mstrObj.CSM_Multi_Picklist_API_Name__c;
		System.debug(mstrObj + '\n\n~~~~ CSM_MstdCreateBatch-Finished for:' + uniqueMapKey);
		mstrUniqueKeyMap.remove(uniqueMapKey);
		if(!mstrUniqueKeyMap.isEmpty()){
			CSM_MstdCreateBatch insertBatch = new CSM_MstdCreateBatch();
			insertBatch.mstrUniqueKeyMap = mstrUniqueKeyMap;
			insertBatch.mstrUniqueKeyValueMap = mstrUniqueKeyValueMap;
			insertBatch.errorCount = errorCount;
			insertBatch.errorDrtails = errorDrtails;
	        String batchprocessid = Database.executeBatch(insertBatch);
		}else{
			if(isEmailRequired){// Send eMail here
				CSM_MultiSelectPicklistReportHandler.sendConfirmedEmail(mstrObj);
			}
			if(String.isNotBlank(errorDrtails)){
				System.debug(errorCount + '\n\n~~~~~Error in Create Batch: ' + errorDrtails);
				CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
				CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: ' + errorDrtails);
				logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CSM, CSM_BatchResultsLogger.STATUS_FAILED, Schema.SobjectType.CSM_MSTR__c.label,	BC.getJobId());
				logger.saveLogRecords();
			}
			
		}
		CSM_Util.notifyUserBatchFailure(BC.getJobId());
	}
}