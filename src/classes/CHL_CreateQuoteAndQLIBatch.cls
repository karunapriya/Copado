/**
 * Created Date		: April 4, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - This batch will copy custom fields from Opportunity --> Quote and OLI --> QLI after quote creation from UI.
 * Support Email 	: smitah@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *_____________________________________________________________________________________________________________________________________
 *
 * Smita					US3275				April 4, 2018		1.1				Batch class to copy custom fields after quote creation from UI.	
 *
 */
global with sharing class CHL_CreateQuoteAndQLIBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Set<Id> quoteIdSet = new Set<Id>();
    public Boolean isOppUpdateRequired {get;set;}
    public SchedulableContext schedulableContextObj {get;set;}
    Set<String> oliFldstoQuery;   
    Set<String> quoteFldstoQuery;
    Set<String> oppFldstoQuery; 
    Set<Id> allQuoteIdSet = new Set<Id>();
    Set<Id> allQLIIdSet = new Set<Id>();
    Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
    Set<Id> failureQuoteIdsSet = new Set<Id>();
    List<REN_Field_Mappings__c> fieldMappingListOpptyToQuote = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(Label.REN_LBL_OPPTY_TO_QUOTE,'Quote', 'Opportunity');        
    List<REN_Field_Mappings__c> OLItoQLIMappingLst = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(Label.REN_LBL_OPPTY_TO_QUOTE,CHL_Constants.OBJ_QUOTELINEITEM,REN_Constants.OBJ_OPPTY_LINE_ITEM);
    private CSM_BatchResultsLogger logger = CSM_BatchResultsLogger.getInstance();
    
    global Database.QueryLocator Start(Database.BatchableContext batchContext) {
    	try{
            Set<String> qliFldsForCRUDChk = !Test.isRunningTest() ? new Set<String> {'Id', CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP} : new Set<String> {'Id'};
            Set<String> qliFldstoQuery = !Test.isRunningTest() ? new Set<String> {'Id','QuoteId', CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c',CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP,'Subtotal'} : new Set<String> {'Id','QuoteId'};
	    	oliFldstoQuery = new Set<String> {'Id','PricebookEntryId','Quantity','SubTotal','OpportunityId','TotalPrice'};
	        REN_Util.getFromAndToFldsToQuery(OLItoQLIMappingLst,oliFldstoQuery,qliFldstoQuery);
            Set<String> quoteFldsForCRUDChk = !Test.isRunningTest() ? new Set<String>{'Id','OpportunityId', CHL_Util.quoteExtnNameSpace +'CHL_Partner_Opportunity__c',CHL_Util.quoteExtnNameSpace +'CHL_MSRP__c'} : new Set<String>{'Id','OpportunityId'};
	        quoteFldstoQuery = new Set<String>{CSM_Util.nameSpacePrefixSolnExtn+'Local_Currency_Code__c','Id','OpportunityId','IsSyncing',CHL_Util.quoteExtnNameSpace +'CHL_Partner_Opportunity__c',CHL_Util.quoteExtnNameSpace +'CHL_MSRP__c','GrandTotal'};
			if(UserInfo.isMultiCurrencyOrganization()){
				quoteFldstoQuery.add('CurrencyIsoCode');
			}
			oppFldstoQuery = new Set<String>();
			REN_Util.getFromAndToFldsToQuery(fieldMappingListOpptyToQuote,oppFldstoQuery, quoteFldstoQuery);  
			CSM_Util.checkCRUD_FLS('Quote', new List<String>(quoteFldsForCRUDChk), CSM_Constants.DML_OPERATION_UPDATE); 
			CSM_Util.checkCRUD_FLS('QuoteLineItem', new List<String>(qliFldsForCRUDChk), CSM_Constants.DML_OPERATION_UPDATE);    
	    	string queryString = 'Select '+String.join(new List<String>(qliFldstoQuery), ',')+ ' From QuoteLineItem Where QuoteId IN : quoteIdSet';
        	return Database.getQueryLocator(queryString);
    	}catch (Exception ex){
			System.debug('\n' + ex);
			CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true,  CSM_Error_Description__c = 'Error: ' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
			logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'QuoteLineItem',	batchContext.getJobId());
			logger.saveLogRecords();
			system.abortJob(batchContext.getJobId());
		}
		return null;   	
    }
    global void execute(Database.BatchableContext batchContext, List<SObject> quoteLineItemsList) {
    	CSM_TriggerManager.disableAllTriggers();
    	logger = CSM_BatchResultsLogger.getInstance();   	
    	try{
	    	List<String> quoteIdList = new List<String>();
	    	quoteIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(quoteIdSet), List<String>.class));
	    	List<String> syncedLineItemIdList = new List<String>();
	    	for(sObject qliObj : quoteLineItemsList){
    			syncedLineItemIdList.add((String)qliObj.get(CHL_Util.quoteExtnNameSpace+'REN_Synced_Line_Item_ID__c'));
    		}
			List<Opportunity> opportunityList = CHL_Util.getObjectListByWhereClause(oppFldstoQuery,'Opportunity','Id IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(quoteIdList, '\',\'')+'\') )');	
			opptyMap = new Map<Id, Opportunity>(opportunityList);
			system.debug('opptyMap::>'+opptyMap);
			List<sObject> quoteList = CHL_Util.getObjectListByWhereClause(quoteFldstoQuery,CHL_Constants.OBJ_QUOTE,'Id IN(\''+String.join(quoteIdList, '\',\'')+'\')');	
	    	Map<Id, sObject> quoteMap = new Map<Id, SObject>(quoteList);
	    	String whereClause = 'where OpportunityId IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN(\''+String.join(quoteIdList, '\',\'')+'\') )';
	    	List<OpportunityLineItem> opliQueriedList = CHL_Util.getObjectListByWhereClause(oliFldstoQuery,'OpportunityLineItem',' Id IN(\''+String.join(syncedLineItemIdList, '\',\'')+'\')');	
	    	List<sObject> quoteListToUpdate = CHL_QuoteSyncHandler.OpptyToQuoteMapping(fieldMappingListOpptyToQuote,quoteList,opportunityList,false);
	    	List<sObject> qliToUpdateList = CHL_QuoteSyncHandler.OLItoQLIMapping(OLItoQLIMappingLst,quoteLineItemsList,opliQueriedList);
	        List<Database.SaveResult> quoteResultList = new List<Database.SaveResult>(); 
	        List<Database.SaveResult> qliResultList = new List<Database.SaveResult>();
	        Map<Id,sObject> quoteLineItemsMap = new Map<Id,sObject>(qliToUpdateList);
	        if(quoteListToUpdate != null && !quoteListToUpdate.isEmpty()){
	    		quoteResultList = Database.update(quoteListToUpdate , false);	
	    	}
	    	if(qliToUpdateList != null && !qliToUpdateList.isEmpty()){
	    		qliToUpdateList = CHL_QuoteLineItemTriggerHelper.processQliRecords(quoteMap,qliToUpdateList, null);
	    		qliResultList = Database.update(qliToUpdateList , false);	
	    	}
	    	if(quoteResultList != null && !quoteResultList.isEmpty()){
	    		for(Database.SaveResult result: quoteResultList){
		    		if (!result.isSuccess()){
		            	CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: ' + result.getId() + ' - ' + result.getErrors().get(0));
						logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'Quote',	batchContext.getJobId());
		            }
		            else{
		            	allQuoteIdSet.add(result.getId());
		            }	
	    		}
	    	}
	    	if(qliResultList != null && !qliResultList.isEmpty()){
	    		for(Database.SaveResult result: qliResultList){
		    		if (!result.isSuccess()){
		            	CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true, CSM_Error_Description__c = 'Error: ' + result.getId() + ' - ' + result.getErrors().get(0));
						logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, 'QuoteLineItem',	batchContext.getJobId());
		            }
		            else{
		            	allQLIIdSet.add(result.getId());
		            }
	    		}
	    		for(Id qliId : quoteLineItemsMap.keySet()){
					if(!allQLIIdSet.contains(qliId)){
						failureQuoteIdsSet.add((Id)quoteLineItemsMap.get(qliId).get('QuoteId'));
					}
				}
	    	}	    	
	    	logger.saveLogRecords();
    	}catch (Exception ex){
			System.debug('\n' + ex);
			CSM_Batch_Result__c errObj = new CSM_Batch_Result__c(CSM_Errors__c= true,  CSM_Error_Description__c = 'Error: ' + ex.getMessage() + ';\nStack Trace:' + ex.getStackTraceString());
			logger.addLogRecord(errObj, system.now(), CSM_BatchResultsLogger.MODULE_CHANNEL, CSM_BatchResultsLogger.STATUS_PENDING, '',	batchContext.getJobId());
			logger.saveLogRecords();
		}
    }
    global void finish(Database.BatchableContext batchContext){
    	Integer qliRecordLimit = 50000;   
    	String solnExtNamespace = CSM_Util.nameSpacePrefixSolnExtn; 	
    	list<String> allQuoteIdList = new List<String>();
    	list<String> allQLIIdList = new List<String>();
    	set<Id> opptyIdSet = new set<Id>();
    	allQuoteIdSet.removeAll(failureQuoteIdsSet);
    	system.debug('opptyMap.keySet()::>'+opptyMap.keySet());
    	opptyIdSet.addAll(opptyMap.keySet());
    	allQuoteIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(allQuoteIdSet), List<String>.class)); 
    	allQLIIdList.addAll((List<String>)JSON.deserialize(JSON.serialize(allQLIIdSet), List<String>.class));
    	if(allQuoteIdList != null && !allQuoteIdList.isEmpty()){
    		CHL_CreateQuoteAndQLIBatchHelper.updateSyncedAfterCreationFlag(allQuoteIdList) ; 
    	}    	
    	if(allQLIIdList != null && !allQLIIdList.isEmpty()){
    		CHL_CreateQuoteAndQLIBatchHelper.rollupMsrp(allQLIIdList, this.isOppUpdateRequired, qliRecordLimit);
    	}    	
    	CSM_TriggerEnablement__c triggerEnablement = CSM_TriggerEnablement__c.getOrgDefaults();
    	if(triggerEnablement.REN_Bypass_Metrics_Field_Calculations__c == false && isOppUpdateRequired) {
    		if(opptyIdSet != null && !opptyIdSet.isEmpty()){
				Integer batchSize = CSM_Util.getCustomListSetting('REN_SetOppSyncPendingStatusBatch');
				batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
				REN_SetOppSyncPendingStatusBatch oppBatchJob = new REN_SetOppSyncPendingStatusBatch();
				oppBatchJob.impactedOpportunitySet = opptyIdSet;
				system.debug('schedulableContextObj::>'+schedulableContextObj);
				oppBatchJob.schedulableContextObj = schedulableContextObj;
				Database.executeBatch(oppBatchJob,batchSize);
			}
    	}
    	
    }
}