public with sharing class Case_Load_Test {
    
    public static void  createCase() {
        
        List<Account> accountList = CSM_TestDataUtility.createAccount(250);
        List<Contact> conList = createContact(accountList);
        List<CSM_Account_Plan_Template__c> testTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        List<CSM_Account_Plan__c> acctPlanList = CSM_TestDataUtility.createAccountPlan(accountList, testTemplates[0].Id);
        List<Case> caseList = new List<Case>();
        for(Account acc : accountList){
            Case caseObj = new Case();
            caseObj .AccountId =acc.id;
            caseObj .Target_Date__c = System.now();
            caseObj .Status = 'New';
            caseObj .Sub_Case_Type__c = 'New';
            caseObj .ContactId = conList[0].id;
            caseList.add(caseObj );
        }
        
        insert caseList;
    }
    
    
    static  List<Contact> createContact(List<Account> accountList){
        List<Contact> conList = new  List<Contact>();
        for(Account acc : accountList){
            Contact con = new Contact();
            con.LastName = 'Contact 1';
            con.Email = 'MyContactNd@test.com';
            con.AccountId = acc.id;
            conList.add(con);
        }
       insert conList;
       return conList;
    }
    
    
}