/**
 * Created Date		: April 9, 2018
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
 * Smita					US3275				April 9, 2018		1.1				Batch class to copy custom fields after quote creation from UI.	
 *
 */
 
public with sharing class CHL_CreateQuoteAndQLIBatchHelper {
	public static void updateSyncedAfterCreationFlag(list<String> allQuoteIdList){		
    	list<sObject> quoteListToUpdate = new list<sObject>();
    	Boolean hasSyncedAfterCreationFld = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_SyncedAfterCreation__c');
    	Set<String> fldstoQuery = new Set<String>{'Id'};
    	if(hasSyncedAfterCreationFld){
    		fldstoQuery.add(CHL_Util.quoteExtnNameSpace+'CHL_SyncedAfterCreation__c');
    	}
    	list<sObject> allQuoteList = CHL_Util.getObjectListByWhereClause(fldstoQuery,CHL_Constants.OBJ_QUOTE,'Id IN(\''+String.join(allQuoteIdList, '\',\'')+'\')');
    	if(allQuoteList != null && !allQuoteList.isEmpty()){
    		for(sObject quote : allQuoteList){
	    		if(hasSyncedAfterCreationFld){
	    			quote.put(CHL_Util.quoteExtnNameSpace+'CHL_SyncedAfterCreation__c','Yes');
	    			quoteListToUpdate.add(quote);
	    		}   		
    		}
    		CHL_QuoteDataAccess.updateQuotes(quoteListToUpdate);
    	}  		
	}  
	public static void rollupMsrp(list<String> allQLIIdList, Boolean isOppUpdateRequired, Integer qliRecordLimit){
		Set<String> qualifiedQuoteIds = new Set<String>();
		Boolean hasMSRP = CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTELINEITEM, CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP);	
		Set<String> fldstoQuery = new Set<String>{'Id','QuoteId'};
		if(hasMSRP)	{
			fldstoQuery.add(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP);	
		}
		list<sObject> allQLIList =  CHL_Util.getObjectListByWhereClause(fldstoQuery,'QuoteLineItem','Id IN(\''+String.join(allQLIIdList, '\',\'')+'\')');
		if(allQLIList != null && !allQLIList.isEmpty()){
    		for(sObject qli : allQLIList){
	    		if(hasMSRP && (Decimal)qli.get(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP) != null){
	    			qualifiedQuoteIds.add((Id)qli.get('QuoteId'));
	    		}
    		}
	    	if(qualifiedQuoteIds != null && !qualifiedQuoteIds.isEmpty()){
	    		CHL_QuoteSyncHandler.rollupMsrpOnQuote(qualifiedQuoteIds, qliRecordLimit);
	    	}
	    	if(isOppUpdateRequired) {
	    		CHL_QuoteSyncHandler.REN_QuoteWrapper quoteWrapper = new CHL_QuoteSyncHandler.REN_QuoteWrapper(); 
			 	quoteWrapper.quoteIdsSet = new Set<Id>();
			 	quoteWrapper.newRecordList = new List<sObject>();
				CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper qliValueWrapper = new CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper();
				List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty = CHL_QuoteSyncHandler.getQuoteToOpptyMapping();	
				qliValueWrapper.fieldMappingListQuoteToOppty = new List<REN_Field_Mappings__c>(fieldMappingListQuoteToOppty);
				qliValueWrapper.qualifiedQuoteId = qualifiedQuoteIds;
				qliValueWrapper.IsSyncing = true;
				quoteWrapper.newRecordList = CHL_QuoteLineItemTriggerHelper.getQuoteListUsingMapping(qliValueWrapper);		
				quoteWrapper.quoteIdsSet = (Set<Id>)JSON.deserialize(JSON.serialize(qualifiedQuoteIds), Set<Id>.class);
		        CHL_QuoteSyncHandler.handleQuoteUpdate(quoteWrapper,fieldMappingListQuoteToOppty);		
	    	}
    	}
	}
}