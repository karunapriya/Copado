public with sharing class CSM_PlayCriteriaDataAccess {
	

	public static List<CSM_Play_Criteria__c> populatePlayCriteriaInformation(String playId)
	{
		List<CSM_Play_Criteria__c> criteriaList = new List<CSM_Play_Criteria__c>();
		
		List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_PLAY_CRIT_DATE,
        	CSM_Constants.OBJ_PLAY_CRIT_NAME,CSM_Constants.OBJ_PLAY_CRIT_TYPE, CSM_Constants.OBJ_PLAY_CRIT_DISPLAY_NAME,
        	CSM_Constants.OBJ_PLAY_CRIT_OPERATOR, CSM_Constants.OBJ_PLAY_CRIT_VALUE, CSM_Constants.OBJ_PLAY_CRIT_PLAY,
        	CSM_Constants.OBJ_PLAY_CRIT_IS_SPECIFIC_DATE,CSM_Constants.OBJ_PLAY_CRIT_DATE_LITERAL_NUMBER, 
        	CSM_Constants.OBJ_PLAY_CRIT_DATE_LITERAL_STRING, CSM_Constants.OBJ_PLAY_CRIT_DATETIME};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAY_CRIT, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldList);
                
        if (noAccessFieldList.isEmpty())
        {
        	criteriaList = [SELECT id, RLM_Date_Value__c, RLM_Values__c, RLM_Field_Name__c, RLM_Is_Specific_Date__c, RLM_Date_Literal_String__c,
        					RLM_Field_Type__c, RLM_LineNo__c, CSM_Play__r.Id, CSM_Play__c,	RLM_Operator__c, RLM_Field_Display_Name__c, RLM_Date_Literal_Number__c,
        					RLM_DateTime_Value__c
							from CSM_Play_Criteria__c
							where CSM_Play__c = :playId
							order by RLM_LineNo__c
							limit 100];
        }
        else 
        { 
        	 String[] arguments = new String[] {CSM_Constants.OBJ_PLAY_CRIT + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	

        return 	criteriaList;
	}
	
	/*public static List<CSM_Play_Criteria__c> populatePlayCriteriaInformation(List<String> playIdList)
	{
		List<CSM_Play_Criteria__c> criteriaList = new List<CSM_Play_Criteria__c>();
		
		List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_PLAY_CRIT_DATE,
        	CSM_Constants.OBJ_PLAY_CRIT_NAME,CSM_Constants.OBJ_PLAY_CRIT_TYPE, CSM_Constants.OBJ_PLAY_CRIT_DISPLAY_NAME,
        	CSM_Constants.OBJ_PLAY_CRIT_OPERATOR, CSM_Constants.OBJ_PLAY_CRIT_VALUE, CSM_Constants.OBJ_PLAY_CRIT_PLAY,
        	CSM_Constants.OBJ_PLAY_CRIT_IS_SPECIFIC_DATE,CSM_Constants.OBJ_PLAY_CRIT_DATE_LITERAL_NUMBER, 
        	CSM_Constants.OBJ_PLAY_CRIT_DATE_LITERAL_STRING};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAY_CRIT, 
                CSM_Constants.DML_OPERATION_READ, criteriaFieldList);
                
        if (noAccessFieldList.isEmpty())
        {
        	criteriaList = [SELECT id, RLM_Date_Value__c, RLM_Values__c, RLM_Field_Name__c, RLM_Is_Specific_Date__c, RLM_Date_Literal_String__c,
        					RLM_Field_Type__c, CSM_Play__r.Id, CSM_Play__c,	RLM_Operator__c, RLM_Field_Display_Name__c, RLM_Date_Literal_Number__c
							from CSM_Play_Criteria__c
							where CSM_Play__c in :playIdList
							order by CSM_Play__c
							limit 1000];
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_PLAY_CRIT + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	

        return 	criteriaList;
	}*/
	
	
	public static List<CSM_Play_Criteria__c> savePlayCriteria(List<CSM_Play_Criteria__c> playCriteriaList)
	{
		
		List<String> criteriaFieldList = new List<String>{CSM_Constants.OBJ_PLAY_CRIT_DATE,
        	CSM_Constants.OBJ_PLAY_CRIT_NAME,CSM_Constants.OBJ_PLAY_CRIT_TYPE, CSM_Constants.OBJ_PLAY_CRIT_DISPLAY_NAME,
        	CSM_Constants.OBJ_PLAY_CRIT_OPERATOR, CSM_Constants.OBJ_PLAY_CRIT_VALUE, //CSM_Constants.OBJ_PLAY_CRIT_PLAY,
        	CSM_Constants.OBJ_PLAY_CRIT_DATETIME};
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAY_CRIT, 
                CSM_Constants.DML_OPERATION_UPSERT, criteriaFieldList);
                
        if (noAccessFieldList.isEmpty())
        {
        	upsert playCriteriaList;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_PLAY_CRITERIA_SAVE));
        	
        }
        else
        {
        	 String[] arguments = new String[] {CSM_Constants.OBJ_PLAY_CRIT + ':'+String.valueOf(noAccessFieldList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments));
        }
	
        return 	playCriteriaList;
	}
	
	public static boolean deletePlayCriteria(List<CSM_Play_Criteria__c> playCriteriaList)
	{
        boolean isSuccess = false;
        
        List<String> noAccessFieldList = CSM_AccessController.getInstance(
                ).returnNoPermissionFieldsNameList(CSM_Constants.OBJ_PLAY_CRIT, 
                CSM_Constants.DML_OPERATION_Delete, null);
        //No need to check if list is empty, exception will be thrown if user cannot delete    
        
    	delete playCriteriaList;
    	isSuccess = true;
        	
        return 	isSuccess;
	}			

}