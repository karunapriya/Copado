public with sharing class CSM_UserPreferencesUtil {
	
	/** Get user's prefrences. If not yet set, it returns CSM_User_Preferences__c object with default data.
	* @param ID userID
	* @return CSM_User_Preferences__c
	*/
	public static CSM_User_Preferences__c getUserPreferences(ID userID, String delimitedFields){
		CSM_User_Preferences__c preferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(userID, delimitedFields);
		if(preferenceObj != null){
			return preferenceObj;
		}
		return new CSM_User_Preferences__c(//Set default data
			CSM_Hide_Overview_Charts__c = false, 
			CSM_Hide_Inactive_Categories__c = true
		);
	}

	public static void saveUserPreference(List<CSM_User_Preferences__c> preferenceObjList, String delimitedFields){
		if (preferenceObjList!=null && !preferenceObjList.isEmpty()){
			preferenceObjList[0].name = UserInfo.getUserName();
			preferenceObjList[0].CSM_User__c = UserInfo.getUserId();
			delimitedFields+=','+CSM_Constants.OBJ_A_NAME+','+CSM_Constants.OBJ_UP_User;
			CSM_UserPreferencesDataAccess.saveUserPreference(preferenceObjList, delimitedFields);
		}
	}
	
	/** Save user's Preferences. It saves the Reports selected by the logged in user from Renewal Insights Page.
	* @param CSM_User_Preferences__c preferenceObj
	* @return void 
	*/
	/*
	public static void saveUserPreferenceReport(List<CSM_User_Preferences__c> preferenceObjList){
		if (preferenceObjList!=null && !preferenceObjList.isEmpty()){
			preferenceObjList[0].name = UserInfo.getUserName();
			preferenceObjList[0].CSM_User__c = UserInfo.getUserId();
			CSM_UserPreferencesDataAccess.saveUserPreferenceForReports(preferenceObjList);
		}
	}
	*/
	/*public static void getUserPreferenceReport(ID userID){
		CSM_User_Preferences__c preferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(userID);
		if(preferenceObj != null){
			return preferenceObj;
		}
		return new CSM_User_Preferences__c(//Set default data
			CSM_Hide_Overview_Charts__c = false, 
			CSM_Hide_Inactive_Categories__c = true
		);
	} */
}