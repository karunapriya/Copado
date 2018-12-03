public with sharing class REN_LineCriteriaDataAccess {
	public static List<REN_Line_Criteria__c> getLineCriteriaListByConfig(String configurationId, String objectName){
		List<REN_Line_Criteria__c> lineCriteriaList = new List<REN_Line_Criteria__c>();
		List<String> lineCriteriaFieldList = new List<String>{REN_Constants.OBJ_LC_RENEW_CONFIG, 
													REN_Constants.OBJ_LC_CRITERIA, 
													REN_Constants.OBJ_LC_DATE_LITERAL_STRING,
													REN_Constants.OBJ_LC_DATE_LITERAL_NUMBER,
													REN_Constants.OBJ_LC_DATE_STRING,
													REN_Constants.OBJ_LC_IS_SPECIFIC_DATE,
													REN_Constants.OBJ_LC_DATE,
													REN_Constants.OBJ_LC_TYPE,
													REN_Constants.OBJ_LC_DISPLAY_NAME,
													REN_Constants.OBJ_LC_FIELD_VALUE,
													REN_Constants.OBJ_LC_OBJ_API_NAME,
													REN_Constants.OBJ_LC_OBJ_FIELD_API_NAME,
													REN_Constants.OBJ_LC_OPERATOR,
													REN_Constants.OBJ_LC_DATETIME};

        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(REN_Constants.OBJ_LC, 
                CSM_Constants.DML_OPERATION_READ, lineCriteriaFieldList);
        if (noAccessFieldList.isEmpty())
        {    
        	String queryString = ' Select Id, REN_Renew_Configuration__c, RLM_Criteria__c, RLM_Values__c, ';
        	queryString +=	' RLM_Object_API_Name__c, RLM_Field_Name__c, RLM_Operator__c, RLM_Date_Literal_String__c, ' ;
        	queryString +=	' RLM_LineNo__c, RLM_Field_Type__c, RLM_Date_Literal_Number__c, RLM_Date_String__c, ';
        	queryString +=	' RLM_Date_Value__c, RLM_Field_Display_Name__c, RLM_Is_Specific_Date__c, RLM_DateTime_Value__c ';
        	queryString +=	' From REN_Line_Criteria__c ';
        	queryString +=	' Where REN_Renew_Configuration__c =:configurationId ';
        	if(objectName != null){
        		queryString +=	' AND RLM_Object_API_Name__c=:objectName ';
        	}
        	queryString +=	' ORDER BY RLM_LineNo__c limit 500 ';
        	lineCriteriaList = Database.query(queryString);
        }
        else
        {
			String[] arguments = new String[] {REN_Constants.OBJ_LC + ':'+String.valueOf(noAccessFieldList)};
		 	throw new CSM_AccessController.AccessControlDmlException( String.format(
		 	System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }
	
		return lineCriteriaList;
	}
	
	public static List<REN_Line_Criteria__c> upsertLineCriterias(List<REN_Line_Criteria__c> lineCriteriaList){
		List<String> lineCriteriaFieldList = new List<String>{//REN_Constants.OBJ_LC_RENEW_CONFIG, 
													REN_Constants.OBJ_LC_CRITERIA, 
													REN_Constants.OBJ_LC_DATE_LITERAL_STRING,
													REN_Constants.OBJ_LC_DATE_LITERAL_NUMBER,
													REN_Constants.OBJ_LC_DATE_STRING,
													REN_Constants.OBJ_LC_IS_SPECIFIC_DATE,
													REN_Constants.OBJ_LC_DATE,
													REN_Constants.OBJ_LC_TYPE,
													REN_Constants.OBJ_LC_DISPLAY_NAME,
													REN_Constants.OBJ_LC_FIELD_VALUE,
													REN_Constants.OBJ_LC_OBJ_API_NAME,
													REN_Constants.OBJ_LC_OBJ_FIELD_API_NAME,
													REN_Constants.OBJ_LC_OPERATOR,
													REN_Constants.OBJ_LC_DATETIME};

        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(REN_Constants.OBJ_LC, 
                CSM_Constants.DML_OPERATION_UPSERT, lineCriteriaFieldList);
        if (noAccessFieldList.isEmpty()){    
        	upsert lineCriteriaList;
        }
        else{
        	String[] arguments = new String[] {REN_Constants.OBJ_LC + ':'+String.valueOf(noAccessFieldList)};
			throw new CSM_AccessController.AccessControlDmlException( String.format(
		        System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments)); 
        }
	
		return lineCriteriaList;
	}

	public static void deleteLineCriteria(List<REN_Line_Criteria__c> lineCriteriaListToDelete){
		List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(REN_Constants.OBJ_LC, 
                CSM_Constants.DML_OPERATION_DELETE, null);
        if (noAccessFieldList.isEmpty()){    
        	delete lineCriteriaListToDelete;
        }
        else{
        	String[] arguments = new String[] {REN_Constants.OBJ_LC};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_DELETABLE, arguments));	
        }
	}
}