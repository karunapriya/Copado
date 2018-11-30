@isTest
private class CSM_PlaybookPlayTriggerHandlerTest {
	@testSetup 
    static void setUp() {
       	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
       	system.assertNotEquals(accountList,null);
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
        system.assertNotEquals(playbookList,null);
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        system.assertNotEquals(playList,null);
        CSM_PlaybookPlay__c playbookPlay =  CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].id, playList[0].id);
        List<CSM_Account_Plan_Template__c> accountPlanTemplate = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlan = CSM_TestDataUtility.createAccountPlan(accountList, accountPlanTemplate[0].id);
        List<String> playbookStringList = new List<String>();
        for(CSM_Playbook__c playbook : playbookList) {
        	playbookStringList.add((String)playbook.id);
        }
        List<String> playStringList = new List<String>();
        for(CSM_Play__c play : playList) {
        	playStringList.add((String)play.id);
        }
        List<CSM_Account_Plan_Playbook__c> succPlanPlaybook = CSM_TestDataUtility.createAccountPlanPlaybookData((String)accountPlan[0].id, (String)accountPlanTemplate[0].id, playbookStringList);
		List<CSM_SuccessPlan_Play__c> succPlanPlay = CSM_TestDataUtility.createAccountPlanPlayData(playStringList, (String)playbookPlay.id, (String)succPlanPlaybook[0].id);    
    
    	User userRecord = CSM_TestDataUtility.createTestUser('Standard User');
    }
    static testMethod void playbookPlayTrigger_AfterInsertPositive() {
    	Test.startTest();
	    	CSM_Constants.PLAYBOOK_PLAY_TRIGGER = true;
	        List<CSM_Account_Plan_Playbook__c> succPlanPlaybookList = [select id from CSM_Account_Plan_Playbook__c];
	        List<CSM_SuccessPlan_Play__c> succPlanPlayList = [select id from CSM_SuccessPlan_Play__c];
	        List<CSM_Playbook__c> playbookList = [select id from csm_playbook__c];
	        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
	        CSM_PlaybookPlay__c playbookPlay =  CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].id, playList[0].id);
	        system.assert(playbookPlay!=null);
	        List<CSM_SuccessPlan_Play__c> succPlanPlay = [select id from CSM_SuccessPlan_Play__c];
	        system.assertNotEquals(succPlanPlay.size(),0);
	   	Test.stopTest();
    }
    /*static testMethod void playbookPlayTrigger_AfterInsertNegative() {
    	List<User> userList = [select id from user];
    	List<CSM_Account_Plan_Playbook__c> succPlanPlaybookList = [select id from CSM_Account_Plan_Playbook__c];
        List<CSM_SuccessPlan_Play__c> succPlanPlayList = [select id from CSM_SuccessPlan_Play__c];
        List<CSM_Playbook__c> playbookList = [select id from csm_playbook__c];
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        CSM_PlaybookPlay__c playbookPlay = new CSM_PlaybookPlay__c();
    	Test.startTest();
    		system.runAs(userList[0]) {
		    	CSM_Constants.PLAYBOOK_PLAY_TRIGGER = true;
		        playbookPlay =  [select id from CSM_PlaybookPlay__c];
    		}
	   	Test.stopTest();
    }*/
    static testMethod void playbookPlayTrigger_BeforeDeletePositive() {
    	Test.startTest();
	    	CSM_Constants.PLAYBOOK_PLAY_TRIGGER = true;
	        List<CSM_PlaybookPlay__c> playbookPlayList =  [select id from CSM_PlaybookPlay__c];
	        delete playbookPlayList;
	        playbookPlayList = [select id from CSM_PlaybookPlay__c];
	        system.assertEquals(playbookPlayList.size(),0);
	   	Test.stopTest();
    }
    /*static testMethod void playbookPlayTrigger_BeforeDeleteNegative() {
    	List<User> userList = [select id from user];
    	List<CSM_PlaybookPlay__c> playbookPlayList =  [select id from CSM_PlaybookPlay__c];
    	Test.startTest();
    		system.runAs(userList[0]) {
		    	CSM_Constants.PLAYBOOK_PLAY_TRIGGER = true;
		        delete playbookPlayList;
    		}
    		system.assertNotEquals(playbookPlayList.size(),0);
	   	Test.stopTest();
    }*/
}