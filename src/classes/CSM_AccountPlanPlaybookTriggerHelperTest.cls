@isTest
private class CSM_AccountPlanPlaybookTriggerHelperTest {
	
	@testSetup static void setup() {
		CSM_TestDataUtility.enableAllTriggers();
		
		insert new SS_License__c(CSM__c = true);
		List<Account> accountList =  CSM_TestDataUtility.createAccount(2);
		LIst<CSM_Account_Plan_Template__c> templateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
		List<CSM_Playbook__c> playbookLst = CSM_TestDataUtility.createPlaybooks(2);
		List<CSM_Play__c> plyLst = CSM_TestDataUtility.createPlayTestData(2);
		CSM_TestDataUtility.createPlaybookPlayTestData(playbookLst[0].id,plyLst[0].id);
		CSM_TestDataUtility.createPlaybookPlayTestData(playbookLst[0].id,plyLst[1].id);
		List<String> playbookIdList = new List<String>(); 
		for(CSM_Playbook__c playbook : playbookLst){
			playbookIdList.add(playbook.id);
		}
		String templateId = templateList[0].id;
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;
		CSM_TestDataUtility.createAccountPlanPlaybookData('', templateId , playbookIdList);
		system.assert(playbookIdList.size() > 0);
 	}

    static testMethod void createSPPBookRecordTest() {
    	CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;        
    	
    	List<Account> accountList =  [Select id from Account Limit 2];
    	LIst<CSM_Account_Plan_Template__c> templateList = [Select id from CSM_Account_Plan_Template__c Limit 1];
    	Test.startTest();
    	List<CSM_Account_Plan__c> planList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
        Test.stopTest();
    	List <CSM_Account_Plan_Playbook__c> spPbookLst = [Select id from CSM_Account_Plan_Playbook__c where CSM_Account_Plan__c != null];	
    	system.debug(' pbsize -' + spPbookLst.size());
    	system.assert(spPbookLst.size()==4);
        
    }
    
    static testMethod void createSPPBookRecordAfterSPTest() {
    	CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;        

    	List<Account> accountList =  [Select id from Account Limit 1];
    	LIst<CSM_Account_Plan_Template__c> templateList = [Select id from CSM_Account_Plan_Template__c Limit 1];
    	List<CSM_Account_Plan__c> planList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
    	List<CSM_Playbook__c> playbookLst = CSM_TestDataUtility.createPlaybooks(1);
		Test.startTest();
		List<String> playbookIdList = new List<String>(); 
		for(CSM_Playbook__c playbook : playbookLst){
			playbookIdList.add(playbook.id);
		}
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;
		String templateId = templateList[0].id;
		CSM_TestDataUtility.createAccountPlanPlaybookData('', templateId , playbookIdList);
		Test.stopTest();
    	List <CSM_Account_Plan_Playbook__c> spPbookLst = [Select id from CSM_Account_Plan_Playbook__c where CSM_Account_Plan__c != null];	
    	system.assert(spPbookLst.size()==3);
    }
    
    static testMethod void changeofTemplateTest() {
    	CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;        

    	List<Account> accountList =  [Select id from Account Limit 1];
    	LIst<CSM_Account_Plan_Template__c> templateList = [Select id from CSM_Account_Plan_Template__c Limit 1];
    	//create acct plan with existing template 
    	List<CSM_Account_Plan__c> planList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
    	
    	//create new template
    	LIst<CSM_Account_Plan_Template__c> newTemplateList = CSM_TestDataUtility.createAccountPlanTemplateData(1);
		List<CSM_Playbook__c> playbookLst = CSM_TestDataUtility.createPlaybooks(1);
		List<CSM_Play__c> plyLst = CSM_TestDataUtility.createPlayTestData(1);
		CSM_TestDataUtility.createPlaybookPlayTestData(playbookLst[0].id,plyLst[0].id);
		List<String> playbookIdList = new List<String>(); 
		for(CSM_Playbook__c playbook : playbookLst){
			playbookIdList.add(playbook.id);
		}
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;		
		String templateId = newTemplateList[0].id;
		CSM_TestDataUtility.createAccountPlanPlaybookData('', templateId , playbookIdList);
    	
    	Test.startTest();
    	CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
        //change of template
    	CSM_Account_Plan__c accountPlan = new CSM_Account_Plan__c(id = planList[0].id);
    	accountPlan.CSM_Account_Plan_Template__c = templateId;
    	update accountPlan;
        Test.stopTest();
    	List <CSM_Account_Plan_Playbook__c> spPbookLst = [Select id from CSM_Account_Plan_Playbook__c where CSM_Account_Plan__c = :planList[0].id];	
    	system.assert(spPbookLst.size()==1);
    }
    static testMethod void afterUpdateTest() {
    	CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;        
        
    	Test.startTest();
	    	List<Account> accountList =  [Select id from Account Limit 2];
	    	LIst<CSM_Account_Plan_Template__c> templateList = [Select id from CSM_Account_Plan_Template__c Limit 1];
	    	List<CSM_Account_Plan__c> planList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
	    	List <CSM_Account_Plan_Playbook__c> spPbookLst = [Select id,CSM_IsActive__c from CSM_Account_Plan_Playbook__c where CSM_Account_Plan__c != null];

	    	List<CSM_Account_Plan_Playbook__c> updateAccountPlanPB = new List<CSM_Account_Plan_Playbook__c>();
	    	CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;
	    	for(CSM_Account_Plan_Playbook__c appb : spPbookLst) {
	    		appb.CSM_IsActive__c = false;
	    		updateAccountPlanPB.add(appb);
	    	}	
	    	update updateAccountPlanPB;
	    	system.assert(spPbookLst.size()==4);	    	
    	Test.stopTest();
    }
     static testMethod void beforeDeleteTest() {
    	CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
		CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;        

    	Test.startTest();
	    	List<Account> accountList =  [Select id from Account Limit 1];
	    	LIst<CSM_Account_Plan_Template__c> templateList = [Select id from CSM_Account_Plan_Template__c Limit 1];
	    	List<CSM_Account_Plan__c> planList = CSM_TestDataUtility.createAccountPlan(accountList, templateList[0].id);
	    	List <CSM_Account_Plan_Playbook__c> spPbookLst = [Select id,CSM_IsActive__c from CSM_Account_Plan_Playbook__c where CSM_Account_Plan__c != null];
	    	system.assert(spPbookLst.size()==2);
	    	CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;
	    	delete spPbookLst[0];
    	Test.stopTest();
    }
}