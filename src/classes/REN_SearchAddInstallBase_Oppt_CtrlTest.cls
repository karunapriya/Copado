@isTest
public with sharing class REN_SearchAddInstallBase_Oppt_CtrlTest {
	static void setUpData() {
		system.assert(true);
	}
	/*This test class deprecated under US3293
		
	@testSetup 
	static void setUpData() {
		List<Account> accList = CSM_TestDataUtility.createAccount(1);
		system.assert(accList.get(0).Id != null);
		Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;
		system.assert(prod.Id != null);
		Id pricebookId = Test.getStandardPricebookId();
		PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = prod.Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        List<Opportunity> testOppList = new List<Opportunity>();
		for (Integer i = 0; i < 1; i++) {
			testOppList.add(new Opportunity(Name = 'TestOpp' + i, StageName = 'Prospecting',
			CloseDate = System.Today(), AccountId = accList[0].Id, Type = 'New Customer', Pricebook2Id = pricebookId));
		}
		insert testOppList;
		Asset asset = new Asset(AccountId = accList[0].id, Product2Id = prod.id, Name = 'Test Asset', Price = 20.00, Quantity = 2);
		insert asset;
		system.assert(asset.Id != null);
		
		ServiceContract contract = new ServiceContract(AccountId = accList[0].id, Name = 'Test Contract', Pricebook2Id = pricebookId);
		insert contract;
		system.assert(contract.Id != null);
		
		ContractLineItem contractLineItem = new ContractLineItem(AssetId = asset.id, ServiceContractId = contract.id,PricebookEntryId = standardPrice.id, UnitPrice = 20.00, Quantity = 2);
		insert contractLineItem;
		system.assert(contractLineItem.Id != null);
		
		List<SObject> serviceContractObjList = CSM_TestDataUtility.createServiceContract(2,accList[0].id);
 		system.debug('\n\n serviceContractObjList ::' + serviceContractObjList);
 		
	}
	
	static testMethod void Test_ShowLogicBuilderAndGetItems(){
		try{
			Test.startTest();
			REN_SearchAddInstallBase_Oppt_Controller controller = getControllerInstance();
			if(controller != null){
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[2];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				controller.showLogicBuilder();
				if(controller.isEntitlementEnabled){
					controller.selectedObject = REN_Constants.OBJ_CONTRACT_LINE_ITEM;
					REN_LogicBuilderCmpCtrl scLogicBuilder = new REN_LogicBuilderCmpCtrl();
					scLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
					controller.showLogicBuilder();
					
				}
				
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_FindFor(){
		try{
			Test.startTest();
			REN_SearchAddInstallBase_Oppt_Controller controller = getControllerInstance();
			if(controller != null){
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[2];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				// Asset and renewal criteria are empty
				controller.findFor();
				system.assert(controller.criteria != null);
				controller.renewalRenewObj.REN_Filter_Criteria__c = 'REN_Status__c != \'Open\'';
				// Asset criteria is empty, renewal is set criteria
				controller.findFor();
				controller.renewObj.REN_Filter_Criteria__c = 'Status != \'Open\'';
				controller.renewalRenewObj.REN_Filter_Criteria__c = '';
				// Asset and renewal is set criteria
				controller.findFor();
				system.assert(controller.criteria != null);
				controller.renewObj.REN_Filter_Criteria__c = 'Status != \'Open\'';
				controller.renewalRenewObj.REN_Filter_Criteria__c = 'REN_Status__c != \'Open\'';
				// Asset is set criteria and renewal is empty
				controller.findFor();
				system.assert(controller.criteria != null);
				if(controller.isEntitlementEnabled){
					controller.selectedObject = REN_Constants.OBJ_CONTRACT_LINE_ITEM;
					REN_LogicBuilderCmpCtrl scLogicBuilder = new REN_LogicBuilderCmpCtrl();
					scLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
					controller.findFor();
					system.assert(controller.criteria != null);
				}
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_FindForException(){
		Test.startTest();
		try{
			REN_SearchAddInstallBase_Oppt_Controller controller = getControllerInstance();
			if(controller != null){
				controller.renewObj = null;
				controller.renewalRenewObj = null;
				controller.findFor();
			}
		}
		catch(Exception e ){
    		system.assert(true);
        }
		Test.stopTest();
	}
	
	static testMethod void Test_FindForCriteria(){
		try{
			Test.startTest();
			REN_SearchAddInstallBase_Oppt_Controller controller = getControllerInstance();
			if(controller != null){
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[2];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				controller.showLogicBuilder();
				if(controller.isEntitlementEnabled){
					controller.selectedObject = REN_Constants.OBJ_CONTRACT_LINE_ITEM;
					REN_LogicBuilderCmpCtrl scLogicBuilder = new REN_LogicBuilderCmpCtrl();
					scLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
					controller.findForCriteria();
				}
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_CancelAndReturnToOppt(){
		try{
			Test.startTest();
			REN_SearchAddInstallBase_Oppt_Controller controller = getControllerInstance();
			if(controller != null){
				PageReference pageRef = controller.cancelAndReturnToOppt();
				system.assert(pageRef != null);
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_AddToOpportunityWithAsset()
	{
		try{
			Test.startTest();
			List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
			fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_OPPT_LINE_TO_ASSET, 'DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'Asset', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_OPPT_LINE_TO_ASSET, 'DOUBLE', 'UnitPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_OPPT_LINE_TO_ASSET, 'DOUBLE', 'TotalPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
		
			REN_FieldMappingsDataAccess.upsertFieldMappings(fMappingList);
			
			REN_SearchAddInstallBase_Oppt_Controller controller = getControllerInstance();
			Asset assetRecord = [select id from asset where name = 'Test Asset'];
			List<sObject> sObj = new List<sObject>();
			
		
			
			if(controller != null){
				controller.dataIds = assetRecord.id;
				controller.selectedObject = REN_Constants.OBJ_ASSET;
				PageReference pageRef = controller.addToOpportunity();
				System.assert(pageRef != null);
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_AddToOpportunity(){
		try{
			Test.startTest();
			List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
			fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY, 'DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'ContractLineItem', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY, 'STRING', 'Description', '', 'OpportunityLineItem', 'ContractLineItem', true, 'Test Data'));
			fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'Asset', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'UnitPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'TotalPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
            REN_FieldMappingsDataAccess.upsertFieldMappings(fMappingList);
			REN_SearchAddInstallBase_Oppt_Controller controller = getControllerInstance();
			Asset assetRecord = [select id from asset where name = 'Test Asset'];
			List<sObject> sObj = new List<sObject>();
			if (UserInfo.isMultiCurrencyOrganization() && CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT)){
				String queryStr = 'select id from contractlineitem where assetid = :assetRecord.id';
				sObj = Database.query(queryStr);
			}
			if(controller != null){
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[2];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				//Call the add to opportunity method here.
				controller.dataIds = assetRecord.id;
				PageReference pageRef = controller.addToOpportunity();
				controller.selectedObject = REN_Constants.OBJ_CONTRACT_LINE_ITEM;
				pageRef = controller.addToOpportunity();
				if(UserInfo.isMultiCurrencyOrganization()){
					controller.selectedObject = REN_Constants.OBJ_CONTRACT_LINE_ITEM;
					REN_LogicBuilderCmpCtrl scLogicBuilder = new REN_LogicBuilderCmpCtrl();
					controller.dataIds = (String) sObj[0].get('id');
					pageRef = controller.addToOpportunity();
				}
				controller.addToOpportunity();
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_AddToOpportunity_Negative(){
		try{
			User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
			Test.startTest();
				REN_SearchAddInstallBase_Oppt_Controller controller = getControllerInstance();
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[2];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				system.runas(restrictedUser) {
					controller.dataIds = String.valueOf(asset.id);
					PageReference pageRef = controller.addToOpportunity();
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static REN_SearchAddInstallBase_Oppt_Controller getControllerInstance(){
		Opportunity opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
		REN_SearchAddInstallBase_Oppt_Controller controller;
		if(opp != null){
			ApexPages.CurrentPage().getparameters().put('Id', opp.Id);
		    ApexPages.StandardController sc = new ApexPages.standardController(opp);
		    controller = new REN_SearchAddInstallBase_Oppt_Controller(sc);
		    system.assert(controller.selectedObject != null);
		    system.assert(controller.lbInputWrapperList != null && !controller.lbInputWrapperList.isEmpty());
		}
		return controller;
	} */
}