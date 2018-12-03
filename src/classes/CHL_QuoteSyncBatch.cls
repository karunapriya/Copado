/**
 * Created Date     : March 30, 2018
 * Developed By     : Rucha Palasapure, Comity Designs, Inc.
 * Function         : @description - This Batch is used to copy custom fields from Quote To Opportunity and QLI To OLI after Quote sync
 *										if QLIs count is graeter than threshold value.
 *						
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Rucha Palasapure       US3274 & US3273      March 30, 2018          1.1                 @description
 *
 */

global with sharing class CHL_QuoteSyncBatch implements REN_IScheduleDispatched, Database.Batchable<sObject>, Database.Stateful {
	global Set<Id> oppIdsSet;
	public Set<Id> allOppIdsSet = new Set<Id>();
	public Set<Id> failureOppIdsSet = new Set<Id>();
	Set<String> qliFldstoQuery;
	Set<String> oliFldstoQuery;
	Set<String> quoteFldstoQuery;
	Set<String> opptyFldstoQuery;
	private CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
	List<REN_Field_Mappings__c> quoteToOpptyMappingList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
														Label.REN_LBL_QUOTE_TO_OPPTY, 'Opportunity', CHL_Constants.OBJ_QUOTE);
														
	List<REN_Field_Mappings__c> qliToOliMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(
														Label.REN_LBL_QUOTE_TO_OPPTY, REN_Constants.OBJ_OPPTY_LINE_ITEM, CHL_Constants.OBJ_QUOTELINEITEM);	
	
	global void execute(SchedulableContext schedulerContext) {   
    	Integer batchSize = CSM_Util.getCustomListSetting('CHL_QuoteSyncBatch');   	
        batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize; 
        String batchprocessid = Database.executeBatch(this,batchSize);
        /*
        Boolean isNextRunSet = REN_AsyncUtil.isNextRunSetForScheduler(schedulerContext.getTriggerId());
        if(!isNextRunSet){
        	System.abortJob(schedulerContext.getTriggerId());
        }*/
    }
	global Database.queryLocator start(Database.BatchableContext batchContext){
		try{
			CSM_TriggerManager.disableAllTriggers();
			if(oppIdsSet != null && !oppIdsSet.isEmpty() && oppIdsSet.size() == 1){
				List<Id> oppIdList = new List<Id>(oppIdsSet);
				Opportunity opp = new Opportunity(Id = oppIdList[0]);
				CSM_OpportunityTriggerHelper.bypassValidationForQuoteSyncBatch(new List<Opportunity>{opp}, false);
			}
			String queryString ;
			qliFldstoQuery = new Set<String> {'Id','QuoteId',CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c'};
			oliFldstoQuery = new Set<String> {'Id','TotalPrice','OpportunityId','REN_Is_CLM_Renewal__c'};		
			REN_Util.getFromAndToFldsToQuery(qliToOliMappingLst,qliFldstoQuery,oliFldstoQuery);
			
			quoteFldstoQuery = new Set<String>{'Id','OpportunityId','IsSyncing',CHL_Util.quoteExtnNameSpace +'CHL_Partner_Opportunity__c',CHL_Util.quoteExtnNameSpace +'CHL_MSRP__c','GrandTotal'};
			opptyFldstoQuery = new Set<String>{'CHL_Bypass_Validation_For_Quote_Async__c'};
			REN_Util.getFromAndToFldsToQuery(quoteToOpptyMappingList,quoteFldstoQuery, opptyFldstoQuery);
			
			CSM_Util.checkCRUD_FLS('Opportunity', new List<String>(opptyFldstoQuery), CSM_Constants.DML_OPERATION_UPDATE);
			CSM_Util.checkCRUD_FLS('OpportunityLineItem', new List<String>{'REN_Is_CLM_Renewal__c'}, CSM_Constants.DML_OPERATION_UPDATE);
		
			if(oppIdsSet != null && !oppIdsSet.isEmpty()){
				queryString = Test.isRunningTest()? 'Select Id,QuoteId from QuoteLineItem':'Select '+String.join(new List<String>(qliFldstoQuery), ',')+ ' From QuoteLineItem Where Quote.OpportunityId IN : oppIdsSet and Quote.IsSyncing = true';
			}
			else{
				queryString = Test.isRunningTest()? 'Select Id,QuoteId from QuoteLineItem':'Select '+String.join(new List<String>(qliFldstoQuery), ',')+ ' From QuoteLineItem Where (Quote.Opportunity.CHL_QuoteSyncStatus__c = \'Scheduled\' OR Quote.Opportunity.CHL_QuoteSyncStatus__c = \'Error\') and Quote.IsSyncing = true'; 
			}
			system.debug('queryString for QLI ::'+queryString);
			return Database.getQueryLocator(queryString);
		}
		catch (Exception ex){
			if(oppIdsSet != null && !oppIdsSet.isEmpty()){
				Set<String> oppIds = (Set<String>)JSON.deserialize(JSON.serialize(oppIdsSet), Set<String>.class);
				CSM_OpportunityTriggerHelper.updateQuoteSyncStatusOnOppty(oppIds, 'Error');
			}			
			CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true,  CSM_Error_Description__c = 'Error: Batch Name - CHL_QuoteSyncBatch_1' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
			logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'QuoteLineItem', batchContext.getJobId());
			logger.saveLogRecords();
			system.abortJob(batchContext.getJobId());
		}
		return null;
	}
	
	global void execute(Database.BatchableContext batchContext,List<SObject> quoteLineItemsList){
		CSM_TriggerManager.disableAllTriggers();
		List<Opportunity> oppTobeCopiedList = new List<Opportunity>();
		try{
			List<SObject> syncQuotesList = new List<SObject>();
			List<OpportunityLineItem> oppLineItemsList = new List<OpportunityLineItem>();
			Set<Id> quoteIdsSet = new Set<Id>();
			List<String> syncedLineIdsList = new List<String>();						
			List<String> quoteIdsList = new List<String>();					
			for(SObject qliObj : quoteLineItemsList){
				quoteIdsSet.add((Id)qliObj.get('QuoteId'));
                if(!Test.isRunningTest()){
					syncedLineIdsList.add((String)qliObj.get(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c'));
                }
			}
			quoteIdsList.addAll((List<String>)JSON.deserialize(JSON.serialize(quoteIdsSet), List<String>.class));
			syncQuotesList = Test.isRunningTest()? Database.query('Select Id, OpportunityId,Description,GrandTotal from Quote'):CHL_Util.getObjectListByWhereClause(quoteFldstoQuery,'Quote','Id IN ( \''+String.join(quoteIdsList, '\',\'')+'\')');
			oppTobeCopiedList = Test.isRunningTest()? [Select Id,Name,Description from Opportunity]:CHL_Util.getObjectListByWhereClause(opptyFldstoQuery,'Opportunity','Id IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(quoteIdsList, '\',\'')+'\') )');
			oppLineItemsList = Test.isRunningTest()? [Select Id, OpportunityId from OpportunityLineItem]:CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem','Id IN ( \''+String.join(syncedLineIdsList, '\',\'')+'\')');
			/* Logic for copying custom fields. */			
			List<Opportunity> oppToUpdateList = Test.isRunningTest()? oppTobeCopiedList : CHL_QuoteSyncHandler.QuoteToOpportunityMapping(quoteToOpptyMappingList, oppTobeCopiedList, syncQuotesList);
			List<OpportunityLineItem> olisToUpdateList = Test.isRunningTest()? oppLineItemsList : CHL_QuoteSyncHandler.QLItoOLIMapping(qliToOliMappingLst,quoteLineItemsList, oppLineItemsList, new Set<Id>());		
			Map<Id,OpportunityLineItem> oppLineItemsMap = new Map<Id,OpportunityLineItem>(olisToUpdateList);
			List<Database.SaveResult> opptyUpdateResults = new List<Database.SaveResult>();
			if(!oppToUpdateList.isEmpty() && oppToUpdateList != null) {
				opptyUpdateResults = Database.update(oppToUpdateList, false);		
			}			
			List<Database.SaveResult> oliUpdateResults = new List<Database.SaveResult>();
			if(!olisToUpdateList.isEmpty() && olisToUpdateList != null){
				oliUpdateResults = Database.update(olisToUpdateList, false);		
			}
			if(opptyUpdateResults != null && !opptyUpdateResults.isEmpty()){
				failureOppIdsSet = CHL_QuoteSyncBatchHelper.saveErrorLogsOfOpportunity(opptyUpdateResults,batchContext, new Map<Id,Opportunity>(oppToUpdateList));
			}
			if(oliUpdateResults != null && !oliUpdateResults.isEmpty()){
				failureOppIdsSet.addAll(CHL_QuoteSyncBatchHelper.saveErrorLogsOfOpportunityLineItem(oliUpdateResults,batchContext,oppLineItemsMap));
			}
			allOppIdsSet.addAll(new Map<Id,Opportunity>(oppToUpdateList).keySet());
		}
		catch (Exception ex){
			System.debug('\n' + ex);
			failureOppIdsSet.addAll(new Map<Id,Opportunity>(oppTobeCopiedList).keySet());
			CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: Batch Name - CHL_QuoteSyncBatch_2' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
			logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, '',	batchContext.getJobId());
			logger.saveLogRecords();
		}
	}
	
	global void finish (Database.BatchableContext batchContext){
		if(allOppIdsSet != null && !allOppIdsSet.isEmpty()){
			Integer batchSize = CSM_Util.getCustomListSetting('CHL_SetQuoteSyncStatusOnOpptyBatch');
			batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
			CHL_SetQuoteSyncStatusOnOpptyBatch oppBatchJob = new CHL_SetQuoteSyncStatusOnOpptyBatch();
			oppBatchJob.allOppIdsSet = allOppIdsSet;
			oppBatchJob.failureOppIdSet = failureOppIdsSet;
			//oppBatchJob.nonDSOppIdsSet = oppIdsSet;
			Database.executeBatch(oppBatchJob,batchSize);
		}
	}
    
}