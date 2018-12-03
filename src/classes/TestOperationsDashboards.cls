// Test method for all custom dashboad related classes
@isTest
public class TestOperationsDashboards{

    // Test method for ProactiveProdDashboardController class (covering both Overall & with dates dashboard)
    public static testMethod void testProactiveProdDashboardController(){
        Test.startTest();
        // Create an Account record
        Account acc = new Account(Name = 'testAccount');     
        insert acc;
        
        // Create Opportunities
        List<Opportunity> testOpportunityList = new List<Opportunity>();
        Opportunity testOpportunity1 = new Opportunity(
            Name = 'testOpportunity1',
            AccountId = acc.Id,
            CloseDate = System.Today(),
            StageName = 'Not Contacted',
            CurrencyIsoCode = 'USD',
            Business_Line__c = 'Core',
            SSI_Theatre__c = 'NALA',
            Client_Territory__c = 'USA',
            Client_Region__c = 'USA',
            Country__c = 'United States',
            Opportunity_Type__c = 'Enterprise',
            Commit_Level__c = 'Black',
            Renewal_List_Price__c = 100000,
            REN_Renewal_Target__c = 120000,
            REN_Earliest_Expiration_Date__c = System.Today());
        testOpportunityList.add(testOpportunity1);  
        
        // Add an opportunity with this quarter end date
        Opportunity testOpportunity2 = new Opportunity(
            Name = 'testOpportunity2',
            AccountId = acc.Id,
            CloseDate = System.Today(),
            StageName = 'Quote Completed',
            CurrencyIsoCode = 'USD',
            Business_Line__c = 'Core',
            SSI_Theatre__c = 'NALA',
            Client_Territory__c = 'USA',
            Client_Region__c = 'USA',
            Country__c = 'United States',
            Opportunity_Type__c = 'Enterprise',
            Commit_Level__c = 'Black',
            Target_DIA__c = 1,
            Renewal_List_Price__c = 100000,
            REN_Renewal_Target__c = 120000,
            REN_Earliest_Expiration_Date__c = System.Today());
        testOpportunityList.add(testOpportunity2);
        
        // Add an opportunity with next quarter end date
        Opportunity testOpportunity3 = new Opportunity(
            Name = 'testOpportunity3',
            AccountId = acc.Id,
            CloseDate = System.Today(),
            StageName = 'Quote Completed',
            CurrencyIsoCode = 'USD',
            Business_Line__c = 'Core',
            SSI_Theatre__c = 'NALA',
            Client_Territory__c = 'USA',
            Client_Region__c = 'USA',
            Country__c = 'United States',
            Opportunity_Type__c = 'Enterprise',
            Commit_Level__c = 'Black',
            Target_DIA__c = 1,
            Renewal_List_Price__c = 100000,
            REN_Renewal_Target__c = 120000,
            REN_Earliest_Expiration_Date__c = System.Today().addMonths(3),
            First_Quote_Completed_Date__c = System.Today().addMonths(2));
        testOpportunityList.add(testOpportunity3);
        
        insert testOpportunityList;
        
        // Create an instance of ProactiveProdDashboardController:
        ProactiveProdDashboardController proactiveOverall = new ProactiveProdDashboardController();
        // Invoke the withDates methods for with Date dashboard:
        proactiveOverall.initProactiveProdWithDates();
        
        // Invoke the overall init methods for overall dashboard:
        proactiveOverall.initProactiveProdOverall();
        
        // Invoke the remote action methods for proactive dashboard:
        proactiveOverall.q0MetricsPlaceholder = JSON.serialize(ProactiveProdDashboardController.fetchQ0DIAMetrics(proactiveOverall.filterConditions));
        proactiveOverall.q1MetricsPlaceholder = JSON.serialize(ProactiveProdDashboardController.fetchQ1DIAMetrics(proactiveOverall.filterConditions));
        proactiveOverall.q0DIASnapshotPlaceholder = JSON.serialize(ProactiveProdDashboardController.fetchQ0DIASnapshot(proactiveOverall.filterConditions));
        proactiveOverall.q1DIASnapshotPlaceholder = JSON.serialize(ProactiveProdDashboardController.fetchQ1DIASnapshot(proactiveOverall.filterConditions));
        proactiveOverall.quoteCompletedAverageDIAPlaceholder = JSON.serialize(ProactiveProdDashboardController.fetchQuoteCompletedAverageDIA(proactiveOverall.filterConditions));
        proactiveOverall.rollingDIAPlaceholder = JSON.serialize(ProactiveProdDashboardController.fetchRollingDIA(proactiveOverall.filterConditions));
        proactiveOverall.q0SalesPipelinePlaceholder = JSON.serialize(ProactiveProdDashboardController.fetchQ0SalesPipelines(proactiveOverall.filterConditions));
        proactiveOverall.q1SalesPipelinePlaceholder = JSON.serialize(ProactiveProdDashboardController.fetchQ1SalesPipelines(proactiveOverall.filterConditions));
        proactiveOverall.updateValues();
        
        // Invoke the report component controller
        testDBReportController(proactiveOverall,null,null);

        // Set the filters and simulate the applyFilter button:
        proactiveOverall.selectedTheatre = 'NALA';
        proactiveOverall.selectedBusinessLine = 'Core';
        proactiveOverall.selectedTerritory = 'USA';
        proactiveOverall.selectedRegion = 'USA';
        proactiveOverall.selectedOpportunityType = 'Enterprise';
        // Apply all fitlers without the dates
        proactiveOverall.filterData();
        // Pass wrong date formats for catching the exceptions
        proactiveOverall.startDate = String.valueOf(Date.today());
        proactiveOverall.filterData();
        proactiveOverall.endDate = String.valueOf(Date.today());
        proactiveOverall.filterData();
        // Set the date in proper format:
        String dt = Date.today().month() + '/'+Date.today().day() + '/'+Date.today().year();
        proactiveOverall.startDate = dt;
        
        // Get the error message for not filling both start and end date:
        proactiveOverall.filterData();
        proactiveOverall.endDate = dt;
        // Set the end date also and filter again:
        proactiveOverall.filterData();
        
        
        System.assert(proactiveOverall.parentController != null,'Parent controller not initialized');
        Test.stopTest();
    }    
    
    // Test method for ReactiveProdDashboardController class (covering both Overall & with dates dashboard)
    public static testMethod void testReactiveProdDashboardController(){
        Test.startTest();
        // Create an Account record
        Account acc = new Account(Name = 'testAccount');     
        insert acc;
        
        // Get the business hours Id 
        List<BusinessHours> lstBusinessHours =  [SELECT Id,Name FROM BusinessHours WHERE IsDefault=true];
        System.assert(lstBusinessHours != null && lstBusinessHours.size() > 0 , 'Business Hours Not defined');
        Id businessHourId = lstBusinessHours[0].Id;
        // Get the EntitilementProcess ID:
        List<SLAProcess> entitilementProcess = [SELECT Id FROM SlaProcess Limit 1];
        System.assert(entitilementProcess != null && entitilementProcess.size()  > 0, 'EntitilementProcess not defined');
        
        // Create Entitlement
        Entitlement testEntitlement = new Entitlement(Name = 'testEntitlementName',
                                                      AccountId = acc.Id,
                                                      StartDate = System.Today().addDays(-1), 
                                                      BusinessHoursId = businessHourId,
                                                      SLAProcessId = entitilementProcess[0].Id);
        insert testEntitlement;
        
        // Create a new contact record
        Contact con = new Contact(FirstName = 'testFirstName', LastName = 'testLastName', Email = 'testContact1@servicesource.com');
        insert con;
        
        // Create a Opportunity record
        Opportunity opp = new Opportunity(
            Name = 'testOpportunity',
            AccountId = acc.Id,
            CloseDate = System.Today(),
            StageName = 'Quote Completed',
            CurrencyIsoCode = 'USD',
            Business_Line__c = 'Core',
            SSI_Theatre__c = 'NALA',
            Client_Territory__c = 'USA',
            Client_Region__c = 'USA',
            Country__c = 'United States',
            Opportunity_Type__c = 'Enterprise',
            Commit_Level__c = 'Black',
            Target_DIA__c = 1,
            Renewal_List_Price__c = 100000,
            REN_Renewal_Target__c = 120000,
            REN_Earliest_Expiration_Date__c = System.Today().addMonths(3),
            First_Quote_Completed_Date__c = System.Today().addMonths(2));
        insert opp;
        
        // Run as the user with a owner office value (company name field on User)
        User usr = new User(Id = UserInfo.getUserId(), CompanyName = 'Denver', FirstName = 'TestFirst',LastName='TestLast');
        System.runAs(usr) {
            // Create Case records:
            List<Case> lstCases = new List<Case>();
            // Case of Quote request record type (with all subtype combintion)
            lstCases.add(newCase('Quote Request', 'New', acc.Id, con.Id,opp.Id,'High','New', 'CRM User',null));
            lstCases.add(newCase('Quote Request', 'New', acc.Id, con.Id,opp.Id,'Normal','New', 'CRM User',null));
            lstCases.add(newCase('Quote Request', 'New', acc.Id, con.Id,opp.Id,'Low','Correction', 'CRM User',null));
            // Case of Booking request record type (with all subtype combintion)
            lstCases.add(newCase('Booking Request', 'New', acc.Id, con.Id,opp.Id,'High','New', 'CRM User',null));
            lstCases.add(newCase('Booking Request', 'New', acc.Id, con.Id,opp.Id,'Normal','new', 'CRM User',null));
            lstCases.add(newCase('Booking Request', 'New', acc.Id, con.Id,opp.Id,'Low','Correction', 'CRM User',null));
            // Case of rest of the record types
            lstCases.add(newCase('Data Update Request', 'New', acc.Id, con.Id,opp.Id,'High',null, 'CRM User',null));
            lstCases.add(newCase('Data Processing Request', 'New', acc.Id, con.Id,opp.Id,'Low',null, 'CRM User',null));
            lstCases.add(newCase('Lead Submission', 'New', acc.Id, con.Id,opp.Id,'High',null, 'CRM User',null));
            lstCases.add(newCase('Reporting Request', 'New', acc.Id, con.Id,opp.Id,'Normal',null, 'CRM User',null));
            lstCases.add(newCase('Review Request', 'New', acc.Id, con.Id,opp.Id,'High',null, 'CRM User',null));
            lstCases.add(newCase('Review Request', 'New', acc.Id, con.Id,opp.Id,'Normal',null, 'CRM User',null));
             //	Create case for genrating milestone case
            lstCases.add(newCase('Booking Request','New',acc.Id, con.Id,opp.Id,'High',null, 'CRM User',null));
            // Insert the cases
            insert lstCases;
            
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            for(case c:lstCases){
            	 c.OwnerId = thisUser.Id;
            }
             
            update lstCases;
            
             lstCases = [SELECT Id, Status FROM Case WHERE status = 'New'];
             //	Update  case for genrating milestone case
             //commenting out updating status for Case_Status_change validation rule
			 /*List<Case> genrateMilestoneCase = new List<Case>();
			 for(Case objCase:lstCases){
				if(objCase.Status == 'New'){
					objCase.Status = 'Closed';
					objCase.Origin = 'Reactive';
					objCase.Priority = 'High';
					genrateMilestoneCase.add(objCase);
				}
			}
			update genrateMilestoneCase;
			*/
		
            // After the case records are in the Database, instanciate the Reactive Dashboard:
            ReactiveProdDashboardController reactiveDBController = new ReactiveProdDashboardController();
            system.debug(reactiveDBController.parentController);            
            system.assertEquals(false, reactiveDBController.singleUserReport, 'singleUserReport should be set to false on page load');
            system.assertNotEquals(null,reactiveDBController.getQueryCondition('QuoteRequest') , 'Query for quote request not populated correctly');

            reactiveDBController.grandSummaryPlaceholder = JSON.serialize(ReactiveProdDashboardController.fetchGrandSummaryData(reactiveDBController.filterConditions));
            reactiveDBController.updateValues();
                
            // Cover the ReactiveDashboardComponentController class (component for reactive DB):
            ReactiveDashboardComponentController reactiveComponent = new ReactiveDashboardComponentController();
            // Set the parent controller and dataset key for fetching data:
            reactiveComponent.dataSetKey = 'QuoteRequest';
            reactiveComponent.parentController = reactiveDBController;
            reactiveComponent.getInitAll();
             reactiveComponent.updateValues();
            reactiveComponent.allDataPlaceholder = JSON.serialize(ReactiveDashboardComponentController.fetchDashboardData(reactiveComponent.dashboardSpecificCondition));
           
            
            // Invoke the report component controller
            testDBReportController(null,null,reactiveDBController);
            
            // Set the filters at the page level and simulate the applyFilter button:
            reactiveDBController.selectedTheatre = 'NALA';
            reactiveDBController.selectedBusinessLine = 'Core';
            reactiveDBController.selectedTerritory = 'USA';
            reactiveDBController.selectedRegion = 'USA';
            reactiveDBController.selectedOpportunityType = 'Enterprise';
            // Apply all fitlers without the dates
            reactiveDBController.filterData();
            // Pass wrong date formats for catching the exceptions
            reactiveDBController.startDate = String.valueOf(Date.today());
            reactiveDBController.filterData();
            reactiveDBController.endDate = String.valueOf(Date.today());
            reactiveDBController.filterData();
            // Set the date in proper format:
            String dt = Date.today().month() + '/'+Date.today().day() + '/'+Date.today().year();
            reactiveDBController.startDate = dt;
            
            // Get the error message for not filling both start and end date:
            reactiveDBController.filterData();
            reactiveDBController.endDate = dt;
            // Set the user filter
            reactiveDBController.selectedUser = UserInfo.getUserId();
            // Set the end date also and filter again:
            reactiveDBController.filterData();
            system.assert(reactiveDBController.availableUsers != null, 'Users option not populated');
            // After user filter applied, the singleUser flag should be set to true:
            system.assertEquals(true, reactiveDBController.singleUserReport, 'singleUserReport should be set to true after filtering');
        }
        Test.stopTest();
    }
    
    
    // Test method for IndividualDashboardController class (covering both Overall & with dates dashboard)
    public static testMethod void testIndividualDashboardController(){
        Test.startTest();
        // Create an Account record
        Account acc = new Account(Name = 'testAccount');     
        insert acc;
        
        // Get the business hours Id 
        List<BusinessHours> lstBusinessHours =  [SELECT Id,Name FROM BusinessHours WHERE IsDefault=true];
        System.assert(lstBusinessHours != null && lstBusinessHours.size() > 0 , 'Business Hours Not defined');
        Id businessHourId = lstBusinessHours[0].Id;
        // Get the EntitilementProcess ID:
        List<SLAProcess> entitilementProcess = [SELECT Id FROM SlaProcess Limit 1];
        System.assert(entitilementProcess != null && entitilementProcess.size()  > 0, 'EntitilementProcess not defined');
        
        // Create an Entitlement record
        Entitlement testEntitlement = new Entitlement(Name = 'testEntitlementName',
                                                      AccountId = acc.Id,
                                                      StartDate = System.Today().addDays(-1), 
                                                      BusinessHoursId = businessHourId, 
                                                      SLAProcessId = entitilementProcess[0].Id);
        insert testEntitlement;
        
        String tName = Util.solnExtnNameSpace + 'Period__c';
        Id periodRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = :tName  and Name = 'SSI Period' LIMIT 1].Id;
        Period__c p = new Period__c(Name = '2016-Q1', Account__c = acc.Id,
                             Period_Start_Date__c = Date.newInstance(2016, 1, 1),
                             Period_End_Date__c = Date.newInstance(2016, 3, 31),
                             Quarter__c = 'Q1',
                             RecordTypeId = periodRecordTypeId);
        Database.insert(p);
        
        // Create a Ops target record:
        Operations_Target__c target = new Operations_Target__c(Period__c = p.id,
                                                                         Employee__c = Userinfo.getUserId() ,
                                                                         Case_Record_Type__c = 'Booking Request', 
                                                                         Case_Origin__c = 'Reactive');
        insert target;
        Operations_Target_Line_Item__c oTargetLineItem = new Operations_Target_Line_Item__c(
					Operations_Target__c = target.Id,
					Start_Date__c = Date.today(),
					End_Date__c = Date.today() + 90);
		insert oTargetLineItem;
		
        // Create a new contact record
        Contact con = new Contact(FirstName = 'testFirstName', LastName = 'testLastName', Email = 'testContact1@servicesource.com');
        insert con;
        
        // Create a Opportunity record
        Opportunity opp = new Opportunity(
            Name = 'testOpportunity',
            AccountId = acc.Id,
            CloseDate = System.Today(),
            StageName = 'Quote Completed',
            CurrencyIsoCode = 'USD',
            Business_Line__c = 'Core',
            SSI_Theatre__c = 'NALA',
            Client_Territory__c = 'USA',
            Client_Region__c = 'USA',
            Country__c = 'United States',
            Opportunity_Type__c = 'Enterprise',
            Commit_Level__c = 'Black',
            Target_DIA__c = 1,
            Renewal_List_Price__c = 100000,
            REN_Renewal_Target__c = 120000,
            REN_Earliest_Expiration_Date__c = System.Today().addMonths(3),
            First_Quote_Completed_Date__c = System.Today().addMonths(2));
        insert opp;
        // Run as the user with a owner office value (company name field on User)
        User usr = new User(Id = UserInfo.getUserId(), CompanyName = 'Denver', FirstName = 'TestFirst',LastName='TestLast');
        System.runAs(usr) {
            // Create Case records:
            List<Case> lstCases = new List<Case>();
            // Case of Quote request record type (with all subtype combintion)
            lstCases.add(newCase('Quote Request', 'New', acc.Id, con.Id,opp.Id,'High','New', 'CRM User',oTargetLineItem.Id));
            lstCases.add(newCase('Quote Request', 'New', acc.Id, con.Id,opp.Id,'Normal','new', 'CRM User',oTargetLineItem.Id));
            lstCases.add(newCase('Quote Request', 'New', acc.Id, con.Id,opp.Id,'Low','Correction', 'CRM User',oTargetLineItem.Id));
            // Case of Booking request record type (with all subtype combintion)
            lstCases.add(newCase('Booking Request', 'New', acc.Id, con.Id,opp.Id,'High','New', 'Proactive',oTargetLineItem.Id));
            lstCases.add(newCase('Booking Request', 'New', acc.Id, con.Id,opp.Id,'Normal','new', 'Proactive',oTargetLineItem.Id));
            lstCases.add(newCase('Booking Request', 'New', acc.Id, con.Id,opp.Id,'Low','Correction', 'Proactive',oTargetLineItem.Id));
            // Case of rest of the record type: Review Request
            lstCases.add(newCase('Review Request', 'New', acc.Id, con.Id,opp.Id,'High','Booking', 'CRM User',oTargetLineItem.Id));
           //	Create case for genrating milestone case
            lstCases.add(newCase('Booking Request','New',acc.Id, con.Id,opp.Id,'High','Booking', 'CRM User',oTargetLineItem.Id));
            
            // Insert the cases
            insert lstCases;
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            for(case c:lstCases){
            	 c.OwnerId = thisUser.Id;
            }
             
            update lstCases;
            
            lstCases = [SELECT Id, Status FROM Case WHERE Id IN :lstCases];
            // Update the Operations_Target__c field on cases (if not set earlier)
            List<Case> lstCasesToAddOperationsTarget = new List<Case>();
            for(Case caseRec: lstCases){
                if(caseRec.Status != 'Review Failed') {
                    caseRec.Operations_Target__c = oTargetLineItem.Id;
                    lstCasesToAddOperationsTarget.add(caseRec);
                }
            }
            update lstCasesToAddOperationsTarget;

		//	Update  case for genrating milestone case
		/*
		commenting out updating status for Case_Status_change validation rule
		List<Case> genrateMilestoneCase = new List<Case>();
		for(Case objCase:lstCases){
			if(objCase.Status == 'New'){
				objCase.Status = 'Closed';
				genrateMilestoneCase.add(objCase);
			}
		}
		
		update genrateMilestoneCase;
*/
            // Create quote records for each one case above
            /*List<Quote__c> lstQuote = new List<Quote__c>();
            for (Case caseRec : lstCases){
                Quote__c quoteRec = new Quote__c(
                    Opportunity__c = opp.Id,
                    Case__c = caseRec.Id,
                    Review_Status__c = 'Fail',
                    Error_Category__c = 'Incorrect SKU',
                    Quote_Type__c = 'Direct',
                    Quote_Type_Year__c = '1',
                    Earliest_New_Start_Date__c = Date.today(),
                    Latest_New_End_Date__c = Date.today(),
                    CurrencyIsoCode = 'USD',
                    Transaction_Amount__c = 1000);
                lstQuote.add(quoteRec);
            }
            insert lstQuote;*/

            
            // After the case & quote records are in the Database, instanciate the Reactive Dashboard:
            IndividualDashboardController individualDBController = new IndividualDashboardController();
            system.debug(individualDBController.parentController);
            system.assertEquals(false, individualDBController.singleUserReport, 'singleUserReport should be set to false on page load');
            system.assertNotEquals(null,individualDBController.getQueryCondition('ReactiveCases') , 'Query for Reactive Cases not populated correctly');
            
            // Invoke the remote methods for the individual dashboard, by passing the filter conditions
            individualDBController.grandSummaryPlaceholder = JSON.serialize(IndividualDashboardController.fetchGrandSummaryData(individualDBController.filterConditions));
            individualDBController.bookingReactivePlaceholder =  JSON.serialize(IndividualDashboardController.fetchBookingReactiveMetrics(individualDBController.filterConditions));
            individualDBController.quoteOverallPlaceholder = JSON.serialize(IndividualDashboardController.fetchQualityQuoteMetrics(individualDBController.quoteFilterConditions));
            individualDBController.updateValues();
            
            // Cover the ReactiveDashboardComponentController class (component for reactive DB):
            IndividualDBComponentController individualDBComponent = new IndividualDBComponentController();
            // Set the parent controller and dataset key for fetching data:
            individualDBComponent.dataSetKey = 'ReactiveCases';
            individualDBComponent.parentController = individualDBController;
            individualDBComponent.getInitAll();
            individualDBComponent.updateValues();
            individualDBComponent.allDataPlaceholder = JSON.serialize(IndividualDBComponentController.fetchDashboardData(individualDBComponent.dashboardSpecificCondition));
            // Invoke the report component controller
            testDBReportController(null,individualDBController,null);
           // Set the filters at the page level and simulate the applyFilter button:
            individualDBController.selectedTheatre = 'NALA';
            individualDBController.selectedBusinessLine = 'Core';
            individualDBController.selectedTerritory = 'USA';
            individualDBController.selectedRegion = 'USA';
            individualDBController.selectedOpportunityType = 'Enterprise';
            // Apply all fitlers without the dates
            individualDBController.filterData();
            // Pass wrong date formats for catching the exceptions
            individualDBController.startDate = String.valueOf(Date.today());
            individualDBController.filterData();
            individualDBController.endDate = String.valueOf(Date.today());
            individualDBController.filterData();
            // Set the date in proper format:
            String dt = Date.today().month() + '/'+Date.today().day() + '/'+Date.today().year();
            individualDBController.startDate = dt;
            
            // Get the error message for not filling both start and end date:
            individualDBController.filterData();
            individualDBController.endDate = dt;
            // Set the user filter
            individualDBController.selectedUser = UserInfo.getUserId();
            // Set the end date also and filter again:
            individualDBController.filterData();
            system.assert(individualDBController.availableUsers != null, 'Users option not populated');
            // After user filter applied, the singleUser flag should be set to true:
            system.assertEquals(true, individualDBController.singleUserReport, 'singleUserReport should be set to true after filtering');
        }
        Test.stopTest();
    }

    
    // Cover the DBReportComponentController class for reactive produciton DB:
    public static void testDBReportController(ProactiveProdDashboardController proactiveProdDBController, IndividualDashboardController individualDBController, ReactiveProdDashboardController reactiveProdDBController){
        // Insert a report URL in the custom setting:
        Zenith_Report_Urls__c repDetail = new Zenith_Report_Urls__c(Name = 'testReport', Report_Name__c = 'ReportName', Report_Unique_Name__c = 'Quality_Demo', Report_Filter__c = '?pv0=#BUSINESS#');
        insert repDetail;
        
        DBReportComponentController reportController = new DBReportComponentController();
        // Pass the Name of the custom setting to fetch the report details:
        reportController.dashboardElementName = 'testReport';
        // Set the parent controller variables:
        reportController.proactiveProdDBController = proactiveProdDBController;
        reportController.individualDBController = individualDBController;
        reportController.reactiveProdDBController = reactiveProdDBController;
        reportController.getInitAll();
        System.assert(reportController.repUrl != null, 'Report URL not prepared');        
        System.assert(reportController.repName != null, 'Report Name not fetched correctly');
    }
    
    // test method to cover DashboardsTabController class:
    public static testMethod void testDashboardsTabController() {
        
        List<Zenith_Dashboard_Tab_Elements__c> lstDBElements = new List<Zenith_Dashboard_Tab_Elements__c>();
        lstDBElements.add(new Zenith_Dashboard_Tab_Elements__c(Name = 'LeftElement', Display_Section__c= 'Left', Active__c = true,
                                                            Element_Type__c = 'Dashboard', Display_Name__c = 'DN', Value__c = 'Dash_Board',
                                                           Group_Name__c = 'LeftGroup', Group_Sequence__c = 1, Element_Sequence__c = 1.1));
        lstDBElements.add(new Zenith_Dashboard_Tab_Elements__c(Name = 'RightElement', Display_Section__c = 'Right',  Active__c = true,
                                                            Element_Type__c = 'Report', Display_Name__c = 'DN', Value__c = 'Report_Name',
                                                           Group_Name__c = 'LeftGroup', Group_Sequence__c = 1, Element_Sequence__c = 1.1));
        insert lstDBElements;
        // Instantiate the Dashboard landing tab controller:
        DashboardsTabController landingTabController = new DashboardsTabController();
        // Ensure the elements are populated correctly:
        System.assertNotEquals(null,landingTabController.leftColumnElements, 'Left Section was not populated correctly');
        System.assertNotEquals(null,landingTabController.rightColumnElements, 'Right Section was not populated correctly');
    }
    
    // Generic method to create a case from given parameters
    private static Case newCase(String recordType, String status, Id accId, Id contactId, Id oppId,String priority, String subCaseType, String origin, Id targetId) {
        Case newCase = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordType).getRecordTypeId(),
                                Status = status,
                                AccountId = accId,
                                ContactId = contactId,
                                Opportunity__c = oppId,
                                Priority = priority,
                                Sub_Case_Type__c = subCaseType,
                                Origin = origin,
                                Operations_Target__c = targetId,
                                Opportunity_Earliest_Existing_End_Date__c = Date.today(),
                                Target_DIA__c = 1,
                                OwnerId = UserInfo.getUserId(),
                                IsEscalated = false,
                                Subject = 'testSubject',
                                Description = 'testDescription',
                                Quote_Request_Type__c = 'Renewal Request (New)');
        // Set the revision related values here:
        if(subCaseType == 'Revision'){
            newCase.Revision_Caused_By__c = 'Client';
            newCase.Revision_Cause__c = 'Price';
        }
        return newCase;
    }
}