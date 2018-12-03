/**
 * Created Date		: Apr 19, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: @description - Low Touch service for No Service Reason Code.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Bhagyashri					US3244				Apr 19, 2018			1.1			@description - Low Touch service for No Service Reason Code.
 *
 */
public with sharing class REN_ReasonsService extends REN_JSONAPIBusinessLayer {
    
    private String objectName {get; set;}
    private Set<String> fieldsToAdd {get; set;}
    private final String NO_SERVICE = 'No Service';
    private String namespace = CSM_Util.getNamespace(); 
	
	/**To get object and correspoding additional fields**/
    private void getObjectAndAdditionalFields(){
 		objectName = namespace.toLowerCase()+'ren_field_mappings__c';
        fieldsToAdd = new Set<String>();
        fieldsToAdd.add('ren_to_field_api_name__c');
        fieldsToAdd.add('ren_default_value__c');
        fieldsToAdd.add('selected');
    }
    
    /**This method is used to set opportunity rejection status**/
    private REN_JSONAPIPayLoad updateOppRejectStatus(REN_LowTouchUtil.LowTouchWrapper ltWrapper){
        REN_LowTouchUtil ltUtil = new REN_LowTouchUtil();
        ltWrapper.payLoad.status = 'SUCCESS';
		System.Savepoint sp;
		String oppId = (new List<Id>(ltWrapper.oppIdSet))[0];
		String solExtNamespace = CSM_Util.nameSpacePrefixSolnExtn;
		boolean isFieldAvailable = CSM_AccessController.hasField('Opportunity', solExtNamespace + 'Commit_Level__c');
		List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
		List<REN_JSONAPIPayLoad.mainData> mainData = ltWrapper.payLoad.data;
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
                    	obj.put(solExtNamespace + 'Commit_Level__c' ,'Black');
                    }
                    obj.put('REN_LT_Renewal_Details__c' ,ltWrapper.fieldDefaultValue);
                    //update op;
                    for(REN_Renews_To__c rli : rliList){
                        rli.REN_Renewal_Status__c  = ltWrapper.fieldApiName;
                        rliListToUpdate.add(rli);
                    }
                    if(rliListToUpdate != null && !rliListToUpdate.isEmpty()){
                        //update rliListToUpdate;
                        REN_RenewRelationshipDataAccess.updateRenewalRelationship(rliListToUpdate,new List<String>{'REN_Renewal_Status__c'});
                    }
                    REN_OpportunityMetricsBusiness.setRliMetricsFieldsOnOpportunity(new List<SObject>{obj});
                    REN_OpportunityDataAccess.updateOpportunitySObject(new List<SObject>{obj},new List<String>{'StageName' ,'Probability','REN_Notify_Opportunity_Owner__c','REN_LT_Renewal_Details__c'});
                    
                } else {
                	ltWrapper.payLoad.status = 'ERROR';
                	errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_DO_NOT_RENEW, system.Label.REN_NO_RLI_OPP, system.Label.REN_NO_RLI_OPP));
                	REN_LowTouchUtil.updateErrorLog(system.Label.REN_DO_NOT_RENEW, system.Label.REN_NO_RLI_OPP, oppId);
                    ltWrapper.payLoad.errors = errorList;
                }
            }
        } catch(Exception e) {
            Database.rollback(sp);
            ltWrapper.payLoad.status = 'ERROR';
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_DO_NOT_RENEW, system.Label.REN_DO_NOT_RENEW, e.getMessage()));
            REN_LowTouchUtil.updateErrorLog(system.Label.REN_DO_NOT_RENEW, e.getMessage(), oppId);
            ltWrapper.payLoad.errors = errorList;
        }
        return ltWrapper.payLoad;
    }
    
    /**This method is used to handle POST responce for No Service Reason Code**/
    public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
        REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
        String  oppId = (new List<String>(oppIdSet))[0];
        REN_LowTouchUtil.LowTouchWrapper ltWrapper = new REN_LowTouchUtil.LowTouchWrapper();
        ltWrapper.payload = payLoad;
        ltWrapper.oppIdSet = new Set<ID> {oppId};
        for (REN_JSONAPIPayLoad.mainData mainData : payLoad.data) {
        	if (mainData.attributes.get('selected') == 'true') {
	        	ltWrapper.fieldApiName =  mainData.attributes.get('ren_to_field_api_name__c');
	        	ltWrapper.fieldDefaultValue = mainData.attributes.get('ren_default_value__c');
        	}	
        }
        
        payLoadParent = updateOppRejectStatus(ltWrapper);
        return JSON.serialize(payLoadParent);
    }
        
 	/**This method is used to get request to fetch field mapping details.**/
 	public override String getResponse(Set<String> oppIdSet){
		getObjectAndAdditionalFields();
        REN_LowTouchUtil lowTouchUtil = new REN_LowTouchUtil();
        
        REN_JSONAPIPayLoad.MetaData meta = lowTouchUtil.getMetaData(objectName, null, fieldsToAdd);
        system.debug('>>?? JSON.serialize(meta) ::'+JSON.serialize(meta));
        List<REN_Field_Mappings__c> renFieldMappingList = REN_FieldMappingsDataAccess.getFieldMappingListByConfig(null,'RENEW_STATUS_FIELD');        
       	System.debug('renFieldMappingList - '+renFieldMappingList);
		REN_JSONAPIPayLoad payLoadParent = lowTouchUtil.getJSONData(objectName, renFieldMappingList, lowTouchUtil.apiNameSet);
		payLoadParent.meta = new REN_JSONAPIPayLoad.definitionsMain();
		payLoadParent.meta.definitions = new Map<String, REN_JSONAPIPayLoad.MetaData>();
		payLoadParent.meta.definitions.put(objectName, meta);
		payLoadParent.action = 'GET';
		payLoadParent.status = 'SUCCESS';
		system.debug('>>?? JSON.serialize(payLoadParent) ::'+JSON.serialize(payLoadParent));
		return JSON.serialize(payLoadParent);
	}
		
}