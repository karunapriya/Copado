public with sharing class CSM_UserPreferenceAttributeDataAccess {
    public static void saveUserPreferenceAttribute(List<CSM_User_Preference_Attribute__c> userPrefAttribList, String delimitedFields) {
		List<String> fieldList = delimitedFields.split(',');
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP_ATTRIB, fieldList, CSM_Constants.DML_OPERATION_UPSERT);
		upsert userPrefAttribList; 
	}	
	public static List<CSM_User_Preference_Attribute__c> getUserPreferenceAttribute(String accountPlanId, String location, String delimitedFields){
		
		List<String> fieldList = delimitedFields.split(',');
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_UP_ATTRIB, 
            CSM_Constants.DML_OPERATION_READ, fieldList);
        List<CSM_User_Preference_Attribute__c> userPreferenceAttributeList;
        if (noAccessFieldList.isEmpty())
        {      
        	String soql = 'SELECT '+delimitedFields+ ' FROM CSM_User_Preference_Attribute__c WHERE CSM_ObjectId__c =:accountPlanId AND CSM_Location__c = :location';
			userPreferenceAttributeList = Database.Query(soql);
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_UP + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }

		if(userPreferenceAttributeList != null && !userPreferenceAttributeList.isEmpty()){
			system.debug(userPreferenceAttributeList+'::Inside::');
			return userPreferenceAttributeList;
		}
		return null;
	}
	public static List<CSM_User_Preference_Attribute__c> getUserPrefAttribByUserPref(String accountPlanId, String userPreference, String location, String delimitedFields) {
		List<String> fieldList = delimitedFields.split(',');
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_UP_ATTRIB, 
            CSM_Constants.DML_OPERATION_READ, fieldList);
        List<CSM_User_Preference_Attribute__c> userPreferenceAttributeList;
        if (noAccessFieldList.isEmpty())
        {      
        	String soql = 'SELECT '+delimitedFields+ ' FROM CSM_User_Preference_Attribute__c WHERE CSM_User_Preference__c =:userPreference AND CSM_ObjectId__c =:accountPlanId AND CSM_Location__c =:location';
			userPreferenceAttributeList = Database.Query(soql);
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_UP + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }

		if(userPreferenceAttributeList != null && !userPreferenceAttributeList.isEmpty()){
			system.debug(userPreferenceAttributeList+'::Inside::');
			return userPreferenceAttributeList;
		}
		return null;
	}
	public static CSM_User_Preference_Attribute__c getSearchTxtUserPreferenceAttribute(String accountPlanId, String userPreferenceId, String location, String delimitedFields){
		
		List<String> fieldList = delimitedFields.split(',');
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_UP_ATTRIB, 
            CSM_Constants.DML_OPERATION_READ, fieldList);
        List<CSM_User_Preference_Attribute__c> userPreferenceAttributeList;
        if (noAccessFieldList.isEmpty())
        {      
        	String soql = 'SELECT '+delimitedFields+ ' FROM CSM_User_Preference_Attribute__c WHERE CSM_ObjectId__c =:accountPlanId AND (CSM_Success_Plan_Action_Search__c != null OR CSM_Success_Plan_Activity_Search__c != null) AND CSM_User_Preference__c =:userPreferenceId AND CSM_Location__c=:location';
			userPreferenceAttributeList = Database.Query(soql);
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_UP + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }

		if(userPreferenceAttributeList != null && !userPreferenceAttributeList.isEmpty()){
			system.debug(userPreferenceAttributeList+'::Inside::');
			return userPreferenceAttributeList[0];
		}
		return null;
	}
	public static void deleteFilterUserPreference(List<CSM_User_Preference_Attribute__c> userPrefAttribList, String delimitedFields) {
		List<String> fieldList = delimitedFields.split(',');
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP_ATTRIB, fieldList, CSM_Constants.DML_OPERATION_DELETE);
		delete userPrefAttribList; 
	}
}