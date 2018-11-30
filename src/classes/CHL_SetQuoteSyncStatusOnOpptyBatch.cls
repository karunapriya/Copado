/**
 * Created Date     : March 30, 2018
 * Developed By     : Rucha Palasapure, Comity Designs, Inc.
 * Function         : @description - This Batch is used to set CHL_QuoteSyncStatus__c as "None" when all the QLIs are processed in CHL_QuoteSyncBatch. .
 						
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Rucha Palasapure       US3274 & US3273     March 30, 2018        1.1                 @description
 *
 */

global with sharing class CHL_SetQuoteSyncStatusOnOpptyBatch implements Database.Batchable<sObject>, Database.Stateful {
	global Set<Id> allOppIdsSet;
	global Set<Id> failureOppIdSet;
	global Set<Id> nonDSOppIdsSet;
	public Set<Id> successOppIdsSet = new Set<Id>();
	private CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();

	global Database.queryLocator start(Database.BatchableContext batchContext){
		try{
			String solnExtNamespace = CSM_Util.nameSpacePrefixSolnExtn;
			Boolean hasCommitLevel = CSM_AccessController.hasField('Opportunity',solnExtNamespace +'Commit_Level__c');
	 		Boolean hasFirstQuoteCompletedDate = CSM_AccessController.hasField('Opportunity',solnExtNamespace + 'First_Quote_Completed_Date__c');
		 	CSM_Util.checkCRUD_FLS('Opportunity', new List<String>{'CHL_QuoteSyncStatus__c','REN_Renewal_Metrics_Status__c','REN_Metrics_Calculation_Date__c'}, CSM_Constants.DML_OPERATION_UPDATE);
		 	String fieldsToQuery = '';
		 	if(hasCommitLevel && hasFirstQuoteCompletedDate){
		 		fieldsToQuery = ','+solnExtNamespace +'Commit_Level__c'+','+solnExtNamespace +'First_Quote_Completed_Date__c';
		 	}
			String queryString = 'Select Id, CHL_QuoteSyncStatus__c,REN_Renewal_Metrics_Status__c,REN_Metrics_Calculation_Date__c,REN_AddsAmount__c' +fieldsToQuery+' from Opportunity where ID IN: allOppIdsSet';
			return Database.getQueryLocator(queryString);
		}
		catch (Exception ex){
			System.debug('\n' + ex);
			CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true,  CSM_Error_Description__c = 'Error:Batch Name - CHL_SetQuoteSyncStatusOnOpptyBatch_1' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
			logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'Opportunity',	batchContext.getJobId());
			logger.saveLogRecords();
			system.abortJob(batchContext.getJobId());
		}
		return null;
	}
	
	global void execute(Database.BatchableContext batchContext,List<Opportunity> OpportunityList){
		try{
			CSM_TriggerManager.disableAllTriggers();
			List<String> oppIdsList = new List<String>();
			for(Opportunity opp : OpportunityList){
				if(failureOppIdSet != null && !failureOppIdSet.isEmpty() && failureOppIdSet.contains(opp.Id)){
					opp.CHL_QuoteSyncStatus__c = 'Error';
				}
				else{
					opp.CHL_QuoteSyncStatus__c = 'None';
					opp.REN_Renewal_Metrics_Status__c = 'Not Calculated';
					opp.REN_Metrics_Calculation_Date__c = system.now();
					successOppIdsSet.add(opp.Id);			
				}			
			}
			List<Database.SaveResult> opptyUpdateResults = Database.update(OpportunityList, false);
			for(Database.SaveResult result: opptyUpdateResults){
	            if (!result.isSuccess()){
	            	CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: Batch Name - CHL_SetQuoteSyncStatusOnOpptyBatch_2' + result.getId() + ' - ' + result.getErrors().get(0));
					logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'Opportunity',	batchContext.getJobId());
	            }
			}
			logger.saveLogRecords();
			oppIdsList.addAll((List<String>)JSON.deserialize(JSON.serialize((new Map<Id,Opportunity>(OpportunityList)).keySet()), List<String>.class));
			Set<String> quoteFldstoQuery = new Set<String>{'Id','OpportunityId','IsSyncing',
															CHL_Util.quoteExtnNameSpace +'CHL_Partner_Opportunity__c',
															CHL_Util.quoteExtnNameSpace +'CHL_MSRP__c','GrandTotal'};
															
			List<SObject> syncQuotesList = CHL_Util.getObjectListByWhereClause(quoteFldstoQuery,'Quote','OpportunityId IN ( \''+String.join(oppIdsList, '\',\'')+'\') AND IsSyncing = true');
			CHL_QuoteSyncHandler.handlePOUpdationOnQuoteSync(new Map<Id,Opportunity>(OpportunityList),syncQuotesList);
		}
		catch (Exception ex){
			System.debug('\n' + ex);
			CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: Batch Name - CHL_SetQuoteSyncStatusOnOpptyBatch_3 ' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
			logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'Opportunity',	batchContext.getJobId());
			logger.saveLogRecords();
		}
	}
	
	global void finish (Database.BatchableContext batchContext){
		/*
		String dispatcherName = String.format(Label.CHL_QUOTE_ASYNC_DISPATCHER, new String[]{String.valueOf(system.now())});
		Boolean isDispatcherExist = REN_AsyncUtil.isDispatcherNameExist(dispatcherName);
		system.debug('isDispatcherExist::'+isDispatcherExist);
		if((nonDSOppIdsSet == null || nonDSOppIdsSet.isEmpty()) && !isDispatcherExist){
			String strDateTime = (system.now().addMinutes(5)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
			String jobId = system.schedule(dispatcherName, strDateTime, new CHL_OpportunityBatchScheduledDispatcher());
		}*/
		if(successOppIdsSet != null && !successOppIdsSet.isEmpty()){
			REN_AsyncUtil.scheduleMetricsFieldCalculationForOLI(successOppIdsSet);
		}	
	}
    
}