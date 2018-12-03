/**
  * @description : CHL_ContactBusinessLayer class is used to return JSON response to show the list of contacts belongs to the master opportunity's account .
    @Params : It accepts input from CHL_GridInputWrapper.
*/
public with sharing class CHL_ContactBusinessLayer {
	
	//public CHL_AngularTabsInputWrapper inputWrapper;  
	public CHL_GridInputWrapper gridInputWrapper;      
	 
	/*public CHL_ContactBusinessLayer(CHL_AngularTabsInputWrapper inputWrapper){
        this.inputWrapper = inputWrapper;    
    }*/
    
 	public CHL_ContactBusinessLayer(CHL_GridInputWrapper inputWrapper){
        this.gridInputWrapper = inputWrapper;
    } 
   
    /**
      * @description : This method returns the JSON object to show list of contacts associated with the  master opportunity.
    */
    public CHL_AngularResponeWrapper constructGridWrapper() {
    	boolean isGlobalSearch = this.gridInputWrapper.q != null && String.isNotBlank(this.gridInputWrapper.q) ? true : false;
        List <CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = CHL_ResponseWrapperUtil.getColumnHeaderFromFieldSet(CSM_Util.getNamespace()+CHL_Constants.CONTACT_DETAILS_FIELDSET_NAME, CHL_Constants.OBJ_CONTACT,isGlobalSearch);

		List <SObject> contactLst = getContactList();		
		List <CHL_AngularResponeWrapper.CHL_GridData> recordList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(contactLst, CSM_Util.getNamespace()+CHL_Constants.CONTACT_DETAILS_FIELDSET_NAME, CHL_Constants.OBJ_CONTACT);
		//CHL_AngularResponeWrapper.CHL_GridConfiguration grdConfig = new CHL_AngularResponeWrapper.CHL_GridConfiguration();
		//boolean selectionNeeded = this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q) ? false : true;	
		
		CHL_AngularResponeWrapper contactWrap = new CHL_AngularResponeWrapper();
		contactWrap.columnHeader = colHeaderList;
		contactWrap.gridData = recordList;
		contactWrap.gridConfiguration = CHL_Util.getGridExportOptions(false,'',false);
		system.debug(' \n\n ContactList --- :: ' + json.serialize(contactWrap));
		return contactWrap;
    }

	 public List<SObject> getContactList(){
    	List <sObject> contactList = new List<sObject>();
    	String queryString = '';
    	Set<String> accIdSet = new Set<String>() ;
    	//list of contact associated with the Master Opp. Account.
    	if(this.gridInputWrapper.q != null && String.isNotBlank(this.gridInputWrapper.q))	{
    		contactList = CSM_ContactDataAccess.getContactsBySOSL(this.gridInputWrapper);
    	} else {
    		if(gridInputWrapper.queryParams != null && gridInputWrapper.queryParams.oppId != null){
				Set<Id> partnerOppIDSet = new  Set<Id>();
				partnerOppIDSet.add(gridInputWrapper.queryParams.oppId);
				List<CHL_Partner_Opportunity__c> partnerOppList = CHL_PartnerOpportunityDataAccess.getPartnerOpportunityDataById(partnerOppIDSet);
				
				if(!partnerOppList.isEmpty()){
					accIdSet.add(partnerOppList[0].CHL_Opportunity__r.accountID);
				}
			} else if(this.gridInputWrapper.queryParams.accountID != null){
				accIdSet.add(this.gridInputWrapper.queryParams.accountID);
			}
			queryString = CHL_Util.getQueryStringFromFieldSet(CSM_Util.getNamespace()+CHL_Constants.CONTACT_DETAILS_FIELDSET_NAME, CHL_Constants.OBJ_CONTACT);
			contactList = CSM_ContactDataAccess.getContactListByAccountFromQueryStr(queryString, accIdSet);
    	}
		return contactList;
    }
	
}