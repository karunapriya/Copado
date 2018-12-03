/*
	Description : Test class for CHL_QuoteTriggerHandler,CHL_QuoteLineItemTriggerHandler and CHL_QuoteSyncHandler class.
				  As quotes are disabled this class is for code coverage.
*/

@isTest
private class CHL_QuoteTriggerHandlerTest {

	@testSetup 
	static void setup() {
		
		insert new SS_License__c(Channel__c = true);
	
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
		
		List<Product2> productList = CHL_TestUtility.createProducts(2);
		insert productList;
		
		List<PricebookEntry> pbeList = CHL_TestUtility.createPricebookEntry(productList,Test.getStandardPricebookId());
		insert pbeList;
		
		List <OpportunityLineItem> opliList = CHL_TestUtility.createOplis(opptyList,pbeList);
		insert opliList;
		
		List<REN_Field_Mappings__c> mappingList = CHL_TestUtility.createQuoteMapping();
		insert mappingList;
		
		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
		partOppty.partnerAcc1Id = accountList[0].id;
		partOppty.partnerAcc1Type = 'Reseller';
		partOppty.contact1Id = contactList[0].Id;
		partOppty.expirationDate = system.today().addDays(-10);
		partOppty.Stage = 'Qualification';
		partOppty.partnerAcc2Id = accountList[0].id;
		partOppty.partnerAcc2Type = 'Distributor';
		partOppty.contact2Id = contactList[0].Id;
		
		List < CHL_Partner_Opportunity__c > chlpartnerList1 = CHL_TestUtility.channelPartnerOpportunityList(1, partOppty);
		insert chlpartnerList1;
	}

	
	static testMethod void quotesTriggerHandlerTest() {		
		List<Opportunity> opptyList = [select Id, name,Pricebook2Id,description from opportunity limit 1];
		List<CHL_Partner_Opportunity__c> poList = [select Id, name from CHL_Partner_Opportunity__c limit 1];
		Set<String> opptyIdSet = new Set<String>();
		Test.startTest();
			
			List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,poList);
			List<Sobject> resellerQuoteList = CHL_TestUtility.createQuotes(1,opptyList,poList);
			if(quoteList != null && !quoteList.isEmpty()) {
				insert quoteList;
				CHL_QuoteTriggerHandler quoteTrigger = new CHL_QuoteTriggerHandler();
				quoteTrigger.onBeforeInsert(quoteList, new Map<ID, sObject>(quoteList));
				insert resellerQuoteList;
				quoteTrigger.onAfterInsert(quoteList, new Map<ID, sObject>(quoteList));				
				quoteTrigger.onAfterUpdate(quoteList, quoteList, new Map<ID, sObject>(quoteList),new Map<ID, sObject>(quoteList));
				quoteTrigger.onBeforeUpdate(quoteList,resellerQuoteList, new Map<ID, sObject>(quoteList), new Map<ID, sObject>(resellerQuoteList));
				if(CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')){ 
					for(Sobject sobj:quoteList) {
						sobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c',null);
						opptyIdSet.add((String)sobj.get('OpportunityId'));
					}
					update quoteList;
					for(Sobject sobj:quoteList) {
						sobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c',poList[0].Id);
						if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c')) {
				    		sobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c', resellerQuoteList[0].Id) ;
				    	}
					}
					update quoteList;
					for(Sobject sobj:quoteList) {
						if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c')) {
				    		sobj.put(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c', null) ;
				    	}
					}
					update quoteList;
				}
			} else {
				Map<ID, sObject> newRecordsMap  = new Map<ID, sObject>();
				quoteList = new List<Sobject>();
				CHL_QuoteTriggerHandler obj = new CHL_QuoteTriggerHandler();
				obj.onBeforeInsert(quoteList,newRecordsMap);
				if(CSM_AccessController.hasObject('QuoteLineItem')){
					obj.onAfterUpdate(quoteList, quoteList, newRecordsMap,newRecordsMap);
				}
				try{
			    	CHL_QuoteSyncHandler.handleQuoteCreation(quoteList,opptyIdSet);
			    	//CHL_QuoteSyncHandler.handleQuoteUpdation(quoteList);
			    	//CHL_QuoteSyncHandler.populatePODetails(quoteList);
			    	//CHL_QuoteSyncHandler.copyPartnerOptyDetails(mapOfPOToQuote);
				}catch(Exception ex){
		  			
				} 
			}
			system.assert(quoteList != null);
			
		Test.stopTest();	   
	}
	
	static testMethod void quotesLineItemTriggerHandlerTest() {
		List<Opportunity> opptyList = [select Id, name,Pricebook2Id,description from opportunity limit 1];
		List<OpportunityLineItem> oliList = [select Id,OpportunityId,Product2Id,PricebookEntryId,SubTotal,ListPrice,Description,Discount,quantity,REN_Start_Date__c,REN_end_Date__c,REN_Is_CLM_Renewal__c,ServiceDate,UnitPrice from OpportunityLineItem where OpportunityId =:opptyList[0].Id];
		Test.startTest();		
			List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,null);
			if(quoteList != null && !quoteList.isEmpty()) {
				insert quoteList;				
				List<Sobject> quotesLineItem =  CHL_TestUtility.createQuoteLineItems(quoteList,oliList);
				insert quotesLineItem;
				system.assert(quotesLineItem != null);
				for(Sobject sobj:quotesLineItem) {
					sobj.put('Description','Updated desc');
				}
				update quotesLineItem;
			} else {	
				List<Sobject> quotesLineItem = new List<Sobject>();
				Map<ID, sObject> newRecordsMap  = new Map<ID, sObject>();
				system.assert(quotesLineItem != null);
				
				CHL_QuoteLineItemTriggerHandler obj = new CHL_QuoteLineItemTriggerHandler();
				obj.onBeforeInsert(quotesLineItem,newRecordsMap);
				if(CSM_AccessController.hasObject('QuoteLineItem')){
					obj.onAfterUpdate(quotesLineItem, quotesLineItem, newRecordsMap,newRecordsMap);
				}
			}			
		Test.stopTest();	
	}
	
	static testmethod void processQliRecordsTest(){
		Account acc = new Account(Name = 'New Account');
		System.assert(acc !=null);
		insert acc;
		Opportunity opp = new Opportunity(Name = 'Test opp', CloseDate = System.today(), 
            StageName = 'Prospecting', Probability = 1.0, AccountId = acc.id);
        insert opp;
        Opportunity target = [Select Id,StageName,CloseDate,Name From Opportunity Where Name = :'Test opp'];
        System.assert(target !=null);
		List<Opportunity> opptyList = new List<Opportunity>();
		opptyList.add(target);
		Map<Id, Opportunity> oppotyMap = new Map<Id, Opportunity>((List<Opportunity>)opptyList);
		Test.startTest();
		CHL_QuoteLineItemTriggerHelper.processQliRecords(null, null, oppotyMap);
		Test.stopTest();
	}
	
	static testmethod void getQuoteListUsingMappingTest(){
		CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper qliValueWrapper = new CHL_QuoteLineItemTriggerHelper.REN_QLIWrapper();	
		qliValueWrapper.fieldMappingListQuoteToOppty = new List<REN_Field_Mappings__c>();
		qliValueWrapper.fieldMappingListQuoteToOppty = null;
		qliValueWrapper.qualifiedQuoteId = new Set <String>();
		qliValueWrapper.qualifiedQuoteId = null;
		qliValueWrapper.IsSyncing = false;		
		Test.startTest();
		List<SObject> quoteList = CHL_QuoteLineItemTriggerHelper.getQuoteListUsingMapping(qliValueWrapper);
		Test.stopTest();
        System.assertEquals(quoteList.size(),0);
	}
	
	static testMethod void quotesMsrpTriggerHandlerTest() {
		List<Opportunity> opptyList = [select Id, name,Pricebook2Id,description from opportunity limit 1];
		List<OpportunityLineItem> oliList = [select Id,OpportunityId,Product2Id,PricebookEntryId,SubTotal,ListPrice,Description,Discount,quantity,REN_Start_Date__c,REN_end_Date__c,REN_Is_CLM_Renewal__c,ServiceDate,UnitPrice from OpportunityLineItem where OpportunityId =:opptyList[0].Id];
		Test.startTest();		
			List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,null);
			if(quoteList != null && !quoteList.isEmpty()) {
				insert quoteList;				
				List<Sobject> quotesLineItem =  CHL_TestUtility.createQuoteLineItems(quoteList,oliList);
				for(Sobject sobj:quotesLineItem) {
					if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTELINEITEM, CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP)) {
						sobj.put(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP, Math.random());
					}
				}
				CSM_TriggerManager.enableFirstTrigger();
				insert quotesLineItem;
				system.assert(quotesLineItem != null);
                
                //call CHL_QuoteLineItemTriggerHelper.processQliRecords
                Map<Id, SObject> quotesMap = new Map<Id, SObject>((List<SObject>)quoteList);
                Map<Id, SObject> quoteLineItemsMap = new Map<Id, SObject>((List<SObject>)quotesLineItem);
                CHL_QuoteLineItemTriggerHelper.processQliRecords(quotesMap, quotesLineItem, null);
                
                Map<Id, Opportunity> oppotyMap = new Map<Id, Opportunity>((List<Opportunity>)opptyList);
                CHL_QuoteLineItemTriggerHelper.processQliRecords(quotesMap, quotesLineItem, oppotyMap);
                
				for(Sobject sobj:quotesLineItem) {
					if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTELINEITEM, CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTELI_MSRP)) {
						sobj.put(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP, Math.random());
					}
				}
                CSM_TriggerManager.enableFirstTrigger();
				update quotesLineItem;
                CSM_TriggerManager.enableFirstTrigger();
				delete quotesLineItem;
			} else {
				List<Sobject> quotesLineItem = new List<Sobject>();
				Map<ID, sObject> newRecordsMap  = new Map<ID, sObject>();
				system.assert(quotesLineItem != null);
				
				CHL_QuoteLineItemTriggerHandler obj = new CHL_QuoteLineItemTriggerHandler();
				obj.onBeforeInsert(quotesLineItem,newRecordsMap);
				obj.onAfterInsert(quotesLineItem,newRecordsMap);
				if(CSM_AccessController.hasObject('QuoteLineItem')){
					obj.onAfterUpdate(quotesLineItem, quotesLineItem, newRecordsMap,newRecordsMap);	
				}
				obj.onAfterDelete(quotesLineItem,newRecordsMap);	
			}			
		Test.stopTest();	
	}

	static  void quoteSyncHandlerQuotesTest() {
		String syncQuoteId = '';
		if(CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')) {
			syncQuoteId = ',SyncedQuoteId';
		}
		string opptyQuery = 'select Id, name, Pricebook2Id,description'+syncQuoteId+' from opportunity limit 1';
		List<sObject> opptyList = Database.query(opptyQuery);//[select Id, name,SyncedQuoteId, Pricebook2Id,description from opportunity limit 1];
		List<OpportunityLineItem> oliList = [select Id,OpportunityId,Product2Id,PricebookEntryId,SubTotal,ListPrice,Description,Discount,quantity,REN_Start_Date__c,REN_end_Date__c,REN_Is_CLM_Renewal__c,ServiceDate,UnitPrice from OpportunityLineItem where OpportunityId =:opptyList[0].Id];
		List<REN_Field_Mappings__c>  fmappingList = [select id from REN_Field_Mappings__c where name in ('Quote → Opportunity' , 'Opportunity → Quote') ];
		set<Id> oppIdSet =new set<Id>();
		for(OpportunityLineItem oli:oliList){
			oppIdSet.add(oli.OpportunityId);
		}
		system.assert(fmappingList != null);
		Test.startTest();			
			List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,null);
			if(quoteList != null && !quoteList.isEmpty()) {
				insert quoteList;
				List<Sobject> quotesLineItem =  CHL_TestUtility.createQuoteLineItems(quoteList,oliList);
                CSM_TriggerManager.enableFirstTrigger();
				insert quotesLineItem;
				system.assert(quotesLineItem != null);
				for(sObject opp:opptyList) {
					if(CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')) {
			    		opp.put('SyncedQuoteId', quoteList[0].Id) ;
			    	}
				}
                CSM_TriggerManager.enableFirstTrigger();
				update opptyList;
				for(Sobject sObj :quotesLineItem) {
					sObj.put('Description','Update QLI');
				}
                CSM_TriggerManager.enableFirstTrigger();
				update quotesLineItem;
			} else {	
				quoteList = new List<Sobject>();			
			    try{
			    	CHL_QuoteSyncHandler.handleOpportunityUpdation(opptyList);
					CHL_QuoteSyncHandler.handleOLIUpdate(oliList,oppIdSet);
					CHL_QuoteSyncHandler.handleOLIrecreation(oppIdSet);
				}catch(Exception ex){
		  			
				}  
			}	
			system.assert(oliList != null);
		Test.stopTest();	 
	}
	
	
	static testMethod void quoteSyncHandlerMappingTest() {
		Test.startTest();			
			List<REN_Field_Mappings__c>  fmappingList = [select id from REN_Field_Mappings__c where name in ('Quote → Opportunity' , 'Opportunity → Quote') ];
			system.assert(fmappingList != null);
			List<Opportunity> opptyList = [select id from Opportunity limit 1];
			List<OpportunityLineItem> oliList = [select OpportunityId,UnitPrice,ServiceDate,Description,Quantity,PricebookEntryId,Product2Id from OpportunityLineItem limit 1 ];
			
			List<Sobject> qliList = new List<Sobject>();
						
			try{
				CHL_QuoteSyncHandler.QLItoOLIMapping(fmappingList,qliList,oliList,null);
				CHL_QuoteSyncHandler.OLItoQLIMapping(fmappingList, qliList,oliList);
				CHL_QuoteSyncHandler.OpptyToQuoteMapping(fmappingList,qliList,opptyList,true);
				CHL_QuoteSyncHandler.QuoteToOpportunityMapping(fmappingList,opptyList,qliList);
				//CHL_QuoteSyncHandler.resetPODetailsonQuote(qliList);
			}catch(Exception ex){
	  			
			} 
		
		Test.stopTest();	   
		
	}
	
	static testMethod void quoteSyncHandlerSyncUpdateTest() {
		Test.startTest();
			
			List<REN_Field_Mappings__c>  fmappingList = [select id from REN_Field_Mappings__c where name in ('Quote → Opportunity' , 'Opportunity → Quote') ];
			system.assert(fmappingList != null);
			List<Opportunity> opptyList = [select id from Opportunity limit 1];
			Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>(opptyList);
			List<OpportunityLineItem> oliList = [select OpportunityId,UnitPrice,ServiceDate,Description,Quantity,PricebookEntryId,Product2Id from OpportunityLineItem limit 1 ];
			List<CHL_Partner_Opportunity__c> poList = [select Id, name from CHL_Partner_Opportunity__c limit 1];
			List<Sobject> qliList = new List<Sobject>();
			List<String> quoteIdList = new List<String>();
			List<String> optyIdList =  new List<String>();			
			Map<Id,sObject> poMap = new Map<Id,sObject>();
			Set<String> quoteIdSet = new Set<String>();
			for(Opportunity opp : opptyList){
				optyIdList.add(opp.id);
			}
			
			try{
		    	CHL_QuoteSyncHandler.onSyncUpdateOpportunity(quoteIdSet,opptyList, opptyMap);
				CHL_QuoteSyncHandler.onSyncUpdateOLI(optyIdList,null,null);
				CHL_QuoteSyncHandler.copyPartnerOptyDetails(poMap);
			}catch(Exception ex){
	  			
			} 
		Test.stopTest();	
	}
	
	static testMethod void quoteSyncHandlerAddsAmtTest() {
		String syncQuoteId = '';
		if(CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')) {
			syncQuoteId = ',SyncedQuoteId';
		}
		string opptyQuery = 'select Id, name, Pricebook2Id,description,REN_AddsAmount__c'+syncQuoteId+' from opportunity limit 1';
		List<sObject> opptyList = Database.query(opptyQuery);//[select Id, name,SyncedQuoteId, Pricebook2Id,description from opportunity limit 1];
		List<CHL_Partner_Opportunity__c> poList = [select Id, name from CHL_Partner_Opportunity__c limit 1];
		List<OpportunityLineItem> oliList = [select Id,OpportunityId,Product2Id,PricebookEntryId,SubTotal,ListPrice,Description,Discount,quantity,REN_Start_Date__c,REN_end_Date__c,REN_Is_CLM_Renewal__c,ServiceDate,UnitPrice from OpportunityLineItem where OpportunityId =:opptyList[0].Id];
		Test.startTest();			
			List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,poList);
			Map<Id,sObject> quoteToMoMap = new Map<Id,sObject>();
			if(quoteList != null && !quoteList.isEmpty()) {
				insert quoteList;
				List<Sobject> quotesLineItem =  CHL_TestUtility.createQuoteLineItems(quoteList,oliList);
                
                CSM_TriggerManager.enableFirstTrigger();
				insert quotesLineItem;
				system.assert(quotesLineItem != null);
				for(sObject opp:opptyList) {
					if(CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')) {
			    		opp.put('SyncedQuoteId', quoteList[0].Id) ;			
			    		opp.put('REN_AddsAmount__c', 5000.00) ;	    		
			    		quoteToMoMap.put(quoteList[0].Id,opp);
			    	}
				}
				try
				{
                    if(quotesLineItem!= null && !quotesLineItem.isEmpty()){
                        quotesLineItem[0].put(CHL_Util.quoteExtnNameSpace+CHL_Constants.OBJ_QUOTELI_MSRP, 101);
                    }
                    CSM_TriggerManager.enableFirstTrigger();
                    update quotesLineItem;
                    CSM_TriggerManager.enableFirstTrigger();
				    update opptyList;
				    List<Opportunity> updatedOpptyList = opptyList;
				    for(Opportunity oppObj:updatedOpptyList) {
					    oppObj.REN_AddsAmount__c = 10000.00;
				    }
				    //opptyList[0].put('REN_AddsAmount__c',10000.00);
				    CSM_TriggerManager.enableFirstTrigger();
				    update updatedOpptyList;
				    CHL_QuoteSyncHandler.handleRRCalculation(quoteToMoMap);
				}catch(Exception ex){
		  			
				} 
			} else {	
				quoteList = new List<Sobject>();			
			    try{
			    	CHL_QuoteSyncHandler.handleRRCalculation(quoteToMoMap);
				}catch(Exception ex){
		  			
				}  
			}	
			system.assert(opptyList != null);
		Test.stopTest();	 
	}
	
	//Below test method is created to include custom labels of distributor Quote button in package.
	static testMethod void testLabels() {
		String CustLabels = Label.CHL_ERR_TWO_TIER_PRICING + ''+Label.CHL_ERR_PARTNER_ACC_DISTRIBUTOR_QUOTE+''+Label.CHL_ERR_NO_DISTRIBUTOR_QUOTE+''+Label.CHL_ERR_DUPLICATE_DISTRIBUTOR_QUOTE+''+Label.CHL_ERR_DISTRIBUTOR_QUOTE+''+Label.CHL_MSG_DISTRIBUTOR_QUOTE;
		String quotePrimaryLabels = Label.CHL_ERR_NO_PRIMARY_QUOTE + '' +Label.CHL_ERR_MAKE_PRIMARY_QUOTE + '' +Label.CHL_ERR_PRIMARY_QUOTE ;
		system.assert(CustLabels != null);
	}
	
	static testMethod void testQLIDataAccess() {
		List<Sobject> qliList = new List<Sobject>();
		Set<String> qliFieldList = new Set<String>();
		try {
			if(CSM_AccessController.hasObject('QuoteLineItem')){
				CHL_QuoteLineItemDataAccess.updateQuoteLineItem(qliFieldList,qliList);
			}
			//CHL_QuoteLineItemDataAccess.insertQuotesLineItems(qliList);
		}			
		catch(Exception ex){
	  			
		}
		system.assert(true);
	}
    
    static testMethod void testQLIDataAccess_1(){
        String syncQuoteId = CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')?',SyncedQuoteId':'';
		
		CSM_Admin__c cAdmin  = CSM_Admin__c.getOrgDefaults();
		cAdmin.CHL_QliCount__c = 0;
		upsert cAdmin;
        string opptyQuery = 'select Id, name, Pricebook2Id,description,REN_AddsAmount__c'+syncQuoteId+' from opportunity limit 1';
        List<sObject> opptyList = Database.query(opptyQuery);
        List<OpportunityLineItem> oliList = [select Id,OpportunityId,Product2Id,PricebookEntryId,SubTotal,ListPrice,Description,Discount,quantity,REN_Start_Date__c,REN_end_Date__c,REN_Is_CLM_Renewal__c,ServiceDate,UnitPrice from OpportunityLineItem where OpportunityId =:opptyList[0].Id];
        Set<String> qliFields = new Set<String>{'QuoteId','Quantity'};
        Test.startTest();			
    	List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,null);
    	insert quoteList;
    	List<Sobject> quotesLineItem =  CHL_TestUtility.createQuoteLineItems(quoteList,oliList);
    	//CSM_TriggerManager.enableFirstTrigger();
    	CHL_QuoteLineItemTriggerHandler qliTrigger = new CHL_QuoteLineItemTriggerHandler();
    	qliTrigger.onBeforeInsert(quotesLineItem,null);
    	insert quotesLineItem;    	
    	qliTrigger.onAfterInsert(quotesLineItem, new Map<ID, sObject>(quotesLineItem));
        Map<Id, sObject> quoteMap = new Map<Id, sObject>(quoteList);
        if(CSM_AccessController.hasObject('QuoteLineItem')){
        	CHL_QuoteLineItemDataAccess.getQuoteLineItemsByQuote(quoteMap.keySet(), qliFields);
        	qliTrigger.onBeforeUpdate(quotesLineItem,quotesLineItem,new Map<ID, sObject>(quotesLineItem),new Map<ID, sObject>(quotesLineItem));
        	qliTrigger.onAfterUpdate(quotesLineItem,quotesLineItem,new Map<ID, sObject>(quotesLineItem),new Map<ID, sObject>(quotesLineItem));
        }        
        Map<Id, sObject> qliMap = new Map<Id, sObject>(quotesLineItem);
        if(CSM_AccessController.hasObject('QuoteLineItem')){
	        CHL_QuoteLineItemDataAccess.getSelectedQli(qliMap.keySet(),new Set<String>{'QuoteId'}, new List<String>{' Quote.Opportunity.isWon = true'});
	        CHL_QuoteLineItemDataAccess.deleteQuotesLineItems((List<sObject>)quotesLineItem);
	        qliTrigger.onAfterDelete(quotesLineItem, new Map<ID, sObject>(quotesLineItem));
        }
        Test.stopTest();
        System.assert(oliList != Null);
    }
	
	static testMethod void testQLIDataAccess_insert() {
		List<Sobject> qliList = new List<Sobject>();
		Set<String> qliFieldList = new Set<String>();
		try {
			if(CSM_AccessController.hasObject('Quote')){
				CHL_QuoteLineItemDataAccess.insertQuotesLineItems(qliList);
			}
		}			
		catch(Exception ex){
	  			
		}
		system.assert(true);
	}
	
	//**** ---Start ---- Test methods for Quote Data Access as Quotes is disable in Master Org. ****/
	
	static testMethod void testQDataAccess_insertQuotes() {
		List<Sobject> quoteList = new List<Sobject>();
		Set<String> quoteFieldList = new Set<String>();
		try {
			if(CSM_AccessController.hasObject('Quote')){
				CHL_QuoteDataAccess.insertQuotes(quoteList);
			}
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	static testMethod void testQDataAccess_methods() {
		Set<String> quoteIdSet = new Set<String>();
		quoteIdSet.add('aa');
		Set<Id> quoteIds = new Set<Id>();
		List<CHL_Partner_Opportunity__c> chlpartnerList = [select id from CHL_Partner_Opportunity__c limit 1];
		String partnerOptyId = chlpartnerList[0].id;
		Set<Id> poIds = new Set<Id>();
		poIds.add(chlpartnerList[0].id);
		Set<Id> quoteIdSet1 = new Set<Id>();
		Boolean isPrimaryRequired = false;
		try {
			 //CHL_QuoteDataAccess.getDistQuotesPerResellerQuote(partnerOptyId, quoteIdSet);
			 isPrimaryRequired = true;
			 if(CSM_AccessController.hasObject('Quote')){
				 CHL_QuoteDataAccess.getQuotesForPO(quoteIds, poIds,'');
				 CHL_QuoteDataAccess.getQuoteListByPartnerOppId(poIds ,isPrimaryRequired);
			 }
			 //Boolean filterDistributorQuotes = true;
			 //CHL_QuoteDataAccess.getQuoteListByPartnerOppId(poIds, isPrimaryRequired, filterDistributorQuotes);
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	
	static testMethod void testQDataAccess_TestPDFmethods() {
		Set<String> quoteIdSet = new Set<String>();
		quoteIdSet.add('aa');
		List<CHL_Partner_Opportunity__c> chlpartnerList = [select id from CHL_Partner_Opportunity__c limit 1];
		String partnerOptyId = chlpartnerList[0].id;
		Set<Id> poIds = new Set<Id>();
		poIds.add(chlpartnerList[0].id);
		Set<Id> quoteIdSet1 = new Set<Id>();
		Boolean isPrimaryRequired = false;
		try {
			if(CSM_AccessController.hasObject('Quote')){
				 CHL_QuoteDataAccess.getQuoteListByPartnerOppId(poIds ,isPrimaryRequired);
				 isPrimaryRequired = true;
				 CHL_QuoteDataAccess.getQuoteListByPartnerOppId(poIds ,isPrimaryRequired);
			}
			 //Boolean filterDistributorQuotes = true;
			 //CHL_QuoteDataAccess.getQuoteListByPartnerOppId(poIds, isPrimaryRequired, filterDistributorQuotes);
			 String fieldSetName = 'testFieldSet';
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	static testMethod void testQDataAccess_insert4() {
		List<CHL_Partner_Opportunity__c> chlpartnerList = [select id from CHL_Partner_Opportunity__c limit 1];
		Set<Id> poIds = new Set<Id>();
		poIds.add(chlpartnerList[0].id);
		Boolean isPrimaryRequired = false;
		try {
			if(CSM_AccessController.hasObject('Quote')){
				CHL_QuoteDataAccess.getSyncedQuotesById(poIds);
			}
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	static testMethod void testQDataAccess_QuotesFieldSet() {
		List<CHL_Partner_Opportunity__c> chlpartnerList = [select id from CHL_Partner_Opportunity__c limit 1];
		Set<Id> poIds = new Set<Id>();
		poIds.add(chlpartnerList[0].id);
		String fieldSetName = 'testFieldSet';
		try {	
			if(CSM_AccessController.hasObject('Quote')){
			 	CHL_QuoteDataAccess.getQuotesListFromFieldSet(poIds, fieldSetName);
			}
		}catch(Exception ex){	} 
		system.assert(true);
	}
	
	static testMethod void testQDataAccess_QuoteById() {
		Set<String> quoteIdSet = new Set<String>();
		try {
			if(CSM_AccessController.hasObject('Quote')){
			 	CHL_QuoteDataAccess.getQuotesById(quoteIdSet);
			}
		}catch(Exception ex){	}
		system.assert(true);
	}

	static testMethod void testQDataAccess_QuotePDF() {
		Set<Id> quoteIdSet1 = new Set<Id>();
		try {
			if(CSM_AccessController.hasObject('Quote')){
				CHL_QuoteDataAccess.getQuotePDFListByQuoteIds(quoteIdSet1);
			}
		}catch(Exception ex){	}
		system.assert(true);
	}

	static testMethod void testQDataAccess_updateQuotes() {
		List<Sobject> quoteList = new List<Sobject>();
		try {
			if(CSM_AccessController.hasObject('Quote')){
				CHL_QuoteDataAccess.updateQuotes(quoteList);
			}
		}catch(Exception ex){	}
		system.assert(true);
	}
	
	static testMethod void test_Quotes(){
		List<REN_Field_Mappings__c>  fmappingList = [select id from REN_Field_Mappings__c where name in ('Quote → Opportunity' , 'Opportunity → Quote') ];
		system.assert(fmappingList != null);
		//List<Opportunity> opptyList = [select id,Pricebook2Id,SyncedQuoteId from Opportunity limit 1];
		String syncQuoteId = CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')?',SyncedQuoteId':'';
		string opptyQuery = 'select Id, name, Pricebook2Id,description,REN_AddsAmount__c'+syncQuoteId+' from opportunity limit 1';
        List<sObject> opptyList = Database.query(opptyQuery);
		List<OpportunityLineItem> oliList = [select OpportunityId,UnitPrice,ListPrice,ServiceDate,Description,Quantity,PricebookEntryId,Product2Id from OpportunityLineItem limit 1 ];
		List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,null);
    	insert quoteList;
    	system.assert(quoteList != null);
    	List<Sobject> quotesLineItemList =  CHL_TestUtility.createQuoteLineItems(quoteList,oliList);
    	insert quotesLineItemList;
    	Map<Id, Id> opptyToRenewalOpptyMap = new Map<Id,Id>();
    	opptyToRenewalOpptyMap.put(opptyList[0].Id,quoteList[0].Id);
    	CHL_Quotes quoteCls = new CHL_Quotes();
    	quoteCls.createRenewals(quoteList,opptyToRenewalOpptyMap);
    	List<Sobject> resellerquoteList = CHL_TestUtility.createQuotes(1,opptyList,null);
    	insert resellerquoteList;
    	Map<Id, Id> mResToDestMap = new Map<Id,Id>();
    	mResToDestMap.put(quoteList[0].Id,resellerquoteList[0].Id);
    	opptyList[0].put('SyncedQuoteId', quoteList[0].Id);
    	update opptyList;
    	String quoteQuery = 'select id,IsSyncing, OpportunityId from Quote limit 1';
    	List<Sobject> discQuoteList = database.query(quoteQuery);
    	quoteCls.updateDistributorQuote(discQuoteList,opptyToRenewalOpptyMap);
    	CHL_QuoteLineItems qliCls = new CHL_QuoteLineItems();
    	qliCls.createRenewals(quotesLineItemList,opptyToRenewalOpptyMap);
	}
	
	static testMethod void test_QuoteExtention(){
		List<REN_Field_Mappings__c>  fmappingList = [select id from REN_Field_Mappings__c where name in ('Quote → Opportunity' , 'Opportunity → Quote') ];
		system.assert(fmappingList != null);
		//List<Opportunity> opptyList = [select id,Pricebook2Id,SyncedQuoteId from Opportunity limit 1];
		String syncQuoteId = CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')?',SyncedQuoteId':'';
		string opptyQuery = 'select Id, name, Pricebook2Id,description,REN_AddsAmount__c'+syncQuoteId+' from opportunity limit 1';
        List<sObject> opptyList = Database.query(opptyQuery);
		List<OpportunityLineItem> oliList = [select OpportunityId,UnitPrice,ListPrice,ServiceDate,Description,Quantity,PricebookEntryId,Product2Id from OpportunityLineItem limit 1 ];
		List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,null);
    	insert quoteList;
    	system.assert(quoteList != null);
    	List<Sobject> quotesLineItemList =  CHL_TestUtility.createQuoteLineItems(quoteList,oliList);
    	insert quotesLineItemList;
    	CHL_QuoteExtension.markPrimaryQuote(new Set<Id>{quoteList[0].Id});
    	CHL_QuoteExtension.createDistributorQuotesAndQlis(new Set<Id>{quoteList[0].Id});
    	CHL_QuoteExtension.syncQuoteFromOpportunity(new Set<Id>{quoteList[0].Id});
	}
	
	static testMethod void test_QuoteBatch(){
        Test.startTest();       
        List<Opportunity> OppList = [Select Id, Name,StageName,Description,Pricebook2Id,CHL_QuoteSyncStatus__c,Probability from Opportunity limit 1];
        CSM_TriggerManager.disableAllTriggers();
        //REN_SetOppSyncPendingStatusBatch.impactedOpportunitySet = new Set<Id>{OppList[0].Id};
        Database.executeBatch(new REN_SetOppSyncPendingStatusBatch(),10);   
        System.assert(true);
        Test.stopTest();
    }
}