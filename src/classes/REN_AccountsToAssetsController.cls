public with sharing class REN_AccountsToAssetsController
{
    public CSM_DataGridAttribute assetGridAttribute {get; set;}
    
     public String accountId
    {
        get
        {
            return accountId;
        }
        set
        {
            accountId = value;
            setGridAttribute();
        }
    }
    
    private void setGridAttribute()
    {
        assetGridAttribute = new CSM_DataGridAttribute();
        assetGridAttribute.gridToolbarId = '';
        assetGridAttribute.tableName = Schema.SObjectType.Asset.labelplural;
        assetGridAttribute.objectType = Schema.SObjectType.Asset.label;
        assetGridAttribute.viewName = Schema.SObjectType.Asset.labelplural.toLowerCase();
        assetGridAttribute.stateSave = CSM_Constants.GRID_ATTR_TRUE;
        assetGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
        assetGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
     	if (String.isBlank(accountId))
     	{
     		gridInputParams.accountId = '';
     	}
     	else
     	{
     	    gridInputParams.accountId = accountId;
     	}
     	gridInputParams.gridCurrency = UserInfo.getDefaultCurrency();
     	gridInputParams.taskOrViewId = '';
     	assetGridAttribute.params = JSON.serialize(gridInputParams);
     	Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
     	assetGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    }
   
}