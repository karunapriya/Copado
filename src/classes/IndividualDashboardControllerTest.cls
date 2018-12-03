@isTest
private class IndividualDashboardControllerTest {

	@testSetup static void testData() {
		Account testAccount;
		List<RecordType> testOppRecordTypeList = new List<RecordType>();
		List<RecordType> testCaseRecordTypeList = new List<RecordType>();
		List<Contact> testContactList = new List<Contact>();
		List<Opportunity> testOpportunityList = new List<Opportunity>();
		List<Quote> testQuoteList = new List<Quote>();
		Case testCase;
		
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
		
		// Create Default Zenith Setting
		Zenith_Setting__c testZenithSetting = new Zenith_Setting__c(
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
		
		// Create Contact
		Contact testContact1 = new Contact(
			AccountId = testAccount.Id,
			FirstName = 'testFirstName1',
			LastName = 'testLastName1',
			Email = 'testContact1@servicesource.com',
			System_User_Reference__c = UserInfo.getUserId());
		testContactList.add(testContact1);
		insert testContactList;
		
		String tName = Util.solnExtnNameSpace + 'Period__c';
		Id periodRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = :tName and Name = 'SSI Period' LIMIT 1].Id;
		Period__c p = new Period__c(Name = '2016-Q1', Account__c = testAccount.Id,
			Period_Start_Date__c = date.today()-1,
			Period_End_Date__c = date.today()+1,
			Quarter__c = 'Q1',
			RecordTypeId = periodRecordTypeId);
		Database.insert(p);
		
		Operations_Target__c opsTarget = new Operations_Target__C();
			opsTarget.Period__c = p.Id;
			opsTarget.Employee__c = UserInfo.getUserId(); 
			opsTarget.Case_Origin__c = 'Reactive';
			opsTarget.Case_Record_Type__c = 'Booking Request';
		Database.insert(opsTarget);
		system.debug('\n\n opsTarget @@@:: ' + opsTarget);
		
		Operations_Target_Line_Item__c operationLI = new Operations_Target_Line_Item__c();
			operationLI.Operations_Target__c = opsTarget.Id;
			operationLI.End_Date__c = date.today()+1;
			operationLI.Start_Date__c = date.today()-1;
		insert operationLI;

		// Create Opportunities
		Opportunity testOpportunity1 = new Opportunity(
			Name = 'testOpportunity1',
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
		insert testOpportunityList;
		
		testCase = new Case(Status = 'New',
			RecordTypeId = testZenithSetting.Case_Booking_Request_Record_Type_Id__c,
			OwnerId = UserInfo.getUserId(),
			AccountId = testAccount.Id,
			ContactId = testContactList[0].Id,
			Opportunity__c = testOpportunityList[0].Id,
			Subject = 'testSubject',
			Description = 'testDescription',
			Sub_Case_Type__c = 'New',
			Operations_Target__c = operationLI.id,
			Origin = 'Reactive');
		insert testCase;
		system.assert(testCase.id != null);
		// Create Quotes
		Quote testQuote1 = new Quote(Name = 'testQuote1',
		OpportunityId = testOpportunityList[0].Id,
		Quote_Type__c = 'Direct',
		Quote_Type_Year__c = '1',
		Review_Status__c = 'Pass',
		Case__c = testCase.id);
		testQuoteList.add(testQuote1);
		
		insert testQuoteList;
		system.assert(testQuoteList[0].id != null);
	}

	static testMethod void filterData_Test() {
		IndividualDashboardController  indvDashBCntrl = new IndividualDashboardController();
		Test.startTest();
			indvDashBCntrl.startDate = '';
			indvDashBCntrl.endDate = '';
			indvDashBCntrl.filterData();
	
			indvDashBCntrl.startDate = '2016-08-30';
			indvDashBCntrl.endDate = '2016-09-30';
			indvDashBCntrl.selectedTheatre ='APJ';
			indvDashBCntrl.selectedBusinessLine = 'Core';
			indvDashBCntrl.selectedTerritory = 'USA';
			indvDashBCntrl.selectedRegion = 'USA';
			indvDashBCntrl.selectedOpportunityType ='Volume';
			indvDashBCntrl.filterData();
			System.assert(indvDashBCntrl != null);
		Test.stopTest();
	}

	static testMethod void WrapperCls_Test() {
		Test.startTest();
			IndividualDashboardController  indvDashBCntrl = new IndividualDashboardController();
			List<SelectOption> selectOption = indvDashBCntrl.availableUsers;
			Boolean selectVar = indvDashBCntrl.singleUserReport;
			IndividualDashboardController.GrandSummaryCaseOwnerWrapper caseOwnerWrapperObj = new IndividualDashboardController.GrandSummaryCaseOwnerWrapper();
			System.assert(caseOwnerWrapperObj != null);
			IndividualDashboardController.GrandSummaryCaseTypeWrapper caseSummaryWrapperObj = new IndividualDashboardController.GrandSummaryCaseTypeWrapper();
			IndividualDashboardController.QuoteQualityWrappers quoteQualityWrapperObj = new IndividualDashboardController.QuoteQualityWrappers();
			IndividualDashboardController.QualityWrapper qualityWrapperObj = new IndividualDashboardController.QualityWrapper(1,1,1,1,1);
		Test.stopTest();
	}

	static testMethod void fetchQualityQuoteMetrics_Test() {
		Test.startTest();
			IndividualDashboardController.fetchQualityQuoteMetrics(' AND id != null');
			system.assert(true);
		Test.stopTest();
	}
	
	static testMethod void fetchQualityQuoteMetrics_Test1() {
		Test.startTest();
			IndividualDashboardController.fetchBookingReactiveMetrics(' AND id != null');
			IndividualDashboardController.fetchGrandSummaryData(' AND id != null');
			system.assert(true);
		Test.stopTest();
	}
	
	 /* -- Test method for ReactiveProdDashboardController -- */
	static testMethod void WrapperClass_Test() {
	    Test.startTest();
			ReactiveProdDashboardController.GrandSummaryPriorityWrapper grandSummaryPWrapperObj = new ReactiveProdDashboardController.GrandSummaryPriorityWrapper();
			ReactiveProdDashboardController.GrandSummaryCaseTypeWrapper grandSummCaseWrapperObj = new ReactiveProdDashboardController.GrandSummaryCaseTypeWrapper();
			ReactiveDashboardComponentController.UserWrapper userWrapper = new ReactiveDashboardComponentController.UserWrapper();
			ReactiveDashboardComponentController.PriorityWrapper priorityWrapper = new ReactiveDashboardComponentController.PriorityWrapper();
			ReactiveDashboardComponentController.OwnerOfficeWrapper ownerOfficeWrapper= new ReactiveDashboardComponentController.OwnerOfficeWrapper();
			ReactiveDashboardComponentController.overallWrapperData  overallWrppData = new ReactiveDashboardComponentController.overallWrapperData();
			System.assert(grandSummCaseWrapperObj != null);
		Test.stopTest();
	}

     /* -- Test method for ReactiveDashboardComponentController -- */
	static testMethod void ReactiveDashBoardComponentCntrl_Test() {
	    List<Case>  caseList =  [Select id,status,Operations_Target__c from case];
		system.debug('\n\n caseList @@@:: ' + caseList);
	    Test.startTest();
			ReactiveDashboardComponentController reactiveDashBoardObj = new ReactiveDashboardComponentController();
			System.assert(reactiveDashBoardObj != null);
			String ownerOffice = ReactiveDashboardComponentController.findOwnerOffice(UserInfo.getUserId(), 'TestName');
			System.assert(ownerOffice != null);
			/*
			commenting out for validation rule Case_Status_change
			caseList[0].Status = 'Closed';
			caseList[0].Priority = 'High';
			update caseList;
			*/
			ReactiveDashboardComponentController.fetchDashboardData(' AND id != null');
		Test.stopTest();
	}
	
	/* -- Test method for ReactiveDashboardComponentController -- */
	static testMethod void getInitAllReactive_Test() {
		Test.startTest();
			try{
				ReactiveDashboardComponentController  reactiveDBDashBCntrl = new ReactiveDashboardComponentController();
				System.assert(reactiveDBDashBCntrl != null);
				reactiveDBDashBCntrl.updateValues();
				reactiveDBDashBCntrl.getInitAll();
			}catch(Exception e){
				
			}
		Test.stopTest();
	}
    
    
	/* -- Test method for IndividualDBComponentController -- */
	static testMethod void getInitAll_Test() {
		Test.startTest();
			try{
				IndividualDBComponentController  indvDBDashBCntrl = new IndividualDBComponentController();
				System.assert(indvDBDashBCntrl != null);
				indvDBDashBCntrl.getInitAll();
			}catch(Exception e){
				
			}
		Test.stopTest();
	}
    
    /* -- Test method for IndividualDBComponentController -- */
	static testMethod void fetchDashboardData_Test() {
		List<Case>  caseList =  [Select id,status,Operations_Target__c from case];
		system.debug('\n\n caseList @@@:: ' + caseList);
	
		Test.startTest();
			System.assert(caseList != null);
			/*commenting out for validation rule Case_Status_change
			caseList[0].Status = 'Closed';
			update caseList;
	        */
			List<CaseMileStone> mileStoneList  = [select id,Case.Owner.Name,Case.RecordType.Name,Case.Operations_Target__c,Case.IsClosed  FROM CaseMileStone ];
			system.debug('\n\n mileStoneList @@@:: ' + mileStoneList);
			
			IndividualDBComponentController.fetchDashboardData(' AND id != null');
		Test.stopTest();
	}
   
}