/**
 * Created Date		: May 3, 2017
 * Developed By		: Amit, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Amit					User Story				May 3, 2017			1.1					@description
 *
 */
public with sharing class CSM_UserDataAccess {

	public static void updateUser(List<String> fieldList, List<User> userList) { 
		
		CSM_Util.checkCRUD_FLS('User', fieldList, CSM_Constants.DML_OPERATION_UPDATE);
		update userList;   
	}
	
	/* US2730 : This method is used to get UserRole id based on User Id.*/
	public static SEt<Id> getUserRoleId(Set<Id> userIds){
		Set<Id> userRoleIdsSet = new Set<Id>();
		//List<String> userFieldsList = new List<String> {'Id','Name','UserRoleId' };
        //CSM_Util.checkCRUD_FLS('User', userFieldsList, CSM_Constants.DML_OPERATION_READ);
        List<User>  usersList = [select Id,Name,UserRoleId from User where Id IN :userIds];
        if(usersList != null && usersList.size()>0){       
	        for(User u : usersList){
	        	userRoleIdsSet.add(u.UserRoleId);
	        }
        }
        return userRoleIdsSet;		
	}
	
	public static List<SObject> getUserListForFocusCategories(){
		List<String> userFields = new List<String> {'Id','Name','UserType' };
        CSM_Util.checkCRUD_FLS('User', userFields, CSM_Constants.DML_OPERATION_READ);
        Set<String> userTypes = new Set<String>{'Guest', 'CsnOnly'};
        String  queryString = 'SELECT id, name FROM User WHERE isactive = true AND UserType NOT IN :userTypes';
        List<SObject> searchList = Database.query(queryString);
        return searchList;		
	}
	
	/* This method is used to get list of users with their license. */
	public static List<User> getUsersListForUserLicense(Set<Id> userIdsSet){
		List<String> userFieldsList = new List<String> {'Id','ProfileId','CHL_Persona__c'};
        CSM_Util.checkCRUD_FLS('User', userFieldsList, CSM_Constants.DML_OPERATION_READ);
        List<User> usersList = [select Id, Profile.UserLicense.Name,CHL_Persona__c from User where Id IN :userIdsSet];
		return usersList;
	}
	
	public static Map<Id,User> getUserDetailsById(Set<String> userIdSet, List<String> fieldList){
        CSM_Util.checkCRUD_FLS('User', fieldList, CSM_Constants.DML_OPERATION_READ);
        String soqlStr = String.join(fieldList, ',');
        soqlStr = 'SELECT ' + soqlStr + ' FROM User WHERE Id IN:userIdSet limit 1000'; 
        List<User> userList = Database.query(soqlStr); 
        Map<Id,User> idToUserMap = new Map<Id,User>(userList);
        return idToUserMap; 
    }
}