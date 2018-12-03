@isTest
public with sharing class CSM_AddPlaybookControllerTest {
		static testMethod void testAddPlaybook() {
			CSM_TestUtility.setup();
			Test.startTest();	
    		Test.setCurrentPage(Page.CSM_AddPlaybook);
    		
    		CSM_AddPlaybookController controller = new CSM_AddPlaybookController();
    		System.assert(controller.hasCSMAccess==true);
    		
    		Test.stopTest();
		}

}