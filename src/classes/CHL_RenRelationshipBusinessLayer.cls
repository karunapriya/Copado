/**
  * @description : CHL_RenRelationshipBusinessLayer class is used to return JSON response to show the list of RenewalRelationship associated with the partner opportunity.
    @Params : It accepts input from CHL_GridInputWrapper.
*/
public with sharing class CHL_RenRelationshipBusinessLayer {

	//public CHL_AngularTabsInputWrapper inputWrapper;   
	public CHL_GridInputWrapper gridInputWrapper;      
	 
	/*public CHL_RenRelationshipBusinessLayer(CHL_AngularTabsInputWrapper inputWrapper){
        this.inputWrapper = inputWrapper;    
    }*/
    
 	public CHL_RenRelationshipBusinessLayer(CHL_GridInputWrapper inputWrapper){
        this.gridInputWrapper = inputWrapper;
    }
   
    /**
      * @description : This method returns the JSON object to show list of partner renew opportunity.
    */
    public CHL_AngularResponeWrapper constructGridWrapper() {
		String namespacePrefix = CSM_Util.getNamespace();
		List<SObject> renewalLst = new List<sObject>();
		List<CHL_AngularResponeWrapper.CHL_GridData> recordList = new List<CHL_AngularResponeWrapper.CHL_GridData>();
		boolean isGlobalSearch = this.gridInputWrapper.q != null && String.isNotBlank(this.gridInputWrapper.q) ? true : false;
        List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = CHL_ResponseWrapperUtil.getColumnHeaderFromFieldSet(namespacePrefix + CHL_Constants.PARTNER_RENEWAL_RELATIONSHIP_FIELDSET_NAME, namespacePrefix + CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP, isGlobalSearch);
		
		//this.gridInputWrapper.q = 'Wo';
		if(this.gridInputWrapper.q != null && String.isNotBlank(this.gridInputWrapper.q))	{
			Integer queryLimit = this.gridInputWrapper.lm == 5 ? 5 : 2000;
   			renewalLst = REN_RenewRelationshipDataAccess.getRenRelationshipBySOSL(this.gridInputWrapper);
		    //system.debug('renewalLst : '+renewalLst);
		    Set<Id>rliIdset = new Set<Id>();
		    //List<CHL_Partner_Renewal_Relationship__c> partnerRenwalList = CHL_PartnerRenRelationshipDataAccess.getPrtnrRenRelFromRenRel(new List<String>{'Id','CHL_Partner_Opportunity__c'},renewalLst);
			for(sObject prr:renewalLst) {
				rliIdset.add((ID)prr.get('Id')); //
			}
			List<SObject> rliLst = CHL_PartnerRenRelationshipDataAccess.getPartnerRenRealtionshipListByRLI(rliIdset,queryLimit);
		    system.debug('renewalLst AFTER : '+rliLst);
		   	recordList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(rliLst, namespacePrefix + CHL_Constants.PARTNER_RENEWAL_RELATIONSHIP_FIELDSET_NAME, namespacePrefix + 'CHL_Partner_Renewal_Relationship__c');
		} else {
			renewalLst = CHL_PartnerRenRelationshipDataAccess.getPartnerRenRealtionshipListFromFieldSet(gridInputWrapper.queryparams.oppId); ////gridInputWrapper.queryParams.oppID;
			recordList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(renewalLst, namespacePrefix + CHL_Constants.PARTNER_RENEWAL_RELATIONSHIP_FIELDSET_NAME, namespacePrefix + 'CHL_Partner_Renewal_Relationship__c',  gridInputWrapper.queryparams.oppId);
		}
		boolean selectionNeeded = this.gridInputWrapper.q != null && String.isNotBlank(this.gridInputWrapper.q) ? false : true;	
		CHL_AngularResponeWrapper contactWrap = new CHL_AngularResponeWrapper();		
		contactWrap.gridConfiguration = CHL_Util.getGridExportOptions(true,'Renewal Relationships',selectionNeeded);
        contactWrap.columnHeader = colHeaderList;
		contactWrap.gridData = recordList;
		//system.debug(' \n\n RenRelationship --- :: ' + json.serialize(contactWrap));
		return contactWrap;
    }
    
}