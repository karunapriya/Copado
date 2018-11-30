/**
* @description    CHL_CommunityLandingController class is used as a landing page for partner community users
*/
public with sharing class CHL_CommunityLandingController {
    
   /**
    * @description : This variable dynamically loads the static resource in the community landing page.
                     This resource should dynamically load the locale js file as per user locale.
    */
    public String locName {
         get 
          { 
            
            locName = '/vendor/angular/i18n/angular-locale_'+CHL_Util.getAngularGridLocaleForUserLocale(userinfo.getLocale())+'.js';
             return locName;
           }
        set;
     }
    
   
    public static CSM_Admin__c getCSMAdminInstance() {
        return CSM_Admin__c.getInstance();
    }

    // US1361 : Used to set header background color on Community.
    public String headerBGColor {
        get { 
            if(getCSMAdminInstance()!=null) {
                headerBGColor = getCSMAdminInstance().CHL_Portal_Color__c;
            }
            return headerBGColor;
        }
        set;
    }
    
    
    // US1361 : Used to set header Font color on community header.
    public string headerFontColor {
        get{
            if(getCSMAdminInstance()!=null) {
                headerFontColor = getCSMAdminInstance().CHL_Portal_Header_BG_Color__c;
            }
            return headerFontColor;
        }
        set;
    }
    
    public String segmentAPIKey {
        get { 
            if(getCSMAdminInstance()!=null) {
                segmentAPIKey = getCSMAdminInstance().CHL_Segment_API_Key__c;
            }
            return segmentAPIKey;
        }
        set;
    }
    
    // US1361 : Used to set logo on community header.
    public string portalLogoURL {
        get{
            List<Document> documentList = [Select d.Id From Document d where d.DeveloperName = 'Channel_Portal_Logo' limit 1];
            if(documentList != null && documentList.size() > 0){
                portalLogoURL = Site.getPathPrefix()+'/servlet/servlet.FileDownload?file='+documentList[0].Id;
            } else {
                portalLogoURL = '';
            }
            return portalLogoURL; 
        }
        set;
    }
    
    //DE1669 : below methood is used to get the url of Fav Icon from documents.
    public string portalFavIconURL {
        get{
            List<Document> documentList = [Select Id From Document where DeveloperName = 'Channel_Portal_Fav_Icon' limit 1];
            if(documentList != null && documentList.size() > 0){
                portalFavIconURL = Site.getPathPrefix()+'/servlet/servlet.FileDownload?file='+documentList[0].Id;
            } else {
                portalFavIconURL = '';
            }
            return portalFavIconURL; 
        }
        set;
    }

    /**
    * @description : This methodreturns the data required for pipe line chart
    * @param :
    */
    @RemoteAction
    public static Object getChartData(String inputValue){
        system.debug('inputValue'+inputValue);
        if(inputValue == '{"queryParams":{"quarters":[],"years":[],"countries":[],"resellerReps":[],"distributorReps":[]}}') {
            inputValue = '{"queryParams":{"quarters":[],"years":[],"countries":["All"],"resellerReps":["All"],"distributorReps":["All"]}}';
        }  
        CHL_GridInputWrapper inputJsonWrapper = (CHL_GridInputWrapper)JSON.deserialize(inputValue, CHL_GridInputWrapper.class);        
        CHL_PipeLineChartBusinessLayer chartBLayer = new CHL_PipeLineChartBusinessLayer(inputJsonWrapper);
        CHL_ChartResponseWrapper wrp = chartBLayer.constructChartWrapper();
        
        String data = JSON.serialize(wrp);
        system.debug('inputValue : '+ inputValue + '\n testJSON : '+JSON.serialize(wrp));
        return wrp;
    }
    /**
    * @description : This method returns the data required for overview tab on the partner landing page.
    *                 This methods returns data for Action tiles, Expiered opportunity matrix and piple line chart
    * @param :
     */
    @RemoteAction
    public static Object getOverviewData(String inputValue){
        
        CHL_OverviewWrapper wrp = new CHL_OverviewWrapper();
        wrp.channelPartner = (Userinfo.getFirstName()==null?'':Userinfo.getFirstName())+ ' ' + Userinfo.getLastName();
        //DateTime d = CHL_Util.fetchLastNewOpportunityViewDate();
        wrp.newOpps =  CHL_PartnerOpportunityDataAccess.fetchLastWeekOpportunitiesCount();
        wrp.updateOpps=  CHL_PartnerOpportunityDataAccess.fetchNeedsStatusUpdate();
        wrp.expiredOpps =  CHL_PartnerOverviewUtil.fetchExpiredMatrix();
        wrp.currentQuarter = CHL_Util.getCurrentQuarter();
        wrp.quarters = CHL_Util.getQuartersList();
        wrp.currentYear =  CHL_Util.getCurrentYear();
        wrp.years = CHL_Util.getNextAndLastYears(10);
        
        CHL_OverviewWrapper overviewWrapper = new CHL_OverviewWrapper();
        overviewWrapper = CHL_PipeLineChartBusinessLayer.partnerOppDetails();
       
        wrp.resellerReps = overviewWrapper.resellerReps;
        wrp.distributorReps = overviewWrapper.distributorReps;
        wrp.countries = overviewWrapper.countries;
        return wrp;
    }//End of method
        
      
    /**
    * @description : This method takes input as search string and returns the matched Account Details .
    *               Added for US501.
    */
    @RemoteAction
     public static object searchAccounts(String inputValue) {
        AccountSearch searchAccObj = new AccountSearch();
        searchAccObj = (AccountSearch) JSON.deserialize(inputValue, AccountSearch.class);
        String searchAcc = searchAccObj.q;
        List <AccountWrapper> AccWrapperList = new List <AccountWrapper> ();
        if(searchAcc != null && searchAcc.length() >= 2 ){
            String searchStr1 = '\'%' + String.escapeSingleQuotes(searchAcc) + '%\'';
            List<Account> accList = CSM_AccountDataAccess.searchAccount(searchStr1);
            for (Account acc: accList) {
                AccountWrapper accWrapperObj = new AccountWrapper(acc);
                AccWrapperList.add(accWrapperObj);
            }
        }
       return AccWrapperList;
    }
    
     @RemoteAction
     public static object globalSearch(String inputValue) {
        /*AccountSearch searchAccObj = new AccountSearch();
        searchAccObj = (AccountSearch) JSON.deserialize(inputValue, AccountSearch.class);
        String searchAcc = searchAccObj.q;*/
        
       return CHL_GlobalSearchBusinessLayer.ConstructGlobalSearch(inputValue);
    }
    
    /**
      * @description : This method is generic method to call all types of grid in community, it will call CHL_BusinessLayerFactory 
                    and from there based on grid type it will call respective grids.
    */
    @RemoteAction
    public static CHL_AngularResponeWrapper getResponseForGrid(String requestValue){        
        
        CHL_GridInputWrapper inputJsonWrapper = (CHL_GridInputWrapper)JSON.deserialize(requestValue, CHL_GridInputWrapper.class);
        CHL_BusinessLayerFactory blFactory = new CHL_BusinessLayerFactory(inputJsonWrapper);
        CHL_AngularResponeWrapper wrp = blFactory.constructGridResponseList();
        system.debug('inputValue : '+ requestValue + '\n testJSON : '+JSON.serialize(wrp)); 
        return wrp;
    }
    
   
   /**
     * @description : This method returns the filter options for Sales Request to show in the Request Tab .
   */
   @RemoteAction
   public static Object getRequestTypes(String inputValue) {
       return CHL_SalesRequestBusinessLayer.getCaseTypes();
   }
   
   @RemoteAction
    public static List<Object> getOppQueryPredicates(String inputValue){   
    	String namespace = CSM_Util.getNamespace();     
        List<Schema.FieldSetMember> fieldSet = CHL_Util.getFieldSet(namespace + CHL_Constants.PARTNER_OPP_DETAILS_FIELDSET_NAME, namespace + 'CHL_Partner_Opportunity__c');
        Map<String, List<SelectOption>> operatorMap = CHL_QueryBuilderUtil.populateOperatorMap();
        return CHL_QueryBuilderUtil.getFilterFieldsResponse(fieldSet, operatorMap);
    } 
    
    /**
      * @description : This method returns the filter options for partner opportunities to show in the Opportunities Tab (such as quarters, Oppty tpes etc) .
    */
    @RemoteAction
    public static CHL_PartnerOpportunityFilters getOppsFilterOptions(String inputValue) {
        
        List<CHL_Opportunity_Status_Log__c> optyStatusLogList = CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
        CHL_PartnerOpportunityFilters wrp = new CHL_PartnerOpportunityFilters();
        wrp.currentQuarter = CHL_Util.getCurrentQuarter();
        wrp.oppTypes = CHL_Util.getOptyTypes();
        wrp.quarters = CHL_Util.getQuartersList();
        wrp.currentYear =  CHL_Util.getCurrentYear();
        wrp.years = CHL_Util.getNextAndLastYears(10);
        
        if(optyStatusLogList != null && !optyStatusLogList.isEmpty())   {
            wrp.maximumDaysBetweenUpdates = Integer.valueOf((optyStatusLogList[0]).get(CHL_CONSTANTS.OBJ_OPSL_DAYS_UPDATES));
        }
        CHL_PartnerOpportunityFilters.CHL_BulkUpdateOptions bulkUpdateOptions = new CHL_PartnerOpportunityFilters.CHL_BulkUpdateOptions();
        bulkUpdateOptions = CHL_PartnerOverviewUtil.fetchResellerDistributorReps();
        bulkUpdateOptions.stages = CHL_PartnerOverviewUtil.getTranslatedAvailableSalesStage(); //fetchStagePicklistValues
        
        wrp.bulkUpdateOptions = bulkUpdateOptions; 
        system.debug('Filter Wrapper : '+wrp+'\n'+JSON.serialize(wrp)+'\n wrp.stages ' +wrp.oppTypes);
        String data = JSON.serialize(wrp);
        return wrp;
    }
  
      /**
      * @description : This method returns the updated grid data, on Opportunities Tab
      * @param :Accepts list of opportunities that needs to update, as JSON String
    */
    @RemoteAction
    public static Object updateOpportunities(string inputValue){
        system.debug('inputValue '+inputValue);
        //inputValue = '{"gridData":[{"updated":false,"rowData":{"CHL_Status__c":{"value":"UPdated Status","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"CHL_Needs_Status_Update__c":{"value":"2015-05-30T04:00:00+00:00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"Latest_Quote":{"value":"Tanvi:RENEW_8JUN","url":"/servlet/servlet.FileDownload?file=0QDj0000000PTXsGAO","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"CHL_Partner_Account_2_Contact__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"CHL_Partner_Account_1_Contact__c":{"value":"Partner User2","url":"","needsUpdate":null,"lookupId":"003j000000UDxFZ","currencyCode":"USD"},"CHL_Close_Date__c":{"value":"2015-08-06T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"CHL_Expiration_Date__c":{"value":"2015-06-30T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"CHL_Amount__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"CHL_Probability__c":{"value":"60","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"CHL_Sales_Stage__c":{"value":"Qualification","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"CHL_Opportunity_Account_Name__c":{"value":"285 Test","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"}},"recordID":"a0hj0000001AAB4AAO","index":1,"canEdit":false},{"updated":false,"rowData":{"CHL_Status__c":{"value":"","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"CHL_Needs_Status_Update__c":{"value":"2015-07-28T11:09:11+00:00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"Latest_Quote":{"value":"","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"CHL_Partner_Account_2_Contact__c":{"value":"","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"CHL_Partner_Account_1_Contact__c":{"value":"Partner User3","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"CHL_Close_Date__c":{"value":"2015-07-28T04:00:00+00:00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"CHL_Expiration_Date__c":{"value":"2015-07-28T04:00:00+00:00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"CHL_Amount__c":{"value":"200.00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"CHL_Probability__c":{"value":"70","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"CHL_Sales_Stage__c":{"value":"Qualification","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"CHL_Opportunity_Account_Name__c":{"value":"285 Test","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"}},"recordID":"a0hj0000001B18bAAC","index":2,"canEdit":false}],"columnHeader":null}';
        CHL_AngularResponeWrapper inputJsonWrapper = (CHL_AngularResponeWrapper)JSON.deserialize(inputValue, CHL_AngularResponeWrapper.class);
        system.debug('input JSON'+inputJsonWrapper);
        CHL_AngularResponeWrapper wrp = CHL_PartnerOpportunityGridUpdate.updatePartnerOpportunity(inputJsonWrapper);
        
        return wrp;
    }//end of Method
    
    /*
     *@Description: This methos is created as part of US1026, to update Quote Primary field from Quote tab
    */
    @RemoteAction
    public static Object saveQuote(string inputValue){
        CHL_AngularResponeWrapper inputJsonWrapper = (CHL_AngularResponeWrapper)JSON.deserialize(inputValue, CHL_AngularResponeWrapper.class);
        CHL_AngularResponeWrapper wrp = CHL_PartnerOpportunityGridUpdate.updateQuotes(inputJsonWrapper);
        
        return wrp;
    }//end of Method
    /**
      * @description : This method returns the data for Contact, Quotes and Renewal Relationship tab in community.
    */
    @RemoteAction
    public static Object  getOppDetails(String inputvalue) {    
        CHL_AngularTabsInputWrapper tabInputObj = new CHL_AngularTabsInputWrapper();
        tabInputObj = (CHL_AngularTabsInputWrapper)JSON.deserialize(inputValue, CHL_AngularTabsInputWrapper.class);
        return CHL_PartnerOpportunityBusinessLayer.getOpportunityDetails(inputvalue);
    }
    
    @RemoteAction
    public static Object getOppNotes(String inputvalue) {    
        //For History Tab
        return CHL_NotesBusinessLayer.getTaskList(inputvalue);       
    }
    
    @RemoteAction
    public static Object createOppTask(String inputvalue) {    
        return CHL_NotesBusinessLayer.createTaskForOpportunity(inputvalue);  
    }
    
    
    @RemoteAction
    public static Object  getRequestNotes(String inputvalue) {    
        //For Details Tab
        return CHL_NotesBusinessLayer.getCaseCommentsList(inputvalue);       
    }
    
    @RemoteAction
    public static Object  getAccountDetails(String inputvalue) {    
        //For Details Tab
        return CHL_AccountBusinessLayer.getAccountDetails(inputvalue);        
    }
    
    
    @RemoteAction
    public static Object  getRequestDetails(String inputvalue) {    
        //For Details Tab
        return CHL_SalesRequestBusinessLayer.getCaseDetailsFromFieldSet(inputvalue);        
    }
    
    @RemoteAction
    public static object getQuoteList(string inputvalue)    {
        system.debug('getQuoteList : '+inputvalue);
        QuoteInputStructure quoteWrp = new QuoteInputStructure();
        quoteWrp = (QuoteInputStructure) JSON.deserialize(inputvalue, QuoteInputStructure.class);
        Set<Id> partnerOppIdSet = new Set<Id>();
        partnerOppIdSet.add(quoteWrp.oppId);               
        List<CHL_AngularResponeWrapper.CHL_ColumnOptions> oppQuotes = new List<CHL_AngularResponeWrapper.CHL_ColumnOptions>();
        if(CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
            List<sObject> quoteList = CHL_QuoteDataAccess.getQuoteListByPartnerOppId(partnerOppIdSet, false);
            for(sObject sObjQuote:quoteList){
                CHL_AngularResponeWrapper.CHL_ColumnOptions oppQuote = new CHL_AngularResponeWrapper.CHL_ColumnOptions();
                oppQuote.lookupId=(String)sObjQuote.get('Id');
                oppQuote.value=(String)sObjQuote.get('Name');
                oppQuotes.add(oppQuote);
            } 
        }
        return oppQuotes;
    }
    
    /**
    * @description : This method returns the list of reports from Portal Reports Folder.
    */
    @RemoteAction
    public static object getReports(string inputvalue)    {
        return CHL_ReportBusinessLayer.getReportDetails(inputvalue);
    }
    
    /**
    * @description : This method returns the list of reports from Portal Reports Folder.
    */
    @RemoteAction
    public static object saveReports(string inputvalue)    {
        return CHL_ReportBusinessLayer.saveReports(inputvalue);
    }
    
    /**
    * @description : This method returns the portal contents from CHL_Portal_Content__c Object
    */
    @RemoteAction
    public static object getContentLinks(string inputvalue)    {
        //CHL_GridInputWrapper inputJsonWrapper = (CHL_GridInputWrapper)JSON.deserialize(inputvalue, CHL_GridInputWrapper.class);
        //CHL_PortalContentBusinessLayer pcLayer = new CHL_PortalContentBusinessLayer(inputJsonWrapper);
        return CHL_PortalContentBusinessLayer.getPortalContents(inputvalue);
    }
    /*@RemoteAction
    public static String getContentLinks(String inputValue){
        String data = '{ "gridConfiguration": { "exportPdf": false, "exportCsv": false, "selection": false, "sorting": true }, "columnHeader": [{ "label": "Description", "readOnly": true, "apiName": "CHL_Content_Description", "isSortable": true, "isSwitchable": true, "dataType": "STRING", "isSimple": true }, { "label": "Url", "readOnly": true, "apiName": "CHL_Content_Link", "isSortable": true, "isSwitchable": true, "dataType": "LINK", "url":"value", "isSimple": true }], "gridData": [ { "rowData": { "CHL_Content_Link": { "value": "http://google.com" }, "CHL_Content_Description": { "value": "Tanner Holloway" } }, "canEdit": false, "recordId": 0 }, { "rowData": { "CHL_Content_Link": { "value": "http://yahoo.com" }, "CHL_Content_Description": { "value": "Jeanette Davis" } }, "canEdit": false, "recordId": 1 }, { "rowData": { "CHL_Content_Link": { "value": "http://servicesource.com" }, "CHL_Content_Description": { "value": "Wagner Hunter" } }, "canEdit": false, "recordId": 2 }, { "rowData": { "CHL_Content_Link": { "value": "http://yahoo.com" }, "CHL_Content_Description": { "value": "Rowe Shaw" } }, "canEdit": false, "recordId": 3 }, { "rowData": { "CHL_Content_Link": { "value": "http://yahoo.com" }, "CHL_Content_Description": { "value": "Catherine Gallegos" } }, "canEdit": false, "recordId": 4 }, { "rowData": { "CHL_Content_Link": { "value": "http://cnn.com" }, "CHL_Content_Description": { "value": "Rosetta Holman" } }, "canEdit": false, "recordId": 5 }, { "rowData": { "CHL_Content_Link": { "value": "http://servicesource.com" }, "CHL_Content_Description": { "value": "Haley Noble" } }, "canEdit": false, "recordId": 6 }, { "rowData": { "CHL_Content_Link": { "value": "http://servicesource.com" }, "CHL_Content_Description": { "value": "Lavonne Velazquez" } }, "canEdit": false, "recordId": 7 }, { "rowData": { "CHL_Content_Link": { "value": "http://servicesource.com" }, "CHL_Content_Description": { "value": "Conley Grimes" } }, "canEdit": false, "recordId": 8 }, { "rowData": { "CHL_Content_Link": { "value": "http://yahoo.com" }, "CHL_Content_Description": { "value": "Holder Myers" } }, "canEdit": false, "recordId": 9 }, { "rowData": { "CHL_Content_Link": { "value": "http://yahoo.com" }, "CHL_Content_Description": { "value": "Cleo Kidd" } }, "canEdit": false, "recordId": 10 }, { "rowData": { "CHL_Content_Link": { "value": "http://servicesource.com" }, "CHL_Content_Description": { "value": "Juliana Nieves" } }, "canEdit": false, "recordId": 11 }, { "rowData": { "CHL_Content_Link": { "value": "http://servicesource.com" }, "CHL_Content_Description": { "value": "Lidia Benson" } }, "canEdit": false, "recordId": 12 } ]}';        
        return data;
    }
    /**
    * @description : This method is used to get list of all locale and languages from  user. Added for US1165.
    */
    @RemoteAction
    public static object getSettingsOptions(string inputvalue)    {
        return CHL_UserSettingsBusinessLayer.getUserSettings();
    }
    
    /**
    * @description : This method update user locale and language from portal. Added for US1165.
    */
    @RemoteAction
    public static object updateSettings(string inputvalue)    {
        return CHL_UserSettingsBusinessLayer.updateUserSettings(inputvalue);
    }
    
     /**
    * @description : This method returns the app config parameters
    */
    @RemoteAction
    public static Object getAppConfig(String inputValue){
        AppConfig app = new AppConfig();
        AppNameSpace appNs = new AppNameSpace();
        UserSession usrSession = new UserSession();
        UserName usrName = new UserName();
        
        appNs.primary = CSM_Util.getNamespace();
        appNs.ext = CSM_Util.nameSpacePrefix21;
        appNs.quote = CHL_Util.quoteExtnNameSpace; //ServiceSourceQ
        
        app.ns = appNs;
        app.entitlements = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
        app.currentQuarter = CHL_Util.getCurrentQuarter();
        app.currentYear = CHL_Util.getCurrentYear();
        app.locale = CHL_UserSettingsBusinessLayer.getCurrentUserLocale(); 
        app.language = CHL_UserSettingsBusinessLayer.getCurrentUserLanguage();
        app.useCookies = CHL_Util.currentUserDetails[0].CHL_Use_Cookies_for_Channel__c;
        app.privayPolicyUrl = (String)CSM_Admin__c.getOrgDefaults().CHL_Privacy_Policy_URL__c;
        app.userCurrency = CHL_UserSettingsBusinessLayer.getCurrentUserCurrency();
        app.dateFormat = CSM_Util.getLocaleDateMap().get(app.locale.id);
        app.reports = Boolean.valueOf(CHL_Util.isDownloadable);
        app.multiCurrency = UserInfo.isMultiCurrencyOrganization();
        app.analytics = new CHL_AnalyticsWrapper();
        
        usrSession.timeout = CHL_Util.fetchUserSessionPeriod();
        usrSession.warnTime = 300;   
        usrSession.logoutUrl = Site.getPathPrefix()+'/secur/logout.jsp';
        app.session = usrSession;
        
        usrName.fname = Userinfo.getFirstName()==null?'':Userinfo.getFirstName();
        usrName.lname = Userinfo.getLastName();
        app.user = usrName;
        app.urlPrefix = Site.getPathPrefix();
        
        //For Client-Side Labels
        app.lang = getLabelStructure();
        system.debug('APP.LANG : '+app.lang);
        return app;
     }
     
     private static CHL_ClientLabelsWrapper.lang getLabelStructure() {
        
        CHL_ClientLabelsWrapper.lang langObj = new CHL_ClientLabelsWrapper.lang();
        
        CHL_ClientLabelsWrapper.common comStrings = new CHL_ClientLabelsWrapper.common();
        CHL_ClientLabelsWrapper.navbar nav = new CHL_ClientLabelsWrapper.navbar();
        CHL_ClientLabelsWrapper.oppDetails oppdet = new CHL_ClientLabelsWrapper.oppDetails();
        CHL_ClientLabelsWrapper.reports rep = new CHL_ClientLabelsWrapper.reports(); 
        CHL_ClientLabelsWrapper.grid grid = new CHL_ClientLabelsWrapper.grid();
        CHL_ClientLabelsWrapper.accountDetails accdet = new CHL_ClientLabelsWrapper.accountDetails();
        CHL_ClientLabelsWrapper.fileAttachment fileatt = new CHL_ClientLabelsWrapper.fileAttachment();
        CHL_ClientLabelsWrapper.requestDetails reqDet = new CHL_ClientLabelsWrapper.requestDetails();
        CHL_ClientLabelsWrapper.notes notes = new CHL_ClientLabelsWrapper.notes();
        CHL_ClientLabelsWrapper.requests reqs = new CHL_ClientLabelsWrapper.requests();
        CHL_ClientLabelsWrapper.settings settings = new CHL_ClientLabelsWrapper.settings();
        CHL_ClientLabelsWrapper.opps opps = new CHL_ClientLabelsWrapper.opps();
        CHL_ClientLabelsWrapper.session session = new CHL_ClientLabelsWrapper.session();
        CHL_ClientLabelsWrapper.overview overview = new CHL_ClientLabelsWrapper.overview();
        CHL_ClientLabelsWrapper.helpLinks helpLinks = new CHL_ClientLabelsWrapper.helpLinks();
        CHL_ClientLabelsWrapper.searchResults searchResults = new CHL_ClientLabelsWrapper.searchResults();
        CHL_ClientLabelsWrapper.queryBuilder queryBuilder=new CHL_ClientLabelsWrapper.queryBuilder();
        CHL_ClientLabelsWrapper.datePicker datePicker=new CHL_ClientLabelsWrapper.datePicker();
        CHL_ClientLabelsWrapper.privacy  privacy = new CHL_ClientLabelsWrapper.privacy();
        
        comStrings.CHL_SEARCH = Label.CHL_LBL_SEARCH;
        comStrings.CHL_NO_RECORDS=Label.CHL_LBL_NO_MATCHING_RECORDS;
        comStrings.CHL_GENERIC_ERROR=Label.CHL_LBL_GENERIC_ERROR;
        comStrings.CHL_HEAP_ERROR=Label.CHL_LBL_HEAP_ERROR;
        comStrings.CHL_SALES_REQUEST=Label.CHL_LBL_SALES_REQ;
        comStrings.CHL_RESULTS_LIMIT_EXCEEDED=Label.CHL_LBL_RESULTS_LIMIT_EXCEEDED;
        comStrings.CHL_SEL_OR_SEARCH=Label.CHL_LBL_SEL_OR_SEARCH;
        
        helpLinks.CHL_EXPAND_ALL = Label.CHL_LBL_EXPAND_ALL;
        helpLinks.CHL_COLLAPSE_ALL = Label.CHL_LBL_COLLAPSE_ALL;
        helpLinks.CHL_VIEW_TITLE = Label.CHL_LBL_HELPFUL_LINKS;
        helpLinks.CHL_SEARCH_LINKS = Label.CHL_LBL_SEARCH_LINKS;
        
        nav.CHL_OPPS = Label.CHL_COMMUNITY_OPPORTUNITIES;
        nav.CHL_LOGOUT = Label.CHL_LBL_LOGOUT;
        nav.CHL_REPORTS = Label.CHL_LBL_REPORTS;
        nav.CHL_REQUESTS = Label.CHL_LBL_REQUESTS;
        nav.CHL_SEARCH_ACCOUNTS = Label.CHL_LBL_SEARCHACCOUNTS;
        nav.CHL_LOCATION_SETTINGS = Label.CHL_LBL_LOCATION_SETTINGS;        
        nav.CHL_OVERVIEW = Label.CHL_OVERVIEW;
        nav.CHL_HELP_LINKS = Label.CHL_LBL_HELPFUL_LINKS;
        
        oppdet.CHL_DETAILS = Label.CHL_LBL_DETAILS;
        oppdet.CHL_QUOTES = Label.CHL_LBL_QUOTES;
        oppdet.CHL_RENEWALS = Label.CHL_LBL_RENEWALS;
        oppdet.CHL_CONTACTS = Label.CHL_LBL_CONTACTS;
        oppdet.CHL_ON = Label.CHL_LBL_ON;
        oppdet.CHL_QUOTE_UPDATED = Label.CHL_LBL_QUOTE_UPDATE_SUCCESSFULLY;
        oppdet.CHL_NOTES = Label.CHL_LBL_HISTORY_TEXT;
        oppdet.CHL_OPP_NAME = Label.CHL_LBL_OPP_NAME;//Schema.SobjectType.CHL_Partner_Opportunity__c.fields.Name.label;
        oppdet.CHL_REQUESTS = Label.CHL_LBL_REQUESTS;
        oppdet.CHL_CREATE_REQUEST = Label.CHL_LBL_CREATE_REQUEST;
        
        rep.CHL_REPORTS = Label.CHL_LBL_REPORTS;
        rep.CHL_SEL_REPORT = Label.CHL_LBL_SEL_REPORT;
        
        grid.CHL_NEXT = Label.CHL_LBL_NEXT;
        grid.CHL_ITEMS_PER_PAGE = Label.CHL_LBL_ITEMS_PER_PAGE;
        grid.CHL_PAGE = Label.CHL_LBL_PAGE;
        grid.CHL_PREVIOUS = Label.CHL_LBL_PREVIOUS;
        grid.CHL_OF = Label.CHL_LBL_OF;
        grid.CHL_EDIT_STATUS = Label.CHL_LBL_EDIT_STATUS;
        grid.CHL_NEW_REQUEST = Label.CHL_LBL_NEW_REQUEST;
        grid.CHL_EXPORT_ALL_AS_CSV=Label.CHL_LBL_EXPORT_ALL_DATA_CSV;
        grid.CHL_EXPORT_ALL_AS_PDF=Label.CHL_LBL_EXPORT_ALL_DATA_PDF;
        grid.CHL_EXPORT_VISIBLE_AS_CSV=Label.CHL_LBL_EXPORT_CSV;
        grid.CHL_EXPORT_VISIBLE_AS_PDF=Label.CHL_LBL_EXPORT_PDF;
        
        accdet.CHL_EDIT = Label.CHL_LBL_EDIT;
        accdet.CHL_OPPS = Label.CHL_COMMUNITY_OPPORTUNITIES;
        accdet.CHL_REQUESTS = Label.CHL_LBL_REQUESTS;
        accdet.CHL_ASSETS = Label.CHL_LBL_ASSETS;
        accdet.CHL_CONTACTS = Label.CHL_LBL_CONTACTS;        
        accdet.CHL_CONTRACTS = Label.CHL_LBL_CONTRACTS;      
        accdet.CHL_DETAILS = Label.CHL_LBL_DETAILS;
        accdet.CHL_ACCOUNT_NAME = Schema.SobjectType.Account.fields.Name.label;
        
        fileatt.CHL_UPLOADING = Label.CHL_LBL_UPLOADING;
        fileatt.CHL_UPLOAD = Label.CHL_LBL_UPLOAD;
        fileatt.CHL_TOO_MANY_FILES = Label.CHL_LBL_TOO_MANY_FILES;
        fileatt.CHL_CANCEL = Label.CSM_LBL_CANCEL;
        fileatt.CHL_FILE_TOO_BIG = Label.CHL_LBL_FILE_TOO_BIG;
        fileatt.CHL_DROP_HERE = Label.CHL_LBL_DROP_FILES;
        
        reqDet.CHL_ATTACHMENTS = Label.CHL_ATTACHMENTS;
        reqDet.CHL_SEARCH = Label.CHL_LBL_SEARCH_TEXT;
        reqDet.CHL_SEND = Label.CHL_LBL_SEND;
        reqDet.CHL_ATTACH_FILES = Label.CHL_LBL_ATTACH_FILES;
        reqDet.CHL_CHARACTERS_REMAINING = Label.CHL_LBL_CHARACTERS_REMAINING;
        reqDet.CHL_NOTES = Label.CHL_LBL_NOTES_TEXT;
        reqDet.CHL_DETAILS = Label.CHL_LBL_DETAILS;
        reqDet.CHL_REQUEST = Label.CHL_LBL_REQUEST;
        reqDet.CHL_CASE_NUMBER = Schema.SobjectType.Case.fields.CASENUMBER.label;
        
        notes.CHL_SEND = Label.CHL_LBL_SEND;
        notes.CHL_NOTE_SIGNATURE = Label.CHL_LBL_NOTE_SIGNATURE;
        notes.CHL_CHAR_REMAINING = Label.CHL_LBL_CHAR_REMAINING;
        
        reqs.CHL_PRIORITY = Schema.SobjectType.Case.fields.Priority.label;
        reqs.CHL_SEARCH_REQUESTS = Label.CHL_LBL_SEARCH_REQUESTS;
        reqs.CHL_SUBJECT = Schema.SobjectType.Case.fields.Subject.label;
        reqs.CHL_NEW_REQUEST = Label.CHL_LBL_NEW_REQUEST;
        reqs.CHL_SUBJECT_REQUIRED = Label.CHL_LBL_SUBJECT_REQUIRED;
        reqs.CHL_SEL_REQUEST_TYPE = Label.CHL_LBL_SEL_REQUEST_TYPE;
        reqs.CHL_ACCOUNT = Label.CHL_Account;
        reqs.CHL_REQUESTS = Label.CHL_LBL_REQUESTS;
        reqs.CHL_ACCOUNT_REQUIRED = Label.CHL_LBL_ACCOUNT_REQUIRED;
        reqs.CHL_REQUEST_TYPE = Label.CHL_LBL_REQUEST_TYPE;
        reqs.CHL_SEL_PRIORITY = Label.CHL_LBL_SEL_PRIORITY;
        reqs.CHL_MESSAGE = Label.CHL_LBL_MESSAGE;
        reqs.CHL_SELECT = Label.CSM_LBL_SELECT;
        reqs.CHL_ATTACHMENT = Label.CHL_LBL_ATTACHMENT;
        reqs.CHL_RELATED_TO = Label.CSM_LBL_RELATEDTO;
        reqs.CHL_DROP_FILES = Label.CHL_LBL_DROP_FILES;
        reqs.CHL_SEARCH_ACCOUNTS = Label.CHL_LBL_SEARCHACCOUNTS;
        reqs.CHL_TOO_MANY_FILES = Label.CHL_LBL_TOO_MANY_FILES;
        reqs.CHL_SUBMIT = Label.CHL_LBL_SUBMIT;
        reqs.CHL_REQUEST_CREATED = Label.CHL_LBL_REQUEST_CREATED;
        reqs.CHL_CREATING_REQUEST = Label.CHL_LBL_CREATING_REQUEST;
        reqs.CHL_UPLOAD_ERROR = Label.CHL_LBL_UPLOAD_ERROR;
        reqs.CHL_CANCEL = Label.CSM_LBL_CANCEL;
        reqs.CHL_SEARCH = Label.CHL_LBL_SEARCH;
        
        settings.CHL_SEL_LOCALE = Label.CHL_LBL_SEL_LOCALE;
        settings.CHL_LOCALE = Label.CHL_LBL_LOCALE;
        settings.CHL_SUBMIT = Label.CHL_LBL_SUBMIT;
        settings.CHL_SEL_LANGUAGE = Label.CHL_LBL_SEL_LANGUAGE;
        settings.CHL_CANCEL = Label.CSM_LBL_CANCEL;
        settings.CHL_LANGUAGE = Label.CHL_LBL_LANGUAGE;        
        settings.CHL_SAVING = Label.CHL_LBL_SAVING;
        settings.CHL_LOCATION_SETTINGS = Label.CHL_LBL_LOCATION_SETTINGS;  
        settings.CHL_CURRENCY = Label.CHL_LBL_CURRENCY; 
        settings.CHL_SEL_CURRENCY=Label.CHL_LBL_SEL_CURRENCY;    
        
        opps.CHL_NO_CHANGE = Label.CHL_LBL_NO_CHANGE;
        opps.CHL_DISTRIBUTOR_REP = Label.CHL_LBL_DISTRIBUTOR_REP; 
        opps.CHL_NEW_STATUS = Label.CHL_LBL_NEW_STATUS; 
        opps.CHL_RESELLER_REP = Label.CHL_LBL_RESELLER_REP; 
        opps.CHL_CANCEL = Label.CSM_LBL_CANCEL; 
        opps.CHL_CLOSE_DATE = Schema.SobjectType.Opportunity.fields.CloseDate.label;
        opps.CHL_UPDATE_NO_CHANGE = Label.CHL_LBL_UPDATE_NO_CHANGE; 
        opps.CHL_PROBABILITY = Label.CHL_LBL_MONITOR_FIELD_PROBABILITY;
        opps.CHL_UPDATE = Label.CHL_LBL_UPDATE; 
        opps.CHL_SALES_STAGE = Label.CHL_LBL_MONITOR_FIELD_SALES_STAGE; 
        opps.CHL_OPPS_SAVED = Label.CHL_LBL_OPPS_SAVED; 
        opps.CHL_SEL_OR_SEARCH = Label.CHL_LBL_SEL_OR_SEARCH; 
        opps.CHL_OPP_SAVED = Label.CHL_LBL_OPP_SAVED; 
        opps.CHL_UPDATE_OPPS = Label.CHL_LBL_Update_Opps; 
        opps.CHL_OPP_STATUS_UPDATED = Label.CHL_LBL_OPP_STATUS_UPDATED; 
        opps.CHL_EDIT_SELECTED = Label.CHL_LBL_EDIT_SELECTED; 
        opps.CHL_DATE_PICKER_CLOSE = Label.CHL_LBL_CLOSE; 
        opps.CHL_SEARCH_OPPS = Label.CHL_LBL_SEARCH_OPPS; 
        opps.CHL_EDIT = Label.CHL_LBL_EDIT; 
        opps.CHL_SEL_OPP_TYPE = Label.CHL_LBL_SEL_OPP_TYPE; 
        opps.CHL_SEL_QUARTER = Label.CHL_LBL_SEL_QUARTER; 
        opps.CHL_SEL_YEAR = Label.CHL_LBL_SEL_YEAR; 
        opps.CHL_OPPS = Label.CHL_COMMUNITY_OPPORTUNITIES; 
        opps.CHL_CHOOSE = Label.CHL_Choose;
        opps.CHL_SEL_OR_SEARCH=Label.CHL_LBL_SEL_OR_SEARCH;
        
        session.CHL_SECOND = Label.CHL_LBL_SECOND; 
        session.CHL_HOURS = Label.CHL_LBL_HOURS;
        session.CHL_HOUR = Label.CHL_LBL_HOUR;
        session.CHL_WARNING_TOTAL_TIME = Label.CHL_LBL_WARNING_TOTAL_TIME;
        session.CHL_MINUTES = Label.CHL_LBL_MINUTES;
        session.CHL_WARNING_REMAINING_TIME = Label.CHL_LBL_WARNING_REMAINING_TIME;
        session.CHL_MINUTE = Label.CHL_LBL_MINUTE;
        session.CHL_KEEP_ALIVE = Label.CHL_LBL_KEEP_ALIVE;
        session.CHL_SECONDS = Label.CHL_LBL_SECONDS;
        session.CHL_LOGOUT = Label.CHL_LBL_LOGOUT;
        session.CHL_SESSION_EXPIRING = Label.CHL_LBL_SESSION_EXPIRING;        
        
        overview.CHL_EXPIRED_OPPS = Label.CHL_LBL_EXPIRED_OPPS;
        overview.CHL_EXPIRATION_YEAR = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_FY__c.label;
        overview.CHL_COUNTRY = Label.CHL_LBL_COUNTRY;
        overview.CHL_EXPIRATION_QUARTER = Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_EQ__c.label;
        overview.CHL_RESELLER_REP = Label.CHL_LBL_RESELLER_REP;
        overview.CHL_OPP_PIPELINE = Label.CHL_LBL_OPP_PIPELINE;
        overview.CHL_DISTRIBUTOR_REP = Label.CHL_LBL_DISTRIBUTOR_REP;
        overview.CHL_START_NEW_REQUEST = Label.CHL_LBL_START_NEW_REQUEST;
        overview.CHL_SELECT_OR_SEARCH = Label.CHL_LBL_SEL_OR_SEARCH;
        overview.CHL_SEE_COMPLETED_REQUESTS = Label.CHL_LBL_SEE_COMPLETED_REQUESTS;
        overview.CHL_GO = Label.REN_LBL_GO;
        overview.CHL_UPDATE_OPPS_STATUS = Label.CHL_LBL_UPDATE_OPPS_STATUS;
        overview.CHL_OPPS_NEED_UPDATE = Label.CHL_LBL_OPPS_NEED_UPDATE;
        overview.CHL_SEE_NEW_OPPS = Label.CHL_LBL_SEE_NEW_OPPS;
        overview.CHL_OPPS_UPDATED = Label.CHL_LBL_OPPS_UPDATED;
        overview.CHL_WELCOME = Label.CHL_LBL_WELCOME;
        
        searchResults.CHL_SEARCH_RESULTS = Label.CHL_LBL_SEARCH_RESULTS_FOR;    
        searchResults.CHL_NO_MATCH = Label.CHL_LBL_NO_MATCHING_RESULTS;
        searchResults.CHL_MORE = Label.CHL_LBL_VIEW_MORE;
        searchResults.CHL_TOP_RESULTS = Label.CHL_LBL_TOP_RESULTS;
        searchResults.CHL_ACCOUNTS = Label.CHL_COMMUNITY_ACCOUNTS;
        searchResults.CHL_OPPS = Label.CHL_COMMUNITY_OPPORTUNITIES;
        searchResults.CHL_QUOTES = Label.CHL_LBL_QUOTES;
        searchResults.CHL_CONTACTS = Label.CHL_LBL_CONTACTS;
        searchResults.CHL_REQUESTS = Label.CHL_LBL_REQUESTS;
        searchResults.CHL_ASSETS = Label.CHL_LBL_ASSETS;
        searchResults.CHL_CONTRACTS = Label.CHL_LBL_CONTRACTS;
        searchResults.CHL_RENEWALS = Label.CHL_LBL_RENEWALS;
        searchResults.CHL_HELP_LINKS = Label.CHL_LBL_HELPFUL_LINKS;
        
        queryBuilder.CHL_PREDEFINED=Label.CHL_LBL_PREDEFINED;
        queryBuilder.CHL_CREATE_QUERY=Label.CHL_LBL_CREATE;
        queryBuilder.CHL_RUN=Label.CHL_LBL_RUN;
        queryBuilder.CHL_SAVE=Label.CHL_LBL_SAVE;
        queryBuilder.CHL_DELETE=Label.CHL_LBL_DELETE;
        queryBuilder.CHL_SAVE_AS=Label.CHL_LBL_SAVE_AS;
        queryBuilder.CHL_AND=Label.CHL_LBL_AND;
        queryBuilder.CHL_ADD_MORE=Label.CHL_LBL_ADD_MORE;
        queryBuilder.CHL_ADD_LOGIC=Label.CHL_LBL_ADD_LOGIC;
        queryBuilder.CHL_REMOVE_LOGIC=Label.CHL_LBL_REMOVE_LOGIC;
        queryBuilder.CHL_SELECT_QUERY=Label.CHL_LBL_SELECT;
        queryBuilder.CHL_CHOOSE = Label.CHL_Choose;
        queryBuilder.CHL_YES = Label.CSM_LBL_YES;
        queryBuilder.CHL_NO = Label.CSM_LBL_NO;
        queryBuilder.CHL_QUERY_SAVED = Label.CHL_LBL_QUERY_SAVED;
        queryBuilder.CHL_LOGIC_PLACEHOLDER = Label.CHL_LBL_QUERY_LOGIC;
        queryBuilder.CHL_LOGIC_INDEX_ERROR = Label.CHL_LBL_LOGIC_INDEX_ERROR;
        queryBuilder.CHL_LOGIC_SYNTAX_ERROR = Label.CHL_LBL_LOGIC_SYNTAX_ERROR;
        queryBuilder.CHL_ADD_FILTER_TOOLTIP = Label.CHL_LBL_ADD_FILTER_TOOLTIP;
        queryBuilder.CHL_REMOVE_FILTER_TOOLTIP = Label.CHL_LBL_REMOVE_FILTER_TOOLTIP;
        queryBuilder.CHL_AND_CAPS =Label.CHL_LBL_AND;
        queryBuilder.CHL_IS_EQUAL_TO=Label.CHL_LBL_IS_EQUAL_TO;
        queryBuilder.CHL_EQUALS=Label.CHL_LBL_EQUALS;
        queryBuilder.CHL_NOT_EQUAL_TO=Label.CHL_LBL_NOT_EQUAL_TO;
        queryBuilder.CHL_IS_GREATER_THAN=Label.CHL_LBL_IS_GREATER_THAN;
        queryBuilder.CHL_IS_LESS_THAN=Label.CHL_LBL_IS_LESS_THAN;
        queryBuilder.CHL_IS_BETWEEN=Label.CHL_LBL_IS_BETWEEN;
        queryBuilder.CHL_IS_BEFORE=Label.CHL_LBL_IS_BEFORE;
        queryBuilder.CHL_IS_AFTER=Label.CHL_LBL_IS_AFTER;
        queryBuilder.CHL_SYSTEM_CAPS=Label.CHL_LBL_SYSTEM;
        queryBuilder.CHL_CUSTOM_CAPS=Label.CHL_LBL_CUSTOM;
        queryBuilder.CHL_UNSAVED_QUERY=Label.CHL_LBL_UNSAVED_QUERY;
        queryBuilder.CHL_SEARCH_OR_SELECT=Label.CHL_LBL_SEL_OR_SEARCH;
        queryBuilder.CHL_IS_NOT_IN=Label.CHL_LBL_IS_NOT_IN;
        queryBuilder.CHL_CONTAINS=Label.REN_LBL_CONTAINS;
        queryBuilder.CHL_YEAR=Label.CHL_LBL_YEAR;
        queryBuilder.CHL_QUARTER=Label.CHL_LBL_QUARTER;
        queryBuilder.CHL_NEEDS_UPDATE=Label.CHL_LBL_NEEDS_UPDATE;
        queryBuilder.CHL_CREATED_AT=Label.CHL_LBL_CREATED_AT;
        queryBuilder.CHL_HAS_QUOTE=Label.CHL_LBL_HAS_QUOTE;
        queryBuilder.CHL_EXPIRATION_DATE=Label.CHL_LBL_EXPIRATION_DATE;
        queryBuilder.CHL_PARTNER_ACCOUNT_1=Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_Partner_Account_1__c.label;
        queryBuilder.CHL_PARTNER_ACCOUNT_2=Schema.SobjectType.CHL_Partner_Opportunity__c.fields.CHL_Partner_Account_2__c.label;
        queryBuilder.CHL_PARTNER_ACCOUNT_CONTACT_1=Label.CHL_LBL_PA_CONTACT1;
        queryBuilder.CHL_PARTNER_ACCOUNT_CONTACT_2=Label.CHL_LBL_PA_CONTACT2;
        queryBuilder.CHL_SALES_STAGE=Label.CHL_LBL_MONITOR_FIELD_SALES_STAGE; 
        queryBuilder.CHL_ACCOUNT=Label.CHL_Account;
        queryBuilder.CHL_CLOSE_DATE=Schema.SobjectType.Opportunity.fields.CloseDate.label;
              
        datePicker.CHL_CLOSE=Label.CHL_LBL_CLOSE;
        datePicker.CHL_CLEAR=Label.CSM_LBL_CLEAR;
        datePicker.CHL_CURRENT=Label.CSM_LBL_TODAY;
        
        privacy.CHL_COOKIE_NOTICE=Label.CHL_COOKIE_NOTICE;
        privacy.CHL_PRIVACY_NOTICE_TEXT_BEFORE_LINK=Label.CHL_PRIVACY_NOTICE_TEXT_BEFORE_LINK;
        privacy.CHL_PRIVACY_NOTICE_LINK_TEXT=Label.CHL_PRIVACY_NOTICE_LINK_TEXT;
        privacy.CHL_PRIVACY_NOTICE_TEXT_AFTER_LINK='.';
        privacy.CHL_PRIVACY_ACCEPT=Label.CHL_PRIVACY_ACCEPT;
        privacy.CHL_PRIVACY_DECLINE=Label.CHL_PRIVACY_DECLINE;
        
        
        langObj.navbar = nav;
        langObj.oppDetails = oppdet;
        langObj.reports = rep;
        langObj.grid = grid;
        langObj.accountDetails = accdet;
        langObj.fileAttachment = fileatt;
        langObj.requestDetails = reqDet;
        langObj.notes = notes;
        langObj.requests = reqs;
        langObj.settings = settings;
        langObj.opps = opps;
        langObj.session = session;
        langObj.overview = overview;
        langObj.common = comStrings;
        langObj.helpLinks = helpLinks;
        langObj.searchResults = searchResults;
        langObj.queryBuilder=queryBuilder;
        langObj.datePicker=datePicker;
        langObj.privacy=privacy;
        
        return langObj;
     }
    
    /**
    * @description : This method populates the New Request form .
    *               Added for US852.
    */
    @RemoteAction
    public static Object getRequestOptions(String inputValue){
        return CHL_PartnerOverviewUtil.getFieldOptions();
    }
    
    /**
    * @description : This method inserts new request i.e case
    *               Added for US852.
    */
    @RemoteAction
    public static Object saveRequest (String newRequest){
        return CHL_PartnerOverviewUtil.saveRequest(newRequest);
    }
    
    /**
    * @description : This method takes input as search string and returns the matched Object Details .
    *               Objects supported : Account,Asset,Service Contract,Quote
    *               Returns id,value
    *               Added for US852.
    */
    @RemoteAction
    public static Object searchRelated(String srch){
        return CHL_PartnerOverviewUtil.searchRelatedTo(srch);
    }
    
    @RemoteAction
    public static Object pulse(String inputValue){
        String data = '{ "success":true }';        
        return data;
    }
     
    public with Sharing class QuoteInputStructure {
        public String oppId;
    }
    
    public class AccountWrapper {
        public String id {get;set;}
        public String AccountNumber {get;set;}
        public String Name {get;set;}
    
        public AccountWrapper(Account accObj) {
            this.id = accObj.Id;
            this.AccountNumber = accObj.AccountNumber;
            this.Name = accObj.Name;
        }
    }

    public with Sharing class AccountSearch {
        public String q;
        public String ot;
    }
    
    public with Sharing class AppNameSpace{
      public String primary;
      public String ext;
      public String quote;
    }
    
    public with Sharing class UserSession{
      public Integer timeout;
      public Integer warnTime;
      public String logoutUrl;
    }
    
    public with Sharing class AppConfig{
       public AppNameSpace ns;
       public String dateFormat;
       public boolean entitlements;
       public boolean reports;
       public CHL_CurrentQuarter currentQuarter;
       public CHL_CurrentYear currentYear;
       public UserSession session;
       public UserName user;
       public string urlPrefix;
       public CHL_Locale locale; 
       public CHL_Language language;
       public CHL_Currency userCurrency;
       public CHL_ClientLabelsWrapper.lang lang;
       public boolean multiCurrency;
       public CHL_AnalyticsWrapper analytics;
       public boolean useCookies;
       public String privayPolicyUrl;
    }
    
    public with Sharing class UserName{
        public string fname;
        public string lname;
    }
    
    
  
}