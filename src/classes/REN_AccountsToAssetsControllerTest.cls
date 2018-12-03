@isTest
private class REN_AccountsToAssetsControllerTest {
	static testMethod void ctrlTest() {
        REN_AccountsToAssetsController controller = new REN_AccountsToAssetsController();
        REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
        Account accnt = testDataSetup.createAccount(1)[0];
        Test.startTest();
	        controller.accountId = accnt.id;
	        CSM_DataGridAttribute gridData = new CSM_DataGridAttribute();
	        controller.assetGridAttribute = gridData;
	        system.assertNotEquals(controller.assetGridAttribute,null);
	        controller.accountId = '';
	        controller.assetGridAttribute = gridData;
	    Test.stopTest();
    }
}