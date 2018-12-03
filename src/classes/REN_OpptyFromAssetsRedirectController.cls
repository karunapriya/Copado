public with sharing class REN_OpptyFromAssetsRedirectController
{
    private transient ApexPages.StandardSetController standSetCont;
    private String parentId;
    private transient List<Asset> selectedAssets;
    public CSM_DataGridAttribute assetGridAttribute{get; set;}
    public String selectedAssetIds{get; set;}
    public Boolean showDataGrid{get; set;}
    public SS_License__c productIdSetting;
    public REN_OpptyFromAssetsRedirectController(ApexPages.StandardSetController controller) {
        standSetCont = controller;
        this.parentId = ApexPages.currentPage().getParameters().get('Id');
        this.showDataGrid = false;
        productIdSetting = SS_License__c.getOrgDefaults();
        this.setGridAttributes();
    }

    public PageReference returnPage(){
        PageReference pageRef = null;
        this.selectedAssets = (List<Asset>) standSetCont.getSelected();
        if(String.isBlank(this.parentId)){
            pageRef = processListViewSelection();
        }else{
            pageRef = processRelatedListSelection();
        }
                
        return pageRef;
    }
    
    public PageReference generateOpportunity(){
        PageReference pageRef = null;
        if(String.isNotBlank(this.selectedAssetIds)){
            if(productIdSetting!=null && productIdSetting.Simplified_Data_Model_Is_Enabled__c){
                pageRef = Page.REN_GenerateSimplifiedOpportunity;
            }else{
                pageRef = Page.REN_CreateOpptyFromAssets;
            }
            pageRef.getParameters().put('assetIds', this.selectedAssetIds);
            if(String.isNotBlank(this.parentId)){
                pageRef.getParameters().put('parentId', this.parentId);
            }
        }
        return pageRef;
    }
    
    private PageReference processRelatedListSelection(){
        PageReference pageRef = null;
        if (this.selectedAssets == null || this.selectedAssets.isEmpty()){
            this.showDataGrid = true;
        }else{
            pageRef = redirectToGenerateOpportunity();
        }
        return pageRef;
    }
    
    private PageReference processListViewSelection(){
        PageReference pageRef = null;
        if (selectedAssets == null || selectedAssets.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.REN_MSG_ATLEAST_ONE_ASSET));
        } else{
            pageRef = redirectToGenerateOpportunity();
        }
        return pageRef; 
    }
    
    private PageReference redirectToGenerateOpportunity(){
        String url = '';
        Boolean firstIteration = true;
        String oldCurrency = '';
        String newCurrency = '';
        for(Asset assetObject: selectedAssets){
            if (UserInfo.isMultiCurrencyOrganization()){
                if(oldCurrency == ''){
                    oldCurrency = (String)assetObject.get('CurrencyIsoCode');
                }   
                newCurrency = (String)assetObject.get('CurrencyIsoCode');
                
                if(String.isNotBlank(oldCurrency) && String.isNotBlank(newCurrency)
                         && oldCurrency != newCurrency) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Label.REN_MSG_ASSETS_CURRENCY));
                    return null;
                }
                else {
                    oldCurrency = (String)assetObject.get('CurrencyIsoCode');
                }
            }
            if(firstIteration){
                url = assetObject.Id;
                firstIteration = false;
            }else{
                url = url + '-' + assetObject.Id; 
            } 
        }
        PageReference pageRef = Page.REN_CreateOpptyFromAssets;
        if(productIdSetting!=null && productIdSetting.Simplified_Data_Model_Is_Enabled__c){
            pageRef = Page.REN_GenerateSimplifiedOpportunity;
        }else{
            pageRef = Page.REN_CreateOpptyFromAssets;
        }
        
        pageRef.getParameters().put('assetIds', url);
        if(String.isNotBlank(this.parentId)){
            pageRef.getParameters().put('parentId', this.parentId);
        }
        return pageRef;
    }
    
    private void setGridAttributes() {
        if(String.isNotBlank(this.parentId)){
            assetGridAttribute = new CSM_DataGridAttribute();        
            assetGridAttribute.tableName = Schema.SObjectType.Asset.label;
            assetGridAttribute.objectType =Schema.SObjectType.Asset.label;
            assetGridAttribute.viewName =CSM_Constants.GRID_ATTR_SEARCH_ADD;
            assetGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
            assetGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
            assetGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
            assetGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
            assetGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
            CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
            if(String.isNotBlank(this.parentId)){
                Id objId = Id.valueOf(this.parentId);
                Schema.SObjectType token = objId.getSObjectType();
                Schema.DescribeSObjectResult dr = token.getDescribe();
                if(dr.getName().equalsIgnoreCase('Account')){
                    gridInputParams.selectedFilterClause = 'Where AccountId = \'' + this.parentId + '\'';
                } else {
                    gridInputParams.selectedFilterClause = 'Where REN_Opportunity__c = \'' + this.parentId + '\'';
                }
            }
            assetGridAttribute.params = JSON.serialize(gridInputParams);
        }
    }
}