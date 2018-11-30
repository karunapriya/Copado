/**
 * Created Date		: Oct 24, 2016
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: @description - This is test class for CHL_GlobalSearchBusinessLayer
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Tanvi					User Story				Oct 24, 2016			1.1					@description
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Comity Designs, Inc. 2016 - All Rights Reserved.
 */
@isTest
private class CHL_GlobalSearchTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		List<Account> accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		List<Opportunity> opptyList = new List<Opportunity>();
		//List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();

		Account acc =  CHL_TestUtility.partnerAccount();
		accountList.add(acc);
		insert accountList;
		
		System.assert(accountList != null);

		Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
		Contact con2 =  CHL_TestUtility.partnerContact(accountList[0].id);
		contactList.add(con);
		contactList.add(con2);
		insert contactList;

		Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
		opptyList.add(oppty);
		insert opptyList; 
		
		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
	   	partOppty.OpportunityId = opptyList[0].id;
	   	partOppty.partnerAcc1Id = accountList[0].id ;
	   	partOppty.partnerAcc1Type = 'Reseller';
	   	partOppty.contact1Id = contactList[0].Id;
	   	partOppty.expirationDate= system.today().addDays(-10);
	   	partOppty.Stage= 'Needs Analysis';
	   	system.assert(partOppty != null);
	     
	   	List<CHL_Partner_Opportunity__c> chlpartnerList =   CHL_TestUtility.channelPartnerOpportunityList(2,partOppty); 
	   	insert chlpartnerList;
	   	
	   	Asset assObj = new Asset();
        assObj.name = 'Partner Asset';
        assObj.AccountId = accountList[0].Id;
        insert assObj;        
        system.assert(assObj!=null);        
        
        REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
		renRelationObj.Name = 'Partner Renewal';
		renRelationObj.REN_Asset__c = assObj.Id;
		renRelationObj.REN_Renews_To__c = opptyList[0].Id;
		insert renRelationObj;
	   	
	   	opptyList = [select Id, name,Pricebook2Id from Opportunity limit 1];
		if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
	       	//To create Quote Obj.
	   		Sobject quoteObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject() ; 
	    	quoteObj.put('Name', 'Test Partner Q1') ; 
	    	quoteObj.put(CHL_Constants.STR_OPPOTUNITYID, opptyList[0].id) ;
	    	quoteObj.put(REN_Constants.OBJ_OPP_PRICEBOOK_ID, opptyList[0].Pricebook2Id) ;
	    	if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)) {
	        	quoteObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_PARTNER_OPPORTUNITY, chlpartnerList[0].id) ;
	   		}
	    	if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY)) {
	    		quoteObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTE_PARTNER_PRIMARY, true) ;
	    	}
	    	insert quoteObj;
 		}
 		
 		CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
		optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
		optyStatusLogObj.CHL_Days_between_Update__c = 5;
		optyStatusLogObj.CHL_Available_Sales_Stages__c = 'Needs Analysis;Closed Won';
		optyStatusLogObj.CHL_Enable_2_Tier_Pricing__c = true;
		insert optyStatusLogObj; 
		
		Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;

		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
		insert price1;
		if (CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)) { 	
    		SObject newServiceContract = CSM_AccessController.newSObject('ServiceContract');//new ServiceContract();
    		newServiceContract.put('AccountId',accountList[0].Id);
			newServiceContract.put('Pricebook2Id', Test.getStandardPricebookId());
			newServiceContract.put('Name', 'Partner SC');
			insert newServiceContract;	
			
			SObject newCLI = CSM_AccessController.newSObject('ContractLineItem');
			newCLI.put('ServiceContractId',newServiceContract.Id);
			newCLI.put('Quantity',1);
			newCLI.put('PricebookEntryId',price1.Id);
			newCLI.put('Description','Partner CLI');
			newCLI.put('UnitPrice',200);
			insert newCLI;
		}
		
	}
	
    static testMethod void typedownSearchTest() {
        List<Account> acclist = [select Id, name from Account limit 1];
        List<Contact> conlist = [select Id, name from Contact limit 1];
        List<Opportunity> opplist = [select Id, name from Opportunity limit 1];
        List<CHL_Partner_Opportunity__c> poList = [select Id, name from CHL_Partner_Opportunity__c limit 1];
        //system.debug('poList : '+poList);
        
        List<CHL_Opportunity_Status_Log__c> osl = [select Id, CHL_Enable_2_Tier_Pricing__c from CHL_Opportunity_Status_Log__c limit 1];
                
        Case csObj = new Case();
        csObj.subject = 'Partner Case';
        csobj.priority = 'Medium';
        csobj.AccountId = acclist[0].Id;
        insert csObj;
        System.assert(acclist != null);
        System.assert(conlist != null);
        System.assert(opplist != null);
		List<Asset> assetList = [select Id,name from Asset limit 1];
        
        List<REN_Renews_To__c> rliList = [select Id,name from REN_Renews_To__c limit 1];
        
        CHL_Partner_Renewal_Relationship__c prr = new CHL_Partner_Renewal_Relationship__c();
        prr.CHL_Partner_Opportunity__c = poList[0].Id;
        prr.CHL_Renewal_Relationship__c = rliList[0].Id;
        insert prr;
        
        Id [] fixedSearchResults= new Id[9];
       	fixedSearchResults[0] = acclist[0].Id;
       	fixedSearchResults[1] = conlist[0].Id;
       	fixedSearchResults[2] = poList[0].Id;
       	fixedSearchResults[3] = csObj.Id;
       	fixedSearchResults[4] = assetList[0].Id;
       	fixedSearchResults[5] = rliList[0].Id;
       	if (CSM_AccessController.hasObject('ContractLineItem')) { 
        	String cliQuery = 'Select Id, LineItemNumber from ContractLineItem limit 1';        
        	List<Sobject> cliList = Database.query(cliQuery);
       		fixedSearchResults[6] = cliList[0].Id;
        }
        if (CSM_AccessController.hasObject('Quote')) {  
	        String quoteQuery = 'Select Id, name from Quote limit 1';        
	        List<Sobject> quoteList = Database.query(quoteQuery); 	        
       		fixedSearchResults[7] = quoteList[0].Id;
        }
       	Test.setFixedSearchResults(fixedSearchResults);
		
		String inputValue = '{"q":"Part"}';
        CHL_GlobalSearchBusinessLayer.ConstructGlobalSearch(inputValue);
        
    }
    
    static testMethod void accountSearchTest() {
    	List<Account> acclist = [select Id, name from Account limit 1];
    	CHL_GridInputWrapper inputWrp = new CHL_GridInputWrapper();
    	inputWrp.q = 'part';
    	System.assert(acclist != null);
        Id [] fixedSearchResults= new Id[1];
       	fixedSearchResults[0] = acclist[0].Id;
        CHL_AccountBusinessLayer accBL= new CHL_AccountBusinessLayer(inputWrp);
        accBL.constructGridWrapper();
    }
    
    static testMethod void contactSearchTest() {
    	List<Contact> conlist = [select Id, name from Contact limit 1];
    	CHL_GridInputWrapper inputWrp = new CHL_GridInputWrapper();
    	inputWrp.q = 'part';
    	System.assert(conlist != null);
        Id [] fixedSearchResults= new Id[1];
       	fixedSearchResults[0] = conlist[0].Id;
        CHL_ContactBusinessLayer accBL= new CHL_ContactBusinessLayer(inputWrp);
        accBL.constructGridWrapper();
    }
    
    static testMethod void poSearchTest() {
        List<CHL_Partner_Opportunity__c> poList = [select Id, name from CHL_Partner_Opportunity__c limit 1];
    	CHL_GridInputWrapper inputWrp = new CHL_GridInputWrapper();
		CHL_GridInputWrapper.CHL_CustomGridParams gridParams = new CHL_GridInputWrapper.CHL_CustomGridParams();
    	gridParams.q = 'part';
		inputWrp.queryParams = gridParams;
    	System.assert(poList != null);
        Id [] fixedSearchResults= new Id[1];
       	fixedSearchResults[0] = poList[0].Id;
        CHL_PartnerOpportunityBusinessLayer poBL = new CHL_PartnerOpportunityBusinessLayer(inputWrp);
        poBL.constructGridWrapper();
    }
    
    static testMethod void assetSearchTest() {
    	List<Asset> assetList = [select Id,name from Asset limit 1];        
        system.assert(assetList!=null);
        Id [] fixedSearchResults= new Id[1];
       	fixedSearchResults[0] = assetList[0].Id;
       	CHL_GridInputWrapper inputWrp = new CHL_GridInputWrapper();
    	inputWrp.q = 'part';
        CHL_AssetBusinessLayer poBL = new CHL_AssetBusinessLayer(inputWrp);
        poBL.constructAssetGrid();
    }
    
    static testMethod void requestSearchTest() {
    	List<Account> acclist = [select Id, name from Account limit 1];
        Case csObj = new Case();
        csObj.subject = 'Partner Case';
        csobj.priority = 'Medium';
        csobj.AccountId = acclist[0].Id;
        insert csObj;
        
        system.assert(csObj!=null);
        Id [] fixedSearchResults= new Id[1];
       	fixedSearchResults[0] = csObj.Id;
       	CHL_GridInputWrapper inputWrp = new CHL_GridInputWrapper();
    	inputWrp.q = 'part';
        CHL_SalesRequestBusinessLayer poBL = new CHL_SalesRequestBusinessLayer(inputWrp);
        poBL.constructGridWrapper();
    }
    
    static testMethod void rrSearchTest() {
    	List<REN_Renews_To__c> rliList = [select Id,name from REN_Renews_To__c limit 1];        
        system.assert(rliList!=null);
        Id [] fixedSearchResults= new Id[1];
       	fixedSearchResults[0] = rliList[0].Id;
       	CHL_GridInputWrapper inputWrp = new CHL_GridInputWrapper();
    	inputWrp.q = 'part';
        CHL_RenRelationshipBusinessLayer poBL = new CHL_RenRelationshipBusinessLayer(inputWrp);
        poBL.constructGridWrapper();
    }
    
    static testMethod void quoteSearchTest() {
    	List<CHL_Opportunity_Status_Log__c> osl = [select Id, CHL_Enable_2_Tier_Pricing__c from CHL_Opportunity_Status_Log__c limit 1];
        String quoteQuery = 'Select Id, name from Quote limit 1';  
        system.assert(osl!=null);
        if (CSM_AccessController.hasObject('Quote')) {      
	        List<Sobject> quoteList = Database.query(quoteQuery); 
	        Id [] fixedSearchResults= new Id[1];
	       	fixedSearchResults[0] = quoteList[0].Id;
        }
       	CHL_GridInputWrapper inputWrp = new CHL_GridInputWrapper();
    	inputWrp.q = 'part';
        CHL_QuoteBusinessLayer poBL = new CHL_QuoteBusinessLayer(inputWrp);
        poBL.constructGridWrapper();
    }
    
    static testMethod void cliSearchTest() {
    	String cliQuery = 'Select Id, LineItemNumber,description from ContractLineItem limit 1';  
    	System.assert(true);
        if (CSM_AccessController.hasObject('ContractLineItem')) {      
	        List<Sobject> cliList = Database.query(cliQuery); 
	        Id [] fixedSearchResults= new Id[1];
	       	fixedSearchResults[0] = cliList[0].Id;
        }
       	CHL_GridInputWrapper inputWrp = new CHL_GridInputWrapper();
    	inputWrp.q = 'part';
    	system.assert(inputWrp!=null);
        CHL_ContractLineItemBusinessLayer poBL = new CHL_ContractLineItemBusinessLayer(inputWrp);
        poBL.constructGridWrapper();
    }
    
    static testMethod void predicateTest() {
    	List<Account> acclist = [select Id, name from Account limit 1];
    	List<Contact> conlist = [select Id, name from Contact limit 1];
    	string inputValue = '{"q":"","ot":"YEAR"}';
    	CHL_CommunityLandingController.globalSearch(inputValue);
    	inputValue = '{"q":"","ot":"QUARTER"}';
    	CHL_CommunityLandingController.globalSearch(inputValue);
    	inputValue = '{"q":"","ot":"SALES_STAGE"}';
    	CHL_CommunityLandingController.globalSearch(inputValue);
    	inputValue = '{"q":"part","ot":"'+ CSM_Util.getNamespace() +'CHL_Partner_Account_2__c"}';
    	CHL_CommunityLandingController.globalSearch(inputValue);
    	inputValue = '{"q":"part","ot":"'+ CSM_Util.getNamespace() +'CHL_Partner_Account_1__c"}';
    	CHL_CommunityLandingController.globalSearch(inputValue);
    	inputValue = '{"q":"part","ot":"'+ CSM_Util.getNamespace() +'CHL_Partner_Account_1_Contact__c"}';
    	CHL_CommunityLandingController.globalSearch(inputValue);
    	system.assert(inputValue!=null);
    }
}