/**
 * Created Date		: Sep 14, 2016
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
 * Amit					User Story				Sep 14, 2016			1.1					@description
 * 
 */
public with sharing class REN_RenewReferenceData {

    private REN_RenewReferenceData() {}
	
	private static REN_RenewReferenceData singletonInstance;
	
	public static REN_RenewReferenceData getInstance(){
		if(singletonInstance == null){
			singletonInstance = new REN_RenewReferenceData();
		}
		return singletonInstance;
	}
	
	public Map<String, REN_Renew_Configuration__c> renewalConfigMap{
		get{
			if(renewalConfigMap == null){
				renewalConfigMap = getRenewConfigDataMap();
			}
			return renewalConfigMap;
		}
		private set;
	} 
	
	public Map<String, List<REN_Field_Mappings__c>> fieldMappingsMap{
		get{
			if(this.fieldMappingsMap == null){
				fieldMappingsMap = getFieldMappingsMapByObject();
			}
			return fieldMappingsMap;
		}
		private set;
	}
	
	private Map<String, REN_Renew_Configuration__c> getRenewConfigDataMap(){
		Map<String, REN_Renew_Configuration__c> renewlaConfigMap = new Map<String, REN_Renew_Configuration__c>();
		for(REN_Renew_Configuration__c rConfig: REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(null)){
			renewlaConfigMap.put(rConfig.REN_Record_Key__c, rConfig);
		}
		return renewlaConfigMap;
	}
	
	private Map<String, List<REN_Field_Mappings__c>> getFieldMappingsMapByObject(){
		Map<String, List<REN_Field_Mappings__c>> fieldMappingsMap = new Map<String, List<REN_Field_Mappings__c>>();
		for(REN_Field_Mappings__c fieldMapping : REN_FieldMappingsDataAccess.retrieveAllFieldMappings()){
			String toFromObjectKey = fieldMapping.REN_To_Object_API_Name__c + ':' + fieldMapping.REN_From_Object_Api_Name__c;
			List<REN_Field_Mappings__c> fmList = fieldMappingsMap.get(toFromObjectKey);
			if(fmList == null){
				fmList = new List<REN_Field_Mappings__c>();
			}
			fmList.add(fieldMapping);
			fieldMappingsMap.put(toFromObjectKey, fmList);
		}
		return fieldMappingsMap;
	}
}