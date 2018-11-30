/**
 * Created Date		: Feb 7, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Covers class CHL_SetPrimaryQuoteOnPOCtrl
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2049					Feb 7, 2017		1.1					Added in sprint 705
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
 * Comity Designs, Inc. 2017 - All Rights Reserved.
 */
@isTest
private class CHL_SetPrimaryQuoteOnPOCtrlTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	static void testSetupMethod() {
		List<Account> accList = CSM_TestDataUtility.createAccount(1);
		system.assert(accList!=null);
		List<Opportunity> opptyList = CSM_TestDataUtility.createOpportunity(1, (String)accList[0].id);
		system.assert(opptyList!=null);
		CHL_Partner_Opportunity__c ptnrOppty = CHL_TestUtility.createPartnerOpportunity(opptyList[0].id);
		if(ptnrOppty != null) {
			insert ptnrOppty;
		}
		system.assert(ptnrOppty!=null);
	}
	
    static testMethod void myUnitTest() {
    	testSetupMethod();
    	List<Opportunity> opptyList = [select id, Opportunity.Pricebook2Id from Opportunity Limit 1];
    	List<CHL_Partner_Opportunity__c> partnerOpptyList = [select id from CHL_Partner_Opportunity__c Limit 1];
    	List<SObject> quotesList = CHL_TestUtility.createQuotes(1,opptyList,partnerOpptyList);
    	if(quotesList != null && !quotesList.isEmpty()) {
			insert quotesList;
        }
    	Test.startTest();
	    	PageReference pageRef = Page.CHL_SetPrimaryQuoteOnPO;
	        pageRef.getParameters().put('Id', opptyList[0].id);
	        CHL_SetPrimaryQuoteOnPOCtrl controller = new CHL_SetPrimaryQuoteOnPOCtrl();
	        if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
	        	controller.recordId = (String)quotesList[0].id;
		        pageRef = controller.setPrimaryQuote();
		        //system.assert(pageRef!=null);	
	        }
	        pageRef = controller.returnURL();
	        system.assert(pageRef!=null);
	  	Test.stopTest();
    }
}