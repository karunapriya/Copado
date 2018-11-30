@isTest
private class CSM_AddPlayControllerTest {
	static User adminUser;
	private static void init() {
		CSM_Constants.PLAY_RESULT_TRIGGER = false;
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;

		CSM_TestUtility.setup();
		List<CSM_Play_Criteria__c> createPlayCriteriaList = CSM_TestDataUtility.createPlayCriteriaData(String.valueOf(CSM_TestUtility.play.id));
		List<CSM_Play_Task__c> createPlayTask= CSM_TestDataUtility.createPlayTaskData(String.valueOf(CSM_TestUtility.play.id));
	}
	
    static testMethod void addPlayControllerTest() {
    	 CSM_TestUtility.addLicense();
    	 CSM_TestUtility.addCSMAdmin();
    	 init();
	     adminUser  = CSM_TestDataUtility.GetTestRunAsUser();
         System.RunAs(adminUser) { 
			test.StartTest();
			PageReference pageRef = Page.CSM_PlaybookManagement;
			pageRef.getParameters().put(CSM_Constants.RET_TO_URL,'/apex/csm_playbookmanagement');
			pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM,CSM_TestUtility.playbook.id);
			pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM,CSM_TestUtility.play.id);
			pageRef.getParameters().put(CSM_Constants.ADD_PARAM,'true');
			
			Test.setCurrentPage(pageRef);
			
			
			CSM_AddPlayController playController = new CSM_AddPlayController();
			playController.playbookId = CSM_TestUtility.playbook.id;
			System.assert(playController.playbookId == CSM_TestUtility.playbook.id);
	        test.stopTest();
         }
    }
}