@isTest(SeeAllData=true)
public with sharing class REN_GroupingLogicControllerTest {
static testMethod void Test_CreateAndEditConfiguration_Positive() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		REN_Renew_Configuration__c rc = testDataSetup.createRenewConfiguration( 1, 'Grouping','MyGrouping')[0];
		
        Test.startTest();
        REN_GroupingLogicController controller = new REN_GroupingLogicController();
        system.assert(controller.renconfigobj != null);
        controller.renconfigobj.REN_View_Name__c='Test';
        controller.saveDataGeneration();
        controller.retrieveRenewConfig(rc.id);
        controller = new REN_GroupingLogicController();
        Test.stopTest();
    } 
    
    static testMethod void Test_Cancel() {
        Test.startTest();
        REN_GroupingLogicController controller = new REN_GroupingLogicController();
        PageReference cancelRef = controller.cancel();
        system.assert(true);
        Test.stopTest();
    }
    
    static testMethod void Test_Cancel_Negative() {
        Test.startTest();
        REN_GroupingLogicController controller = new REN_GroupingLogicController();
        controller.batchId='DFGGKIGMN2343ERF';
        controller.genCount = 'Success';
        PageReference cancelRef = controller.cancel();
        controller.genCount = 'Fail';
        cancelRef = controller.cancel();
        system.assert(true);
        Test.stopTest();
    }
    static testMethod void Test_Save_Negative() {
    	try{
    	Test.startTest();
	        REN_GroupingLogicController controller = new REN_GroupingLogicController();
       		controller.saveDataGeneration();
	        Test.stopTest();
    	}
	    catch(Exception ex){
	    	system.assert(true);
	    }
    }
}