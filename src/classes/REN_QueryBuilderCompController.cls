/**
 * Created Date     : April 26, 2018
 * Developed By     : Nidhi, Comity Designs, Inc.
 *
 * Function         : Query builder classes.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Nidhi                    US3340                  April 26, 2018  1.1                 Added in sprint 757
 **/


public with sharing class REN_QueryBuilderCompController extends REN_BaseChildController{
	public Integer lineIndex{get;set;}
	public String finalQuery{get;set;}
    
	public Map<String, List<SelectOption>> dataTypeOperatorMap{get;set;}
    public Map<String, list<SelectOption>> fieldToOperatorMap{get;set;}
    
	public String fieldAPIName{get;set;}
	public Integer lineNumber{get;set;}
	public List<SelectOption> soDateStringLiteral{get; set;}
	public String baseNamespace{get;set;}
	public List<SelectOption> selectOptionList {get;set;}
    public REN_QueryBuilderWrapper inputWrapper {get;set;}
    private String invokingObject {get;set;}
    private String columns {get;set;}
    private Map<String, String> relatedObjectLookupFieldMap {get; set;}
    private String selectedRelatedObject {get; set;}
    public String uniqueName {get; set;} // Added for US3928 : Support for picklist values and multi-select picklist values.

    
    public REN_ConfigSettings configSettings {get; 
		set{
        	configSettings = value;
            System.debug('configSettings - '+configSettings);
			if (configSettings != null && inputWrapper==null){
                initializeQueryBuilder();
			}
    	}
	}

    private void initializeQueryBuilder(){
        String columns = '';
		Boolean isRSReq = false;
        System.debug('configSettings - '+configSettings);
		if(fieldToOperatorMap == null || fieldToOperatorMap.isEmpty()) {
			String filterCriteria = '';
            if(configSettings.flowName == 'IB Export'){
            	filterCriteria = 'where REN_RS_Configuration__r.REN_Flow_Name__c = \'' + String.escapeSingleQuotes(configSettings.flowName) + '\' AND REN_Object_API_Name__c = \'' + configSettings.objApiName + '\'';   
                columns = (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Columns__c');
                invokingObject = (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c');
                isRSReq = true;
            }else{
              	filterCriteria = 'where REN_RS_Configuration__r.REN_Flow_Name__c = \'' + String.escapeSingleQuotes(configSettings.flowName) + '\'';  
                columns = configSettings.filterableFieldSet;
                invokingObject = configSettings.objApiName;
            }
			List<REN_RS_Field_Operator__c> rsFieldOperatorList = REN_RSFieldOperatorDataAccess.getRSFieldOperators(new List<String>{'REN_Field_API_Name__c', 'REN_Operators__c','REN_Object_API_Name__c'}, new List<String>{'REN_RS_Configuration__r.REN_Invoking_Object__c'}, new List<String>{filterCriteria});
            System.debug('rsFieldOperatorList - '+rsFieldOperatorList);
	        fieldToOperatorMap = REN_QueryBuilderHelper.getFieldToOperatorMap(rsFieldOperatorList);
	        system.debug('fieldToOperatorMap::'+fieldToOperatorMap);
            initializeQueryBuilderWrapper(null, invokingObject, columns, isRSReq, null);
		}
    }

    public void initializeQueryBuilderWrapper(String selectedRelatedObject, String invokingObject, String columns, Boolean isRSReq, Map<String, String> relatedObjectLookupFieldMap){
        this.invokingObject = invokingObject;
        this.columns = columns;
        this.relatedObjectLookupFieldMap = relatedObjectLookupFieldMap;
        this.selectedRelatedObject = selectedRelatedObject;
        inputWrapper = new REN_QueryBuilderWrapper(invokingObject, columns, isRSReq, configSettings.flowName);
        System.debug('inputWrapper - '+inputWrapper);
    }
    
	public REN_QueryBuilderCompController(){
        super();
        baseNamespace = CSM_Util.getNamespace();
        this.soDateStringLiteral = CSM_CriteriaService.getDateStringList();
		dataTypeOperatorMap = REN_QueryBuilderHelper.getDataTypeOperatorMap();
	}

    
	public REN_QueryBuilderWrapper queryBuilder(REN_QueryBuilderWrapper inputWrapper) {
		system.debug('inputWrapper*************'+inputWrapper);
		Boolean isValid = REN_QueryBuilderHelper.validateCriteria(inputWrapper);
		finalQuery = inputWrapper.finalQuery;
		if(!inputWrapper.isIbExport){
			Integer i = 0;
			for (REN_QueryBuilderWrapper.ColumnFilter filter :inputWrapper.columnFilterList){
				i++;
				if(String.isNotBlank(filter.fieldApiName)){
					finalQuery += '\n, Filter' + i + ' = '  + filter.filterStringValueSet + ', ' +  filter.filterNumberValueSet;
				}
			}
		}
		return inputWrapper;
	}
    
	public boolean isMaxCriteriaReached {
		get{
			if(inputWrapper != null){
				return (inputWrapper.columnFilterList != null && inputWrapper.columnFilterList.size() >= 10);
			}
			return null;
		} 
		set;
	}

	public PageReference addNewFilter() {
		inputWrapper.columnFilterList.add(new REN_QueryBuilderWrapper.ColumnFilter(inputWrapper.objectApiName));
		return null;
	}

	public PageReference queryBuilder() {
		Boolean isValid = REN_QueryBuilderHelper.validateCriteria(inputWrapper);
		return null;
	}
    
    public String doSearch(){
        String responseStr = null;
        
        Boolean isValid = REN_QueryBuilderHelper.validateCriteria(inputWrapper);
        List<Schema.FieldSetMember> fieldSetMemberList = CHL_Util.getFieldSet((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Field_Set_Name__c'), (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c'));
        
        if(isValid){
            String jsonFilterCriteria = REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList,inputWrapper.filterLogic, false, '');
            
	        String fieldsName = '';           
			for(Schema.FieldSetMember fld :fieldSetMemberList){
               if(configSettings.flowName == 'IB Export'){
                   fieldsName += fld.getFieldPath().replaceAll('__c', '') + ',';
               }else{
                   fieldsName += fld.getFieldPath() + ',';
               }
           }            
            Integer index = fieldsName.lastIndexOf(',');
            if(index != -1) {
                fieldsName = fieldsName.substring(0,index);
            }
	        Integer recordLimit = configSettings.getRecordLimit();
        	recordLimit = recordLimit==null?0:recordLimit;
            String finalQuery = '{"top":' + recordLimit + ',"filter":"'+jsonFilterCriteria+'","select":"'+fieldsName+'"}';
            System.debug('**Search finalQuery ' + finalQuery);
            responseStr = callRSAction(fieldsName, finalQuery);
            reInitialize();
        }
        return responseStr;
    }
    
    private String callRSAction(String fieldsName, String finalQuery){
        String responseStr = null;
        REN_RSIntegrationUtil.REN_RSIntegrationWrapper wrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();
        
        wrapper.namedCredential = (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Named_Credential__c');
        wrapper.namedCredentialExtn = (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Named_Credential_URL_Extension__c');
        wrapper.jsonData = finalQuery;
        wrapper.endPointToAppend = '?$select='+fieldsName;
        wrapper.action = 'POST';
        System.debug('wrapper - '+ wrapper);
        REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
        HttpResponse resp = callout.postHttpRequest(wrapper);
        
        if(resp == null || resp.getStatusCode() != 200){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_IBExport_Response_Error);
			ApexPages.addMessage(myMsg);
        }else{
            responseStr = resp.getBody(); 
            wrapper.jsonData = null;
        }
        return responseStr;

    }
    
	public void reInitialize() {
    	if(inputWrapper.columnFilterList != null){            	
        	for(integer i = inputWrapper.columnFilterList.size() - 1; i >= 0; --i){
                if (inputWrapper.columnFilterList[i] != null) {
                    String strFieldName = String.valueOf(inputWrapper.columnFilterList[i].fieldApiName);
                    if (String.isBlank(strFieldName) || strFieldName.equalsIgnoreCase(Label.CSM_LBL_NONE)) {
                        inputWrapper.columnFilterList.remove(i);
                    }
                }
            }
            
            Integer tempCounter = REN_Constants.DEFAULT_CRITERIA_COUNT - inputWrapper.columnFilterList.size();
            if (tempCounter > 0) {
                for (Integer idx = 0; idx < tempCounter; idx++) {
                    inputWrapper.columnFilterList.add(new REN_QueryBuilderWrapper.ColumnFilter(invokingObject));
                }
            }	
        }
    }
    
	public PageReference deleteFilter() {
		if(lineIndex >= 0 && inputWrapper.columnFilterList.size() > lineIndex){
			inputWrapper.columnFilterList.remove(lineIndex);
		}
		
		if(inputWrapper.columnFilterList.size() == 0){
            inputWrapper.filterLogic = '';
        }
		return null;
	}

	public PageReference onFieldChange() {
		REN_QueryBuilderWrapper.ColumnFilter cFilter = inputWrapper.columnFilterList.get(lineNumber);
		if(fieldToOperatorMap == null || fieldToOperatorMap.isEmpty()) {
			String filterCriteria = '';
            //String invokingObject = (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c');
            if(!inputWrapper.isIbExport){
            	filterCriteria = 'where REN_RS_Configuration__r.REN_Flow_Name__c = \'' + String.escapeSingleQuotes(configSettings.flowName) + '\' AND REN_Object_API_Name__c = \'' + String.escapeSingleQuotes(configSettings.objApiName) + '\'';   
            }else{
              	filterCriteria = 'where REN_RS_Configuration__r.REN_Flow_Name__c = \'' + String.escapeSingleQuotes(configSettings.flowName) + '\'';  
            }
			List<REN_RS_Field_Operator__c> rsFieldOperatorList = REN_RSFieldOperatorDataAccess.getRSFieldOperators(new List<String>{'REN_Field_API_Name__c', 'REN_Operators__c','REN_Object_API_Name__c'}, new List<String>{'REN_RS_Configuration__r.REN_Invoking_Object__c'}, new List<String>{filterCriteria});
	        fieldToOperatorMap = REN_QueryBuilderHelper.getFieldToOperatorMap(rsFieldOperatorList);
	        system.debug('fieldToOperatorMap::'+fieldToOperatorMap);
		}
		Map<String, Schema.SObjectField> relatedObjDefinitionMap;
		if(cFilter.fieldApiName != null && String.isNotEmpty(cFilter.fieldApiName)){
            if(fieldToOperatorMap.containsKey(cFilter.fieldApiName)){
                cFilter.isFieldHasCustomOperator = true;
            }else{
                cFilter.isFieldHasCustomOperator = false;
            }
            system.debug('cFilter.fieldApiName**'+cFilter.fieldApiName);
            Schema.DescribeFieldResult  fldDesc;
            String objName = '';
            if(cFilter.fieldApiName.contains('.')) {
            	String[] strSplit = String.valueOf((cFilter.fieldApiName)).split('\\.');
            	system.debug('strSplit.size()**'+strSplit.size());
            	Schema.DescribeFieldResult f = strSplit[0].endsWithIgnoreCase('__r') ? Schema.getGlobalDescribe().get(inputWrapper.objectApiName).getDescribe().fields.getMap().get(strSplit[0].replace('__r','__c')).getDescribe() : Schema.getGlobalDescribe().get(inputWrapper.objectApiName).getDescribe().fields.getMap().get(strSplit[0]+'Id').getDescribe() ;   
                List<Schema.SObjectType> reference = f.getReferenceTo();
                relatedObjDefinitionMap = REN_QueryBuilderHelper.getObjectFieldDefinition(reference[0].getDescribe().getName());
            	fldDesc = relatedObjDefinitionMap.get(strSplit[1]).getDescribe();
            	//cFilter.fieldDataType = String.valueOf(fldDesc.getType());
            } else {
            	fldDesc = inputWrapper.objFieldDefinitionMap.get(cFilter.fieldApiName).getDescribe();
				//cFilter.fieldDataType = String.valueOf(fldDesc.getType());
            }
			cFilter.fieldDataType = String.valueOf(fldDesc.getType());
			if(REN_QueryBuilderHelper.TYPE_DATE_SET.contains(cFilter.fieldDataType)){            	
				cFilter.relatedObject = new REN_Line_Criteria__c();
			}else if(cFilter.fieldDataType == 'REFERENCE'){
				cFilter.relatedObject = Schema.getGlobalDescribe().get(inputWrapper.objectApiName).newSObject();
				cFilter.lookupSearchStr = '';
			}else if(cFilter.fieldDataType == 'PICKLIST' || cFilter.fieldDataType == 'MULTIPICKLIST'){
				cFilter.relatedObject = Schema.getGlobalDescribe().get(inputWrapper.objectApiName).newSObject();
				List<Schema.PicklistEntry> pickListValues = fldDesc.getPicklistValues();
				if(pickListValues != null && !pickListValues.isEmpty()) {
					cFilter.selectOptionList = new List<SelectOption>();
					for( Schema.PicklistEntry value : pickListValues)
					{
						cFilter.selectOptionList.add(new SelectOption(value.getValue(),value.getLabel()));
					}	
				}
			}
			cFilter.filterValue = '';
		}else {
            cFilter.fieldDataType = null;
            cFilter.relatedObject = null;
        }
        system.debug('cFilter::'+cFilter);
		return null;
	}
	
    
    public PageReference hideValueInput() {
		return null;
	}
	
	
	public PageReference onDateOptionClick() {
		return null;
	}

    public String findFor(Integer customSearchLimit, String selectedChildObject, String selectOwnerOption, String selectedGroupId, List<REN_QueryBuilderWrapper.ColumnFilter> ownerFilterCriteria){
        String parentIdCSV = '';
        //Re Initilize filter criteria
        if(inputWrapper.columnFilterList != null){
            reInitialize();	
        }

        system.debug('inputWrapper**'+inputWrapper);
		Boolean isValid = REN_QueryBuilderHelper.validateCriteria(inputWrapper);
		finalQuery = inputWrapper.finalQuery;
		if(!inputWrapper.isIbExport){
			Integer i = 0;
			for (REN_QueryBuilderWrapper.ColumnFilter filter :inputWrapper.columnFilterList){
				i++;
				if(String.isNotBlank(filter.fieldApiName)){
					finalQuery += '\n, Filter' + i + ' = '  + filter.filterStringValueSet + ', ' +  filter.filterNumberValueSet;
				}
			}
		}

        String fieldsName = '';
        system.debug('isValid::'+isValid);
        if(isValid) {
            checkForSingleCriteria(); 
            if(!ApexPages.hasMessages()){
                ownerFilterCriteria = new List<REN_QueryBuilderWrapper.ColumnFilter>();
                parentIdCSV = processSOQL(customSearchLimit, configSettings.noSearch, selectedChildObject, selectOwnerOption, selectedGroupId, ownerFilterCriteria);
            }
        }
        return parentIdCSV;
    }

	private String processSOQL(Integer customSearchLimit, Boolean noSearch, String selectedChildObject, String selectOwnerOption, String selectedGroupId, List<REN_QueryBuilderWrapper.ColumnFilter> ownerFilterCriteria) {
		String parentIdCSV = '';
		String relatedFieldName = '';
        Set<String> relatedFieldsSet = new Set<String>{};
        Set<String> firstFilterSet = new Set<String>();
        String objName = String.isNotBlank(selectedRelatedObject)? selectedRelatedObject : configSettings.selectedParentObject;
		String fieldSetMapKey = String.isNotBlank(selectedChildObject)? selectedChildObject : configSettings.selectedParentObject;
		Integer recordLimit = 10000; //Added for DE3039
		
        if(String.isNotBlank(selectedRelatedObject) && relatedObjectLookupFieldMap.containsKey(selectedRelatedObject)){
			relatedFieldName = relatedObjectLookupFieldMap.get(selectedRelatedObject);
			if(String.isNotBlank(relatedFieldName)){
				relatedFieldsSet.add(relatedFieldName);
			}
		}
		recordLimit = (String.isBlank(selectedRelatedObject) || selectedRelatedObject == configSettings.selectedParentObject) ?  customSearchLimit: recordLimit;
		
		if(relatedFieldsSet == null || relatedFieldsSet.isEmpty()){
			relatedFieldsSet.add('Id');
		}
		
		if(String.isNotBlank(configSettings.requiredFieldName) && noSearch){
        	relatedFieldsSet.add(configSettings.requiredFieldName);
   
        }
        
		List<REN_QueryBuilderWrapper.ColumnFilter> columnFilterList = inputWrapper.columnFilterList;
		REN_CustomSearchController.REN_SOQLWrapper wrapper = new REN_CustomSearchController.REN_SOQLWrapper();
        wrapper.fromObject = String.isNotBlank(selectedRelatedObject)? selectedRelatedObject : configSettings.selectedParentObject;
        wrapper.knownFields = relatedFieldsSet;
    	wrapper.sFilter1 = columnFilterList[0].filterStringValueSet;
		wrapper.nFilter1 = columnFilterList[0].filterNumberValueSet;
		
		//Search by same parent and child object
        if(configSettings.selectedParentObject == fieldSetMapKey){
            System.debug('**In same selectOwnerOption ' + selectOwnerOption + '  selectedGroupId ' + selectedGroupId);
            if(selectOwnerOption == 'My'){
                if(configSettings.selectedParentObject == 'Asset'){
                    addFilterCondition('Account.',UserInfo.getUserId(), ownerFilterCriteria);
                }else{
                	addFilterCondition('',UserInfo.getUserId(), ownerFilterCriteria);    
                }
            }else if(selectOwnerOption == 'Teams'){
                addChildFilterCondition(configSettings.selectedParentObject, 'Id', ownerFilterCriteria);
            }else if((selectOwnerOption == '' || selectOwnerOption == null) && configSettings.selectedParentObject == 'Case' && selectedGroupId != null && selectedGroupId != Label.CSM_LBL_NONE){
                addFilterCondition('',selectedGroupId, ownerFilterCriteria);
            }
                
            
        }else if(configSettings.selectedParentObject != fieldSetMapKey){//Search by different parent and child object
            System.debug('**fieldSetMapKey ' + fieldSetMapKey);
            if(selectOwnerOption == 'My'){
                String parentObjRelName = '';
                if(fieldSetMapKey.contains('__c')){
                    parentObjRelName = fieldSetMapKey.substringAfter('.');
                }else{
                    parentObjRelName = configSettings.selectedParentObject;    
                }
                if(configSettings.selectedParentObject == 'Asset'){
                    parentObjRelName = parentObjRelName.replace('__c', '__r') + '.Account.';
                }else{
                    parentObjRelName = parentObjRelName.replace('__c', '__r') + '.';
                }
                
                addFilterCondition(parentObjRelName, UserInfo.getUserId(), ownerFilterCriteria);
            }else if(selectOwnerOption == 'Teams'){
                String parentObjRelName = fieldSetMapKey.substringAfter('.');
                addChildFilterCondition(configSettings.selectedParentObject, parentObjRelName, ownerFilterCriteria);
            }else if((selectOwnerOption == '' || selectOwnerOption == null ) && configSettings.selectedParentObject == 'Case' && selectedGroupId != null && selectedGroupId != Label.CSM_LBL_NONE){
                String parentObjRelName = '';
                if(fieldSetMapKey.contains('__c')){
                    parentObjRelName = fieldSetMapKey.substringAfter('.');
                }else{
                    parentObjRelName = configSettings.selectedParentObject;
                }
                
                parentObjRelName = parentObjRelName.replace('__c', '__r') + '.';
                addFilterCondition(parentObjRelName, selectedGroupId, ownerFilterCriteria);
            }
                
        }		
		
     	wrapper.whereCondition = inputWrapper.filterCondition;
    	wrapper.isFirstFilterSetRequired = false;
   		wrapper.recordLimit = recordLimit + 1;
        
        List<sObject> relatedObjList = new List<sObject>();	
        relatedObjList = REN_OpportunityDataAccess.getObjectRecordsList(wrapper);
        
        //VCP - NEED TO REVISIT
        if(noSearch){
			configSettings.relatedObjectRecordList = relatedObjList;
		}
			
		List<sObject> parentRecList = new List<sObject>();
		Set<String> parentIdSet = new Set<String>();
		if(relatedObjList != null){
			parentIdSet = getParentRecIds(relatedObjList,relatedFieldName);
			parentIdCSV = JSON.serialize(parentIdSet);
		}
		System.debug(relatedObjList.size() + '\n\n2~~~~parentIdSet.size(): ' + parentIdSet.size());
        //VCP - NEED TO REVISIT
        if(parentIdSet.size() >= recordLimit){
            configSettings.isLimitError ='true';
            configSettings.isNotLBError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,String.format(Label.REN_CUSTOM_SEARCH_LIMIT_ERROR, new String[]{String.valueOf(customSearchLimit)})));
        }
        
		return parentIdCSV;
	}    

    private Set<String> getParentRecIds(List<sObject> relatedObjList, String relatedFieldName){
		Set<String> parentIdSet = new Set<String>();
		relatedFieldName = String.isBlank(relatedFieldName) ? 'id' : relatedFieldName;
		if(relatedObjList != null){
			Set<String> parentObjIdSet = new Set<String>();
			for(sObject obj: relatedObjList){
				ID parentObjId = (ID)obj.get(relatedFieldName);
				if(String.isNotBlank(parentObjId)){
					parentIdSet.add(parentObjId);
				}
			}
		}
		return parentIdSet;
	}
    
    private void addChildFilterCondition(String selectedObj, String whereField, List<REN_QueryBuilderWrapper.ColumnFilter> ownerFilterCriteria){
        Set<Id> recordIdSet = new Set<Id>();
        REN_QueryBuilderWrapper.ColumnFilter colFilterObj = new REN_QueryBuilderWrapper.ColumnFilter(configSettings.selectedParentObject);
        
        if(selectedObj == 'Opportunity'){
            recordIdSet = REN_Util.queryTeamMembers(new List<String>{'OpportunityId'},'OpportunityTeamMember','UserId');
        }else if(selectedObj == 'Case'){
            recordIdSet = REN_Util.queryTeamMembers(new List<String>{'ParentId'},'CaseTeamMember','MemberId');
        }
        System.debug('**recordIdSet ' + recordIdSet);
        if(recordIdSet != null){
            if(String.isBlank(inputWrapper.filterCondition)){
                inputWrapper.filterCondition = whereField + ' In (\'' + String.join(new List<Id>(recordIdSet), '\',\'') + '\')';
            }else{
                inputWrapper.filterCondition += ' AND ' + whereField + ' In (\'' + String.join(new List<Id>(recordIdSet), '\',\'') + '\')';
            }
            System.debug('**queryBuilderInputWrapper.filterCondition ' + inputWrapper.filterCondition);
            colFilterObj.fieldApiName = 'Id';
            colFilterObj.operator = '=';
            colFilterObj.filterValue = String.join(new List<Id>(recordIdSet), ',');
            colFilterObj.fieldDataType = 'String';
            colFilterObj.filterCondition = inputWrapper.filterCondition;
            ownerFilterCriteria.add(colFilterObj);
        }
    }
    
    private void addFilterCondition(String parentObjRelName, String ownerId, List<REN_QueryBuilderWrapper.ColumnFilter> ownerFilterCriteria){
        REN_QueryBuilderWrapper.ColumnFilter colFilterObj = new REN_QueryBuilderWrapper.ColumnFilter(configSettings.selectedParentObject);
        
        if(String.isBlank(inputWrapper.filterCondition)){
            inputWrapper.filterCondition = parentObjRelName + 'OwnerId = \'' + ownerId + '\'';
        }else{
            inputWrapper.filterCondition += ' AND ' + parentObjRelName + 'OwnerId = \'' + ownerId + '\'';
        }
        
        colFilterObj.fieldApiName = 'OwnerId';
        colFilterObj.operator = '=';
        colFilterObj.filterValue = ownerId;
        colFilterObj.fieldDataType = 'REFERENCE';
        colFilterObj.filterCondition = inputWrapper.filterCondition;
        ownerFilterCriteria.add(colFilterObj);
    }
    
    /**
	* @description: This method used to check for single criteria provided in Query Builder for 'No Found Items' and 'Search Results' functionality. Based on that we Hide\Show Tabs.
					Added as part of US3859.      
	*/
    private void checkForSingleCriteria(){                    
        String operatorName = '';
		String fieldType = '';
        List<REN_QueryBuilderWrapper.ColumnFilter> columnFilterListNew = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        
        for (REN_QueryBuilderWrapper.ColumnFilter wrapper :inputWrapper.columnFilterList){
            String fieldName = String.valueOf(wrapper.fieldApiName);
            if(wrapper.filterCondition != null && !fieldName.equalsIgnoreCase(Label.CSM_LBL_NONE)){
                columnFilterListNew.add(wrapper);
            }
        }
        if(columnFilterListNew != null && !columnFilterListNew.isEmpty()){
        	operatorName = String.valueOf(columnFilterListNew[0].operator);
        	fieldType = String.valueOf(columnFilterListNew[0].fieldDataType); 
            
            //VCP - NEED TO REVISIT
        	configSettings.requiredFieldName = String.valueOf(columnFilterListNew[0].fieldApiName); 
        }
        if(columnFilterListNew != null && columnFilterListNew.size() == 1 
        		&& (operatorName == CSM_Constants.OPERATOR_EQUAL
					|| operatorName	== CSM_Constants.OPERATOR_LIKE
					|| operatorName	==	CSM_Constants.OPERATOR_IN) && fieldType != 'BOOLEAN'){
            //VCP - NEED TO REVISIT
			configSettings.noSearch=true;
			system.debug('configSettings.noSearch::'+configSettings.noSearch);
		}
        //queryBuilderInputWrapper.columnFilterList = columnFilterListNew;
	}
    
    public void renderSavedSearch(CSM_Focus_Category_View__c fcView, List<CSM_Focus_Category_View_Criteria__c> fcvCriteriaList){
        for(CSM_Focus_Category_View_Criteria__c fcvc : fcvCriteriaList){
            inputWrapper.columnFilterList.get((Integer)fcvc.RLM_LineNo__c - 1).fieldApiName = fcvc.RLM_Field_Name__c;
            inputWrapper.columnFilterList.get((Integer)fcvc.RLM_LineNo__c - 1).fieldDataType = fcvc.RLM_Field_Type__c;
            lineNumber = (Integer)fcvc.RLM_LineNo__c-1;
            onFieldChange();
            inputWrapper.columnFilterList.get((Integer)fcvc.RLM_LineNo__c - 1).filterValue = fcvc.RLM_Values__c;
            if(String.isNotBlank(fcView.RLM_Filter_Logic__c)){
                inputWrapper.filterLogic = fcView.RLM_Filter_Logic__c;
                inputWrapper.isFilterLogic = true;
            }
            if(fcvc.RLM_Field_Type__c == 'DATETIME' || fcvc.RLM_Field_Type__c == 'DATE'){
                REN_Line_Criteria__c lineCriteria = new REN_Line_Criteria__c();
                lineCriteria.RLM_Is_Specific_Date__c = fcvc.RLM_Is_Specific_Date__c;
                lineCriteria.RLM_Date_Literal_Number__c = fcvc.RLM_Date_Literal_Number__c;
                lineCriteria.RLM_Date_Literal_String__c = fcvc.RLM_Date_Literal_String__c;
                lineCriteria.RLM_DateTime_Value__c = fcvc.RLM_DateTime_Value__c;
                lineCriteria.RLM_Date_Value__c = fcvc.RLM_Date_Value__c;
                inputWrapper.columnFilterList.get((Integer)fcvc.RLM_LineNo__c - 1).relatedObject = lineCriteria;
            }
            inputWrapper.columnFilterList.get((Integer)fcvc.RLM_LineNo__c - 1).fieldLabel = fcvc.RLM_Field_Display_Name__c;
            inputWrapper.columnFilterList.get((Integer)fcvc.RLM_LineNo__c - 1).operator = fcvc.RLM_Operator__c;
        }
    }
    
}