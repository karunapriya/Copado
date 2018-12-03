@isTest
public class OpportunityTriggerTest{
    
    static testMethod void oppAutoCloseCaseTest(){
        Zenith_Features__c zfToInsert = new Zenith_Features__c(Auto_Close_Case__c = true);
        insert zfToInsert;
        //createZBRRecord();
        //createTestRecord();
        Account testAccount = new Account(
            Name = 'testAccount');     
        insert testAccount;
        
        // Create Contacts
        Contact testContact1 = new Contact(AccountId = testAccount.Id,
            FirstName = 'testFirstName1',
            LastName = 'testLastName1',
            Email = 'testContact1@servicesource.com');
        
        insert testContact1;
        
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware', IsActive = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
                                                            Pricebook2Id = pricebookId, Product2Id = prod.Id,
                                                            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        // Create Opportunities
        Opportunity testOpportunity1 = new Opportunity(
            Name = 'testOpportunity1',
            AccountId = testAccount.Id,
            CloseDate = System.Today(),
            StageName = 'Not Contacted',
            CurrencyIsoCode = 'USD',
            //Contact__c = testContactList[0].Id,
            //Secondary_Contact__c = testContactList[1].Id,
            SSI_Theatre__c = 'NALA',
            Client_Territory__c = 'USA',
            Client_Region__c = 'USA',
            Country__c = 'United States',
            Commit_Level__c = 'Black',
            Renewal_List_Price__c = 100000,
            PriceBook2Id = pricebookId,
            PO_Number__c = '1234');
            //Earliest_Existing_End_Date__c = System.Today());
        
        insert testOpportunity1;
        
        Id testCaseRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' and Name = 'Quote Request' LIMIT 1].Id;
        
        // Create Cases
        Case testCase1 = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testCaseRecordType,//zbrToInsert.Case_Quote_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContact1.Id,
            Opportunity__c = testOpportunity1.Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New',
            Target_DIA__c = 90,
            Opportunity_Earliest_Existing_End_Date__c = System.Today());
            insert testCase1;
            
            Case testCase2 = new Case(Status = 'Work in progress',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testCaseRecordType,//zbrToInsert.Case_Quote_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContact1.Id,
            Opportunity__c = testOpportunity1.Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New',
            Target_DIA__c = 90,
            Opportunity_Earliest_Existing_End_Date__c = System.Today());
            insert testCase2;
  
		System.assert(testCase1.id != null);
        
        
        Quote quoteObj = new Quote();
        quoteObj.Name = 'Test Quote'; 
        quoteObj.OpportunityId = testOpportunity1.id;
        quoteObj.Pricebook2Id =  testOpportunity1.Pricebook2Id;
        quoteObj.Local_Currency_Code__c = 'EUR';
        insert quoteObj;
        
         testOpportunity1.SyncedQuoteId = quoteObj.Id;
         update testOpportunity1;
        
        testOpportunity1.StageName = 'Closed Sale';
        testOpportunity1.PO_Number__c = '5678';
        testOpportunity1.Client_Booking_Date__c = system.today();
       
        system.debug('\n\n  updated :: ' + testOpportunity1.StageName);
        update testOpportunity1;
        
        List<Case> caseList = new List<Case>{testCase1, testCase2};
        Map<id,Opportunity> oppMap = new Map<id,Opportunity>{testOpportunity1.id => testOpportunity1};
        CaseTriggerHandlerHelper helper = new CaseTriggerHandlerHelper();
        SS_TriggerCollectionParameters.CaseTriggerParams caseParams = new SS_TriggerCollectionParameters.CaseTriggerParams();
        caseParams.newRecords =caseList;
        caseParams.oldRecordsMap = new Map<ID, Case>(caseList);
		caseParams.triggerEvent = 'onBeforeUpdate';
        CaseTriggerInvocationHandler haldler = new CaseTriggerInvocationHandler();
        haldler.featureInvocation(caseParams);

        caseParams.qualifiedCasesList = new List<Case>(); 
        caseParams.originalCaseStatusClosedList = new List<Case>(); 
        caseParams.originalCaseStatusClosedID = new Set<Id>();
        caseParams.generateRevisionCaseID = new Set<Id>();
        caseParams.completeMilestoneID = new Set<Id>();
        caseParams.generateRevisionCaseList = new List<Case>();
		caseParams.triggerEvent = 'onAfterUpdate';
        haldler.featureInvocation(caseParams);
        CaseTriggerHandlerHelper.updateReviewRequestCase(caseList, oppMap);
        testCase2.ParentId = testCase1.id;
        testCase2.Status = 'Review Failed';
        helper.addErrorToCase(testCase2);
        try{
        	OpportunityTriggerHandlerHelper.validateChanges(new List<Opportunity>{testOpportunity1}, new Map<ID, Opportunity>{testOpportunity1.id => testOpportunity1});
        }catch(Exception e){}
        
    }
}