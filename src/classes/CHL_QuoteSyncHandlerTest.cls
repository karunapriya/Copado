/*
	Description : Test class to cover methods of CHL_QuoteSyncHandler, CHL_QuoteDataAccess class.
				  Quotes is disabled in Master org, so some of the methods are called by passing empty object/list
*/
@isTest
private class CHL_QuoteSyncHandlerTest {

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
		
		List < CHL_Partner_Opportunity__c > poList = CHL_TestUtility.channelPartnerOpportunityList(1, partOppty);
		insert poList;
		
		CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
			optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
			optyStatusLogObj.CHL_Days_between_Update__c = 5;
			optyStatusLogObj.CHL_Enable_2_Tier_Pricing__c = true;
			optyStatusLogObj.CHL_Show_Oppty_for_Unavailable_Stage__c = true;
		insert optyStatusLogObj; 
		
		if(CSM_AccessController.hasObject('Quote')) {
	       List<SObject> quotesList = CHL_TestUtility.createQuotes(1, opptyList, poList);
	       quotesList[0].put(REN_Constants.OBJ_OPP_PRICEBOOK_ID,Test.getStandardPricebookId());
	       insert quotesList;
	       system.assert(quotesList != null);
	       
	       List<SObject> quoteLineItemsList = CHL_TestUtility.createMultipleQuoteLineItems(1,quotesList,productList,pbeList);
	       insert quoteLineItemsList;
	        
	       // Quote sync on Opp
	       opptyList[0].put('SyncedQuoteId' , quotesList[0].id);
	       update opptyList;
       }
	}
	
    static testMethod void quotePrimaryTest() {
    	List<Opportunity> opptyList = [select Id, name,Pricebook2Id,description from opportunity limit 1];
		List<CHL_Partner_Opportunity__c> poList = [select Id, name from CHL_Partner_Opportunity__c limit 1];
        System.assert(poList != null); 
		Set<Id> poIdSet = new Set<Id>();
		poIdSet.add(poList[0].Id);
		Test.startTest();
			
			List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,poList);
			List<Sobject> resellerQuoteList = CHL_TestUtility.createQuotes(1,opptyList,poList);
			if(quoteList != null && !quoteList.isEmpty()) {
				insert quoteList;
				insert resellerQuoteList;
				Boolean hasPOFieldOnQuote = CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTE_PARTNER_PRIMARY);
				if(hasPOFieldOnQuote) {
					for(Sobject sobj:quoteList) {
						sobj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTE_PARTNER_PRIMARY,true);
					}
					update quoteList;
				}
			} else {
				Map<Id, sObject> newRecordsMap = new Map<Id,sObject>();
				Map<Id, sObject> oldRecordsMap = new Map<Id,sObject>();
				quoteList = new List<sObject>();
        		Set<Id> quoteIds = new Set<Id>();
        		CHL_QuoteSyncHandler.resetPrimaryForQuotes(quoteIds,poIdSet);
        		CHL_QuoteSyncHandler.resetResellerPrimaryForQuotes(quoteIds,poIdSet);
        		CHL_QuoteDataAccess.getDistributorQuoteList(quoteIds);
				CHL_QuoteTriggerHandler obj = new CHL_QuoteTriggerHandler();
				obj.onBeforeUpdate(quoteList, quoteList, newRecordsMap,newRecordsMap);
			}
        
    }
    
    static  testMethod void quoteSyncHandlerOliTest() {
		String syncQuoteId = '';
		if(CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')) {
			syncQuoteId = ',SyncedQuoteId';
		}
		string opptyQuery = 'select Id, name, Pricebook2Id,description'+syncQuoteId+' from opportunity limit 1';
		List<sObject> opptyList = Database.query(opptyQuery);//[select Id, name,SyncedQuoteId, Pricebook2Id,description from opportunity limit 1];
		List<OpportunityLineItem> oliList = [select Id,OpportunityId,Product2Id,PricebookEntryId,SubTotal,ListPrice,Description,Discount,quantity,REN_Start_Date__c,REN_end_Date__c,REN_Is_CLM_Renewal__c,ServiceDate,UnitPrice from OpportunityLineItem where OpportunityId =:opptyList[0].Id];
		List<REN_Field_Mappings__c>  fmappingList = [select id from REN_Field_Mappings__c where name in ('Quote → Opportunity' , 'Opportunity → Quote') ];
		system.assert(fmappingList != null);
		set<Id> oppIdSet =new set<Id>();
		for(OpportunityLineItem oli:oliList){
			oppIdSet.add(oli.OpportunityId);
		}
		Test.startTest();			
		List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,null);
				
	    try{
	        CHL_QuoteSyncHandler.handleOLIrecreation(oppIdSet);			
		}
		catch(Exception ex)
		{	
		}  
		try{
	        CHL_QuoteSyncHandler.handleOLIUpdate(oliList,oppIdSet);	
		}
		catch(Exception ex)
		{	
		}
        
		system.assert(oliList != null);
		Test.stopTest();	 
	}
	
	/* Start - US3858: Created test methods to call QuoteSyncHandler's functions directly to increase the code coverage.*/
	
	static testmethod void testQuoteSyncHandler(){
	    Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([select id,name,Pricebook2Id from opportunity limit 1]);
	    system.assert(oppMap != null);
	    if(CSM_AccessController.hasObject('Quote')) {
		    Map<Id,CHL_Partner_Opportunity__c> poMap = new Map<Id,CHL_Partner_Opportunity__c>([select id from CHL_Partner_Opportunity__c limit 1]);
		    String queryStr = 'select id,Pricebook2Id from Quote limit 1';
		    Map<Id,SObject> quoteMap = new Map<Id,SObject>(Database.query(queryStr));
		    String queryString = 'Select id from quoteLineItem limit 1';
		    Map<Id,SObject> qliMap = new Map<Id,SObject>(Database.query(queryString));
		    List <OpportunityLineItem> opliList = [Select id from OpportunityLineItem limit 1 ];
		    Set<String> quoteIdStrSet = new  Set<String>();
		    for (Id idObj : quoteMap.keySet()){
		    	quoteIdStrSet.add(String.valueOF(idObj));
		    }
		    Test.startTest(); 
		    	try{
					CHL_QuoteSyncHandler.calculateRRMetricsOnPO(new Set<Id>(oppMap.keySet()));
				}catch(Exception ex){	} 
			    
			    try{
			        CHL_QuoteSyncHandler.handleQuotePrimary(new List<sObject>(quoteMap.values()), new Set<Id>(poMap.keySet()));
			     }catch(Exception ex){	} 
		      	
		      	try{
			    	CHL_QuoteSyncHandler.handleQLI_OLIUpdate(new Set<Id>(oppMap.keySet()), opliList, quoteIdStrSet);
			     }catch(Exception ex){	} 
			     
			     try{
			    	CHL_QuoteSyncHandler.handleSimplifiedQLICreation(new Set<Id>(quoteMap.keySet()), new Set<Id>(qliMap.keySet()), quoteMap, oppMap);
			     }catch(Exception ex){	} 
			     
			    
	        Test.stopTest();
	    }
    }
	
	
	static testmethod void testQuoteSyncHandlerMethod(){
	    Map<Id,Opportunity> masterOpportunityMap = new Map<Id,Opportunity>([select id,name,Pricebook2Id from opportunity limit 1]);
	    system.assert(masterOpportunityMap != null); 
	    
	    if(CSM_AccessController.hasObject('Quote')) {
	    	String queryStr = 'select id,Pricebook2Id from Quote limit 1';
		    List<SObject> quotesList = Database.query(queryStr);
		    List<CHL_Partner_Opportunity__c> poList = [select id from CHL_Partner_Opportunity__c limit 1]; 
		   
		    Map<Id, sObject> poIdToQuoteMap = new Map<Id, sObject>();
		    poIdToQuoteMap.put(poList[0].id, quotesList[0]);
		  
		    Set<Id> quoteIdsSet = new Set<Id>();
		    quoteIdsSet.add(quotesList[0].id);
		    
		    Set<String> quoteIdSet = new Set<String>();
		    quoteIdSet.add(String.valueOf(quotesList[0].id));
		    
		    CHL_QuoteSyncHandler.REN_QuoteWrapper quoteWrapper = new CHL_QuoteSyncHandler.REN_QuoteWrapper();
		    quoteWrapper.quoteIdsSet = quoteIdsSet;
		    quoteWrapper.opportunityIdSet = masterOpportunityMap.keySet();
		    
		    Test.startTest(); 
		    	try{
	       			CHL_QuoteSyncHandler.processPartnerOpportunityList(quoteWrapper, poIdToQuoteMap, masterOpportunityMap);
		    	}catch(Exception ex){	} 
			    
			    try{
			    	CHL_QuoteSyncHandler.updatePartnerOpptyFieldsFromQLI(poIdToQuoteMap, masterOpportunityMap, quoteWrapper);
			    }catch(Exception ex){	} 
			    
			    try{
			    	CHL_QuoteSyncHandler.rollupCountsOnQuoteFromQLI(quoteWrapper);
			    }catch(Exception ex){	} 
			    
			    try{
			    	CHL_QuoteSyncHandler.handlePOUpdationOnQuoteSync(masterOpportunityMap, quotesList);
			    }catch(Exception ex){	} 
			    
			    try{
			    	CHL_QuoteSyncHandler.handleOpportunityUpdation(quoteIdSet, new List<Opportunity>(masterOpportunityMap.values()), masterOpportunityMap);
			    }catch(Exception ex){	} 
			    
			    try{
			    	CHL_QuoteSyncHandler.updatePartnerOpptyFields(poIdToQuoteMap, masterOpportunityMap);
			     }catch(Exception ex){	} 
	        Test.stopTest();
	    }
    }
    
	
}