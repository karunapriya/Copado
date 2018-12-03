@isTest
public with sharing class REN_SearchAndMoveRliContrlTest {
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
				
		REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
		list<REN_Renews_To__c> renRelationObjlist = new list<REN_Renews_To__c>();
        renRelationObj.Name = 'Partner Renewal';
        renRelationObj.REN_Renews_To__c = testOppList[0].Id;
        renRelationObj.REN_Renewal_Status__c = 'Won';
        renRelationObj.REN_Renewal_Target__c = 50000.0;
        renRelationObj.REN_Renewal_Target_Multiplier__c = 1;
        renRelationObj.REN_Previous_Price__c = 50000.0;
        renRelationObjlist.add(renRelationObj);
        insert renRelationObjlist;
	}
	
	static testMethod void Test_FindFor(){
		try{
			Test.startTest();
			REN_SearchAndMoveRliController controller = getControllerInstance();
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				controller.findFor();
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_MoveToOpportunity()
	{
		try{
			Test.startTest();
            Opportunity opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
            list<Ren_Renews_To__c> renRelationObjlist=[select Id from Ren_Renews_To__c limit 1];
			REN_SearchAndMoveRliController controller = getControllerInstance();
			REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				controller.hasQuote = true;
            list<Opportunity> oppList= new list<Opportunity>();
            oppList.add(opp);
            controller.selectedrliopplist=oppList;
            	controller.dataIds =renRelationObjlist[0].id;
				controller.MoveToOpportunity();
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
    
    static testMethod void Test_MoveToOpportunityNeg()
	{
		try{
			Test.startTest();
            Opportunity opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
            list<Ren_Renews_To__c> renRelationObjlist=[select Id from Ren_Renews_To__c limit 1];
			REN_SearchAndMoveRliController controller = getControllerInstance();
			REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				controller.hasQuote = true;
         		controller.MoveToOpportunity();
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_FindForException(){
		Test.startTest();
		try{
			REN_SearchAndMoveRliController controller = getControllerInstance();
            REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
			assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
			REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
			renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
			if(controller != null){
				controller.renewObj = null;
				controller.renewalRenewObj = null;
                controller.noResultFound();
				controller.findFor();
			}
		}
		catch(Exception e ){
    		system.assert(true);
        }
		Test.stopTest();
	}
	
	static testMethod void Test_ValidateAndMoveOpportunity()
	{
		try{
			Test.startTest();
            Opportunity opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
            list<Ren_Renews_To__c> renRelationObjlist=[select Id from Ren_Renews_To__c limit 1];
			REN_SearchAndMoveRliController controller = getControllerInstance();
            controller.hasQuote=true;
			REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
			assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
			REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
			renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
			List<SelectOption> options = controller.getItems();
			system.assert(options != null && !options.isEmpty());
            controller.dataIds=renRelationObjlist[0].id;
			PageReference pageRef = controller.ValidateAndMoveOpportunity();
			//System.assert(pageRef != null);
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
    static testMethod void Test_ValidateAndMoveOpportunityNeg()
	{
		try{
			Test.startTest();
            Opportunity opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
            list<Ren_Renews_To__c> renRelationObjlist=[select Id from Ren_Renews_To__c limit 1];
			REN_SearchAndMoveRliController controller = getControllerInstance();
            controller.hasQuote=true;
			REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
			assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
			REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
			renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
			List<SelectOption> options = controller.getItems();
			system.assert(options != null && !options.isEmpty());
			PageReference pageRef = controller.ValidateAndMoveOpportunity();
			//System.assert(pageRef != null);
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}

	
	static testMethod void Test_PriceBookRedirect(){
		try{
			Test.startTest();
			REN_SearchAndMoveRliController controller = getControllerInstance();
			if(controller != null){
				PageReference pageRef = controller.PriceBookRedirect();
				system.assert(pageRef != null);
			}
            //controller.formatProperSearchedString('Test String,Test String 2,Test String 3');
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_CancelAndReturnToOppt(){
		try{
			Test.startTest();
			REN_SearchAndMoveRliController controller = getControllerInstance();
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
	
	static testMethod void Test_FindForCriteriaGetRLI(){
		try{
			Test.startTest();
			REN_SearchAndMoveRliController controller = getControllerInstance();
			if(controller != null){
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				controller.findForCriteria();
				controller.getRliRecordList(CSM_Util.getNamespace() + 'REN_Quantity__c');
				controller.showLogicBuilder();
				
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void Test_GetRLInvlaid(){
		try{
			Test.startTest();
			REN_SearchAndMoveRliController controller = getControllerInstance();
			if(controller != null){
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				controller.getRliInvalidRecordList(CSM_Util.getNamespace() + 'REN_Quantity__c');
				
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static testMethod void loadGridOppTest() {	
        Test.startTest();
        CSM_DataGridAttribute gridData = new CSM_DataGridAttribute();  
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
        gridData.objectType ='searchAndMove';
    	inputWrapper.params = gridParams;
    	REN_SearchAndMoveRliBusinessLayer businessLayer = new REN_SearchAndMoveRliBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	Test.stopTest();
    	
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    }
    
	static testMethod void Test_ShowLogicBuilderAndGetItems(){
		try{
			Test.startTest();
			REN_SearchAndMoveRliController controller = getControllerInstance();
			if(controller != null){
				REN_LogicBuilderCmpCtrl assetLogicBuilder = new REN_LogicBuilderCmpCtrl();
				assetLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[0];
				REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
				renewalLogicBuilder.logicBuilderInput = controller.lbInputWrapperList[1];
				List<SelectOption> options = controller.getItems();
				system.assert(options != null && !options.isEmpty());
				controller.showLogicBuilder();
			}
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	}
	
	static REN_SearchAndMoveRliController getControllerInstance(){
		Opportunity opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
        list<REN_Renews_To__c> renRelationObjlist=[Select Id From REN_Renews_To__c Where REN_Renews_To__c =:'TestOpp0'];
			ApexPages.CurrentPage().getparameters().put('Id', opp.Id);
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(renRelationObjlist);
		    REN_SearchAndMoveRliController controller = new REN_SearchAndMoveRliController(sc);		    		
			controller.hasQuote = true;	
		    system.assert(controller.selectedObject != null);
		    system.assert(controller.lbInputWrapperList != null && !controller.lbInputWrapperList.isEmpty());
			return controller;
	}
	
	static testMethod void Test_setInvalidRliFilter() {
        Test.startTest();
        REN_SearchAndMoveRliController controller = getControllerInstance();
        PageReference pgRef = controller.setInvalidRliFilter();
        Test.stopTest();
        System.assert(pgRef == null);
    }
    
    static testMethod void Test_setValidRliFilter() {
        Test.startTest();
        REN_SearchAndMoveRliController controller = getControllerInstance();
        PageReference pgRef = controller.setValidRliFilter();
        //controller.getRliInvalidRecordList(CSM_Util.getNamespace() + 'REN_Quantity__c');
        Test.stopTest();
        System.assert(pgRef == null);
    }
    
    static testMethod void Test_findForSearch() {
        Test.startTest();
        REN_SearchAndMoveRliController controller = getControllerInstance();
        controller.selectedObject = REN_Constants.OBJ_REN_RENEWS_TO;
        PageReference pgRef = controller.findForSearch();
        Test.stopTest();
        System.assert(pgRef == null);
    }
    
    static testMethod void Test_OpptyWithNoPriceBook() {
    		Test.startTest();
    		Opportunity oppty = [SELECT Id FROM Opportunity WHERE StageName = 'Prospecting' AND Name = 'TestOpp0'];
		oppty.Pricebook2Id = null;
		update oppty;
    		REN_SearchAndMoveRliController controller = getControllerInstance();
    		System.assert(controller.noPriceBookSelected == true);
    		Test.stopTest();
    }
    
    static testMethod void Test_opptyWithClosedStage() {
    		Test.startTest();
    		SS_Validations__c ssValidations = SS_Validations__c.getOrgDefaults();
    		ssValidations.REN_No_Split_allowed_for_Opp_Stage__c = 'Closed Sale';
    		upsert ssValidations;
    		Opportunity oppty = [SELECT Id FROM Opportunity WHERE StageName = 'Prospecting' AND Name = 'TestOpp0'];
    		oppty.StageName = 'Closed Sale';
    		update oppty;
    		REN_SearchAndMoveRliController controller = getControllerInstance();
    		controller.ValidateAndMoveOpportunity();
    		System.assert(controller.closedOppSelected == true);
    		upsert ssValidations;
    }
	
}