@isTest
private class REN_AssetBusinessLayerTest {
	private static Id testAccountId;
    private static CSM_Account_Plan_Template__c testTemplate;
    private static CSM_Account_Plan__c testAcctPlan;
    
    static testMethod void Test_GetAssetWrapperList() {
    	setUp();
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.accountId = testAccountId;
    	gridParams.accountPlanId = testAcctPlan.Id;
    	inputWrapper.params = gridParams;
    	CSM_BusinessLayer businessLayer = new REN_AssetBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	Test.stopTest();
    }
    
    static testMethod void Test_GetAWrapperList_EmptyList() {
    	setUp();
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.accountPlanId = testAcctPlan.Id;
    	inputWrapper.params = gridParams;
    	CSM_BusinessLayer businessLayer = new REN_AssetBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	Test.stopTest();
    }
    
    static void setUp(){ 
    	List<REN_Renew_Configuration__c> renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
		List <Account> accountList = CSM_TestDataUtility.createAccount(1);
		
		List<CSM_Account_Plan_Template__c> testTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        System.assert(!testTemplates.isEmpty());
        testTemplate = testTemplates[0];
        
        List<CSM_Account_Plan__c> acctPlanList = CSM_TestDataUtility.createAccountPlan(accountList, testTemplate.Id);
        System.assert(!acctPlanList.isEmpty());
        testAcctPlan = acctPlanList[0];		
		
        Asset assetObject = new Asset();
		assetObject.Name = 'Test_US359SLA: Gold';
		assetObject.Price = 500;
		assetObject.AccountId = accountList[0].id;
		insert assetObject;
		testAccountId = accountList[0].id;
	}
}