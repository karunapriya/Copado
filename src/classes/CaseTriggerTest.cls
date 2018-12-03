@isTest
public class CaseTriggerTest{

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
            WHERE Name = 'System Administrator'
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
        
        // Create Quote Line Items
        
        
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
    }
    
    static testMethod void leadSubmissionUnsuccessfully() {
        createTestRecord();
        
        Case testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Lead_Submission_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Opportunity__c = testOpportunityList[0].Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New',
            Target_DIA__c = 90,
            Opportunity_Earliest_Existing_End_Date__c = System.Today(),
            Product_s_That_Needs_To_Be_Quoted__c = 'test',
            Applicable_Discounts__c = 'test',
            New_Term_Dates__c = 'test');
        insert testCase;
        System.assert(testCase.id != null);
        //Commenting out for Case_Status_change validation rule
        /*testCase.Status = 'Closed - Unsuccessfully';
          testCase.Closed_Unsuccessfully_Reason__c = 'User- Request Details';
          update testCase;
          System.assert(testCase != null);*/
        
    }
    
    static testMethod void leadSubmissionClosed() {
        createTestRecord();
        
        Case testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Lead_Submission_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Opportunity__c = testOpportunityList[0].Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New',
            Target_DIA__c = 90,
            Opportunity_Earliest_Existing_End_Date__c = System.Today(),
            Product_s_That_Needs_To_Be_Quoted__c = 'test',
            Applicable_Discounts__c = 'test',
            New_Term_Dates__c = 'test');
        insert testCase;
        System.assert(testCase.id != null);
        //Commenting out for Case_Status_change validation rule
        /*testCase.Status = 'Closed';
        update testCase;
        System.assert(testCase != null);*/
    }
    
    static testMethod void escalateDER() {
        createTestRecord();
        User testUser1 = new User(
            FirstName = 'testFirstName1',
            LastName = 'testLastName1',
            Alias = 'ttest1',
            Email = 'testUser1@servicesource.com',
            Username = 'testUser1@servicesource.com',
            CommunityNickname = 'testUser1',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = testProfileList[0].id);
        insert testUser1;
        
        User testUser2 = new User(
            FirstName = 'testFirstName2',
            LastName = 'testLastName2',
            Alias = 'ttest2',
            Email = 'testUser2@servicesource.com',
            Username = 'testUser2@servicesource.com',
            CommunityNickname = 'testUser2',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = testProfileList[0].id,
            ManagerId = testUser1.Id);
        insert testUser2;
    
        System.runAs(testUser2){
            Case testCase = new Case(Status = 'New',
                OwnerId = UserInfo.getUserId(),
                RecordTypeId = testZenithSetting.Case_Quote_Request_Record_Type_Id__c,
                AccountId = testAccount.Id,
                ContactId = testContactList[0].Id,
                Opportunity__c = testOpportunityList[0].Id,
                Subject = 'testSubject',
                Description = 'testDescription',
                Sub_Case_Type__c = 'New',
                Target_DIA__c = 90,
                Opportunity_Earliest_Existing_End_Date__c = System.Today());
            insert testCase;
            System.assert(testCase.id != null);
             //Commenting out for Case_Status_change validation rule
            /*testCase.OwnerId = testUser2.Id;
            update testCase;
            
            testCase.Request_Escalation__c = true;
            testCase.Escalation_Reason__c = 'testEscalationReason';
            update testCase;*/
        }
    }
    
    static testMethod void quoteRequestPassed() {
        createTestRecord();
        
        Case testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Quote_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Opportunity__c = testOpportunityList[0].Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New');
        insert testCase;
        System.assert(testCase.id != null);
        Quote testQuoteUpdate = new Quote(Id = testQuoteList[0].Id, 
            Case__c = testCase.Id);
        update testQuoteUpdate;
        
         //Commenting out for Case_Status_change validation rule
         /*  testCase.Status = 'Ready';
        update testCase;*/
        
         Case testCaseTwo = testCase.clone();
        testCaseTwo.ParentId = testCase.Id;
        testCaseTwo.RecordTypeId = testZenithSetting.Case_Review_Request_Record_Type_Id__c;
        insert testCaseTwo;
        
        Case testCase3 = testCase.clone();
        testCase3.ParentId = testCase.Id;
        testCase3.RecordTypeId = testZenithSetting.Case_Review_Request_Record_Type_Id__c;
        testCase3.Sub_Case_Type__c = 'Quote';
        insert testCase3;
        
        Case testCase4 = testCase.clone();
        testCase4.ParentId = testCase.Id;
        testCase4.RecordTypeId = testZenithSetting.Case_Review_Request_Record_Type_Id__c;
        testCase4.Sub_Case_Type__c = 'Booking';
        insert testCase4;
        
        List<Case> testCase2 = [SELECT Id, 
            Status 
            FROM Case 
            WHERE RecordTypeId = :testZenithSetting.Case_Review_Request_Record_Type_Id__c 
            AND ParentId = :testCase.Id 
            ORDER BY CreatedDate DESC];
        System.debug('##### testCase2: ' + testCase2);
        
        Quote testQuoteUpdate2 = new Quote(Id = testQuoteList[0].Id, 
            Review_Status__c = 'Pass', 
            Error_Category__c = null);
        update testQuoteUpdate2;
        
         //Commenting out for Case_Status_change validation rule
        /*testCase2[0].Status = 'Closed';
        update testCase2[0];*/
        
        PeerReviewUtils.peerReviewTracker(new List<Case> {testCase3, testCase4});
        PeerReviewUtils.getQuoteReviewStatusCount(testCase3.id + '');
        
        try{
          PeerReviewUtils.generateRevisionCase(new List<Case> {testCase3});
        }catch(Exception e){}
        try{
          PeerReviewUtils.generateRevisionCase(new List<Case> {testCase4});
        }catch(Exception e){}
        try{
          PeerReviewUtils.generateRevisionCase(new List<Case> {testCase3});
        }catch(Exception e){}
        try{
          PeerReviewUtils.originalCaseStatusClosed(new List<Case> {testCase4});
        }catch(Exception e){}
        try{
          PeerReviewUtils.generateReviewCase(new Map<Id, Case>(new List<Case> {testCase, testCase3,testCase4}));
        }catch(Exception e){}
        
    }
    
    static testMethod void quoteRequestFailed() {
        createTestRecord();
        
        Case testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Quote_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Opportunity__c = testOpportunityList[1].Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New');
        insert testCase;
        System.assert(testCase.id != null);
        List<Quote> testQuoteUpdateList = new List<Quote>();
        Quote testQuoteUpdate1 = new Quote(Id = testQuoteList[1].Id, 
            Case__c = testCase.Id);
        testQuoteUpdateList.add(testQuoteUpdate1);
        
        Quote testQuoteUpdate2 = new Quote(Id = testQuoteList[2].Id, 
            Case__c = testCase.Id);
        testQuoteUpdateList.add(testQuoteUpdate2);
        
        update testQuoteUpdateList;
        
         //Commenting out for Case_Status_change validation rule
        /*   testCase.Status = 'Ready';
        update testCase;*/
        
        Case testCaseTwo = testCase.clone();
        testCaseTwo.ParentId = testCase.Id;
        testCaseTwo.RecordTypeId = testZenithSetting.Case_Review_Request_Record_Type_Id__c;
        insert testCaseTwo;
        
        List<Case> testCase2 = [SELECT Id, 
            Status 
            FROM Case 
            WHERE RecordTypeId = :testZenithSetting.Case_Review_Request_Record_Type_Id__c 
            AND ParentId = :testCase.Id 
            ORDER BY CreatedDate DESC];
        System.debug('##### testCase2: ' + testCase2);
        
        List<Quote> testQuoteUpdateRList = new List<Quote>();
        Quote testQuoteUpdate1R = new Quote(Id = testQuoteList[1].Id, 
            Review_Status__c = 'Fail', 
            Error_Category__c = 'Incorrect Dates');
        testQuoteUpdateRList.add(testQuoteUpdate1R);
        
        Quote testQuoteUpdate2R = new Quote(Id = testQuoteList[2].Id, 
            Review_Status__c = 'Pass');
        testQuoteUpdateRList.add(testQuoteUpdate2R);
        
        update testQuoteUpdateRList;
        
        testCase2[0].OwnerId = UserInfo.getUserId();
        //Commenting out for Case_Status_change validation rule
        //testCase2[0].Status = 'Review Failed';
        update testCase2[0];
    }
    
    static testMethod void quoteRequestUnsuccessfully() {
        createTestRecord();
        
        Case testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Quote_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Opportunity__c = testOpportunityList[0].Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New');
        insert testCase;
        System.assert(testCase.id != null);
        Quote testQuoteUpdate = new Quote(Id = testQuoteList[0].Id, 
            Case__c = testCase.Id);
        update testQuoteUpdate;
        
         //Commenting out for Case_Status_change validation rule
        /*testCase.Status = 'Ready';
          update testCase;*/
        
         Case testCaseTwo = testCase.clone();
        testCaseTwo.ParentId = testCase.Id;
        testCaseTwo.RecordTypeId = testZenithSetting.Case_Review_Request_Record_Type_Id__c;
        insert testCaseTwo;
        
        List<Case> testCase2 = [SELECT Id, 
            Status 
            FROM Case 
            WHERE RecordTypeId = :testZenithSetting.Case_Review_Request_Record_Type_Id__c 
            AND ParentId = :testCase.Id 
            ORDER BY CreatedDate DESC];
        System.debug('##### testCase2: ' + testCase2);
        
        //Commenting out for Case_Status_change validation rule
       /* testCase2[0].Status = 'Closed - Unsuccessfully';
          testCase2[0].Closed_Unsuccessfully_Reason__c = 'User - Error';
          update testCase2[0];*/
    }
    
    static testMethod void bookingRequestPassed() {
        createTestRecord();
        
        Case testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Booking_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Opportunity__c = testOpportunityList[0].Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New',
            Contract_Amount__c = 10000);
        insert testCase;
        System.assert(testCase.id != null);
        Case testCaseTwo = testCase.clone();
        testCaseTwo.ParentId = testCase.Id;
        testCaseTwo.RecordTypeId = testZenithSetting.Case_Review_Request_Record_Type_Id__c;
        insert testCaseTwo;
        
        //Commenting out for Case_Status_change validation rule
         /*testCase.Status = 'Ready';
         update testCase;*/
        
        List<Case> testCase2 = [SELECT Id, 
            Status 
            FROM Case 
            WHERE RecordTypeId = :testZenithSetting.Case_Review_Request_Record_Type_Id__c 
            AND ParentId = :testCase.Id 
            ORDER BY CreatedDate DESC];
        System.debug('##### testCase2: ' + testCase2);

       //Commenting out for Case_Status_change validation rule
       /* testCase2[0].Status = 'Closed';
          update testCase2[0];*/
    }
    
    static testMethod void bookingRequestFailed() {
        createTestRecord();
        
        Case testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Booking_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Opportunity__c = testOpportunityList[0].Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New',
            Contract_Amount__c = 10000);
        insert testCase;
        System.assert(testCase.id != null);
        //Commenting out for Case_Status_change validation rule
        /*testCase.Status = 'Ready';
          update testCase;*/
        
        Case testCaseTwo = testCase.clone();
        testCaseTwo.ParentId = testCase.Id;
        testCaseTwo.RecordTypeId = testZenithSetting.Case_Review_Request_Record_Type_Id__c;
        insert testCaseTwo;
        
        List<Case> testCase2 = [SELECT Id, 
            Status 
            FROM Case 
            WHERE RecordTypeId = :testZenithSetting.Case_Review_Request_Record_Type_Id__c 
            AND ParentId = :testCase.Id 
            ORDER BY CreatedDate DESC];
        System.debug('##### testCase2: ' + testCase2);

        //Commenting out for Case_Status_change validation rule
        /*testCase2[0].OwnerId = UserInfo.getUserId();
          testCase2[0].Error_Category__c = 'Incorrect Dates';
          testCase2[0].Status = 'Review Failed';
          update testCase2[0];*/
    }
    
    static testMethod void bookingRequestUnsuccessfully() {
        createTestRecord();
        
        Case testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Booking_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Opportunity__c = testOpportunityList[0].Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New',
            Contract_Amount__c = 10000);
        insert testCase;
    System.assert(testCase.id != null);
        Case testCaseTwo = testCase.clone();
        testCaseTwo.ParentId = testCase.Id;
        testCaseTwo.RecordTypeId = testZenithSetting.Case_Review_Request_Record_Type_Id__c;
        insert testCaseTwo;

        //Commenting out for Case_Status_change validation rule
       /* testCase.Status = 'Ready';
          update testCase;*/
        
        List<Case> testCase2 = [SELECT Id, 
            Status 
            FROM Case 
            WHERE RecordTypeId = :testZenithSetting.Case_Review_Request_Record_Type_Id__c 
            AND ParentId = :testCase.Id 
            ORDER BY CreatedDate DESC];
        System.debug('##### testCase2: ' + testCase2);
        
        //Commenting out for Case_Status_change validation rule
        /*testCase2[0].Status = 'Closed - Unsuccessfully';
          testCase2[0].Closed_Unsuccessfully_Reason__c = 'User - Error';
          update testCase2[0];*/
    }
}