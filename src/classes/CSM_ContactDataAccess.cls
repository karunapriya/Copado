/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		09.03.2014
 * @description	CSM_ContactDataAccess class used to access contact information
 */
public with sharing class CSM_ContactDataAccess {
	
	/** 
 	 * @description	gets the contact information
 	 * @return List<Contact>
 	 */
	public static List<Contact> populateContactInformation(String accountId)
	{
		List<Contact> tmpList = new List<Contact>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_CONTACT_FIRSTNAME, CSM_Constants.OBJ_CONTACT_CSM_RELATED,
			CSM_Constants.OBJ_CONTACT_LASTNAME, CSM_Constants.OBJ_CONTACT_TITLE, CSM_Constants.OBJ_CONTACT_PHONE};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_CONTACT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
			tmpList = [select id, name, firstname, lastname, title, phone, csm_related__c
							from Contact 
							where accountId = :accountId 
							order by CSM_related__c desc, 
							firstName asc
							limit 10];
		
    	return tmpList;
	}
	
	public static List<Contact> getContactInformation(List<Id> accountIdsLst)
	{
		List<Contact> tmpList = new List<Contact>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_CONTACT_FIRSTNAME, CSM_Constants.OBJ_CONTACT_CSM_RELATED,
			CSM_Constants.OBJ_CONTACT_LASTNAME, CSM_Constants.OBJ_CONTACT_TITLE, CSM_Constants.OBJ_CONTACT_PHONE};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_CONTACT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
			tmpList = [select id, name, firstname, Contact.AccountId, lastname, title, phone, csm_related__c
							from Contact 
							where accountId in :accountIdsLst 
							order by CSM_related__c desc, 
							firstName asc
							limit 50];
    	return tmpList;
	}
	
	/** 
 	 * @description	sets list of contacts to the csm_related field with true
 	 * @return boolean
 	 */
	public static boolean relateContact(List<String> contactIdList) 
	{
		List<Contact> contactList = New List<Contact>();
		
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_CONTACT_FIRSTNAME, CSM_Constants.OBJ_CONTACT_CSM_RELATED,
		CSM_Constants.OBJ_CONTACT_LASTNAME, CSM_Constants.OBJ_CONTACT_TITLE, CSM_Constants.OBJ_CONTACT_PHONE};
	
    	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_CONTACT, fcFieldList, CSM_Constants.DML_OPERATION_UPDATE);
    	
    	//If user has access to fields, query the Success Plan Phase
    	
    		contactList = [select id, csm_related__c from Contact where id in :contactIdList limit 50];
    		for(Contact p : contactList)
    		{
    			p.csm_related__c = true;
    		}
    		update contactList;
    		return true;
	}
	
	/** 
 	 * @description	sets the list of contacts to csm_related of false
 	 * @return boolean
 	 */
	public static boolean unrelateContact(List<String> contactIdList) 
	{
		List<Contact> contactList = New List<Contact>();
		
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_CONTACT_FIRSTNAME, CSM_Constants.OBJ_CONTACT_CSM_RELATED,
		CSM_Constants.OBJ_CONTACT_LASTNAME, CSM_Constants.OBJ_CONTACT_TITLE, CSM_Constants.OBJ_CONTACT_PHONE};
	List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_CONTACT,CSM_Constants.DML_OPERATION_UPDATE, fcFieldList);
    	
    	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_CONTACT, fcFieldList, CSM_Constants.DML_OPERATION_UPDATE);
    	
    	//If user has access to fields, query the Success Plan Phase
    	
    		contactList = [select id, csm_related__c from Contact where id in :contactIdList limit 50];
    		for(Contact p : contactList)
    		{
    			p.csm_related__c = false;
    		}
    		update contactList;
    		return true;
    	
	}
	
	/**
      * @description : This method returns list of contact associated with the Account.
    */
	public static List<SObject> getContactListByAccountFromQueryStr(String queryString, Set<String> accId) {
		List<String> fcFieldList = new List<String>{REN_Constants.FLD_ID};
    	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_CONTACT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<SObject> contactList = new List <SObject>();
		if(queryString != null){
			queryString += ' where AccountId in :accId Limit 1000 ';
			contactList = Database.query(queryString);
		}
		return contactList;
	}
	
	public static List<Contact> getContactList() {
		List<String> fcFieldList = new List<String>{REN_Constants.FLD_ID};
    	CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_CONTACT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		return [Select id from Contact where Email!= null Limit 1];
	}
	
	public static List<Contact> getContactListByAccount(Id accId) {
		List<String> fcFieldList = new List<String>{'Id','Name'};
    	CSM_Util.checkCRUD_FLS('Contact', fcFieldList, 'Read');
		return [select Id,name from contact where AccountId =:accId limit 500];
	}
	public static List<SObject> getContactsBySOSL(CHL_GridInputWrapper inputWrapper)
	{
		List <sObject> contactList = new List<sObject>();
		String queryString = '';
		String fieldList = CHL_Util.getQueryStringFromFieldSet(CSM_Util.getNamespace()+CHL_Constants.CONTACT_DETAILS_FIELDSET_NAME, CHL_Constants.OBJ_CONTACT);
   		fieldList = fieldList.removeStartIgnoreCase('select ');
   		fieldList = fieldList.removeEndIgnoreCase(' from Contact');
   		system.debug('fieldList AFTER Remove '+fieldList);
   		Integer queryLimit = inputWrapper.lm == 5 ? 5 : 2000;
   		queryString = 'FIND\''+ inputWrapper.q +'*\' IN All Fields Returning Contact ('+fieldList+' ORDER BY LastName Asc) Limit '+queryLimit;
		List<List<SObject>>searchList = search.query(queryString);
		system.debug('searchList::'+searchList);
		if(searchList != null && searchList.size()>0){
			contactList.addAll(searchList[0]);
		}
		return contactList;
	}
	
	public static List<sObject> searchContactByWhereClause(String searchStr1, String whereCondition){
		List<String> contactFieldList = new List<String>{'Id','Name'};
        CSM_Util.checkCRUD_FLS('Contact', contactFieldList, CSM_Constants.DML_OPERATION_READ);
        String queryString = 'FIND\''+ searchStr1 +'*\' IN Name Fields Returning Contact (Id,Name '+whereCondition+' ORDER BY Name Asc) Limit 2000';
    	List<List<SObject>>searchList = search.query(queryString);
    	List<sObject> conList = new List<sObject>();
    	if(searchList != null && searchList.size()>0){
            conList.addAll(searchList[0]);
        }
        return conList;
	}
	
	public static List<Contact> contactExactSearch(String email){
		List<String> contactFieldList = new List<String>{'Id','Name', 'AccountId', 'Phone', 'Fax', 'MobilePhone', 'Email'};
		//String accountId = contactObj.AccountId, name = contactObj.Name, phone = contactObj.Phone, fax = contactObj.Fax, mobilePhone = contactObj.mobilePhone, email = contactObj.eMail;
		
        CSM_Util.checkCRUD_FLS('Contact', contactFieldList, CSM_Constants.DML_OPERATION_READ);
        String queryString = 'SELECT AccountId, Name, Phone, Fax, MobilePhone, Email, FirstName FROM Contact where Email = :eMail' ;
        List<Contact>searchList = Database.query(queryString);
        return searchList;
	}
	
	/**
    * @description : This method returns list of contact associated with the Opportunity.Added as a part of US2018.
    */
	public static List<OpportunityContactRole> getContactFromOpp(Set<ID> oppId) {
		List<String> fcFieldList = new List<String>{REN_Constants.FLD_ID, 'ContactId'};
    	CSM_Util.checkCRUD_FLS('OpportunityContactRole', fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
		String queryString = 'SELECT ContactId, Contact.Name, Contact.REN_Prefered_Language_Code__c,Contact.Phone, Contact.Fax, Contact.MobilePhone, Contact.Email, Contact.LastName,Contact.FirstName,IsPrimary,OpportunityId,Role, Contact.MailingStreet, Contact.MailingState, Contact.MailingPostalCode, Contact.MailingCountry, Contact.MailingCity FROM OpportunityContactRole where OpportunityId in :oppId and IsPrimary = true limit 1';
		List<OpportunityContactRole> contactList = Database.query(queryString);
	    System.debug('\n\n @@ check contact list :: ' + contactList);
		return contactList;
	}
	
	/**
    * @description : This method returns list of contacts by Id
    */
	public static List<Contact> getContactsById(Set<Id> ContactIdSet) {
		String solnExtnNamespace = CSM_Util.nameSpacePrefixSolnExtn;
		
		List<String> contactFieldList = new List<String>{'Id','Name', 'AccountId', 'Phone', 'Fax', 'MobilePhone', 'Email', 'HasOptedOutOfEmail'};
    	
		String queryString = 'SELECT AccountId, Name, Phone, Fax, MobilePhone, Email, FirstName, LastName, HasOptedOutOfEmail, REN_Prefered_Language_Code__c';
		String whereClause = ' FROM Contact where Id IN :ContactIdSet limit 10000';
		
		if(CSM_AccessController.hasField('Contact', solnExtnNamespace + 'System_User_Reference__c')){
			queryString += ', ' + solnExtnNamespace + 'System_User_Reference__c ';
			contactFieldList.add(solnExtnNamespace + 'System_User_Reference__c');
		}
		
		CSM_Util.checkCRUD_FLS('Contact', contactFieldList, CSM_Constants.DML_OPERATION_READ);		
		queryString += whereClause;
		
		List<Contact> contactList = Database.query(queryString);
	    System.debug('\n\n @@ check contact list :: ' + contactList);
		return contactList;
	}
		
	public static void insertContact(List<Contact> contactList) {
		List<String> contactFieldList = new List<String>{'Id', 'AccountId', 'Phone', 'Fax', 'MobilePhone', 'Email'};
    	CSM_Util.checkCRUD_FLS('Contact', contactFieldList, CSM_Constants.DML_OPERATION_INSERT);
		insert contactList;
	}
	
	public static List<Contact> getPartnerContact(set<Id> contactIdSet){
        String queryString='SELECT Id,AccountId FROM Contact WHERE  Id IN:contactIdSet AND Account.isPartner=true limit 10000';        
        List<Contact> conlist=Database.query(queryString);
        return conlist; 
    }
    
    public static void updateContact(List<Contact> contactList, List<String> contactFieldList) {
    	CSM_Util.checkCRUD_FLS('Contact', contactFieldList, CSM_Constants.DML_OPERATION_UPDATE);
		update contactList;
	}
		
}