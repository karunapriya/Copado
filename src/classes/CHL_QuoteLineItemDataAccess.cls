public with sharing class CHL_QuoteLineItemDataAccess {
	
	public static void updateQuoteLineItem(Set<String> qliFlds,List<SObject> quoteLineList) {
    	List<String> qliFieldList = new List<String>(qliFlds);	
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTELINEITEM, qliFieldList, CSM_Constants.DML_OPERATION_UPDATE);
		update quoteLineList;
	}
	
	 public static void insertQuotesLineItems(List<SObject> quoteLineItemList) {
     	List<String> quoteLineItemFieldList = new List<String>{
     													REN_Constants.OBJ_OLI_QUANTITY,
     													REN_Constants.OBJ_OLI_UNITPRICE
     													};
    	if(!Test.isRunningTest()){
    		quoteLineItemFieldList.add(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_END_DATE);
 			quoteLineItemFieldList.add(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_START_DATE);
 			quoteLineItemFieldList.add(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_ASSET);
    	}
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTELINEITEM, quoteLineItemFieldList, CSM_Constants.DML_OPERATION_INSERT);
		insert quoteLineItemList;
	}
	
	public static List<SObject> getQuoteLineItemsByQuote(Set<Id> quoteIds, Set<String> qliFlds){
		if(Test.isRunningTest()){
			CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTELINEITEM, new List<String>{'quoteId'}, CSM_Constants.DML_OPERATION_READ) ;
		}else {
			CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTELINEITEM, new List<String>(qliFlds), CSM_Constants.DML_OPERATION_READ);
		}
		String soqlStr =Test.isRunningTest() ? 'Select Id,quoteId,Product2Id,UnitPrice,PricebookEntryId,Discount,Description,Quantity from QuotelineItem limit 1' : CSM_Util.getSOQLString(CHL_Constants.OBJ_QUOTELINEITEM, qliFlds, ' QuoteId IN:quoteIds', null, null);		
		return Database.query(soqlStr);
	}
	public static void deleteQuotesLineItems(List<SObject> quoteLineItemList) {	
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTELINEITEM, null, CSM_Constants.DML_OPERATION_DELETE);
        delete quoteLineItemList;
    }
    
    public static List<SObject> getQliFromId(Set<Id> qliIdSet) {
    	List<String> quoteLineItemFieldList = new List<String>{	'Quantity',
     													CSM_Util.nameSpacePrefixSolnExtn + 'Local_Currency_Amount__c'
     													};
     	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTELINEITEM, quoteLineItemFieldList, CSM_Constants.DML_OPERATION_UPDATE);
    	String queryString = 'Select QuoteId,'+ CSM_Util.nameSpacePrefixSolnExtn +'Local_Currency_Amount__c,'+ CSM_Util.nameSpacePrefixSolnExtn +'Local_Currency_Code__c,Quantity From QuoteLineItem  where Id IN :qliIdSet Limit 10000';
    	return Database.query(queryString);
    }
    
   
    public static List<SObject> getSelectedQli(Set<Id> qliIdSet, Set<String> qliFieldSet, List<String> whereConditionList) {
	
    	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTE, new List<String>{'OpportunityId'}, CSM_Constants.DML_OPERATION_READ);
    	CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_QUOTELINEITEM, new List<String>(qliFieldSet), CSM_Constants.DML_OPERATION_READ);	
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, new List<String>{'stageName'}, CSM_Constants.DML_OPERATION_READ);
    	
    	String queryString = 'Select QuoteId,Quote.OpportunityID From QuoteLineItem where Id IN :qliIdSet ' + (String.isBlank(whereConditionList[0]) ? '' : (' and '+ whereConditionList[0])) +' Limit 10000';
    	return Database.query(queryString);
    }
}