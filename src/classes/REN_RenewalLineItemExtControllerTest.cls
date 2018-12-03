/**
 * Created Date		: May 23, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Test Coverage for REN_RenewalLineItemExtController
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					Test Coverage			May 23, 2017	1.1					Test Coverage
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
@isTest(SeeAllData = false) 
private class REN_RenewalLineItemExtControllerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	/*@testSetup 
	static void testSetupMethod() {
	}*/
    static testMethod void saveTest() {
    	List <Account> accountList = CSM_TestDataUtility.createAccount(1);
		system.assert(accountList != null);
		system.assert(!accountList.isEmpty());
		
		List <Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(1, accountList[0].id);
		system.assert(opportunityList != null);
		system.assert(!opportunityList.isEmpty());
		
		String standardPriceBookId = Test.getStandardPricebookId();
		
		Product2 p2 = new Product2(Name = 'Test Product', isActive = true,ProductCode ='IN7080');
		insert p2;
		system.assert(p2.Id != null);
		
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = p2.Id, UnitPrice = 99, isActive = true);
		insert pbe;
		system.assert(pbe.Id != null);
		
		REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
        renRelationObj.Name = 'Partner Renewal';
        renRelationObj.REN_Renews_To__c = opportunityList[0].Id;
        renRelationObj.REN_Renewal_Status__c = 'Won';
        renRelationObj.REN_Renewal_Target__c = 50000.0;
        renRelationObj.REN_Renewal_Target_Multiplier__c = 1;
        renRelationObj.REN_Previous_Price__c = 50000.0;
        insert renRelationObj;
        
    	Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(renRelationObj);
			REN_RenewalLineItemExtController testCreateRenewalOpportunity = new REN_RenewalLineItemExtController(sc);
			testCreateRenewalOpportunity.hasQuote = true;
			PageReference pageRef = Page.REN_CreateRenewalRelationship;
			pageRef.getParameters().put('id', String.valueOf(renRelationObj.Id));
	        Test.setCurrentPage(pageRef);
	        testCreateRenewalOpportunity.removeSyncQuoteAndSave();
	        testCreateRenewalOpportunity.validatePopup();
	    Test.stopTest();
    
    }
}