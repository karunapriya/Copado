public with sharing class CHL_QuoteLineItemTriggerHelper {
	
	/* Below method is used to update UnitPrice and Local_Currency_Line_Total__c fields of QLI.*/
	public static List<SObject> processQliRecords(Map<Id, sObject> quotesMap,List<SObject> quoteLineItemList,Map<Id, Opportunity> opptyMap){
		String solnExtNamespace = CSM_Util.nameSpacePrefixSolnExtn;
        List<SObject> quoteLineItesmList = new List<sObject>();
		Set<String> opportunityIdSet = new Set<String>();
		Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
		if(opptyMap == null || opptyMap.isEmpty()){
	        for (sObject quoteObj: quotesMap.values()){
	            opportunityIdSet.add((String)(quoteObj.get('OpportunityId')));
	        }
	        opportunityIdSet.remove(null);   
	       	opportunityMap = new Map<Id, Opportunity>(CSM_OpportunityDataAccess.getOpportunitiesById(opportunityIdSet));
		}else{
			opportunityMap = opptyMap;
		} 
        if(quoteLineItemList != null && !quoteLineItemList.isEmpty()){
            for (sObject quoteLine: quoteLineItemList){
                sObject quoteObj = quotesMap.get((Id)quoteLine.get('QuoteId'));
                Opportunity oppObj = opportunityMap.get((Id)quoteObj.get('OpportunityId'));
                if(CSM_AccessController.hasField('QuoteLineItem', solnExtNamespace + 'Local_Currency_Amount__c')){
	                if(quoteLine.get(solnExtNamespace+'Local_Currency_Amount__c') != null && quoteObj.get(solnExtNamespace+'Local_Currency_Code__c') != null){
	                    Decimal unitPrice = REN_CurrencyExchangeRateDataAccess.acmCurrencyConversion(
	                                        (Decimal)quoteLine.get(solnExtNamespace+'Local_Currency_Amount__c'), 
	                                        (String)quoteObj.get(solnExtNamespace+'Local_Currency_Code__c'), 
	                                        (String)quoteObj.get('CurrencyIsoCode'),
	                                        (oppObj == null ? null : oppObj.CloseDate));	            		
	                    if(unitPrice != null){                   	
	                        Decimal totalAmount = (Decimal)quoteLine.get(solnExtNamespace+'Local_Currency_Amount__c') * (Decimal)quoteLine.get('Quantity');
	                        quoteLine.put('UnitPrice',unitPrice);
	                        quoteLine.put(solnExtNamespace+'Local_Currency_Line_Total__c',totalAmount);
	                        quoteLineItesmList.add(quoteLine);
	                    }
	                }
                }	        
            }
        }
        return quoteLineItesmList;
 	}
 	
 	public static List<sObject> getQuoteListUsingMapping(REN_QLIWrapper wrapper){
		List<sObject> quotList = new List<sObject>();
        Set<String> frmFldForQuoteSet = new Set<String>();
		Set<String> toFldForQuoteSet = new Set<String>();
		if(wrapper.fieldMappingListQuoteToOppty == null || wrapper.fieldMappingListQuoteToOppty.isEmpty()){
			return quotList;
		}
 		
        REN_Util.getFromAndToFldsToQuery(wrapper.fieldMappingListQuoteToOppty,frmFldForQuoteSet,toFldForQuoteSet);
        Set<String> quoteFldstoQuery = new Set<String> {'Id','OpportunityId','IsSyncing',CHL_Util.quoteExtnNameSpace +'CHL_Partner_Opportunity__c'};
        quoteFldstoQuery.addall(frmFldForQuoteSet);
        if(wrapper.additionalFields != null){
        	quoteFldstoQuery.Addall(wrapper.additionalFields);
        }
        List<String> quoteListMsrp = new List<String>();
        quoteListMsrp.addAll((List<String>)JSON.deserialize(JSON.serialize(wrapper.qualifiedQuoteId), List<String>.class));
        if(CSM_AccessController.hasObject('Quote') && !Test.isRunningTest()){
        	if(wrapper.IsSyncing){
        		quotList = CHL_Util.getObjectListByWhereClause(quoteFldstoQuery,'Quote','Id IN ( \''+String.join(quoteListMsrp, '\',\'')+'\') and IsSyncing=true ');	
			}else{
				quotList = CHL_Util.getObjectListByWhereClause(quoteFldstoQuery,'Quote','Id IN ( \''+String.join(quoteListMsrp, '\',\'')+'\')');
			}
        }       
        return quotList;
	}
	
 	public with sharing class REN_QLIWrapper {
		public Set<String> qualifiedQuoteId;
    	public Set<String> additionalFields;
		public List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty;
		public Boolean IsSyncing {get; set;}
	}
}