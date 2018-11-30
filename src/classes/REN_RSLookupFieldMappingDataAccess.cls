/**
 * Created Date		: Jun 12, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
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
 * Dilip					User Story				Jun 12, 2018			1.1					@description
 *
 */
public with sharing class REN_RSLookupFieldMappingDataAccess {

	//This method returns all the records matching relationship name with object API name.
	public static List<sObject> getLookupFieldMapSetting(Set<String> relationshipNameSet){
		
		if(relationshipNameSet != null && !relationshipNameSet.isEmpty()){
			String baseNamespace = CSM_Util.getNamespace();
			List<String> fieldNameList = new List<String>{baseNamespace + 'REN_Field_API_Name__c', baseNamespace + 'REN_Named_Credential__c', baseNamespace + 'REN_Named_Credential_URL_Extension__c', baseNamespace + 'REN_Object_API_Name__c', baseNamespace + 'REN_RS_Configuration__c'};
			
			CSM_Util.checkCRUD_FLS(baseNamespace + 'REN_RS_Lookup_Field_Mapping__c', fieldNameList, CSM_Constants.DML_OPERATION_READ);
			
			List<String> relationshipNameList = new List<String>(relationshipNameSet);
			String relationshipName = relationshipNameList[0];
			
			String queryString = 'Select Id, ' + baseNamespace + 'REN_Field_API_Name__c, ' + baseNamespace + 'REN_Named_Credential__c, ' + baseNamespace + 'REN_Named_Credential_URL_Extension__c, ' + baseNamespace + 'REN_Object_API_Name__c, ' + baseNamespace + 'REN_RS_Configuration__c from ' + baseNamespace + 'REN_RS_Lookup_Field_Mapping__c where ' + baseNamespace + 'REN_Object_API_Name__c =:relationshipName';
			
			List<sObject> lookupMapSettingObjList = Database.query(queryString);
			
			if(!lookupMapSettingObjList.isEmpty())
				return lookupMapSettingObjList;
		}
		
		return null;
		
	}
}