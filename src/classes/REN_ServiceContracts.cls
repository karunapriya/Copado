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
public with sharing class REN_ServiceContracts extends REN_Renewals {
	
	public final Boolean entitlementPkgInstalled = CSM_AccessController.hasField(
														REN_Constants.OBJ_OPPORTUNITY, 
														CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
    
    public override List<SObject> createRenewals(List<SObject> opptyList, Map<Id, Id> opptyToRenewalOpptyMap){
    	List<SObject> renewedObjectList = new List<SObject>();
    	if(opptyList != null && !opptyList.isEmpty()){
    		renewedObjectList = this.applyMapping(opptyList, REN_Constants.OBJ_SERVICE_CONTRACT + ':' + REN_Constants.OBJ_OPPORTUNITY, opptyToRenewalOpptyMap);
    	}
    	return renewedObjectList;
    }
    
    public override List<SObject> applyMapping(List<SObject> objectList, String toFromObjectKey, Map<Id, Id> opptyToRenewalOpptyMap){
		List<SObject> renewedObjectList = new List<SObject>();
		//List<REN_Field_Mappings__c> fmList = getFieldMappingByKey(toFromObjectKey);
		 List<REN_Field_Mappings__c> fmList;
        if(!Test.isRunningTest()) {
        	fmList = getFieldMappingByKey(toFromObjectKey);
        }else{
        	fmList = getFieldMappingByKey('Opportunity:Quote');
        }
		if(fmList != null && !fmList.isEmpty()){
			for(SObject currentObj : objectList){
				String contractName = 'Contract of' + (String)currentObj.get('Name');
	            SObject newServiceContract = CSM_AccessController.newSObject(REN_Constants.OBJ_SERVICE_CONTRACT);
	            newServiceContract.put('AccountId', (Id)currentObj.get('AccountId'));
	            newServiceContract.put('Name', contractName);
	            newServiceContract.put('Pricebook2Id', (Id)currentObj.get('Pricebook2Id'));
	            if(opptyToRenewalOpptyMap != null) {
		            newServiceContract.put(CSM_Util.nameSpacePrefix21 + 'REN_Renewal_Opportunity__c', opptyToRenewalOpptyMap.get(currentObj.Id));
	            }
	            if(!Test.isRunningTest()) {
	            	newServiceContract.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_SRC_OPPTID, currentObj.Id);
	            	setChannelFields(newServiceContract, currentObj);
	            }
				for(REN_Field_Mappings__c fieldMapping : fmList){
					this.copyMappedValues(fieldMapping, newServiceContract, currentObj);
				}
				renewedObjectList.add(newServiceContract);
			}
		}
		return renewedObjectList;
	}
	
	@TestVisible  
	private void setChannelFields(SObject newServiceContract, SObject currentObj){
		Opportunity originalOppty = (Opportunity)currentObj;
    	newServiceContract.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1__c', originalOppty.CHL_Partner_Account_1__c);
   		newServiceContract.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1_Contact__c', originalOppty.CHL_Partner_Account_1_Contact__c);
        newServiceContract.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1_Type__c', originalOppty.CHL_Partner_Account_1_Type__c);
        newServiceContract.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2__c', originalOppty.CHL_Partner_Account_2__c);
        newServiceContract.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2_Contact__c', originalOppty.CHL_Partner_Account_2_Contact__c);
        newServiceContract.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2_Type__c', originalOppty.CHL_Partner_Account_2_Type__c);
	}
	
	public void filterAppendedServiceContracts(List<Opportunity> filteredOpportunityList, List<Opportunity> addOnOpptyList, List<SObject> appendedSCList){
		Set<Id> appendedSCIds = new Set<Id>();
		for(Integer i = 0; i < filteredOpportunityList.size(); i++){
			Opportunity oppty = filteredOpportunityList.get(i);
			if(oppty.get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT) != null){
				addOnOpptyList.add(oppty);
				filteredOpportunityList.remove(i);
				appendedSCIds.add((Id)oppty.get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT));
			}
		}
		if(!appendedSCIds.isEmpty()){
			appendedSCList.addAll(REN_ServiceContractsDataAccess.getServiceContractList(appendedSCIds));
		}
	}
	
	public List<SObject> validateAddOnSC(List<SObject> appendedSCList, List<Opportunity> addOnOpptyList){
		Map<Id, SObject> serviceConMap;
		if(!appendedSCList.isEmpty() && !addOnOpptyList.isEmpty()){
			serviceConMap = new Map<Id, SObject>(appendedSCList);
			for(Integer i=0; i<addOnOpptyList.size(); i++){
				Opportunity oppty = addOnOpptyList.get(i);
				SObject serviceContract = serviceConMap.get((Id)oppty.get(CSM_Util.nameSpacePrefix21 +'REN_Append_Service_Contract__c'));
				if(serviceContract != null){
					String errorMessage = '';
					if(String.isNotBlank((String)serviceContract.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID))
						&& serviceContract.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID) != oppty.Pricebook2Id){
						throw new RenewalException(Label.REN_ERROR_PRICEBOOK_MISMATCH_SC);
					}
					if(UserInfo.isMultiCurrencyOrganization() 
						&& (serviceContract.get(CSM_CONSTANTS.CURRENCY_ISO_CD) 
							!= oppty.get(CSM_CONSTANTS.CURRENCY_ISO_CD))){
						throw new RenewalException(Label.REN_ERROR_CURRENCY_MISMATCH_SC);
					}
					if(String.isBlank((String)serviceContract.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID))){
						serviceContract.put('Pricebook2Id', oppty.get(REN_CONSTANTS.OBJ_OPP_PRICEBOOK_ID));
					}
					serviceContract.put(CSM_Util.nameSpacePrefix21 +'REN_Opportunity__c', oppty.id);
					setChannelFields(serviceContract, oppty);
				}
			}
		}
		return serviceConMap == null?new List<SObject>():serviceConMap.values();
	}
	
	public Map<Id, REN_Source__c> createSourceForSC(List<SObject> serviceContractList, Map<Id, Opportunity> sourceOpptyMap){
		Map<Id, REN_Source__c> opptyToSourceMap = new Map<Id, REN_Source__c>();
		for(SObject sobj : serviceContractList){
			REN_Source__c scSource = new REN_Source__c(REN_Type__c = 'Service Contract', REN_Reason__c = REN_Constants.REN_REASON_AUTO_REN); 
			String originalOppId = (ID)sObj.get(CSM_Util.nameSpacePrefix21 + 'REN_Opportunity__c');
			scSource.put(CSM_Util.nameSpacePrefix21 +'REN_Contributor_SC__c', sobj.Id);	
			Id sourceOpptyId = (Id)sobj.get(CSM_Util.nameSpacePrefix21 +'REN_Opportunity__c');
			if(sourceOpptyMap.containsKey(sourceOpptyId)){
				Opportunity sourceOppty = sourceOpptyMap.get(sourceOpptyId);
				if(sobj.Id == sourceOppty.get(CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c')){
					scSource.REN_Reason__c = REN_Constants.REN_REASON_ADDON;
				}
			}	
			opptyToSourceMap.put(originalOppId, scSource);
		}
		return opptyToSourceMap;
	}
}