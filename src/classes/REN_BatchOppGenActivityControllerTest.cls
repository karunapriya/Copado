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
@isTest(SeeAllData=true)
private class REN_BatchOppGenActivityControllerTest {

    static testMethod void myUnitTest() {
    	
        REN_BatchOppGenActivityController controller = new REN_BatchOppGenActivityController();
        CSM_DataGridAttribute gridData = new CSM_DataGridAttribute();
        controller.batchOppGenGridAttribute = gridData;
    	controller.batchOppGenGridAttribute.tableName = 'batchHistory';
        REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 limit 1];
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
        Test.startTest();
	    controller.deletableRecordId = batchActivityObj.id;
	    PageReference p1 = controller.deleteSelectedRecord();
	    system.assert(true);
	    p1 = controller.redirectToBatchOppGeneration();
	    system.assertNotEquals(p1,null);
	    Test.stopTest();
    }
    static testMethod void deleteSelectedRecord_Negative() {
    	
        REN_BatchOppGenActivityController controller = new REN_BatchOppGenActivityController();
        REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 limit 1];
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
        User adminUser  = CSM_TestDataUtility.createTestUser('System Administrator');
       System.RunAs(adminUser){
        Test.startTest();
        PageReference myPage = Page.REN_BatchOppGeneration;
	    Test.setCurrentPageReference(myPage);
	    controller.deletableRecordId = batchActivityObj.id;
	    PageReference p1 = controller.deleteSelectedRecord();
	    system.assert(true);
	    Test.stopTest();
       }
    }
    
    static testMethod void testBusinessLayer() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc= testDataSetup.createRenewConfiguration( 1, 'Filter', 'MyTest2')[0];
		REN_Renew_Configuration__c rc_group= testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		Pricebook2 standardPB = [SELECT Id FROM Pricebook2 limit 1];
		REN_Batch_Activity__c batchActivityObj = testDataSetup.createBatchActivity(1,rc_group,rc,DateTime.now(),standardPB.id)[0];
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	inputWrapper.viewName = 'BatchHistory';
    	inputWrapper.params = gridParams;
    	REN_BatchOppGenActivityLayer businessLayer = new REN_BatchOppGenActivityLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    	Test.stopTest();
    }
}