public with sharing class CHL_AssetBusinessLayer {
    
     public CHL_GridInputWrapper inputWrapper; 
    
     public CHL_AssetBusinessLayer(CHL_GridInputWrapper inputWrapper){
        this.inputWrapper = inputWrapper;
    }
    
    public CHL_AngularResponeWrapper constructAssetGrid() {
    	Boolean isGlobalSearch = this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q) ? true : false;
    	Boolean selectionNeeded = this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q) ? false : true;	
        List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = getColumnHeader(isGlobalSearch);
        List<SObject> dataList = getRecordList();
        List<CHL_AngularResponeWrapper.CHL_GridData> recordList = getRecordDetailsList(dataList); 
        system.debug('recordList :: '+recordList);
        CHL_AngularResponeWrapper assetReqWrap = new CHL_AngularResponeWrapper();  
       	assetReqWrap.gridConfiguration = CHL_Util.getGridExportOptions(Boolean.valueOf(CHL_Util.isDownloadable),Label.CHL_LBL_ASSETS,selectionNeeded);
        assetReqWrap.columnHeader = colHeaderList;
        assetReqWrap.gridData = recordList;
        system.debug('::'+JSON.serialize(assetReqWrap));
        return assetReqWrap;
    }
    
    
    private List<SObject> getRecordList(){    
    	//this.inputWrapper.q = 'global';    
    	if(this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q))	{
    		return REN_AssetDataAccess.getAssetsBySOSL(this.inputWrapper);
		} else if(this.inputWrapper.queryParams.accountID != null) {
        	return REN_AssetDataAccess.getAssetsByAccountId(this.inputWrapper.queryParams.accountID);        	
        }
        return null;
    }
    
   
    
    public static List<CHL_AngularResponeWrapper.CHL_GridData> getRecordDetailsList(List<sObject> sObjectList) {  
    	
    	List < CHL_AngularResponeWrapper.CHL_GridData > recordList = new List < CHL_AngularResponeWrapper.CHL_GridData > ();
        recordList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(sObjectList, CSM_Util.getNamespace()+'CHL_Asset_Account_Details_Community', 'Asset');
        return recordList;
    }
    
    private static List<CHL_AngularResponeWrapper.CHL_ColumnHeader> getColumnHeader(boolean isFromGlobalSearch)  {
        
        List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = new List<CHL_AngularResponeWrapper.CHL_ColumnHeader>();        
        colHeaderList = CHL_ResponseWrapperUtil.getColumnHeaderFromFieldSet(CSM_Util.getNamespace()+'CHL_Asset_Account_Details_Community', 'Asset', isFromGlobalSearch);        
        return colHeaderList;
     }
}