/**
 * Created Date     : Feb, 18 2018
 * Developed By     : Vishal, Comity Designs, Inc.
 *
 * Function         : @description - Low Touch service for No Service Reason Code.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Vishal                   US3244             Feb 18, 2018    1.0         Low Touch service for No Service Reason Code.   
 *
 */
public with sharing class REN_LowTouchReasonsService extends REN_LowTouchBusinessLayer {
    
    private String objectName {get; set;}
    private Set<String> fieldsToAdd {get; set;}
    private final String NO_SERVICE = 'No Service';
    private String namespace = CSM_Util.getNamespace(); 
	
	/**To get object and correspoding additional fields**/
    private void getObjectAndAdditionalFields(){
		String namespace = CSM_Util.getNamespace();
 		objectName = namespace.toLowerCase()+'ren_field_mappings__c';
        fieldsToAdd = new Set<String>();
        fieldsToAdd.add(namespace+'ren_to_field_api_name__c');
        fieldsToAdd.add(namespace+'ren_default_value__c');
        fieldsToAdd.add('selected');
    }
    
    /**This method is used to set opportunity rejection status**/
    private REN_LowTouchPayLoad updateOppRejectStatus(REN_LowTouchUtil.LowTouchWrapper ltWrapper){
        REN_LowTouchUtil ltUtil = new REN_LowTouchUtil();
        ltWrapper.payLoad.status = 'SUCCESS';
		System.Savepoint sp;
		String oppId ;
		if(!ltWrapper.oppIdSet.isEmpty()){
			for(String opptyId :ltWrapper.oppIdSet) {
				oppId = opptyId;
			}	
		}
		String solExtNamespace = CSM_Util.nameSpacePrefixSolnExtn;
		boolean isFieldAvailable = CSM_AccessController.hasField('Opportunity', solExtNamespace + 'Commit_Level__c');
		List<REN_LowTouchPayLoad.Error> errorList = new List<REN_LowTouchPayLoad.Error>();
		List<REN_LowTouchPayLoad.mainData> mainData = ltWrapper.payLoad.data;
		try {
			if(String.isNotBlank(oppId)){
				sp = Database.setSavepoint();
				set<String> requestedFields = new set<String>{'Id' ,'StageName'};
                Opportunity op = REN_OpportunityDataAccess.getOpportunityById(oppId,requestedFields);
                sObject obj = (sObject) op;              
                List<REN_Renews_To__c> rliListToUpdate = new List<REN_Renews_To__c>();
                List<REN_Renews_To__c> rliList = REN_RenewRelationshipDataAccess.getLstRenRelationshipByRenewalStatus(new List<Opportunity>{op});
                if(rliList != null && !rliList.isEmpty()) {
                	obj.put('StageName' ,NO_SERVICE);                                  
                    OpportunityStage oppStage = REN_OpportunityDataAccess.getProbabilityValueByStage(NO_SERVICE);
                    obj.put('Probability' ,oppStage.DefaultProbability);
                    obj.put('REN_Notify_Opportunity_Owner__c' ,true);
                    if(isFieldAvailable) {
                    	obj.put('Commit_Level__c' ,'Black');
                    }
                    obj.put('REN_LT_Renewal_Details__c' ,ltWrapper.defaultValue);
                    //update op;
                    REN_OpportunityDataAccess.updateOpportunitySObject(new List<SObject>{obj},new List<String>{'StageName' ,'Probability','REN_Notify_Opportunity_Owner__c','REN_LT_Renewal_Details__c'});
                    for(REN_Renews_To__c rli : rliList){
                        rli.REN_Renewal_Status__c  = ltWrapper.apiName;
                        rliListToUpdate.add(rli);
                    }
                    if(rliListToUpdate != null && !rliListToUpdate.isEmpty()){
                        //update rliListToUpdate;
                        REN_RenewRelationshipDataAccess.updateRenewalRelationship(rliListToUpdate,new List<String>{'REN_Renewal_Status__c'});
                    }
                    
                } else {
                	ltWrapper.payLoad.status = 'ERROR';
                	errorList.add(new REN_LowTouchUtil().createErrorList('Exception', '', system.Label.REN_DO_NOT_RENEW, system.Label.REN_NO_RLI_OPP));
                	REN_HandleOpportunityStageUpdate.updateErrorLog(system.Label.REN_DO_NOT_RENEW, system.Label.REN_NO_RLI_OPP, oppId);
                    ltWrapper.payLoad.errors = errorList;
                }
            }
        } catch(Exception e) {
            Database.rollback(sp);
            ltWrapper.payLoad.status = 'ERROR';
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', '', system.Label.REN_DO_NOT_RENEW, e.getMessage()));
            REN_HandleOpportunityStageUpdate.updateErrorLog(system.Label.REN_DO_NOT_RENEW, e.getMessage(), oppId);
            ltWrapper.payLoad.errors = errorList;
        }
        return ltWrapper.payLoad;
    }
    
    /**This method is used to handle POST responce for No Service Reason Code**/
    public override String postResponse(Set<String> oppIdSet, REN_LowTouchPayLoad payLoad){
        REN_LowTouchPayLoad payLoadParent = new REN_LowTouchPayLoad();
        String  oppId = (new List<String>(oppIdSet))[0];
        REN_LowTouchUtil.LowTouchWrapper ltWrapper = new REN_LowTouchUtil.LowTouchWrapper();
        ltWrapper.payload = payLoad;
        ltWrapper.oppIdSet = new Set<ID> {oppId};
        for (REN_LowTouchPayLoad.mainData mainData : payLoad.data) {
        	if (mainData.attributes.get('selected') == 'true') {
	        	ltWrapper.apiName =  mainData.attributes.get(namespace+'ren_to_field_api_name__c');
	        	ltWrapper.defaultValue = mainData.attributes.get(namespace+'ren_default_value__c');
        	}	
        }
        
        payLoadParent = updateOppRejectStatus(ltWrapper);
        return JSON.serialize(payLoadParent);
    }
        
 	/**This method is used to get request to fetch field mapping details.**/
 	public override String getResponse(Set<String> oppIdSet){
		getObjectAndAdditionalFields();
        REN_LowTouchUtil lowTouchUtil = new REN_LowTouchUtil();
        
        REN_LowTouchPayLoad.MetaData meta = lowTouchUtil.getMetaData(objectName, null, fieldsToAdd);
        
        List<REN_Field_Mappings__c> renFieldMappingList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(null,'RENEW_STATUS_FIELD');        
       	System.debug('renFieldMappingList - '+renFieldMappingList);
		REN_LowTouchPayLoad payLoadParent = lowTouchUtil.getJSONData(objectName, renFieldMappingList, lowTouchUtil.apiNameSet);
		payLoadParent.meta = new REN_LowTouchPayLoad.definitionsMain();
		payLoadParent.meta.definitions = new Map<String, REN_LowTouchPayLoad.MetaData>();
		payLoadParent.meta.definitions.put(objectName, meta);
		payLoadParent.action = 'GET';
		system.debug('>>?? JSON.serialize(payLoadParent) ::'+JSON.serialize(payLoadParent));
		return JSON.serialize(payLoadParent);
	}
		
}