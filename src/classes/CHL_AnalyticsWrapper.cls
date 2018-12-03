/**
 * Created Date     : Dec 2, 2016
 * Developed By     : Kavita, Comity Designs, Inc.
 *
 * Function         : @description - Segment dimensions initialization is done in this class.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj                  US1836              Dec 2, 2016         1.1                 @description
 *
 */
public with sharing class CHL_AnalyticsWrapper {

    public Traits traits { get; set; }

    public with Sharing class Traits
    {
        public string TENANT_ID { get; set; }
        public string TENANT_NAME { get; set; }
        public string ACCOUNT_ID { get; set; }
        public string ACCOUNT_NAME { get; set; }
        public string ACCOUNT_TYPE { get; set; }
        public string USER_ID { get; set; }
        public string USER_NAME { get; set; }
    }
    
    public CHL_AnalyticsWrapper(){
        traits = new Traits();
        traits.TENANT_ID = UserInfo.getOrganizationId();
        traits.TENANT_NAME = UserInfo.getOrganizationName();
        traits.USER_ID = UserInfo.getUserId();
        traits.USER_NAME = UserInfo.getUsername();
        
        List<User> listOfUser = CHL_Util.currentUserDetails;
        Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
            
        if(listOfUser!=null && listOfUser.size()>0 && acc <> null){
            traits.ACCOUNT_ID = acc.id;  //Contact.AccountId;
            traits.ACCOUNT_NAME = acc.Name;      //Account.Name;
            traits.ACCOUNT_TYPE = currentUserAccountType;      //Account.CHL_Partner_Account_Type__c;
        }
        
    }
}