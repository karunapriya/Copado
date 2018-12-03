@isTest
private class REN_AssetTriggerHandlerTest {
    
    static testMethod void testUpdateAsset() {
        SS_License__c SS_License = new SS_License__c();
        SS_License.Renew__c = true;
        insert SS_License;
        REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
        testDataSetup.createRenewConfigurations();
        testDataSetup.renewDataSetup(1, 1, 1);
        REN_Renew_Configuration__c config = testDataSetup.renewConfigurationMap.get(REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT);
        List<REN_Line_Criteria__c> lineCriteriaList = new List<REN_Line_Criteria__c>();
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 1, RLM_Field_Type__c = CSM_Constants.TYPE_STRING, RLM_Field_Name__c = 'Name', RLM_Operator__c = '=', RLM_Values__c = 'Name', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 2, RLM_Field_Type__c = CSM_Constants.TYPE_STRING, RLM_Field_Name__c = 'Name', RLM_Operator__c = '!=', RLM_Values__c = 'Name', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 3, RLM_Field_Type__c = CSM_Constants.TYPE_STRING, RLM_Field_Name__c = 'Name', RLM_Operator__c = 'LIKE', RLM_Values__c = 'Name', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 4, RLM_Field_Type__c = CSM_Constants.TYPE_STRING, RLM_Field_Name__c = 'Name', RLM_Operator__c = 'ALL', RLM_Values__c = 'Name', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 5, RLM_Field_Type__c = CSM_Constants.TYPE_INTEGER, RLM_Field_Name__c = 'Quantity', RLM_Operator__c = '=', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 6, RLM_Field_Type__c = CSM_Constants.TYPE_CURRENCY, RLM_Field_Name__c = 'Price', RLM_Operator__c = '!=', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 7, RLM_Field_Type__c = CSM_Constants.TYPE_CURRENCY, RLM_Field_Name__c = 'Price', RLM_Operator__c = '<=', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 8, RLM_Field_Type__c = CSM_Constants.TYPE_CURRENCY, RLM_Field_Name__c = 'Price', RLM_Operator__c = '>=', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 9, RLM_Field_Type__c = CSM_Constants.TYPE_CURRENCY, RLM_Field_Name__c = 'Price', RLM_Operator__c = '<', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =10, RLM_Field_Type__c = CSM_Constants.TYPE_CURRENCY, RLM_Field_Name__c = 'Price', RLM_Operator__c = '>', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =11, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '=', RLM_Is_Specific_Date__c = true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =12, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '!=', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =13, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '>', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =14, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '>=', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =15, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '<', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =16, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '<=', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =17, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = 'ALL', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =18, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'Name', RLM_Operator__c = 'IN', RLM_Values__c = 'Name', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        insert lineCriteriaList;
        system.assert(lineCriteriaList != null);
        
        config.RLM_Currency_Code__c = 'EUR';
        update config;
        config.RLM_Filter_Logic__c = '(( 1 OR 2 ) OR ( 3 OR 4 ) OR ( 5 OR 6 ) OR ( 7 OR 8 ) OR ( 9 OR 10 ) OR ( 11 OR 12 ) OR ( 13 OR 14 ) OR ( 15 OR 16 ) OR ( 17 OR 18 ) )';
        config.REN_Filter_Criteria__c = new REN_LogicBuilderValidationHelper().buildWhereCriteriaString(lineCriteriaList, config);
        update config;
        
        REN_Renew_Configuration__c config1 = testDataSetup.renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET);
        config1.RLM_Filter_Logic__c = null;
        update config1;
        
        testDataSetup.renewDataSetup(1, 1, 1);
        testDataSetup.resetAllTriggersTo(true);
        testDataSetup.opportunityList[0].stageName = 'Closed Won';
        update testDataSetup.opportunityList[0];
        system.debug(config);
        
        Test.startTest(); 
        
        testDataSetup.resetAllTriggersTo(true);
        List<Asset> assetList = [select id from Asset where accountid = :testDataSetup.accountList[0].id];
        system.debug('\n\n~~~~assetList: ' + assetList);
        if(!assetList.isEmpty()){
            assetList[0].Name = 'Test-Line_Criteria';
            assetList[0].Quantity = 100;
            assetList[0].Price = 1000;
            assetList[0].REN_Start_Date__c = System.today() + 50;
            assetList[0].REN_End_Date__c = System.today() + 100;
            update assetList[0];
            system.assert(assetList[0].Quantity == 100);
        }
        Test.stopTest();
    }
    
    static testMethod void testUpdateAssetLogicWithAND() {
        SS_License__c SS_License = new SS_License__c();
        SS_License.Renew__c = true;
        insert SS_License;
        REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
        testDataSetup.createRenewConfigurations();
        testDataSetup.renewDataSetup(1, 1, 1);
        REN_Renew_Configuration__c config = testDataSetup.renewConfigurationMap.get(REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT);
        
        List<REN_Line_Criteria__c> lineCriteriaList = new List<REN_Line_Criteria__c>();
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 1, RLM_Field_Type__c = CSM_Constants.TYPE_STRING, RLM_Field_Name__c = 'Name', RLM_Operator__c = '=', RLM_Values__c = 'Name', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 2, RLM_Field_Type__c = CSM_Constants.TYPE_STRING, RLM_Field_Name__c = 'Name', RLM_Operator__c = '!=', RLM_Values__c = 'Name', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 3, RLM_Field_Type__c = CSM_Constants.TYPE_STRING, RLM_Field_Name__c = 'Name', RLM_Operator__c = 'LIKE', RLM_Values__c = 'Name', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 4, RLM_Field_Type__c = CSM_Constants.TYPE_STRING, RLM_Field_Name__c = 'Name', RLM_Operator__c = 'ALL', RLM_Values__c = 'Name', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 5, RLM_Field_Type__c = CSM_Constants.TYPE_INTEGER, RLM_Field_Name__c = 'Quantity', RLM_Operator__c = '=', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 6, RLM_Field_Type__c = CSM_Constants.TYPE_CURRENCY, RLM_Field_Name__c = 'Price', RLM_Operator__c = '!=', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 7, RLM_Field_Type__c = CSM_Constants.TYPE_CURRENCY, RLM_Field_Name__c = 'Price', RLM_Operator__c = '<=', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 8, RLM_Field_Type__c = CSM_Constants.TYPE_CURRENCY, RLM_Field_Name__c = 'Price', RLM_Operator__c = '>=', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 9, RLM_Field_Type__c = CSM_Constants.TYPE_CURRENCY, RLM_Field_Name__c = 'Price', RLM_Operator__c = '<', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =10, RLM_Field_Type__c = CSM_Constants.TYPE_CURRENCY, RLM_Field_Name__c = 'Price', RLM_Operator__c = '>', RLM_Values__c = '1', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =11, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '=', RLM_Is_Specific_Date__c = true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =12, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '!=', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =13, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '>', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =14, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '>=', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =15, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '<', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =16, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = '<=', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =17, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'REN_Start_Date__c', RLM_Operator__c = 'ALL', RLM_Is_Specific_Date__c =  true, RLM_Date_Value__c = System.today(), RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c =18, RLM_Field_Type__c = CSM_Constants.TYPE_DATE, RLM_Field_Name__c = 'Name', RLM_Operator__c = 'IN', RLM_Values__c = 'Name', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        insert lineCriteriaList;
        system.assert(lineCriteriaList != null);
        
        config.RLM_Currency_Code__c = 'EUR';
        update config;
        config.RLM_Filter_Logic__c = '(( 1 AND 2 ) OR ( 3 AND 4 ) OR ( 5 AND 6 ) OR ( 7 AND 8 ) OR ( 9 AND 10 ) OR ( 11 AND 12 ) OR ( 13 AND 14 ) OR ( 15 AND 16 ) OR ( 17 AND 18 ) )';
        config.REN_Filter_Criteria__c = new REN_LogicBuilderValidationHelper().buildWhereCriteriaString(lineCriteriaList, config);
        update config;
        
        REN_Renew_Configuration__c config1 = testDataSetup.renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET);
        config1.RLM_Filter_Logic__c = null;
        update config1;
        testDataSetup.renewDataSetup(1, 1, 1);
        testDataSetup.resetAllTriggersTo(true);
        testDataSetup.opportunityList[0].stageName = 'Closed Won';
        update testDataSetup.opportunityList[0];
        system.debug(config);
        
        Test.startTest(); 
        
        testDataSetup.resetAllTriggersTo(true);
        List<Asset> assetList = [select id from Asset where accountid = :testDataSetup.accountList[0].id];
        system.debug('\n\n~~~~assetList: ' + assetList);
        if(!assetList.isEmpty()){
            assetList[0].Name = 'Test-Line_Criteria';
            assetList[0].Quantity = 100;
            assetList[0].Price = 1000;
            assetList[0].REN_Start_Date__c = System.today() + 50;
            assetList[0].REN_End_Date__c = System.today() + 100;
            update assetList[0];
            system.assert(assetList[0].Quantity == 100);
        }
        //system.assertEquals(controller.getDescription(), 'This is TestFilter: recordKey-1');
        Test.stopTest();
    }
    
    static void setUp() {
        SS_License__c SS_License = new SS_License__c();
        SS_License.Renew__c = true;
        insert SS_License;
        List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
        renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
        upsert renewConfigurationList;
        
        REN_OpportunityRenewalAdminController ctrl = new REN_OpportunityRenewalAdminController();
        system.assert(ctrl.lbInputWrapperList != null);
        //ctrl.renewConfigurationList[0].REN_Update_On__c = REN_Constants.FLD_VAL_UPDATE_ON_ASSET_EX;
        //upsert ctrl.renewConfigurationList;
        ctrl = new REN_OpportunityRenewalAdminController();
        system.assert(ctrl.getThis() != null);
        
        REN_FieldMappingComponentController fmc = new REN_FieldMappingComponentController();
        CHL_RenPartnerDataSyncCtrl partnerDataSyncObj = new CHL_RenPartnerDataSyncCtrl();
        REN_FieldMappingInputWrapper  fmappigInputWrapper = new REN_FieldMappingInputWrapper('Opportunity', 'Asset', '12345', partnerDataSyncObj, system.label.CHL_LBL_PARTNER_OPP_FIELDS, system.label.REN_LBL_MAPPING_SECTION_HEADER, 'Partner_Opportunity Field', 'Opportunity Field', system.label.CHL_LBL_PARTNER_OPP_FIELDS,'ParentId');
        fmc.fmInputWrapper = fmappigInputWrapper;
        
        ctrl.setBaseChildController(fmc);
        ctrl.setBaseChildControllerMap('fmc', ctrl.getBaseChildController());
        //fmc.configAdminId = ctrl.renewConfigurationList[0].Id;
        fmc.fmInputWrapper.fromObjectName = 'Asset';
        fmc.fmInputWrapper.toObjectName = 'OpportunityLineItem';
        
        REN_CriteriaMetComponentController cmcc = new REN_CriteriaMetComponentController();
        ctrl.setBaseChildController(cmcc);
        ctrl.setBaseChildControllerMap('cmcc', ctrl.getBaseChildController());
        ctrl.save();
    }
    
    static testMethod void Test_UpdateAsset_Positive() {
        setUp();
        Test.startTest();
        List<Account> accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList.get(0).Id != null);
        Opportunity testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting',
                                                CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer');
        insert testOppty;
        
        Product2 prod = REN_TestDataUtility.createProduct(1);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 standardPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert standardPB;
        
        PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
        insert price1;
        system.assert(price1.Id != null);
        system.assert(prod.Id != null);
        
        
        OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = testOppty.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id);
        insert opptyLineItem;
        
        Asset asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);		
        asset.REN_Oppty_Line_Item_Id__c = opptyLineItem.Id;                
        insert asset;
        
        REN_Renews_To__c renRelationObj  = new REN_Renews_To__c();
        renRelationObj.Name  = 'Ren-OPP';
        renRelationObj.REN_Asset__c = asset.Id;
        renRelationObj.REN_Renews_To__c = testOppty.Id;
        //renRelationObj.REN_Renewal_Product_Line_Id__c = opptyLineItem.Id;
        renRelationObj.REN_Product__c = prod.id;
        insert renRelationObj;
        system.assert(renRelationObj != null);
        
        asset.quantity = 10;
        asset.price = 1000;
        update asset;
        system.assert(asset.quantity == 10);
        Test.stopTest();
    } 
    
}