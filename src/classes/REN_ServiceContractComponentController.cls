public with sharing class REN_ServiceContractComponentController
{
    public CSM_DataGridAttribute contractGridAttribute {get; set;}
    
     public String scAccountId
    {
        get
        {
            return scAccountId;
        }
        set
        {
            scAccountId = value;
            setGridAttribute();
        }
    }
    
    private void setGridAttribute()
    {
    	
    	//<!-- <c:CSM_DataGrid tableName="ServiceContracts" objType="ContractLineItem" params="{taskOrViewId:'',accountId:'{!accountId}'}" viewName="serviceContracts" stateSave="true" hasSearch="true" hasShowColumns="true" gridToolBarId=""/> -->
        contractGridAttribute = new CSM_DataGridAttribute();
        contractGridAttribute.gridToolbarId = '';
        contractGridAttribute.tableName = CSM_Constants.GRID_ATTR_SERVICE_CONTRACTS;
        contractGridAttribute.objectType = CSM_Constants.GRID_ATTR_CONT_LINE_ITEM;
        contractGridAttribute.viewName = CSM_Constants.GRID_ATTR_SERV_CONTRACTS;
        contractGridAttribute.stateSave = CSM_Constants.GRID_ATTR_TRUE;
        contractGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
        contractGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
     	if (String.isBlank(scAccountId))
     	{
     		gridInputParams.accountId = '';
     	}
     	else
     	{
     	    gridInputParams.accountId = scAccountId;
     	}
     	gridInputParams.taskOrViewId = '';
     	contractGridAttribute.params = JSON.serialize(gridInputParams);	
     	Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		contractGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    }
}