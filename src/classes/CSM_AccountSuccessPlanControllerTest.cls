@isTest(SeeAllData = true)
public with sharing class CSM_AccountSuccessPlanControllerTest
{
	private static Id testAccountId;
	private static CSM_Account_Plan_Template__c testTemplate;
	private static CSM_Account_Plan__c testAcctPlan;
	
	static testMethod void testAccountSuccessPlan()
	{
	    setUp();
    	Test.startTest();
    	PageReference pageRef = Page.CSM_AccountSuccessPlan;
    	pageRef.getParameters().put(CSM_Constants.OBJ_IG_ID, testAcctPlan.Id);
    	Test.setCurrentPage(pageRef);    
    	
    	ApexPages.StandardController sc = new ApexPages.standardController(testAcctPlan);
        CSM_AccountSuccessPlanController aspController = new CSM_AccountSuccessPlanController(sc);
        string packageVersion=aspController.packageVersion;
        string scoutURL=aspController.scoutUrl;
        System.assertNotEquals(aspController.liList, null);
        System.assertNotEquals(aspController.acctPlan, null);
        
    	Test.stopTest();
	}
    static testMethod void testAccountSuccessPlanNeg()
	{
	    setUp();
    	Test.startTest();
    	ApexPages.StandardController sc = new ApexPages.standardController(testAcctPlan);
        CSM_AccountSuccessPlanController aspController = new CSM_AccountSuccessPlanController(sc);
        System.assertNotEquals(aspController.liList, null);
        System.assertNotEquals(aspController.acctPlan, null);
        
    	Test.stopTest();
	}
	
	static void setUp() 
	{
		List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        System.assert(!accountList.isEmpty());
        testAccountId = accountList[0].Id;
        System.assertNotEquals(testAccountId, null);
        
        List<CSM_Account_Plan_Template__c> testTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        System.assert(!testTemplates.isEmpty());
        testTemplate = testTemplates[0];
        
        List<CSM_Account_Plan__c> acctPlanList = CSM_TestDataUtility.createAccountPlan(accountList, testTemplate.Id);
        System.assert(!acctPlanList.isEmpty());
        testAcctPlan = acctPlanList[0];
        
	}
	
	static testMethod void accountTriggerHandler_NegativeTest() {
		setUp();
        List<CSM_Account_Plan__c> acctPlanList =[select Id from CSM_Account_Plan__c where id = :testAcctPlan.id limit 1];
         System.assert(!acctPlanList.isEmpty());
        // Cause DMLException
        CSM_AccountTriggerHandler ath = new CSM_AccountTriggerHandler();
        CSM_Account_Plan__c ap = new CSM_Account_Plan__c();
        ath.onAfterUpdate(null,acctPlanList,null,null);
	}
}