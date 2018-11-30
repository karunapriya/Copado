@isTest
private class CSM_PlaybookBusinessLayerTest {

	private static Id testAccountId;
    private static CSM_Account_Plan_Template__c testTemplate;
    private static CSM_Account_Plan__c testAcctPlan;
    
    static testMethod void Test_GetPlaybookWrapperList() {
    	setUp();
    	Test.startTest(); 
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.accountId = testAccountId;
    	gridParams.accountPlanId = testAcctPlan.Id;
    	inputWrapper.params = gridParams;
    	CSM_BusinessLayer businessLayer = new CSM_PlaybookBusinessLayer(inputWrapper);
		
		CSM_GridImageWrapper grdImage = new CSM_GridImageWrapper();
	    grdImage.imgSource = null;
	    grdImage.altImg  = null;
	    grdImage.imgWidth  = null;
	    grdImage.imgHeight  = null;
	    grdImage.imgClass  = null;
	    grdImage.imgTitle  = null;
		
    	
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
        
        List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybooks(10);
        List<String> pbIdList = new List<String>();
        for(CSM_Playbook__c p : playbookList)
        {
            pbIdList.add(p.id);
        }
        List<CSM_Account_Plan_Playbook__c> appList = CSM_TestDataUtility.createAccountPlanPlaybookData(acctPlanList[0].Id, null, pbIdList );
    }
}