/**
 * Created Date		: Feb 7, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Covers class CHL_QuoteOnPOBusinessLayer
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2049					Feb 7, 2017		1.1					Added in Sprint 705
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
private class CHL_QuoteOnPOBusinessLayerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		List<Account> accList = CSM_TestDataUtility.createAccount(1);
		system.assert(accList!=null);
		List<Opportunity> opptyList = CSM_TestDataUtility.createOpportunity(1, (String)accList[0].id);
		system.assert(opptyList!=null);
		CHL_Partner_Opportunity__c ptnrOppty = CHL_TestUtility.createPartnerOpportunity(opptyList[0].id);
		system.assert(ptnrOppty!=null);
		if(ptnrOppty != null) {
			insert ptnrOppty;
		}
	}
	
    static testMethod void myUnitTest() {
    	testSetupMethod();
    	List<Opportunity> opptyList = [select id,Pricebook2Id from Opportunity Limit 1];
    	List<CHL_Partner_Opportunity__c> partnerOpptyList = [select id from CHL_Partner_Opportunity__c Limit 1];
    	system.assert(partnerOpptyList!=null);
    	List<SObject> quotesList = CHL_TestUtility.createQuotes(1,opptyList,partnerOpptyList);
    	if(quotesList != null && !quotesList.isEmpty()) {
			insert quotesList;
        }
    	Test.startTest();
    		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
	    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
	    	gridParams.opptyId = (String)partnerOpptyList[0].id;
	    	inputWrapper.params = gridParams;
	    	CSM_BusinessLayer businessLayer = new CHL_QuoteOnPOBusinessLayer(inputWrapper);
	    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
	    	system.assert(true);
    	Test.stopTest();
    }
}