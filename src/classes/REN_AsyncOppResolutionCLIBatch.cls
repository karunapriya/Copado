/**
 * Created Date		: Sep 30, 2016
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * admin					User Story				Sep 30, 2016			1.1					@description
 *
 */
global with sharing class REN_AsyncOppResolutionCLIBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful {
    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
    private CSM_Batch_Result__c batchResult = new CSM_Batch_Result__c();
	private CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	//Schedulable method
    global void execute(SchedulableContext schedulerContext) {   
    	Integer batchSize = CSM_Util.getCustomListSetting('REN_AsyncOppResolutionCLIBatch');
    	batchSize = (batchSize == null || batchSize == 0) ? 1 : batchSize;
        String batchprocessid = Database.executeBatch(this,batchSize);
    }
	//For QueryLocator the governor limit for the total number of records retrieved by SOQL queries is bypassed.  
	//A maximum of 50 million records can be returned
	global Database.queryLocator start(Database.BatchableContext batchContext) {
		String jobId = batchContext.getJobId();
		try{
			logger.addLogRecord(batchResult, system.now(), 
				CSM_BatchResultsLogger.MODULE_RENEW, 
				CSM_BatchResultsLogger.STATUS_PENDING, 
				CSM_Constants.OBJ_ACCOUNT,jobId);
			
			String soqlStr = 'Select r.REN_Source_Opportunity__c'
							+ (CSM_AccessController.hasField('REN_Renewal_Processing_Status__c', CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c') ? (', r.' + CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c') : '')
							+ ', r.REN_Renewal_Opportunity__c, r.Id From REN_Renewal_Processing_Status__c r WHERE r.REN_Is_all_required_CLI_created__c= FALSE';
			system.debug('soqlStr : ' + soqlStr);
			return Database.getQueryLocator(soqlStr);
		}catch (Exception ex) {
			batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_FAILED;
			logger.setErrorFieldValues(batchResult, system.now(), true, 'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			logger.saveLogRecords();
			System.abortJob(jobId);
			return null;
		}
	}
	//Execute method
	global void execute(Database.BatchableContext batchContext, List<SObject> renewProcessStatusList) {
		try{
			CSM_TriggerManager.disableAllTriggers();
			List<REN_Line_Processing_Status__c> lineProcessStatusList = new List<REN_Line_Processing_Status__c>();
			Set<Id> renProcessingIds = new Set<Id>();
			for(sObject renProcess: renewProcessStatusList){
				renProcessingIds.add((Id)renProcess.get('Id'));
			}
			String namespace = CSM_Util.getNameSpace();
			String lpsKnownFields = namespace + 'REN_Failure_Msg__c,' + namespace + 'REN_Failure__c,' + namespace + 'REN_Renewal_Contract_Line_Item_Id__c,' + namespace+'REN_Source_OLI_Id__c,' + namespace+'REN_Product__c,' + namespace+'REN_CLI_Qualified__c,' + namespace+'REN_Renewal_Processing_Status__c';
			String queryString = 'Select ' + lpsKnownFields + ' From REN_Line_Processing_Status__c WHERE  REN_CLI_Qualified__c = TRUE AND REN_Renewal_Contract_Line_Item_Id__c = null AND (REN_Renewal_Asset_Id__c != null OR (((REN_OLI_Qualified__c = TRUE AND REN_Renewal_OLI_Id__c != null) OR REN_OLI_Qualified__c = FALSE)) ) AND REN_Renewal_Processing_Status__c IN :renProcessingIds';
			system.debug('\nqueryString::CLI::'+queryString);
			lineProcessStatusList = Database.query(queryString);
			
			REN_AsyncOppRenewalCLIBatchHelper.processContractLineItems(lineProcessStatusList);
			Map<ID, SObject> renewProcessStatusMap = new Map<ID, SObject>(renewProcessStatusList);
			REN_AsyncOppRenewalBatchHelper.checkAndMarkRenewalCompleted(renewProcessStatusMap.keySet());
		}
		catch (exception ex) {
			logger.setErrorFieldValues(batchResult, system.now(), true, 'Error: ' + ex.getMessage() + '; Stack Trace:' + ex.getStackTraceString());
			logger.saveLogRecords();
        }
	}
	global void finish(Database.BatchableContext batchContext) {
		batchResult.CSM_Status__c = CSM_BatchResultsLogger.STATUS_COMPLETED;
		batchResult.CSM_Batch_Completion_Time__c = system.now();
		logger.saveLogRecords();
		REN_AsyncOppResolutionRRBatch batch=new REN_AsyncOppResolutionRRBatch();
		Integer batchSize = CSM_Util.getCustomListSetting('REN_AsyncOppResolutionRRBatch');
		batchSize = (batchSize == null || batchSize == 0) ? 1 : batchSize;
		database.executebatch(batch,batchSize);
	}
}