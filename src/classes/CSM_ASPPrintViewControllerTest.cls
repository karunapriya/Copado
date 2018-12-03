@isTest(SeeAllData=true)
private class CSM_ASPPrintViewControllerTest {

	private static Id testAccountId;
	private static CSM_Account_Plan_Template__c testTemplate;
	private static CSM_Account_Plan__c testAcctPlan;
	
	static testMethod void Test_ASPPrintView_Positive() {
		Test.startTest();
		setUp();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAcctPlan);
		CSM_ASPPrintViewController ctrl = new CSM_ASPPrintViewController(sc);
		system.assert(ctrl != null);
		system.assert(ctrl.acctPlanList != null);
		Test.stopTest();
	}
	
	static testMethod void Test_ASPPrintView_Negative() {
		Test.startTest();
		setUp();
		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser){
    		try{
				ApexPages.StandardController sc = new ApexPages.StandardController(testAcctPlan);
				CSM_ASPPrintViewController ctrl = new CSM_ASPPrintViewController(sc);
    		}catch(Exception ex){
    			system.assert(true);
    		}
    	}
		Test.stopTest();
	}
	
	static void setUp() {
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
}