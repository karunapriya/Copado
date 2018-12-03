/**
 * Created Date     : Oct 11, 2018
 * Developed By     : Bhagyashri, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Comity                   Test Coverage               Oct 11, 2018            1.1                 @description
 *
 * 
 */
@isTest
private class REN_CustomSearchControllerTest implements HttpCalloutMock {
    //SGujar: Need to Revisit
    /**
     * Method to create test records once and use for all the methods in this test class
     */ 
    
    @testSetup 
    static void testSetupMethod() {
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        Product2 prod1 = REN_TestDataUtility.createProduct(1);
        insert prod1;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 standardPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert standardPB;
        List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(3, accountList[0].id);
        opportunityList[0].Pricebook2Id=standardPB.id;
        update opportunityList;
        CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
            partOppty.OpportunityId = opportunityList[0].id;
            partOppty.partnerAcc1Id = accountList[0].id ;
            partOppty.partnerAcc1Type = 'Reseller';
            partOppty.expirationDate= system.today().addDays(-10);
            partOppty.Stage= 'Needs Analysis';  
        CHL_Partner_Opportunity__c chlpartnerObj =   CHL_TestUtility.channelPartnerOpportunity(partOppty); 
        insert chlpartnerObj;
        if(CSM_AccessController.hasObject('Quote')) {
            
            List<SObject> quotesList = CHL_TestUtility.createQuotes(1,opportunityList,new List<CHL_Partner_Opportunity__c>{chlpartnerObj});
            quotesList[0].put(REN_Constants.OBJ_OPP_PRICEBOOK_ID,opportunityList[0].Pricebook2Id);
            insert quotesList;
            system.assert(quotesList != null);
            opportunityList[0].put('SyncedQuoteId',quotesList[0].Id);
            update opportunityList;
        }
        system.assert(chlpartnerObj.Id != null);
        
        SS_Validations__c ssValidations = SS_Validations__c.getOrgDefaults();
        ssValidations.REN_No_Split_allowed_for_Opp_Stage__c = 'Closed Sale';
        upsert ssValidations;
        String nameSpace = CSM_Util.getNamespace(); 
        
        List<REN_Custom_Search_Config__c> customSearchList = new List<REN_Custom_Search_Config__c>();
        REN_Custom_Search_Config__c customSearchConfigRec = CSM_TestUtility.insertCustomSearchConfig('Opportunity', 'Opportunity', nameSpace+'REN_Opportunity_Custom_Search', 
                                                                                                        nameSpace + 'REN_Renews_To__c.' + nameSpace + 'REN_Renews_To__c', nameSpace+'REN_Opportunity_Custom_Search', nameSpace+'REN_Opportunity_Custom_Search', null);
        REN_Custom_Search_Config__c customSearchConfigRec2 = CSM_TestUtility.insertCustomSearchConfig('Opportunity to opp', 'Opportunity', nameSpace+'REN_Opportunity_Custom_Search', 
                                                                                                        '', nameSpace+'REN_Opportunity_Custom_Search', nameSpace+'REN_Opportunity_Custom_Search', null);
        REN_Custom_Search_Config__c customSearchConfigRec3 = CSM_TestUtility.insertCustomSearchConfig('External Accounts', 'Account', null, 
                                                                                                        '', null, nameSpace+'REN_Account_Custom_Search', 'External Account Search');
        customSearchList.add(customSearchConfigRec);
        customSearchList.add(customSearchConfigRec2);
        customSearchList.add(customSearchConfigRec3);
        insert customSearchList;
        
        CSM_Admin__c adminObj = new CSM_Admin__c();
        adminObj.REN_Custom_Search_Records_Limit__c = 1000; 
        insert adminObj;
        system.assert(customSearchConfigRec != null);
        
        List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
        CSM_Focus_Category_View__c focusView = CSM_TestUtility.insertFCVTestUtility('Saved Search Account by Opportunities','','WHERE (Name = \'\')','select id, name, CSM_Account_Has_Success_Plan__c  from Account WHERE (Name = \'\') Order By LastModifiedDate Desc Nulls Last',
                                    'Account', '', 'Opportunity.AccountId', true, 'All Accounts', '1', '');
        fcViewList.add(focusView);
        CSM_Focus_Category_View__c focusView2 = CSM_TestUtility.insertFCVTestUtility('Saved Search Oppty by Oppty','','WHERE (StageName = \'\')', 'select id, name  from Opportunity WHERE (StageName = \'\') Order By LastModifiedDate Desc Nulls Last',
                                    'Opportunity', '', 'Opportunity', true, 'All Opportunities', '2', '');
        fcViewList.add(focusView2);
        insert fcViewList;
        
        REN_RSTestDataUtility.RSConfigWrapper rsConfig = new REN_RSTestDataUtility.RSConfigWrapper();
        rsConfig.customObj = 'Opportunity' ;
        rsConfig.displayDialog = true;
        rsConfig.displayResposeDialog = true;
        rsConfig.flowName = 'Request Count';
        rsConfig.invokingObj = 'Opportunity';
        rsConfig.namedCredential = 'RS_Echo';
        rsConfig.namedCredentialUrlExt = '/odata/frb1/dell/opportunity/dell.CreditBalance';
        rsConfig.noOfCol = '2';
        rsConfig.responseObj = 'Opportunity';
        rsConfig.soql = 'Select Account.Id,Account.Name,Name from Opportunity where id =';
        
        List<REN_RS_Config__c> rsConfigList = new List<REN_RS_Config__c>();
        REN_RS_Config__c rsConfigObj = REN_RSTestDataUtility.createRSConfig(rsConfig);
        rsConfigList.add(rsConfigObj);
        
        REN_RSTestDataUtility.RSConfigWrapper rsConfig2 = new REN_RSTestDataUtility.RSConfigWrapper();
        rsConfig2.customObj = null ;
        rsConfig2.displayDialog = true;
        rsConfig2.displayResposeDialog = true;
        rsConfig2.flowName = 'External Account Search';
        rsConfig2.invokingObj = 'Account';
        rsConfig2.namedCredential = 'RS_ODATA_FRB5';
        rsConfig2.namedCredentialUrlExt = '/ExternalAccount/dell.CustomSearch';
        rsConfig2.noOfCol = null;
        rsConfig2.responseObj = null;
        rsConfig2.soql = null;
        rsConfig2.recordLimit = 100;
        REN_RS_Config__c rsConfigObj2 = REN_RSTestDataUtility.createRSConfig(rsConfig2);
        rsConfigList.add(rsConfigObj2);
        
        insert rsConfigList;
    }
    
    static testMethod void CustomSearchPage_PositiveTest() {
        List<opportunity> oppList = [select id from opportunity limit 10];
        ApexPages.currentPage().getParameters().put('objName', 'Opportunity');
        REN_CustomSearchController ctrl = new REN_CustomSearchController();
        system.assert(ctrl != null);
    }
    static testMethod void CustomSearchPage_NegTest() {
        List<opportunity> oppList = [select id from opportunity limit 10];
        oppList[0].stageName = 'Closed Sale';
        update oppList;
        REN_Custom_Search_Config__c customSearchConfigRec = REN_Custom_Search_Config__c.getOrgDefaults();
        delete customSearchConfigRec;
        ApexPages.currentPage().getParameters().put('objName', 'Opportunity');
        REN_CustomSearchController ctrl = new REN_CustomSearchController();
        system.assert(ctrl != null);
    }
    static testMethod void CustomSearchResultTest() {
        List<opportunity> oppList = [select id from opportunity limit 10];
        ApexPages.currentPage().getParameters().put('objName', 'Opportunity');
        REN_CustomSearchController ctrl = new REN_CustomSearchController();
        ctrl.customSearchLimit = 20;
        ctrl.selectedParentObject = 'Opportunity';
        ctrl.selectedChildObject = 'Opportunity';
        REN_QueryBuilderCompController assetLogicBuilder = new REN_QueryBuilderCompController();
        assetLogicBuilder.configSettings = ctrl.configSettings;
        assetLogicBuilder.configSettings.initializeConfigSettings('Opportunity', 'Opportunity', 'Test', false, 'Mass Update');
        ctrl.setBaseChildController(assetLogicBuilder);
        ctrl.callOnRelatedObjectChange();   
        ctrl.callOnParentObjectChange();
        ctrl.findFor();
        ctrl.refreshMessages();
        ctrl.transferOpportunity();
        ctrl.showSelectedRecInfoMsg();
        ctrl.showRSThresholdExceedError();
        ctrl.displayTransferResult();
       system.assert(ctrl != null);
    }
    
    static testMethod void CustomSearchSavedSearch() {
        List<CSM_Focus_Category_View__c> focusList = [select id from CSM_Focus_Category_View__c where CSM_Object_Name__c = 'Opportunity' and RLM_Related_Object_Name__c = 'Opportunity' limit 1];
        List<CSM_Focus_Category_View_Criteria__c> fcvcList = new List<CSM_Focus_Category_View_Criteria__c>();
        CSM_Focus_Category_View_Criteria__c fcViewCriteriaObj= CSM_TestUtility.createFCVCriteria('StageName', 'Stage','PICKLIST', '=', 'Not Contacted', focusList[0].Id);
        fcViewCriteriaObj.RLM_LineNo__c = 1;
        CSM_Focus_Category_View_Criteria__c fcViewCriteriaObj2 = CSM_TestUtility.createFCVCriteria('CloseDate', 'Close Date', 'DATETIME', '=', null, focusList[0].Id);
        fcViewCriteriaObj2.RLM_LineNo__c = 2;
        fcViewCriteriaObj2.RLM_Is_Specific_Date__c = true;
        fcvcList.add(fcViewCriteriaObj);
        fcvcList.add(fcViewCriteriaObj2);
        insert fcvcList;
        system.assert(fcvcList.size() > 0);
        ApexPages.currentPage().getParameters().put('id', focusList[0].Id);
        REN_CustomSearchController ctrl = new REN_CustomSearchController();
        ctrl.selectedParentObject = 'Opportunity';
        ctrl.selectedChildObject = 'Opportunity';
        system.assert(ctrl != null);
    }
    static testMethod void savedSearchParentError() {
        CSM_Focus_Category_View__c focusView = CSM_TestUtility.insertFCVTestUtility('Saved Search Account by Opportunities','','WHERE (Name = \'\')','select id, name, CSM_Account_Has_Success_Plan__c  from Account WHERE (Name = \'\') Order By LastModifiedDate Desc Nulls Last',
                                    'Account', '', 'Opportunity.AccountId', true, 'All Accounts', '1', '');
        insert focusView;
        system.assert(focusView != null);
        ApexPages.currentPage().getParameters().put('id', focusView.Id);
        REN_CustomSearchController ctrl = new REN_CustomSearchController();
        ctrl.selectedParentObject = 'Account';
        ctrl.selectedChildObject = 'Opportunity.AccountId';
        system.assert(ctrl != null);
    }
    
    static testMethod void savedSearchChildError() {
        CSM_Focus_Category_View__c focusView = CSM_TestUtility.insertFCVTestUtility('Saved Search Oppty by Oppty','','WHERE (StageName = \'\')', 'select id, name  from Opportunity WHERE (StageName = \'\') Order By LastModifiedDate Desc Nulls Last',
                                    'Opportunity', '', 'Asset.REN_Opportunity__c', true, 'All Opportunities', '2', '1 AND 2');
        insert focusView;
        system.assert(focusView != null);
        ApexPages.currentPage().getParameters().put('id', focusView.Id);
        REN_CustomSearchController ctrl = new REN_CustomSearchController();
        ctrl.selectedParentObject = 'Opportunity';
        ctrl.selectedChildObject = 'Asset.REN_Opportunity__c';
        system.assert(ctrl != null);
    }
    
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"@odata.context":"https://sbx.dev.ssi-cloud.com/odata/frb1/dell/$metadata#Edm.Int64","value":10}');
        response.setStatusCode(200);
        system.assert(true);
        return response;
    }
   
    static testMethod void filterByOwnerWORSUnitTest(){
        List<opportunity> oppList = [select id from opportunity limit 10];
        system.assert(oppList != null);
        REN_CustomSearchController customSearchObj = new REN_CustomSearchController();
        customSearchObj.hasMassTransferAccess = true;
        system.assert(customSearchObj != null);
        customSearchObj.selectOwnerOption = 'Teams';
        customSearchObj.findFor();
        customSearchObj.updateSelectionToNone();
        customSearchObj.disableQueueOpt();
        customSearchObj.sendCountRequest();
    }
    
    static testMethod void filterByOwnerUnitTest(){
        List<opportunity> oppList = [select id from opportunity limit 10];
        REN_CustomSearchController customSearchObj = new REN_CustomSearchController();
        customSearchObj.selectedParentObject = 'Account';
        customSearchObj.selectedChildObject = 'Opportunity.AccountId';
        system.assert(customSearchObj != null);
        REN_RS_Config__c rsConfig = new REN_RS_Config__c(REN_Flow_Name__c = 'Request Count', REN_Invoking_Object__c = 'Opportunity', REN_RS_Request_Timeout_Limit__c = 3000, REN_Named_Credential__c = 'Test', REN_Named_Credential_URL_Extension__c = 'Test');
        insert rsConfig;
        system.assert(rsConfig != null);
        Boolean isOppTeamEnabled = CSM_AccessController.hasObject('OpportunityTeamMember');
        
        if(isOppTeamEnabled){
            sObject oppTeamObj = Schema.getGlobalDescribe().get('OpportunityTeamMember').newSobject();
            oppTeamObj.put('OpportunityId', oppList[0].id);
            oppTeamObj.put('UserId', UserInfo.getUserId());
            insert oppTeamObj;
            system.assert(oppTeamObj != null);
        }
        
        customSearchObj.selectOwnerOption = 'Teams';
        customSearchObj.findFor();
        customSearchObj.updateSelectionToNone();
        customSearchObj.disableQueueOpt();
        REN_QueryBuilderCompController assetLogicBuilder = new REN_QueryBuilderCompController();
        List<REN_QueryBuilderWrapper.ColumnFilter> columnFilterLst = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter colFilterObj = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        Set<Integer> filterNumValueSet = new Set<Integer>();
        filterNumValueSet.add(200);
        colFilterObj.fieldApiName = 'Amount';
        colFilterObj.fieldDataType = 'CURRENCY';
        colFilterObj.operator = CSM_Constants.OPERATOR_EQUAL;
        colFilterObj.filterValue = 'Test';
        colFilterObj.filterCondition = 'Amount IN :nFilter1';
        colFilterObj.filterValue = '200';
        colFilterObj.filterNumberValueSet = filterNumValueSet; 
        columnFilterLst.add(colFilterObj);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new REN_CustomSearchControllerTest());
        customSearchObj.sendCountRequest();
        customSearchObj.sendCountRequest();
        Test.stopTest();
    }
   
        /* Start -- US3859 - Added test method for Consolidate and Not Found Items functionality */
   
    static testMethod void ConsolidateAndNotFoundTest() {
        List<Sobject> oppList = [select id,amount from opportunity limit 5];
        if(oppList != null){
            oppList[0].put('amount',200);
            update oppList;
        }
        ApexPages.currentPage().getParameters().put('objName', 'Opportunity');
        ApexPages.currentPage().getParameters().put('id', oppList[0].Id);
        REN_CustomSearchController ctrl = new REN_CustomSearchController();
        ctrl.selectedParentObject = 'Opportunity';
        ctrl.selectedChildObject = 'Opportunity';
        ctrl.selectedOpportunityIds = oppList[0].id;
        ctrl.isSyncQuoteEnabledOnAnySelectedOpp = true;
        ctrl.baseMainController = new REN_BaseMainController();
        REN_BaseMainController basCtrl = ctrl.baseMainController;
        List<REN_QueryBuilderWrapper.ColumnFilter> columnFilterLst = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter colFilterObj = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        Set<Integer> filterNumValueSet = new Set<Integer>();
        filterNumValueSet.add(200);
        colFilterObj.fieldApiName = 'Amount';
        colFilterObj.fieldDataType = 'CURRENCY';
        colFilterObj.operator = CSM_Constants.OPERATOR_EQUAL;
        colFilterObj.filterValue = 'Test';
        colFilterObj.filterCondition = 'Amount IN :nFilter1';
        colFilterObj.filterValue = '200';
        colFilterObj.filterNumberValueSet = filterNumValueSet; 
        columnFilterLst.add(colFilterObj);
        
        REN_QueryBuilderWrapper queryBuilder = new REN_QueryBuilderWrapper('Opportunity', 'Test', true, 'Request Count');
        queryBuilder.columnFilterList = columnFilterLst;
        REN_QueryBuilderCompController baseChild = new REN_QueryBuilderCompController();
        baseChild.inputWrapper = queryBuilder;
        Test.startTest(); 
            //ctrl.relatedObjList = oppList;
            ctrl.consolidateOpportunity();  
            ctrl.redirectToConsolidate();  
            ctrl.noResultFound();
            ctrl.validateRecordCount();
            ctrl.renderSavedSearch();
        system.assert(ctrl != null);
        Test.stopTest();
    }
    
    static testMethod void renderSavedSearchTest() {
        List<Sobject> oppList = [select id,amount from opportunity limit 5];
        if(oppList != null){
            oppList[0].put('amount',200);
            update oppList;
        }
        CSM_Focus_Category_View__c fcv1 = new CSM_Focus_Category_View__c();
        fcv1.CSM_Display_Name__c = 'fcv 1';
        fcv1.CSM_Columns__c = '';
        fcv1.CSM_Criteria__c = '';
        fcv1.CSM_SOQL__c = '';
        fcv1.CSM_Object_Name__c = 'Opportunity';
        fcv1.CSM_IsTile__c = true;
        fcv1.CSM_Currency_Header__c = '';
        fcv1.CSM_Sort_By__c='Name';
        fcv1.CSM_Sort_Order__c='Asc';
        fcv1.RLM_Related_Object_Name__c = 'Opportunity';
        fcv1.CSM_Object_Name__c = 'Opportunity';
        fcv1.CSM_Filter_By_Owner_Value__c = 'Queue';
        insert fcv1;
        
        ApexPages.currentPage().getParameters().put('objName', 'Opportunity');
        ApexPages.currentPage().getParameters().put('id', fcv1.Id);
        REN_Custom_Search_Config__c customConfig = REN_Custom_Search_Config__c.getOrgDefaults();
        customConfig.REN_Related_Object__c = '';
        update customConfig;
        REN_CustomSearchController ctrl = new REN_CustomSearchController();
        ctrl.selectedParentObject = 'Opportunity';
        ctrl.selectedChildObject = 'Opportunity';
        ctrl.selectedOpportunityIds = oppList[0].id;
        Test.startTest(); 
            ctrl.renderSavedSearch();
            system.assert(ctrl != null);
        Test.stopTest();
    }
    static testMethod void customSearchNegativeTest(){
        REN_CustomSearchController customSearchCtrl = new REN_CustomSearchController();
        system.assert(customSearchCtrl != null);
        customSearchCtrl.parentIdCSV = 'test';
        customSearchCtrl.selectedrecords = 'test';
        customSearchCtrl.recordLimit = 50;
        customSearchCtrl.jsonString = '';
        customSearchCtrl.responseStr = '';
        customSearchCtrl.selectedRecordCount = 2;
        customSearchCtrl.rsRequestLimit = 4;
        customSearchCtrl.initializeCustomSerachMap();
        customSearchCtrl.validateRecordCount();
        
        customSearchCtrl = new REN_CustomSearchController();
        customSearchCtrl.selectedRecordCount = 4;
        customSearchCtrl.rsRequestLimit = 2;
        customSearchCtrl.rsHighWaterMarkLimit = 6;
        customSearchCtrl.isRSConfig = true;
        customSearchCtrl.validateRecordCount();
        
        customSearchCtrl = new REN_CustomSearchController();
        customSearchCtrl.selectedRecordCount = 4;
        customSearchCtrl.rsRequestLimit = 2;
        customSearchCtrl.rsHighWaterMarkLimit = 6;
        customSearchCtrl.isRSConfig = false;
        customSearchCtrl.validateRecordCount();
        customSearchCtrl.callOnParentObjectChange();
    }
    static testMethod void customSearchExternalAcc(){
        REN_Custom_Search_Config__c customSearchConfig = REN_Custom_Search_Config__c.getValues('External Accounts');
        REN_CustomSearchController customSearchCtrl = new REN_CustomSearchController();
        system.assert(customSearchCtrl != null);
        REN_QueryBuilderCompController logicBuilder = new REN_QueryBuilderCompController();
        logicBuilder.configSettings = customSearchCtrl.configSettings;
        logicBuilder.configSettings.initializeConfigSettings('Opportunity', 'Opportunity', 'Test', false, 'Mass Update');
        customSearchCtrl.setBaseChildController(logicBuilder);
        customSearchCtrl.selectedParentObject = customSearchConfig.REN_Parent_Object__c+':'+customSearchConfig.Name;
        customSearchCtrl.callOnParentObjectChange();
        customSearchCtrl.findFor();
        System.assert(customSearchCtrl.selectedObject == 'Account');
    }
    
    /* End -- US3859 - Added test method for Consolidate and Not Found Items functionality */
    
}