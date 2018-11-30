public with sharing class CHL_AccountBusinessLayer {


    /**
      * @description : This method returns the JSON object to show list of contacts associated with the  master opportunity.
    */
    public static Object  getAccountDetails(String inputvalue) {    
        CHL_AngularTabsInputWrapper inputWrapper = (CHL_AngularTabsInputWrapper)JSON.deserialize(inputValue, CHL_AngularTabsInputWrapper.class);
        String accountId = inputWrapper.accountId; 
          
        List<Account>  accountList = CSM_AccountDataAccess.getDetailsFromFieldSetByAccId(accountId,CSM_Util.getNamespace() + CHL_Constants.ACCOUNT_DETAILS_FIELDSET_NAME);    
        List<CHL_DetailTabResponseWrapper> accDetailWrapperList = CHL_ResponseWrapperUtil.getObjectDetailsFromFieldSet(accountList, CSM_Util.getNamespace() +CHL_Constants.ACCOUNT_DETAILS_FIELDSET_NAME, CSM_Constants.OBJ_ACCOUNT);
        return accDetailWrapperList[0];
    }
    
    public CHL_GridInputWrapper inputWrapper;  
    
    public CHL_AccountBusinessLayer(CHL_GridInputWrapper inputWrapper){
        this.inputWrapper = inputWrapper;
    }
    
    public CHL_AngularResponeWrapper constructGridWrapper() {
        
    	List<SObject> accList = new List<sObject>();
		//this.gridInputWrapper.q = 'Wo';
		if(this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q))	{
			accList = CSM_AccountDataAccess.getAccountsBySOSL(this.inputWrapper);
		} /*else {
			accList = CSM_AccountDataAccess.getDetailsFromFieldSetByAccId(accountId,CSM_Util.getNamespace() + CHL_Constants.ACCOUNT_DETAILS_FIELDSET_NAME);
		}*/
		List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = CHL_ResponseWrapperUtil.getColumnHeaderFromFieldSet(CSM_Util.getNamespace() + CHL_Constants.ACCOUNT_DETAILS_FIELDSET_NAME, CSM_Constants.OBJ_ACCOUNT,true);
		List<CHL_AngularResponeWrapper.CHL_GridData> recordList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(accList, CSM_Util.getNamespace() + CHL_Constants.ACCOUNT_DETAILS_FIELDSET_NAME, CSM_Constants.OBJ_ACCOUNT); //,  gridInputWrapper.queryparams.oppId
		CHL_AngularResponeWrapper accWrap = new CHL_AngularResponeWrapper();	
		boolean selectionNeeded = this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q) ? false : true;	
		accWrap.gridConfiguration = CHL_Util.getGridExportOptions(true,'Accounts',selectionNeeded);
        accWrap.columnHeader = colHeaderList;
		accWrap.gridData = recordList;
		system.debug(' \n\n RenRelationship --- :: ' + json.serialize(accWrap));
		return accWrap;
     }

	 
}