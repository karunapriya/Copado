/**
 * Created Date		: Sep 2, 2016
 * Developed By		: Amit, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Amit					User Story				Sep 2, 2016			1.1					@description
 *
 */
public with sharing class REN_Opportunities extends REN_Renewals {

	public static Boolean NOTIFY_OWNER = false;
    public override Map<Id, SObject> createRenewalsMap(List<SObject> opptyList, Map<Id, Id> opptyToRenewalOpptyMap){
    	Map<Id, SObject> renewedObjectMap = new Map<Id, SObject>();
    	if(opptyList != null && !opptyList.isEmpty()){
    		renewedObjectMap = this.applyMappingMap(opptyList, REN_Constants.OBJ_OPPORTUNITY + ':' + REN_Constants.OBJ_OPPORTUNITY);
    	}
    	return renewedObjectMap;
    }
    
    public override Map<Id, SObject> applyMappingMap(List<SObject> objectList, String toFromObjectKey){
		Map<Id, SObject> renewedObjectMap = new Map<Id, SObject>();
		//List<REN_Field_Mappings__c> fmList = REN_RenewReferenceData.getInstance().fieldMappingsMap.get(toFromObjectKey);
		List<REN_Field_Mappings__c> fmList = getFieldMappingByKey(toFromObjectKey);
		if(fmList != null && !fmList.isEmpty()){
			for(SObject currentObj : objectList){
				SObject renewedSobj = new Opportunity();
				renewedSobj.put('REN_Is_CLM_Renewal__c', true);
				renewedSobj.put('AccountId', (Id)currentObj.get('AccountId'));
				renewedSobj.put('Pricebook2Id', (Id)currentObj.get('Pricebook2Id'));
				// Below flag is not required from batch. It will be only set for realtime oppty resolution.
				renewedSobj.put('REN_Notify_Opportunity_Owner__c', NOTIFY_OWNER);
				for(REN_Field_Mappings__c fieldMapping : fmList){
					this.copyMappedValues(fieldMapping, renewedSobj, currentObj);
				}
				renewedObjectMap.put(currentObj.Id, renewedSobj);
			}
		}
		return renewedObjectMap;
	}
	
	public List<Opportunity> findAddOnOpportunities(List<Opportunity> filteredOpportunityList){
    	List<Opportunity> opptyListWithAddOn = new List<Opportunity>();
		if(filteredOpportunityList != null && !filteredOpportunityList.isEmpty()){
			for(Integer i = 0; i<filteredOpportunityList.size(); i++){
				Opportunity filteredOppty = filteredOpportunityList.get(i);
				if(filteredOppty.REN_Append_Renewal_Opportunity__c != null){
					opptyListWithAddOn.add(filteredOppty);
					filteredOpportunityList.remove(i);
				}
			}
		}
		return opptyListWithAddOn;
    }
    
    public void handleOpportunityWithAddOn(Map<Id,Opportunity> opptyWithOriginalMap,List<Opportunity> addOnOpportunityList, List<REN_Source__c> sourceList){
    	if(!opptyWithOriginalMap.isEmpty()&&!addOnOpportunityList.isEmpty()){
    		List<Opportunity> addOnOpptyForUpdate = validateAddOn(opptyWithOriginalMap,addOnOpportunityList);
    		if(addOnOpptyForUpdate != null && !addOnOpptyForUpdate.isEmpty()){
    			update addOnOpptyForUpdate;
    		}
    		if(!addOnOpportunityList.isEmpty()){
    			sourceList = sourceList == null ? new List<REN_Source__c>() : sourceList;
    			for(Opportunity oppty :addOnOpportunityList){
	    			sourceList.add(new REN_Source__c(REN_Inheriting_Opportunity__c = oppty.REN_Append_Renewal_Opportunity__c, 
	    							REN_Contributor__c = oppty.Id, REN_Type__c = 'Opportunity', 
	    							REN_Reason__c = REN_Constants.REN_REASON_ADDON));
    			}
    		}
    	}
    }
    
    public List<REN_Source__c> createSource(Map<Id, SObject> source2RenewOpptyMap){
		List<REN_Source__c> sourceList = new List<REN_Source__c>();
		SObject renewedOppty;
		if(!source2RenewOpptyMap.keySet().isEmpty()){
			for(Id sourceOpptyId : source2RenewOpptyMap.keySet()){
				renewedOppty = source2RenewOpptyMap.get(sourceOpptyId);
				sourceList.add(new REN_Source__c(REN_Inheriting_Opportunity__c = renewedOppty.id,
													REN_Contributor__c = sourceOpptyId, 
													REN_Type__c = 'Opportunity', 
													REN_Reason__c = REN_Constants.REN_REASON_AUTO_REN));
			}
												
		}
		return sourceList;
	}
    
    public void handleOpportunityWithAddOn(Map<Id,Opportunity> opptyWithOriginalMap,List<Opportunity> addOnOpportunityList){
    	
    	if(!opptyWithOriginalMap.isEmpty()&&!addOnOpportunityList.isEmpty()){
    		List<Opportunity> addOnOpptyForUpdate = validateAddOn(opptyWithOriginalMap,addOnOpportunityList);
    	}
    }
    
    private List<Opportunity> validateAddOn(Map<Id,Opportunity> opptyWithOriginalMap,List<Opportunity> opptyWithAddOnList){
    	Set<String> addOnOpptyIds = new Set<String>();
    	List<Opportunity> opptyWithAddOnDetailList = new List<Opportunity>();
       
    	for(Opportunity oppty : opptyWithAddOnList){
    		addOnOpptyIds.add(oppty.Id);
    	}
    	if(UserInfo.isMultiCurrencyOrganization()){
			opptyWithAddOnDetailList = REN_OpportunityDataAccess.getPricebookAndCurrencyForOppandAppendOpp(addOnOpptyIds);
		}
		else{
			opptyWithAddOnDetailList = REN_OpportunityDataAccess.getPricebookForOppandAppendOpp(addOnOpptyIds);
		}
		Map<Id, Opportunity> opptyWithAddOnDetailMap = new Map<Id, Opportunity>(opptyWithAddOnDetailList);
		List<Opportunity> addOnOpptyForUpdate = new List<Opportunity>();
		for(Integer i = 0; i < opptyWithAddOnList.size(); i++){
			Opportunity oppty =opptyWithAddOnList.get(i);
            Opportunity opptyWithAddOnDetail = opptyWithAddOnDetailMap.get(oppty.Id);
			String errorMessage = '';
			if(String.isNotBlank(opptyWithAddOnDetail.REN_Append_Renewal_Opportunity__r.Pricebook2Id)
				&& opptyWithAddOnDetail.REN_Append_Renewal_Opportunity__r.Pricebook2Id != opptyWithAddOnDetail.Pricebook2Id){
				errorMessage = Label.REN_ERROR_PRICEBOOK_MISMATCH_OPP+'\n';
				throw new RenewalException(errorMessage);
			}
			if(UserInfo.isMultiCurrencyOrganization() 
				&& (opptyWithAddOnDetail.getSObject('REN_Append_Renewal_Opportunity__r').get(CSM_CONSTANTS.CURRENCY_ISO_CD) 
					!= opptyWithAddOnDetail.get(CSM_CONSTANTS.CURRENCY_ISO_CD))){
				errorMessage = errorMessage + Label.REN_ERROR_CURRENCY_MISMATCH_OPP; 
				throw new RenewalException(errorMessage);
			}
			if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId') 
				&& opptyWithAddOnDetail.getSObject('REN_Append_Renewal_Opportunity__r').get('SyncedQuoteId') != null) {
				errorMessage = String.format(Label.REN_MSG_OPP_HAS_QUOTE_IN_RR_EDIT_TRIGGER, 
									new String[]{(String)(opptyWithAddOnDetail.getSObject('REN_Append_Renewal_Opportunity__r').get('Name')), 
										(String)(opptyWithAddOnDetail.get('REN_Append_Renewal_Opportunity__c'))});
				throw new RenewalException(errorMessage);
			}
			if(String.isBlank(opptyWithAddOnDetail.REN_Append_Renewal_Opportunity__r.Pricebook2Id)){
				Opportunity appOpportunity = (Opportunity)oppty.getSObject('REN_Append_Renewal_Opportunity__r');
				appOpportunity.put('Pricebook2Id', oppty.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID));
				addOnOpptyForUpdate.add(appOpportunity);
			}
		}
		return addOnOpptyForUpdate;
    }
}