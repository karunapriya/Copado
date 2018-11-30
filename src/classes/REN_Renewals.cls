/**
 * Created Date		: Sep 13, 2016
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
 * Amit					User Story				Sep 13, 2016			1.1					@description
 *
 */
public virtual with sharing class REN_Renewals implements REN_IMapping {
	
	public virtual List<Opportunity> applyOpportunityCriteria(Set<Id> opportunityIds, String renewConfigName, String toFromObjKey){ 
		List<Opportunity> filteredOpportunityList = new List<Opportunity>();
    	if(opportunityIds != null && !opportunityIds.isEmpty()){
	    	REN_Renew_Configuration__c renewConfiguration = REN_RenewReferenceData.getInstance().renewalConfigMap.get(renewConfigName);
	    	if(validateLineCriteria(renewConfiguration) && String.isNotBlank(renewConfiguration.REN_Filter_Criteria__c)){
                Set<String> knownFields=new Set<String>{'REN_Append_Renewal_Opportunity__c','REN_Append_Renewal_Opportunity__r.Name', 'Pricebook2Id', 'Name', 'Description', 'AccountId', 'CHL_Partner_Account_1__c', 'CHL_Partner_Account_1_Contact__c', 'CHL_Partner_Account_1_Type__c', 'CHL_Partner_Account_2__c', 'CHL_Partner_Account_2_Contact__c', 'CHL_Partner_Account_2_Type__c'};
                if (CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c')){
                    knownFields.add(CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c');
                }
                knownFields.addAll(getMappingFieldsToQuery(toFromObjKey));
				filteredOpportunityList = (List<Opportunity>)REN_OpportunityDataAccess.getFilteredRecordsList(
																				'Opportunity', 
                   																knownFields, 
																				opportunityIds, 
																				renewConfiguration.REN_Filter_Criteria__c, 
																				null,
																				null);
	    	}
    	}
    	return filteredOpportunityList;
	}
	
	public virtual List<OpportunityLineItem> applyOpliCriteria(Set<Id> opportunityIds, String renewConfigName){
		List<OpportunityLineItem> filteredOpliList = new List<OpportunityLineItem>();
    	if(opportunityIds != null && !opportunityIds.isEmpty()){
	    	REN_Renew_Configuration__c renewConfiguration = REN_RenewReferenceData.getInstance().renewalConfigMap.get(renewConfigName);
	    	// No need to query OPLIs again. As we are querying all the fields in this query.
	    	if(renewConfiguration.REN_Is_Active__c && String.isNotBlank(renewConfiguration.REN_Filter_Criteria__c)){
				filteredOpliList = (List<OpportunityLineItem>)REN_OpportunityLineItemDataAccess.getFilteredRecords('OpportunityLineItem', 
																					new Set<String>(), 
																					opportunityIds, 
																					renewConfiguration.REN_Filter_Criteria__c, 
																					new Set<String>());
	    	}else if(renewConfiguration.REN_Is_Active__c && String.isBlank(renewConfiguration.REN_Filter_Criteria__c)){
	    		filteredOpliList = (List<OpportunityLineItem>)REN_OpportunityLineItemDataAccess.getFilteredRecords('OpportunityLineItem', 
																					new Set<String>(), 
																					opportunityIds, 
																					null, 
																					new Set<String>());
	    	}
    	}
    	return filteredOpliList;
	}
	
	public virtual List<SObject> createRenewals(List<SObject> sObjList, Map<Id, Id> sourceToRenewalMap){return null;}
	public virtual Map<Id, SObject> createRenewalsMap(List<SObject> sObjList, Map<Id, Id> sourceToRenewalMap){return null;}
	
	public virtual Set<String> getMappingFieldsToQuery(String toFromObjectKey){
		List<REN_Field_Mappings__c> fmList = getFieldMappingByKey(toFromObjectKey);
		return REN_Util.getFromFldsToQuery(fmList);
	}
	
	public virtual List<REN_Field_Mappings__c> getFieldMappingByKey(String toFromObjectKey) {
		List<REN_Field_Mappings__c> fmList = REN_RenewReferenceData.getInstance().fieldMappingsMap.get(toFromObjectKey);
		if(fmList == null){
			String[] toFromObjects = toFromObjectKey.split(':');
			throw new RenewalException(String.format(Label.REN_LBL_MAPPINGS_ERROR_MSG, 
								new String[]{toFromObjects[1], toFromObjects[0]}));
		}
		return fmList;
	}
	
	public virtual SObject copyMappedValues(REN_Field_Mappings__c fieldMapping, SObject renewedSObject, SObject currentObj){
		if(String.isNotBlank(fieldMapping.REN_Default_Value__c)){
            if(fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Currency))
            	|| fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Double))){
                renewedSObject.put(fieldMapping.REN_To_Field_API_Name__c, Double.valueOf(fieldMapping.REN_Default_Value__c));
            }else if(fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Integer))
            	|| fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Percent))){
                renewedSObject.put(fieldMapping.REN_To_Field_API_Name__c, Integer.valueOf(fieldMapping.REN_Default_Value__c));
            }else if(fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.DateTime))){
                renewedSObject.put(fieldMapping.REN_To_Field_API_Name__c, DateTime.valueOf(fieldMapping.REN_Default_Value__c + ' 00:00:00'));
            }else if(fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Date))){
                renewedSObject.put(fieldMapping.REN_To_Field_API_Name__c, Date.valueOf(fieldMapping.REN_Default_Value__c + ' 00:00:00'));
            }else if(fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Boolean))){
                renewedSObject.put(fieldMapping.REN_To_Field_API_Name__c, Boolean.valueOf(fieldMapping.REN_Default_Value__c));
            }else{
                renewedSObject.put(fieldMapping.REN_To_Field_API_Name__c, fieldMapping.REN_Default_Value__c);
            }
        }else if(String.isNotBlank(fieldMapping.REN_From_Field_API_Name__c)){
            renewedSObject.put(fieldMapping.REN_To_Field_API_Name__c, currentObj.get(fieldMapping.REN_From_Field_API_Name__c));
        }
        if (UserInfo.isMultiCurrencyOrganization() 
        		&& !(renewedSObject.getSObjectType().getDescribe().getName().equalsIgnoreCase('OpportunityLineItem'))
        		&& !(renewedSObject.getSObjectType().getDescribe().getName().equalsIgnoreCase('Quote'))
        		&& !(renewedSObject.getSObjectType().getDescribe().getName().equalsIgnoreCase('QuoteLineItem'))
        		&& !(renewedSObject.getSObjectType().getDescribe().getName().equalsIgnoreCase('ContractLineItem'))){
				renewedSObject.put('CurrencyIsoCode', (String)currentObj.get('CurrencyIsoCode'));
		}
        return renewedSObject;
	}
	
	private Boolean validateLineCriteria(REN_Renew_Configuration__c renewConfiguration){
		Boolean isLineCriteriaValid = false;
    	Set<String> lineCriteriaSet = new Set<String>();
		if(renewConfiguration != null && renewConfiguration.Line_Criteria__r != null){
			for(REN_Line_Criteria__c criteria : renewConfiguration.Line_Criteria__r) {
				lineCriteriaSet.add(criteria.RLM_Field_Name__c);
			}  
			if(renewConfiguration.REN_Is_Active__c 
				&& renewConfiguration.REN_Filter_Criteria__c != null 
				&& lineCriteriaSet.contains(REN_Constants.OBJ_RC_OPPORTUNITY_STAGE)){
				isLineCriteriaValid = true;
			}
		}
		return isLineCriteriaValid;
	}
	
	public virtual List<SObject> applyMapping(List<SObject> objectList, String toFromObjectKey){
		return null;
	}
	
	public virtual List<SObject> applyMapping(List<SObject> objectList, String toFromObjectKey, Map<Id, Id> sourceToRenewalMap){
		return null;
	}
	
	public virtual Map<Id, SObject> applyMappingMap(List<SObject> objectList, String toFromObjectKey){
		return null;
	}
	
	public class RenewalException extends Exception {}
}