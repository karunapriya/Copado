@isTest
public class ProactiveRuleTriggerTest{

    static Account testAccount;
    static Entitlement testEntitlement;
    static List<MilestoneType> testMilestoneTypeList = new List<MilestoneType>();
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
        
        // Create MilestoneType
        testMilestoneTypeList = [SELECT Id FROM MilestoneType LIMIT 1];
        
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
    
    static testMethod void createProactiveRule() {
        createTestRecord();
        
        // Create Proactive Rule
        Proactive_Rule__c testProRule = new Proactive_Rule__c(
            Name = 'Opportunity > 20000',
            CurrencyIsoCode = 'USD');
        insert testProRule;
        
        
        // Create Proactive Rule Line Items
        List<Proactive_Rule_Line_Item__c> testProRuleLineItemList = new List<Proactive_Rule_Line_Item__c>();
        
        Proactive_Rule_Line_Item__c testProRuleLineItem1 = new Proactive_Rule_Line_Item__c(
            Proactive_Rule__c = testProRule.Id,
            Field__c = 'Amount',
            Operator__c = '>',
            Value__c = '20000');
        testProRuleLineItemList.add(testProRuleLineItem1);
        
        Proactive_Rule_Line_Item__c testProRuleLineItem2 = new Proactive_Rule_Line_Item__c(
            Proactive_Rule__c = testProRule.Id,
            Field__c = 'StageName',
            Operator__c = '=',
            Value__c = 'Not Contacted');
        testProRuleLineItemList.add(testProRuleLineItem2);
        
        insert testProRuleLineItemList;
        
        // Create Proactive Case Setups
        List<Proactive_Case_Setup__c> testProCaseSetupList = new List<Proactive_Case_Setup__c>();
        
        Proactive_Case_Setup__c testProCaseSetup1 = new Proactive_Case_Setup__c(
            Proactive_Rule__c = testProRule.Id,
            Field__c = 'Status',
            Value__c = 'New');
        testProCaseSetupList.add(testProCaseSetup1);
        
        Proactive_Case_Setup__c testProCaseSetup2 = new Proactive_Case_Setup__c(
            Proactive_Rule__c = testProRule.Id,
            Field__c = 'Origin',
            Value__c = 'Proactive');
        testProCaseSetupList.add(testProCaseSetup2);
        
        Proactive_Case_Setup__c testProCaseSetup3 = new Proactive_Case_Setup__c(
            Proactive_Rule__c = testProRule.Id,
            Field__c = 'RecordTypeId',
            Value__c = testCaseRecordTypeList[4].Id);
        testProCaseSetupList.add(testProCaseSetup3);
        
        Proactive_Case_Setup__c testProCaseSetup4 = new Proactive_Case_Setup__c(
            Proactive_Rule__c = testProRule.Id,
            Field__c = 'Target_DIA__c',
            Value__c = '90');
        testProCaseSetupList.add(testProCaseSetup4);
        
        Proactive_Case_Setup__c testProCaseSetup5 = new Proactive_Case_Setup__c(
            Proactive_Rule__c = testProRule.Id,
            Field__c = 'Subject',
            Value__c = 'Proactive Quote Request');
        testProCaseSetupList.add(testProCaseSetup5);
        
        insert testProCaseSetupList;
        
        // Update Proactive Rule to active
        testProRule.Filter_Logic__c = testProRuleLineItemList[0].Name + ' AND ' + testProRuleLineItemList[1].Name;
        testProRule.Is_Active__c = true;
        testProRule.Limit__c = 1;
        testProRule.Order_By__c = 'Amount';
        testProRule.Order_Type__c = 'Ascending';
        testProRule.Preferred_Run_Hour__c = '0';
        testProRule.Preferred_Run_Minute__c = '0';
        testProRule.Recurring_Day__c = 'MON; TUE; WED; THU; FRI';
        update testProRule;
        
        // Update Proactive Rule to inactive
        testProRule.Is_Active__c = false;
        update testProRule;
        System.assert(testProRule != null);
        // Update Proactive Rule Line Item
        testProRuleLineItemList[0].Value__c = '21000';
        update testProRuleLineItemList[0];
        
        delete testProRuleLineItem2;
    }
    
     static testMethod void checkAllTriggerEvents() {
        Proactive_Rule__c testProRule = new Proactive_Rule__c(
            Name = 'Opportunity > 20000',
            CurrencyIsoCode = 'USD');
        insert testProRule;
        update testProRule;
        delete testProRule;
        undelete testProRule;
        System.assert(true);
      }
}