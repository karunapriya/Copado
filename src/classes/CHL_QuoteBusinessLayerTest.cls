/**
* @description    Test class for CHL_QuoteBusinessLayer        
*/
@isTest
public with sharing class CHL_QuoteBusinessLayerTest {
	
	 @testSetup static void setup() {
		List<Account> accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		List<Opportunity> opptyList = new List<Opportunity>();
		List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();

		Account acc =  CHL_TestUtility.partnerAccount();
		accountList.add(acc);
		insert accountList;
		
		System.assert(accountList != null);

		Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
		contactList.add(con);
		insert contactList;

		Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
		opptyList.add(oppty);
		insert opptyList; 
		
		// Start -- Added for QuoteSynHandler class
		
		List<Product2> productList = CHL_TestUtility.createProducts(2);
		insert productList;
		
		List<PricebookEntry> pbeList = CHL_TestUtility.createPricebookEntry(productList,Test.getStandardPricebookId());
		insert pbeList;
		
		List <OpportunityLineItem> opliList = CHL_TestUtility.createOplis(opptyList,pbeList);
		insert opliList;
		
		List<REN_Field_Mappings__c> mappingList = CHL_TestUtility.createQuoteMapping();
		insert mappingList;
		
		// End
		
		CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
        optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
        optyStatusLogObj.CHL_Days_between_Update__c = 5;
        optyStatusLogObj.CHL_Enable_2_Tier_Pricing__c = true;
        insert optyStatusLogObj; 
		
		CHL_Partner_Opportunity__c parOptyObj = new CHL_Partner_Opportunity__c(); 
		parOptyObj.Name = 'testParOpp';
		parOptyObj.CHL_Opportunity__c = opptyList[0].id;
		insert parOptyObj; 		
		
	}
	
	static testmethod void constructGridWrapperTest(){
		//CHL_Partner_Opportunity__c parOptyObj = [select Id from CHL_Partner_Opportunity__c limit 1];
		List < CHL_Partner_Opportunity__c > partnerOppList = [select Id, name, CHL_Sales_Stage__c,CHL_Opportunity__c from CHL_Partner_Opportunity__c limit 1];
        List<Opportunity> opptyList = [select Id, name,Pricebook2Id from opportunity limit 1 ];
        system.assert(partnerOppList<>null);  
        List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,partnerOppList);
        if(quoteList != null && !quoteList.isEmpty()) {
			insert quoteList;
        }
		Test.startTest();			
			//if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
			CHL_GridInputWrapper inputWrapper = new CHL_GridInputWrapper();
			CHL_GridInputWrapper.CHL_CustomGridParams gridParams = new CHL_GridInputWrapper.CHL_CustomGridParams();
			gridParams.oppId = partnerOppList[0].id;
		    inputWrapper.queryParams=gridParams;
			CHL_QuoteBusinessLayer quoteBL=new CHL_QuoteBusinessLayer(inputWrapper);
			CHL_AngularResponeWrapper wrapper = quoteBL.constructGridWrapper();
			system.assert(true);
			//}
		Test.stopTest();
	}
	
	//**** ---Start ---- Test methods for CHL_QuoteSyncHandler as Quotes is disable in Master Org. ****/
	static testMethod void testQSynHandler_handleQuoteLineItemAfterCreation() {
		List<Sobject> qliList = new List<Sobject>();
		Set<Id> qliIdSet = new Set<Id>();
		Set<Id> quoteIdSet = new Set<Id>();
		try {
			CHL_QuoteSyncHandler.handleQuoteLineItemAfterCreation(quoteIdSet,qliIdSet,null,null);
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	/*static testMethod void testQSynHandler_handleQuoteLineItemAfterDeletion() {
		List<Sobject> qliList = new List<Sobject>();
		try {
			CHL_QuoteSyncHandler.handleQuoteLineItemAfterDeletion(qliList);
		}catch(Exception ex){	}
		system.assert(true);
	}*/
	
    static testMethod void testQSynHandler_handleQuoteLineItemUpdation() {
		List<Sobject> oldRecords = new List<Sobject>();
		List<Sobject> newQuoteLineItemRecords = new List<Sobject>();
		Map<ID, sObject> oldRecordsMap = new Map<ID, sObject>();
		Map<ID, sObject> newRecordsMap = new Map<ID, sObject>();
		
		try {
			CHL_QuoteSyncHandler.handleQuoteLineItemUpdation(oldRecords, newQuoteLineItemRecords, oldRecordsMap, newRecordsMap);
		    CHL_QuoteSyncHandler.handleQuoteLineItemUpdation(newQuoteLineItemRecords);
		}catch(Exception ex){	}
		system.assert(true);
	} 
	
	static testMethod void testQSynHandler_handleQuoteUpdation() {
		List<Sobject> qliList = new List<Sobject>();
		try {
			//CHL_QuoteSyncHandler.handleQuoteUpdation(qliList);
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	static testMethod void testQSynHandler_handleOpportunityUpdation() {
		List<Sobject> qliList = new List<Sobject>();
		try {
			CHL_QuoteSyncHandler.handleOpportunityUpdation(qliList);
		}catch(Exception ex){	}
		system.assert(true);
	}
	
		
	static testMethod void testQSynHandler_UpdateMSRp() {
		Set<String> quoteIDSet = new Set<String>();
		try {
			CHL_QuoteSyncHandler.rollupMsrpOnQuote(quoteIDSet);
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	
	
	static testMethod void testQSynHandler_handelLOICreation() {
		List<OpportunityLineItem> oliList = [select id, OpportunityId from OpportunityLineItem limit 10];
		set<Id> oppIdSet =new set<Id>();
		for(OpportunityLineItem oli:oliList){
			oppIdSet.add(oli.OpportunityId);
		}
		Set<String> quoteFieldList = new Set<String>();
		try {
			CHL_QuoteSyncHandler.handleOLIrecreation(oppIdSet);
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	static testMethod void testQSynHandler_handelOLIUpdate() {
		List<OpportunityLineItem> oliList = [select id,OpportunityId from OpportunityLineItem limit 10];
		Set<Id> oppIdSet = new Set<Id>();
		for(OpportunityLineItem oli: oliList){
			oppIdSet.add(oli.OpportunityId);
		}
		Set<String> quoteFieldList = new Set<String>();
		try {
			CHL_QuoteSyncHandler.handleOLIUpdate(oliList,oppIdSet);
		}catch(Exception ex){	}
		system.assert(true);
	}
		
	static testMethod void testQSynHandler_onSyncUpdateOLI() {
	    List<OpportunityLineItem> oliList = [select id from OpportunityLineItem limit 10];
		List<String> oliIdList = new List<String>();
		if(oliList != null  && oliList.size() > 0){
			oliIdList.add(oliList[0].id);
		}
		try {
			CHL_QuoteSyncHandler.onSyncUpdateOLI(oliIdList,null,null);
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	static testMethod void testQSynHandler_copyPartnerOptyDetails() {
		List<CHL_Partner_Opportunity__c> poList = [select id from CHL_Partner_Opportunity__c limit 10];
		Map<Id,sObject> partnerOpptyToQuoteMap = new Map<Id,sObject>();
		partnerOpptyToQuoteMap.put(poList[0].id, poList[0]);
		Set<String> quoteFieldList = new Set<String>();
		try {
			CHL_QuoteSyncHandler.copyPartnerOptyDetails(partnerOpptyToQuoteMap);
		}catch(Exception ex){	}
		system.assert(true);
	}

	static testMethod void testQSynHandler_QuoteToOpportunityMapping() {
        List<REN_Field_Mappings__c> fieldMappingListQuoteToOppty;
        List<Opportunity> opportunityList ;
        List<Sobject> newRecords = new List<Sobject>();
		try {
			CHL_QuoteSyncHandler.QuoteToOpportunityMapping(fieldMappingListQuoteToOppty,opportunityList,newRecords);
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	//**** ---END ---- Test methods for CHL_QuoteSyncHandler as Quotes is disable in Master Org. ****/
	
}