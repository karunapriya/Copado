@isTest 
private class MilestoneTimeCalculatorTest {
    
    static Account testAccount;
    static Entitlement testEntitlement;
    static List<MilestoneType> testMilestoneTypeList = new List<MilestoneType>();
    static List<BusinessHours> testBusinessHours = new List<BusinessHours>();
    static List<RecordType> testOppRecordTypeList = new List<RecordType>();
    static List<RecordType> testCaseRecordTypeList = new List<RecordType>();
    static List<Profile> testProfileList = new List<Profile>();
    static Zenith_Setting__c testZenithSetting;
    static List<Contact> testContactList = new List<Contact>();
    static List<Opportunity> testOpportunityList = new List<Opportunity>();

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

        // Create Contacts
        Contact testContact1 = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'testFirstName1',
            LastName = 'testLastName1',
            Email = 'testContact1@servicesource.com');
        testContactList.add(testContact1);
        
        Contact testContact2 = new Contact(AccountId = testAccount.Id,
            FirstName = 'testFirstName2',
            LastName = 'testLastName2',
            Email = 'testContact2@servicesource.com');
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
            SSI_Theatre__c = 'NALA',
            Client_Region__c = 'USA',
            Client_Territory__c = 'USA',
            Country__c = 'United States');
        testOpportunityList.add(testOpportunity2);
        
        insert testOpportunityList;
    }

    static testMethod void testMilestoneTimeCalculator() {
        createTestRecord();
        
        Case testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Quote_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContactList[0].Id,
            Opportunity__c = testOpportunityList[0].Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Origin = 'Proactive',
            Quote_Request_Type__c = 'Renewal Request (New)',
            Target_DIA__c = 90,
            Opportunity_Earliest_Existing_End_Date__c = System.Today() + 100,
            BusinessHoursId = testBusinessHours[0].Id);
        insert testCase;
        
        MilestoneTimeCalculator calculator = new MilestoneTimeCalculator();
        Integer actualTriggerTime = calculator.calculateMilestoneTriggerTime(testCase.Id, testMilestoneTypeList[0].Id);
        System.assert(actualTriggerTime != null);
    }
}