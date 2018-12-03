public with sharing class RenewableLineItemDataAccess {
    public static List<REN_Value_Mapping__c> getValueMappingRec(String recordKey){
     	List<REN_Value_Mapping__c> valueMappingList = new List<REN_Value_Mapping__c>();    
        List<String> fcFieldList = new List<String>{Constants.OBJ_RC_RECORD_KEY,Constants.REN_VALUE};
        Util.checkCRUD_FLS(Constants.REN_OBJ_VALUE_MAPPING, fcFieldList, Constants.DML_OPERATION_READ);

        if(!String.isEmpty(recordKey)){
          	valueMappingList = [select id, name,
    								REN_Record_Key__c,
    								REN_Value__c
          					from REN_Value_Mapping__c
          					where REN_Record_Key__c = :recordKey
          					limit 1];
    	}
        return valueMappingList;
    }
}