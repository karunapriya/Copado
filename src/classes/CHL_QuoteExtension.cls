/**
 * Created Date     : Nov 10, 2016
 * Developed By     : Amit, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Amit                 User Story              Nov 10, 2016            1.1                 @description
 *
 */
public with sharing class CHL_QuoteExtension {

    public static void markPrimaryQuote(Set<Id> quoteIds){
    	//Triggers are stopped from this execution
        if(quoteIds != null && !quoteIds.isEmpty()){
            List<SObject> quoteList = CHL_QuoteDataAccess.retrieveQuotesById(quoteIds, new Set<String>{'Id', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c',CHL_Util.quoteExtnNameSpace + 'CHL_Is_Distributor_Quote__c',CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Quote__c',CHL_Util.quoteExtnNameSpace +'CHL_Reseller_Primary__c'});
            Boolean hasPOField = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c');
            Set<Id> quoteIdSet = new Set<Id>();
            Set<Id> poIdSet = new Set<Id>();
            if(quoteList != null && !quoteList.isEmpty()){
                for(SObject quote : quoteList){
                	if(hasPOField && (Id)quote.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c') != null){
                		poIdSet.add((Id)quote.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'));
                	}                  
                }
                if(poIdSet != null && !poIdSet.isEmpty()){
                	CHL_QuoteSyncHandler.handleQuotePrimary(quoteList, poIdSet);
                	handlePOUpdationFromQuote(poIdSet);
                }                
            }
        }
    }
 
    public static void createDistributorQuotesAndQlis(Set<Id> quoteIds){
		//Triggers are stopped from this execution
		if(quoteIds != null && !quoteIds.isEmpty()){
            CHL_Quotes quotes = new CHL_Quotes();
            CHL_QuoteLineItems qlis = new CHL_QuoteLineItems();
            
    	 	Set<String> fieldList = Test.isRunningTest() ? quotes.getMappingFieldsToQuery('Opportunity:Quote') : quotes.getMappingFieldsToQuery(CHL_Constants.OBJ_QUOTE + ':' + CHL_Constants.OBJ_QUOTE);
	        addExtraQuoteFields(fieldList);
            Map<Id,Id> resToDistiMap = new Map<Id,Id>();
            List<Opportunity> opptyToUpdateList = new List<Sobject>();
            List<SObject> quoteList = CHL_QuoteDataAccess.retrieveQuotesById(quoteIds, fieldList);
            if(quoteList != null && !quoteList.isEmpty()){
                List<SObject> distributorQuoteList = quotes.createRenewals(quoteList, null); //Test.isRunningTest() ? quoteList : 
                CHL_QuoteDataAccess.insertQuotes(distributorQuoteList);
                quotes.updateDistributorQuote(quoteList,createQuoteToRenewQuoteMap(distributorQuoteList));
                fieldList = Test.isRunningTest() ? quotes.getMappingFieldsToQuery('Opportunity:Quote') : quotes.getMappingFieldsToQuery(CHL_Constants.OBJ_QUOTELINEITEM + ':' + CHL_Constants.OBJ_QUOTELINEITEM);
                addExtraQliFields(fieldList);
                Map<Id, Id> quoteToRenewQuoteMap = createQuoteToRenewQuoteMap(distributorQuoteList);
                List<SObject> qliList = CHL_QuoteLineItemDataAccess.getQuoteLineItemsByQuote(quoteIds, fieldList);
                List<SObject> renewedQliList = qlis.createRenewals(qliList, quoteToRenewQuoteMap);
                if(renewedQliList != null && !renewedQliList.isEmpty()){
                    CHL_QuoteLineItemDataAccess.insertQuotesLineItems(renewedQliList);
                }
            }
        }
    }
    
     public static void syncQuoteFromOpportunity(Set<Id> quoteIds){
    	if(quoteIds != null && !quoteIds.isEmpty()){
    		List<SObject> quoteList = CHL_QuoteDataAccess.retrieveQuotesById(quoteIds, new Set<String>{'OpportunityId','LineItemCount'});
    		List<String> opptIdList = new List<String>();
        	Opportunity oppObj;
        	Double qliCount = 0;   
        	Set<Id> opptyIdSet = new Set<Id>();
        	List<Opportunity> opptyToUpdateList = new List<Opportunity>();
    		for(sObject quoteObj: quoteList) {
    			opptIdList.add((String)quoteObj.get('OpportunityId'));
             	oppObj = new Opportunity();
             	oppObj.put('SyncedQuoteId', (Id)quoteObj.get('Id'));
             	oppObj.Id = (Id)quoteObj.get('OpportunityId');
             	opptyToUpdateList.add(oppObj);
             	opptyIdSet.add((Id)quoteObj.get('OpportunityId'));
             	qliCount = qliCount + (Decimal)quoteObj.get('LineItemCount');
    		}
    		System.debug('opptyToUpdateList :: '+opptyToUpdateList+' \n :: quoteIds'+quoteIds);
    		if(!opptyToUpdateList.isEmpty() && opptyToUpdateList != null) {
	        	List<Opportunity> oldOpptyList = REN_OpportunityDataAccess.getOpportunityAllDetailsById(opptIdList);
		        REN_OpportunityDataAccess.updateOpportunityforRenewals(opptyToUpdateList);
		        CSM_TriggerManager.TriggerHandler triggerHandler = new CSM_OpportunityTriggerHandler();
	            triggerHandler.onAfterUpdate(oldOpptyList, opptyToUpdateList, new Map<ID,Opportunity>(oldOpptyList), new Map<ID,Opportunity>(opptyToUpdateList));
				Decimal threshold = CSM_Admin__c.getOrgDefaults().CHL_QliCount__c;
				if(qliCount <= threshold){
					CHL_QuoteSyncHandler.handleOLIrecreation(opptyIdSet);
				}	            
	        }
    	}
    }
    
    public static void handlePOUpdationFromQuote(Set<Id> poIdSet){
    	List<sObject> parnetOpptyQuoteList = CHL_QuoteDataAccess.getQuoteListByPartnerOppId(poIdSet, false);
        Map<Id, sObject> poIdToQuoteMap = new Map<Id, sObject>();
        for(SObject poquoteObj : parnetOpptyQuoteList){
        	if((boolean)poquoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c') == true) {
        		poIdToQuoteMap.put((Id)poquoteObj.get(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c'), poquoteObj);
        	}
        }
        CHL_QuoteSyncHandler.updatePartnerOpptyFields(poIdToQuoteMap, null);
    }
    
    private static void addExtraQuoteFields(Set<String> fieldList){
        fieldList.add('IsSyncing');
        fieldList.add('OpportunityId');
        fieldList.add('Pricebook2Id');
        fieldList.add('ShippingHandling');
        fieldList.add('Tax');
        fieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');
        fieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c');
        fieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Primary__c');        
        fieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__r.CHL_Partner_Account_1__c');
        fieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__r.CHL_Partner_Account_1_Contact__c');
        fieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__r.CHL_Partner_Account_1_Type__c');
        fieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__r.CHL_Partner_Account_2__c');
        fieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__r.CHL_Partner_Account_2_Contact__c');
        fieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__r.CHL_Partner_Account_2_Type__c');
        fieldList.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__r.CHL_Incumbent__c');
    }
    
     private static void addExtraQliFields(Set<String> fieldList){
        fieldList.add('QuoteId');
        fieldList.add('Product2Id');
        fieldList.add('UnitPrice');
        fieldList.add('PricebookEntryId');
        fieldList.add('Discount');
        //fieldList.add(CHL_Util.quoteExtnNameSpace +'REN_Original_Line_Item_ID__c');
        fieldList.add(CHL_Util.quoteExtnNameSpace +'CHL_For_Distributor_Quote__c');
    }
    
    private static Map<Id, Id> createQuoteToRenewQuoteMap(List<SObject> distributorQuoteList){
        Map<Id, Id> quoteToDistributorQuoteMap = new Map<Id, Id>();
        for(SObject sobj : distributorQuoteList){
            quoteToDistributorQuoteMap.put(sobj.getCloneSourceId(), sobj.Id);
        }
        return quoteToDistributorQuoteMap;
    }
    
}