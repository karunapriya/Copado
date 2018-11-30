/**
 * Created Date    : April 26, 2018
 * Developed By    : Nidhi, Comity Designs, Inc.
 *
 * Function      : Query builder classes.
 * Support Email   : email
 * Version      : 1.0
 *
 * Modification Log
 *
 * Developer Name      User Story        Date      Version       Description
 *____________________________________________________________________________________________________
 *
 * Nidhi          US3340          April 26, 2018  1.1           Added in sprint 757
 **/

public with sharing class REN_QueryBuilderHelper {

	public static Set<String> TYPE_STRING_SET = new Set<String>{'ID','REFERENCE','STRING','EMAIL','TEXTAREA','LONGTEXTAREA','PHONE','URL','CONTAINS'};
	public static Set<String> TYPE_NUMBER_SET = new Set<String>{'INTEGER','DOUBLE','PERCENT','CURRENCY'};
	public static Set<String> TYPE_DATE_SET = new Set<String>{'DATE','DATETIME'};
	public static Set<String> TYPE_NOT_SUPPORTED_SET = new Set<String>{'ANYTYPE','BASE64','COMPLEXVALUE','ADDRESS','COMBOBOX','TIME'};
	public static Set<String> TYPE_OBJECT_FIELD_SET = new Set<String>{'REFERENCE', 'DATE', 'DATETIME', 'BOOLEAN'};
	
	public static List<SelectOption> getObjectFields(List<REN_QueryBuilderWrapper.REN_FieldWrapper> sObjectFieldList){
		List<SelectOption> fieldList = new List<SelectOption>();
		fieldList.add(new SelectOption('',Label.CSM_LBL_NONE));
		for(REN_QueryBuilderWrapper.REN_FieldWrapper field: sObjectFieldList){
			system.debug('field**'+field);
			
			//if (fieldDefinition.isFilterable() == true || String.valueOf(fieldDefinition.getType()) == 'REFERENCE'){
			if(!TYPE_NOT_SUPPORTED_SET.contains(String.valueOf(field.dataType))){
				if(String.isNotBlank(field.relationshipName)) {
					fieldList.add(new SelectOption(field.apiName, field.relationshipName + ': ' + field.label));
				} else {
					fieldList.add(new SelectOption(field.apiName, field.label));
				}
			}
			//}
		}
		system.debug('fieldList**'+fieldList);
		//fieldList.sort();
		return fieldList;
	}

	public static Map<String, Schema.SObjectField> getObjectFieldDefinition(String objectApiName){
		system.debug('objectApiName::'+objectApiName);
		Schema.SObjectType objectSchema = Schema.getGlobalDescribe().get(objectApiName);
		Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
		return fieldMap;
	}

	public static List<sObject> executeQuery(REN_QueryBuilderWrapper queryBuilderWrapper){
		List<REN_QueryBuilderWrapper.ColumnFilter> columnFilterList = queryBuilderWrapper.columnFilterList;
		Integer noOfFilters = columnFilterList.size();
		Set<String> sFilter1;
		Set<Integer> nFilter1;
		if(noOfFilters > 0){
			sFilter1 = columnFilterList[0].filterStringValueSet;
			nFilter1 = columnFilterList[0].filterNumberValueSet;
		} 
		
		List<sObject> result;
		if(!ApexPages.hasMessages()){
			try{
				//CRUD CHECK
				system.debug('queryBuilderWrapper.finalQuery::>'+queryBuilderWrapper.finalQuery);
				result = Database.query(queryBuilderWrapper.finalQuery);
			}catch(Exception e){
				System.debug(e);
                if(e.getMessage() == 'Invalid date'){
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.REN_LBL_DATE_ISSUE));                		
                }else{
               		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));	
                }
			}
		}
		return result;
	}

	public static boolean validateCriteria(REN_QueryBuilderWrapper queryBuilderWrapper){
		Boolean isValid = validateFilterLogic(queryBuilderWrapper.filterLogic, queryBuilderWrapper.columnFilterList);
		if(!isValid){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CHL_GENERAL_ERROR + Label.REN_LBL_FILTER_LOGIC_VALIDATE_ERROR_MSG )); //REN_LBL_Filter_Logic_Ref_Error
		}

		Map<Integer, REN_QueryBuilderWrapper.ColumnFilter> lineFilterMap = validateQueryFilters(queryBuilderWrapper); 
		if(!ApexPages.hasMessages()){
			String finalWhereClause = getWhereClauseString(lineFilterMap, queryBuilderWrapper.filterLogic);
			queryBuilderWrapper.filterCondition = finalWhereClause;
			if(String.isNotBlank(finalWhereClause)){
				finalWhereClause = ' WHERE ' + finalWhereClause;
			}
			queryBuilderWrapper.finalQuery = 'SELECT id FROM ' + queryBuilderWrapper.objectApiName + finalWhereClause + ' LIMIT ' + queryBuilderWrapper.maxRecordLimit;
			system.debug('Query- ' + queryBuilderWrapper.finalQuery);
			system.debug('queryBuilderWrapper.isIbExport- '+queryBuilderWrapper.isIbExport);
			if(!queryBuilderWrapper.isIbExport){
				executeQuery(queryBuilderWrapper);
			}
		} 
		return !ApexPages.hasMessages();
	}

	public static Map<Integer, REN_QueryBuilderWrapper.ColumnFilter> validateQueryFilters(REN_QueryBuilderWrapper queryBuilderWrapper){
		List<REN_QueryBuilderWrapper.ColumnFilter> columnFilterList = queryBuilderWrapper.columnFilterList;
		Map<Integer, REN_QueryBuilderWrapper.ColumnFilter> lineFilterMap = new Map<Integer, REN_QueryBuilderWrapper.ColumnFilter>();
		Integer i = 0;
		for (REN_QueryBuilderWrapper.ColumnFilter filter :columnFilterList){
			i++;
			if(String.isNotBlank(filter.fieldApiName) && filter.fieldApiName != null){
				if(String.isNotBlank(filter.operator) && filter.operator != '--None--'){
					if(String.isNotBlank(filter.filterValue) || TYPE_OBJECT_FIELD_SET.contains(filter.fieldDataType) 
					|| filter.operator == CSM_Constants.EXISTS || filter.operator == CSM_Constants.NOT_EXISTS){
						validateQueryFilter(filter, i, queryBuilderWrapper.isIbExport);
						lineFilterMap.put(i, filter);
					}else{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Field_Value_Error));
					}
				}else{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Operator_Error));
				}
			}
		}
		return lineFilterMap;
	}

	public static void validateQueryFilter(REN_QueryBuilderWrapper.ColumnFilter filter, Integer lineNo, boolean isIbExport){
		if(filter.fieldDataType == 'REFERENCE' ){
			processReferenceFilter(filter, lineNo);
		}else if (filter.fieldDataType == CSM_Constants.TYPE_BOOLEAN){
			filter.filterValue = String.valueOf(filter.isCheckBoxChecked);
			filter.filterCondition = filter.fieldApiName + ' = ' + filter.isCheckBoxChecked;
		}else if (filter.fieldDataType == 'MULTIPICKLIST'){
			processMultiSelectFilter(filter);
		}else if (filter.fieldDataType == 'PICKLIST'){
			processPickListFilter(filter, lineNo, isIbExport);
		}else if (TYPE_STRING_SET.contains(filter.fieldDataType)){
			processStringFilter(filter, lineNo, isIbExport);
		}else if (TYPE_NUMBER_SET.contains(filter.fieldDataType)){
			processNumberFilter(filter, lineNo);
		}else if (TYPE_DATE_SET.contains(filter.fieldDataType)){
			processDateFilter(filter, isIbExport);
		}else if (TYPE_NOT_SUPPORTED_SET.contains(filter.fieldDataType)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_Data_Type_Error, new List<String>{''+lineNo})));
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_Data_Type_UnHandle_Error, new List<String>{''+lineNo})));
		}
	}
	
    /* US3928 : Added to support for multi-select picklist values and supported operators.*/
	private static void processMultiSelectFilter(REN_QueryBuilderWrapper.ColumnFilter filter){
    	system.debug('@@@@ filter.filterValue  '+filter.filterValue );
    	String optionValues = filter.filterValue.removeEnd(']');
    	optionValues = optionValues.removeStart('[');
    	
    	Set<String> filterSet = parseCsvString(optionValues);
    	filter.filterStringValueSet = filterSet;
    	
    	String selectedValues = '';
    	for(String value :filter.filterStringValueSet){
    		selectedValues =  value +';' +selectedValues;
    	}
    	
    	filter.filterValue = selectedValues.removeEnd(';');
    	system.debug('@@@@ filter.filterValue after  '+filter.filterValue );
    	
    	if((filter.operator == CSM_Constants.OPERATOR_EQUAL || filter.operator == CSM_Constants.OPERATOR_NOTEQUAL)){      
			filter.filterCondition = filter.fieldApiName + (filter.operator == CSM_Constants.OPERATOR_NOTEQUAL ? ' !=': ' =') + ' \''+ filter.filterValue + '\'';
		}else if ((filter.operator == 'INCLUDES' || filter.operator == 'EXCLUDES') ){
		    filter.filterCondition = filter.fieldApiName + (filter.operator == 'INCLUDES' ? ' INCLUDES (':  ' EXCLUDES (') + '  \''+ filter.filterValue + '\')';
		}
		system.debug('@@@@ filter.filterCondition  '+filter.filterCondition );
	}
	
	/* US3928 : Added to support multi-select option for picklist values and supported operators.*/
	private static void processPickListFilter(REN_QueryBuilderWrapper.ColumnFilter filter, Integer lineNo, boolean isIbExport){
		system.debug('@@@@ filter.filterValue String :: '+filter.filterValue );
    	String optionValues = filter.filterValue.removeEnd(']');
    	optionValues = optionValues.removeStart('[');
    	
    	Set<String> filterSet = parseCsvString(optionValues);
    	filter.filterStringValueSet = filterSet;
    	if ((filter.operator == CSM_Constants.OPERATOR_IN || filter.operator == CSM_Constants.OPERATOR_NOTIN)){
    		String finalValue = System.JSON.serialize(filterSet).replace('"','\'');
			finalValue = finalValue.replace('[','(');
			finalValue = finalValue.replace(']',')');
			filter.filterCondition = filter.fieldApiName + ' ' + CSM_Constants.OPERATOR_IN + ' ' +  finalValue;
    	 }
		system.debug('@@@@ filter.filterCondition  '+filter.filterCondition );
	}

	private static void processStringFilter(REN_QueryBuilderWrapper.ColumnFilter filter, Integer lineNo, boolean isIbExport){
		Set<String> filterSet = parseCsvString(filter.filterValue);
		filter.filterStringValueSet = filterSet;
		if((filter.operator == CSM_Constants.OPERATOR_EQUAL || filter.operator == CSM_Constants.OPERATOR_NOTEQUAL) && lineNo == 1){      
			filter.filterCondition = filter.fieldApiName + (filter.operator == CSM_Constants.OPERATOR_NOTEQUAL ? ' NOT': '') + ' IN :sFilter'+ lineNo;
		} else if ((filter.operator == CSM_Constants.OPERATOR_IN || filter.operator == CSM_Constants.OPERATOR_NOTIN) && lineNo == 1){
			filter.filterCondition = filter.fieldApiName + (filter.operator == CSM_Constants.OPERATOR_NOTIN ? ' NOT': '') + ' IN :sFilter'+ lineNo;
		} else if (filter.operator == CSM_Constants.OPERATOR_EQUAL || filter.operator == CSM_Constants.OPERATOR_NOTEQUAL){
			filter.filterCondition = filter.fieldApiName + ' ' + filter.operator + ' ' + '\'' + filter.filterValue + '\'';
		} else if (filter.operator == CSM_Constants.EXISTS){
			filter.filterValue = String.isNotBlank(filter.filterValue) ? '' : filter.filterValue;
			filter.filterCondition = filter.fieldApiName + ' ' + CSM_Constants.OPERATOR_NOTEQUAL + ' ' + '\'' + '\'';
		} else if (filter.operator == CSM_Constants.NOT_EXISTS) {
			filter.filterValue = String.isNotBlank(filter.filterValue) ? '' : filter.filterValue;
			filter.filterCondition = filter.fieldApiName + ' ' + CSM_Constants.OPERATOR_EQUAL + ' ' + '\'' + '\'';
		} else if (filter.operator == CSM_Constants.OPERATOR_IN || filter.operator == CSM_Constants.OPERATOR_NOTIN) {
			String finalValue = System.JSON.serialize(filterSet).replace('"','\'');
			finalValue = finalValue.replace('[','(');
			finalValue = finalValue.replace(']',')');
			filter.filterCondition = filter.fieldApiName + ' ' + CSM_Constants.OPERATOR_IN + ' ' +  finalValue;
		} else if (filter.operator == CSM_Constants.STARTS_WITH) {
			filter.filterCondition = filter.fieldApiName + ' ' + CSM_Constants.OPERATOR_LIKE + ' \''  +  filter.filterValue + '%\'';
		} else if (filter.operator == CSM_Constants.OPERATOR_LIKE) {
			filter.filterCondition = filter.fieldApiName + ' ' + CSM_Constants.OPERATOR_LIKE + ' \'%'  +  filter.filterValue + '%\'';
		} 
	}

	private static void processNumberFilter(REN_QueryBuilderWrapper.ColumnFilter filter, Integer lineNo){
		Set<String> filterSet = parseCsvString(filter.filterValue);
		filter.filterNumberValueSet = parseNumericFliters(filterSet);
		
		if((filter.operator == CSM_Constants.OPERATOR_EQUAL || filter.operator == CSM_Constants.OPERATOR_NOTEQUAL) && lineNo == 1){      
			filter.filterCondition = filter.fieldApiName + (filter.operator == CSM_Constants.OPERATOR_NOTEQUAL ? ' NOT': '') + ' IN :nFilter'+ lineNo;
		} else if ((filter.operator == CSM_Constants.OPERATOR_IN || filter.operator == CSM_Constants.OPERATOR_NOTIN) && lineNo == 1){
			filter.filterCondition = filter.fieldApiName + (filter.operator == CSM_Constants.OPERATOR_NOTIN ? ' NOT': '') + ' IN :nFilter'+ lineNo;
		} else if (filter.operator == CSM_Constants.OPERATOR_GREATERTHAN || filter.operator == CSM_Constants.OPERATOR_GREATERTHANEQUALTO || 
				filter.operator == CSM_Constants.OPERATOR_LESSERTHAN || filter.operator == CSM_Constants.OPERATOR_LESSERTHANEQUALTO || 
				filter.operator == CSM_Constants.OPERATOR_EQUAL || filter.operator == CSM_Constants.OPERATOR_NOTEQUAL){
			filter.filterCondition = filter.fieldApiName + ' ' + filter.operator + ' ' + filter.filterValue;
		}
	}

	private static void processDateFilter(REN_QueryBuilderWrapper.ColumnFilter filter, Boolean isIbExport){
		try{
			if(filter.fieldDataType == CSM_Constants.TYPE_DATE){
				if(filter.relatedObject.get('RLM_Date_Value__c') != null) {
					Date filterDate = (Date) filter.relatedObject.get('RLM_Date_Value__c');
					if(filterDate != null){
						filter.filterValue = String.valueOf(filterDate);
						filter.filterCondition = filter.fieldApiName + ' ' + filter.operator + ' ' + filter.filterValue;
					}
				}
				if (filter.relatedObject.get('RLM_Is_Specific_Date__c') != null && !(Boolean)filter.relatedObject.get('RLM_Is_Specific_Date__c'))
                {
                	filter.filterCondition = getConditionWithDateLiteral(filter);
                }
			}else if(filter.fieldDataType ==  CSM_Constants.TYPE_DATETIME){
				if(filter.relatedObject.get('RLM_DateTime_Value__c') != null) {
					DateTime filterDateTime = DateTime.valueOfGmt(String.valueof(filter.relatedObject.get('RLM_DateTime_Value__c'))); 
					if(filterDateTime != null){
						filter.filterValue = String.valueOf(filterDateTime);
                        String filterVal = isIbExport ? String.valueOf(filterDateTime) : String.valueOf(filterDateTime.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\''));
						filter.filterCondition = filter.fieldApiName + ' ' + filter.operator + ' ' + filterVal;					}
				}
				if (filter.relatedObject.get('RLM_Is_Specific_Date__c') != null && !(Boolean)filter.relatedObject.get('RLM_Is_Specific_Date__c'))
                {
                	filter.filterCondition = getConditionWithDateLiteral(filter);
                }
			}
			if((filter.relatedObject.get('RLM_DateTime_Value__c') == null && filter.relatedObject.get('RLM_Date_Value__c') == null) 
			&& (filter.operator != CSM_Constants.EXISTS && filter.operator != CSM_Constants.NOT_EXISTS) && isIbExport){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Field_Value_Error));
			}
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Invalid Input - ' + e.getMessage()));
		}
	}
	
	private static String getConditionWithDateLiteral(REN_QueryBuilderWrapper.ColumnFilter filter) {
    	String dateLiteralString = String.valueOf(filter.relatedObject.get('RLM_Date_Literal_String__c'));
        if ((String.valueOf(filter.relatedObject.get('RLM_Date_Literal_String__c'))).contains('_N_') || (String.valueOf(filter.relatedObject.get('RLM_Date_Literal_String__c'))).startsWith('N_'))
		{
			dateLiteralString += ':' + filter.relatedObject.get('RLM_Date_Literal_Number__c');
		} 		
        filter.filterCondition = filter.fieldApiName + ' ' + filter.operator + ' ' + dateLiteralString;
        system.debug('filter.filterCondition>>>>>>>>>>>>In the method>>>>>>>>'+filter.filterCondition);
        return filter.filterCondition;
	}

	private static void processReferenceFilter(REN_QueryBuilderWrapper.ColumnFilter filter, Integer lineNo){
		filter.filterValue = String.isNotBlank(filter.filterValue) ? filter.filterValue : (String) filter.relatedObject.get(filter.fieldApiName);

		if(String.isBlank(filter.filterValue) && filter.operator != CSM_Constants.EXISTS && filter.operator != CSM_Constants.NOT_EXISTS){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Field_Value_Error));
		}
		filter.filterCondition = filter.fieldApiName  + ' ' + filter.operator + ' ' + ' \'' + filter.filterValue + '\'';
	}


	/* This method used to parse bulk filter values i.e 240k char. */
	public static Set<String> parseCsvString(string filterValue){
		Set<String> parsedSet;
		String firstFilterStr = filterValue;
		if(filterValue.length() < 140000){
			parsedSet = REN_Util.parseFilterValues(filterValue);
		}else{
			Integer index = 0;
			if(filterValue.contains(',')) {
				index = (filterValue.substring(0,140000)).lastIndexOfIgnoreCase(',');
			} else if(filterValue.contains('\n')) {
				index = (filterValue.substring(0,140000)).lastIndexOfIgnoreCase('\n');
			}
			firstFilterStr = filterValue.substring(0,index);
			filterValue = filterValue.substring(index+1);
			parsedSet = REN_Util.parseFilterValues(firstFilterStr);
			parsedSet.addAll(REN_Util.parseFilterValues(filterValue));
		}
		return parsedSet;
	}

	/* This method used to identify valid numeric values.*/
	private static Set<Integer> parseNumericFliters(Set<String> strValueSet){
		Set<Integer> parsedNumberSet = new Set<Integer>();
		try{
			for(String val :strValueSet){
				parsedNumberSet.add(Integer.valueOf(val));
			}
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Invalid Input - ' + e.getMessage()));
		}
		return parsedNumberSet;
	}


	/* This method is used to validate 'Add Filter Logic' in Query Builder */
	public static Boolean validateFilterLogic(String filterLogic, List<REN_QueryBuilderWrapper.ColumnFilter> criteriaList){
		if(String.isBlank(filterLogic)){
			return true;
		}
		if(criteriaList == null || criteriaList.isEmpty()){
			return false;
		}
		String filterLogicToValidate = filterLogic.replaceAll('\\(', '').replaceAll('\\)', '');
		list<String> splitFilterList = filterLogicToValidate.split('[a-zA-Z ][a-zA-Z ]');
		List<String> listOfLogicNum = new List<String>();

		for(String s: splitFilterList){
			if(!String.isEmpty(s) )
				listOfLogicNum.add(s.trim());
		}

		Set<String> setOfLineNum = new Set<String>(); 
		Integer lineNumber = 1;
		for (REN_QueryBuilderWrapper.ColumnFilter filterObj :criteriaList){
			String fieldName = filterObj.fieldApiName;
			system.debug('#### '+ fieldName);
			if(String.isNotBlank(filterObj.fieldApiName)){
				system.debug('#### 11'+ fieldName);
				setOfLineNum.add(String.valueOF(lineNumber));
			}
			lineNumber++;
		}
		Set<String> strSet  =  new Set<String>(listOfLogicNum);
		System.debug('-------'+ strSet + ' = ' + setOfLineNum);
		return setOfLineNum.containsAll(strSet) && strSet.containsAll(setOfLineNum);      
	}

	private static String getWhereClauseString(Map<Integer, REN_QueryBuilderWrapper.ColumnFilter> lineFilterMap, String filterLogic)  {
		String finalWhereClauseString;
		if(String.isBlank(filterLogic)) {
			finalWhereClauseString = getWhereClause(lineFilterMap.values());
		}else{
			finalWhereClauseString = getWhereClause(lineFilterMap, filterLogic);
		}
		return finalWhereClauseString;
	} 

	private static String getWhereClause(Map<Integer, REN_QueryBuilderWrapper.ColumnFilter> lineFilterMap, String filterLogic)  {

		String finalWhereClauseString='';
		String[] splitFilterLogic = filterLogic.split('(?=\\D)|(?<=\\D)');
		for(String logicChar : splitFilterLogic) {
			if(logicChar != null){
				system.debug('@@@@ ~logicChar - ' + logicChar);
				try {
					finalWhereClauseString += finalWhereClauseString.length() == 0 ? '(':'';
					finalWhereClauseString += lineFilterMap.get(Integer.valueOf(logicChar)).filterCondition;
				}catch(system.TypeException te){
					finalWhereClauseString += String.escapeSingleQuotes(logicChar);
				}
			}
		}
		if(String.isNotBlank(finalWhereClauseString)) {
			finalWhereClauseString += ')';
		}
		return finalWhereClauseString;
	}

	private static String getWhereClause(List<REN_QueryBuilderWrapper.ColumnFilter> lineFilterList)  {
		system.debug('@@@@ IN ~getWhereClause - ' +lineFilterList);
		String finalWhereClauseString='';
		for(Integer i=0; i<lineFilterList.size(); i++) {
			if(i == 0)  {
				finalWhereClauseString = '(' + lineFilterList[i].filterCondition;
			} else {
				finalWhereClauseString += ' AND ' + lineFilterList[i].filterCondition;      
			}
		}  
		if(String.isNotBlank(finalWhereClauseString)) {
			finalWhereClauseString += ')';
		}
		system.debug('@@@@ ~finalWhereClauseString - ' + finalWhereClauseString);      
		return finalWhereClauseString;
	}


	public static Map<String, List<SelectOption>> getDataTypeOperatorMap(){
		Map<String, List<SelectOption>> operatorMap = new Map<String, List<SelectOption>>();
		List<SelectOption> booleanOptions = new List<SelectOption>();
		booleanOptions.add(new SelectOption('', Label.CSM_LBL_NONE));
		booleanOptions.add(new SelectOption('=',Label.REN_LBL_EQUALS));
		booleanOptions.add(new SelectOption('!=',Label.REN_LBL_NOT_EQUAL));

		List<SelectOption> basicOptions = new List<SelectOption>(booleanOptions);
		basicOptions.add(new SelectOption('>',Label.REN_LBL_GREATER_THAN));
		basicOptions.add(new SelectOption('>=',Label.REN_LBL_GREATER_THAN_EQUAL_TO));
		basicOptions.add(new SelectOption('<',Label.REN_LBL_LESSER_THAN));
		basicOptions.add(new SelectOption('<=',Label.REN_LBL_LESSER_THAN_EQUAL_TO));
		basicOptions.add(new SelectOption(CSM_Constants.EXISTS,Label.REN_LBL_EXISTS));
		basicOptions.add(new SelectOption(CSM_Constants.NOT_EXISTS,Label.REN_LBL_NOT_EXISTS));
		
		
		
		List<SelectOption> optionsForLookup = new List<SelectOption>(basicOptions);
		operatorMap.put(CSM_Constants.TYPE_REFERENCE, optionsForLookup);
		operatorMap.put(CSM_Constants.TYPE_DATE, optionsForLookup);
		operatorMap.put(CSM_Constants.TYPE_DATETIME, optionsForLookup);
		
        basicOptions.add(new SelectOption(CSM_Constants.OPERATOR_IN,CSM_Constants.OPERATOR_IN));
        basicOptions.add(new SelectOption(CSM_Constants.OPERATOR_NOTIN,CSM_Constants.OPERATOR_NOTIN));
        
        List<SelectOption> multiselectOptions = new List<SelectOption>();
		multiselectOptions.add(new SelectOption('', Label.CSM_LBL_NONE));
		multiselectOptions.add(new SelectOption('=',Label.REN_LBL_EQUALS));
		multiselectOptions.add(new SelectOption('!=',Label.REN_LBL_NOT_EQUAL));
		multiselectOptions.add(new SelectOption(CSM_Constants.OPERATOR_INCLUDES,label.REN_LBL_INCLUDES));
		multiselectOptions.add(new SelectOption(CSM_Constants.OPERATOR_EXCLUDES,label.REN_LBL_EXCLUDES));
        
		List<SelectOption> pickListOptions = new List<SelectOption>();
		pickListOptions.add(new SelectOption('', Label.CSM_LBL_NONE));
		pickListOptions.add(new SelectOption(CSM_Constants.OPERATOR_IN,CSM_Constants.OPERATOR_IN));
        pickListOptions.add(new SelectOption(CSM_Constants.OPERATOR_NOTIN,CSM_Constants.OPERATOR_NOTIN));

		List<SelectOption> allOptions = new List<SelectOption>(basicOptions);
		allOptions.add(new SelectOption(CSM_Constants.STARTS_WITH, CSM_Constants.STARTS_WITH));
		allOptions.add(new SelectOption(CSM_Constants.OPERATOR_LIKE, Label.REN_LBL_CONTAINS));

		operatorMap.put(null, allOptions);
		operatorMap.put(CSM_Constants.TYPE_STRING, allOptions);
		operatorMap.put(CSM_Constants.TYPE_PICKLIST, pickListOptions);
		operatorMap.put(CSM_Constants.TYPE_MULTIPICKLIST, multiselectOptions);
		operatorMap.put(CSM_Constants.TYPE_TEXTAREA, basicOptions);
		operatorMap.put(CSM_Constants.TYPE_LONGTEXTAREA, basicOptions);
		
		operatorMap.put('ID', allOptions);
		operatorMap.put('EMAIL', allOptions);
		operatorMap.put('URL', allOptions);
		operatorMap.put('PHONE', allOptions);

		operatorMap.put(CSM_Constants.TYPE_INTEGER, basicOptions);
		operatorMap.put(CSM_Constants.TYPE_DOUBLE, basicOptions);
		operatorMap.put(CSM_Constants.TYPE_CURRENCY, basicOptions);
		operatorMap.put(CSM_Constants.TYPE_PERCENT, basicOptions);

		operatorMap.put(CSM_Constants.TYPE_BOOLEAN, booleanOptions);    
		return operatorMap;
	}
	
    public static Map<String, List<SelectOption>> getFieldToOperatorMap(List<REN_RS_Field_Operator__c> rsFieldOperatorList){
        Map<String, List<SelectOption>> operatorMap = new Map<String, List<SelectOption>>();
        
        if(rsFieldOperatorList != null && !rsFieldOperatorList.isEmpty() ){
            for(REN_RS_Field_Operator__c fieldOp : rsFieldOperatorList){
                if(fieldOp.REN_Field_API_Name__c != null && fieldOp.REN_Operators__c != null){
                    List<String> operatorList = fieldOp.REN_Operators__c.split(';');
                    
                    operatorMap.put(fieldOp.REN_Field_API_Name__c, new List<SelectOption>{new SelectOption('', '---None---')});
                    
                    for(String operator : operatorList){
                        if(operator.equalsIgnoreCase('Equals')){
                        	operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption('=',Label.REN_LBL_EQUALS));
                        }else if(operator.equalsIgnoreCase('Not Equal To')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption('!=',Label.REN_LBL_NOT_EQUAL));
                        }else if(operator.equalsIgnoreCase('IN')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption(CSM_Constants.OPERATOR_IN,CSM_Constants.OPERATOR_IN));
                        }else if(operator.equalsIgnoreCase('NOT IN')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption(CSM_Constants.OPERATOR_NOTIN,CSM_Constants.OPERATOR_NOTIN));
                        }else if(operator.equalsIgnoreCase('Greater Than')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption('>',Label.REN_LBL_GREATER_THAN));
                        }else if(operator.equalsIgnoreCase('Greater Or Equal')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption('>=',Label.REN_LBL_GREATER_THAN_EQUAL_TO));
                        }else if(operator.equalsIgnoreCase('Less Than')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption('<',Label.REN_LBL_LESSER_THAN));
                        }else if(operator.equalsIgnoreCase('Less Or Equal')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption('<=',Label.REN_LBL_LESSER_THAN_EQUAL_TO));
                        }else if(operator.equalsIgnoreCase('Exists')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption(CSM_Constants.EXISTS,Label.REN_LBL_EXISTS));
                        }else if(operator.equalsIgnoreCase('Not Exists')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption(CSM_Constants.NOT_EXISTS,Label.REN_LBL_NOT_EXISTS));
                        }else if(operator.equalsIgnoreCase('Starts With')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption(CSM_Constants.STARTS_WITH, CSM_Constants.STARTS_WITH));
                        }else if(operator.equalsIgnoreCase('Contains')){
                            operatorMap.get(fieldOp.REN_Field_API_Name__c).add(new SelectOption(CSM_Constants.OPERATOR_LIKE, Label.REN_LBL_CONTAINS));
                        }
                    }
                    
                }
                
            }
        }
        
        return operatorMap;
    }
}