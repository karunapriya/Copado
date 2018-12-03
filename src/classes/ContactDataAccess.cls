/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         07/27/2016
 * @description  Contact Data Access class
 */
public with sharing class ContactDataAccess{
	/**
    * @description : This method returns a list of contacts for the given set  system user references
    * @param a set of user ids
    * @return a list of contacts
    */
	public static List<Contact>  getContactsBySystemUserRefs(Set<String> userIds)	{
	    List<String> contactFieldList = new List<String>{'AccountId', 'Email', 'FirstName', 'LastName', 'Title', 'Department', 'OwnerId',
	    												'Phone', 'MobilePhone','Fax', 'MailingStreet', 'MailingCity', 'MailingPostalCode', 
	    												'MailingState', 'MailingCountry',Util.solnExtnNameSpace + 'System_User_Reference__c'};
	    Util.checkCRUD_FLS('Contact', contactFieldList, Constants.DML_OPERATION_READ);
		
		return [SELECT Id, AccountId, Email, FirstName, LastName, Title, Department, Phone, MobilePhone,
            Fax, MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry, OwnerId,
            System_User_Reference__c FROM Contact WHERE System_User_Reference__c IN :userIds];
	}
	
	public static List<Contact>  getContactBySystemUserReference(Set<String> userIds)	{
	    List<String> contactFieldList = new List<String>{'FirstName', 'LastName',Util.solnExtnNameSpace + 'System_User_Reference__c'};
	    Util.checkCRUD_FLS('Contact', contactFieldList, Constants.DML_OPERATION_READ);
		
		return [SELECT Id, Name FROM Contact WHERE System_User_Reference__c IN :userIds Limit 1];
	}
	
	/**
    * @description : This method updates contacts
    * @param a list of contacts
    */
	public static void updateContacts(List<Contact> updatedContacts, List<String> contactFieldList){
		Util.checkCRUD_FLS('Contact', contactFieldList, Constants.DML_OPERATION_UPDATE);
		update updatedContacts;
	} 
	
	/**
    * @description : This method inserts contacts
    * @param a list of contacts
    */
	public static void insertContacts(List<Contact> insertContacts, List<String> contactFieldList){
		Util.checkCRUD_FLS('Contact', contactFieldList, Constants.DML_OPERATION_INSERT);
		insert insertContacts;
	} 
}