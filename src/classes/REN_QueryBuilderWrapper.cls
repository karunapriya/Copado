/**
 * Created Date		: April 26, 2018
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: Query builder classes.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					US3340					April 26, 2018	1.1			 		Added in sprint 757
**/
public with sharing class REN_QueryBuilderWrapper {
	public String objectApiName{get;set;}
	public String filterTitle{get;set;}
	public List<ColumnFilter> columnFilterList{get;set;}
	public Map<String, Schema.SObjectField> objFieldDefinitionMap{get;set;}
	public List<SelectOption> fieldList{get;set;}
	public boolean isFilterLogic{get;set;}
	public boolean isIbExport{get;set;}
	public String filterLogic{get;set;}
	public Integer maxFiltersAllowed{get;set;}
	public Integer maxRecordLimit{get;set;}
	public transient String finalQuery{get;set;}
	public String filterCondition{get;set;}
	public String flowName {get; set;}
	
	public REN_QueryBuilderWrapper(String objApiName, String filterableFieldSet, Boolean isRSReq, String flowName){
		resetObject(objApiName,filterableFieldSet, isRSReq, flowName);
	}
  	
	public void resetObject(String objApiName, String filterableFieldSet, Boolean isRSReq, String flow){
		objectApiName = objApiName;
		filterTitle = objectApiName;
		isFilterLogic = false;
		isIbExport = isRSReq;
		flowName = flow;
		maxFiltersAllowed = 10;
		maxRecordLimit = 100;
		filterLogic = '';
		columnFilterList = new List<ColumnFilter>{new ColumnFilter(objectApiName), new ColumnFilter(objectApiName), new ColumnFilter(objectApiName)};
		objFieldDefinitionMap = REN_QueryBuilderHelper.getObjectFieldDefinition(objectApiName);
        List<Schema.FieldSetMember> fieldSetMemberList = null;
        if(Schema.getGlobalDescribe().get(objApiName).getDescribe().FieldSets.getMap().containsKey(filterableFieldSet)){
            fieldSetMemberList = CHL_Util.getFieldSet(filterableFieldSet, objApiName);
        }
        List<REN_FieldWrapper> fieldWrapperList = new List<REN_FieldWrapper>();
		REN_FieldWrapper fieldWrapper;
        if(fieldSetMemberList != null && !fieldSetMemberList.isEmpty()){
            for(Schema.FieldSetMember fld: fieldSetMemberList){
            	fieldWrapper = new REN_FieldWrapper();
                fieldWrapper.label = fld.getLabel();
                fieldWrapper.apiName = fld.getFieldPath();
                fieldWrapper.dataType = fld.getType();
                String[] strSplit;
                String relationshipName = '';
 				if(fld.getFieldPath().contains('.')) {
 					strSplit = fld.getFieldPath().split('\\.');
 					if(strSplit[0].endsWithIgnoreCase('__r')){
	                	Schema.DescribeFieldResult fieldDesc = Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap().get(strSplit[0].replace('__r','__c')).getDescribe();
	                    List<Schema.SObjectType> reference = fieldDesc.getReferenceTo();
	                    relationshipName = reference[0].getDescribe().getLabel();
	                }else{
	                	relationshipName = strSplit[0]; 	                }
                    fieldWrapper.relationshipName = relationshipName;
 				}
                fieldWrapperList.add(fieldWrapper);
            }
        }
        if(!fieldWrapperList.isEmpty()){
            fieldList = REN_QueryBuilderHelper.getObjectFields(fieldWrapperList);
        }
	}
	
	public class REN_FieldWrapper {
		public String label {get; set;}
		public String apiName {get; set;}
		public Schema.DisplayType dataType {get; set;}
		public String relationshipName {get; set;}
	}
  	
	public class ColumnFilter{
		public String objectApiName{get;set;}
     	public String fieldLabel{get;set;}
        public String lookupSearchStr{get;set;}
     	public String fieldApiName{get;set;}
     	public String fieldDataType{get;set;}
     	public String operator{get;set;}
        public Boolean isFieldHasCustomOperator {get;set;}
		public boolean isCheckBoxChecked{get;set;}
     	public String filterValue{get;set;}
     	public transient Set<String> filterStringValueSet{get;set;}
     	public transient Set<Integer> filterNumberValueSet{get;set;}
     	public transient String filterCondition{get;set;}
     	public sObject relatedObject{get;set;}
     	public List<SelectOption> selectOptionList {get;set;}
     	public boolean showObjectField{
     		get{
     			if(fieldDataType == 'REFERENCE'){
     				String relatedObjectName = '';
     				String relatedFieldApiName = '';
     				if(String.isNotBlank(fieldApiName) && fieldApiName.contains('.')) {
     					String[] str = fieldApiName.split('\\.');
     					Schema.DescribeFieldResult f = str[0].endsWithIgnoreCase('__r') ? Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(str[0].replace('__r','__c')).getDescribe() : Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(str[0]+'Id').getDescribe() ;   
               			List<Schema.SObjectType> reference = f.getReferenceTo();
     					relatedObjectName = reference[0].getDescribe().getName();
     					relatedFieldApiName = str[1];
     				}
     				if(String.isNotBlank(relatedObjectName) && String.isNotBlank(relatedFieldApiName)) {
     					return String.isNotBlank(relatedFieldApiName) && Schema.getGlobalDescribe().get(relatedObjectName).getDescribe().fields.getMap().get(relatedFieldApiName).getDescribe().isUpdateable();
     				} else {
     					return String.isNotBlank(fieldApiName) && Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().isUpdateable();
     				}
     			}else{
	     			return REN_QueryBuilderHelper.TYPE_OBJECT_FIELD_SET.contains(fieldDataType);
     			}
	     	}
     	}
     	public String relationshipName{
            get{
            	if(fieldDataType == 'REFERENCE' && objectApiName != null && String.isNotBlank(objectApiName) && fieldApiName != null && String.isNotBlank(fieldApiName) ){
            		String relatedObjectName = '';
     				String relatedFieldApiName = '';
     				if(String.isNotBlank(fieldApiName) && fieldApiName.contains('.')) {
     					String[] str = fieldApiName.split('\\.');
     					Schema.DescribeFieldResult f = str[0].endsWithIgnoreCase('__r') ? Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(str[0].replace('__r','__c')).getDescribe() : Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(str[0]+'Id').getDescribe() ;   
               			List<Schema.SObjectType> reference = f.getReferenceTo();
     					relatedObjectName = reference[0].getDescribe().getName();
     					relatedFieldApiName = str[1];
     				}
     				List <Schema.sObjectType> relationshipNameList;
     				if(String.isNotBlank(relatedObjectName) && String.isNotBlank(relatedFieldApiName)) {
     					relationshipNameList = Schema.getGlobalDescribe().get(relatedObjectName).getDescribe().fields.getMap().get(relatedFieldApiName).getDescribe().getReferenceTo();
     				} else {
     					relationshipNameList = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getReferenceTo();
     				}
                    
                    if(relationshipNameList != null && !relationshipNameList.isEmpty()){
                        return relationshipNameList[0].getDescribe().getName();
                    }
                    
                }
                return null;
        	}
        }
     	
     	public ColumnFilter(String objApiName){
     		objectApiName = objApiName;
     		isCheckBoxChecked = false;
            isFieldHasCustomOperator = false;
     	}
  	}
    
}