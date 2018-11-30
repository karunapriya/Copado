@isTest
private class CSM_SuccessPlanPlayBusinessLayerTest {
	@testSetup 
    static void setUp() {
       	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
        List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(1);
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
		
		system.assert(succPlanPlay.size() > 0);		    
    
    	//User userRecord = CSM_TestDataUtility.createTestUser('Standard User');
    }
    static testMethod void testBusinessLayer_Positive() {
    	List<CSM_Account_Plan__c> accountPlan = [select id from CSM_Account_Plan__c limit 1];
    	Test.startTest();
		   	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
	    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
	    	gridParams.accountPlanId = accountPlan[0].id;
	    	inputWrapper.params = gridParams;
	    	CSM_BusinessLayer businessLayer = new CSM_SuccessPlanPlayBusinessLayer(inputWrapper);
	    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
	    	system.assert(responseWrapper != null);
	    	system.assert(responseWrapper.header != null);
	    	system.assert(responseWrapper.row != null);
	    	system.assertEquals(responseWrapper.hasAction, false);
	    	system.assertEquals(responseWrapper.hasCheckbox, false);
	    	system.assertEquals(responseWrapper.hasDetail, false);
	    Test.stopTest();
    }
    static testMethod void testBusinessLayer_Negative() {
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	List<CSM_Account_Plan__c> accountPlan = [select id from CSM_Account_Plan__c limit 1];
    	Test.startTest();
	        system.runAs(restrictedUser) {
			   	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
		    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
		    	gridParams.accountPlanId = accountPlan[0].id;
		    	inputWrapper.params = gridParams;
		    	CSM_BusinessLayer businessLayer = new CSM_SuccessPlanPlayBusinessLayer(inputWrapper);
		    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
		    	system.assert(responseWrapper != null);
	        }
		Test.stopTest();	    	
    }
}