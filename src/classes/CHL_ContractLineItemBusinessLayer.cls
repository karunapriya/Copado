public with sharing class CHL_ContractLineItemBusinessLayer {
    
     public CHL_GridInputWrapper inputWrapper;  
    
     public CHL_ContractLineItemBusinessLayer(CHL_GridInputWrapper inputWrapper){
        this.inputWrapper = inputWrapper;
    }
    
    public CHL_AngularResponeWrapper constructGridWrapper() {
    	Boolean isGlobalSearch = this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q) ? true : false;
    	Boolean selectionNeeded = this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q) ? false : true;	
        List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = getColumnHeader(isGlobalSearch);
        CHL_AngularResponeWrapper assetReqWrap = new CHL_AngularResponeWrapper();  
        if(CSM_AccessController.hasObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM)){
            List<SObject> dataList = getRecordList();
	        List<CHL_AngularResponeWrapper.CHL_GridData> recordList = getRecordDetailsList(dataList); 
	        assetReqWrap.gridConfiguration = CHL_Util.getGridExportOptions(false,'',selectionNeeded);
	        assetReqWrap.columnHeader = colHeaderList;
	        assetReqWrap.gridData = recordList;
        }
        return assetReqWrap;
    }
    
    
    private List<SObject> getRecordList(){        
    	//this.inputWrapper.q = '15';    
    	if(this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q))	{
		    return REN_ContractLineItemDataAccess.getCLIBySOSL(this.inputWrapper);
		} else if(this.inputWrapper.queryParams.accountID != null) {
        	return REN_ContractLineItemDataAccess.getContractLineItemsByAccount(this.inputWrapper.queryParams.accountID);
        }
        return null;
    }
    
    public List<CHL_AngularResponeWrapper.CHL_GridData> getRecordDetailsList(List<sObject> sObjectList) {  
    	
        List < CHL_AngularResponeWrapper.CHL_GridData > recordList = new List < CHL_AngularResponeWrapper.CHL_GridData > ();
        if(!Test.isRunningTest()) {
        	recordList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(sObjectList, CSM_Util.nameSpacePrefix21 + 'CHL_CLI_Account_Details_Community', 'ContractLineItem');
        }
        return recordList;
    }
    
    private List<CHL_AngularResponeWrapper.CHL_ColumnHeader> getColumnHeader(boolean isFromSearch)  {
        
        List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = new List<CHL_AngularResponeWrapper.CHL_ColumnHeader>();      
        if(!Test.isRunningTest()) {
        	colHeaderList = CHL_ResponseWrapperUtil.getColumnHeaderFromFieldSet(CSM_Util.nameSpacePrefix21+'CHL_CLI_Account_Details_Community', 'ContractLineItem', isFromSearch);
        }
        return colHeaderList;
     }
}