/**
 * Created Date		: Mar 9, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: This class is created to have common code for Channel query builder
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2155					Mar 9, 2017		1.1					Added in sprint 709
 *
 */
public with sharing class CHL_QueryBuilderUtil {
	static string namespace = CSM_Util.getNamespace();
	
	public static Map<String, List<SelectOption>> populateOperatorMap(){
		Map<String, List<SelectOption>> operatorMap = new Map<String, List<SelectOption>>();
		Map<String, String> operatorValueMap = getOperatorMap();
		List<SelectOption> multiPicklistOperatorsOptions = new List<SelectOption>();
		List<String> multiPicklistOperatorsList = new List<String> { 
			Label.CHL_LBL_EQUALS,
			Label.CHL_LBL_NOT_EQUAL_TO
		};
		
		for(String str : multiPicklistOperatorsList) {
			multiPicklistOperatorsOptions.add(new SelectOption(operatorValueMap.get(str), str));
		}
		
		List<SelectOption> checkBoxOperatorsOptions = new List<SelectOption>();
		List<String> checkBoxOperatorsList = new List<String> { 
			Label.CHL_LBL_IS_EQUAL_TO
		};	
		for(String str : checkBoxOperatorsList) {
			checkBoxOperatorsOptions.add(new SelectOption(operatorValueMap.get(str), str));
		}	
		
		List<SelectOption> dateOperatorsOptions = new List<SelectOption>();
		List<String> dateOperatorsList = new List<String> { 
			Label.CHL_LBL_IS_EQUAL_TO,Label.CHL_LBL_NOT_EQUAL_TO, Label.CHL_LBL_IS_BETWEEN, Label.CHL_LBL_IS_BEFORE, Label.CHL_LBL_IS_AFTER
		};
		for(String str : dateOperatorsList) {
			dateOperatorsOptions.add(new SelectOption(operatorValueMap.get(str), str));
		}
		
		List<SelectOption> allOperatorsOptions = new List<SelectOption>();
		List<String> allOperatorsList = new List<String> {
			Label.CHL_LBL_IS_EQUAL_TO, Label.CHL_LBL_IS_BETWEEN, Label.CHL_LBL_IS_BEFORE, Label.CHL_LBL_IS_AFTER, Label.CHL_LBL_EQUALS,Label.CHL_LBL_NOT_EQUAL_TO
		};
		for(String str : allOperatorsList) {
			allOperatorsOptions.add(new SelectOption(operatorValueMap.get(str), str));
		}
		
		List<SelectOption> integerOperatorsOptions = new List<SelectOption>();
		List<String> integerOperatorsList = new List<String> {
			Label.CHL_LBL_IS_EQUAL_TO, Label.CHL_LBL_NOT_EQUAL_TO, Label.CHL_LBL_IS_GREATER_THAN, Label.CHL_LBL_IS_LESS_THAN
		};										
		for(String str : integerOperatorsList) {
			integerOperatorsOptions.add(new SelectOption(operatorValueMap.get(str), str));
		}
		
		List<SelectOption> textOptions = new List<SelectOption>();
		List<String> textList = new List<String> {
			Label.CHL_LBL_IS_EQUAL_TO, Label.CHL_LBL_NOT_EQUAL_TO, Label.REN_LBL_CONTAINS
		};										
		for(String str : textList) {
			textOptions.add(new SelectOption(operatorValueMap.get(str), str));
		}
		operatorMap.put('DATE', dateOperatorsOptions);
		operatorMap.put('DATETIME', dateOperatorsOptions);
		operatorMap.put('INTEGER', integerOperatorsOptions);
		operatorMap.put('CURRENCY', integerOperatorsOptions);
		operatorMap.put('PERCENT', integerOperatorsOptions);
		operatorMap.put('MULTIPICKLIST', multiPicklistOperatorsOptions);	
		operatorMap.put('REFERENCE', multiPicklistOperatorsOptions);		
		operatorMap.put('BOOLEAN', checkBoxOperatorsOptions);
		operatorMap.put('Record Type', checkBoxOperatorsOptions);	
		operatorMap.put('SELECT', multiPicklistOperatorsOptions);
		operatorMap.put('NUMBER', integerOperatorsOptions);
		operatorMap.put('TEXT', textOptions);
		return operatorMap;	
	}
	public static List<CHL_QueryBuilderResponseWrapper.CHL_Options> getFilterOptions(String fieldName, String fieldType) {
		CHL_QueryBuilderResponseWrapper.CHL_OppPredicates oppPredicatesRec = new CHL_QueryBuilderResponseWrapper.CHL_OppPredicates();
		CHL_QueryBuilderResponseWrapper.CHL_Options optionsRec;
		oppPredicatesRec.options = new List<CHL_QueryBuilderResponseWrapper.CHL_Options>();
		List<String> booleanValues = new List<String>{'True', 'False'};
		if(fieldType.contains('BOOLEAN')) {
    		for(String str : booleanValues) {
    			optionsRec = new CHL_QueryBuilderResponseWrapper.CHL_Options();
    			optionsRec.id = str.toUpperCase();
    			optionsRec.name = str;
    			oppPredicatesRec.options.add(optionsRec);
    		}
    	}
    	return oppPredicatesRec.options;
	}
	public static CHL_QueryBuilderResponseWrapper.CHL_OppPredicates addStaticPredicates(String fieldName, String fieldType,List<SelectOption> operatorList, Integer cnt) {
		CHL_QueryBuilderResponseWrapper.CHL_OppPredicates oppPredicatesRec = new CHL_QueryBuilderResponseWrapper.CHL_OppPredicates();
    	oppPredicatesRec.options = new List<CHL_QueryBuilderResponseWrapper.CHL_Options>();
    	CHL_QueryBuilderResponseWrapper.CHL_Operators operatorsRec;
    	oppPredicatesRec.id = '\'' + cnt + '\'';
    	if(fieldName.equalsIgnoreCase(namespace + 'CHL_FY__c')) {
    		oppPredicatesRec.value = Label.CHL_LBL_YEAR;	
    		oppPredicatesRec.objectType = 'YEAR';
    	} else if(fieldName.equalsIgnoreCase(namespace + 'CHL_EQ__c')) {
    		oppPredicatesRec.value = Label.CHL_LBL_QUARTER;
    		oppPredicatesRec.objectType = 'QUARTER';
    	} else if(fieldName.equalsIgnoreCase(namespace + 'CHL_Sales_Stage__c')) {
    		oppPredicatesRec.value = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_Sales_Stage__c.label;
    		oppPredicatesRec.objectType = fieldName;
    	} else if(fieldName.equalsIgnoreCase(namespace + 'CHL_Needs_Status_Update__c')) {
    		oppPredicatesRec.value = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_Needs_Status_Update__c.label;
    		oppPredicatesRec.objectType = fieldName;
    	}
    	else if(fieldName.equalsIgnoreCase(namespace + 'CHL_Customer_Engagement_Type__c')) {
    		oppPredicatesRec.value = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_Customer_Engagement_Type__c.label;
    		oppPredicatesRec.objectType = fieldName;
    	}
    	oppPredicatesRec.type = fieldType;
    	oppPredicatesRec.options = getFilterOptions(fieldName, '');
    	oppPredicatesRec.apiName = fieldName;
    	oppPredicatesRec.isUsable = true;
    	oppPredicatesRec.operators = new List<CHL_QueryBuilderResponseWrapper.CHL_Operators>();
    	for(SelectOption str : operatorList) {
    		operatorsRec = new CHL_QueryBuilderResponseWrapper.CHL_Operators();
    		operatorsRec.id = str.getValue();
    		operatorsRec.value = str.getLabel();
    		oppPredicatesRec.operators.add(operatorsRec);
    	}
    	return oppPredicatesRec;
	}
	
	
    
    public static List<Object> getFilterFieldsResponse(List<Schema.FieldSetMember> fieldSet, Map<String, List<SelectOption>> operatorMap) {
    	Boolean is2TierPricingEnabled;
     	CHL_QueryBuilderResponseWrapper wrp = new CHL_QueryBuilderResponseWrapper();
    	CHL_QueryBuilderResponseWrapper.CHL_Operators operatorsRec;
    	wrp.oppPredicates = new List<CHL_QueryBuilderResponseWrapper.CHL_OppPredicates>();
        Integer cnt = 4;
        Set<String> fieldNamesSet = new Set<String>();        
        Set<String> staticPredicateSet = new Set<String>();
        Set<String> excludeFieldset = getExcludePredicates();
        Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
        if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null){
       		is2TierPricingEnabled = CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0].CHL_Enable_2_Tier_Pricing__c;
        }
    	//Map<String, List<SelectOption>> operatorMap = CHL_QueryBuilderUtil.populateOperatorMap();
    	CHL_QueryBuilderResponseWrapper.CHL_OppPredicates oppPredicatesRec;
        oppPredicatesRec = addStaticPredicates(namespace + 'CHL_FY__c', 'SELECT', operatorMap.get('SELECT'), 0);
        staticPredicateSet.add(namespace + 'CHL_FY__c');
        wrp.oppPredicates.add(oppPredicatesRec);
        oppPredicatesRec = addStaticPredicates(namespace + 'CHL_EQ__c', 'SELECT', operatorMap.get('SELECT'), 1);
        staticPredicateSet.add(namespace + 'CHL_EQ__c');
        wrp.oppPredicates.add(oppPredicatesRec);
        oppPredicatesRec = addStaticPredicates(namespace + 'CHL_Sales_Stage__c', 'SELECT', operatorMap.get('SELECT'), 2);
        staticPredicateSet.add(namespace + 'CHL_Sales_Stage__c');
        wrp.oppPredicates.add(oppPredicatesRec);
        oppPredicatesRec = addStaticPredicates(namespace + 'CHL_Needs_Status_Update__c', 'BOOLEAN', operatorMap.get('BOOLEAN'), 3);
        staticPredicateSet.add(namespace + 'CHL_Needs_Status_Update__c');
        wrp.oppPredicates.add(oppPredicatesRec);
        oppPredicatesRec = addStaticPredicates(namespace + 'CHL_Customer_Engagement_Type__c', 'SELECT', operatorMap.get('SELECT'), 2);
        staticPredicateSet.add(namespace + 'CHL_Customer_Engagement_Type__c');
        wrp.oppPredicates.add(oppPredicatesRec);
        
    	for (Schema.FieldSetMember fieldSetObj: fieldSet) {
    		if(!(excludeFieldset.contains(String.valueOf(fieldSetObj.getFieldPath())))
    			&& !(staticPredicateSet.contains(String.valueOf(fieldSetObj.getFieldPath())))
    			&& !(String.valueOf(fieldSetObj.getFieldPath()).equalsIgnoreCase(CHL_Constants.OBJ_PO_AMOUNT) && currentUserAccountType == 'Reseller' && is2TierPricingEnabled)
    			&& !(String.valueOf(fieldSetObj.getFieldPath()).equalsIgnoreCase(namespace + 'CHL_MSRP__c') && !is2TierPricingEnabled)) {
    				
		        	oppPredicatesRec = new CHL_QueryBuilderResponseWrapper.CHL_OppPredicates();
		        	oppPredicatesRec.options = new List<CHL_QueryBuilderResponseWrapper.CHL_Options>();
		        	fieldNamesSet.add(String.valueOf(fieldSetObj.getFieldPath()));
		        	oppPredicatesRec.id = '\'' + cnt + '\'';
		        	oppPredicatesRec.type = String.valueOf(fieldSetObj.getType());
		        	if(String.valueOf(fieldSetObj.getType()).containsIgnoreCase('PICKLIST')
		        	|| String.valueOf(fieldSetObj.getType()).containsIgnoreCase('MULTIPICKLIST') 
		        	|| String.valueOf(fieldSetObj.getType()).containsIgnoreCase('REFERENCE')){
		        	//|| ((String.valueOf(fieldSetObj.getFieldPath()).containsIgnoreCase('CHL_EQ__c')) && (String.valueOf(fieldSetObj.getType()).containsIgnoreCase('DOUBLE')))) {
				       	oppPredicatesRec.type = 'SELECT';
				    } else if(String.valueOf(fieldSetObj.getType()) == 'INTEGER' || String.valueOf(fieldSetObj.getType()) == 'PERCENT' || String.valueOf(fieldSetObj.getType()) == 'DOUBLE') {
				    	oppPredicatesRec.type = 'NUMBER';
				    } else if(String.valueOf(fieldSetObj.getType()).containsIgnoreCase('STRING') || String.valueOf(fieldSetObj.getType()).containsIgnoreCase('TEXT')) {
				    	oppPredicatesRec.type = 'TEXT';
				    } /*else if(String.valueOf(fieldSetObj.getType()).containsIgnoreCase('DATE')) {
				    	oppPredicatesRec.type = 'DATE';
				    } */
				    else {
				    	oppPredicatesRec.type = String.valueOf(fieldSetObj.getType());
				    }
				    /*if((String.valueOf(fieldSetObj.getFieldPath()).containsIgnoreCase(namespace + 'CHL_EQ__c'))) {
				    	oppPredicatesRec.objectType = 'QUARTER';
				    	oppPredicatesRec.value = 'Quarter';
				    } else if((String.valueOf(fieldSetObj.getFieldPath()).containsIgnoreCase(namespace + 'CHL_FY__c'))) {
				    	oppPredicatesRec.objectType = 'YEAR';
				    	oppPredicatesRec.value = 'Year';
				    } else {
				    	oppPredicatesRec.objectType = String.valueOf(fieldSetObj.getFieldPath());
				    	oppPredicatesRec.value = String.valueOf(fieldSetObj.getLabel());
				    }*/
				    oppPredicatesRec.objectType = String.valueOf(fieldSetObj.getFieldPath());
				    oppPredicatesRec.value = String.valueOf(fieldSetObj.getLabel());
		        	oppPredicatesRec.options = CHL_QueryBuilderUtil.getFilterOptions(String.valueOf(fieldSetObj.getFieldPath()), oppPredicatesRec.type);
		        	oppPredicatesRec.apiName = String.valueOf(fieldSetObj.getFieldPath());
		        	oppPredicatesRec.isUsable = true;
		        	oppPredicatesRec.operators = new List<CHL_QueryBuilderResponseWrapper.CHL_Operators>();
		        	cnt+=1;
		        	List<SelectOption> operatorList = operatorMap.get(oppPredicatesRec.type);
		        	system.debug('oppPredicatesRec.type :: '+oppPredicatesRec.type);
		        	for(SelectOption str : operatorList) {
		        		operatorsRec = new CHL_QueryBuilderResponseWrapper.CHL_Operators();
		        		operatorsRec.id = str.getValue();
		        		operatorsRec.value = str.getLabel();
		        		oppPredicatesRec.operators.add(operatorsRec);
		        	}
		        	wrp.oppPredicates.add(oppPredicatesRec);
    		}
        }
        return wrp.oppPredicates;
    }
    
    public static String buildQueryCriteria(List<CHL_GridInputWrapper.CHL_GridFilterParams> filters, string queryName, String filterLogic) {
    	
    	Map<Integer, String> lineToConditionMap = new Map<Integer, String>();
		String dateField = '';
		String fieldType = '';
		String queryCondition = '';
		String queryCriteria = '';
		String minValue, maxValue = '';
		Map<String, String> id2OperatorMap = getOperatorMapForQuery();
		
        for(Integer i=0;i<filters.size();i++) {
			dateField = '';
			fieldType = '';
			queryCondition = '';
        
        	if((filters[i].predicate.type).equalsIgnoreCase('TEXT') || (filters[i].predicate.type).equalsIgnoreCase('SELECT') || (filters[i].predicate.type).equalsIgnoreCase('BOOLEAN')) {
				if((filters[i].predicate.objectType).equalsIgnoreCase('COUNTRY')) {
					queryCondition = queryCondition + ' CHL_Partner_Account_1__r.BillingCountry';
				} else if((filters[i].predicate.objectType).ContainsIgnoreCase('SALES_STAGE') && queryName.ContainsIgnoreCase(Label.CHL_LBL_PREDEFINED)){
					queryCondition = queryCondition + ' toLabel(' +filters[i].predicate.apiName+')';
				} else {
					queryCondition = queryCondition + ' ' +filters[i].predicate.apiName;
				}
				fieldType = filters[i].predicate.type;
			} else if((filters[i].predicate.type).equals('DATE') || (filters[i].predicate.type).equals('DATETIME')) {
				dateField = filters[i].predicate.apiName;
				fieldType = filters[i].predicate.type;
			} else if((filters[i].predicate.type).equals('NUMBER') || (filters[i].predicate.type).equals('CURRENCY')) {
				dateField = filters[i].predicate.apiName;
				fieldType = filters[i].predicate.type;
				queryCondition = queryCondition + ' ' +filters[i].predicate.apiName;
			}
        	
        	if(((filters[i].operator.id).equals('EQUALS') && (!(filters[i].predicate.type).equalsIgnoreCase('SELECT'))) 
        	|| (filters[i].operator.id).equals('BEFORE') 
        	|| (filters[i].operator.id).equals('AFTER') 
        	|| (filters[i].operator.id).equals('LESS THAN') 
        	|| (filters[i].operator.id).equals('GREATER THAN') 
        	|| ((filters[i].operator.id).equals('NOT_EQUALS') && (!(filters[i].predicate.type).equalsIgnoreCase('SELECT')))) {
				queryCriteria = '';
				if(fieldType.equalsIgnoreCase('DATE')) {
					if((filters[i].predicate.objectType).equalsIgnoreCase('CREATED_AT')) {
						queryCondition = 'CreatedDate= THIS_WEEK';
					} else {	
						queryCriteria += CSM_CriteriaService.buildDateCriteria(queryCriteria, true, CHL_Util.getDateFromGMT(filters[i].value), id2OperatorMap.get(filters[i].operator.id), 
						'', dateField, null, null, fieldType);
						queryCriteria = queryCriteria.remove('(');
						queryCondition += ' ' + queryCriteria;
					}
					system.debug('dcrit2 - ' + queryCondition);
				} else if(fieldType.equalsIgnoreCase('DATETIME')) {
					String formatedDateField = (filters[i].value).replace('T',' ');
					formatedDateField = formatedDateField.removeEnd('.000Z');
					queryCriteria += CSM_CriteriaService.buildDateCriteria(queryCriteria, true, null, id2OperatorMap.get(filters[i].operator.id), 
					'', dateField, null, DateTime.valueOfGMT(formatedDateField), fieldType);
					queryCriteria = queryCriteria.remove('(');
					queryCondition += queryCriteria;
					system.debug('dcrit2 - ' + queryCondition);
				} else if(fieldType.equalsIgnoreCase('BOOLEAN') ) {
					queryCondition = queryCondition + id2OperatorMap.get(filters[i].operator.id) + filters[i].value;	
				} else if(fieldType.equalsIgnoreCase('NUMBER') || fieldType.equalsIgnoreCase('CURRENCY') ) {
					queryCondition = queryCondition + id2OperatorMap.get(filters[i].operator.id) + filters[i].value;
				}	else {
					queryCondition = queryCondition + id2OperatorMap.get(filters[i].operator.id) + + '\'' + filters[i].value + '\'' ;	
				}
			} else if((filters[i].operator.id).equals('CONTAINS')){
				queryCondition = queryCondition + ' LIKE ' + + '\'%' + filters[i].value + '%\'' ;
			} else if((filters[i].operator.id).equals('BETWEEN')) {
				if(fieldType.equalsIgnoreCase('DATETIME')) {
					String formatedDateField = (filters[i].minValue).replace('T',' ');
					formatedDateField = formatedDateField.removeEnd('.000Z');
					DateTime dateTimeValue = DateTime.valueOfGMT(formatedDateField);
					minValue = dateTimeValue.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
					String formatedDatemaxValueField = (filters[i].maxValue).replace('T',' ');
					formatedDatemaxValueField = formatedDatemaxValueField.removeEnd('.000Z');
					DateTime dateTimemaxValue = DateTime.valueOfGMT(formatedDatemaxValueField);
					maxValue = dateTimemaxValue.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
				} else {
					minValue = String.valueOf(CHL_Util.getDateFromGMT(filters[i].minValue));
					List<String> splitString = minValue.split(' ',2);
					if(splitString != null && !splitString.isEmpty()) {
						minValue = splitString[0];
					}
					
					maxValue = String.valueOf(CHL_Util.getDateFromGMT(filters[i].maxValue));
					splitString = maxValue.split(' ',2);
					if(splitString != null && !splitString.isEmpty()) {
						maxValue = splitString[0];
					}
				}
				
				queryCondition = queryCondition + dateField +' >= ' + minValue +
								' AND ' + dateField + ' <= ' + maxValue;
			} else if((filters[i].operator.id).equals('EQUALS') && (filters[i].predicate.type).equalsIgnoreCase('SELECT')) {
				queryCondition = queryCondition + ' IN ';
				queryCondition = queryCondition + formQueryForInAndNotIn(filters[i], 'IN');
			} else if((filters[i].operator.id).equals('NOT_EQUALS') && (filters[i].predicate.type).equalsIgnoreCase('SELECT')) {
				queryCondition = queryCondition + ' NOT IN ';
				queryCondition = queryCondition + formQueryForInAndNotIn(filters[i], 'NOT IN');
			}
			lineToConditionMap.put(filters[i].index,queryCondition);
    		
    	}
    	REN_LogicBuilderValidationHelper helper = new REN_LogicBuilderValidationHelper();
    	return helper.getWhereClauseString(lineToConditionMap,filterLogic);
    }
    
    public static Map<String, String> getOperatorMap() {
    	Map<String, String> operatorValueMap = new Map<String, String>();
			operatorValueMap.put(Label.CHL_LBL_EQUALS, 'EQUALS');
			operatorValueMap.put(Label.CHL_LBL_IS_EQUAL_TO, 'EQUALS');
			operatorValueMap.put(Label.CHL_LBL_IS_BETWEEN, 'BETWEEN');
			operatorValueMap.put(Label.CHL_LBL_IS_BEFORE, 'BEFORE');
			operatorValueMap.put(Label.CHL_LBL_IS_AFTER, 'AFTER');
			operatorValueMap.put(Label.CHL_LBL_IS_GREATER_THAN, 'GREATER THAN');
			operatorValueMap.put(Label.CHL_LBL_IS_LESS_THAN, 'LESS THAN');
			operatorValueMap.put(Label.REN_LBL_CONTAINS, 'CONTAINS');
			operatorValueMap.put(Label.CHL_LBL_NOT_EQUAL_TO, 'NOT_EQUALS');
		return operatorValueMap;
		
    }
    
    public static Map<String, String> getOperatorMapForQuery() {
    	Map<String, String> id2OperatorMap = new Map<String, String>();
			id2OperatorMap.put('EQUALS', '=');
			id2OperatorMap.put('BEFORE', '<');
			id2OperatorMap.put('AFTER', '>');
			id2OperatorMap.put('GREATER THAN', '>');
			id2OperatorMap.put('LESS THAN', '<');
			id2OperatorMap.put('NOT_EQUALS', '!=');			
		return id2OperatorMap;
		
    }
    
    private static Set<String> getExcludePredicates() {
    	Set<String> excludePredicates = new Set<String>();
    	excludePredicates.add(namespace + 'CHL_Opportunity__c');
		excludePredicates.add('OwnerId');
		excludePredicates.add(namespace + 'CHL_Partner_Account_1_Name__c');
		excludePredicates.add(namespace + 'CHL_Partner_Account_1_Contact_Name__c');
		excludePredicates.add(namespace + 'CHL_Partner_Account_2_Name__c');
		excludePredicates.add(namespace + 'CHL_Partner_Account_2_Contact_Name__c');
		excludePredicates.add('Id');
    	return excludePredicates;
    }
    
    public static List<CHL_GlobalSearchWrapper> getSearchOptions(String objectType, String searchString) {
    	List<CHL_GlobalSearchWrapper> wrp = new List<CHL_GlobalSearchWrapper>();
    	if(objectType.containsIgnoreCase('QUARTER')) {
        		Set<String> quarterSet = new Set<String>{'Q1','Q2','Q3','Q4'};
         		for(String qtr:quarterSet)  {
            		CHL_GlobalSearchWrapper qtrwrp = new CHL_GlobalSearchWrapper(null,'','');
                	qtrwrp.id = qtr;
                	qtrwrp.name = qtr;         
            		wrp.add(qtrwrp);
        		}
        } else if(objectType.containsIgnoreCase('YEAR')){
        		Integer currYear = System.today().Year();
		        for(Integer i = (-10); i <= 10; i++){
		            CHL_GlobalSearchWrapper yearObj = new CHL_GlobalSearchWrapper(null,'','');
		            yearObj.id  = String.valueOf(currYear + i) ;
		            yearObj.name  = yearObj.id;
		            wrp.add(yearObj);
		        }
        } else if(objectType.containsIgnoreCase('SALES_STAGE')) {
        		Map<String,String> picklistValueLabelMap = CHL_Util.getPicklistValuesMap(CHL_Partner_Opportunity__c.CHL_Sales_Stage__c.getDescribe());
		      	for(String str : CHL_Util.getAvailableSalesStage()){
		  			CHL_GlobalSearchWrapper oppStage = new CHL_GlobalSearchWrapper(null,'','');   
		  			if(picklistValueLabelMap.containsKey(str)) {
		    			oppStage.id = str;
		    			oppStage.name = picklistValueLabelMap.get(str); 
		    			wrp.add(oppStage);
		  			}
		    	}
        } 
        else if(objectType.containsIgnoreCase(namespace+'CHL_Customer_Engagement_Type__c')) {
        	Map<String,String> picklistValueLabelMap = CHL_Util.getPicklistValuesMap(CHL_Partner_Opportunity__c.CHL_Customer_Engagement_Type__c.getDescribe());
		    for(String str : picklistValueLabelMap.keyset()){
		  		CHL_GlobalSearchWrapper engagementType = new CHL_GlobalSearchWrapper(null,'','');   
		    	engagementType.id = str;
		    	engagementType.name = picklistValueLabelMap.get(str); 
		    	wrp.add(engagementType);
		    }
        } 
        else {
		    	Schema.SObjectType objType = Schema.getGlobalDescribe().get(CSM_Util.getNamespace() + 'CHL_Partner_Opportunity__c');
		        Schema.DescribeSObjectResult objectResult = objType.getDescribe();
		        system.debug('in d else objectResult : '+objectResult);
		        Schema.DescribeFieldResult fieldResult;
		        String obj = '';
		        String[] objSplit;
		        List<Schema.sObjectType> refObject;
				if(objectType.contains('.')) {
		    		objSplit = objectType.split('\\.');
		            if(objSplit[0].contains('__r')) {
		            	obj = objSplit[0].replace('__r', '__c');
		            } else {
		            	obj = objSplit[0];
		            }
				}
				if(obj != '') {
					fieldResult = objectResult.fields.getMap().get(obj).getDescribe();
					refObject = fieldResult.getReferenceTo();
					system.debug('refObject : '+refObject);
					if(refObject != null && refObject.size() == 1) {
						objType = Schema.getGlobalDescribe().get(String.valueOf(refObject[0]));
		            	objectResult = objType.getDescribe();
		            	fieldResult = objectResult.fields.getMap().get(objSplit[1]).getDescribe();
		            	refObject = fieldResult.getReferenceTo();
						system.debug('refObject in d if : '+refObject);
		    		}
				} else {
		    		fieldResult = objectResult.fields.getMap().get(objectType).getDescribe();
		    		refObject = fieldResult.getReferenceTo();
					system.debug('refObject : '+refObject);
		    	}
		    	system.debug('fieldResult : '+fieldResult);
				Schema.DisplayType fieldType = fieldResult.getType();
				if(String.valueOf(fieldType) == 'PICKLIST') {
			    	wrp = getPickListValues(fieldResult);
					//globalSearchWrpList.addAll(wrp);
				} else {
					wrp = getSearchValues(objectType, searchString,String.valueof(refObject));
				}
    	}
		return wrp;
    }
    
    private static List<CHL_GlobalSearchWrapper> getPickListValues(Schema.DescribeFieldResult fieldResult) {
		List<CHL_GlobalSearchWrapper> globalSearchWrpList = new List<CHL_GlobalSearchWrapper>();
		List<Schema.PicklistEntry> fieldPicklistValues = fieldResult.getPicklistValues();
   		for(Schema.PicklistEntry a : fieldPicklistValues) {
   			CHL_GlobalSearchWrapper pickListValue = new CHL_GlobalSearchWrapper(null,'',''); 
   			pickListValue.id = a.value;
			pickListValue.name = a.value; 
			globalSearchWrpList.add(pickListValue);
   		}
   		return globalSearchWrpList;
	}
	
	private static List<CHL_GlobalSearchWrapper> getSearchValues(String objectType, String searchString, String objName) {
		List<CHL_GlobalSearchWrapper> globalSearchWrpList = new List<CHL_GlobalSearchWrapper>();
		String whereclause = '';
		List<sObject> sobjectList = new List<sObject>();
		system.debug('objName : '+objName);
		if(objectType.containsIgnoreCase('CHL_Partner_Account_1_Contact__c') 
			|| objectType.containsIgnoreCase('CHL_Partner_Account_2_Contact__c')) {
			if(CSM_AccessController.hasField('ACCOUNT', 'isPartner')) {
				whereclause = ' where Accountid in(select Id from Account where ispartner= true)';
			}
			sobjectList = CSM_ContactDataAccess.searchContactByWhereClause(searchString,whereclause);
		} else if(objectType.containsIgnoreCase('CHL_Partner_Account_1__c') 
			|| objectType.containsIgnoreCase('CHL_Partner_Account_2__c')) {
    			if(CSM_AccessController.hasField('ACCOUNT', 'isPartner')) {
        		
        			whereclause = ' Where isPartner = true';
        		} /*else {
        			whereclause = ' Where isPartner = false';
        		}*/
    		
    		sobjectList = CSM_AccountDataAccess.searchAccountsBySOSL(searchString,whereclause);
		} else if(String.isnotBlank(objName)) {
			objName = objName.removeStart('(');
			objName = objName.removeEnd(')');
			//String queryString;
			/*if(objName == 'Case') {
				
			}*/
			String queryString = objName == 'Case'?'FIND\''+ searchString +'*\' IN All Fields Returning '+ objName +'(Id,Subject)':'FIND\''+ searchString +'*\' IN NAME Fields Returning '+ objName +'(Id,Name)';
			system.debug('queryString ::: '+queryString);
			List<List<SObject>>searchList = search.query(queryString);
    		if(searchList != null && searchList.size()>0){
    			sobjectList.addAll(searchList[0]);
			}
		}
		for(sObject sObj:sobjectList) {
			CHL_GlobalSearchWrapper accObj = new CHL_GlobalSearchWrapper(null,'',''); 
			accObj.id = (String)sObj.get('Id');
			accObj.Name = (String)sObj.get('Name');
			globalSearchWrpList.add(accObj);
		}
		return globalSearchWrpList;
	}
	
	private static String formQueryForInAndNotIn(CHL_GridInputWrapper.CHL_GridFilterParams filter, String operator){
	 	String queryCondition = '';
	 	if((filter.values) != null && !(filter.values).isEmpty()) {
			queryCondition = queryCondition + '(';
			for(CHL_GridInputWrapper.CHL_GridParamsOption option:filter.values) {
				if((filter.predicate.objectType).equalsIgnoreCase('QUARTER') && (option.id).startsWith('Q'))  {
					queryCondition = queryCondition + (option.id).removeStartIgnoreCase('Q') + ',';
				} else if((filter.predicate.objectType).equalsIgnoreCase('ACCOUNT'))  {
					queryCondition = queryCondition + '\'' + String.escapeSingleQuotes(option.name) + '\',';
				} else if((filter.predicate.objectType).equalsIgnoreCase('COUNTRY'))  {
					queryCondition = queryCondition+ '\'' + String.escapeSingleQuotes(option.id) + '\',';
				} else {
					queryCondition = queryCondition + '\'' + String.escapeSingleQuotes(option.id) + '\',';
				}
			}
			queryCondition = queryCondition.removeEnd(',');
			queryCondition = queryCondition + ')';
			if(queryCondition.contains('CHL_Partner_Account_1__r.BillingCountry')) {
				String[] countryquery = queryCondition.split(operator);
				queryCondition = '(CHL_Partner_Account_1__r.BillingCountry '+operator +countryquery[1]+' OR CHL_Partner_Account_2__r.BillingCountry '+operator+countryquery[1]+')';
				system.debug('countryquery : '+countryquery);
			}
		} 
		return queryCondition;
	 }
}