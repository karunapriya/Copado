/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         07/29/2016
 * @description  User Data Access class
 */
public with sharing class UserDataAccess
{
	/**
    * @description : This method returns a list of users for the given set of user ids
    * @param a set of user ids
    * @return a list of users
    */
	public static List<User> getUsersByIds(Set<String> userIds)	
	{	
		 List<String> userFields = new List<String> {'Id', 'Email', 'FirstName', 'LastName', 'Title', 
	         'Department', 'Phone', 'MobilePhone', 'Fax', 'Street', 'City', 'PostalCode', 'State', 
	         'Country','Name' };
        
         Util.checkCRUD_FLS('User', userFields, Constants.DML_OPERATION_READ);
		
	    return [SELECT Id, 
	                   Email, 
	                   FirstName, 
	                   LastName, 
	                   Title, 
	                   Department, 
	                   Phone, 
	                   MobilePhone, 
	                   Fax, 
	                   Street, 
	                   City, 
	                   PostalCode, 
	                   State, 
	                   Country,
	                   Name 
	              FROM User 
	             WHERE Id IN :userIds];
	}
	
	/**
    * @description : This method returns a map of users for the given set of user ids
    * @param a set of user ids
    * @return a map of users
    */
    public static Map<Id, User> getUserMapByIds(Set<String> userIds)	
	{	
		 List<String> userFields = new List<String> {'Id', 'Email', 'FirstName', 'LastName', 'Title', 
	         'Department', 'Phone', 'MobilePhone', 'Fax', 'Street', 'City', 'PostalCode', 'State', 
	         'Country','Name' };
        
         Util.checkCRUD_FLS('User', userFields, Constants.DML_OPERATION_READ);
	    return new Map<Id, User>([SELECT Id, 
	                   Email, 
	                   FirstName, 
	                   LastName, 
	                   Title, 
	                   Department, 
	                   Phone, 
	                   MobilePhone, 
	                   Fax, 
	                   Street, 
	                   City, 
	                   PostalCode, 
	                   State, 
	                   Country,
	                   Name 
	              FROM User 
	             WHERE Id IN :userIds]);
	}
	
	/**
    * @description : This method returns a map of users for the given set of user ids, manager roles and user role name
    * @param a set of user ids
    * @param a set of manager roles
    * 
    * @return a map of users
    */
    public static Map<Id, User> getUserMapByIdsAndRoles(Set<String> userIds, Set<String> managerRoles,  String userRoleName)	
	{	
        List<String> userFields = new List<String> {'Id','Name','UserRoleId' };
        Util.checkCRUD_FLS('User', userFields, Constants.DML_OPERATION_READ);
        
        List<String> userRoleFields = new List<String> {'DeveloperName' };
        Util.checkCRUD_FLS('UserRole', userRoleFields, Constants.DML_OPERATION_READ);
        
	    String userQuery = 'SELECT Id, Name FROM User WHERE Id = \''+UserInfo.getUserRoleId()+'\' ';
        if(managerRoles.contains(userRoleName)){
            userQuery += ' OR (UserRoleId != null AND UserRole.DeveloperName IN :managerRoles) ';   
        }
        return new Map<Id, User>((List<User>)Database.Query(userQuery));
	}
	
	/**
    * @description : This method returns a map of user roles
    * @return a map of user roles
    */
	public static Map<Id,UserRole> getAllUserRoles()
	{
		List<String> userRoleFields = new List<String> {'DeveloperName', 'Id' };
        Util.checkCRUD_FLS('UserRole', userRoleFields, Constants.DML_OPERATION_READ);
		return new Map<Id,UserRole>([SELECT Id,DeveloperName FROM UserRole limit 5000]);
	}
	
	public static List<User> getAllUsers()
	{
		List<String> userFields = new List<String> {'CompanyName', 'Id' };
        Util.checkCRUD_FLS('User', userFields, Constants.DML_OPERATION_READ);
		return [SELECT ID,CompanyName FROM User limit 50000];
	}
}