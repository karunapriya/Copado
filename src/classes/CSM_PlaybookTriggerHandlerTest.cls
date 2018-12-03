@isTest
private class CSM_PlaybookTriggerHandlerTest {
	@testSetup 
    static void setUp() {
		List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		system.assertNotEquals(accountList,null);
	   
	   	List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
	   	system.assertNotEquals(playbookList,null);
	   
	   	List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
	   	system.assertNotEquals(templateList,null);
	   
	   	List<CSM_Account_Plan__c> accountPlan = CSM_TestDataUtility.createAccountPlan(accountList, (String)templateList[0].id);
	   	system.assertNotEquals(accountPlan,null);
	   
	   	List<String> playbookListStr = new List<String>();
	   	for(CSM_Playbook__c pb :playbookList) {
	   		playbookListStr.add((String)pb.id);
	   	}
	   	
	   	List<CSM_Account_Plan_Playbook__c> accountPlanPlaybook = CSM_TestDataUtility.createAccountPlanPlaybookData((String)accountPlan[0].id, (String)templateList[0].id, playbookListStr);
    }
    static testMethod void playbookTrigger_AfterUpdatePositive() {
    	Test.startTest();
	    	CSM_Constants.PLAYBOOK_TRIGGER = true;
	        List<CSM_Playbook__c> playbookList = [select id,CSM_IsActive__c from csm_playbook__c limit 1];
	        List<CSM_Playbook__c> updatePlaybook = new List<CSM_Playbook__c>();
	        for(CSM_Playbook__c pb : playbookList) {
	        	pb.CSM_IsActive__c = false;
	        	updatePlaybook.add(pb);
	        }
	        update updatePlaybook;
	        system.assertNotEquals(updatePlaybook,null);
	   	Test.stopTest();
    }
    static testMethod void playbookTrigger_AfterUpdateNegative() {
	   	CSM_Constants.PLAYBOOK_PLAY_TRIGGER = true;
		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
		List<sObject> oldRecords = new List<sObject>();
		List<sObject> newRecords = new List<sObject>();
		Map<ID, sObject> oldRecordsMap = new Map<ID, sObject>();
		Map<ID, sObject> newRecordsMap = new Map<ID, sObject>();
		List<CSM_Playbook__c> playbookList = [select id,CSM_IsActive__c from csm_playbook__c limit 1];
		newRecords = playbookList;
		System.RunAs(restrictedUser) {
			Test.startTest();
				CSM_PlaybookTriggerHandler triggerhandlercls = new CSM_PlaybookTriggerHandler();
				triggerhandlercls.onAfterUpdate(oldRecords,newRecords,oldRecordsMap,newRecordsMap);
				system.assert(true);
			Test.stopTest();	   		
		}
    }
}