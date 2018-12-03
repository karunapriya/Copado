@isTest
public class CaseQuoteCtrlTest{
    
    static Account testAccount;
    static Entitlement testEntitlement;
    static List<MilestoneType> testMilestoneTypeList = new List<MilestoneType>();
    static List<BusinessHours> testBusinessHours = new List<BusinessHours>();
    static List<RecordType> testOppRecordTypeList = new List<RecordType>();
    static List<RecordType> testCaseRecordTypeList = new List<RecordType>();
    static List<Profile> testProfileList = new List<Profile>();
    static Zenith_Setting__c testZenithSetting;
    static Zenith_Features__c testZenithFeatures;
    static List<Contact> testContactList = new List<Contact>();
    static List<Opportunity> testOpportunityList = new List<Opportunity>();
    static List<Quote> testQuoteList = new List<Quote>();
    static List<Peer_Review__c> testPeerReviewList = new List<Peer_Review__c>();
    static Case testCase;
    static List<Quote> quoteToReviewList = new List<Quote>();
    static List<Quote> quoteToCorrectList = new List<Quote>();

    static void createTestRecord() {
        // Create Account
        testAccount = new Account(
            Name = 'testAccount');     
        insert testAccount;
        
        // Create Entitlement
        testEntitlement = new Entitlement(
            Name = 'testEntitlementName',
            AccountId = testAccount.Id,
            StartDate = System.Today());
        insert testEntitlement;
        
        // Get MilestoneType
        testMilestoneTypeList = [SELECT Id FROM MilestoneType LIMIT 1];
        
        // Get BusinessHours
        testBusinessHours = [SELECT Id, TimeZoneSidKey FROM BusinessHours WHERE IsDefault = true];
        
        // Get Opportunity Record Types
        testOppRecordTypeList = [SELECT Id 
            FROM RecordType 
            WHERE SobjectType = 'Opportunity' 
            AND (Name = 'Opportunity - Edit' OR Name = 'Opportunity - Read Only') 
            ORDER BY Name ASC];
        
        // Get Case Record Types
        testCaseRecordTypeList = [SELECT Id 
            FROM RecordType 
            WHERE SobjectType = 'Case' 
            AND (Name = 'Booking Request' 
                OR Name = 'Data Processing Request' 
                OR Name = 'Data Update Request' 
                OR Name = 'Lead Submission' 
                OR Name = 'Quote Request' 
                OR Name = 'Reporting Request' 
                OR Name = 'Review Request'
            ) 
            ORDER BY Name ASC];
        System.debug('##### testCaseRecordTypeList: ' + testCaseRecordTypeList);
        
        // Get System Administrator Profile Id
        testProfileList = [SELECT Id 
            FROM Profile 
            WHERE Name = 'System Administrator' OR Name = 'Standard User' 
            ORDER BY Name DESC];
        
        // Create Default Zenith Setting
        testZenithSetting = new Zenith_Setting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Case_Booking_Request_Record_Type_Id__c = testCaseRecordTypeList[0].Id,
            Case_Data_Processing_Record_Type_Id__c = testCaseRecordTypeList[1].Id,
            Case_Data_Update_Record_Type_Id__c = testCaseRecordTypeList[2].Id,
            Case_Lead_Submission_Record_Type_Id__c = testCaseRecordTypeList[3].Id,
            Case_Quote_Request_Record_Type_Id__c = testCaseRecordTypeList[4].Id,
            Case_Reporting_Request_Record_Type_Id__c = testCaseRecordTypeList[5].Id,
            Case_Review_Request_Record_Type_Id__c = testCaseRecordTypeList[6].Id,
            Case_Opportunity_LKID__c = '',
            Default_Account_ID__c = testAccount.Id,
            Default_Account_Name__c = 'testAccount');
        insert testZenithSetting;
        
        // Create Default Zenith Features
        testZenithFeatures = new Zenith_Features__c(
            Auto_Close_Case__c = true,
            Auto_Submit_Case_Approval__c = true,
            Peer_Review__c = true);
        insert testZenithFeatures;

        // Create Contacts
        Contact testContact1 = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'testFirstName1',
            LastName = 'testLastName1',
            Email = 'testContact1@servicesource.com',
            System_User_Reference__c = UserInfo.getUserId());
        testContactList.add(testContact1);
        
        Contact testContact2 = new Contact(AccountId = testAccount.Id,
            FirstName = 'testFirstName2',
            LastName = 'testLastName2',
            Email = 'testContact2@servicesource.com',
            System_User_Reference__c = UserInfo.getUserId());
        testContactList.add(testContact2);
        
        insert testContactList;
        
        // Create Opportunities
        Opportunity testOpportunity1 = new Opportunity(
            Name = 'testOpportunity1',
            RecordTypeId = testOppRecordTypeList[0].Id,
            AccountId = testAccount.Id,
            CloseDate = System.Today(),
            StageName = 'Not Contacted',
            CurrencyIsoCode = 'USD',
            Amount = 15000,
            Business_Line__c = 'Core',
            Engagement_Type__c = 'SREV',
            Opportunity_Type__c = 'Enterprise',
            SSI_Theatre__c = 'NALA',
            Client_Region__c = 'USA',
            Client_Territory__c = 'USA',
            Country__c = 'United States');
        testOpportunityList.add(testOpportunity1);  
        
        Opportunity testOpportunity2 = new Opportunity(
            Name = 'testOpportunity2',
            RecordTypeId = testOppRecordTypeList[0].Id,
            AccountId = testAccount.Id,
            CloseDate = System.Today(),
            StageName = 'Not Contacted',
            CurrencyIsoCode = 'USD',
            Amount = 25000,
            Business_Line__c = 'Core',
            Engagement_Type__c = 'SREV',
            Opportunity_Type__c = 'Enterprise',
            SSI_Theatre__c = 'NALA',
            Client_Region__c = 'USA',
            Client_Territory__c = 'USA',
            Country__c = 'United States');
        testOpportunityList.add(testOpportunity2);
        
        insert testOpportunityList;
        
        // Create Quotes
        Quote testQuote1 = new Quote(Name = 'testQuote1',
            OpportunityId = testOpportunityList[0].Id,
            Quote_Type__c = 'Direct',
            Quote_Type_Year__c = '1');
        testQuoteList.add(testQuote1);
        
        Quote testQuote2 = new Quote(Name = 'testQuote2',
            OpportunityId = testOpportunityList[1].Id,
            Quote_Type__c = 'Direct',
            Quote_Type_Year__c = '2');
        testQuoteList.add(testQuote2);
        
        Quote testQuote3 = new Quote(Name = 'testQuote3',
            OpportunityId = testOpportunityList[1].Id,
            Quote_Type__c = 'Direct',
            Quote_Type_Year__c = '2');
        testQuoteList.add(testQuote3);
        
        insert testQuoteList;
        
        // Create Peer Reviews
        Peer_Review__c testPeerReview1 = new Peer_Review__c(User__c = UserInfo.getUserId(),
            Is_Active__c = true,
            Case_Record_Type__c = testZenithSetting.Case_Booking_Request_Record_Type_Id__c,
            Business_Line__c = 'Core',
            Engagement_Type__c = 'SREV',
            Opportunity_Type__c = 'Enterprise',
            SSI_Theatre__c = 'NALA',
            Client_Territory__c = 'USA',
            Client_Region__c = 'USA',
            CurrencyIsoCode ='USD',
            Min_Amount__c = null,
            Max_Amount__c = null,
            Review_Threshold__c = 1,
            Current_Counter__c = 0);
        testPeerReviewList.add(testPeerReview1);
        
        Peer_Review__c testPeerReview2 = new Peer_Review__c(User__c = UserInfo.getUserId(),
            Is_Active__c = true,
            Case_Record_Type__c = testZenithSetting.Case_Quote_Request_Record_Type_Id__c,
            Business_Line__c = 'Core',
            Engagement_Type__c = 'SREV',
            Opportunity_Type__c = 'Enterprise',
            SSI_Theatre__c = 'NALA',
            Client_Territory__c = 'USA',
            Client_Region__c = 'USA',
            CurrencyIsoCode ='USD',
            Min_Amount__c = null,
            Max_Amount__c = null,
            Review_Threshold__c = 1,
            Current_Counter__c = 0);
        testPeerReviewList.add(testPeerReview2);
        
        insert testPeerReviewList;
        
        testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Quote_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Opportunity__c = testOpportunityList[0].Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New');
        insert testCase;
    }
    
    static testMethod void updateQuoteReviewStatus() {
        createTestRecord();
        
        Quote testQuoteUpdate = new Quote(Id = testQuoteList[0].Id, 
            Case__c = testCase.Id);
        update testQuoteUpdate;
        //commenting out for validation rule Case_Status_change
        /*testCase.OwnerId = UserInfo.getUserId();
        testCase.Status = 'Ready';
        update testCase;
        System.assert(testCase.id != null);*/
        Case testCase2 = testCase.clone();
        testCase2.RecordTypeId = testZenithSetting.Case_Review_Request_Record_Type_Id__c ;
        testCase2.ParentId = testCase.Id;
        insert testCase2;
        System.assert(testCase2.id != null);
        System.debug('##### testCase: ' + testCase);
        
        List<Case> testCase2List = [SELECT Id,
            OwnerId,        
            Status,
            ParentId            
            FROM Case 
            WHERE RecordTypeId = :testZenithSetting.Case_Review_Request_Record_Type_Id__c 
            AND ParentId = :testCase.Id 
            ORDER BY CreatedDate DESC];
            
        System.debug('##### testCase2List: ' + testCase2List);

        CaseQuoteReviewCtrl controller = new CaseQuoteReviewCtrl(new ApexPages.StandardController(testCase2List[0]));
        controller.activateEditMode();
        controller.deactivateEditMode();
        controller.undoChanges();
        quoteToReviewList = controller.getRelatedQuote();
        quoteToReviewList[0].Review_Status__c = 'Fail';
        quoteToReviewList[0].Error_Category__c = 'Incorrect Dates';
        controller.saveChanges();
        
        Case testCase3 = new Case(RecordTypeId = testZenithSetting.Case_Quote_Request_Record_Type_Id__c,
            ParentId = testCase2List[0].Id,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Status = 'New',
            Priority = 'Normal',
            Origin = 'CRM User',
            Subject = 'testSubject',
            Description = 'Please revise the failed quote(s) from following case',
            Opportunity__c = testOpportunityList[0].Id,
            Original_Case_1P__c = testCase.Id,
            Sub_Case_Type__c = 'Correction',
            Original_Quoter_1P__c = UserInfo.getUserId(),
            Quote_Request_Type__c = 'Correction Request');
        insert testCase3;
        
        CaseQuoteToCorrectCtrl controller2 = new CaseQuoteToCorrectCtrl(new ApexPages.StandardController(testCase3));
        quoteToCorrectList = controller2.getQuoteToCorrect();
    }
    
    static testMethod void testCaseDataAccess() 
    {
    	createTestRecord();
    	set<boolean> setFlag = new set<boolean>();
        List<RecordType> recordTypeList = CaseDataAccess.getRecordTypeIdByCase(new Set<Id>{testCase.Id});
        List<Case> caseList = CaseDataAccess.getCasesByRecordTypeAndIds(new List<Case>{testCase});
        System.assert(!caseList.isEmpty());
        setFlag.add(false);
        caseList = CaseDataAccess.getCasesByRecordTypeAndIds(new Set<Id>{testCase.Id});
        caseList = CaseDataAccess.getCasesByOpportintyAndClosed(new Set<String>{testOpportunityList[0].Id,
            testOpportunityList[1].Id}, setFlag);
        System.assert(!caseList.isEmpty());
    }
}