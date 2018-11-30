@isTest
public with sharing class CSM_TimelineComponentControllerTest
{
	
	private static Id testAccountId;
	private static Id testAccountPlanTemplateId;
	private static String testTaskId;
	
	static testMethod void testTimeline() {
		
		setUp();
		Test.startTest();	
    	String timelineWrapperJson = CSM_TimelineComponentController.getTimelineJsonWrapper(testAccountId, testAccountPlanTemplateId);
    	system.debug('timelineWrapperJson $$$$$$$ '+timelineWrapperJson);
    	Test.stopTest();
	}
	
	static void setUp() 
	{
		CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        CSM_TestUtility.addCSMAdmin();
        
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        System.assert(!accountList.isEmpty());
        testAccountId = accountList[0].Id;
        
        List<CSM_Account_Plan_Template__c> acctPlanTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        System.assert(!acctPlanTemplateList.isEmpty());
        testAccountPlanTemplateId = acctPlanTemplateList[0].Id;
        
        List<CSM_Account_Plan_Phase__c> phaseData = CSM_TestDataUtility.createAccountPlanPhaseData(4, testAccountPlanTemplateId);
        
        CSM_Account_Plan__c accountPlan = new CSM_Account_Plan__c();
        accountPlan.CSM_AccountId__c = testAccountId;
        accountPlan.CSM_Account_Plan_Template__c = testAccountPlanTemplateId;
        accountPlan.CSM_Phase_Start_Date__c = System.today();
        insert accountPlan;
        System.assertNotEquals(accountPlan.Id, null);
        
        List<Opportunity> opptyList = CSM_TestDataUtility.createOpportunity(1, testAccountId);
        system.assert(opptyList[0].Id != null);
        opptyList[0].REN_Is_CLM_Renewal__c = true;
        update opptyList;
        
        CSM_Playbook__c playBook = new CSM_Playbook__c();
		playBook.CSM_IsActive__c = true;
		playBook.CSM_Display_Name__c = 'Playbook A';
		playBook.CSM_Automated__c = false;
		playBook.CSM_Playbook_Type__c = 'Manual';
		insert playBook;
		System.assertNotEquals(playBook.Id, null);
		
		CSM_Play__c play = new CSM_Play__c();
		play.CSM_IsActive__c = true;
		play.CSM_Automated__c = false;
		play.CSM_Display_Name__c = 'Play A';
		play.CSM_Object_Name__c = 'Account';
		insert play;
		System.assertNotEquals(play.Id, null);
        
        CSM_TestUtility.insertPlayTask(play.Id);
		
		CSM_TestUtility.insertPlaybookPlay(playBook.Id, play.Id);
		
		CSM_TestUtility.insertSPPB(accountPlan.Id, playBook.Id);
		
		CSM_TestUtility.insertSPPL(play.Id, CSM_TestUtility.acctPlanPB.Id);
		
		CSM_TestUtility.insertTask(testAccountId, accountPlan.Id, play.Id);
		
        Task timelineTask = new Task();       
        timelineTask.Subject = 'Test Subject';
        timelineTask.ActivityDate = System.today() + 1;
        timelineTask.WhatId = testAccountId;
        timelineTask.CSM_Account_Plan__c = accountPlan.Id;
        timelineTask.CSM_Play__c = play.Id;
        timelineTask.CSM_SuccessPlan_Play__c = CSM_TestUtility.spPlay.Id;
                
        insert timelineTask;
        System.assertNotEquals(timelineTask.Id, null);
        testTaskId = timelineTask.Id;
        
        Task timelineTask2 = new Task();       
        timelineTask2.Subject = 'Test Subject2';
        timelineTask2.ActivityDate = System.today() + 1;
        timelineTask2.WhatId = testAccountId;
        timelineTask2.CSM_Account_Plan__c = accountPlan.Id;
        timelineTask2.CSM_Play__c = play.Id;
        timelineTask2.status = CSM_Constants.TASK_COMPLETED;
        timelineTask2.CSM_SuccessPlan_Play__c = CSM_TestUtility.spPlay.Id;        
        insert timelineTask2;
        System.assertNotEquals(timelineTask2.Id, null);
	}
}