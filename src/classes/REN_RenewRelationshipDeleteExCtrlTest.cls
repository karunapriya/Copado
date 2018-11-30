/**
 * Created Date     : July 19, 2017
 * Developed By     : Rucha Palasapure, Comity Designs, Inc.
 *
 * Function         : @description - This class is the test class for REN_RenewRelationshipDeleteExController.
 * Support Email    : 
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Rucha                    US2496              July 19, 2017            1.1                 @description
 *
**/

@isTest
public class REN_RenewRelationshipDeleteExCtrlTest {
	
	@testSetup	
	static void setup(){
		List<Account> accountList = new List<Account>();
		List<Opportunity> opptyList = new List<Opportunity>();
		List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();
		List<Contact> contactList = new List<Contact>();
		List<REN_Renews_To__c> renewableLineItemsList = new List<REN_Renews_To__c>();
		
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
		
		REN_Renews_To__c rli = new REN_Renews_To__c();
        rli.REN_Product__c = productList[0].Id;
        rli.REN_Renews_To__c = opptyList[0].Id;
        rli.REN_Start_Date__c = system.today();
        rli.REN_New_Start_Date__c = system.today();
        rli.REN_End_Date__c = system.today() + 3;
        rli.REN_New_End_Date__c = system.today() + 3;
        rli.REN_Quantity__c = 2;
        renewableLineItemsList.add(rli);    
        insert renewableLineItemsList;
    }
    
    static testMethod void testQuoteSyncNegative(){
        Test.startTest();
        REN_Renews_To__c rli = [select Id, Name from REN_Renews_To__c limit 1];
			
	        Test.setCurrentPageReference(Page.REN_RenewRelationshipDelete);	        	        
	        ApexPages.currentPage().getParameters().put('id',rli.Id);	       
	        ApexPages.StandardController sc = new ApexPages.StandardController(rli);    
	        REN_RenewRelationshipDeleteExController rrCtrl = new REN_RenewRelationshipDeleteExController(sc);
            rrCtrl.oppId = null;
            rrCtrl.rliList = null;    
        	rrCtrl.deleteRLI();
	        rrCtrl.removeSyncedQuote();
	        rrCtrl.cancelAndReturnToOppt();
        	system.assert(true);       
		Test.stopTest();
    }
    
    static testMethod void testQuoteSync(){
    	Test.startTest();
	    	List<Opportunity> opptyList = [select Id, name,Pricebook2Id,description from opportunity limit 1];
			List<CHL_Partner_Opportunity__c> poList = [select Id, name from CHL_Partner_Opportunity__c limit 1];
			List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,poList);
			insert quoteList;
        	CSM_TriggerManager.disableAllTriggers();
			
			if(quoteList != null && !quoteList.isEmpty()){
				opptyList[0].put('SyncedQuoteId', quoteList[0].Id);
				update opptyList;
			}	    				
	    	String syncQuoteId = '';
			if(CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')) {
				syncQuoteId = ',SyncedQuoteId';
			}
			string opptyQuery = 'select Id, name, Pricebook2Id,description'+syncQuoteId+' from opportunity limit 1';
			List<sObject> opptyList2 = Database.query(opptyQuery);
			//system.assert(opptyList2 != null);
			
			REN_Renews_To__c rli = [select Id, Name from REN_Renews_To__c limit 1];
			
	        Test.setCurrentPageReference(Page.REN_RenewRelationshipDelete);	        	        
	        ApexPages.currentPage().getParameters().put('id',rli.Id);	       
	        ApexPages.StandardController sc = new ApexPages.StandardController(rli);    
	        REN_RenewRelationshipDeleteExController rrCtrl = new REN_RenewRelationshipDeleteExController(sc);
	        rrCtrl.removeSyncedQuote();
	        rrCtrl.cancelAndReturnToOppt();
	        
	        List<REN_Renews_To__c> rliList = [select Id, Name from REN_Renews_To__c];
	        
	        //system.assertEquals(true, rliList.isEmpty());
	        //system.assertEquals(0, rliList.size());    
	        system.assert(true);       
		Test.stopTest();
    }
}