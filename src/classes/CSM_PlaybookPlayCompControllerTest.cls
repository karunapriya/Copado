@isTest
private class CSM_PlaybookPlayCompControllerTest {

	@testSetup 
    static void setUp() {
		insert new SS_License__c(CSM__c = true);
		/*CSM_TriggerEnablement__c cTriggerEnablement  = CSM_TriggerEnablement__c.getOrgDefaults();
		cTriggerEnablement.CSM_AccountPlanTrigger__c = true;
		cTriggerEnablement.CSM_AccountPlan_PlaybookTrigger__c = true;
		cTriggerEnablement.CSM_PlaybookPlayTrigger__c = true;
		cTriggerEnablement.CSM_AccountTrigger__c = true;
		cTriggerEnablement.CSM_TaskTrigger__c = true;
		cTriggerEnablement.CSM_SuccessPlanPlayTrigger__c = true;		
		upsert cTriggerEnablement;*/

       	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        
        List<CSM_Play_Task__c> playTaskList = new List<CSM_Play_Task__c>();//CSM_TestDataUtility.createPlayTaskData(playList[0].id);
        CSM_Play_Task__c newTask1 = new CSM_Play_Task__c();
        newTask1.CSM_Assign_To__c = CSM_Constants.ASSIGN_ACCOUNT_MANAGER;
        newTask1.Name = 'Task 1';
        newTask1.CSM_Days_Until_Due__c = 30;
        newTask1.CSM_IsActive__c = true;
        newTask1.CSM_Play__c = playList[0].Id;
        newTask1.CSM_Description__c = 'The description';
        playTaskList.add(newTask1);
        
        insert playTaskList;
        
        CSM_PlaybookPlay__c playbookPlay =  CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].id, playList[0].id);
        List<CSM_Account_Plan_Template__c> accountPlanTemplate = CSM_TestDataUtility.createAccountPlanTemplateData(1);

		csm_constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;        
        List<CSM_Account_Plan__c> accountPlan = CSM_TestDataUtility.createAccountPlan(accountList, accountPlanTemplate[0].id);
		CSM_TestDataUtility.createAccountPlanPlaybookData((String)accountPlan[0].Id, null, new List<String> {playbookList[0].Id});        
		system.assert(accountPlan.size() > 0);        
    }

	static testMethod void testPlaybookPlayComp_Negative() {
		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	List<Account> accountList = [select id from account limit 1];
    	List<CSM_Account_Plan__c> accountPlan = [select id from CSM_Account_Plan__c limit 1];
    	List<CSM_Playbook__c> playbookList = [select id from CSM_Playbook__c limit 1];
        Test.startTest();
        
        CSM_PlaybookPlayCompController controller = new CSM_PlaybookPlayCompController();
        controller.accountId = accountList[0].id;
        controller.acctPlanId = accountPlan[0].id;
       //** controller.playbookId = playbookList[0].id;
        system.runAs(restrictedUser) {
	        controller.addPlayBook();
	        controller.removePlaybookAssociation();
        }
		Test.stopTest();
		system.assert(playbookList.size() > 0);
	}



    static testMethod void testPlaybookPlayComp_Positive() {
    	List<Account> accountList = [select id from account limit 1];
    	List<CSM_Account_Plan__c> accountPlan = [select id from CSM_Account_Plan__c limit 1];
    	List<CSM_Playbook__c> playbookList = [select id from CSM_Playbook__c limit 1];
		List<CSM_Account_Plan_Template__c> accountPlanTemplate =  [select id from CSM_Account_Plan_Template__c limit 1];
		List<CSM_Play__c> playList = [select id from CSM_Play__c limit 1]; 		  	
    	playList[0].CSM_Play_ReEntry__c = true;
    	update playList;
    	
    	List<csm_account_plan_playbook__c> sppb1 = [select Id from csm_account_plan_playbook__c];
    	system.debug('sppblist - ' + sppb1);
    	
    	List<csm_account_plan_playbook__c> sppb = [select Id from csm_account_plan_playbook__c where csm_account_plan__c =:accountPlan[0].Id and csm_playbook__c =:playbookList[0].Id];
    	
    	List<csm_successplan_play__c> sppl = [select Id from csm_successplan_play__c where csm_successplan_playbook__c =:sppb[0].Id and csm_play__c =:playList[0].Id];
    	 
        Test.startTest();
        
        
        CSM_Constants.TASK_TRIGGER = true;
        Task tsk = new Task();
        tsk.subject = 'test task';
        tsk.csm_successplan_play__c = sppl[0].Id;
        tsk.whatId = accountList[0].Id;
        tsk.ActivityDate = system.today();
        insert tsk;
        
        CSM_Constants.TASK_TRIGGER = true;        
        tsk.status = 'Completed';
        update tsk;
        
        CSM_PlaybookPlayCompController controller = new CSM_PlaybookPlayCompController();
        controller.accountId = accountList[0].id;
        controller.acctPlanId = accountPlan[0].id;
        controller.plybookId = playbookList[0].Id;

		controller.validateRefresh();
		controller.refreshPlaybook();        

        controller.addPlayBook();
        controller.removePlaybookAssociation();
        controller.addPlayBookSkipCriteria();
        system.assertNotEquals(controller.playbookGridAttribute,null);
        system.assertNotEquals(controller.successPlanPlayGridAttribute,null);
        
		Test.stopTest();
	}
}