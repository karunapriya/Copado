@isTest
private class REN_ServiceContractBusinessLayerTest {
	private static Id testAccountId;
    private static CSM_Account_Plan_Template__c testTemplate;
    private static CSM_Account_Plan__c testAcctPlan;
    private static List<Sobject> sc;
    
    static testMethod void Test_GetAssetWrapperList() {
    	setUp();
    	sc = CSM_TestDataUtility.createServiceContract(1, testAccountId);
    	system.assertNotEquals(sc, null);
    	
    	Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;
    	Id standardPB = Test.getStandardPricebookId();
    	PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB, UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
		insert price1;
		system.assert(price1.Id != null);
		
    	//Sobject tempVar = new ContractLineItem();
    	if (CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT))
	    {
	    	SObject tempVar = CSM_AccessController.newSObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
	        tempVar.put(REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID,price1.id);
	        tempVar.put(REN_Constants.OBJ_SCLI_QUANTITY,1);
	        tempVar.put(REN_Constants.OBJ_OLI_UNITPRICE,10);
	        tempVar.put(REN_Constants.OBJ_SCLI_STARTDATE,Date.Today());
	        tempVar.put(REN_Constants.OBJ_SCLI_ENDDATE,Date.Today().addYears(1));
	        tempVar.put(REN_Constants.OBJ_SCLI_SERVICECONTRACTID, sc[0].id);
	        insert tempVar;
	    }
	   
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.accountId = testAccountId;
    	gridParams.accountPlanId = testAcctPlan.Id;
   		gridParams.selectedFilterClause = 'where status != null';
    	inputWrapper.params = gridParams;
    	CSM_BusinessLayer businessLayer = new REN_ServiceContractBusinessLayer(inputWrapper);
    	if (CSM_AccessController.hasObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM)){
	    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
	    	system.assert(responseWrapper != null);
    	}
    	system.assert(gridParams != null);
    	Test.stopTest();
    }
    
    static testMethod void Test_GetAWrapperList_EmptyList() {
    	setUp();
    	Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.accountPlanId = testAcctPlan.Id;
    	inputWrapper.params = gridParams;
    	CSM_BusinessLayer businessLayer = new REN_ServiceContractBusinessLayer(inputWrapper);
    	if (CSM_AccessController.hasObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM)){
	    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
	    	system.assert(responseWrapper != null);
    	}
    	system.assert(gridParams != null);
    	Test.stopTest();
    }

    static testMethod void TestGenericErrorMessage() {
    	Test.startTest();
    	try{
    		 throw new CSM_AccessController.AccessControlDmlException( 'My Message');
    	}catch(Exception e){
			system.assert(REN_Util.getGenericErrorMessage(e, 'a') != null);
    	}
    	system.assert(true);
    	Test.stopTest();
    }
    
    static void setUp(){ 
    	REN_TestDataSetup testDataSetup = new REN_TestDataSetup('ssTest');
    	testDataSetup.createRenewConfigurations();
    	testDataSetup.renewDataSetup(1, 1, 1);
    	testDataSetup.setFieldsData(testDataSetup.opportunityList, REN_Constants.OBJ_RC_OPPORTUNITY_STAGE, 'Closed Won');
    	//testDataSetup.resetAllTriggersTo(true);
    	update testDataSetup.opportunityList;
    	testAccountId = testDataSetup.accountList[0].id;
		
		List<CSM_Account_Plan_Template__c> testTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        System.assert(!testTemplates.isEmpty());
        testTemplate = testTemplates[0];
        
        List<CSM_Account_Plan__c> acctPlanList = CSM_TestDataUtility.createAccountPlan(testDataSetup.accountList, testTemplate.Id);
        System.assert(!acctPlanList.isEmpty());
        testAcctPlan = acctPlanList[0];		
	}
}