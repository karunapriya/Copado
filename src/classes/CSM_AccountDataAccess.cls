public with sharing class CSM_AccountDataAccess
{
    
    public static List<Task> getActiveHistory(Id accountId)
    {
        List<String> taskFieldList = new List<String>{CSM_Constants.OBJ_AH_SUBJECT, CSM_Constants.OBJ_AH_ACTIVITYDATE,
                 CSM_Constants.OBJ_AH_OWNER_ID, CSM_Constants.OBJ_AH_PLAY, CSM_Constants.OBJ_AH_TASK_STATE,
                CSM_Constants.OBJ_AH_COMPLETED_DATE, CSM_Constants.OBJ_AH_PLAY_EXIT_DATE,CSM_Constants.OBJ_T_TYPE};
                   
        String strRecord = '';
        if(CSM_Util.getRecordTypeExists(new Task())){
            strRecord = ',RecordType.Name ';            
        }
      
       CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TASK, taskFieldList, CSM_Constants.DML_OPERATION_READ);
       
            Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_ACTIVITY_HISTORY); 
            //Commented because Activity History does give the RecordType and Type
                       /* return [SELECT 
                      (SELECT Subject, 
                              IsTask, 
                              ActivityDate,
                              EndDateTime,  
                              OwnerId, 
                              Owner.Name,
                              CSM_Play__c, 
                              CSM_Task_State__c,
                              CSM_Completed_Date__c,
                              CSM_Play__r.CSM_Display_Name__c,
                              CSM_Play_Exit_Date__c  
                         FROM ActivityHistories
                        ORDER BY ActivityDate DESC, LastModifiedDate DESC
                        LIMIT :limitVal)
                    FROM Account WHERE Id = :accountId LIMIT 1]; */

                    //String soql = 'SELECT Subject, ActivityDate, OwnerId, Owner.Name, CSM_Play__c, CSM_Task_State__c,CSM_Completed_Date__c,CSM_Play__r.CSM_Display_Name__c,' + str + 
                      //             ' Type,CSM_Play_Exit_Date__c FROM Task WHERE WhatId = :accountId and isClosed = true   ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT :limitVal';
                    String soql = 'SELECT id, What.Type, CSM_Account_Plan__r.CSM_AccountId__c, format(activitydate), subject, whatid, CSM_Account__c, '+
                                    'CSM_Account_Plan__r.CSM_AccountId__r.Name, CSM_SuccessPlan_Play__r.CSM_Play__c, '+
                                    'CSM_Risk_Reason__c, CSM_Account_Plan__c, What.Name, OwnerId, Owner.Name, Status, CSM_Task_State__c, '+ 
                                    'CSM_Play__c, Description, format(CSM_Completed_Date__c), CSM_Play_Task__c, whoid, REN_Opportunity__c, '+'CSM_SuccessPlan_Play__r.CSM_SuccessPlan_Playbook__r.CSM_Playbook__r.CSM_Display_Name__c, '+
                                    'CSM_Play__r.CSM_Display_Name__c, format(CSM_Play_Enter_Date__c), format(CSM_Play_Exit_Date__c), CSM_Play_Status__c,Type '+ strRecord
                           + ' FROM Task '+
                            ' WHERE WhatId = :accountId and isClosed = true ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT :limitVal';
                      
                    List<Task> tmplist;                 
                    tmplist =  Database.query(soql);
                    return tmplist;


                    /*if(CSM_Util.getRecordTypeExists()){
                        return [SELECT 
                                  Subject, 
                                  ActivityDate,
                                  OwnerId, 
                                  Owner.Name,
                                  CSM_Play__c, 
                                  CSM_Task_State__c,
                                  CSM_Completed_Date__c,
                                  CSM_Play__r.CSM_Display_Name__c,
                                  RecordTypeId,
                                  Type,
                                  CSM_Play_Exit_Date__c  
                             FROM Task WHERE WhatId = :accountId and isClosed = true
                             ORDER BY ActivityDate DESC, LastModifiedDate DESC
                            LIMIT :limitVal];

                    }else{
                    
                        return [SELECT 
                                  Subject, 
                                  ActivityDate,
                                  OwnerId, 
                                  Owner.Name,
                                  CSM_Play__c, 
                                  CSM_Task_State__c,
                                  CSM_Completed_Date__c,
                                  CSM_Play__r.CSM_Display_Name__c,
                                  Type,
                                  CSM_Play_Exit_Date__c  
                             FROM Task WHERE WhatId = :accountId and isClosed = true
                             ORDER BY ActivityDate DESC, LastModifiedDate DESC
                            LIMIT :limitVal];
                    }*/
    }
    
    public static List<Account> getDetailFieldSet(String accountId)
    {
        List<String> acctFieldList = new List<String>();
        Id localAcctId = accountId;
        boolean firstField = true;
        String queryString = 'SELECT ';
        String nameSpace = CSM_Util.getNamespace();
        for(Schema.FieldSetMember fld :SObjectType.Account.FieldSets.CSM_Details_Fieldset.getFields()) 
        {
            String fldStr = fld.getFieldPath();
            if (nameSpace!=null && nameSpace.length()>0){
                fldStr = fldStr.replace(nameSpace, '');
            }
            acctFieldList.add(fldStr);
            if (firstField)
            {
                queryString += fld.getFieldPath();
                firstField = false;
            }
            else 
            {
                queryString += ', ' + fld.getFieldPath();
            }
        }
        queryString += ' from Account where Id = :localAcctId LIMIT 1';   
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TYPE_ACCOUNT, acctFieldList, CSM_Constants.DML_OPERATION_READ);
        
        return Database.query(queryString);
    }
        
    public static List<Account> getHealthInformationForAllAccounts()
    { 
        return null;
    }
    
    public static List<Account> getHealthInformationForSpecificAccounts(CSM_UserPreferencesFilterWrapper userPrefWrapper)
    {
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ID, CSM_Constants.OBJ_A_HEALTH_STATUS, CSM_Constants.OBJ_A_LAST_HEALTH_STATUS};
        List<String> accountPlanFieldList = new List<String>{CSM_Constants.OBJ_A_ID, CSM_Constants.OBJ_AP_NAME, CSM_Constants.OBJ_AP_ACTIVE};
                
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TYPE_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_AP, accountPlanFieldList, CSM_Constants.DML_OPERATION_READ);
        
        String dateString = null;
        String queryString = 'SELECT ';     
        
            CSM_Admin__c adminSettings = CSM_AdminDataAccess.getCSMAdminInstance();
            Integer limitCount = 5000;
            if(adminSettings.CSM_Health_Charts_Rec_Limit__c != null)
            {
                limitcount = Integer.valueOf(adminSettings.CSM_Health_Charts_Rec_Limit__c);
            } 
            queryString +=  ' Id, CSM_Last_Health_Status__c, CSM_Health_Status__c, (select id, name, CSM_isActive__c, CSM_DisplayName__c from Success_Plans__r  where CSM_isActive__c = true ) FROM Account ';

            if(userPrefWrapper != null){ 
                if (userPrefWrapper.attObjectType != null && userPrefWrapper.attObjectType.equalsIgnoreCase('Account')) {
                    if(userPrefWrapper.attrFieldDateValue != null){
                        dateString = String.valueOf(userPrefWrapper.attrFieldDateValue);
                    }
                    if(userPrefWrapper.attrFieldName != null || userPrefWrapper.attrFieldName != ''){
                        if(userPrefWrapper.attrFieldValue != null && !String.isEmpty(userPrefWrapper.attrFieldValue)){
                            if(userPrefWrapper.attrFieldValue.equalsIgnoreCase('UserLookupField')){
                                if(userPrefWrapper.attrFieldUserId != null && userPrefWrapper.attrFieldUserId != ''){
                                    queryString += ' WHERE ' + userPrefWrapper.attrFieldName + ' = ' + ' \'' + userPrefWrapper.attrFieldUserId + '\' ';
                                }
                                else{
                                    queryString += ' WHERE ' + userPrefWrapper.attrFieldName + ' = null ';
                                }                               
                            }
                            else { 
                                if(userPrefWrapper.attrFieldType != null){
                                    if(userPrefWrapper.attrFieldType == CSM_Constants.TYPE_DATE){
                                        queryString += ' WHERE ' + userPrefWrapper.attrFieldName + ' = ' +  dateString ;
                                    }
                                    else if(userPrefWrapper.attrFieldType == CSM_Constants.TYPE_DOUBLE 
                                       || userPrefWrapper.attrFieldType == CSM_Constants.TYPE_INTEGER
                                       || userPrefWrapper.attrFieldType == CSM_Constants.TYPE_CURRENCY
                                       || userPrefWrapper.attrFieldType == CSM_Constants.TYPE_PERCENT ){
                                        queryString += ' WHERE ' + userPrefWrapper.attrFieldName + ' = ' +  userPrefWrapper.attrFieldValue ;
                                    }
                                    else if(userPrefWrapper.attrFieldType == CSM_Constants.TYPE_STRING || userPrefWrapper.attrFieldType == CSM_Constants.TYPE_PICKLIST || userPrefWrapper.attrFieldType == CSM_Constants.TYPE_REFERENCE){
                                        queryString += ' WHERE ' + userPrefWrapper.attrFieldName + ' = ' + ' \'' + userPrefWrapper.attrFieldValue + '\' ';
                                    }
                                }
                            }
                        }
                        else if(String.isNotBlank(userPrefWrapper.attrFieldName)){
                            queryString += ' WHERE ' + userPrefWrapper.attrFieldName + ' = null ';
                        }
                    }
                }
                
                else if (userPrefWrapper.attObjectType != null && userPrefWrapper.attObjectType.equalsIgnoreCase('Success Plan')) {
                    
                    //query here to get the SPAccountsIdList rather than depending on the user prefwrapper, later delete it from the wrapper completely
                    Set<Id> accountIdsList = new Set<Id>();
                    
                    if (userPrefWrapper.attrFieldType != null 
                        //&& userPrefWrapper.attrFieldUserId != null
                        && userPrefWrapper.attrFieldName != null) {
                        //List<CSM_Account_Plan__c> accountPlans = CSM_AccountPlanDataAccess.getFilterBasedAccountPlans(userPrefWrapper.attrFieldName, userPrefWrapper.attrFieldUserId);
                        
                        if (userPrefWrapper.attrSPAccountIdsList != null && !userPrefWrapper.attrSPAccountIdsList.isEmpty()) {
                            /*for (CSM_Account_Plan__c accountPlan : accountPlans) {
                                if (!accountIdsList.contains(accountPlan.CSM_AccountId__c)) {
                                    accountIdsList.add(accountPlan.CSM_AccountId__c);
                                }
                            }*/
                            accountIdsList = userPrefWrapper.attrSPAccountIdsList;
                            if (accountIdsList != null && !accountIdsList.isEmpty()) {
                                Set<Id> localSet = accountIdsList;
                                queryString += ' WHERE Id IN  :localSet';
                            }
                            
                            else { 
                                system.debug('no account list found');
                                return new List<Account>();
                            }
                        }
                        else {
                            system.debug('no matching accounts found for Success Plans');
                            return new List<Account>();
                        }                   
                    }                       
                }
            }
            queryString += ' Limit ' + limitcount;
            system.debug('QUERY IS::' + queryString);
            return Database.query(queryString);      
    }
    
    public static List<Account> getAccountsByHealthStatus(String healthStatus)
    {
        return null;
    }
    
    public static List<Account> getAccountsByHealthStatusFilters(String healthStatus, 
                                    String attrFieldName, String attrFieldType, String attrFieldValue, 
                                    String attrObjectType, Set<Id> attrSPAccountIdsList)
    {
        return null;           
    }      
    
    public static List<Account> getAccountsByHealthStatusFilterAttr(String healthStatus, String attrFieldName, String attrFieldType, String attrFieldValue, String attrObjectType)
    {
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ID, CSM_Constants.OBJ_A_NAME, CSM_Constants.OBJ_A_HEALTH_STATUS};
        List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ID, CSM_Constants.OBJ_AP_NAME, CSM_Constants.OBJ_AP_ACTIVE, CSM_Constants.OBJ_AP_DISPLAY_NAME};
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TYPE_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_AP, acctPlanFieldList, CSM_Constants.DML_OPERATION_READ);
        
        String queryString = ' ';
            
              if (attrObjectType != null && attrObjectType.equalsIgnoreCase('Account')) {
                  queryString += 'select id, Name, (select id, name, CSM_isActive__c, CSM_DisplayName__c from Success_Plans__r where CSM_isActive__c = true) from Account where CSM_Health_Status__c = :healthStatus';
                  String filterQuery = buildQueryStringForList(attrFieldName, attrFieldType, attrFieldValue);
                  if(filterQuery != null && filterQuery != ''){
                    queryString += ' AND ' + filterQuery;
                  }
              }
              else if (attrObjectType != null && attrObjectType.equalsIgnoreCase('Success Plan')) {
                Set<Id> accountIdsList = new Set<Id>();

                List<CSM_Account_Plan__c> accountPlans = CSM_AccountPlanDataAccess.getFilterBasedAccountPlans(attrFieldName, attrFieldValue);
                
                if (accountPlans != null && !accountPlans.isEmpty()) {
                    for (CSM_Account_Plan__c accountPlan : accountPlans) {
                        if (!accountIdsList.contains(accountPlan.CSM_AccountId__c)) {
                            accountIdsList.add(accountPlan.CSM_AccountId__c);
                        }
                    }
                    if (accountIdsList != null && !accountIdsList.isEmpty()) {
                        Set<Id> localSet = accountIdsList;
                        queryString += 'select id, Name, (select id, name, CSM_isActive__c, CSM_DisplayName__c from Success_Plans__r where CSM_isActive__c = true) from Account where Id IN  :localSet and CSM_Health_Status__c = :healthStatus';
                    }
                }                   
                
              }
              else if (attrObjectType == null) {
                  queryString += 'select id, Name, (select id, name, CSM_isActive__c, CSM_DisplayName__c from Success_Plans__r where CSM_isActive__c = true) from Account where CSM_Health_Status__c = :healthStatus';
              }
              
              queryString += ' limit 10000 ';
              system.debug('QUERYString::' + queryString);            
              return Database.query(queryString);             
        return null;            
    }
  
    public static List<Account> getAccountsByHealthStatusWithFilter(String healthStatus, String attrFieldName, String attrFieldType, String attrFieldValue){
        
        return null;
    }
    
    public static List<Account> getAccountsByHealthStatusAndDateRange(String healthStatus, Date lowDate, Date highDate)
    {
        return null;
    }
    
    public static List<Account> getAccountsByHealthStatusAndDateRangeWithFilter(String healthStatus, Date lowDate, Date highDate, String attrFieldName, String attrFieldType, String attrFieldValue)
    {
        return null;      
    }

    public static List<Account> getAccountsByHealthStatusAndDateRangeWithFilterAttr(String healthStatus, Date lowDate, Date highDate, String attrFieldName, String attrFieldType, String attrFieldValue, String attrObjectType)
    {
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ID, CSM_Constants.OBJ_A_NAME, CSM_Constants.OBJ_A_HEALTH_STATUS, CSM_Constants.OBJ_A_LAST_HEALTH_STATUS};
        List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ID, CSM_Constants.OBJ_AP_NAME, CSM_Constants.OBJ_AP_ACTIVE, CSM_Constants.OBJ_AP_DISPLAY_NAME};
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TYPE_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
        
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_AP, acctPlanFieldList, CSM_Constants.DML_OPERATION_READ);
                    
        String queryString = ' ';
        Set<Id> accountIdsList = new Set<Id>();
        
        if (attrObjectType != null && attrObjectType.equalsIgnoreCase('Success Plan')) {

            List<CSM_Account_Plan__c> accountPlans = null;
            if (attrFieldName != null && !attrFieldValue.equalsIgnoreCase('UserLookupField')) {
                system.debug('valid values in account Plan');
                accountPlans = CSM_AccountPlanDataAccess.getFilterBasedAccountPlans(attrFieldName, attrFieldValue);             
            }
            
            if (accountPlans != null && !accountPlans.isEmpty()) {
                for (CSM_Account_Plan__c accountPlan : accountPlans) {
                    if (!accountIdsList.contains(accountPlan.CSM_AccountId__c)) {
                        accountIdsList.add(accountPlan.CSM_AccountId__c);
                    }
                }
            }           
        }
                
              
            if(highDate == null && lowDate == null)
            {
                if (attrObjectType != null && attrObjectType.equalsIgnoreCase('Success Plan') 
                        && accountIdsList != null && !accountIdsList.isEmpty()) {
                        Set<Id> localSet = accountIdsList;
                        queryString += ' select id, Name, (select id, name, CSM_isActive__c, CSM_DisplayName__c from Success_Plans__r where CSM_isActive__c = true) from Account where Id IN  :localSet and CSM_Health_Status__c = :healthStatus and CSM_Last_Health_Status__c = null ';                        
                }
                else {              
                    queryString += ' select id, Name, (select id, name, CSM_isActive__c, CSM_DisplayName__c from Success_Plans__r where CSM_isActive__c = true) from Account where CSM_Health_Status__c = :healthStatus and CSM_Last_Health_Status__c = null '; 
                    if (attrFieldName != null && attrFieldType != null) {
                        String filterQuery = buildQueryStringForList(attrFieldName, attrFieldType, attrFieldValue);
                        if(filterQuery != null && filterQuery != ''){
                            queryString += ' AND ' + filterQuery;
                        }
                    }
                }
                queryString += ' limit 10000 ';
                return Database.query(queryString);
            }
            else if (highDate == null)
            {
                if (attrObjectType != null && attrObjectType.equalsIgnoreCase('Success Plan') 
                        && accountIdsList != null && !accountIdsList.isEmpty()) {
                        Set<Id> localSet = accountIdsList;
                        queryString += ' select id, Name, (select id, name, CSM_isActive__c, CSM_DisplayName__c from Success_Plans__r where CSM_isActive__c = true) from Account where Id IN  :localSet and CSM_Health_Status__c = :healthStatus and CSM_Last_Health_Status__c <= :lowDate ';                       
                }
                else {                              
                    queryString += ' select id, Name, (select id, name, CSM_isActive__c, CSM_DisplayName__c from Success_Plans__r where CSM_isActive__c = true) from Account where CSM_Health_Status__c = :healthStatus and CSM_Last_Health_Status__c <= :lowDate ';
                    if (attrFieldName != null && attrFieldType != null) {
                        String filterQuery = buildQueryStringForList(attrFieldName, attrFieldType, attrFieldValue);
                        if(filterQuery != null && filterQuery != ''){
                            queryString += ' AND ' + filterQuery;
                        }
                    }
                }
                queryString += ' limit 10000 ';
                return Database.query(queryString);
            }
            else 
            { 
                if (attrObjectType != null && attrObjectType.equalsIgnoreCase('Success Plan') 
                        && accountIdsList != null && !accountIdsList.isEmpty()) {
                        Set<Id> localSet = accountIdsList;
                        queryString += ' select id, Name, (select id, name, CSM_isActive__c, CSM_DisplayName__c from Success_Plans__r where CSM_isActive__c = true) from Account where Id IN  :localSet and CSM_Health_Status__c = :healthStatus and CSM_Last_Health_Status__c <= :lowDate and CSM_Last_Health_Status__c > :highDate ';                     
                }
                else {                                        
                    queryString += ' select id, Name, (select id, name, CSM_isActive__c, CSM_DisplayName__c from Success_Plans__r where CSM_isActive__c = true) from Account where CSM_Health_Status__c = :healthStatus and CSM_Last_Health_Status__c <= :lowDate and CSM_Last_Health_Status__c > :highDate ';
                    if (attrFieldName != null && attrFieldType != null) {
                        String filterQuery = buildQueryStringForList(attrFieldName, attrFieldType, attrFieldValue);
                        if(filterQuery != null && filterQuery != ''){
                            queryString += ' AND ' + filterQuery;
                        }
                    }
                }
                queryString += ' limit 10000 ';
                return Database.query(queryString);         
            }                   
    }
    
    // VCP - Deprecated method
    public static Boolean isScoutEnabled(String accountId)
    {
    
        return false;
    }
    
    public static List<Account> getAccountInformationById(String accountId)
    {
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ANNUAL_REVENUE};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
             
                 return [select AnnualRevenue,name,CHL_Prevent_Portal_Download__c,CHL_Partner_Account_Type__c
                           from Account 
                          where Id = :accountId LIMIT 1];       
    }
    public static List<Account> getAccountInformationforCases(set<Id> accountIds)
    {
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ID,CSM_Constants.OBJ_A_NUMBER_OF_CASES, CSM_Constants.OBJ_A_WORKING_CASES, CSM_Constants.OBJ_A_NEW_CASES,
                CSM_Constants.OBJ_A_HIGH_CASES, CSM_Constants.OBJ_A_CLOSED_CASES, CSM_Constants.OBJ_A_AVERAGE_SLA_CASES, CSM_Constants.OBJ_A_OLDEST_CASES};
     
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
             
                if (accountIds.IsEmpty()){
                    return new List<Account>(); 
                } else {
                    return [select  Id, CSM_Number_of_Cases__c,CSM_Number_of_Working_Cases__c,
                              CSM_Number_of_New_Cases__c,CSM_Number_of_Open_High_Priority_Cases__c,
                              CSM_Number_of_Closed_Cases__c,CSM_Average_SLA_Response_Time__c 
                               from Account 
                              where Id IN :accountIds limit 10000];
                }        
    }
    
    public static void updateAccountsforCase(List<Account> accountToUpdatelst){
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_NUMBER_OF_CASES, CSM_Constants.OBJ_A_WORKING_CASES, CSM_Constants.OBJ_A_NEW_CASES,
                CSM_Constants.OBJ_A_HIGH_CASES, CSM_Constants.OBJ_A_CLOSED_CASES, CSM_Constants.OBJ_A_AVERAGE_SLA_CASES, CSM_Constants.OBJ_A_OLDEST_CASES};    
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_UPDATE);
             
            if (!accountToUpdatelst.IsEmpty()){
                update accountToUpdatelst;
            }   
    }

    
    public static String buildQueryStringForList(String attrFieldName, String attrFieldType, String attrFieldValue)
    {
        String queryString = '';
        if(attrFieldName != null && attrFieldType != null && !attrFieldValue.equalsIgnoreCase('UserLookupField'))
        {  
            if(attrFieldType == CSM_Constants.TYPE_DOUBLE 
                   || attrFieldType == CSM_Constants.TYPE_INTEGER
                   || attrFieldType == CSM_Constants.TYPE_CURRENCY
                   || attrFieldType == CSM_Constants.TYPE_PERCENT
                   || attrFieldType == CSM_Constants.TYPE_DATE){
                    queryString += attrFieldName + ' = ' +  attrFieldValue ;
                }
            else {
                queryString += attrFieldName + ' = ' + ' \'' + attrFieldValue + '\' ';              
            }               
        }
        return queryString;
    }
    
    public static void updateOverdueTasks(List<Account> theAccountList){
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_OVERDUE_TASKS_COUNT};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_UPDATE);
          
            if (!theAccountList.IsEmpty()){
                update theAccountList;
            }   
    }
    
     public static void updateAccounts(List<Account> theAccountList){
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_HAS_ACCOUNT_PLAN};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_UPDATE);
          
            if (!theAccountList.IsEmpty()){
                update theAccountList;
            }   
    }

   

/*    public static List<SObject> getAcctsForPlayTaskBatch (List<SObject> sObjList){
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ID, CSM_Constants.OBJ_A_NAME};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_UPDATE);
            List<Id> accList = new List<Id>();
            List<Account> accTs;            
            if (!sObjList.IsEmpty()){

                String soql ='select '  + CSM_Constants.OBJ_A_ID + ',' + CSM_Constants.OBJ_A_NAME + ' from Account ';
                
                    for(SObject sObj: sObjList){
                        accList.add((Id)sObj.get('CSM_AccountId__c'));
                    }
                soql = soql + ' where Id IN :accList limit 25000' ;             
                accTs = Database.query(soql);
                return accTs;
            }   
            return null;
    }

    public static List<SObject> getOpptsForPlayTaskBatch (List<SObject> sObjList){
        List<String> opptFieldList = new List<String>{CSM_Constants.OBJ_A_ID, CSM_Constants.OBJ_O_NAME};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_OPPORTUNITY, opptFieldList, CSM_Constants.DML_OPERATION_UPDATE);
            List<Id> accList = new List<Id>();
            List<Opportunity> oppTs;            
            if (!sObjList.IsEmpty()){

                String soql ='select '  + CSM_Constants.OBJ_A_ID + ',' +  CSM_Constants.OBJ_T_ACCOUNTID + ' from Opportunity ';
                
                    for(SObject sObj: sObjList){
                        accList.add((Id)sObj.get('AccountId'));
                    }
                soql = soql + ' where AccountId IN :accList limit 25000' ;              
                oppTs = Database.query(soql);
                return oppTs;
            }   
            return null;
    }

    public static List<SObject> getCasesForPlayTaskBatch (List<SObject> sObjList){
        List<String> caseFieldList = new List<String>{CSM_Constants.OBJ_A_ID, CSM_Constants.OBJ_CASE_CASENUMBER};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_CASE, caseFieldList, CSM_Constants.DML_OPERATION_UPDATE);
            List<Id> accList = new List<Id>();
            List<Case> cases;           
            if (!sObjList.IsEmpty()){

                String soql ='select '  + CSM_Constants.OBJ_A_ID + ',' +  CSM_Constants.OBJ_T_ACCOUNTID + ' from Case ';
                
                    for(SObject sObj: sObjList){
                        accList.add((Id)sObj.get('AccountId'));
                    }
                soql = soql + ' where AccountId IN :accList limit 25000' ;              
                cases = Database.query(soql);
                return cases;
            }   
            return null;
    }


    public static List<SObject> getAcctPlansForPlayTaskBatch (List<SObject> sObjList){
        List<String> acctPLanFieldList = new List<String>{CSM_Constants.OBJ_A_ID};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_AP, acctPLanFieldList, CSM_Constants.DML_OPERATION_UPDATE);
            List<Id> accList = new List<Id>();
            List<CSM_Account_Plan__c> acctPlans;            
            if (!sObjList.IsEmpty()){

                String soql ='select '  + CSM_Constants.OBJ_A_ID +',' + CSM_Constants.OBJ_AP_ACCOUNT  + ' from CSM_Account_Plan__c';
                
                    for(SObject sObj: sObjList){
                        accList.add((Id)sObj.get('CSM_AccountId__c'));
                    }
                soql = soql + ' where CSM_AccountId__c IN :accList limit 25000' ;               
                acctPlans = Database.query(soql);
                return acctPlans;
            }   
            return null;
    }*/

    
    public static List<Account> getOverdueTaskCountAcct (Set<Id> acctSet){
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ID, CSM_Constants.OBJ_A_OVERDUE_TASKS_COUNT};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
 
            List<Account> accountOverdueTaskList = new List<Account>();             
            if (!acctSet.IsEmpty()){
                accountOverdueTaskList = [select Id, CSM_Overdue_Tasks_Count__c from Account where Id IN: acctSet];
                return  accountOverdueTaskList;
            }   
            return null;
    }
    
    public static Map<Id, Account> getAcctMapById (Set<String> acctSet){
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ID, 'Name'};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
 
        return new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :acctSet LIMIT 10000]);
    }
    
    public static List<Account> searchAccount(String searchStr1){
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ID};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
        String queryString = 'SELECT Id,AccountNumber,Name FROM Account where  (name like' + searchStr1 +') or (AccountNumber like ' + searchStr1 +') Limit 500';
        List<Account> accList = Database.query(queryString);
        return accList;
    }
    
    /**
      * @description : This method returns details of Account from fieldSet.
      * @param : Account.    
    */
    public static List<SObject> getDetailsFromFieldSetByAccId(String accountId, String fieldSetName) {
        List<SObject> accountList = new List<SObject>();
        String queryString = '';
        
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ID};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
        
        queryString = CHL_Util.getQueryStringFromFieldSet(fieldSetName, CSM_Constants.OBJ_ACCOUNT);
        queryString = queryString + '  where Id = : accountId Limit 1000 ';
        system.debug('\n\n @@queryString in getDetailsFromFieldSetByAccId method :: ' + queryString);
        accountList = Database.query(queryString);
        return accountList;
    }  
    
     public static List<Account> getParentAccInfo(List<ID> CurrentParent , boolean parentFlag){
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_PARENTID};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
            if(parentFlag == false){
                 return [SELECT ParentId, Id FROM Account WHERE Id IN : CurrentParent ORDER BY Name Limit 10000];  
            }else{
                return[SELECT ParentId, Name, Id FROM Account WHERE ParentID IN : CurrentParent ORDER BY Name Limit 10000];
            }     
    }   
    public static List<Account> getPartnerAccountByCriteria(String searchCriteria,Set<Id> idsToExclude){
        List<Schema.FieldSetMember> accountFieldSet = SObjectType.Account.FieldSets.CHL_Account_Portal_Group.getFields();
        List<String> accountFieldList = new List<String>();
        String tempIds = '\''+'\'';
        String queryString = 'Select id,';
        for(Schema.FieldSetMember f : accountFieldSet) {
            accountFieldList.add(f.getFieldPath());
            queryString += f.getFieldPath() + ', ';
        }
        for(Id idsToEx :idsToExclude) {
            tempIds = tempIds+','+'\''+idsToEx+'\'';
        } 
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
        queryString = queryString.removeEnd(', ');
        if(test.isRunningTest()){
            queryString += ' from Account where Name LIKE \''+ '%'+String.escapeSingleQuotes(searchCriteria)+'%'+ '\' AND ID NOT IN ('+tempIds+ ') Limit 1000';
        } else {
            queryString += ' from Account where IsPartner=true and Name LIKE \''+ '%'+String.escapeSingleQuotes(searchCriteria)+'%'+ '\' AND ID NOT IN ('+tempIds+ ') Limit 1000';
        }
        system.debug('\n\n check this:: ' + queryString);
        return Database.query(queryString);    
    }
    public static List<Account> getAccountInformationById(List<Id> accountIds)
    {
        List<String> accountFieldList = new List<String>{CSM_Constants.OBJ_A_ANNUAL_REVENUE};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
             
                 return [select Id,AnnualRevenue,name,CHL_Prevent_Portal_Download__c,CHL_Partner_Account_Type__c
                           from Account 
                          where Id IN :accountIds LIMIT 1000];       
    }
    public static List<SObject> getAccountsBySOSL(CHL_GridInputWrapper inputWrapper)
    {
        List<SObject> accList = new List<sObject>();
        String fieldList = CHL_Util.getQueryStringFromFieldSet(CSM_Util.getNamespace() + CHL_Constants.ACCOUNT_DETAILS_FIELDSET_NAME,'Account' );
        fieldList = fieldList.removeStartIgnoreCase('select ');
        fieldList = fieldList.removeEndIgnoreCase(' from Account');
        system.debug('fieldList AFTER Remove '+fieldList);
        Integer queryLimit = inputWrapper.lm == 5 ? 5 : 2000;
        String queryString = 'FIND\''+ inputWrapper.q +'*\' IN All Fields Returning Account (' +fieldList+' ORDER BY Name Asc) Limit '+queryLimit;
        List<List<SObject>>searchList = search.query(queryString);
        system.debug('searchList::'+searchList);
        if(searchList != null && searchList.size()>0){
            accList.addAll(searchList[0]);
        }
        return accList;
    }
    
    public static List<SObject> searchAccountsBySOSL(String searchStr1, String whereCondition) {
    	List<String> accountFieldList = new List<String>{'Id','Name'};
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, accountFieldList, CSM_Constants.DML_OPERATION_READ);
        List<SObject> accList = new List<SObject>();
        String queryString = 'FIND\''+ searchStr1 +'*\' IN Name Fields Returning Account (Id,Name '+whereCondition+' ORDER BY Name Asc) Limit 2000';
    	List<List<SObject>>searchList = search.query(queryString);
    	if(searchList != null && searchList.size()>0){
            accList.addAll(searchList[0]);
        }
        return accList;
    }
    
}