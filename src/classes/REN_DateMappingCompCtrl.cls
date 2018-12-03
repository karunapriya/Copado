/**
 * Created Date		: Sep 6, 2016
 * Developed By		: prashant, Comity Designs, Inc.
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
 * prashant					User Story				Sep 6, 2016								@description
 * 
 */
public with sharing class REN_DateMappingCompCtrl extends REN_BaseChildController{

    public String objectName {get;set;} 
	private Map<String, String> valueMap;
	public List<REN_Value_Mapping__c> valueMappingRecList {get;set;}
	public List<SelectOption> selectOptions {get;set;}
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
	
    public REN_DateMappingCompCtrl() {
    	valueMappingRecList = REN_ValueMappingDataAccess.getValueMappingRec(REN_Constants.REN_RLI_DATE_MAP);
    	//system.debug('----valueMappingRecList---'+valueMappingRecList);
    }
    public Map<String, String> getRenewalDate()
	{
		try{
			selectOptions = new List<SelectOption>();
			selectOptions.add(new SelectOption('None','--None--'));
			Map<String, String> savedValueMap = REN_ValueMappingDataAccess.getRenewalDates();
			valueMap = new Map<String, String>();
			valueMap.put(REN_Constants.RENEWAL_LINE_ITEM_DATE,savedValueMap.get(REN_Constants.REN_RLI_DATE_MAP));
			Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
			Schema.SObjectType leadSchema = schemaMap.get(objectName);
			Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
			system.debug('fieldMap--------'+fieldMap);
			for (String fieldName: fieldMap.keySet()){
				Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
				if(fielddataType == Schema.DisplayType.DateTime  || fielddataType == Schema.DisplayType.Date) {
					system.debug('fieldName---'+fieldName);
					selectOptions.add(new SelectOption(fieldName,fieldMap.get(fieldName).getDescribe().getLabel()));
				}
			}
		}catch(Exception ex){
			ex.getMessage();
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
	    	valueMappingRecord.REN_Record_Key__c = REN_Constants.REN_RLI_DATE_MAP;
	    	for(String key: valueMap.keySet()){
	    		tempValue = (valueMap.containsKey(key) ? valueMap.get(key) : '');
	    	}
	    	valueMappingRecord.REN_Value__c = tempValue;
	    	valueMappingRecList = REN_ValueMappingDataAccess.saveValueMappingRecord(new List<REN_Value_Mapping__c>{valueMappingRecord});
	    }
	    catch(exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(e, e.getMessage())));
		}
    	return null;
    }

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	// MARK: Your method goes here
}