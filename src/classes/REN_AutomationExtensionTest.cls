/**
 * Created Date		: Oct 4, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					User Story				Oct 4, 2018			1.1					@description
 *
 
 * Comity Designs, Inc. 2018 - All Rights Reserved.
 */
@isTest
private class REN_AutomationExtensionTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		List < Account > accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList.get(0).Id != null);
        
        Product2 prod1 = REN_TestDataUtility.createProduct(1);
        insert prod1;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 standardPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert standardPB;
        
        Opportunity testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=Test.getStandardPricebookId(),
                                                CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, REN_Earliest_Expiration_Date__c = System.Today() + 2);
        
        insert testOppty;
        system.assert(testOppty != null);
        
        if(CSM_AccessController.hasObject('Quote')) {
        	
            List<SObject> quotesList = CHL_TestUtility.createQuotes(1,new List<Opportunity>{testOppty},null);
	        quotesList[0].put(REN_Constants.OBJ_OPP_PRICEBOOK_ID,Test.getStandardPricebookId());
	        insert quotesList;
	        system.assert(quotesList != null);
	        
            List<SObject> quoteLineItemsList = CHL_TestUtility.createMultipleQuoteLineItems(100,quotesList,new List<Product2>{prod1},new List<PricebookEntry>{standardPrice});
	        insert quoteLineItemsList;        
        } 
        REN_RSTestDataUtility.RSConfigWrapper rsConfig = new REN_RSTestDataUtility.RSConfigWrapper();
		rsConfig.flowName = 'Approve';
		rsConfig.invokingObj = 'Quote';
		rsConfig.namedCredential = 'RS_ODATA';
		rsConfig.namedCredentialUrlExt = '/odata/frb1/dell/quote/dell.Approve';
       	rsConfig.displayDialog = false;
        rsConfig.displayResposeDialog = false;

      
		REN_RS_Config__c rsConfigObj = REN_RSTestDataUtility.createRSConfig(rsConfig);
		insert rsConfigObj;
	}
	
    static testMethod void testApprove() {
    	system.debug(system.Label.REN_LBL_APPROVE);
    	system.debug(system.Label.REN_LBL_REJECT);
        String quoteString = 'Select Id, OpportunityId from Quote';
	    List<SObject> quoteList = Database.query(quoteString);
	    system.assert(quoteList != null);
        REN_AutomationExtension.QuoteParameter objQuoteParam = new REN_AutomationExtension.QuoteParameter();
        objQuoteParam.flowName = system.Label.REN_LBL_APPROVE;
        objQuoteParam.QuoteId = quoteList[0].id;
        REN_AutomationExtension.invoke(new List<REN_AutomationExtension.QuoteParameter>{objQuoteParam});       
    }
    static testMethod void testReject() {
        String quoteString = 'Select Id, OpportunityId from Quote';
	    List<SObject> quoteList = Database.query(quoteString);
	    system.assert(quoteList != null);
        REN_AutomationExtension.QuoteParameter objQuoteParam = new REN_AutomationExtension.QuoteParameter();
        objQuoteParam.flowName = system.Label.REN_LBL_REJECT;
        objQuoteParam.QuoteId = quoteList[0].id;
        REN_AutomationExtension.invoke(new List<REN_AutomationExtension.QuoteParameter>{objQuoteParam});       
    }
}