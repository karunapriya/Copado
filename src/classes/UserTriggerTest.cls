@isTest
public class UserTriggerTest{
    
    static User testUser;
    static Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    /*static Zenith_Business_Rules__c ZBR = Zenith_Business_Rules__c.getOrgDefaults();
    
    static Account testAccount;
    static Entitlement testEntitlement;
    static List<MilestoneType> testMilestoneTypeList = new List<MilestoneType>();
    static List<RecordType> testRecordTypeList = new List<RecordType>();
    static Profile testProfile;
    static Zenith_Business_Rules__c zbrToInsert;
    
    static void createZBRRecord() {

        // Create Account
        testAccount = new Account(
            Name = 'testAccount');     
        insert testAccount;
        
        // Create Entitlement
        testEntitlement = new Entitlement(Name = 'testEntitlementName',
            AccountId = testAccount.Id,
            StartDate = System.Today());
        insert testEntitlement;
        
        // Create MilestoneType
        testMilestoneTypeList = [SELECT Id FROM MilestoneType LIMIT 1];
        
        // Get Case Record Types
        testRecordTypeList = [SELECT Id FROM RecordType WHERE SobjectType = 'Case'];
        
        // Get System Administrator Profile Id
        testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create Default Zenith Business Rule
        zbrToInsert = new Zenith_Business_Rules__c(SetupOwnerId = UserInfo.getOrganizationId(),
            Bulk_Generate_Sales_Target_Activation__c = false,
            Case_Entitlement_Id__c = testEntitlement.Id,
            Case_Quote_Request_Record_Type_Id__c = testRecordTypeList[0].Id,
            Case_Review_Request_Record_Type_Id__c = testRecordTypeList[0].Id,
            Days_for_Proactive_DER__c  = 120,
            Default_Account_ID__c = testAccount.Id,
            Default_Account_Name__c = 'testAccount',
            DIA__c = 90,
            Number_for_Proactive_DER__c = 3,
            My_Team_Sales_Target_Report_Id__c = 'abcabcabc',
            Peer_Review_Activation__c = false,
            SLA__c = 1,
            Standard_Milestone__c = testMilestoneTypeList[0].Id,
            System_Administrator__c = testProfile.Id,
            Zenith_Admin_Profile_Id__c = testProfile.Id,
            Zenith_Data_Services_Profile_Id__c = testProfile.Id,
            Zenith_Operation_Services_E_Profile_Id__c = testProfile.Id,
            Zenith_Operation_Services_Profile_Id__c = testProfile.Id,
            Zenith_Sales_Ops_Profile_Id__c = testProfile.Id,
            Zenith_Sales_Profile_Id__c = testProfile.Id);
        insert zbrToInsert;
    }*/
    
    static testMethod void createEditUser() {
        //createZBRRecord();
        
        testUser = new User(
            FirstName = 'testFirstName1',
            LastName = 'testLastName1',
            Alias = 'ttest1',
            Email = 'testUser1@servicesource.com',
            Username = 'testUser1@servicesource.com',
            CommunityNickname = 'testUser1',
            Title = 'testTitle',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = testProfile.Id);//zbrToInsert.Zenith_Admin_Profile_Id__c);
        insert testUser;
        System.assert(testUser.id != null);
        testUser.Title = 'testNewTitle';
        update testUser;
    }
}