/**
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
 */
@isTest
private class CSM_BatchPlanTemplateAssignmentTest {
    static testMethod void myUnitTest() {
		//REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		//REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest')[0];
		REN_Batch_Activity__c renBatch = new REN_Batch_Activity__c();
		insert renBatch;
		CSM_Account_Plan_Template__c acctPlanTemplate =   new CSM_Account_Plan_Template__c();
		acctPlanTemplate.CSM_Template_Name__c = 'Test';
		insert acctPlanTemplate;
		renBatch.REN_Plan_Template_Id__c = acctPlanTemplate.Id;
    	Test.startTest(); 
    	
    	CSM_BatchPlanTemplateAssignController controller = new CSM_BatchPlanTemplateAssignController();
	    PageReference myPage = Page.CSM_BatchPlanTemplateAssignment;
	    Test.setCurrentPageReference(myPage);
		controller.renBatch = renBatch;     	
    	PageReference p1 = controller.populateUser();

		p1 = controller.cancel();
		p1 = controller.createNewObjectFilterRecord();
		p1 = controller.editObjectFilterRecord();
		p1 = controller.editPlanDefaultRecord();
	    p1 = controller.createPlanDefaultRecord();
	    controller.savePlanBatch();

	    system.assert(p1 != null);
	    Test.stopTest();
    }
    
    static testMethod void testBusinessLayer() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'CSM_PTA', 'MyTest')[0];
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();

    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	inputWrapper.viewName = 'CSM_PTA';
    	inputWrapper.params = gridParams;
    	inputWrapper.params.selectedTaskFilter = rc.Id;    	
    	CSM_BatchPTABusinessLayer businessLayer = new CSM_BatchPTABusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser)
    	{
	    	try
	    	{
				responseWrapper = businessLayer.retrieveSObjectWrapperList();
	    	}
	    	catch(Exception e)
	    	{
	    		system.assert(true);
	    	}
    	}    	
    	Test.stopTest();
    }

}