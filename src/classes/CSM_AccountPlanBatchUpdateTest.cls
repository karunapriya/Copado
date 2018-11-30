@isTest
public with sharing class CSM_AccountPlanBatchUpdateTest 
{
	private static Id testAccountId;
	private static CSM_Account_Plan_Template__c testTemplate;
	private static List<CSM_Account_Plan__c>  acctPlanList;
	
	static testMethod void testAccountPlanDetails() {
	 	setUp();
    	Test.startTest();
    	CSM_AccountPlanBatchUpdate batch = new CSM_AccountPlanBatchUpdate();
    	batch.isNegativeTest = false;
        //string sch = '0 0 0 1 JAN ? *';
        //system.schedule('Batch Process', sch, batch);
    	ID batchprocessid = Database.executeBatch(batch);
  		CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
        List<CSM_Account_Plan__c> newAcctPlanList =[select Id, CSM_CurrentPhase__c from CSM_Account_Plan__c where Id = : acctPlanList[0].Id limit 1];
    	Test.stopTest();
    
    	System.assertNotEquals(batchprocessid, null);
    	System.assertEquals(newAcctPlanList[0].CSM_CurrentPhase__c, null);
    	System.assertEquals(batch.testJobSize, null);
		System.assertEquals(batch.processSize, null);
	}

	static testMethod void apBatchNegative() {
	 	setUp();
    	Test.startTest();
  		CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
  		CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
    	CSM_AccountPlanBatchUpdate batch = new CSM_AccountPlanBatchUpdate();
    	batch.isNegativeTest = true;
        //string sch = '0 0 0 1 JAN ? *';
        //system.schedule('Batch Process', sch, batch);
   		ID batchprocessid = Database.executeBatch(batch);
       	List<CSM_Account_Plan__c> newAcctPlanList =[select Id, CSM_CurrentPhase__c from CSM_Account_Plan__c where Id = : acctPlanList[0].Id limit 1];
    	Test.stopTest();

    	System.assertNotEquals(batchprocessid, null);
    	System.assertEquals(newAcctPlanList[0].CSM_CurrentPhase__c, null);
    	System.assertEquals(batch.testJobSize, null);
		System.assertEquals(batch.processSize, null);
	}


	 
	static void setUp() 
	{
		List<Account> accountList = CSM_TestDataUtility.createAccount(2);
        System.assert(!accountList.isEmpty());
        testAccountId = accountList[0].Id;
        System.assertNotEquals(testAccountId, null);
        
        List<CSM_Account_Plan_Template__c> testTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        System.assert(!testTemplates.isEmpty());
        testTemplate = testTemplates[0];
  		CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
  		CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
        acctPlanList = CSM_TestDataUtility.createAccountPlan(accountList, testTemplate.Id);
        System.assert(!acctPlanList.isEmpty());
        acctPlanList[0].CSM_Phase_Start_Date__c= System.today().addDays(30);
        
        List<CSM_Account_Plan_Phase__c> testAcctPlanPhaseList = CSM_TestDataUtility.createAccountPlanPhaseData(1, testTemplate.Id);
	}
        
}