/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.28.2014
* @description    CSM_FocusCategoriesDataAccess class related to saving Data to Salesforce  
*/
public with sharing class CSM_FocusCategoriesDataAccess {
    
    public List<CSM_FocusCategoryWrapper> focusCategoryList {get; private set;}
    public Map<Id, CSM_Focus_Category__c> focusCategoryMap {get; private set;}
    private Map<String, CSM_FocusCategoryWrapper> focusCategoryWrapperMap {get; set;}
    public String byOwnerId {get; set;}
    public Boolean getInActive {get; set;}
    public Set<String> existingListViews {get; private set;}
    public String currencyHeaderToSum {get; set;}
    public Map<String, CSM_FocusCategoryWrapper> focusCategoryWrapperViewMap {get; set;}
    public Map<String, Map<String, CSM_FocusCategoryWrapper>> focusCategoryColumnActiveMap {get; private set;}
    private Map<String, CSM_FocusCategoryWrapper> focusCategoryActiveMap {get; set;}
    private Map<String, List<SObject>> mapViewInfo {get; set;}
    private Map<String, List<String>> columnListMap {get; set;}
    public List<Schema.FieldSetMember> taskMandatoryFields;
    
    public CSM_UserPreferencesFilterWrapper userPreferences {
        get; 
        set{
            if (value!=null && userPreferences==null){
                userPreferences = value;
            }
        }
    }
    public CSM_FocusCategoriesDataAccess() {
        taskMandatoryFields = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> tmpFieldsList = SObjectType.Task.FieldSets.CSM_CompleteDismiss_Popup.getFields();
        for(Schema.FieldSetMember f : tmpFieldsList) {
            if (f.DBRequired && String.valueOf(f.Type) != 'ID'){
                taskMandatoryFields.add(f);
            }
        }
    }     
    
    /**
    * @description populateWrapperClass adds all the values from the FocusCategory 
    *
    * @return null 
    */
    public void populateWrapperClass() {
        populateWrapperClass(null, null, null);
    }   
    
    /**
    * @description populateWrapperClass adds all the values from the FocusCategory 
    *
    * @return null 
    */
    public void populateWrapperClass(String fcColumnId, String fcId, Set<String> columnKeySet) {
        
        List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_FC_VIEW_ORDER, CSM_Constants.OBJ_FCV, 
            CSM_Constants.OBJ_FCC, CSM_Constants.OBJ_FCG_ISACTIVE};
            
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_FC, fcFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<String> fcvFieldList = new List<String>{CSM_Constants.OBJ_FCV_OBJECT_NAME, CSM_Constants.OBJ_FCV_DISPLAY_NAME,
            CSM_Constants.OBJ_FCV_SOQL, CSM_Constants.OBJ_FCV_COLUMNS, CSM_Constants.OBJ_FCV_CRIT};
          
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_FCV, fcvFieldList, CSM_Constants.DML_OPERATION_READ);
       
        // Check if there are no access list is empty (i.e. user has the access)
       
            PageReference pageRefTemp = Page.CSM_TaskList;
            String taskRetURL = pageRefTemp.getURL() + CSM_Constants.PARAM_VIEWID_URL; 
            pageRefTemp = Page.CSM_FocusCategoriesFullList;
            String acctOpptyRetURL = pageRefTemp.getURL() + CSM_Constants.PARAM_VIEWID_URL; 
            
            Integer recLimit = CSM_AdminDataAccess.getFocusCategoryRecLimit();
            Integer recMaxLimit = CSM_AdminDataAccess.getFocusCategoryMaxRecLimit();
            // Initialize the variables
            userPreferences = new CSM_UserPreferencesFilterWrapper();
            focusCategoryList = new List<CSM_FocusCategoryWrapper>();
            focusCategoryWrapperMap = new Map<String, CSM_FocusCategoryWrapper>();
            existingListViews = new Set<String>();
            mapViewInfo = new Map<String, List<SObject>>();
            focusCategoryColumnActiveMap = new Map<String, Map<String, CSM_FocusCategoryWrapper>>();
            focusCategoryActiveMap = new Map<String, CSM_FocusCategoryWrapper>();
            focusCategoryWrapperViewMap = new Map<String, CSM_FocusCategoryWrapper>(); 
            focusCategoryMap = new Map<Id, CSM_Focus_Category__c>();
            Map<Id, Integer> soqlResultCountMap = new Map<Id, Integer>();
            Map<String, List<SObject>> mapViewTaskInfo = new Map<String, List<SObject>>();
            boolean isShowInActive = false;
            List<SObject> listSObjectCalc = new List<SObject>();
            List<String> soqlList = new List<String>();
            // Get the category map
            if (fcId!=null){
                focusCategoryMap = new Map<Id, CSM_Focus_Category__c> ([SELECT Id, Name, CSM_Focus_Category_Column__c, CSM_View_Order__c, 
                                                                        CSM_Focus_Category_View__c, CSM_Focus_Category_View__r.CSM_Object_Name__c, CSM_IsActive__c,
                                                                        CSM_Focus_Category_View__r.CSM_Display_Name__c, CSM_Focus_Category_View__r.CSM_SOQL__c,CSM_Focus_Category_View__r.CSM_Filter_By_Owner_Value__c,
                                                                        CSM_Focus_Category_View__r.CSM_Columns__c, CSM_Focus_Category_View__r.CSM_Criteria__c,CSM_Focus_Category_View__r.CSM_Currency_Header__c                
                                                                        FROM CSM_Focus_Category__c where CSM_Focus_Category_Column__r.csm_focus_category_group__r.csm_isactive__c = true
                                                                        and Id =: fcId LIMIT 1]);                                                      
            } else {
                if (fcColumnId != null) {
                    focusCategoryMap = new Map<Id, CSM_Focus_Category__c> ([SELECT Id, Name, CSM_Focus_Category_Column__c, CSM_View_Order__c, 
                                                                            CSM_Focus_Category_View__c, CSM_Focus_Category_View__r.CSM_Object_Name__c, CSM_IsActive__c,
                                                                            CSM_Focus_Category_View__r.CSM_Display_Name__c, CSM_Focus_Category_View__r.CSM_SOQL__c,CSM_Focus_Category_View__r.CSM_Filter_By_Owner_Value__c,
                                                                            CSM_Focus_Category_View__r.CSM_Columns__c, CSM_Focus_Category_View__r.CSM_Criteria__c,CSM_Focus_Category_View__r.CSM_Currency_Header__c                
                                                                            FROM CSM_Focus_Category__c  where CSM_Focus_Category_Column__r.csm_focus_category_group__r.csm_isactive__c = true
                                                                            and CSM_Focus_Category_Column__c =: fcColumnId LIMIT 30]);
                } else {
                    if (columnKeySet!= null){
                        focusCategoryMap = new Map<Id, CSM_Focus_Category__c> ([SELECT Id, Name, CSM_Focus_Category_Column__c, CSM_View_Order__c, 
                                                                                CSM_Focus_Category_View__c, CSM_Focus_Category_View__r.CSM_Object_Name__c, CSM_IsActive__c,
                                                                                CSM_Focus_Category_View__r.CSM_Display_Name__c, CSM_Focus_Category_View__r.CSM_SOQL__c,CSM_Focus_Category_View__r.CSM_Filter_By_Owner_Value__c,
                                                                                CSM_Focus_Category_View__r.CSM_Columns__c, CSM_Focus_Category_View__r.CSM_Criteria__c,CSM_Focus_Category_View__r.CSM_Currency_Header__c                
                                                                                FROM CSM_Focus_Category__c  where CSM_Focus_Category_Column__r.csm_focus_category_group__r.csm_isactive__c = true 
                                                                                and CSM_Focus_Category_Column__c IN: columnKeySet 
                                                                                ORDER BY CSM_Focus_Category_Column__c, CSM_View_Order__c LIMIT 30]); 
                    }else {
                        focusCategoryMap = new Map<Id, CSM_Focus_Category__c> ([SELECT Id, Name, CSM_Focus_Category_Column__c, CSM_View_Order__c, 
                                                                                CSM_Focus_Category_View__c, CSM_Focus_Category_View__r.CSM_Object_Name__c, CSM_IsActive__c,
                                                                                CSM_Focus_Category_View__r.CSM_Display_Name__c, CSM_Focus_Category_View__r.CSM_SOQL__c,CSM_Focus_Category_View__r.CSM_Filter_By_Owner_Value__c,
                                                                                CSM_Focus_Category_View__r.CSM_Columns__c, CSM_Focus_Category_View__r.CSM_Criteria__c,CSM_Focus_Category_View__r.CSM_Currency_Header__c               
                                                                                FROM CSM_Focus_Category__c  where CSM_Focus_Category_Column__r.csm_focus_category_group__r.csm_isactive__c = true
                                                                                ORDER BY CSM_Focus_Category_Column__c, CSM_View_Order__c LIMIT 30]);
                    }
                } 
            }
            
            // Get the focus category map and check if it is not empty
            if (focusCategoryMap!=null && !focusCategoryMap.isEmpty()) {
                Integer soqlCount = 0;
                Set<String> viewIds = new Set<String>(); 
                for (CSM_Focus_Category__c fc : focusCategoryMap.values()) {
                    viewIds.add(fc.CSM_Focus_Category_View__c);
                }
                
                Map<Id, CSM_Focus_Category_View__c> mapFCView = new Map<Id, CSM_Focus_Category_View__c>([SELECT Id, (SELECT RLM_Field_Display_Name__c, RLM_Field_Name__c, RLM_Operator__c, 
                                                                                                        RLM_Values__c, RLM_Date_Literal_String__c, RLM_Date_Value__c, RLM_DateTime_Value__c, RLM_Date_Literal_Number__c 
                                                                                                        FROM CSMFocusCategoriesViewCriteria__r), 
                                                                                                        (SELECT CSM_Display_Name__c, CSM_Object_Field_Name__c, CSM_Object_Field_Type__c 
                                                                                                        From CSMFocusCategoryView__r) 
                                                                                                        FROM CSM_Focus_Category_View__c WHERE Id IN :viewIds LIMIT 1000]);
                for (CSM_Focus_Category__c fc : focusCategoryMap.values()) {
                    soqlList = new List<String>();
                    Boolean hasSOQLError = false;
                    soqlCount ++;
                    // Create a new focus category wrapper
                    CSM_FocusCategoryWrapper fcW = new CSM_FocusCategoryWrapper();
                    fcW.CategoryId = fc.Id;
                    fcW.CategoryOrder = String.valueOf(fc.CSM_View_Order__c);
                    fcW.CategoryActive = fc.CSM_IsActive__c;
                    fcw.fcvFilter = fc.CSM_Focus_Category_View__r.CSM_Filter_By_Owner_Value__c;                    
                    fcW.ColumnId = fc.CSM_Focus_Category_Column__c;
                    
                    fcW.CategoryViewId = fc.CSM_Focus_Category_View__c;
                    fcW.CategoryObjType = fc.CSM_Focus_Category_View__r.CSM_Object_Name__c;
                    if(CSM_Constants.OBJ_CONTRACT.equalsIgnoreCase(fcW.CategoryObjType)){
                        fcW.linkName = CSM_Constants.CONTRACT_NUMBER;
                    }
                    else{
                        fcW.linkName = CSM_Constants.NAME;
                    }
                    fcW.CategoryDisplayName = fc.CSM_Focus_Category_View__r.CSM_Display_Name__c;
                    fcW.SOQL = fc.CSM_Focus_Category_View__r.CSM_SOQL__c;
                    fcW.Columns = fc.CSM_Focus_Category_View__r.CSM_Columns__c;
                    fcW.Criteria = fc.CSM_Focus_Category_View__r.CSM_Criteria__c;
                    fcW.headerCurrencyFieldName = fc.CSM_Focus_Category_View__r.CSM_Currency_Header__c;
              
                    if (!String.isBlank(fcW.headerCurrencyFieldName)){
                        String currencyName = UserInfo.getDefaultCurrency();
                        if(UserInfo.isMultiCurrencyOrganization())
                        {
                            fcW.headerCurrencyCode = currencyName+' ';
                        }
                        else
                        {
                            fcW.headerCurrencyCode=currencyName+' ';//CSM_Util.convertCurrencyNameToSymbol(currencyName);
                        }
                    }

                    fcW.UniqueId = CSM_Util.NewGuid();
                    
                    System.debug('columnKeySet - '+columnKeySet);
                    if (columnKeySet!=null){
                        //MF Removed
                        /*if (byOwnerId != null) {
                            fcW.soql += ' AND ownerId = \''+byOwnerId +'\'';
                        }*/
                        
                        //append filter values to URL
                        String fieldValue = null;
                        if(userPreferences.attrFieldUserId != null){
                            fieldValue = userPreferences.attrFieldUserId;
                        }
                        else{
                            if(userPreferences.attrFieldType == CSM_Constants.TYPE_DATE){
                                 fieldValue = String.valueOf(userPreferences.attrFieldDateValue);
                            }
                            else{
                                fieldValue = userPreferences.attrFieldValue;
                            }
                        }
                        String filter = '&';
                        filter += CSM_Constants.USER_PREF_OBJECT_TYPE + '=' + userPreferences.attObjectType;
                        filter += '&' + CSM_Constants.USER_PREF_FIELD_NAME + '=' + userPreferences.attrFieldName;
                        filter += '&' + CSM_Constants.USER_PREF_FIELD_TYPE + '=' + userPreferences.attrFieldType;
                        filter += '&' + CSM_Constants.USER_PREF_FIELD_VALUE + '=' + fieldValue;
                            
                        
                        // Check if the Map contains object type  
                        // if not we need to create the View info
                        system.debug('userPreferences.attObjectType>>>>'+userPreferences.attObjectType);
                        system.debug('userPreferences.attrFieldName>>>>'+userPreferences.attrFieldName);
                        system.debug('userPreferences.attrFieldType>>>>'+userPreferences.attrFieldType);
                        if (fcW.CategoryObjType!=null){
                            if(!String.isEmpty(userPreferences.attObjectType) && !String.isEmpty(userPreferences.attrFieldName) && !String.isEmpty(userPreferences.attrFieldType)){
                                if(fcW.CategoryObjType!=CSM_Constants.OBJ_TYPE_TASK){
                                    fcW.ViewURL = acctOpptyRetURL+fcW.CategoryViewId+filter;                                
                                }else{
                                    fcW.ViewURL = taskRetURL+fcW.CategoryViewId+filter;                             
                                }

                            }else{
                                if(fcW.CategoryObjType!=CSM_Constants.OBJ_TYPE_TASK){
                                    fcW.ViewURL = acctOpptyRetURL+fcW.CategoryViewId;                               
                                }else{
                                    fcW.ViewURL = taskRetURL+fcW.CategoryViewId;
                                }
                                
                            }
                            
                            if (Test.isRunningTest()){
                                fcW.soql = 'SELECT Id, name,AnnualRevenue, BillingCity, BillingState FROM '+fcW.CategoryObjType ; 
                            }
                            
                            if (!mapViewInfo.containsKey(fcW.CategoryViewId)){
                                try { 
                                    String soql = fcW.SOQL;
                                    system.debug('soql >>>>>>'+soql);
                                    //MF 
                                    //IF if filter is not null or ''
                                  //  system.debug('filterWrapper in soql build $$ ' + fcW.CategoryViewId + ' ' + userPreferences);
                                    if(!String.isEmpty(userPreferences.attrFieldName) && !String.isEmpty(userPreferences.attrFieldType))
                                    {
                                        //Verify if and or where. 
                                        if(fcW.CategoryObjType != CSM_Constants.OBJ_TYPE_TASK && userPreferences.attObjectType != null && !userPreferences.attObjectType.equalsIgnoreCase('Task') ){
                                            if(soql.toUpperCase().contains('ORDER BY')) {
                                                soqlList = soql.split('Order By');
                                                soql = soqlList[0];
                                                if(soql.toUpperCase().contains('WHERE') )
                                                {
                                                    soql += ' AND ';
                                                }
                                                else {
                                                    soql += ' WHERE ';
                                                }
                                            } else if(soql.toUpperCase().contains('WHERE') )
                                            {
                                                soql += ' AND ';
                                            }
                                            else {
                                                soql += ' WHERE ';
                                            }
                                        }
                                        
                                        if (userPreferences.attObjectType != null && userPreferences.attObjectType.equalsIgnoreCase('Success Plan') && fcW.CategoryObjType != CSM_Constants.OBJ_TYPE_TASK) {
                                            Set<Id> accountIdsList = new Set<Id>();
                                            if (userPreferences.attrFieldName != null) {
                                                //List<CSM_Account_Plan__c> accountPlans = CSM_AccountPlanDataAccess.getFilterBasedAccountPlans(userPreferences.attrFieldName, userPreferences.attrFieldUserId);
                                                /*
                                                if (accountPlans != null && !accountPlans.isEmpty()) {
                                                    for (CSM_Account_Plan__c accountPlan : accountPlans) {
                                                        if (!accountIdsList.contains(accountPlan.CSM_AccountId__c)) {
                                                            accountIdsList.add(accountPlan.CSM_AccountId__c);
                                                        }
                                                    }
                                                }*/
                                                Set<Id> localSet = userPreferences.attrSPAccountIdsList;
                                                
                                                if (fcW.CategoryObjType == CSM_Constants.OBJ_TYPE_OPPORTUNITY || fcW.CategoryObjType == CSM_Constants.OBJ_CASE) {
                                                    soql += 'AccountId  IN: localSet';
                                                }
                                                else if (fcW.CategoryObjType == CSM_Constants.OBJ_TYPE_ACCOUNT_PLAN) {
                                                    soql += 'CSM_AccountId__c  IN: localSet';
                                                }
                                                else if (fcW.CategoryObjType == CSM_Constants.OBJ_TYPE_ACCOUNT) {
                                                    soql += 'Id  IN: localSet';
                                                }
                                            }
                                                                                        
                                        }else if (userPreferences.attObjectType != null && userPreferences.attObjectType.equalsIgnoreCase('Task') ) {
                                            if(fcW.CategoryObjType == CSM_Constants.OBJ_TYPE_TASK){
                                                if(soql.toUpperCase().contains('ORDER BY')) {
                                                	soqlList = soql.split('Order By');
                                                	soql = soqlList[0];
                                                    if(soql.toUpperCase().contains('WHERE') )
                                                    {
                                                        soql += ' AND ';
                                                    }
                                                    else {
                                                        soql += ' WHERE ';
                                                    }
                                                } else if(soql.toUpperCase().contains('WHERE') )
                                                    {
                                                        soql += ' AND ';
                                                    }
                                                    else {
                                                        soql += ' WHERE ';
                                                    }
                                                soql += userPreferences.attrFieldName; 
                                                    
                                                if(userPreferences.attrFieldType != null && userPreferences.attrFieldType != ''){
                                                    if(userPreferences.attrFieldtype == CSM_Constants.TYPE_REFERENCE)
                                                    {
                                                        if(userPreferences.attrFieldUserId != null && userPreferences.attrFieldUserId != ''){
                                                            soql +=  ' = ' + ' \'' + userPreferences.attrFieldUserId + '\' ';
                                                        }
                                                        else
                                                        {
                                                            soql += ' = null ';
                                                        }
                                                    }
                                                }                                           
                                            }
                                        }else if (userPreferences.attObjectType != null && userPreferences.attObjectType.equalsIgnoreCase('Account') && fcW.CategoryObjType != CSM_Constants.OBJ_TYPE_TASK) { 
                                            if (fcW.CategoryObjType == CSM_Constants.OBJ_TYPE_OPPORTUNITY || fcW.CategoryObjType == CSM_Constants.OBJ_CASE)
                                            {
                                                soql += ' Account.';
                                            }                                           
                                            soql += userPreferences.attrFieldName; 
                                                
                                            if(userPreferences.attrFieldType != null && userPreferences.attrFieldType != ''){
                                                //If type is lookup, use the UserId field.
                                                if(userPreferences.attrFieldtype == CSM_Constants.TYPE_REFERENCE)
                                                {
                                                    if(userPreferences.attrFieldUserId != null && userPreferences.attrFieldUserId != ''){
                                                        soql +=  ' = ' + ' \'' + userPreferences.attrFieldUserId + '\' ';
                                                    }
                                                    else
                                                    {
                                                        soql += ' = null ';
                                                    }
                                                }
                                                else if(userPreferences.attrFieldType == CSM_Constants.TYPE_DATE){ 
                                                        if(userPreferences.attrFieldDateValue != null){
                                                            String dateString = String.valueOf(userPreferences.attrFieldDateValue);
                                                            soql += ' = ' +  dateString ;
                                                        }
                                                        else{
                                                            soql += ' = null ' ;
                                                        }
                                                }
                                                else if(userPreferences.attrFieldType == CSM_Constants.TYPE_DOUBLE 
                                                    || userPreferences.attrFieldType == CSM_Constants.TYPE_INTEGER
                                                    || userPreferences.attrFieldType == CSM_Constants.TYPE_CURRENCY
                                                    || userPreferences.attrFieldType == CSM_Constants.TYPE_PERCENT ){
                                                        if(userPreferences.attrFieldValue != null && !String.isEmpty(userPreferences.attrFieldValue)){
                                                            soql += ' = ' +  userPreferences.attrFieldValue ;                                                       
                                                        }
                                                        else{
                                                            soql += ' = null ';
                                                        }
                                                }
                                                else {
                                                    if(userPreferences.attrFieldValue != null && !String.isEmpty(userPreferences.attrFieldValue)){
                                                        soql += ' = ' + ' \'' + userPreferences.attrFieldValue + '\' ';
                                                    }
                                                    else{
                                                        soql += ' = null ';
                                                    }
                                                }
                                            }
                                        }
                                        // end of else for success plan v account
                                            
                                    }
                                    if(soqlList != null && !soqlList.isEmpty() && soqlList.size() == 2) {
                                        soql += ' ORDER BY ' + soqlList[1];
                                    }
                                   soql = CSM_Util.processMyFCVSOQL(soql, fcw.fcvFilter); 
                                   soql  += ' limit '+String.valueOf(recMaxLimit);
                                   //append the mandatory Task Parameters to the query
                                   if(fcW.CategoryObjType == CSM_Constants.OBJ_TYPE_TASK && taskMandatoryFields != null && !taskMandatoryFields.isEmpty()) {
                                        String mandatoryFieldStrings = ' ';
                                        for(Schema.FieldSetMember f : taskMandatoryFields) {
                                            if (!soql.toLowerCase().contains(f.FieldPath.toLowerCase())){
                                                mandatoryFieldStrings += String.valueOf(f.FieldPath) + ',';
                                            }
                                        }
                                        //get the query substring till 'select' and append the mandatory fields string                                      
                                        soql = soql.substring(0, 6) + mandatoryFieldStrings + soql.substring(6);
                                    }                                   
                                   
                                    system.debug('soql fc$::' + soql);
                                    
                                    fcW.listSObject = database.query(soql);
                                    Set<Id> recIds = new Set<Id>();
                                    listSObjectCalc = fcW.listSObject;
                                    soqlResultCountMap.put(fcW.CategoryViewId, fcW.listSObject.size());
                                    List<SObject> objList = new List<SObject>();
                                    
                                    Integer iCounter = 1;
                                    for (SObject sobj : fcW.listSObject){
                                        recIds.add(sobj.id);
                                        if (iCounter<=recLimit){
                                            objList.add(sObj);  
                                        }
                                        iCounter++;
                                    }
                                    
                                    if(fcW.CategoryObjType == CSM_Constants.OBJ_TYPE_TASK) {
                                        fcW.sObjectHasEditAccess = CSM_AccessController.hasEditRecordAccess(recIds,userinfo.getUserId());
                                    }
                                    // Get the controller for an object type
                                    mapViewInfo.put(fcW.CategoryViewId, objList);
                                } catch (Exception ex){
                                    hasSOQLError = true;
                                }
                            }
                            System.debug('fcW.soql - '+fcW.soql + ' fcW.CategoryViewId - '+ fcW.CategoryViewId);
                            if (hasSOQLError == false && mapViewInfo.containsKey(fcW.CategoryViewId)){
                                
                                if (soqlResultCountMap!=null && soqlResultCountMap.containsKey(fcW.CategoryViewId)){
                                    fcW.CategoryCount = soqlResultCountMap.get(fcW.CategoryViewId);
                                }
                                // Get the list view rows
                                fcW.listSObject = mapViewInfo.get(fcW.CategoryViewId); 
                               // listSObjectCalc = fcW.listSObject;   
                                System.debug('fcW.CategoryViewId - ' + fcW.CategoryViewId + ' - fcW.listSObject - '+fcW.listSObject);
                                    
                                // Get the category count for display purposes
                                //fcW.CategoryCount = mapViewInfo.get(fcW.CategoryViewId).getResultSize();
                                if (fcW.Criteria!=null && fcW.Criteria.length() > 0){
                                    fcW.CriteriaJSON = JSON.serialize(mapFCView.get(fcW.CategoryViewId).CSMFocusCategoriesViewCriteria__r);
                                    fcW.CriteriaObjList = new List<CSM_Focus_Category_View_Criteria__c>();
                                    for (CSM_Focus_Category_View_Criteria__c fcCrit: mapFCView.get(fcW.CategoryViewId).CSMFocusCategoriesViewCriteria__r)
                                    {
                                        if (fcCrit.RLM_Date_Literal_String__c != null)
                                        {
                                            if (fcCrit.RLM_Date_Literal_String__c.startsWith('N_'))
                                            {
                                                fcCrit.RLM_Date_Literal_String__c = fcCrit.RLM_Date_Literal_String__c.replace('N_', fcCrit.RLM_Date_Literal_Number__c + ' ');
                                            }
                                            else if (fcCrit.RLM_Date_Literal_String__c.contains('_N_'))
                                            {
                                                fcCrit.RLM_Date_Literal_String__c = fcCrit.RLM_Date_Literal_String__c.replace('_N_', ' ' + fcCrit.RLM_Date_Literal_Number__c + ' ');
                                            }
                                        }
                                        fcW.CriteriaObjList.add(fcCrit);
                                    }
                                    
                                }           
                                String namespace = CSM_Util.getNamespace();
                                Map<String, CSM_FocusCategoryWrapper.colNameForAPI> nameForAPI = new Map<String, CSM_FocusCategoryWrapper.colNameForAPI>();                 
                                Map<String, CSM_FocusCategoryWrapper.colNameForAPI> nameForREF = new Map<String, CSM_FocusCategoryWrapper.colNameForAPI>(); 
                                Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                                Schema.SObjectType sobjType = globalDescribe.get(fcW.CategoryObjType);
                                if(sobjType == null){
                                    sobjType = globalDescribe.get(namespace + fcW.CategoryObjType);
                                }
                                Map<String, Schema.SObjectField> objFieldInfo = sobjType.getDescribe().fields.getMap();
                                String refRelation = '';
                                if (fcW.listSObject!=null && !fcW.listSObject.isEmpty()) {
                                        
                                    if (fcW.Columns!=null){
                                        for (CSM_Focus_Category_View_Column__c rcV : mapFCView.get(fcW.CategoryViewId).CSMFocusCategoryView__r){
                                            CSM_FocusCategoryWrapper.colNameForAPI nForAPI = new CSM_FocusCategoryWrapper.colNameForAPI();
                                            CSM_FocusCategoryWrapper.colNameForAPI nForREF = new CSM_FocusCategoryWrapper.colNameForAPI();
                                            
                                            if(rcV.CSM_Object_Field_Type__c == CSM_Constants.TYPE_REFERENCE)
                                            {
                                                String fieldName = '';
                                                /* if(String.isNotBlank(rcV.CSM_Object_Field_Name__c) 
                                                    && rcV.CSM_Object_Field_Name__c.startsWith(nameSpace)){
                                                    fieldName = rcV.CSM_Object_Field_Name__c.removeStart(nameSpace);
                                                }else{
                                                    fieldName = rcV.CSM_Object_Field_Name__c;
                                                } */
                                                if(String.isNotBlank(rcV.CSM_Object_Field_Name__c)) {
                                                    fieldName = rcV.CSM_Object_Field_Name__c;
                                                }
                                                
                                                refRelation = CSM_Util.findNameForLookup(fieldName, objFieldInfo);
                                                nForREF.apiName = refRelation.trim().toLowerCase();
                                                nForREF.displayName = rcV.CSM_Display_Name__c;
                                                nForREF.fieldType = rcV.CSM_Object_Field_Type__c;
                                                nForREF.refFieldId = rcV.CSM_Object_Field_Name__c.trim().toLowerCase();
                                                nameForREF.put(nForREF.apiName, nForREF);
                                            }else{
                                                nForAPI.apiName = rcV.CSM_Object_Field_Name__c.trim().toLowerCase();
                                                nForAPI.displayName = rcV.CSM_Display_Name__c;
                                                nForAPI.fieldType = rcV.CSM_Object_Field_Type__c;
                                                nameForAPI.put(nForAPI.apiName, nForAPI);
                                            }
                                            
                                        }
                                    }
                                }
                                         
                                List<CSM_FocusCategoryWrapper.colNameForAPI> columnList = new List<CSM_FocusCategoryWrapper.colNameForAPI>();
                                List<CSM_FocusCategoryWrapper.colNameForAPI> columnLimitList = new List<CSM_FocusCategoryWrapper.colNameForAPI>();
                                
                                Integer i = 0;
                                if (fcW.Columns!=null){
                                    System.debug('VVV - nameForAPI - '+nameForAPI);
                                    
                                    for (String column : fcW.Columns.split(',')) {
                                        if (column!=null && column!='null' && 
                                            column.trim().toLowerCase()!=CSM_Constants.OBJ_IG_ID.toLowerCase() && 
                                            column.trim().toLowerCase()!=CSM_Constants.OBJ_IG_NAME.toLowerCase()){
                                            String colName = column.toLowerCase().trim();
                                            CSM_FocusCategoryWrapper.colNameForAPI cNameForAPI = new CSM_FocusCategoryWrapper.colNameForAPI();
                                            cNameForAPI.apiName = colName;
                                            cNameForAPI.displayName = colName;
                                            cNameForAPI.fieldType = '';
                                            //cNameForAPI.refFieldId = '';
                                            System.debug('ZZZ ColName - '+colName);
                                            System.debug('ZZZ ColName - '+nameForAPI.containsKey(colName));
                                            if (nameForAPI.containsKey(colName))
                                            {
                                                cNameForAPI.displayName = nameForAPI.get(colName).displayName;
                                                cNameForAPI.fieldType = nameForAPI.get(colName).fieldType;
                                                cNameForAPI.refFieldId = nameForAPI.get(colName).refFieldId;
                                            }else if(nameForREF.containsKey(colName)){
                                                cNameForAPI.displayName = nameForREF.get(colName).displayName;
                                                cNameForAPI.fieldType = nameForREF.get(colName).fieldType;
                                                cNameForAPI.lookUpField = CSM_Constants.TYPE_LOOKUP;
                                                cNameForAPI.refFieldId = nameForREF.get(colName).refFieldId;
                                                }
                                            
                                            columnList.add(cNameForAPI);
                                            if (i<2){
                                                columnLimitList.add(cNameForAPI);
                                            }
                                            i++;
                                            
                                        }
                                    }
                                    fcW.ColumnNameList = columnList;
                                    fcW.ColumnNameLimitList = columnLimitList;
                                    
                                } 
                            }
                        } else {
                            try {
                                if (!mapViewTaskInfo.containsKey(fcW.CategoryViewId)){
                                    String soql = fcW.SOQL + ' LIMIT '+String.valueOf(recMaxLimit);
                                    // Let the task list as it is
                                    fcW.listSObject = database.query(soql);
                                    listSObjectCalc = fcW.listSObject;
                                    soqlResultCountMap.put(fcW.CategoryViewId, fcW.listSObject.size());
                                    List<SObject> objList = new List<SObject>();
                                    Integer iCounter = 1;
                                    for (SObject sobj : fcW.listSObject){
                                        
                                        if (iCounter<=recLimit){
                                            objList.add(sObj);  
                                        }
                                        iCounter++;
                                    }
                                    // Get the controller for an object type
                                    mapViewTaskInfo.put(fcW.CategoryViewId, objList);
                                } 
                                if (mapViewTaskInfo.containsKey(fcW.CategoryViewId)){
                                    if(!String.isEmpty(userPreferences.attObjectType) && !String.isEmpty(userPreferences.attrFieldName) && !String.isEmpty(userPreferences.attrFieldType) 
                                        && (!String.isEmpty(userPreferences.attrFieldUserId) || userPreferences.attrFieldDateValue != null || !String.isEmpty(userPreferences.attrFieldValue))){
                                        fcW.ViewURL = taskRetURL+fcW.CategoryViewId+filter;
                                    }else{
                                        fcW.ViewURL = taskRetURL+fcW.CategoryViewId;
                                    }
                                    if (soqlResultCountMap!=null && soqlResultCountMap.containsKey(fcW.CategoryViewId)){
                                        fcW.CategoryCount = soqlResultCountMap.get(fcW.CategoryViewId);
                                    }   
                                    //fcW.listSObject = mapViewTaskInfo.get(fcW.CategoryViewId);
                                }
                            }  catch (Exception ex) {
                                hasSOQLError = true;
                            }
                        }
                       
                        isShowInactive = (this.userPreferences.showInactive==null?false:this.userPreferences.showInactive);
                       
                        // Get the category column active map:do changes here.
                        
                        if (hasSOQLError == false && 
                           // ((this.getInActive == false && fcW.CategoryActive == true) ||
                           ((isShowInActive == false && fcW.CategoryActive == true) ||
                            isShowInActive == true)) {
                            
                            if (focusCategoryColumnActiveMap.containsKey(fcW.ColumnId)) {
                                focusCategoryActiveMap = focusCategoryColumnActiveMap.get(fcW.ColumnId);
                            } else {
                                focusCategoryActiveMap = new Map<String, CSM_FocusCategoryWrapper>();
                            }
                            focusCategoryActiveMap.put(fcW.CategoryId, fcW);
                            focusCategoryColumnActiveMap.put(fcW.ColumnId, focusCategoryActiveMap);
                        }
                    }                   
                    fcW.totalCurrencyAmount = 0;
                    if(!String.isBlank(fcW.headerCurrencyFieldName) && listSObjectCalc != null && !listSObjectCalc.isEmpty()){
                        //Count for max categories
                        for(sObject s: listSObjectCalc){
                            Double c;
                            try{
                                //String fcvObjName = CSM_AccessController.findObjectNameFromRecordIdPrefix((String)s.get('Id'));
                                //system.debug('iiiiiiiiii  -' + (String)s.get('Id'));
                                //system.debug('kkkkkkkkk  -' + fcW.headerCurrencyFieldName);                                                               
                                //system.debug('lllllllllll  -' + fcvObjName);
                                //if(CSM_AccessController.hasField(fcvObjName,fcW.headerCurrencyFieldName)){
                                    c = (Double)s.get(fcW.headerCurrencyFieldName);                             
                                //}
                            }catch(System.TypeException ste){
                                String formattedValue = (String)s.get(fcW.headerCurrencyFieldName);
                                if(String.isNotBlank(formattedValue)){

                                    // remove currency sign
                                    if(UserInfo.isMultiCurrencyOrganization()){
                                        formattedValue = formattedValue.right(formattedValue.length() - 4);
                                    }else{
                                        formattedValue = formattedValue.right(formattedValue.length() - 1);
                                    }

                                    // remove special chars
                                    //formattedValue = formattedValue.replace(',', '');
                                    formattedValue = formattedValue.replaceAll('[^0-9.]', '');  //DE1772                                
                                    
                                    //system.debug('formattedValue $$$$$$$ '+formattedValue);
                                    c = Double.valueOf(formattedValue);
                                }
                            }
                            if(c != null){
                                fcW.totalCurrencyAmount += c;
                            }
                        }
                    }
                    focusCategoryList.add(fcW);
                    // Set rest of the focus categories         
                    existingListViews.add(fcW.CategoryViewId);
                    focusCategoryWrapperMap.put(fcW.UniqueId, fcW);
                }
                focusCategoryList.sort();
            } 
    }
    
    /**
    * @description createFocusCategory - creates new Focus Category Wrapper
    *
    * @return null 
    */
    public void createFocusCategory(String focusCategoryName, String focusCategoryObjType, String focusCategoryColumnId, String focusCategoryViewId) {
        Integer rowNum = 1;
        if (!focusCategoryList.isEmpty()){
            focusCategoryList.sort();
            rowNum = Integer.valueOf(focusCategoryList[focusCategoryList.size()-1].CategoryOrder)+1;
        }
        
       if(!String.isBlank(focusCategoryName))
        {
        CSM_FocusCategoryWrapper fcW = new CSM_FocusCategoryWrapper();
        fcW.CategoryObjType = focusCategoryObjType;
        fcW.ColumnId = focusCategoryColumnId;
        fcW.CategoryViewId = focusCategoryViewId;
        fcW.CategoryActive = true;
        fcW.CategoryOrder = String.valueOf(rowNum);
        fcW.UniqueId = CSM_Util.NewGuid();
        fcW.CategoryDisplayName = focusCategoryName;
        existingListViews.add(focusCategoryViewId);
        focusCategoryWrapperMap.put(fcW.UniqueId, fcW);
        focusCategoryList.add(fcW);
        }
    
    }
    
    /**
    * @description saveAndRetrieveId - Save and retrieve Id for newly created focus Category 
    *
    * @return String - Category Id returned 
    */
    public String saveAndRetrieveId(String focusCategoryUniqueId) {
        String fcId = null;
        if (focusCategoryWrapperMap.containsKey(focusCategoryUniqueId)) {
            CSM_FocusCategoryWrapper fcW = focusCategoryWrapperMap.get(focusCategoryUniqueId);
            if (fcW.CategoryId!=null){
                fcId = fcW.CategoryId;
            } else {
                CSM_Focus_Category__c fc = createFC(fcW);
                List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_FC_CATEGORY_COLUMN, CSM_Constants.OBJ_FC_FOCUS_CATEGORY_VIEW,
                        CSM_Constants.OBJ_FC_ISACTIVE, CSM_Constants.OBJ_FC_NAME, CSM_Constants.OBJ_FC_VIEW_ORDER};
                
                CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_FC, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
                
                    upsert fc;
                    fcId = fc.Id;
                    focusCategoryMap.put(fc.Id, fc);
            }
        }
        return fcId;
    }
    
    /**
    * @description createFC - Create a new focus category 
    *
    * @return CSM_Focus_Category__c based on create/edit function  
    */
    private CSM_Focus_Category__c createFC(CSM_FocusCategoryWrapper fcW) {
        CSM_Focus_Category__c fc;
        
        // Check if the focus category is new or an update
        if (focusCategoryMap.containsKey(fcW.CategoryId)){
            fc = focusCategoryMap.get(fcW.CategoryId);
        } else {
            fc = new CSM_Focus_Category__c();
            fc.CSM_Focus_Category_Column__c = fcW.ColumnId;
            fc.CSM_Focus_Category_View__c = fcW.CategoryViewId;
        }
        fc.CSM_IsActive__c = fcW.CategoryActive;
        fc.Name = fcW.CategoryDisplayName;
        fc.CSM_View_Order__c = 0;
        
        if (fcW.CategoryOrder!=null){
            fc.CSM_View_Order__c = Integer.valueOf(fcW.CategoryOrder);
        }
        
        return fc;          
    }
    
    /**
    * @description deleteFocusCategory - Deletes the focus category from the column
    * return Success or Failure
    */
    
    public boolean deleteFocusCategory(String focusCategoryColumnId, String categoryId) {
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_FC, null, CSM_Constants.DML_OPERATION_DELETE);
        
        List<CSM_Focus_Category__c> focusCategories = [SELECT Id FROM CSM_Focus_Category__c 
                                WHERE CSM_Focus_Category_Column__c =:focusCategoryColumnId and Id=:categoryId LIMIT 1];
                                
        if (focusCategories != null && !focusCategories.isEmpty()) {
            delete focusCategories;
            return true;
        }
        return false;
    }
    
    /**
    * @description saveFocusCategory - Save all the focus categories 
    *
    * @return null
    */
    public void saveFocusCategory() {
        // Check is the field list have access for the current context (user)
        List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_FC_ISACTIVE, CSM_Constants.OBJ_FC_NAME, CSM_Constants.OBJ_FC_VIEW_ORDER};
                        
        CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_FC, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        // Check for FLS and object check 
        
            // Save focus categories and re-populate the wrapper class
            String focusColumnId;
            if (focusCategoryList!=null && focusCategoryList.size()>0){
                List<CSM_Focus_Category__c> fcToUpdate = new List<CSM_Focus_Category__c>();
                for (CSM_FocusCategoryWrapper fcW: focusCategoryList){
                    CSM_Focus_Category__c fc = createFC(fcW);
                    focusColumnId = fc.CSM_Focus_Category_Column__c;
                    fcToUpdate.add(fc);             
                }  
                upsert fcToUpdate;
                
                // Repopulate the focus column again to get latest values
                populateWrapperClass(focusColumnId, null, null);
            }
        
    }
    
    /**
    * 
    * @description setCon Get the list views based on object changes
    * 
    * @return List<SelectOption> 
    * 
    */
    public List<SelectOption> setCon(String typeofObject) {
        
        List<SelectOption> fcViewList = new List<SelectOption>();
        Map<String, Map<String, String>> objListViewMap = getViewMap();
        if (objListViewMap!=null && !objListViewMap.isEmpty() && objListViewMap.containsKey(typeofObject)){
            for (String viewId : objListViewMap.get(typeofObject).keySet()){
                SelectOption so = new SelectOption(viewId, objListViewMap.get(typeofObject).get(viewId));
                fcViewList.add(so);
            }
        }
        return fcViewList;
    }

    /**
    * @description getViewMap - Create selectoptions for Category Groups    
    *
    * @return Map<String, String> - return Map of list views 
    */  
    private Map<String, Map<String, String>> getViewMap() {
        
        // Use MetaService for List Views
        Map<String, Map<String, String>> fcViewMap = CSM_FocusCategoryViewDataAccess.populateViewInformation();
        return fcViewMap;
    }

    /**
    * @description getFocusCategoryColumnActiveMap - Create selectoptions for Category Groups   
    *
    * @return CSM_Focus_Category_Group__c - return created focus category select options 
    */
    public Map<String, Map<String, CSM_FocusCategoryWrapper>> getFocusCategoryColumnActiveMap(Set<String> columnKeySet) {
        populateWrapperClass(null, null, columnKeySet);
        return focusCategoryColumnActiveMap;
    }

    public static List<CSM_Focus_Category__c> getAllTaskFCs() 
    {

        List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_FC_FOCUS_CATEGORY_VIEW,CSM_Constants.OBJ_FC_CATEGORY_COLUMN};
        List<String> fcgFieldList = new List<String>{CSM_Constants.OBJ_FCG_ISACTIVE};  
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_FC, fcFieldList, CSM_Constants.DML_OPERATION_READ);
          
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_FCG, fcgFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<CSM_Focus_Category__c> lstFocusCategories;
       
        lstFocusCategories = [select csm_focus_category_View__c from csm_focus_category__c where csm_focus_category_View__c in (select Id from csm_focus_category_view__c where CSM_Object_Name__c = 'Task') and csm_focus_category_column__c in (select id from csm_focus_category_column__c where CSM_Focus_Category_Group__r.CSM_IsActive__c = true) limit 1];
        

        //System.Debug('GroupList - ' + tmpGroups[0].getSObject('CSM_Focus_Category_Column__r').get('CSM_Focus_Category_Group__c'));
        return lstFocusCategories; 
    }
    public static Map<Id,CSM_Focus_Category__c> getFocusCategoryByFCG(String fcgId){
        List<String> fcFieldList =  new List<String>{CSM_Constants.OBJ_FC_FOCUS_CATEGORY_VIEW,CSM_Constants.OBJ_FC_CATEGORY_COLUMN};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_FC, fcFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<CSM_Focus_Category__c> fcList = [select id,CSM_Focus_Category_View__c,CSM_Focus_Category_Column__r.CSM_Display_Name__c  from CSM_Focus_Category__c where CSM_Focus_Category_Column__c  IN (select id from CSM_Focus_Category_Column__c where CSM_Focus_Category_Group__c  = :fcgId)];
        
        Map<Id,CSM_Focus_Category__c> excludeDuplicateMap = new Map<Id,CSM_Focus_Category__c>();
        for(CSM_Focus_Category__c fc :fcList) {
            excludeDuplicateMap.put(fc.CSM_Focus_Category_View__c, fc);
        }
        return excludeDuplicateMap; 
    }
}