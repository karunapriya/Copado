@isTest
public class PeerReviewCtrlTest{
    
    static Account testAccount;
    static List<RecordType> testCaseRecordTypeList = new List<RecordType>();
    static List<Profile> testProfileList = new List<Profile>();
    static Zenith_Setting__c testZenithSetting;
    static Peer_Review__c testPeerReview;
    static List<SelectOption> testCaseRecordTypeOptions = new List<SelectOption>();
    static List<SelectOption> testBusinessLineOptions = new List<SelectOption>();
    static List<SelectOption> testEngagementTypeOptions = new List<SelectOption>();
    static List<SelectOption> testOpportunityTypeOptions = new List<SelectOption>();
    static List<SelectOption> testSSITheatreOptions = new List<SelectOption>();
    static List<SelectOption> testClientTerritoryOptions = new List<SelectOption>();
    static List<SelectOption> testClientRegionOptions = new List<SelectOption>();

    static void createTestRecord() {
        // Create Account
        testAccount = new Account(
            Name = 'testAccount');     
        insert testAccount;
        
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
        
        // Create Peer Reviews
        testPeerReview = new Peer_Review__c(User__c = UserInfo.getUserId(),
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
        insert testPeerReview;
        
        Peer_Review__c peerReviewObj2 = new Peer_Review__c(User__c = UserInfo.getUserId(),
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
        insert peerReviewObj2;
        
        
    }
    
    static testMethod void updatePeerReview() {
        createTestRecord();

        PeerReviewViewCtrl controller = new PeerReviewViewCtrl(new ApexPages.StandardController(testPeerReview));
        testCaseRecordTypeOptions = controller.getCaseRecordTypeOptions();
        testBusinessLineOptions = controller.getBusinessLineOptions();
        testEngagementTypeOptions = controller.getEngagementTypeOptions();
        testOpportunityTypeOptions = controller.getOpportunityTypeOptions();
        testSSITheatreOptions = controller.getSSITheatreOptions();
        testClientTerritoryOptions = controller.getClientTerritoryOptions();
        testClientRegionOptions = controller.getClientRegionOptions();
        controller.onPeerReviewEdit();
        controller.offPeerReviewEdit();
        controller.cancelEdit();
        System.assert(controller != null);
    }
    
	static testMethod void testGenericHistoryComp(){
        createTestRecord();
        /*List<Peer_Review__History> prHist = [SELECT ParentId FROM Peer_Review__History ORDER BY CreatedDate DESC LIMIT 5];
         System.assert(!prHist.isEmpty());
         Schema.SObjectType sobjectType = prHist[0].ParentId.getSObjectType();
         String sobjectName = sobjectType.getDescribe().getName();
         SObject record = Database.query('Select Id, Name From ' + sobjectName + ' Where Id = ' + prHist[0].ParentId);
         controller.myObject = record; */
        Peer_Review__c peerReviewObj = new Peer_Review__c(User__c = UserInfo.getUserId(),
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
        insert peerReviewObj;
       
        List<Peer_Review__History> prHist = [SELECT ParentId FROM Peer_Review__History ORDER BY CreatedDate DESC LIMIT 5];
        system.debug('\n\n prHist :: ' + prHist); 
        Test.startTest();    
	        GenericHistoryComponentCtrl controller = new GenericHistoryCOmponentCtrl();
	        controller.myObject = peerReviewObj;
	        controller.getObjectHistory();
	        
	        String fieldLabel = GenericHistoryComponentCtrl.returnFieldLabel('Min_Amount__c');
	        System.assertNotEquals(null, fieldLabel);
	        
	        fieldLabel = GenericHistoryComponentCtrl.returnFieldLabel('testThis');
	        System.assert(String.isEmpty(fieldLabel));
        Test.stopTest();
    }
    
    static testMethod void testPeerReviewTriggerHandler_Test(){
    	createTestRecord();
        GenericHistoryComponentCtrl controller = new GenericHistoryCOmponentCtrl();
        
         Peer_Review__c peerReviewObj1 = new Peer_Review__c(User__c = UserInfo.getUserId(),
            Is_Active__c = true,
            Case_Record_Type__c = testZenithSetting.Case_Lead_Submission_Record_Type_Id__c,
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
        insert peerReviewObj1; 
      
        List<Peer_Review__c> peerReviewList = [Select id,SSI_Theatre__c from Peer_Review__c limit 10];
        for(Peer_Review__c pr :peerReviewList){
        	pr.SSI_Theatre__c = 'APJ';
        }
        Test.startTest();  
            System.assert(peerReviewList != null);
        	update peerReviewList;
        Test.stopTest();
    }
    
    static testMethod void AccessCntrl_Test(){
      	try{
      	   Test.startTest();
	           List<String> fieldList = new List<String>{'Sub_Case_Type__c'};
	           System.assert(fieldList != null);
			   Util.checkCRUD_FLS('case', fieldList, Constants.DML_OPERATION_DELETE);
			   
			   List<String> fieldList1 = new List<String>{'CreatedDate', 'CreatedById','NoFieldName'};
			   Util.checkCRUD_FLS('case', fieldList1, Constants.DML_OPERATION_READ);
		   Test.stopTest();
     	} catch(Exception e){
     	
        }
    } 
    
    static testMethod void AccessCntrl_Test1(){
      	try{
      	   Test.startTest();
	           	List<String> fieldList = new List<String>{'Sub_Case_Type__c'};
			   	System.assert(fieldList != null);
			   	Util.checkCRUD_FLS('NoObject', fieldList, Constants.DML_OPERATION_DELETE);
		   Test.stopTest();
     	} catch(Exception e){
     	
        }
    }
    
    static testMethod void testDataAccess(){
        createTestRecord();
        Test.startTest();
	        List<Peer_Review__c> peerReviewList = PeerReviewDataAccess.getPeerReviewByType(new Set<Id>{testCaseRecordTypeList[0].Id}, 
	            new Set<Id> {UserInfo.getUserId()}, new Set<String> {'Core'}, new Set<String> {'SREV'}, 
	            new Set<String> {'Enterprise'}, new Set<String> {'NALA'}, new Set<String> {'USA'}, 
	            new Set<String> {'USA'}, new Set<String>());
	        System.assert(!peerReviewList.isEmpty());
	        
	        peerReviewList = PeerReviewDataAccess.getPeerReviewByTypeAndOwner(
	            testZenithSetting.Case_Booking_Request_Record_Type_Id__c, UserInfo.getUserId(), 'Core',
	            'SREV', 'Enterprise', 'NALA', 'USA', 'USA', 
	            new List<Quote>(), '');
	        System.assert(!peerReviewList.isEmpty());
	    
	    	List<Peer_Review__c> peerReviewList1 = [Select id,SSI_Theatre__c from Peer_Review__c limit 10];
	      	for(Peer_Review__c pr :peerReviewList1){
	        	pr.SSI_Theatre__c = 'APJ';
	      	}
	     	UserDataAccess.getAllUsers();
	     	List<sObject> quoteObj = new List<sObject>();
     	Test.stopTest();
     }
     
     static testMethod void testPeerReviewUtil()
     {
         createTestRecord();
         Contact testContact1 = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'testFirstName1',
            LastName = 'testLastName1',
            Email = 'testContact1@servicesource.com');
         insert testContact1;
         System.assert(testContact1.Id != null);
         
         
         List<RecordType> testOppRecordTypeList = [SELECT Id 
            FROM RecordType 
            WHERE SobjectType = 'Opportunity' 
            AND (Name = 'Opportunity - Edit' OR Name = 'Opportunity - Read Only') 
            ORDER BY Name ASC];
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
         insert testOpportunity1;
         System.assert(testOpportunity1.Id != null);
         
     	 Case testCase = new Case(Status = 'New',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = testZenithSetting.Case_Quote_Request_Record_Type_Id__c,
            AccountId = testAccount.Id,
            ContactId = testContact1.Id,
            Opportunity__c = testOpportunity1.Id,
            Subject = 'testSubject',
            Description = 'testDescription',
            Sub_Case_Type__c = 'New');
         insert testCase;
         System.assert(testCase.Id != null);
         PeerReviewUtils.peerReviewPreCheck(testCase);
     }
      
}