@isTest
private class REN_OpptyAssetsRedirectTest
{
    static List<Asset> assetList;
    static List<Product2> productList;
    static List<Account> accountList;
    static List<PricebookEntry> pbEntryList;
    static String assetIds = '';
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
        fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'Asset', true, ''));
        fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'UnitPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
        fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'TotalPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
        insert fMappingList;
    }
    static testMethod void noAssetsSelectedTest() {
        Test.startTest();
        List<Asset> lst = new List<Asset>();        
        REN_OpptyFromAssetsRedirectController ctrl = new REN_OpptyFromAssetsRedirectController(new ApexPages.StandardSetController(lst));
        PageReference pageRef = ctrl.returnPage();
        Test.stopTest();                
        
        system.assert(pageRef == null);
    }
    

    
    static testMethod void assetsSelectedTest() {
        Test.startTest();
        setUp();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(assetList);
        stdSetController.setSelected(assetList);

        
        PageReference pageRef = Page.REN_OpptyFromAssetsRedirect;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('assetIds', assetIds);
        REN_OpptyFromAssetsRedirectController ctrl = new REN_OpptyFromAssetsRedirectController(stdSetController);
        pageRef = ctrl.returnPage();
        Test.stopTest(); 
        system.assert(pageRef != null);
    }
}