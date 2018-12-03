/**
 * Created Date		: Nov 28, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Test class for opportunity split wizard OLI
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1760					Nov 28, 2016	1.0					Initial development
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
private class REN_OpptSplitWizardOLIControllerTest {
	static void setup(){
		system.assert(true);
	}
	
	/* This test class is deprecated under US3293
	   If you need this test class code take previous version.
	
	@testSetup
	static void setup(){
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup();
		List<Product2> products = testDataSetup.createProduct(1);
        PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = test.getStandardPricebookId(), UnitPrice = 1.0, IsActive = true, Product2Id = products[0].Id);
		insert price1;
		List<PricebookEntry> pbEntries =new  List<PricebookEntry>();
        pbEntries.add(price1);
		List<Account> accts = testDataSetup.createAccount(1);
		List<Opportunity> oppts = testDataSetup.createOpportunity(1, accts);
		system.assert(oppts!=null);
		List<OpportunityLineItem> olis = testDataSetup.createOpportunityLineItem(1, oppts, pbEntries);
		system.assert(olis!=null);		
	}
	
	
    static testMethod void OpptSplitWizardRedirectTest() {
    	REN_OpptSplitWizardOLIController controller = new REN_OpptSplitWizardOLIController(null);
    	CSM_DataGridAttribute opptSplitOLIGridAttribute = controller.opptSplitOLIGridAttribute;   
        PageReference pageRef = controller.redirectToOpptSplitWizard();
        if(pageRef != null) {
        	system.assert(true);
        }
    }*/
    
    
	static testMethod void testBusinessLayer() {
		list<Opportunity> oppts=[select Id from Opportunity limit 1];		
		Test.startTest();
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	inputWrapper.viewName = 'OpptSplitOLI';
        if(oppts!=null && !oppts.isEmpty()){
            gridParams.opptyId=oppts[0].id;
        }
        inputWrapper.params = gridParams;
    	
    	REN_OpptSplitWizardOLIBusinessLayer businessLayer = new REN_OpptSplitWizardOLIBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	Test.stopTest();
    	
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
	}
    static testMethod void testBusinessLayerNeg() {	
		Test.startTest();
		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	inputWrapper.viewName = 'OpptSplitOLI';
    	inputWrapper.params = gridParams;
    	
    	REN_OpptSplitWizardOLIBusinessLayer businessLayer = new REN_OpptSplitWizardOLIBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	Test.stopTest();
    	
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
	} 
}