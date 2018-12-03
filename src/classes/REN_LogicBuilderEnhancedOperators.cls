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
public with sharing class REN_LogicBuilderEnhancedOperators {
	
	public static Map<String, List<SelectOption>> getFieldsToOperatorMap(String flowName){
 		List<REN_RS_Field_Operator__c> rsFieldOperatorList = REN_RSFieldOperatorDataAccess.getRSFieldOperators('IB Export');
        Map<String, list<SelectOption>> fieldToOperatorMap = REN_QueryBuilderHelper.getFieldToOperatorMap(rsFieldOperatorList);
        return fieldToOperatorMap;
	}
	
    public static Map<String, List<SelectOption>> getFieldToOperatorMap(List<REN_RS_Field_Operator__c> rsFieldOperatorList){
        Map<String, List<SelectOption>> operatorMap = new Map<String, List<SelectOption>>();
        
        if(rsFieldOperatorList != null && !rsFieldOperatorList.isEmpty() ){
            for(REN_RS_Field_Operator__c fieldOp : rsFieldOperatorList){
                if(fieldOp.REN_Field_API_Name__c != null && CSM_AccessController.hasField(fieldOp.REN_RS_Configuration__r.REN_Invoking_Object__c, fieldOp.REN_Field_API_Name__c ) && fieldOp.REN_Operators__c != null){
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
                        }
                    }
                    
                }
                
            }
        }
        
        return operatorMap;
    }
    
	public static Map<String, List<SelectOption>> getDataTypeOperatorMap(String flowName){
		Map<String, List<SelectOption>> operatorMap = new Map<String, List<SelectOption>>();
		List<SelectOption> booleanOptions = new List<SelectOption>();
		booleanOptions.add(new SelectOption('', '---None---'));
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

		List<SelectOption> allOptions = new List<SelectOption>(basicOptions);
		allOptions.add(new SelectOption(CSM_Constants.STARTS_WITH, CSM_Constants.STARTS_WITH));

		operatorMap.put(null, allOptions);
		operatorMap.put(CSM_Constants.TYPE_STRING, allOptions);
		operatorMap.put(CSM_Constants.TYPE_PICKLIST, basicOptions);
		operatorMap.put(CSM_Constants.TYPE_MULTIPICKLIST, basicOptions);
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
}