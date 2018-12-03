@isTest
public with sharing class REN_RRTriggerHandlerTest {
	     
	@testSetup static void setup() { 
	    List<Account> accList = CSM_TestDataUtility.createAccount(1);
	    system.assert(accList.get(0).Id != null);		
		
		Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
		Opportunity oppObj = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=customPB.id,
		                            CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, 
		                            REN_Earliest_Expiration_Date__c = System.Today() + 2);
		insert oppObj;
		
		Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;
	
		PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = customPB.id, UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
		insert price1;
		system.assert(price1.Id != null);
		
		OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = oppObj.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
		insert opptyLineItem;

	    Asset asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);
		asset.REN_Oppty_Line_Item_Id__c = opptyLineItem.Id;
		insert asset;
        
        insert new SS_License__c(Renew__c = true);

        REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
        renRelationObj.Name = 'Ren-OPP';
        renRelationObj.REN_Asset__c = asset.Id;
        renRelationObj.REN_Renews_To__c = oppObj.Id;
        renRelationObj.REN_Quantity__c = 1;
        renRelationObj.REN_Total_Price__c = 100;
        renRelationObj.REN_Product__c = prod.Id;
        //renRelationObj.REN_Renewal_Product_Line_Id__c = opptyLineItem.Id;
        insert renRelationObj;

        REN_Value_Mapping__c obj = new REN_Value_Mapping__c();
		obj.REN_Record_Key__c = REN_Constants.REN_RLI_DATE_MAP;
		obj.REN_Value__c = 'ren_new_end_date__c';
		insert obj;
        
        REN_Field_Mappings__c fm1 = getFieldMappingRec('STRING', 'Name', 'Name', 'ServiceContract', 'Opportunity', true, '');
        REN_Field_Mappings__c fm2 = getFieldMappingRec('CURRENCY', 'UnitPrice', 'UnitPrice', 'ContractLineItem', 'OpportunityLineItem', true, '');
        REN_Field_Mappings__c fm3 = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'ContractLineItem', 'OpportunityLineItem', true, '');
        REN_Field_Mappings__c fm4 = getFieldMappingRec('DATE', 'CloseDate', 'EndDate', 'Opportunity', 'ServiceContract', true, '');
        REN_Field_Mappings__c fm5 = getFieldMappingRec('STRING', 'Name', 'Name', 'Opportunity', 'ServiceContract', true, '');
        REN_Field_Mappings__c fm6 = getFieldMappingRec('BOOLEAN', 'IsPrivate', 'false', 'Opportunity', 'ServiceContract', true, '');
        REN_Field_Mappings__c fm7 = getFieldMappingRec('PICKLIST', 'StageName', 'Status', 'Opportunity', 'ServiceContract', true, '');
        REN_Field_Mappings__c fm8 = getFieldMappingRec('DOUBLE', 'Quantity', 'REN_Quantity__c', 'OpportunityLineItem',REN_Constants.OBJ_REN_RENEWS_TO, true, '');
        REN_Field_Mappings__c fm9 = getFieldMappingRec('DOUBLE', 'REN_Previous_Price__c', 'UnitPrice', REN_Constants.OBJ_REN_RENEWS_TO,'OpportunityLineItem', true, '');
        REN_Field_Mappings__c fm10 = getFieldMappingRec('DOUBLE','UnitPrice', 'REN_Previous_Price__c', 'OpportunityLineItem',REN_Constants.OBJ_REN_RENEWS_TO, true, '');
    
        List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c> ();
        fMappingList.add(fm1);
        fMappingList.add(fm2);
        fMappingList.add(fm3);
        fMappingList.add(fm4);
        fMappingList.add(fm5);
        fMappingList.add(fm6);
        fMappingList.add(fm7);
        fMappingList.add(fm8);
        fMappingList.add(fm9);
        fMappingList.add(fm10);
        insert fMappingList;
        
 	}
    
	static testMethod void insertRRTest() {
		List<Asset>  assetList = [select id from asset];
		List<opportunity> oppList = [select id from opportunity];
		List<OpportunityLineItem> oliList = [select id from OpportunityLineItem];
		List<Product2> prodList = [select id from  Product2];
		Test.startTest();
			REN_Renews_To__c renRelationObj1 = new REN_Renews_To__c();
            renRelationObj1.Name = 'Ren-OPP';
            renRelationObj1.REN_Asset__c = assetList[0].Id;
            renRelationObj1.REN_Renews_To__c = oppList[0].Id;
            renRelationObj1.REN_Quantity__c = 1;
            renRelationObj1.REN_Previous_Price__c = 100;
            renRelationObj1.REN_Total_Price__c = 100;
            renRelationObj1.REN_Product__c = prodList[0].Id;
           // renRelationObj1.REN_Renewal_Product_Line_Id__c = oliList[0].Id;
            CSM_TriggerManager.enableFirstTrigger();
            insert renRelationObj1; 
            system.assert(renRelationObj1 != null);		
		Test.stopTest();
	}
     
    static testMethod void insertRRForSDMTest() {
           List<Asset>  assetList = [select id from asset];
          List<opportunity> oppList = [select id from opportunity];
          List<OpportunityLineItem> oliList = [select id from OpportunityLineItem];
          List<Product2> prodList = [select id from  Product2];
            
           Test.startTest();
        		List<Product2> prod = [select id,name from Product2];
        	    system.assert(prod != null);	
        		SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
        		productIdSetting.Renewal_Amount_Product_Id__c = prod[0].Id;
        		upsert productIdSetting;
           		SS_Constants.isSimplifiedDataModelEnabled = true;
        	    REN_Renews_To__c renRelationObj1 = new REN_Renews_To__c();
                renRelationObj1.Name = 'Ren-OPP';
                renRelationObj1.REN_Asset__c = assetList[0].Id;
                renRelationObj1.REN_Renews_To__c = oppList[0].Id;
                renRelationObj1.REN_Quantity__c = 1;
                renRelationObj1.REN_Previous_Price__c = 100;
                renRelationObj1.REN_Total_Price__c = 100;
                renRelationObj1.REN_Product__c = prodList[0].Id;
                //renRelationObj1.REN_Renewal_Product_Line_Id__c = oliList[0].Id;
                system.debug('@@@ 9' + renRelationObj1);
                CSM_TriggerManager.enableFirstTrigger();
                insert renRelationObj1; 
           
		
            Test.stopTest();
    }
    
	static testMethod void updateRRTest() {
		Test.startTest();  
        	List<REN_Renews_To__c> rliList = [select id,REN_Is_End_Date_Modified__c,REN_End_Date__c,REN_Total_Price__c from REN_Renews_To__c];
        	system.assert(rliList != null);		
        	Update rliList;
        Test.stopTest();
    }
    
    static testMethod void updateRRForSDMTest() {
		Test.startTest();  
        	SS_Constants.isSimplifiedDataModelEnabled = true;
        	List<REN_Renews_To__c> rliList = [select id,REN_Is_End_Date_Modified__c,REN_End_Date__c,REN_Total_Price__c from REN_Renews_To__c];
        	system.assert(rliList != null);
        	Update rliList;
        Test.stopTest();
        
    }
    
	static testMethod void deleteRRTest() {
    	Test.startTest();  
        	List<REN_Renews_To__c> rliList = [select id,REN_Is_End_Date_Modified__c,REN_End_Date__c,REN_Total_Price__c from REN_Renews_To__c];
        	system.assert(rliList != null);		
        	delete rliList;
            CSM_TriggerManager.enableFirstTrigger();
            undelete  rliList;
		Test.stopTest();
    }
    
    static testMethod void simplifiedOpportunityTest() {
		Test.startTest();  
        	List<Opportunity> oppList = [select id ,Name,PriceBook2Id,REN_Is_CLM_Renewal__c From Opportunity where name = 'TestOpp'];
        	system.assert(oppList != null);		
            List<Product2> prod = [select id,name from Product2];
        	
        	SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
        	productIdSetting.Renewal_Amount_Product_Id__c = prod[0].Id;
        	upsert productIdSetting;
            Map<id,Opportunity> oppMap = new Map<id,Opportunity>(oppList);
        	REN_RRSimplifiedTriggerHelper.simplifiedOpportunity(oppMap.keySet());
        	Test.stopTest();        
    }
    
    static testMethod void deleteRRForSDMTest() {
    	Test.startTest();
            List<Product2> prod = [select id,name from Product2];
        	system.assert(prod != null);	
        	SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
        	productIdSetting.Renewal_Amount_Product_Id__c = prod[0].Id;
        	upsert productIdSetting;
        	SS_Constants.isSimplifiedDataModelEnabled = true;
        	List<REN_Renews_To__c> rliList = [select id,REN_Is_End_Date_Modified__c,REN_End_Date__c,REN_Total_Price__c from REN_Renews_To__c];
        	delete rliList;
            CSM_TriggerManager.enableFirstTrigger();
            undelete  rliList;
		Test.stopTest();
    }
    
	static REN_Field_Mappings__c getFieldMappingRec(String dataType, String toName, String fromName, String toObject, String fromObject, 
                                                    Boolean isRequired, String defaultValue){
		REN_Field_Mappings__c fm = new REN_Field_Mappings__c();
        fm.REN_Field_Data_Type__c = dataType;
        fm.REN_To_Field_API_Name__c = toName;
        fm.REN_From_Field_API_Name__c = fromName;
        fm.REN_To_Object_API_Name__c = toObject;
        fm.REN_From_Object_Api_Name__c = fromObject;
        fm.REN_Is_Required__c = isRequired;
        fm.REN_Default_Value__c = defaultValue;
        return fm;
    }
}