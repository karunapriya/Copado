@isTest
private class CSM_PlaysListControllerTest {

	static testMethod void Test_PlaysListController(){
		Test.startTest();
		CSM_PlaysListController playsListController = new CSM_PlaysListController();
		system.assert(playsListController.retUrl.contains('csm_playslist'));
		system.assertEquals(playsListController.hasCSMAccess, false);
		Test.stopTest();
	}
}