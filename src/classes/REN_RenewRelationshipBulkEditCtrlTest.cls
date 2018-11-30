@isTest
public with sharing class REN_RenewRelationshipBulkEditCtrlTest {
	
	public static Opportunity testOppty;
	public static List<Account> accList;
	public static REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
	
    	
    	
	static testMethod void testRenewalRelationshipsEdit(){
		try{
			createData();
			//REN_Constants.RENEWALRELATIONSHIP_BEFORE_TRIGGER = true;
			//REN_Constants.RENEWALRELATIONSHIP_AFTER_TRIGGER = true;
			Test.startTest();
	    	PageReference currPage = Page.REN_RenewalRelationshipBulkEdit;
	        Test.setCurrentPageReference(currPage);	        
	        ApexPages.CurrentPage().getParameters().put('OpptId', testOppty.Id); 			
	        ApexPages.StandardController sc = new ApexPages.StandardController(testOppty);
	        REN_RenewalRelationshipBulkEditCtrl controller = new REN_RenewalRelationshipBulkEditCtrl(sc);
	        controller.opptyId = testOppty.Id;	        
	        controller.appendedIds = renRelationObj.Id;
	        controller.helpParam = '';
	        controller.statusToUpdateTo = '';
	        controller.changeStatus();
	        Map<String, String> rrStatus = controller.getRRStatusOptions();
	        system.assert(rrStatus != null);
	        controller.cancel();
			List<REN_Renews_To__c> rrList = REN_RenewRelationshipDataAccess.getRenewalRelationshipForOppty(new Set<String>{testOppty.Id});
			//REN_Constants.RENEWALRELATIONSHIP_BEFORE_TRIGGER = true;
			//REN_Constants.RENEWALRELATIONSHIP_AFTER_TRIGGER = true;
			delete rrList;
			//REN_Constants.RENEWALRELATIONSHIP_BEFORE_TRIGGER = true;
			//REN_Constants.RENEWALRELATIONSHIP_AFTER_TRIGGER = true;
			undelete rrList;
			system.assert(rrList.get(0).Id != null);
			Test.stopTest();
		}
		catch(Exception e ){
    		system.debug('Exception : ' + e.getMessage());
        }
	} 
	
	static testMethod void testRenewRelationshipBusinessLayer(){
		createData();
		Test.startTest();
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	gridParams.accountId = accList.get(0).Id;
    	gridParams.opptyId = testOppty.Id;
    	inputWrapper.params = gridParams;
    	CSM_BusinessLayer businessLayer = new REN_RenewRelationshipBusinessLayer(inputWrapper);
    	CSM_GridResponseWrapper responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    	system.assert(responseWrapper.row != null);
    	system.assert(!responseWrapper.row.isEmpty());
    	system.assertEquals(responseWrapper.hasAction, false);
    	system.assertEquals(responseWrapper.hasCheckbox, true);
    	system.assertEquals(responseWrapper.hasDetail, false);
    	
		upsert renRelationObj; 
		businessLayer = new REN_RenewRelationshipBusinessLayer(inputWrapper);
    	responseWrapper = businessLayer.retrieveSObjectWrapperList();
    	system.assert(responseWrapper != null);
    	system.assert(responseWrapper.header != null);
    	system.assert(!responseWrapper.header.isEmpty());
    	system.assert(responseWrapper.row != null);
    	system.assert(!responseWrapper.row.isEmpty());
    	system.assertEquals(responseWrapper.hasAction, false);
    	system.assertEquals(responseWrapper.hasCheckbox, true);
    	system.assertEquals(responseWrapper.hasDetail, false);
    	
    	Test.stopTest();
		
	}
	
	public static void createData(){
		accList = CSM_TestDataUtility.createAccount(1);
	    system.assert(accList.get(0).Id != null);		
		//create renewal Relationship and attach it to this opportunity
		//Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
		testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=customPB.id,
		CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, REN_Earliest_Expiration_Date__c = System.Today() + 2);

		insert testOppty;
		Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;
		
		PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = customPB.id, UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
		insert price1;
		system.assert(price1.Id != null);

		system.assert(prod.Id != null);
		OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = testOppty.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
		insert opptyLineItem;

		Asset asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);
		asset.REN_Oppty_Line_Item_Id__c = opptyLineItem.Id;
		insert asset;

		renRelationObj = new REN_Renews_To__c();
		renRelationObj.Name = 'Ren-OPP';
		renRelationObj.REN_Asset__c = asset.Id;
		renRelationObj.REN_Renews_To__c = testOppty.Id;
		renRelationObj.REN_Quantity__c = 1;
		renRelationObj.REN_Total_Price__c = 100;
		renRelationObj.REN_Product__c = prod.Id;
		insert renRelationObj;				
	}
	
	static testMethod void testRebuild(){
		createData();
		
		List<OpportunityLineItem> OLILst = [Select id from OpportunityLineItem where OpportunityId =:testOppty.Id Limit 1];
		delete OLILst;
		List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
		fMappingList.add(REN_TestDataUtility.createFieldMapping('Renewal Relationship → Opportunity Line Item', 'DOUBLE', 'Quantity', 'REN_Quantity__c', 'OpportunityLineItem', 'REN_Renews_To__c', false, ''));
        //fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'UnitPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
        fMappingList.add(REN_TestDataUtility.createFieldMapping('Renewal Relationship → Opportunity Line Item', 'DOUBLE', 'TotalPrice', 'REN_Total_Price__c', 'OpportunityLineItem', 'REN_Renews_To__c', false, ''));
        REN_FieldMappingsDataAccess.upsertFieldMappings(fMappingList);
        PageReference currPage = Page.REN_RenewalRelationshipBulkEdit;
        Test.setCurrentPageReference(currPage);	        
        ApexPages.CurrentPage().getParameters().put('OpptId', testOppty.Id); 
		ApexPages.StandardController sc = new ApexPages.StandardController(testOppty);
		REN_RenewalRelationshipBulkEditCtrl objRRBEC = new REN_RenewalRelationshipBulkEditCtrl(sc);
        objRRBEC.appendedIds = renRelationObj.id + '-';
        Test.startTest();
        objRRBEC.rebuild();
        Test.stopTest();
    	OLILst =  [Select id from OpportunityLineItem where OpportunityId =:testOppty.Id Limit 1];
    	system.assert(!OLILst.isEmpty());
	}   	
	
	static testMethod void test_SplitConsolidate(){
		createData();
		List<OpportunityLineItem> OLILst = [Select id from OpportunityLineItem where OpportunityId =:testOppty.Id Limit 1];
		delete OLILst;
		List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
		fMappingList.add(REN_TestDataUtility.createFieldMapping('Renewal Relationship → Opportunity Line Item', 'DOUBLE', 'Quantity', 'REN_Quantity__c', 'OpportunityLineItem', 'REN_Renews_To__c', false, ''));
        //fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'UnitPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
        fMappingList.add(REN_TestDataUtility.createFieldMapping('Renewal Relationship → Opportunity Line Item', 'DOUBLE', 'TotalPrice', 'REN_Total_Price__c', 'OpportunityLineItem', 'REN_Renews_To__c', false, ''));
        system.assert(!fMappingList.isEmpty());
        REN_FieldMappingsDataAccess.upsertFieldMappings(fMappingList);
        PageReference currPage = Page.REN_RenewalRelationshipBulkEdit;
        Test.setCurrentPageReference(currPage);	        
        ApexPages.CurrentPage().getParameters().put('OpptId', testOppty.Id); 
		ApexPages.StandardController sc = new ApexPages.StandardController(testOppty);
		REN_RenewalRelationshipBulkEditCtrl objRRBEC = new REN_RenewalRelationshipBulkEditCtrl(sc);
        objRRBEC.appendedIds = renRelationObj.id + '-';
        Test.startTest();
            objRRBEC.disableConsolidate = 'true';
	        objRRBEC.disableSplit = true;
	        
	 		objRRBEC.hasValidStageForConsolidate = true;
	        objRRBEC.validateConsolidate();       
	        
	        objRRBEC.hasValidStageForConsolidate = false;
	        objRRBEC.validateConsolidate();       
	        
	        objRRBEC.hasValidStageForSplit = true;
	        objRRBEC.validateSplit();
	        
	        objRRBEC.hasValidStageForSplit = false;
	        objRRBEC.validateSplit();
	        
	        objRRBEC.saveRRColumnsToUserPreference();
         Test.stopTest();
	}
	
	public static testmethod void testRebuildWithSimplified(){
        
        accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList.get(0).Id != null);       
        //create renewal Relationship and attach it to this opportunity
        //Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=customPB.id,
        CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, REN_Earliest_Expiration_Date__c = System.Today() + 2);

        insert testOppty;
        Product2 prod = REN_TestDataUtility.createProduct(1);
        insert prod;
        
        
        
        REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
        renRelationObj.Name = 'Ren-OPP';
        //renRelationObj.REN_Asset__c = asset.Id;
        renRelationObj.REN_Renews_To__c = testOppty.Id;
        renRelationObj.REN_Quantity__c = 1;
        renRelationObj.REN_Total_Price__c = 100;
        renRelationObj.REN_Product__c = prod.Id;
        //renRelationObj.REN_Renewal_Product_Line_Id__c = opptyLineItem.Id;
        insert renRelationObj;
        
        SS_Constants.isSimplifiedDataModelEnabled = true;
        PageReference currPage = Page.REN_RenewalRelationshipBulkEdit;
        Test.setCurrentPageReference(currPage);
        ApexPages.CurrentPage().getParameters().put('OpptId', testOppty.Id); 
        ApexPages.StandardController sc = new ApexPages.StandardController(testOppty);
        
        
        SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
        productIdSetting.Renewal_Amount_Product_Id__c = prod.Id;
        
        upsert productIdSetting;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = customPB.id, UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
        insert price1;
        system.assert(price1.Id != null);
        
        REN_RenewalRelationshipBulkEditCtrl objRRBEC = new REN_RenewalRelationshipBulkEditCtrl(sc);
        objRRBEC.rebuild();
        delete renRelationObj;
        objRRBEC.rebuild();
        
    }
    
}