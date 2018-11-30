public with sharing class CSM_UserPreferencesDataAccess {
/*
	public static CSM_User_Preferences__c getUserPreferences(ID userID){
		List<CSM_User_Preferences__c> userPreferencesList = [Select id, CSM_Hide_Overview_Charts__c, CSM_Hide_Inactive_Categories__c, CSM_Object_Field_Filter__c, 
																CSM_Object_Field_Date_Value__c, CSM_Object_Field_Type__c,
																CSM_Object_Field_Filter_User__c, CSM_Object_Field_Filter_Value__c,
																CSM_Overview_Carousel_Chart__c,
															 	CSM_Overview_FC_Group_Filter__c, CSM_Success_Plan_Actions_Filter__c,
															 	CSM_Success_Plan_Actions_Grid_Columns__c, CSM_Success_Plan_Activity_Grid_Columns__c,
															 	CSM_Success_Task_Filter__c,
															 	CSM_Success_Task_Grid_Columns__c,																
																CSM_Object_Filter__c, CSM_Filter_Display_Name__c,Ren_Insights_Selected_Reports__c from CSM_User_Preferences__c where CSM_User__c = :userID];
		if(userPreferencesList != null && !userPreferencesList.isEmpty()){
			return userPreferencesList[0];
		}
		return null;
	}
*/	
	public static CSM_User_Preferences__c getUserPreferences(ID userID, String delimitedFields){
		
		List<String> fieldList = delimitedFields.split(',');
        List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_UP, 
            CSM_Constants.DML_OPERATION_READ, fieldList);
        List<CSM_User_Preferences__c> userPreferencesList;
        if (noAccessFieldList.isEmpty())
        {      
        	String soql = 'SELECT '+delimitedFields+ ' FROM CSM_User_Preferences__c WHERE CSM_User__c =:userID';
			userPreferencesList = Database.Query(soql);
        }
        else
        {
             String[] arguments = new String[] {CSM_Constants.OBJ_UP + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }

		if(userPreferencesList != null && !userPreferencesList.isEmpty()){
			return userPreferencesList[0];
		}
		return null;
	}
	
	public static void saveUserPreference(List<CSM_User_Preferences__c> preferenceObjList, String delimitedFields) {
		List<String> fieldList = delimitedFields.split(',');
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldList, CSM_Constants.DML_OPERATION_UPSERT);
		upsert preferenceObjList; 
	}	
/*	
	public static void saveUserPreferenceForOverviewCharts(List<CSM_User_Preferences__c> preferenceObjList) {
        List<String> fieldListForCRUD = new List<String>{CSM_Constants.OBJ_A_NAME, CSM_Constants.OBJ_UP_User, CSM_Constants.OBJ_UP_Hide_Overview_Charts};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldListForCRUD, CSM_Constants.DML_OPERATION_UPSERT);
		upsert preferenceObjList; 
	}
	
	public static void saveUserPreferenceForInactiveCategories(List<CSM_User_Preferences__c> preferenceObjList) {
        List<String> fieldListForCRUD = new List<String>{CSM_Constants.OBJ_A_NAME, CSM_Constants.OBJ_UP_User, CSM_Constants.OBJ_UP_HIDE_INACTIVE_CATEGORIES};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldListForCRUD, CSM_Constants.DML_OPERATION_UPSERT);
		upsert preferenceObjList; 
	}
	public static void saveUserPreferenceForFilterAttributes(List<CSM_User_Preferences__c> preferenceObjList) {
        List<String> fieldListForCRUD = new List<String>{CSM_Constants.OBJ_A_NAME, CSM_Constants.OBJ_UP_User, 
        									CSM_Constants.OBJ_UP_HIDE_INACTIVE_CATEGORIES,
        									CSM_Constants.OBJ_UP_FIELD_FILTER,
        									CSM_Constants.OBJ_UP_FIELD_FILTER_USER,
        									CSM_Constants.OBJ_UP_FIELD_FILTER_VALUE,
        									CSM_Constants.OBJ_UP_FILTER,
        									CSM_Constants.OBJ_UP_FILTER_DISPLAY_NAME,
        									CSM_Constants.OBJ_UP_FIELD_FILTER_DATE_VALUE
        								};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldListForCRUD, CSM_Constants.DML_OPERATION_UPSERT);
		upsert preferenceObjList; 
	}	
	
	public static void saveUserPreferenceForReports(List<CSM_User_Preferences__c> preferenceObjList) {
        List<String> fieldListForCRUD = new List<String>{CSM_Constants.OBJ_A_NAME, CSM_Constants.OBJ_UP_User, 
        									CSM_Constants.OBJ_UP_HIDE_INACTIVE_CATEGORIES
        								};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldListForCRUD, CSM_Constants.DML_OPERATION_UPSERT);
		upsert preferenceObjList; 
	}	
	
	public static void saveUserPreferenceForChannelViewedOptys(List<CSM_User_Preferences__c> preferenceObjList) {
        List<String> fieldListForCRUD = new List<String>{CHL_Constants.OBJ_UP_VIEWED_NEW_OPTY_DATE};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldListForCRUD, CSM_Constants.DML_OPERATION_UPSERT);
		upsert preferenceObjList; 
	}
	
	public static CSM_User_Preferences__c getCSMGridAndFilterUserPreferences(ID userID){
        List<String> fieldListForCRUD = new List<String>{CSM_Constants.OBJ_A_ID, CSM_Constants.OBJ_A_NAME,CSM_Constants.OBJ_UP_USER,
        													CSM_Constants.OBJ_UP_OVERVIEW_CAROUSEL_CHART,
        													CSM_Constants.OBJ_UP_OVERVIEW_FCGROUP_FILTER,
        													CSM_Constants.OBJ_UP_SP_ACTION_FILTER,
        													CSM_Constants.OBJ_UP_SP_ACTION_GRID_COLUMNS,
        													CSM_Constants.OBJ_UP_SP_ACTIVITY_GRID_COLUMNS,
        													CSM_Constants.OBJ_UP_ST_ACTION_GRID_COLUMNS};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldListForCRUD, CSM_Constants.DML_OPERATION_READ);
		List<CSM_User_Preferences__c> userPreferencesList = [Select id, CSM_Overview_Carousel_Chart__c,
															 CSM_Overview_FC_Group_Filter__c, CSM_Success_Plan_Actions_Filter__c,
															 CSM_Success_Plan_Actions_Grid_Columns__c, CSM_Success_Plan_Activity_Grid_Columns__c,
															 CSM_Success_Task_Filter__c,
															 CSM_Success_Task_Grid_Columns__c from CSM_User_Preferences__c where CSM_User__c = :userID];
		if(userPreferencesList != null && !userPreferencesList.isEmpty()){
			return userPreferencesList[0];
		}
		return null;
	}

	public static void saveUserPreferenceForOverviewChart(List<CSM_User_Preferences__c> preferenceObjList) {
        List<String> fieldListForCRUD = new List<String>{CSM_Constants.OBJ_UP_OVERVIEW_CAROUSEL_CHART};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldListForCRUD, CSM_Constants.DML_OPERATION_UPSERT);
		upsert preferenceObjList; 
	}

	public static void saveUserPreferenceForOverviewFCG(List<CSM_User_Preferences__c> preferenceObjList) {
        List<String> fieldListForCRUD = new List<String>{CSM_Constants.OBJ_UP_OVERVIEW_FCGROUP_FILTER};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldListForCRUD, CSM_Constants.DML_OPERATION_UPSERT);
		upsert preferenceObjList; 
	}
	
	public static void saveUserPreferenceForSPAction(List<CSM_User_Preferences__c> preferenceObjList) {
		List<String> fieldListForCRUD = new List<String>{CSM_Constants.OBJ_A_NAME, CSM_Constants.OBJ_UP_SP_ACTION_FILTER, CSM_Constants.OBJ_UP_User, CSM_Constants.OBJ_UP_SP_ACTION_GRID_COLUMNS};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldListForCRUD, CSM_Constants.DML_OPERATION_UPSERT);
		
		upsert preferenceObjList;
	}
	
	public static void saveUserPreferenceColumnsFilter(List<CSM_User_Preferences__c> preferenceObjList) {
		CSM_User_Preferences__c latestUserPref = getCSMGridAndFilterUserPreferences(UserInfo.getUserId());
        preferenceObjList[0].CSM_Success_Plan_Actions_Filter__c = latestUserPref.CSM_Success_Plan_Actions_Filter__c;
        List<String> fieldListForCRUD = new List<String>{CSM_Constants.OBJ_A_NAME, CSM_Constants.OBJ_UP_SP_ACTIVITY_GRID_COLUMNS, CSM_Constants.OBJ_UP_User, CSM_Constants.OBJ_UP_Hide_Overview_Charts};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_UP, fieldListForCRUD, CSM_Constants.DML_OPERATION_UPSERT);
		upsert preferenceObjList; 
	}
*/	
}