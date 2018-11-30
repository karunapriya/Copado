public with sharing class REN_ValueMappingCompCtrl extends REN_BaseChildController {
	public String objectName {get;set;}
	public String objFieldName {get;set;}
	private Map<String, String> valueMap;
	public List<REN_Value_Mapping__c> valueMappingRecList {get;set;}
	public List<SelectOption> selectOptions {
		get; 
		set {
			if (value!=null && !value.isEmpty()){
				selectOptions = value;
			}
		}
	}
	
	public REN_FieldMappingInputWrapper fmInputWrapper{
		get;
		set{
			if(value != null){
				this.fmInputWrapper = value;
				if(String.isNotBlank(this.fmInputWrapper.mappingName)) {
					this.objectNameSuper = this.fmInputWrapper.mappingName;
					this.baseMainController = this.fmInputWrapper.baseMainController;
				}
			}
		}
	}
	
    public REN_ValueMappingCompCtrl() {
    	valueMappingRecList = REN_ValueMappingDataAccess.getValueMappingRec(REN_Constants.REN_RR_STATUS_MAP);
    }
    public Map<String, String> getRenewalStatus()
	{
		valueMap = new Map<String, String>();
		Map<String, String> savedValueMap = REN_ValueMappingDataAccess.getRenewalStatus();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
		Schema.DescribeSObjectResult objectResult = objType.getDescribe();
		Schema.DescribeFieldResult fieldResult = objectResult.fields.getMap().get(objFieldName).getDescribe();
    	List<Schema.PicklistEntry> renewalStatusPicklist = fieldResult.getPicklistValues();
   		for(Schema.PicklistEntry a : renewalStatusPicklist) {
   			valueMap.put(a.value, savedValueMap.containsKey(a.value)? savedValueMap.get(a.value) : '');
   		}
   		return valueMap;
	}
    
    public PageReference save() {
	    try {
	    	String tempValue = '';
	    	REN_Value_Mapping__c valueMappingRecord = new REN_Value_Mapping__c();
	    	if(valueMappingRecList != null && !valueMappingRecList.isEmpty()) {
	    		if(valueMappingRecList[0].id != null) {
	    			valueMappingRecord.id = valueMappingRecList[0].id;
	    		}
	    	}
	    	valueMappingRecord.REN_Record_Key__c = REN_Constants.REN_RR_STATUS_MAP;
	    	for(String key: valueMap.keySet()){
	    		tempValue += key + '=' + (valueMap.containsKey(key) ? valueMap.get(key) : '') + ', ';
	    	}
	    	valueMappingRecord.REN_Value__c = tempValue;
	    	valueMappingRecList = REN_ValueMappingDataAccess.saveValueMappingRecord(new List<REN_Value_Mapping__c>{valueMappingRecord});
	    }
	    catch(exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(e, e.getMessage())));
		}
    	return null;
    }
    
}