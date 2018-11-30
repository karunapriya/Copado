@isTest(SeeAllData=false)
private class REN_CreateOpptyFromAssetsControllerTest {	

	static List<Asset> assetList;
	static List<Product2> productList;
	static List<PricebookEntry> pbEntryList;
	static String assetIds = '';
	static List<Account> accountList;
	static testMethod void Test_Init_Positive(){
		Test.startTest();
		setUp();
		PageReference pageRef = Page.REN_CreateOpptyFromAssets;
		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put('assetIds', assetIds);
		REN_CreateOpptyFromAssetsController controller = new REN_CreateOpptyFromAssetsController();
		system.assert(controller.renewOpportunity != null);
		system.assert(!controller.opliWrapperList.isEmpty());
		Test.stopTest();
	}
	
	static testMethod void Test_Init_Negative(){
		Test.startTest();
		setUp();
		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser){
			PageReference pageRef = Page.REN_CreateOpptyFromAssets;
			Test.setCurrentPageReference(pageRef);
			pageRef.getParameters().put('assetIds', assetIds);
			REN_CreateOpptyFromAssetsController controller = new REN_CreateOpptyFromAssetsController();
			system.assert(controller.renewOpportunity != null);
			system.assert(controller.opliWrapperList == null);
    	}
		Test.stopTest();
	}
	
	static testMethod void Test_Save_Positive(){
		Test.startTest();
		setUp();
		PageReference pageRef = Page.REN_CreateOpptyFromAssets;
		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put('assetIds', assetIds);
		REN_CreateOpptyFromAssetsController controller = new REN_CreateOpptyFromAssetsController();
		controller.renewOpportunity.Name = 'TestOpp';
		controller.renewOpportunity.Probability = 10;
		controller.renewOpportunity.StageName = 'Prospecting';
		controller.renewOpportunity.AccountId = accountList.get(0).Id;
		controller.renewOpportunity.CloseDate = Date.today();
		controller.renewOpportunity.Pricebook2Id = Test.getStandardPricebookId();
		PageReference saveRef = controller.save();
		system.assert(saveRef != null);
		system.assert(controller.renewOpportunity != null);
		system.assert(controller.opliWrapperList != null);
		Test.stopTest();
	}
	
	static testMethod void Test_Save_Negative(){
		Test.startTest();
		setUp();
		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser){
			PageReference pageRef = Page.REN_CreateOpptyFromAssets;
			Test.setCurrentPageReference(pageRef);
			pageRef.getParameters().put('assetIds', assetIds);
			REN_CreateOpptyFromAssetsController controller = new REN_CreateOpptyFromAssetsController();
			PageReference saveRef = controller.save();
			system.assert(saveRef == null);
			system.assert(controller.renewOpportunity != null);
			system.assert(controller.opliWrapperList == null);
    	}
		Test.stopTest();
	}
	
	static testMethod void Test_Cancel(){
		Test.startTest();
		setUp();
		PageReference pageRef = Page.REN_CreateOpptyFromAssets;
		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put('assetIds', assetIds);
		REN_CreateOpptyFromAssetsController controller = new REN_CreateOpptyFromAssetsController();
		pageRef = controller.cancel();
		system.assert(pageRef != null);
		system.assert(controller.renewOpportunity != null);
		system.assert(controller.opliWrapperList != null);
		Test.stopTest();
	}
	
	static void setUp(){
		assetList = new List<Asset>();
		productList = new List<Product2>();
		accountList = CSM_TestDataUtility.createAccount(1);
		system.assert(accountList.get(0).Id != null);
		for(Integer i=0; i < 5; i++){
			productList.add(REN_TestDataUtility.createProduct(i));
		}
		insert productList;
		pbEntryList = new List<PricebookEntry>();
		for(Product2 prod : productList){
			assetList.add(REN_TestDataUtility.createAsset(accountList.get(0).Id, prod.Id));
			pbEntryList.add(REN_TestDataUtility.createPBEntry(prod.Id));
		}
		insert assetList;
		insert pbEntryList;
		for(Asset asset : assetList){
			if(String.isNotBlank(assetIds)){
				assetIds += '-'+asset.Id;
			}else{
				assetIds += asset.Id;
			}
		}
		
		List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
        renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
        upsert renewConfigurationList;
		system.assert(renewConfigurationList != null);
		
		List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
		/*
		fMappingList.add(REN_TestDataUtility.createFieldMapping(renewConfig.Id, 'DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'Asset', true, ''));
		fMappingList.add(REN_TestDataUtility.createFieldMapping(renewConfig.Id, 'DOUBLE', 'UnitPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
		fMappingList.add(REN_TestDataUtility.createFieldMapping(renewConfig.Id, 'DOUBLE', 'TotalPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
		*/
		fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'Asset', true, ''));
		fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'UnitPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
		fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'TotalPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
		insert fMappingList;
	}
}