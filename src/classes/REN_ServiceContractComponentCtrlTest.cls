@isTest
private class REN_ServiceContractComponentCtrlTest {
    static testMethod void ctrlTest() {
        REN_ServiceContractComponentController controller = new REN_ServiceContractComponentController();
        REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
        Account accnt = testDataSetup.createAccount(1)[0];
        Test.startTest();
	        controller.scAccountId = accnt.id;
	        CSM_DataGridAttribute gridData = new CSM_DataGridAttribute();
	        controller.contractGridAttribute = gridData;
	        system.assertNotEquals(controller.contractGridAttribute,null);
	        controller.scAccountId = '';
	        controller.contractGridAttribute = gridData;
	    Test.stopTest();
    }
}