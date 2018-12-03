@isTest
private class CSM_OpportunityBusinessLayerTest {

    private static Id testAccountId;
    private static CSM_Account_Plan_Template__c testTemplate;
    private static CSM_Account_Plan__c testAcctPlan;
    
    static testMethod void Test_GetOpportunityWrapperList() {
    	setUp();
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.accountId = testAccountId;
    	gridParams.accountPlanId = testAcctPlan.Id;
    	inputWrapper.params = gridParams;
    	CSM_BusinessLayer businessLayer = new CSM_OpportunityBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    	system.assert(responseWrapper.row != null);
    	system.assert(!responseWrapper.row.isEmpty());
    	system.assertEquals(responseWrapper.hasAction, true);
    	system.assertEquals(responseWrapper.hasCheckbox, false);
    	system.assertEquals(responseWrapper.hasDetail, false);
    	Test.stopTest();
    }
    
    static testMethod void Test_GetOpportunityWrapperList_EmptyList() {
    	setUp();
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.accountPlanId = testAcctPlan.Id;
    	inputWrapper.params = gridParams;
    	CSM_BusinessLayer businessLayer = new CSM_OpportunityBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    	system.assert(responseWrapper.row != null);
    	system.assert(responseWrapper.row.isEmpty());
    	system.assertEquals(responseWrapper.hasAction, true);
    	system.assertEquals(responseWrapper.hasCheckbox, false);
    	system.assertEquals(responseWrapper.hasDetail, false);
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
        
        Opportunity opport = new Opportunity();
        opport.AccountId = testAccountId;
        opport.StageName = 'Prospecting';
        opport.CloseDate = System.today() + 1;
        opport.Name = 'Opportunity Test';
        insert opport;
        System.assertNotEquals(opport.Id, null);
    }
    
    static testMethod void Test_GetOpportunityWrapperList1() {
    	setUp();
    	Test.startTest();
    		CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    		CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    		gridParams.accountId = testAccountId;
    		gridParams.accountPlanId = testAcctPlan.Id;
    		inputWrapper.params = gridParams;
    		inputWrapper.viewName = CSM_Constants.GRID_ATTR_CONSOLIDATE;
    		CSM_BusinessLayer businessLayer = new CSM_OpportunityBusinessLayer(inputWrapper);
    		CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	    system.assert(responseWrapper != null);
    	Test.stopTest();
    }
}