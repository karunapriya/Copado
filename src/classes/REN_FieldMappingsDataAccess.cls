public with sharing class REN_FieldMappingsDataAccess {

	public static List<REN_Field_Mappings__c> getFieldMappingListByConfig(String mappingNameNotInUse, String toObjName, String fromObjName){
		return getFieldMappingListByConfig( toObjName, fromObjName);
	}
	public static List<REN_Field_Mappings__c> getFieldMappingListByConfig(String toObjName, String fromObjName){
		List<String> fieldMappingsFieldList = new List<String>{REN_Constants.OBJ_FM_DEFAULT_VALUE, 
													REN_Constants.OBJ_FM_FIELD_DATA_TYPE,
													REN_Constants.OBJ_FM_FROM_FIELD_API_NAME,
													REN_Constants.OBJ_FM_FROM_OBJECT_API_NAME,
													REN_Constants.OBJ_FM_IS_REQUIRED,
													REN_Constants.OBJ_FM_TO_FIELD_API_NAME,
													REN_Constants.OBJ_FM_TO_OBJECT_API_NAME};
       	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_FM, fieldMappingsFieldList, CSM_Constants.DML_OPERATION_READ);
        return [Select Id, REN_Default_Value__c, REN_Field_Data_Type__c, 
        						REN_From_Field_API_Name__c, REN_From_Object_Api_Name__c, REN_Is_Required__c, 
        						REN_To_Field_API_Name__c, REN_To_Object_API_Name__c
        						From REN_Field_Mappings__c 
        						Where 
        						REN_To_Object_API_Name__c=:toObjName 
        						And REN_From_Object_Api_Name__c=:fromObjName ORDER BY REN_Is_Required__c DESC limit 500];
	}
	
	public static List<REN_Field_Mappings__c> retrieveAllFieldMappings(){
		List<String> fieldMappingsFieldList = new List<String>{REN_Constants.OBJ_FM_DEFAULT_VALUE, 
													REN_Constants.OBJ_FM_FIELD_DATA_TYPE,
													REN_Constants.OBJ_FM_FROM_FIELD_API_NAME,
													REN_Constants.OBJ_FM_FROM_OBJECT_API_NAME,
													REN_Constants.OBJ_FM_IS_REQUIRED,
													REN_Constants.OBJ_FM_TO_FIELD_API_NAME,
													REN_Constants.OBJ_FM_TO_OBJECT_API_NAME};
       	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_FM, fieldMappingsFieldList, CSM_Constants.DML_OPERATION_READ);
        return [Select Id, Name, REN_Default_Value__c, REN_Field_Data_Type__c, 
        						REN_From_Field_API_Name__c, REN_From_Object_Api_Name__c, REN_Is_Required__c, 
        						REN_To_Field_API_Name__c, REN_To_Object_API_Name__c
        						From REN_Field_Mappings__c 
        						ORDER BY REN_Is_Required__c DESC limit 1000];
	}
	public static List<REN_Field_Mappings__c> getFieldMappingListByCondition(String toDefaultValue,String toFieldValue, String fromObjName){
    List<String> fieldMappingsFieldList = new List<String>{REN_Constants.OBJ_FM_DEFAULT_VALUE,                           
                          REN_Constants.OBJ_FM_FROM_OBJECT_API_NAME,                          
                          REN_Constants.OBJ_FM_TO_FIELD_API_NAME};                          
         CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_FM, fieldMappingsFieldList, CSM_Constants.DML_OPERATION_READ);
        return [Select Id, REN_Default_Value__c,REN_From_Object_Api_Name__c, 
                    REN_To_Field_API_Name__c
                    From REN_Field_Mappings__c 
                    Where 
                    REN_Default_Value__c=:toDefaultValue And REN_To_Field_API_Name__c=:toFieldValue
                    And REN_From_Object_Api_Name__c=:fromObjName ORDER BY REN_Is_Required__c DESC limit 500];
  }
  
	public static List<REN_Field_Mappings__c> upsertFieldMappings(List<REN_Field_Mappings__c> fieldMappingsList){
		List<String> fieldMappingsFieldList = new List<String>{REN_Constants.OBJ_FM_DEFAULT_VALUE, 
													REN_Constants.OBJ_FM_FIELD_DATA_TYPE,
													REN_Constants.OBJ_FM_FROM_FIELD_API_NAME,
													REN_Constants.OBJ_FM_FROM_OBJECT_API_NAME,
													REN_Constants.OBJ_FM_IS_REQUIRED,
													REN_Constants.OBJ_FM_TO_FIELD_API_NAME,
													REN_Constants.OBJ_FM_TO_OBJECT_API_NAME,
													REN_Constants.OBJ_FM_NAME};

       	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_FM, fieldMappingsFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        upsert fieldMappingsList;
		return fieldMappingsList;
	}
	
	public static void deleteFieldMappings(List<REN_Field_Mappings__c> fieldMappingsList){
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_FM, null, CSM_Constants.DML_OPERATION_DELETE);
    	delete fieldMappingsList;
    } 
}