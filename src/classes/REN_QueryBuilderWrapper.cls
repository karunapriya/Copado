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
	public String parentObjectApiName{get;set;}//First filter
	public String objectApiName{get;set;} //Related Filter
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
		resetObject(objApiName, objApiName, null, filterableFieldSet, isRSReq, flowName, null);
	} 
	
	public REN_QueryBuilderWrapper(REN_ConfigSettings configSettings, String objApiName, String filterableFieldSet, Boolean isRSReq){
		System.debug(isRSReq + ': isRSReq\n\n~~~~@In REN_QueryBuilderWrapper: ' + configSettings);
		resetObject(configSettings.selectedParentObject, objApiName, configSettings.parentChildRelationShipField, filterableFieldSet, isRSReq, configSettings.flowName, configSettings.gParentRelationShipFieldSetMap);
	}
  	
	public void resetObject(String parentObjectApiName, String objApiName, String parentChildRelationshipField, String filterableFieldSet, Boolean isRSReq, String flow, Map<String, String> gParentRelationShipFieldSetMap){
		system.debug('@@@@ parentChildRelationshipField' + parentChildRelationshipField);
		objectApiName = objApiName;
		this.parentObjectApiName = parentObjectApiName;
		filterTitle = objectApiName;
		isFilterLogic = false;
		isIbExport = isRSReq;
		flowName = flow;
		maxFiltersAllowed = 10;
		maxRecordLimit = 100;
		filterLogic = '';
		columnFilterList = new List<ColumnFilter>{new ColumnFilter(objectApiName), new ColumnFilter(objectApiName), new ColumnFilter(objectApiName)};
		objFieldDefinitionMap = REN_QueryBuilderHelper.getObjectFieldDefinition(objectApiName);
		List<REN_FieldWrapper> fieldWrapperList = new List<REN_FieldWrapper>();
		
		addFieldsFromFieldSet(objApiName, filterableFieldSet, fieldWrapperList, null, null);
       	setGrandParentInfo(parentObjectApiName, objApiName, parentChildRelationshipField, gParentRelationShipFieldSetMap, fieldWrapperList);//?
        
        if(!fieldWrapperList.isEmpty()){
            fieldList = REN_QueryBuilderHelper.getObjectFields(fieldWrapperList);
        }
	}

	private void addFieldsFromFieldSet(String objApiName, String fieldSetName, List<REN_FieldWrapper> fieldWrapperList, String referenceField, String referenceName){
        system.debug('/n/n~~~~  @@@@@   referenceField ::    ' + referenceField);
        system.debug('/n/n~~~~  @@@@@   referenceName ::    ' + referenceName);
        List<Schema.FieldSetMember> fieldSetMemberList = null;
        System.debug(objApiName + '\n\n~~~~@addFieldsFromFieldSet: ' + fieldSetName);
        if(Schema.getGlobalDescribe().get(objApiName).getDescribe().FieldSets.getMap().containsKey(fieldSetName)){
            fieldSetMemberList = CHL_Util.getFieldSet(fieldSetName, objApiName);
        }
        REN_FieldWrapper fieldWrapper;
        if(fieldSetMemberList != null && !fieldSetMemberList.isEmpty()){
        	boolean isReference = String.isNotBlank(referenceField);
            for(Schema.FieldSetMember fld: fieldSetMemberList){
            	if(String.isNotBlank(referenceName)){
            		System.debug(referenceName + '\n\n~~~~@fld.getFieldPath(): ' + fld.getFieldPath());
            	}
            	fieldWrapper = new REN_FieldWrapper();
                fieldWrapper.label = fld.getLabel();
                fieldWrapper.apiName = (isReference ?  referenceField + '.' : '') + fld.getFieldPath();
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
	                	relationshipName = strSplit[0]; 	                
	                }
	                relationshipName = (isReference ?  referenceName + ':' : '') + relationshipName;
                    fieldWrapper.relationshipName = relationshipName;
				}else{
               		fieldWrapper.label = (isReference ?  referenceName + ': ' : '') + fld.getLabel();
 				}
                fieldWrapperList.add(fieldWrapper);
            }
        }
        System.debug(objApiName + '\n\n~~~~@fieldWrapperList: ' + fieldWrapperList);
		
	}
	
	
	private void setGrandParentInfo(String parentObjectName, String childObjectName, String parentChildRelationshipField, Map<String, String> gParentRelationShipFieldSetMap, List<REN_FieldWrapper> fieldWrapperList){
		if(gParentRelationShipFieldSetMap != null){
			boolean is3LevelRelationShip = String.isNotBlank(childObjectName) && parentObjectName != childObjectName;
			for(String relationshipField : gParentRelationShipFieldSetMap.keySet()){
                Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(parentObjectName).getDescribe().fields.getMap().get(relationshipField).getDescribe();
                if(fieldResult.getReferenceTo().isEmpty()){
                    //configSettings.isNotLBError = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, new String[] {relationshipField})));
                }else{
                    List<Schema.SObjectType> reference = fieldResult.getReferenceTo();
                    Schema.DescribeSObjectResult objectDescribe =  reference[0].getDescribe();
                	String grandParentObj =  objectDescribe.getName();
                	
                	String relationshipName = fieldResult.getLabel();
                	String referenceField = relationshipField;
                	String fieldSetName = gParentRelationShipFieldSetMap.get(relationshipField);

					if(relationshipField.endsWithIgnoreCase('ID')){
						relationshipName = relationshipName.removeEndIgnoreCase('Id').trim();
						referenceField = relationshipField.removeEndIgnoreCase('Id').trim();
					}else if(referenceField.endsWithIgnoreCase('__c')){
						referenceField = relationshipField.replace('__c','__r');
					}

                    System.debug(is3LevelRelationShip + '\n\n~~~~@parentChildRelationshipField: ' + parentChildRelationshipField + '|');
                    
                    if(is3LevelRelationShip){
						Schema.DescribeFieldResult parentChildRelationshipFieldDescribe = Schema.getGlobalDescribe().get(childObjectName).getDescribe().fields.getMap().get(parentChildRelationshipField).getDescribe();
		                if(parentChildRelationshipFieldDescribe.getReferenceTo().isEmpty()){
		                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  String.format(System.Label.CSM_MSG_INVALID_FIELD_NAME, new String[] {parentChildRelationshipField})));
		                }else{
                    		System.debug(is3LevelRelationShip + '\n\n~~~~@parentChildRelationshipFieldDescribe: ' + parentChildRelationshipFieldDescribe);
							if(parentChildRelationshipField.endsWithIgnoreCase('ID')){
								relationshipName = parentChildRelationshipFieldDescribe.getLabel().removeEndIgnoreCase('Id').trim() + ':' + relationshipName;
								referenceField = parentChildRelationshipField.removeEndIgnoreCase('Id').trim() + '.' + referenceField;
							}else if(parentChildRelationshipField.endsWithIgnoreCase('__c')){
								relationshipName = parentChildRelationshipFieldDescribe.getLabel() + ':' + relationshipName;
								referenceField = parentChildRelationshipField.replace('__c','__r') + '.' + referenceField;
							}
		                }
                    }
					addFieldsFromFieldSet(grandParentObj, fieldSetName, fieldWrapperList, referenceField, relationshipName);
                }
			}
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
		public String parentObjectApiName{get;set;}
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
     					Integer lSize = str.size();
     					system.debug('@@@ fieldApiName :: ' + fieldApiName + ' \n @@@ objectApiName '+objectApiName + '\n@@@ lSize :: ' + lSize + '\n@@@ str :: ' + str + '\n@@@ str[lSize-2] :: ' + str[lSize-2]);
     					if(lSize > 1){
	               		    Schema.DescribeFieldResult f = null;
	     					//relatedObjectName = str[lSize-2].replace('__r','__c');
	     					relatedObjectName = Ren_Util.getObjectApiName(objectApiName, fieldApiName);
	     					relatedFieldApiName = str[lSize-1];
	     					system.debug(relatedObjectName + '= relatedObjectName\n@relatedFieldApiName :: ' + relatedFieldApiName); 
     					}
     				}
     				if(String.isNotBlank(relatedObjectName) && String.isNotBlank(relatedFieldApiName)) {
     					system.debug(Schema.getGlobalDescribe().get(relatedObjectName) + '= ------ :: ' + Schema.getGlobalDescribe().get(relatedObjectName).getDescribe().fields.getMap().get(relatedFieldApiName));
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
     					Integer lSize = str.size();
     					system.debug('\n@@ str ' +str + '\n@@ lSize ' +lSize +  '\n@@ objectApiName ' +objectApiName + '\n@@ str[lSize-2] ' +str[lSize-2]);
     					if(lSize > 1){
     						//relatedObjectName = str[lSize-2].replace('__r','__c');
     						relatedObjectName = Ren_Util.getObjectApiName(objectApiName, fieldApiName);
     						
     						relatedFieldApiName = str[lSize-1];
     					}
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