public with sharing class REN_ValueMappingDataAccess {
     public static List<REN_Value_Mapping__c> saveValueMappingRecord(List<REN_Value_Mapping__c> valueMappingRecord){        
        List<String> fcFieldList = new List<String>{REN_Constants.OBJ_RC_RECORD_KEY,REN_Constants.REN_VALUE};
        CSM_Util.checkCRUD_FLS(REN_Constants.REN_OBJ_VALUE_MAPPING, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        upsert valueMappingRecord;          
        return valueMappingRecord;
    } 
    public static List<REN_Value_Mapping__c> getValueMappingRec(String recordKey){
     	//CSM_Batch_Success_Plan_Default__c thePlanDef = new CSM_Batch_Success_Plan_Default__c();
     	List<REN_Value_Mapping__c> valueMappingList = new List<REN_Value_Mapping__c>();    
        List<String> fcFieldList = new List<String>{REN_Constants.OBJ_RC_RECORD_KEY,REN_Constants.REN_VALUE};
        CSM_Util.checkCRUD_FLS(REN_Constants.REN_OBJ_VALUE_MAPPING, fcFieldList, CSM_Constants.DML_OPERATION_READ);

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
    public static Map<String, String> getRenewalStatus(){
		Map<String, String> valueMap = new Map<String, String>();
		List<REN_Value_Mapping__c> valueMappingRecList = REN_ValueMappingDataAccess.getValueMappingRec(REN_Constants.REN_RR_STATUS_MAP);
    	if(valueMappingRecList!=null && !valueMappingRecList.isEmpty() && String.isNotBlank(valueMappingRecList[0].REN_Value__c)){
			String[] valSplit =  valueMappingRecList[0].REN_Value__c.split(',');
			for(String str :valSplit) {
				String[] keyValList =  str.split('=');
				if(keyValList.size() == 2){
    				valueMap.put(keyValList[0].trim(),keyValList[1].trim());
				}
			}
    	}
    	return valueMap;
	}
		
	public static Map<String, Set<String>> getRenewalStatusByInternalStatus(){
		Map<String, Set<String>> valueMap = new Map<String, Set<String>>();
		List<REN_Value_Mapping__c> valueMappingRecList = REN_ValueMappingDataAccess.getValueMappingRec(REN_Constants.REN_RR_STATUS_MAP);
		if(valueMappingRecList!=null && !valueMappingRecList.isEmpty() && String.isNotBlank(valueMappingRecList[0].REN_Value__c)){
			String[] valSplit =  valueMappingRecList[0].REN_Value__c.split(',');
			for(String str :valSplit) {
				String[] keyValList =  str.split('=');
				if(keyValList.size() == 2){
					Set<String> statusSet = valueMap.get(keyValList[1].trim());
					if(statusSet == null) {
						statusSet = new Set<String>();
					}
					statusSet.add(keyValList[0].trim());
		    		valueMap.put(keyValList[1].trim(), statusSet);
				}
			}
		  }
   		return valueMap;
	}
	

	public static Map<String, String> getRenewalDates(){
		Map<String, String> valueMap = new Map<String, String>();
		List<String> valueLst = new List<String>();
		List<REN_Value_Mapping__c> valueMappingRecList = REN_ValueMappingDataAccess.getValueMappingRec(REN_Constants.REN_RLI_DATE_MAP);
    	if(valueMappingRecList!=null && !valueMappingRecList.isEmpty() && String.isNotBlank(valueMappingRecList[0].REN_Value__c)){
			valueMap.put(REN_Constants.REN_RLI_DATE_MAP,valueMappingRecList[0].REN_Value__c);
    	}
    	return valueMap;
	}
}