public with sharing class AAA_CompilationIssue {

    public static List<User> currentUserDetails {
        get {
            if (currentUserDetails==null){
                currentUserDetails = [select Contact.AccountId, Account.Name, ContactId,AccountId from User where Id=:UserInfo.getUserId() Limit 1];                  
            }
            return currentUserDetails;
        }
        private set;
    }
}