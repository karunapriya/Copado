/**
 * Created Date		: Dec 7, 2016
 * Developed By		: Chandra, Comity Designs, Inc.
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
 * Chandra					User Story				Dec 7, 2016			1.1					@description
 * 
 */
 @isTest(SeeAllData=true)
private class REN_ConsolidateOpportunitiesBatchLogTest {
	@isTest
    static void testConsolidateOpportunitiesBatchLogCtrl() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		testDataSetup.createRenewConfigurations();
    	testDataSetup.renewDataSetup(1, 1, 2);	
    	testDataSetup.createConsolidationRequest(1,testDataSetup.opportunityList);
 
 		Test.startTest(); 
		
		PageReference myPage = Page.REN_ConsolidateOpportunitiesBatchLog;	   
	    Test.setCurrentPageReference(myPage);
	    REN_ConsolidateOpportunitiesBatchLogCtrl controller = new REN_ConsolidateOpportunitiesBatchLogCtrl();
	    String s = controller.helpParam;
	    CSM_DataGridAttribute p1 = controller.dataGridAttribute1;
	    system.assert(p1.tableName == 'ConsolidateOpportunityLog');
	    Test.stopTest();
    	
    }

    static testMethod void testConsolidateOpportunityBusinessLayer() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		testDataSetup.createRenewConfigurations();
    	testDataSetup.renewDataSetup(1, 1, 2);	
    	testDataSetup.createConsolidationRequest(1,testDataSetup.opportunityList);
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	//gridParams.accountId = testAccountId;
    	//gridParams.accountPlanId = testAcctPlan.Id;
    	inputWrapper.params = gridParams;
    	REN_ConsolidateOpportunityBusinessLayer businessLayer = new REN_ConsolidateOpportunityBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	Test.stopTest();
    }

}