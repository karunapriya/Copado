@isTest
private class CSM_CustomObjectTriggerHandlerTest {
	
	 @testSetup
	 static void setup() {       
		CSM_Constants.ACCOUNT_TRIGGER = false;
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
		
		insert new SS_License__c(CSM__c = true);
		
		List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(2); 
        
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
        List<CSM_Play_Criteria__c> playCriteriaList = CSM_TestDataUtility.createPlayCriteriaData(playList[0].id);
        
        List<CSM_Play__c> playListOppty = CSM_TestDataUtility.createPlayOpportunityTestData(playbookList[1].Id, 1);
        List<CSM_Play_Criteria__c> playCriteriaListOppty = playCriteriaList = CSM_TestDataUtility.createPlayCriteriaOpptyData(playListOppty[0].id);
        
        List<CSM_Play_Task__c> playTaskList = CSM_TestDataUtility.createPlayTaskData(playList[0].id);
        List<CSM_Play_Task__c> playTaskListOppty = CSM_TestDataUtility.createPlayTaskData(playListOppty[0].id);
        List<CSM_PlaybookPlay__c> playbookPlayList = new List<CSM_PlaybookPlay__c>(); 
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[0].Id, playList[0].Id));
        playbookPlayList.add(CSM_TestDataUtility.createPlaybookPlayTestData(playbookList[1].Id, playListOppty[0].Id));
        
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        system.assert(accountList != null);
        List<Opportunity> opptyList = CSM_TestDataUtility.createOpportunity(1, accountList[0].Id);
        System.debug('ZZZ - opptyList - '+opptyList);
        List<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> accountPlanList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = CSM_TestDataUtility.createAccountPlanPlaybookData(accountPlanList[0].id, templateList[0].id, new List<String>{playbookList[0].id, playbookList[1].id});
	}


    static testMethod void myUnitTest() {
    	
    	
			Test.startTest();
	    	List<Opportunity> opptyList = [SELECT accountId, Name, CloseDate, StageName, REN_Is_Consolidated__c FROM Opportunity WHERE Name = 'New Opp 1'];
	    	CSM_CustomObjectTriggerHandler cot = new CSM_CustomObjectTriggerHandler();
	    	System.debug('opptyList - '+opptyList);
	        // TO DO: implement unit test
	        cot.onAfterUpdate(null, opptyList, null, null);
	        List<Task> tkList = [SELECT Id FROM Task WHERE WhatId IN :opptyList];
	        System.assert(tkList!=null);
	        Test.stopTest();
		
    }
}