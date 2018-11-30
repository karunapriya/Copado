/**
 * This class contains unit tests for validating the behavior of CHL_UserTriggerHelper classes
 * and triggers.
  */
@isTest
private class CHL_UserTriggerHelperTest {

@testSetup 
    static void setUpData() {
       
        Account ac = new Account(name ='Test Account') ;
        insert ac; 
        system.assert(ac.id != null);
               
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;  
        
        con = new Contact(LastName ='testCon1',AccountId = ac.Id);
        insert con;  
        
        insert new SS_License__c(Channel__c = true);
        
        List<String> portalGroupNameList = new List<String>();
        portalGroupNameList.add('Portal Group');
        List<Group>  publicGroupList = CHL_PublicGroupDataAccess.createGroup(portalGroupNameList);
        
        CHL_Portal_Group__c portalGrp = new CHL_Portal_Group__c();
        portalGrp.Name = 'Portal Group';
        portalGrp.CHL_Public_Group__c = publicGroupList[0].id;
        insert  portalGrp;             
        system.assert(portalGrp.id != null);    
        
        CHL_Portal_Group_Member__c portlGrpMmber = new CHL_Portal_Group_Member__c();
        portlGrpMmber.CHL_Partner_Account__c = ac.id;
        portlGrpMmber.CHL_Portal_Group__c = portalGrp.id;
        insert portlGrpMmber;
        
    }
    static testMethod void userTriggerTest() {
        Profile p = [select id from profile where name='System Administrator'];
        Id proID = p.Id;
        Contact con = [Select id from Contact where LastName ='testCon' Limit 1];
        Integer randomUserIndex = Math.round(Math.random()*4);
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = proID, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='tester_5@noemail.com_'+randomUserIndex);
       
        Test.startTest();
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            // This is done to avoid mixed dml exception error.
            System.runAs (thisUser) {
                insert user;
            }
        Test.stopTest();
        List<GroupMember> groupMemberList = [select id from GroupMember where  GroupId IN (Select id from Group where Name = 'Portal Group') ];
        system.assert(groupMemberList != null && !groupMemberList.isEmpty());
    }
    
    static testMethod void userTriggerTest_CaseShare() {
        Profile p = [select id from profile where name='System Administrator'];
        Id proID = p.Id;
        
        Integer randomUserIndex = Math.round(Math.random()*4);
        User user0 = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = proID, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='tester_2@noemail.com_'+randomUserIndex);
                
        User user1 = new User(alias = 'test1234', email='test1234@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = proID, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='tester0_3@noemail.com_'+randomUserIndex+'_20');
                
        Account ac = [select id, name from Account where name ='Test Account' limit 1];
        
        Test.startTest();
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs (thisUser) {
                CHL_Constants.USER_AFTER_TRIGGER = false;
                insert user0;
                system.assert(user0.id != null);
            }
            System.runAs(user0) {
                List<Case> caseList = new List<Case>();  
                caseList.add(new Case(accountid = ac.id, Subject = 'Test Case 1'));
                caseList.add(new Case(accountid = ac.id, Subject = 'Test Case 2'));
                insert caseList;
                system.assert(caseList != null);
            }
            System.runAs (thisUser) {
                List<Case> caseRec = [select id from Case limit 2];
                CHL_Constants.USER_AFTER_TRIGGER = true;
                insert user1;
                system.assert(user1.id != null);
            }
        Test.stopTest();
        
    }
}