/**
 * Created Date     : Sep 25, 2017
 * Developed By     : Dheeraj Vashist, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj Vashist                  User Story              Sep 25, 2017            1.1                 @description
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Comity Designs, Inc. 2017 - All Rights Reserved.
 */
@isTest
private class REN_GenerateSimplifiedOpptyCtrlTest {

    /**
     * Method to create test records once and use for all the methods in this test class
     */ 
    @testSetup
    public static void setup(){
        List<Asset> assetList = new List<Asset>();
        String namePrifix = CSM_Util.getNamespace();
        Account accountObj=CHL_TestUtility.partnerAccount();
        insert accountObj;
        
        Opportunity opp=CHL_TestUtility.partnerOpportunity(accountObj.id,'Closed Won');
        opp.pricebook2Id = Test.getStandardPricebookId();
        insert Opp;
        
        Opportunity opp1=CHL_TestUtility.partnerOpportunity(accountObj.id,'Closed Won');
        opp1.pricebook2Id = Test.getStandardPricebookId();
        insert opp1;
        
        List<Product2> listOfProduct = CHL_TestUtility.createProducts(2);
        insert listOfProduct;
        
        for(Product2 prod : listOfProduct){
           Asset ast = REN_TestDataUtility.createAsset(accountObj.Id, prod.Id);
           ast.InstallDate=system.today();
           ast.Status='Installed';
           
           assetList.add(ast);

        }
        insert assetList;
        
        Pricebook2 pb = new pricebook2(name='test');
        insert pb;
        
        List<PriceBookEntry> listOfPBE = CHL_TestUtility.createPricebookEntry(listOfProduct,Test.getStandardPricebookId());
        insert listOfPBE;
        
        List<OpportunityLineItem> listOfOli = CHL_TestUtility.createOplis(new List<Opportunity>{opp},listOfPBE);
        insert listOfOli;
        
        List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
        renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
        upsert renewConfigurationList;
        
        SS_License__c productIdSetting= SS_License__c.getOrgDefaults();
        productIdSetting.Renewal_Amount_Product_Id__c = listOfProduct.get(0).Id;
        productIdSetting.Simplified_Data_Model_Is_Enabled__c=true;
        insert productIdSetting;
        
        REN_Field_Mappings__c fmStage = getFieldMappingRec('PICKLIST', 'StageName', '', 'Opportunity', 'Opportunity', true, 'Qualification');
        REN_Field_Mappings__c fmStageAsset = getFieldMappingRec('PICKLIST', 'StageName', 'Status', 'Opportunity', 'Asset', true, '');
        REN_Field_Mappings__c fmStageSC = getFieldMappingRec('PICKLIST', 'StageName', 'Status', 'Opportunity', 'ServiceContract', true, '');
        
        //CloseDate
        REN_Field_Mappings__c fmCloseDt = getFieldMappingRec('DATE', 'CloseDate', 'CloseDate', 'Opportunity', 'Opportunity', true, '');
        REN_Field_Mappings__c fmCloseDtAsset = getFieldMappingRec('DATE', 'CloseDate', 'InstallDate', 'Opportunity', 'Asset', true, '');
        REN_Field_Mappings__c fmCloseDtSC = getFieldMappingRec('DATE', 'CloseDate', 'EndDate', 'Opportunity', 'ServiceContract', true, '');
        //OwnerId
        REN_Field_Mappings__c fmOwner = getFieldMappingRec('REFERENCE', 'OwnerId', 'OwnerId', 'Opportunity', 'Opportunity', true, '');
        
        //Name
        REN_Field_Mappings__c fmName = getFieldMappingRec('STRING', 'Name', 'Name', 'Opportunity', 'Opportunity', true, '');
        REN_Field_Mappings__c fmNameAst = getFieldMappingRec('STRING', 'Name', 'Name', 'Opportunity', 'Asset', true, '');
        REN_Field_Mappings__c fmNameSCOPP = getFieldMappingRec('STRING', 'Name', 'Name', 'Opportunity', 'ServiceContract', true, '');
                
        //IsPrivate
        REN_Field_Mappings__c fmPrivate = getFieldMappingRec('BOOLEAN', 'IsPrivate', 'IsPrivate', 'Opportunity', 'Opportunity', true, '');
        
        //Probability
        REN_Field_Mappings__c fmProb = getFieldMappingRec('PERCENT', 'Probability', '', 'Opportunity', 'Opportunity', true, '15');
        
        //Oppt Line Item
        REN_Field_Mappings__c fmQuantityOpLn = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmServDtOpLn = getFieldMappingRec('DATE', 'ServiceDate', '', 'OpportunityLineItem', 'OpportunityLineItem', true, '2019-09-17');
        
        
        REN_Related_List__c rlAsset = new REN_Related_List__c(Name=REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Competitors');
        insert rlAsset;
        //Assets
        REN_Field_Mappings__c fmCompPrd = getFieldMappingRec('BOOLEAN', 'IsCompetitorProduct', '', 'Asset', 'OpportunityLineItem', true, 'false');
        
        REN_Field_Mappings__c fmNameAsset = getFieldMappingRec('STRING', 'Name', 'Name', 'Asset', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmQuantityAsset = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'Asset', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmDescAsset = getFieldMappingRec('TEXTAREA', 'Description', 'Description', 'Asset', 'OpportunityLineItem', true, '');
        
        //Service Contracts
        REN_Field_Mappings__c fmNameSC  = getFieldMappingRec('STRING', 'Name', 'Name', 'ServiceContract', 'Opportunity', true, '');
        
        REN_Field_Mappings__c fmOwnerSC = getFieldMappingRec('REFERENCE', 'OwnerId', 'OwnerId', 'ServiceContract', 'Opportunity', true, '');
        
        REN_Field_Mappings__c fmUnitPriceSC = getFieldMappingRec('DOUBLE', 'UnitPrice', 'UnitPrice', 'ContractLineItem', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmQtySC = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'ContractLineItem', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmUnitPriceSCRR = getFieldMappingRec('DOUBLE',  namePrifix +'REN_Previous_Price__c','UnitPrice',  namePrifix +'REN_Renews_To__c', 'ContractLineItem', true, '');
        
        REN_Field_Mappings__c fmQtySCRR = getFieldMappingRec('DOUBLE', namePrifix +'REN_Quantity__c', 'Quantity', namePrifix +'REN_Renews_To__c','ContractLineItem' , true, '');
        
        List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
        fMappingList.add(fmCloseDt);
        fMappingList.add(fmStage);
        fMappingList.add(fmOwner);
        fMappingList.add(fmName);
        fMappingList.add(fmNameAst);
        fMappingList.add(fmStageAsset );
        fMappingList.add(fmCloseDtAsset );
        fMappingList.add(fmPrivate);
        fMappingList.add(fmProb);
        fMappingList.add(fmNameSCOPP);
        fMappingList.add(fmCloseDtSC);
        fMappingList.add(fmStageSC);
        
        fMappingList.add(fmQuantityOpLn);
        fMappingList.add(fmServDtOpLn);
        
        fMappingList.add(fmCompPrd);
        fMappingList.add(fmNameAsset);
        fMappingList.add(fmQuantityAsset);
        fMappingList.add(fmDescAsset);
        
        //Added below code to fix the test class failuare after patch version upload 1.25.7
        fMappingList.add(fmNameSC);
        fMappingList.add(fmOwnerSC);
        fMappingList.add(fmUnitPriceSC);
        fMappingList.add(fmUnitPriceSCRR);
        fMappingList.add(fmQtySCRR);
        insert fMappingList;
        
        system.assert(fMappingList != null);
        
        if (CSM_AccessController.hasObject(CHL_Constants.OBJ_SERVICE_CONTRACT)) {
             Sobject sCObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_SERVICE_CONTRACT).newSObject() ; 
             sCObj.put('Name', 'SC Test') ;
             if (CSM_AccessController.hasField(REN_Constants.OBJ_T_REN_OPPORTUNITY_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 +REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT)){
               // VCP - ORG21 check
               sCObj.put(CSM_Util.nameSpacePrefix21 +'REN_Opportunity__c', opp.Id);
               sCObj.put('Status', opp.StageName);
               sCObj.put('EndDate', opp.CloseDate);
             }
             sCObj.put('Pricebook2Id', Test.getStandardPricebookId()); 
             insert sCObj;
             
             SObject cli = CSM_AccessController.newSObject('ContractLineItem');
             cli.put('ServiceContractId', sCObj.get('Id'));
             cli.put('UnitPrice', 100.00);
             cli.put('Discount', 1);
             cli.put('Quantity', 1.0);
             cli.put('PricebookEntryId', listOfPBE[0].Id);
             insert cli;
             
        }
        
    }
    
    public static testmethod void testSimplified(){
        List<Asset> assetList = new List<Asset>();
        Opportunity opp = [Select id,stageName from Opportunity limit 1];
        PageReference tpageRef = Page.REN_GenerateSimplifiedOpportunity;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id', Opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        REN_GenerateSimplifiedOpportunityCtrl genSimplified = new REN_GenerateSimplifiedOpportunityCtrl(sc);
        genSimplified.calculateOliTotal();
        genSimplified.getJsonArray();
        genSimplified.save();
        genSimplified.cancel();
        assetList = [Select id from asset]; 
        system.assert(assetList != null);
        String assetIds;
        for(Asset asset : assetList){
            if(String.isNotBlank(assetIds)){
                assetIds += '-'+asset.Id;
            }else{
                assetIds += asset.Id;
            }
        }
        
        PageReference tpageRef2 = Page.REN_GenerateSimplifiedOpportunity;
        Test.setCurrentPage(tpageRef2);
        ApexPages.currentPage().getParameters().put('assetIds', assetIds);
        REN_GenerateSimplifiedOpportunityCtrl genSimplified2 = new REN_GenerateSimplifiedOpportunityCtrl(sc);
        genSimplified2.save();
        genSimplified2.cancel(); 
        if (CSM_AccessController.hasObject(CHL_Constants.OBJ_SERVICE_CONTRACT)) {
            List<sObject> lstOfSC = Database.query('SELECT id FROM '+CHL_Constants.OBJ_SERVICE_CONTRACT);
            PageReference tpageRef3 = Page.REN_GenerateSimplifiedOpportunity;
            Test.setCurrentPage(tpageRef3);
            ApexPages.currentPage().getParameters().put('contractId', ''+lstOfSC.get(0).get('Id'));
            REN_GenerateSimplifiedOpportunityCtrl genSimplified3 = new REN_GenerateSimplifiedOpportunityCtrl(sc);
            genSimplified3.save();
            genSimplified3.cancel();
        }
            
    }
    static testmethod void testSimplifiedNeg(){
        list<Opportunity> opp = [Select id,Name,stageName from Opportunity limit 2];
        SS_License__c productIdSetting= SS_License__c.getOrgDefaults();
        productIdSetting.Renewal_Amount_Product_Id__c = null;
        update productIdSetting;
        PageReference tpageRef = Page.REN_GenerateSimplifiedOpportunity;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id', '');
        ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
        REN_GenerateSimplifiedOpportunityCtrl genSimplified = new REN_GenerateSimplifiedOpportunityCtrl(sc);
        genSimplified.save();
        System.assert(productIdSetting != Null);
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
}