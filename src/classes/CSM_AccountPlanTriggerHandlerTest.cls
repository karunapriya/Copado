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
private class CSM_AccountPlanTriggerHandlerTest {

	private static Id testAccountId;
	private static CSM_Account_Plan_Template__c testTemplate;
	private static List<CSM_Account_Plan__c>  acctPlanList;
	
	static testMethod void testAccountPlantRigger() {
	 	setUp();
    	Test.startTest();
	}

	static testMethod void accountPlanTriggerUpdate() {
	 	setUp();
    	Test.startTest();
    	CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
    	CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
    	List<CSM_Account_Plan__c> newAcctPlanList =[select Id, CSM_AccountId__c,CSM_CurrentPhase__c from CSM_Account_Plan__c where Id = : acctPlanList[0].Id limit 1];
    	newAcctPlanList[0].CSM_CurrentPhase__c = '4';
		update newAcctPlanList;
    	Test.stopTest();
    	List<Account> lstAcct = [select Id, CSM_Account_Has_Success_Plan__c from Account where iD =: newAcctPlanList[0].CSM_AccountId__c];
    	system.debug('accli' + lstAcct);
    	system.assert(lstAcct[0].CSM_Account_Has_Success_Plan__c == true);
	}
	
	static testMethod void accountPlanTriggerDelete() {
	 	setUp();
    	Test.startTest();
    	CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
    	CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
    	List<CSM_Account_Plan__c> newAcctPlanList =[select Id, CSM_Accountid__c from CSM_Account_Plan__c where Id = : acctPlanList[0].Id limit 1];
		Set<Id> delList = new Set<Id>();
		for(CSM_Account_Plan__c aplan:newAcctPlanList){
			delList.add(aPlan.CSM_AccountId__c);
		}
		delete newAcctPlanList;
    	Test.stopTest();
    	system.debug('delist' + delList);
    	List<Account> lstAcct = [select Id, CSM_Account_Has_Success_Plan__c from Account where iD IN: delList];
    	system.assert(lstAcct[0].CSM_Account_Has_Success_Plan__c == false);
    	
	}


	static testMethod void accountPlanTriggerUnDelete() {
	 	setUp();
    	Test.startTest();
    	CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
    	CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
    	List<CSM_Account_Plan__c> newAcctPlanList =[select Id,CSM_AccountId__c, CSM_CurrentPhase__c from CSM_Account_Plan__c where Id = : acctPlanList[0].Id limit 1];

		delete newAcctPlanList;
    	CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
    	CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
		undelete newAcctPlanList;
    	Test.stopTest();
    	List<Account> lstAcct = [select Id, CSM_Account_Has_Success_Plan__c from Account where iD =: newAcctPlanList[0].CSM_AccountId__c];
    	system.assert(lstAcct[0].CSM_Account_Has_Success_Plan__c == true);
    	
	}

	 
	static void setUp() 
	{
        
		insert new SS_License__c(CSM__c = true);

		List<Account> accountList = CSM_TestDataUtility.createAccount(2);
        System.assert(!accountList.isEmpty());
        testAccountId = accountList[0].Id;
        System.assertNotEquals(testAccountId, null);
        
        List<CSM_Account_Plan_Template__c> testTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        System.assert(!testTemplates.isEmpty());
        testTemplate = testTemplates[0];
		CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = true;
		CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = true;
		
		List<CSM_Account_Plan__c> accountPlanList = new List<CSM_Account_Plan__c>();
    	
    	for (Account a : accountList)
    	{
    		CSM_Account_Plan__c accountPlan = new CSM_Account_Plan__c();
    		accountPlan.CSM_Account_Plan_Template__c = testTemplates[0].Id;
    		accountPlan.CSM_Phase_Start_Date__c = System.today();
    		accountPlan.CSM_AccountId__c = a.id;
    		accountPlan.CSM_isActive__c = true;
    		accountPLanList.add(accountPlan);
    	}
    	insert accountPlanList;
		
        acctPlanList = accountPlanList;
        System.assert(!acctPlanList.isEmpty());
        acctPlanList[0].CSM_Phase_Start_Date__c= System.today().addDays(30);
        List<CSM_Account_Plan_Phase__c> testAcctPlanPhaseList = CSM_TestDataUtility.createAccountPlanPhaseData(1, testTemplate.Id);
	}
}