public with sharing class UserUtils{
    
    @future
    public static void userCreateContact(List<String> userInsertedList){
        Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
        List<Contact> contactToInsertList = new List<Contact>();
        List<String> contactFieldList = new List<String>{'AccountId','Email','FirstName','LastName','Title','Department','Phone','MobilePhone','Fax','MailingStreet', 'MailingCity',
        												  'MailingPostalCode','MailingState','MailingCountry',Util.solnExtnNameSpace + 'System_User_Reference__c'};
        List<User> userList =  UserDataAccess.getUsersByIds(new Set<String>(userInsertedList));
        for(User u :userList) 	
        {
            Contact c = new Contact(AccountId = ZS.Default_Account_ID__c,
                Email = u.Email,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Title = u.Title,
                Department = u.Department,
                Phone = u.Phone,
                MobilePhone = u.MobilePhone,
                Fax = u.Fax,
                MailingStreet = u.Street,
                MailingCity = u.City,
                MailingPostalCode = u.PostalCode,
                MailingState = u.State,
                MailingCountry = u.Country,
                System_User_Reference__c = u.Id);
            contactToInsertList.add(c);
        }
        
        if(contactToInsertList.size() > 0){
        	ContactDataAccess.insertContacts(contactToInsertList, contactFieldList);
        }
    }
    
    @future
    public static void userUpdateContact(List<String> userUpdatedList){
        Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
        Map<Id, User> userMap = UserDataAccess.getUserMapByIds(new Set<String>(userUpdatedList));
        List<Contact> contactList = ContactDataAccess.getContactsBySystemUserRefs(new Set<String>(userUpdatedList));
        List<String> contactFieldList = new List<String>{'AccountId','Email','FirstName','LastName','Title','Department','Phone','MobilePhone','Fax','MailingStreet', 'MailingCity',
        												  'MailingPostalCode','MailingState','MailingCountry'};
        if (!contactList.isEmpty())
        {
            for(Contact c : contactList){
              
	            c.AccountId = ZS.Default_Account_ID__c;
	            c.Email = userMap.get(c.System_User_Reference__c).Email;
	            c.FirstName = userMap.get(c.System_User_Reference__c).FirstName;
	            c.LastName = userMap.get(c.System_User_Reference__c).LastName;
	            c.Title = userMap.get(c.System_User_Reference__c).Title;
	            c.Department = userMap.get(c.System_User_Reference__c).Department;
	            c.Phone = userMap.get(c.System_User_Reference__c).Phone;
	            c.MobilePhone = userMap.get(c.System_User_Reference__c).MobilePhone;
	            c.Fax = userMap.get(c.System_User_Reference__c).Fax;
	            c.MailingStreet = userMap.get(c.System_User_Reference__c).Street;
	            c.MailingCity = userMap.get(c.System_User_Reference__c).City;
	            c.MailingPostalCode = userMap.get(c.System_User_Reference__c).PostalCode;
	            c.MailingState = userMap.get(c.System_User_Reference__c).State;
	            c.MailingCountry = userMap.get(c.System_User_Reference__c).Country;
            }       
	        ContactDataAccess.updateContacts(contactList, contactFieldList);
	    }
    }
}