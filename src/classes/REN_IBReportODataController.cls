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

public with sharing class REN_IBReportODataController {
    
    private static Map<String,String> getOperatorsMap(){
        Map<String,String> operatorsMap = new Map<String,String>();
        operatorsMap.put(CSM_Constants.OPERATOR_EQUAL, 'eq');
        operatorsMap.put(CSM_Constants.OPERATOR_NOTEQUAL, 'ne');
        operatorsMap.put(CSM_Constants.OPERATOR_GREATERTHAN, 'gt');
        operatorsMap.put(CSM_Constants.OPERATOR_GREATERTHANEQUALTO, 'ge');
        operatorsMap.put(CSM_Constants.OPERATOR_LESSERTHAN, 'lt');
        operatorsMap.put(CSM_Constants.OPERATOR_LESSERTHANEQUALTO, 'le');
        operatorsMap.put(CSM_Constants.STARTS_WITH, 'startswith');
        return operatorsMap;
    }
    
    public static String formODataQueryInJson(List<REN_QueryBuilderWrapper.ColumnFilter> filterCriteriaList, String logicString){
        String jsonQuery = '';
        Map<Integer, String> lineNoToFilterMap = new Map<Integer, String>();
        List<String> values;
        Integer countInt = 1;
        Map<String,String> operatorsMap = getOperatorsMap();
        for(REN_QueryBuilderWrapper.ColumnFilter criteria :filterCriteriaList){
            if(criteria.fieldApiName != null && criteria.filterValue != null){
                jsonQuery = '(';                
                if(criteria.filterValue != null && criteria.filterValue.contains(',')){
                    values = criteria.filterValue.split(',');                    
                }
                if((criteria.operator == CSM_Constants.OPERATOR_IN || criteria.operator == CSM_Constants.OPERATOR_EQUAL) && values != null && values.size() > 1){
                    if(criteria.fieldDataType.equalsIgnoreCase('String')){
                        jsonQuery += 'IN('+criteria.fieldApiName+',[\''+criteria.filterValue.replace(',','\',\'')+'\'])';
                    }
                    else{
                        jsonQuery += 'IN('+criteria.fieldApiName+',['+criteria.filterValue+'])';
                    }
                }
                else if((criteria.operator == CSM_Constants.OPERATOR_NOTIN || criteria.operator == CSM_Constants.OPERATOR_NOTEQUAL) && values != null && values.size() > 1){
                    if(criteria.fieldDataType.equalsIgnoreCase('String')){
                        jsonQuery += 'NOT_IN('+criteria.fieldApiName+',[\''+criteria.filterValue.replace(',','\',\'')+'\'])';
                    }
                    else{
                        jsonQuery += 'NOT_IN('+criteria.fieldApiName+',['+criteria.filterValue+'])';
                    }
                }
                else if(criteria.operator == CSM_Constants.STARTS_WITH && criteria.fieldDataType.equalsIgnoreCase('String')){
                    jsonQuery += 'startswith('+criteria.fieldApiName+',\''+criteria.filterValue+'\')';              
                }
                else if(criteria.fieldDataType == CSM_Constants.TYPE_DATE || criteria.fieldDataType == CSM_Constants.TYPE_DATETIME){
                    jsonQuery += criteria.fieldApiName 
                                + ' ' + (operatorsMap.containsKey(criteria.operator)?operatorsMap.get(criteria.operator) : '')
                                + ' ' + '\''+criteria.filterValue+'\'';
                }
                else{
                    jsonQuery += criteria.fieldApiName 
                                    + ' ' + (operatorsMap.containsKey(criteria.operator)?operatorsMap.get(criteria.operator) : '')
                                    + ' ' + (criteria.fieldDataType.equalsIgnoreCase('String')? '\''+criteria.filterValue+'\'' : criteria.filterValue);
                }
                jsonQuery += ')';
                lineNoToFilterMap.put(countInt,jsonQuery);
                countInt++; 
            }
        }
        String whereClause = '';
        if(lineNoToFilterMap != null && !lineNoToFilterMap.isEmpty() && lineNoToFilterMap.size() > 1){
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
        			finalWhereClauseString += ' AND ' + filter; 
        		}        		
        	}       	
        }
        return finalWhereClauseString;
    }
    
}