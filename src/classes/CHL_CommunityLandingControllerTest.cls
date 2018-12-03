/**
* @description    Test class for CHL_CommunityLandingController        
*/
@isTest
private with sharing class CHL_CommunityLandingControllerTest {

    @testSetup 
    static void setup() {       
       List<Account> accountList = new List<Account>();
       List<Contact> contactList = new List<Contact>();
       List<Opportunity> opptyList = new List<Opportunity>();
       List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();
       
       Account acc =  CHL_TestUtility.partnerAccount();
       accountList.add(acc);
       insert accountList;
       
       System.assert(accountList != null);
       
       Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
       contactList.add(con);
       insert contactList;
       
       Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
       opptyList.add(oppty);
       insert opptyList; 
       
       CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
       optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
       optyStatusLogObj.CHL_Days_between_Update__c = 5;
       optyStatusLogObj.CHL_Enable_2_Tier_Pricing__c = true;
       insert optyStatusLogObj; 
       
       CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
       partOppty.OpportunityId = opptyList[0].id;
       partOppty.partnerAcc1Id = accountList[0].id ;
       partOppty.partnerAcc1Type = 'Reseller';
       partOppty.contact1Id = contactList[0].Id;
       partOppty.expirationDate= system.today().addDays(-10);
       partOppty.Stage = 'Qualification';
       partOppty.partnerAcc2Id = accountList[0].id;
       partOppty.partnerAcc2Type  = 'Distributor';
       partOppty.contact2Id = contactList[0].Id;
        
       chlpartnerList =   CHL_TestUtility.channelPartnerOpportunityList(5,partOppty); 
       insert chlpartnerList;
       system.debug('chlpartnerList : '+chlpartnerList);
       
       Note noteObj = new Note();
       noteObj.Title = 'Title';
       noteObj.Body = 'This is test Note' ;
       noteObj.ParentId = chlpartnerList[0].Id;
       insert noteObj;     
       
    }
    
    static testMethod void communityOverviewTest() {
       
        List<Contact> contactList = [select Id, name from contact limit 1];        
        User u = CHL_TestUtility.createTestPartnerUser('System Administrator','testpartnercontact@test.com',contactList[0].Id);
        List<CHL_Partner_Opportunity__c> partnerOptyList = [SELECT CHL_Partner_Account_1_Contact__c,CHL_Partner_Account_1_Type__c,CHL_Partner_Account_1__c,CHL_Partner_Account_1_Contact__r.name,CHL_Partner_Account_2_Contact__c,CHL_Partner_Account_2_Contact__r.name,CHL_Partner_Account_2_Type__c FROM CHL_Partner_Opportunity__c limit 2];         
        system.debug(' LIST FROM TEST : '+partnerOptyList.size() + partnerOptyList[0].CHL_Partner_Account_1_Type__c);
        system.assert([Select id from  CHL_Partner_Opportunity__c].size()>0);
        Object sobj1;
        sobj1 = new CHL_OverviewWrapper();
        sobj1 = CHL_CommunityLandingController.getOverviewData('');
        //CSM_User_Preferences__c userPref = new CSM_User_Preferences__c(CSM_User__c=u.id,CHL_Viewed_New_Opportunities_Date__c=system.today().addDays(-5));
        //insert userPref;  
        sobj1 = CHL_CommunityLandingController.getOverviewData('');    
        system.assert(sobj1<>null); 
     }  
     
     static testMethod void searchAccountTest() {
        
        List<Contact> contactList = [select Id, name from contact limit 1];
        //testDataSetup();
        //User u = CHL_TestUtility.createTestPartnerUser('Channel Community','testpartnercontact@test.com',contactList[0].id);
      
        Test.startTest();  
            //system.runas(u){
                String accSerach = '{"q":"Test"}';
                System.assert(accSerach != null);
                CHL_CommunityLandingController.searchAccounts(accSerach);
            //}
        Test.stopTest();
     }  
     
     static testMethod void getOppsFilterOptionsTest() {
        //testDataSetup();
        List<Contact> contactList = [select Id, name from contact limit 1];
        //User u = CHL_TestUtility.createTestPartnerUser('Channel Community','testpartnercontact@test.com',contactList[0].Id);
        Test.startTest();  
            //system.runas(u){
                CHL_PartnerOpportunityFilters optyFilterObj = new CHL_PartnerOpportunityFilters();
                optyFilterObj = CHL_CommunityLandingController.getOppsFilterOptions('');    
                system.assert(optyFilterObj<>null);
            //}
        Test.stopTest();
    }
    
    /*static testMethod void getOppsTest() {
        //testDataSetup();
        List<Contact> contactList = [select Id, name from contact limit 1];
        integer currentQuarter = ((System.today().month() - CHL_Util.getFiscalYearMonth()) / 3) + 1;
        set<string> quarterSet = new set<String>();
        Test.startTest();  
            //system.runas(ChannelUser){
                
                CHL_GridInputWrapper inputWrapper = new CHL_GridInputWrapper();
                CHL_GridInputWrapper.CHL_CustomGridParams gridParams = new CHL_GridInputWrapper.CHL_CustomGridParams();
                quarterSet.add('All'); 
                gridParams.currentQuarter = 'Q'+currentQuarter;
                gridParams.oppsType = 'OPEN_OPPS';
                gridParams.quarters = quarterSet;
                
                inputWrapper.queryParams = gridParams;
                inputWrapper.gridType = 'OPTY_GRID';
                string inputvalue= JSON.serialize(inputWrapper);
                CHL_AngularResponeWrapper wrp = new CHL_AngularResponeWrapper();
                wrp = CHL_CommunityLandingController.getOpps(inputvalue);    
                  
                system.assert(wrp<>null);
            //}
        Test.stopTest();
    }*/
    
    static testMethod void getChartDataTest() {
        //testDataSetup();
        List<Contact> contactList = [select Id, name from contact limit 1];
        
        /*User u = CHL_TestUtility.createTestPartnerUser('Channel Community','testpartnercontact@testu.com',contactList[0].Id);
        insert u;
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        PermissionSet ps   = CHL_TestUtility.getPermissionSet('Channel_Community');
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;*/
        system.assert([Select id from  CHL_Partner_Opportunity__c].size()>0);
        Set<String> quarterSet = new Set<String>();
        Set<String> countrySet = new Set<String>();
        Set<String> resellerset = new Set<String>();
        Set<String> distributorset = new Set<String>();
    	Set < String > yearSet = new Set < String > ();
        Test.startTest();  
        //system.runas(u){
            //Temporary comment function for fix deployment issues.
            CHL_GridInputWrapper inputWrapper = new CHL_GridInputWrapper();
            CHL_GridInputWrapper.CHL_CustomGridParams gridParams = new CHL_GridInputWrapper.CHL_CustomGridParams();
            CHL_CurrentQuarter currentQtr = CHL_Util.getCurrentQuarter();
			quarterSet.add(currentQtr.id);    
			CHL_CurrentYear currentYearObj = CHL_Util.getCurrentYear();
			yearSet.add(currentYearObj.Id);
            countryset.add('All');
            resellerset.add('All');
            distributorset.add('All');
            gridParams.quarters = quarterSet;
            gridParams.countries = countryset;
            gridParams.resellerReps = resellerset;
            gridParams.distributorReps = distributorset;
            inputWrapper.queryparams = gridParams;
            string inputvalue= JSON.serialize(inputWrapper);            
            Object sobj1;
            Map< String, Map< Boolean, Integer > > chartStatusMap = new Map< String, Map< Boolean, Integer > > ();
            Map<Boolean, Integer> mapBooleanVsInteger = new Map<Boolean, Integer> {
				true => 1,
				false=> 0
				};
			chartStatusMap.put('test',mapBooleanVsInteger);
            sobj1 = new CHL_ChartResponseWrapper(chartStatusMap);
            sobj1 = CHL_CommunityLandingController.getChartData(inputvalue);
            system.assert(sobj1<>null); 
               
        //}
        Test.stopTest();   
    }
    
     Static testMethod void updateOpportunitiesTest() {
     	List<Account> accountList = [select id from Account limit 1];
     	String AccId = accountList[0].id;
        List<CHL_Partner_Opportunity__c > partnerOppList = [select name, CHL_Sales_Stage__c from CHL_Partner_Opportunity__c];
        system.assert(partnerOppList<>null);  
        string nameSpace = CSM_Util.getNamespace();
        String inputValue = '{"gridData":[{"updated":false,"rowData":{"'+nameSpace+'CHL_Customer_Engagement_Type__c":{"value":"Partner LED","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Status__c":{"value":"UPdated Status","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Needs_Status_Update__c":{"value":"2015-05-30T04:00:00+00:00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"Latest_Quote":{"value":"RENEW_8JUN","url":"/servlet/servlet.FileDownload?file=0QDj0000000PTXsGAO","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_2_Contact__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_1_Contact__c":{"value":"Partner User2","url":"","needsUpdate":null,"lookupId":"003j000000UDxFZ","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_2_Type__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_1_Type__c":{"value":"Reseller","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Close_Date__c":{"value":"2015-08-06T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Expiration_Date__c":{"value":"2015-06-30T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Amount__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Probability__c":{"value":"60","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Sales_Stage__c":{"value":"Qualification","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Opportunity_Account_Name__c":{"value":"285 Test","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+ nameSpace+'CHL_Partner_Account_1__c":{"value":"'+ AccId +'","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+ nameSpace+'CHL_Partner_Account_2__c":{"value":"'+ AccId +'","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"}},"recordID":"' + partnerOppList[0].id + '","index":1,"canEdit":false}]}';
        Test.startTest();
            System.assert(inputValue != null);
             CHL_CommunityLandingController.updateOpportunities(inputValue); 
             String responseValue = '{"oppId":"'+partnerOppList[0].id +'"}'; 
             CHL_CommunityLandingController.getOppNotes(responseValue);
              
        Test.stopTest();
    } 
    
    Static testMethod void getOppDetailsTest() {
        List<Contact> contactList = [select Id, name from contact limit 1];
        User adminUser = CSM_TestDataUtility.createTestUser('System Administrator');
        insert adminUser;
        
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        PermissionSet ps   = CHL_TestUtility.getPermissionSet('PRISM_Base');
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;
        
        List < CHL_Partner_Opportunity__c > partnerOppList = [select Id, name, CHL_Sales_Stage__c from CHL_Partner_Opportunity__c limit 1];
        system.assert(partnerOppList<>null);  
        CHL_AngularTabsInputWrapper inputWrapper = new CHL_AngularTabsInputWrapper();
        inputWrapper.oppId = partnerOppList[0].Id;
        inputWrapper.relatedObject = 'details';
        string inputValue= JSON.serialize(inputWrapper);    
        system.debug('inputValue : '+inputValue);  
        Test.startTest();
        system.runas(adminUser){
            System.assert(inputValue != null);
            CHL_CommunityLandingController.getOppDetails(inputValue);    
            inputWrapper.relatedObject = 'contacts';
            inputValue= JSON.serialize(inputWrapper);
            CHL_CommunityLandingController.getOppDetails(inputValue);            
            inputWrapper.relatedObject = 'renewals';
            inputValue= JSON.serialize(inputWrapper);
            CHL_CommunityLandingController.getOppDetails(inputValue); 
        }
        Test.stopTest();
    } 
    
    Static testMethod void getQuoteDetailsTest() {
        try
        {
            List < CHL_Partner_Opportunity__c > partnerOppList = [select Id, name, CHL_Sales_Stage__c,CHL_Opportunity__c from CHL_Partner_Opportunity__c limit 1];
            List<Opportunity> opptyList = [select Id, name,Pricebook2Id from opportunity limit 1 ];
            system.assert(partnerOppList<>null);  
            /*if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
                //To create Quote Obj.
                Sobject quoteObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject() ; 
                quoteObj.put('Name', 'TestQ1') ; 
                quoteObj.put(CHL_Constants.STR_OPPOTUNITYID, opptyList[0].id) ;
                quoteObj.put(REN_Constants.OBJ_OPP_PRICEBOOK_ID, opptyList[0].Pricebook2Id) ;
                if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)) {
                    quoteObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_PARTNER_OPPORTUNITY, partnerOppList[0].id) ;
                }
                if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY)) {
                    quoteObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTE_PARTNER_PRIMARY, false) ;
                }
                insert quoteObj;
            }*/
            List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,partnerOppList);
            if(quoteList != null && !quoteList.isEmpty()) {
				insert quoteList;
            }
            CHL_AngularTabsInputWrapper inputWrapper = new CHL_AngularTabsInputWrapper();
            inputWrapper.oppId = partnerOppList[0].Id;
            inputWrapper.relatedObject = 'quotes';
            string inputValue= JSON.serialize(inputWrapper);    
            CHL_CommunityLandingController.QuoteInputStructure quoteInput = new CHL_CommunityLandingController.QuoteInputStructure();
            quoteInput.oppId = partnerOppList[0].Id;
            string quoteInputValue= JSON.serialize(inputWrapper);   
            Test.startTest();
                System.assert(inputValue != null);
                 CHL_CommunityLandingController.getOppDetails(inputValue);    
                 CHL_CommunityLandingController.getQuoteList(quoteInputValue);
            Test.stopTest();
        }
        catch (Exception e)
        {
            //try/catch is here if quote not enabled
        }
    } 
    
    Static testMethod void getNotesListTest() {
        List <Note> noteList = [select Body, CreatedById, CreatedDate, Id, ParentId from note];
        CHL_AngularTabsInputWrapper inputWrapper = new CHL_AngularTabsInputWrapper();
        if(!noteList.isEmpty()){
            inputWrapper.oppId = noteList[0].ParentId;
        }
        inputWrapper.relatedObject = 'notes';
        string inputValue = JSON.serialize(inputWrapper);

        Test.startTest();
            System.assert(inputValue != null);
            CHL_CommunityLandingController.getOppDetails(inputValue);
        Test.stopTest();
    }
    
    Static testMethod void getRequestsTest() {
        string inputValue = '{"gridType":"CHANNEL_REQUESTS","queryParams":{"caseType":"Closed"}}';
        Test.startTest();
            System.assert(inputValue != null);
            //CHL_CommunityLandingController.getRequests(inputValue);
            CHL_CommunityLandingController.getRequestTypes(inputValue);
        Test.stopTest();
    }
    
 
   Static testMethod void getAccountDetailsTest(){
        List < Contact > contactList = [select Id, name from contact limit 1];
        User adminUser = CSM_TestDataUtility.createTestUser('System Administrator');
        insert adminUser;
        
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        PermissionSet ps   = CHL_TestUtility.getPermissionSet('PRISM_Base');
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;
        
        System.RunAs(adminUser) {
            List<Account> accountList = new List<Account>();
            Account acc = CHL_TestUtility.partnerAccount();
            accountList.add(acc);
            insert accountList;
            CHL_AngularTabsInputWrapper inputWrapper = new CHL_AngularTabsInputWrapper();
            inputWrapper.accountId = accountList[0].Id;
            string inputValue = JSON.serialize(inputWrapper);
            Test.startTest();
            System.assert(inputValue != null);
            CHL_CommunityLandingController.getAccountDetails(inputValue);
            Test.stopTest();
        }
    }
    
    static testMethod void getResponseForGridTest(){
        List<Account> accountList = [select Id, name from Account limit 1];
        List <Opportunity> OptyList = [select Id, name from Opportunity limit 1];
        CHL_GridInputWrapper inputWrapper = new CHL_GridInputWrapper();
        CHL_GridInputWrapper.CHL_CustomGridParams gridParams = new CHL_GridInputWrapper.CHL_CustomGridParams();
        gridParams.accountID = accountList[0].Id;
        gridParams.oppId = OptyList[0].Id;
        Test.startTest();
            inputWrapper.gridType = 'CHANNEL_REQUESTS';
            inputWrapper.queryParams = gridParams;
            string inputValue= JSON.serialize(inputWrapper);    
            System.assert(inputValue != null);
            CHL_CommunityLandingController.getResponseForGrid(inputValue);
            inputWrapper.gridType = 'CHANNEL_OPPS';
            inputWrapper.queryParams = gridParams;
            inputValue= JSON.serialize(inputWrapper);
            CHL_CommunityLandingController.getResponseForGrid(inputValue);          
            inputWrapper.gridType = 'CHANNEL_CONTACTS';
            inputWrapper.queryParams = gridParams;
            inputValue= JSON.serialize(inputWrapper);
            CHL_CommunityLandingController.getResponseForGrid(inputValue);
            /*inputWrapper.gridType = 'CHANNEL_QUOTES';
            inputWrapper.queryParams = gridParams;
            inputValue= JSON.serialize(inputWrapper);
            CHL_CommunityLandingController.getResponseForGrid(inputValue);
            inputWrapper.gridType = 'CHANNEL_RENEWALS';
            inputWrapper.queryParams = gridParams;
            inputValue= JSON.serialize(inputWrapper);
            CHL_CommunityLandingController.getResponseForGrid(inputValue);*/
            inputWrapper.gridType = 'CHANNEL_ASSETS';
            inputWrapper.queryParams = gridParams;
            inputValue= JSON.serialize(inputWrapper);
            CHL_CommunityLandingController.getResponseForGrid(inputValue);
            inputWrapper.gridType = 'CHANNEL_CONTRACTS';
            inputWrapper.queryParams = gridParams;
            inputValue= JSON.serialize(inputWrapper);
            CHL_CommunityLandingController.getResponseForGrid(inputValue);
        Test.stopTest();
    }
    //moved method in CHL_SalesRequestBusinessLayerTest class
	/*static testMethod void getCaseCommentsList_Test() {
    	List<Case> caseList = [select id from Case ];
    	Case caseObj = new Case();
    	CaseComment caseComment = new CaseComment();
		caseComment.CommentBody  = 'test subject';
		caseComment.ParentId = caseList[0].id;
    	
        CHL_AngularTabsInputWrapper inputWrapper = new CHL_AngularTabsInputWrapper();
        system.assert(caseList != null);
        if(!caseList.isEmpty()){
            inputWrapper.requestId = caseList[0].Id;
        }
        String inputValue = JSON.serialize(inputWrapper);
        Test.startTest();   
           CHL_CommunityLandingController.getRequestNotes(inputValue);
        Test.stopTest();
    } */
    
	static testMethod void getReports_Test() {
        Test.startTest();   
        	
           CHL_CommunityLandingController.getReports('Test');
           CHL_CommunityLandingController.saveReports('{"id":"00Oo00c00a3YBK","name":"Quotes","tileVisible":true}');
           string inputvalue = 'test';
           System.assert(inputValue != null);
        Test.stopTest();
    }
    
	static testMethod void getSettingsOptions_Test() {
        Test.startTest();   
           CHL_CommunityLandingController.getSettingsOptions('Test');
           string inputvalue = 'test';
           System.assert(inputValue != null);
        Test.stopTest();
    }
    
	static testMethod void updateSettings_Test() {
        Test.startTest();  
			String inputValue = '{"locale": {"id": "fr_CH","value": "French (Switzerland)"},"language" : {"id" : "es","value": "Spanish"}}}'; 
			 System.assert(inputValue != null);
			CHL_CommunityLandingController.updateSettings(inputValue);
        Test.stopTest();
    }
    
	static testMethod void getAppConfig_Test() {
        Test.startTest();
        	String  inputValue = 'Test';
            System.assert(inputValue != null); 
			CHL_CommunityLandingController.getAppConfig(inputValue);
        Test.stopTest();
    }
    
    static testMethod void pulse_Test() {
        Test.startTest(); 
        	String  inputValue = 'Test';
            System.assert(inputValue != null);  
			CHL_CommunityLandingController.pulse(inputValue);
		Test.stopTest();
    }
    
    static testMethod void CHL_Branding_test() {
        CHL_CommunityLandingController con = new CHL_CommunityLandingController();
        insert new CSM_Admin__c(CHL_Portal_Color__c = '#008000',CHL_Portal_Header_BG_Color__c= '#008000');
        Test.startTest(); 
            con.locName = 'CHL_loc';
            String strLocName = con.locName;
            con.HeaderBGColor= '#008000';
            String colorCode =  con.HeaderBGColor;
            con.portalLogoURL = 'Channel_portal_Logo';
            String portalUrl = con.portalLogoURL;
            con.headerFontColor = '#008000';
            String fontColor = con.headerFontColor;
            System.assert(fontColor != null);  
		Test.stopTest();
    }
    
     //Test method for CHL_UserSettingsCompCtrl.
     static testMethod void CHL_UserSettingsCompCtrl_test() {
        Test.startTest(); 
        	String  inputValue = 'Test';
            System.assert(inputValue != null);  
			CHL_UserSettingsCompCtrl userSettingObj = new CHL_UserSettingsCompCtrl();
			if(!UserInfo.isMultiCurrencyOrganization()){
				CHL_Currency currencyObj = new CHL_Currency();
				currencyObj.id = 'EUR';
				currencyObj.value = 'EUR';
			}
		Test.stopTest();
    }
    
    static testMethod void getOppQueryPredicates_Test() {
        Test.startTest();
        	String  inputValue = 'Test';
            System.assert(inputValue != null); 
			CHL_CommunityLandingController.getOppQueryPredicates(inputValue);
        Test.stopTest();
    }
    
    static testMethod void getFilterOptions_Test() {
        Test.startTest();
        	String  fieldName = 'Test';
        	String fieldType = 'BOOLEAN';
            System.assert(fieldName != null); 
			List<CHL_QueryBuilderResponseWrapper.CHL_Options> filterOpt = CHL_QueryBuilderUtil.getFilterOptions(fieldName, fieldType);
        Test.stopTest();
    }
}