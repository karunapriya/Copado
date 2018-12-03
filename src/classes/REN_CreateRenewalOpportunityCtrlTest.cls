@isTest
private class REN_CreateRenewalOpportunityCtrlTest {
    
    static testMethod void CreateRenewalOpportunityCtrlTest(){
        List <Account> accountList = CSM_TestDataUtility.createAccount(1);
        system.assert(accountList != null);
        system.assert(!accountList.isEmpty());
        
        List <Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(1, accountList[0].id);
        REN_FutureOppResolutionHandler.applyOpportunityCriteria(opportunityList,opportunityList);
        system.assert(opportunityList != null);
        system.assert(!opportunityList.isEmpty());
        
        List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
        renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
        upsert renewConfigurationList;
        system.assert(renewConfigurationList!=null);
        Map<String, REN_Renew_Configuration__c> renewConfigurationMap = new Map<String, REN_Renew_Configuration__c>();
        if(renewConfigurationList != null){
            for(REN_Renew_Configuration__c rConfig: renewConfigurationList){
                renewConfigurationMap.put(rConfig.REN_Record_Key__c, rConfig);
            }
        }
        REN_Renew_Configuration__c config = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET);
        REN_Renew_Configuration__c configSC = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT);
        List<REN_Line_Criteria__c> lineCriteriaList = new List<REN_Line_Criteria__c>();
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 1, RLM_Field_Type__c = CSM_Constants.TYPE_PICKLIST, RLM_Field_Name__c = 'StageName', RLM_Operator__c = '=', RLM_Values__c = 'Closed Won', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = config.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 1, RLM_Field_Type__c = CSM_Constants.TYPE_PICKLIST, RLM_Field_Name__c = 'StageName', RLM_Operator__c = '=', RLM_Values__c = 'Closed Won', REN_Renew_Configuration__c = configSC.Id));
        insert lineCriteriaList;
        system.assert(lineCriteriaList != null);        
         
        REN_Field_Mappings__c fmStage = getFieldMappingRec('PICKLIST', 'StageName', '', 'Opportunity', 'Opportunity', true, 'Closed Won');
        
        //CloseDate
        REN_Field_Mappings__c fmCloseDt = getFieldMappingRec('DATE', 'CloseDate', 'CloseDate', 'Opportunity', 'Opportunity', true, '');
        
        //OwnerId
        REN_Field_Mappings__c fmOwner = getFieldMappingRec('REFERENCE', 'OwnerId', 'OwnerId', 'Opportunity', 'Opportunity', true, '');
        
        //Name
        REN_Field_Mappings__c fmName = getFieldMappingRec('STRING', 'Name', 'Name', 'Opportunity', 'Opportunity', true, '');
        
        //IsPrivate
        REN_Field_Mappings__c fmPrivate = getFieldMappingRec('BOOLEAN', 'IsPrivate', 'IsPrivate', 'Opportunity', 'Opportunity', true, '');
        
        //Probability
        REN_Field_Mappings__c fmProb = getFieldMappingRec('PERCENT', 'Probability', '', 'Opportunity', 'Opportunity', true, '15');
        
        //Oppt Line Item
        REN_Field_Mappings__c fmQuantityOpLn = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmServDtOpLn = getFieldMappingRec('DATE', 'ServiceDate', '', 'OpportunityLineItem', 'OpportunityLineItem', true, '2019-09-17');
                
        //Asset
        REN_Field_Mappings__c fmCompPrd = getFieldMappingRec('BOOLEAN', 'IsCompetitorProduct', '', 'Asset', 'OpportunityLineItem', true, 'false');
        
        REN_Field_Mappings__c fmNameAsset = getFieldMappingRec('STRING', 'Name', 'Name', 'Asset', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmQuantityAsset = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'Asset', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmDescAsset = getFieldMappingRec('TEXTAREA', 'Description', 'Description', 'Asset', 'OpportunityLineItem', true, '');
        
        //Service Contracts
        REN_Field_Mappings__c fmNameSC  = getFieldMappingRec('STRING', 'Name', 'Name', 'ServiceContract', 'Opportunity', true, '');
        
        REN_Field_Mappings__c fmOwnerSC = getFieldMappingRec('REFERENCE', 'OwnerId', 'OwnerId', 'ServiceContract', 'Opportunity', true, '');
        
        REN_Field_Mappings__c fmUnitPriceSC = getFieldMappingRec('DOUBLE', 'UnitPrice', 'UnitPrice', 'ContractLineItem', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmQtySC = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'ContractLineItem', 'OpportunityLineItem', true, '');        
        
        List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
        fMappingList.add(fmStage);
        fMappingList.add(fmOwner);
        fMappingList.add(fmName);
        fMappingList.add(fmPrivate);
        fMappingList.add(fmProb);
        fMappingList.add(fmCloseDt);
        
        fMappingList.add(fmQuantityOpLn);
        fMappingList.add(fmServDtOpLn);
        
        fMappingList.add(fmCompPrd);
        fMappingList.add(fmNameAsset);
        fMappingList.add(fmQuantityAsset);
        fMappingList.add(fmDescAsset);
        
        fMappingList.add(fmNameSC);
        fMappingList.add(fmOwnerSC);
        
        insert fMappingList;
                
        //Name
        REN_Field_Mappings__c fm1 = getFieldMappingRec('STRING', 'Name', 'Name', 'ServiceContract', 'Opportunity', true, '');
    
        //UnitPrice
        REN_Field_Mappings__c fm2 = getFieldMappingRec('CURRENCY', 'UnitPrice', 'UnitPrice', 'ContractLineItem', 'OpportunityLineItem', true, '');
    
        //Quantity
        REN_Field_Mappings__c fm3 = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'ContractLineItem', 'OpportunityLineItem', true, '');
    
        //CloseDate
        REN_Field_Mappings__c fm4 = getFieldMappingRec('DATE', 'CloseDate', 'EndDate', 'Opportunity', 'ServiceContract', true, '');

        //Name:Opportunity
        REN_Field_Mappings__c fm5 = getFieldMappingRec('STRING', 'Name', 'Name', 'Opportunity', 'ServiceContract', true, '');

        //IsPrivate
        REN_Field_Mappings__c fm6 = getFieldMappingRec('BOOLEAN', 'IsPrivate', 'false', 'Opportunity', 'ServiceContract', true, '');
    
        //StageName
        REN_Field_Mappings__c fm7 = getFieldMappingRec('PICKLIST', 'StageName', 'Status', 'Opportunity', 'ServiceContract', true, '');
    
        //Quantity
        REN_Field_Mappings__c fm8 = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'OpportunityLineItem', true, '');
    
        List<REN_Field_Mappings__c> fMapList = new List<REN_Field_Mappings__c> ();
        fMapList.add(fm1);
        fMapList.add(fm2);
        fMapList.add(fm3);
        fMapList.add(fm4);
        fMapList.add(fm5);
        fMapList.add(fm6);
        fMapList.add(fm7);
        fMapList.add(fm8);
        insert fMapList;
        
        String standardPriceBookId = Test.getStandardPricebookId();
        
        Product2 p2 = new Product2(Name = 'Test Product', isActive = true,ProductCode ='IN7080');
        insert p2;
        system.assert(p2.Id != null);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = p2.Id, UnitPrice = 99, isActive = true);
        insert pbe;
        system.assert(pbe.Id != null);
        
        List <OpportunityLineItem> opliList = new List <OpportunityLineItem> ();
        OpportunityLineItem newol = new OpportunityLineItem();
        newol.UnitPrice = 50000;
        newol.ServiceDate = System.today();
        newol.Description = 'Desc 1';
        newol.Quantity = 1;
        newol.PricebookEntryId = pbe.Id;
        newol.OpportunityId = opportunityList[0].Id;
        opliList.add(newol);
        insert opliList;
        system.assert(opliList!=null);
        
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(opportunityList[0]);
            REN_CreateRenewalOpportunityCtrl testCreateRenewalOpportunity = new REN_CreateRenewalOpportunityCtrl(sc);
            PageReference pageRef = Page.REN_CreateRenewalOpportunity;
            pageRef.getParameters().put('id', String.valueOf(opportunityList[0].Id));
            Test.setCurrentPage(pageRef);
            system.assert(opportunityList!=null);
            
            if(CSM_AccessController.hasField('Opportunity', 'Opportunity_Name__c')){
                for(Opportunity oppObj : testCreateRenewalOpportunity.renewOpportunityList){
                    oppObj.put('Name','Renew ' + oppObj.Name);
                    
                }
            }
        
            for(REN_OpptLineWrapper olW: testCreateRenewalOpportunity.lstAllOpptLinesW){
                if(olW.opLine.UnitPrice != null && olW.opLine.Quantity != null){
                    olW.opLine.TotalPrice = olW.opLine.UnitPrice * olW.opLine.Quantity;
                }else{
                    olW.opLine.TotalPrice = 0;
                }
            }
            
            testCreateRenewalOpportunity.save();
            testCreateRenewalOpportunity.cancel();
        Test.stopTest();        
    }
        
    static testMethod void CreateRenewalOpportunityCtrTest_Negative(){
        List<Account> accountLst = CSM_TestDataUtility.createAccount(1);
        List<Opportunity> opportunityLst = CSM_TestDataUtility.createOpportunity(1, accountLst[0].id);
        
        Test.startTest();
        List<Opportunity> lstOpptFromQry = [SELECT Id, AccountId, CloseDate FROM Opportunity WHERE id=:opportunityLst[0].Id];
        ApexPages.StandardController sc = new ApexPages.StandardController(opportunityLst[0]);
        PageReference pageRef = Page.REN_CreateRenewalOpportunity;
        pageRef.getParameters().put('id', String.valueOf(opportunityLst[0].Id));
        Test.setCurrentPage(pageRef);
        REN_CreateRenewalOpportunityCtrl testCreateRenewalOpportunity = new REN_CreateRenewalOpportunityCtrl(sc);
        system.assert(testCreateRenewalOpportunity.existingOpportunity != null);
        Test.stopTest();
    }
    static REN_Field_Mappings__c getFieldMappingRec(String dataType, String toName, String fromName, String toObject, String fromObject, 
                                                    Boolean isRequired, String defaultValue)
    {
        REN_Field_Mappings__c fm = new REN_Field_Mappings__c();
        //fm.REN_Renew_Configuration__c = rcRenewalId;
        fm.REN_Field_Data_Type__c = dataType;
        fm.REN_To_Field_API_Name__c = toName;
        fm.REN_From_Field_API_Name__c = fromName;
        fm.REN_To_Object_API_Name__c = toObject;
        fm.REN_From_Object_Api_Name__c = fromObject;
        fm.REN_Is_Required__c = isRequired;
        fm.REN_Default_Value__c = defaultValue;
        return fm;
    }   
    
    
    public static testMethod void testGenerateSDMCtrl(){
        List<Account> accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList.get(0).Id != null);       
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        Opportunity testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=customPB.id,
        CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, REN_Earliest_Expiration_Date__c = System.Today() + 2);
        insert testOppty;

        Product2 prod = REN_TestDataUtility.createProduct(1);
        insert prod;
        
        SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
        productIdSetting.Renewal_Amount_Product_Id__c = prod.Id;
        productIdSetting.Simplified_Data_Model_Is_Enabled__c = true;
        upsert productIdSetting;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = customPB.id, UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
        insert price1;
        
        OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = testOppty.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
        insert opptyLineItem;
        //Name
        REN_Field_Mappings__c fm1 = getFieldMappingRec('STRING', 'Name', 'Name', 'Opportunity', 'Opportunity', true, '');
        REN_Field_Mappings__c fm2 = getFieldMappingRec('PICKLIST', 'StageName', 'StageName', 'Opportunity', 'Opportunity', true, '');
        REN_Field_Mappings__c fm3 = getFieldMappingRec('DATE', 'CloseDate', 'CloseDate', 'Opportunity', 'Opportunity', true, '');
        REN_Field_Mappings__c fm4 = getFieldMappingRec('REFERENCE', 'AccountId', 'AccountId', 'Opportunity', 'Opportunity', true, '');
        
         //Asset
        REN_Field_Mappings__c fmCompPrd = getFieldMappingRec('BOOLEAN', 'IsCompetitorProduct', '', 'Asset', 'OpportunityLineItem', true, 'false');
        
        REN_Field_Mappings__c fmNameAsset = getFieldMappingRec('STRING', 'Name', 'Name', 'Asset', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmQuantityAsset = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'Asset', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmDescAsset = getFieldMappingRec('TEXTAREA', 'Description', 'Description', 'Asset', 'OpportunityLineItem', true, '');
        
        //Service Contracts
        REN_Field_Mappings__c fmNameSC  = getFieldMappingRec('STRING', 'Name', 'Name', 'ServiceContract', 'Opportunity', true, '');
        
        REN_Field_Mappings__c fmOwnerSC = getFieldMappingRec('REFERENCE', 'OwnerId', 'OwnerId', 'ServiceContract', 'Opportunity', true, '');
        
        REN_Field_Mappings__c fmUnitPriceSC = getFieldMappingRec('DOUBLE', 'UnitPrice', 'UnitPrice', 'ContractLineItem', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmQtySC = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'ContractLineItem', 'OpportunityLineItem', true, '');        
        
        
        
        List<REN_Field_Mappings__c> fMapList = new List<REN_Field_Mappings__c> ();
        fMapList.add(fm1);
        fMapList.add(fm2);
        fMapList.add(fm3);
        fMapList.add(fm4);
        fMapList.add(fmNameSC);
        fMapList.add(fmOwnerSC);
        fMapList.add(fmUnitPriceSC);
        fMapList.add(fmQtySC);
        fMapList.add(fmDescAsset);
        fMapList.add(fmQuantityAsset);
        fMapList.add(fmNameAsset);
        fMapList.add(fmCompPrd);
        insert fMapList;
        
        List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
        renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
        upsert renewConfigurationList;
        List<Asset> astLst = new List<Asset>{CHL_TestUtility.createAsset(accList.get(0).Id),CHL_TestUtility.createAsset(accList.get(0).Id)};
        insert astLst;
        String assetIds = astLst.get(0).Id+'-'+astLst.get(1).Id;
        PageReference pageRef = Page.REN_GenerateSimplifiedOpportunity;
        pageRef.getParameters().put('id', String.valueOf(testOppty.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(testOppty);
        REN_GenerateSimplifiedOpportunityCtrl genSDMCtrl = new REN_GenerateSimplifiedOpportunityCtrl(sc);
        genSDMCtrl.save();
        genSDMCtrl.cancel();
        pageRef.getParameters().put('assetIds', assetIds);
        Test.setCurrentPage(pageRef);
        REN_GenerateSimplifiedOpportunityCtrl genSDMCtrl2 = new REN_GenerateSimplifiedOpportunityCtrl(sc);
    }
}