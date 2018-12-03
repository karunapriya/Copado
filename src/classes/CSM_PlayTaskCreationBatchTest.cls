@isTest
public class CSM_PlayTaskCreationBatchTest {
	public static boolean isNegative;
    static testMethod void myUnitTest() {
    	isNegative = false;
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
        playbookList[0].CSM_Automated__c = false;
        //playbookList[1].CSM_Automated__c = false;
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
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
        system.assert(tmpList[0].id != null);
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

        csm_successplan_play__c spplay = new   csm_successplan_play__c();
        spplay.csm_successplan_playbook__c = accountPlanPlaybookList[0].Id;   
        spplay.csm_play__c =   playList[0].Id;
        
        insert spplay;
        
		update accountList;
		        
		Test.StartTest();
		//String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);		
		//String jobID = system.schedule('TestTasks', strDateTime, new CSM_BatchCreatePlayScheduledDispatcher());
		String jobID = Database.executeBatch(new CSM_PlayTaskCreationBatch());
		Test.StopTest();
		//System.abortJob(jobID);

        List<Task> taskList = [select Id,ActivityDate from Task where whatId =:accountList[0].Id];		
        system.assert(taskList.size() > 0);
    }
    
    static testMethod void myUnitTest1() {
    	isNegative = true;
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(1);
        playbookList[0].CSM_Automated__c = false;
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
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
        system.assert(tmpList[0].id != null);
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

        
		Test.StartTest();
		String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);		
		String jobID = system.schedule('TestTask01', strDateTime, new CSM_BatchCreatePlayScheduledDispatcher());
    	//User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	//system.runAs(restrictedUser){
			String jobID1 = Database.executeBatch(new CSM_PlayTaskCreationBatch());
    	//}
		Test.StopTest();
		//System.abortJob(jobID);
		//System.abortJob(jobID1);				

        List<Task> taskList = [select Id,ActivityDate from Task where whatId =:accountList[0].Id];		
        system.assert(taskList.size() == 0);
    }    
    
}