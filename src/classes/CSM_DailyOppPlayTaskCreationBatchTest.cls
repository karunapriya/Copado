/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class CSM_DailyOppPlayTaskCreationBatchTest {

	public static boolean isNegative;
    static testMethod void myUnitTest() {
    	isNegative = false;
        CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
		
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
        
        playList[0].CSM_Query_Criteria__c = 'select id, AccountId from Opportunity';
        playList[0].CSM_Object_Name__c = 'Opportunity';
        update playList[0];
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);

        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id});
        CSM_Constants.ACCOUNT_TRIGGER = true;
        CSM_Constants.CASE_TRIGGER = true;
		List<Opportunity> opp =   CSM_TestDataUtility.createOpportunity(1,accountList[0].Id);
		system.debug('Test 1 -'  + opp);		
        //Opp.Status = 'New';
		Test.StartTest();
		//String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);		
		//String jobID = system.schedule('TestTasks', strDateTime, new CSM_BatchCreatePlayScheduledDispatcher());
		String jobID = Database.executeBatch(new CSM_DailyOppPlayTaskCreationBatch());
		Test.StopTest();
		//System.abortJob(jobID);

        List<Task> taskList = [select Id,ActivityDate from Task];
        		
        system.assert(jobID != null);
    }
    
    static testMethod void myUnitTest1() {
    	isNegative = true;
        CSM_Constants.ACCOUNT_TRIGGER = true;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
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
        
        playList[0].CSM_Query_Criteria__c = 'select id,Case from Case';
        playList[0].CSM_Object_Name__c = 'Case';
        update playList[0];
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);

        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id});
        CSM_Constants.ACCOUNT_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
                
		Test.StartTest();
		String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);		
		String jobID = system.schedule('TestTask01', strDateTime, new CSM_DailyOppBatchCreatePlaySchdDispatchr());
		String jobID1 = Database.executeBatch(new CSM_DailyOppPlayTaskCreationBatch());
		Test.StopTest();
		System.abortJob(jobID);
		System.abortJob(jobID1);				

        List<Task> taskList = [select Id,ActivityDate from Task where whatId =:accountList[0].Id];		
        system.assert(taskList.size() == 0);
    }   

}