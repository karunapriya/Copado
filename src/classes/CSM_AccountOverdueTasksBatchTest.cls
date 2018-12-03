@isTest(SeeAllData = true)
private class CSM_AccountOverdueTasksBatchTest {

    static testMethod void myUnitTest() {
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
        playbookList[0].CSM_Automated__c = false;
        //playbookList[1].CSM_Automated__c = false;
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        
        playList[0].CSM_Query_Criteria__c = 'select id from Account';
        playList[0].CSM_Object_Name__c = 'Account';
        update playList[0];
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        List<Account> accountList = CSM_TestDataUtility.createAccount(2);

        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id});
        CSM_Constants.ACCOUNT_TRIGGER = true;
		accountList[0].AnnualRevenue = 100;
		accountList[1].CSM_Overdue_Tasks_Count__c = 1;
		
        csm_successplan_play__c spplay = new   csm_successplan_play__c();
        spplay.csm_successplan_playbook__c = accountPlanPlaybookList[0].Id;   
        spplay.csm_play__c =   playList[0].Id;
        
        insert spplay;
		
        List<CSM_Play_Task__c> tmpList = new List<CSM_Play_Task__c>();      
        CSM_Play_Task__c newTask1 = new CSM_Play_Task__c();
        newTask1.CSM_Assign_To__c = CSM_Constants.ASSIGN_ACCOUNT_OWNER;
        newTask1.Name = 'Task 1';
        newTask1.CSM_Days_Until_Due__c = 1;
        newTask1.CSM_IsActive__c = true;
        newTask1.CSM_Play__c = playList[0].Id;
        newTask1.CSM_Description__c = 'The description';
        tmpList.add(newTask1);
        insert tmpList;     
		
		update accountList[0];
		update accountList[1];		
        //CSM_TaskCreationTriggerUtil.CreatePlayActivities(new Set<Id>{testOpp[0].accountId});
        List<Task> taskList = [select Id,ActivityDate from Task where whatId =:accountList[0].Id];


        taskList[0].ActivityDate = system.today() - 2;
        update taskList;
                    
        
		Test.StartTest();
		String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);		
		String jobID = system.schedule(Label.CSM_BATCH_OVERDUE_TASKS, strDateTime, new CSM_BatchAccOvrdueTskScheduledDispatcher());
		Database.executeBatch(new CSM_AccountOverdueTasksBatch());
		Test.StopTest();
        List<Account> acctList = [select Id from Account where CSM_Overdue_Tasks_Count__c > 0 and Id =:accountList[0].Id];		
        system.assert(taskList.size() == 1);
    }
}