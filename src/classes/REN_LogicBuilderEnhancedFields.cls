/**
 * Created Date     : September 7, 2018
 * Developed By     : Vishal, Comity Designs, Inc.
 *
 * Function         : Query builder classes.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date                Version           Description
 *____________________________________________________________________________________________________
 *
 * Vishal                   US                      September 7, 2018   1.0               Added in sprint 
 **/
public with sharing class REN_LogicBuilderEnhancedFields {

	public static Set<String> TYPE_STRING_SET = new Set<String>{'ID','REFERENCE','STRING','EMAIL','MULTIPICKLIST','TEXTAREA','LONGTEXTAREA','PHONE','URL'};
	public static Set<String> TYPE_NUMBER_SET = new Set<String>{'INTEGER','DOUBLE','PERCENT','CURRENCY'};
	public static Set<String> TYPE_DATE_SET = new Set<String>{'DATE','DATETIME'};
	public static Set<String> TYPE_NOT_SUPPORTED_SET = new Set<String>{'ANYTYPE','BASE64','COMPLEXVALUE','ADDRESS','COMBOBOX','TIME'};
	public static Set<String> TYPE_OBJECT_FIELD_SET = new Set<String>{'REFERENCE', 'DATE', 'DATETIME', 'BOOLEAN'};
 
 	//public static List<SelectOption> getObjectFields(String flowName){
        //selectedObject = (String)configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c');
        //fieldSetName = (String)configSettingObj.get(baseNamespace + 'REN_Field_Set_Name__c');
        //queryBuilderInputWrapper = new REN_QueryBuilderWrapper((String)configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c'), (String)configSettingObj.get(baseNamespace + 'REN_Columns__c'));

 	//}
		
		
	public static List<SelectOption> getObjectFields(List<Schema.SObjectField> sObjectFieldList){
		List<SelectOption> fieldList = new List<SelectOption>();
		fieldList.add(new SelectOption('', CSM_Constants.STR_NONE));
		for(Schema.SObjectField field: sObjectFieldList){
			Schema.DescribeFieldResult fieldDefinition = field.getDescribe();
			//if (fieldDefinition.isFilterable() == true || String.valueOf(fieldDefinition.getType()) == 'REFERENCE'){
			if(!TYPE_NOT_SUPPORTED_SET.contains(String.valueOf(fieldDefinition.getType()))){
				fieldList.add(new SelectOption(fieldDefinition.getName(), fieldDefinition.getLabel().replace('_', ' ')));
			}
			//}
		}
		fieldList.sort();
		return fieldList;
	}

	public static Map<String, Schema.SObjectField> getObjectFieldDefinition(String objectApiName){
		Schema.SObjectType objectSchema = Schema.getGlobalDescribe().get(objectApiName);
		Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
		return fieldMap;
	}

}