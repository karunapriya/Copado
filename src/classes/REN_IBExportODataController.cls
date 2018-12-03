/**
 * Created Date     : April 26, 2018
 * Developed By     : Rucha Palasapure, Comity Designs, Inc.
 *
 * Function         : This class is used to create OData Query in JSON.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Rucha                    US3342              April 26, 2018    1.1            Added in sprint 757
**/

public with sharing class REN_IBExportODataController {
    public static String DB_DATETIME_FORMAT = 'yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'';
    public static String DB_DATE_FORMAT = 'yyyy-MM-dd';
    
    private static Map<String,String> getOperatorsMap(){
        Map<String,String> operatorsMap = new Map<String,String>();
        operatorsMap.put(CSM_Constants.OPERATOR_EQUAL, 'eq');
        operatorsMap.put(CSM_Constants.OPERATOR_NOTEQUAL, 'ne');
        operatorsMap.put(CSM_Constants.OPERATOR_GREATERTHAN, 'gt');
        operatorsMap.put(CSM_Constants.OPERATOR_GREATERTHANEQUALTO, 'ge');
        operatorsMap.put(CSM_Constants.OPERATOR_LESSERTHAN, 'lt');
        operatorsMap.put(CSM_Constants.OPERATOR_LESSERTHANEQUALTO, 'le');
        operatorsMap.put(CSM_Constants.STARTS_WITH, 'startswith');
        operatorsMap.put(CSM_Constants.EXISTS,'ne');
        operatorsMap.put(CSM_Constants.NOT_EXISTS,'eq');
        return operatorsMap;
    }
    
    public static String formODataQueryInJson(List<REN_QueryBuilderWrapper.ColumnFilter> filterCriteriaList, String logicString, Boolean hasCustomPostfix, String relationshipName){
        String jsonQuery = '';
        Map<Integer, String> lineNoToFilterMap = new Map<Integer, String>();
        Set<String> values;
        Integer countInt = 1;
        Map<String,String> operatorsMap = getOperatorsMap();
        Integer searchTextSize = 0;
        
        for(REN_QueryBuilderWrapper.ColumnFilter criteria :filterCriteriaList){
        	values = null;
            if(criteria.fieldApiName != null){
            	
            	String fieldApiName = '';
                
                if(String.isNotBlank(relationshipName)){
                    
                    if(criteria.fieldApiName.contains('.')){
                        String tempStr = criteria.fieldApiName;
                        if(tempStr.replace('__r', '__c').startsWith( (relationshipName.contains('.') ? relationshipName.substringAfter('.') : relationshipName) )){
                            fieldApiName = tempStr.replace('__r', '__c').replace((relationshipName.contains('.') ? relationshipName.substringAfter('.') + '.' : ''), '');
                        }else if(criteria.fieldApiName.startsWith((relationshipName.contains('.') ? relationshipName.substringAfter('.').replace('Id','') : relationshipName))){
                            fieldApiName = criteria.fieldApiName.substringAfter('.');
                        }else{
                            String isParentFields = ( relationshipName.contains('.') ? relationshipName.substringBefore('.').replace('__c', '__r') + '_' : '' );
                            if(String.isNotBlank(isParentFields)){
                                fieldApiName = isParentFields + criteria.fieldApiName;
                            }else{
                                fieldApiName = criteria.fieldApiName.replace('.', '_');
                            }
                        }                        
                    }else{
                        fieldApiName = ( relationshipName.contains('.') ? relationshipName.substringBefore('.').replace('__c', '__r') + '_' : '' ) + criteria.fieldApiName;
                    }
                    
                }else{
                    fieldApiName = criteria.fieldApiName;
                }           
            	
                if(!hasCustomPostfix){
                    fieldApiName = fieldApiName.replace('__c', '').replace(CSM_Util.getNamespace(), '');    
                }
                
                jsonQuery = '(';                
                
                if(criteria.filterValue != null && criteria.filterValue.contains('"')){
                	checkSearchTextLimit(criteria.filterValue.length(), 548000);
                	if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
                		values = REN_Util.processValuesWithDoubleQuotes(criteria.filterValue);	
                	} else {
                		return null;
                	}
                } else if(criteria.filterValue != null && (criteria.filterValue.contains('\n') || criteria.filterValue.contains(',') || criteria.filterValue.contains('\'')) && (!criteria.fieldDataType.equalsIgnoreCase('REFERENCE'))){
                	checkSearchTextLimit(criteria.filterValue.length(), 380000);
                	if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
                		values = new Set<String>(REN_QueryBuilderHelper.parseCsvString(criteria.filterValue));	
                	} else {
                		return null;
                	}
                		
                }
                
                if(criteria.operator == CSM_Constants.EXISTS || criteria.operator == CSM_Constants.NOT_EXISTS){
                	 jsonQuery += criteria.operator.replace(' ', '_')+'(' + fieldApiName+')';
                }else if((criteria.operator == CSM_Constants.OPERATOR_IN) || (criteria.operator == CSM_Constants.OPERATOR_EQUAL && values != null && values.size() > 1)){
                    if(values == null){
                        values = new Set<String>{criteria.filterValue};
                    }
                    if(criteria.fieldDataType.equalsIgnoreCase('String')){
                        jsonQuery += 'IN('+fieldApiName+',' + System.JSON.serialize(values).replace('"','\'') + ')';
                    }
                    else{
                        jsonQuery += 'IN('+fieldApiName+',' + System.JSON.serialize(values).replace('"','') + ')';
                    }
                }
                else if((criteria.operator == CSM_Constants.OPERATOR_NOTIN) || (criteria.operator == CSM_Constants.OPERATOR_NOTEQUAL && values != null && values.size() > 1)){
                    if(values == null){
                        values = new Set<String>{criteria.filterValue};
                    }
                    if(criteria.fieldDataType.equalsIgnoreCase('String')){
                        jsonQuery += 'NOT_IN('+fieldApiName+',' + System.JSON.serialize(values).replace('"','\'') + ')';
                    }
                    else{
                        jsonQuery += 'NOT_IN('+fieldApiName+',' + System.JSON.serialize(values).replace('"','') + ')';
                    }
                }
                else if(criteria.operator == CSM_Constants.STARTS_WITH && criteria.fieldDataType.equalsIgnoreCase('String')){
                    jsonQuery += 'startswith('+fieldApiName+',\''+criteria.filterValue+'\')';              
                }
               else if(criteria.fieldDataType == CSM_Constants.TYPE_DATE || criteria.fieldDataType == CSM_Constants.TYPE_DATETIME){
               		if(criteria.relatedObject.get('RLM_Is_Specific_Date__c') == true || !hasCustomPostfix){
                        Datetime dt = Datetime.valueOfGmt(criteria.filterValue);
                        jsonQuery += fieldApiName 
                            + ' ' + (operatorsMap.containsKey(criteria.operator)?operatorsMap.get(criteria.operator) : '')
                            + ' ' + (criteria.fieldDataType == CSM_Constants.TYPE_DATE ? dt.formatGMT(DB_DATE_FORMAT) : dt.formatGMT(DB_DATETIME_FORMAT));    
                    }else{
                        List<String> dateValueList = REN_Util.getDateByLiteral(new List<String>{(String)criteria.relatedObject.get('RLM_Date_Literal_String__c')},Integer.valueOf(criteria.relatedObject.get('RLM_Date_Literal_Number__c')));
                        if(!dateValueList.isEmpty()){ 
                        	String literal = (String)criteria.relatedObject.get('RLM_Date_Literal_String__c');
                            if(literal == 'Today' || literal == 'Yesterday' || literal == 'Tomorrow' || literal == 'N_DAYS_AGO'){
                                Datetime dt = Datetime.valueOfGmt(dateValueList[0]);
                                jsonQuery += fieldApiName 
                                    + ' ' + (operatorsMap.containsKey(criteria.operator)?operatorsMap.get(criteria.operator) : '')
                                    + ' ' + (criteria.fieldDataType == CSM_Constants.TYPE_DATE ? dt.formatGMT(DB_DATE_FORMAT) : dt.formatGMT(DB_DATETIME_FORMAT));     
                            }else{
                                Datetime startDate = Datetime.valueOfGmt(dateValueList[0]);
                                Datetime endDate = Datetime.valueOfGmt(dateValueList[1]);
                                if(criteria.operator == CSM_Constants.OPERATOR_EQUAL){
                                    jsonQuery += '(' +fieldApiName
                                        +' '+ operatorsMap.get(CSM_Constants.OPERATOR_GREATERTHANEQUALTO) 
                                        + ' '+(criteria.fieldDataType ==CSM_Constants.TYPE_DATE ? startDate.formatGMT(DB_DATE_FORMAT) : startDate.formatGMT(DB_DATETIME_FORMAT))+ ') ' + 'and'
                                        + ' '+'('+fieldApiName
                                        +' '+ operatorsMap.get(CSM_Constants.OPERATOR_LESSERTHANEQUALTO) 
                                        + ' '+(criteria.fieldDataType ==CSM_Constants.TYPE_DATE ? endDate.formatGMT(DB_DATE_FORMAT) : endDate.formatGMT(DB_DATETIME_FORMAT))+')';
                                }else if(criteria.operator == CSM_Constants.OPERATOR_NOTEQUAL){
                                    jsonQuery += '(' + fieldApiName
                                        +' '+ operatorsMap.get(CSM_Constants.OPERATOR_LESSERTHAN) 
                                        + ' '+(criteria.fieldDataType ==CSM_Constants.TYPE_DATE ? startDate.formatGMT(DB_DATE_FORMAT) : startDate.formatGMT(DB_DATETIME_FORMAT))+ ') ' + 'or'
                                        + ' '+'('+fieldApiName
                                        +' '+ operatorsMap.get(CSM_Constants.OPERATOR_GREATERTHAN) 
                                        + ' '+(criteria.fieldDataType ==CSM_Constants.TYPE_DATE ? endDate.formatGMT(DB_DATE_FORMAT) : endDate.formatGMT(DB_DATETIME_FORMAT))+')';
                                }else if(criteria.operator == CSM_Constants.OPERATOR_LESSERTHAN || criteria.operator == CSM_Constants.OPERATOR_GREATERTHANEQUALTO){
                                    jsonQuery += fieldApiName 
                                        + ' ' + (operatorsMap.containsKey(criteria.operator)?operatorsMap.get(criteria.operator) : '')
                                        + ' ' + (criteria.fieldDataType == CSM_Constants.TYPE_DATE ? startDate.formatGMT(DB_DATE_FORMAT) : startDate.formatGMT(DB_DATETIME_FORMAT));    
                                }else if(criteria.operator == CSM_Constants.OPERATOR_GREATERTHAN || criteria.operator == CSM_Constants.OPERATOR_LESSERTHANEQUALTO){
                                    jsonQuery += fieldApiName 
                                        + ' ' + (operatorsMap.containsKey(criteria.operator)?operatorsMap.get(criteria.operator) : '')
                                        + ' ' + (criteria.fieldDataType == CSM_Constants.TYPE_DATE ? endDate.formatGMT(DB_DATE_FORMAT) : endDate.formatGMT(DB_DATETIME_FORMAT));    
                                }   
                            }    
                        }                                              
                 	 }	 
                } else if(values != null && values.size() == 1){
                    jsonQuery += fieldApiName 
                                    + ' ' + (operatorsMap.containsKey(criteria.operator)?operatorsMap.get(criteria.operator) : '')
                                    + ' ' + (criteria.fieldDataType.equalsIgnoreCase('String') || criteria.fieldDataType.equalsIgnoreCase('REFERENCE') || criteria.fieldDataType.equalsIgnoreCase('PICKLIST')? '\''+new list<string>(values)[0]+'\'' : new list<string>(values)[0]);
                } else{
                    jsonQuery += fieldApiName 
                                    + ' ' + (operatorsMap.containsKey(criteria.operator)?operatorsMap.get(criteria.operator) : '')
                                    + ' ' + (criteria.fieldDataType.equalsIgnoreCase('String') || criteria.fieldDataType.equalsIgnoreCase('REFERENCE') || criteria.fieldDataType.equalsIgnoreCase('PICKLIST')? '\''+criteria.filterValue.remove('\n')+'\'' : criteria.filterValue);
                }
                jsonQuery += ')';
                lineNoToFilterMap.put(countInt,jsonQuery);
                 
            }
            countInt++;
        }
        String whereClause = '';
        if(lineNoToFilterMap != null && !lineNoToFilterMap.isEmpty() && lineNoToFilterMap.size() > 1){
            logicString = logicString.toLowerCase();
            jsonQuery = getWhereClauseString(lineNoToFilterMap, (logicString != null ? String.escapeSingleQuotes(logicString) : logicString ));
        }
        else{
            jsonQuery = jsonQuery.removeStart('(');
            jsonQuery = jsonQuery.removeEnd(')');
        }
        return jsonQuery;
     }
     
     public static String getWhereClauseString(Map<Integer, String> lineNoToFilterMap, String filterLogic)  {
        String finalWhereClauseString='';
        if(String.isNotBlank(filterLogic)){
            String[] splitFilterLogic = filterLogic.split('(?=\\D)|(?<=\\D)');
            for(String logicChar : splitFilterLogic) {
                if(logicChar != null){
                    try {
                        finalWhereClauseString += lineNoToFilterMap.get(Integer.valueOf(logicChar));
                    }
                    catch(system.TypeException te){
                        finalWhereClauseString += String.escapeSingleQuotes(logicChar);
                    }
                }
            }
        }
        else{
        	for(String filter : lineNoToFilterMap.values()){
        		if(String.isBlank(finalWhereClauseString)){
        			finalWhereClauseString = filter;
        		}
        		else{
        			finalWhereClauseString += ' and ' + filter; 
        		}        		
        	}       	
        }
        return finalWhereClauseString;
    }
    private static void checkSearchTextLimit(Integer searchTextLength, Integer supportedLimit) {
    	if(searchTextLength > supportedLimit) {
    		system.debug('searchTextLength::'+searchTextLength);
    		searchTextLength = searchTextLength - supportedLimit;
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,String.format(Label.REN_LBL_CRITERIA_LIMIT_EXCEED,new List<String>{String.valueOf(searchTextLength)}));
			ApexPages.addMessage(myMsg);
    	}
    }
}