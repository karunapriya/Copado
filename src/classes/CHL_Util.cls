public with sharing class CHL_Util {
    //public static final String quoteExtnNameSpace = '';
    
    /** 
    * @description: Finds the Account Hierarchy.
    * @returns the ID of Accounts and its corresponding parent Accounts for Partner 1/2 Account of partner opportunity
    */
    public static Set<Id> getAccAndParentAccIDs(Id partnerAcc1, Id partnerAcc2){
        Set<Id> parentAccountIds = new Set<Id>();                            
        if(partnerAcc1 <> null){
            parentAccountIds.add(partnerAcc1);
            Set<ID> parentAccountsForAcc1 = fetchParentAccounts(partnerAcc1);
            if(parentAccountsForAcc1 !=  null){
                for(ID accId :parentAccountsForAcc1 ){
                    parentAccountIds.add(accId);
                }
            }
        }
        if(partnerAcc2 <> null){
            parentAccountIds.add(partnerAcc2); 
            Set<ID> parentAccountsForAcc2 = fetchParentAccounts(partnerAcc2);
            if(parentAccountsForAcc2 !=  null){
                for(ID accId :parentAccountsForAcc2 ){
                    parentAccountIds.add(accId);
                }
            }
        }        
        return parentAccountIds;
    } //end of Method
    
    /** 
    * @description: Finds the Account Hierarchy.
    * @returns the ID of parent Accounts for the passed account Id.
    */
    public  static Set<ID> fetchParentAccounts( String accId ){    
        List<Account> al            = new List<Account>{};
        List<ID> currentParent      = new List<ID>{};
        Set<ID> parentAccountList    = new Set<ID>{};
        Integer level               = 0;
        Boolean isNoParentAccounts   = false;
        
        //Add the Parent Account ID
        currentParent.add(accId);
        
        //Loop though all children Accounts
        while ( !isNoParentAccounts && level < 20){
            String queryString  = '';
            if( level == 0 ){
                al = CSM_AccountDataAccess.getParentAccInfo(currentParent, false);
            } else {
                 al = CSM_AccountDataAccess.getParentAccInfo(currentParent, false);
            } 
            
            if( al.size() == 0 ){
                isNoParentAccounts = true;
            }
            else{
                currentParent.clear();
                for ( Integer i = 0 ; i < al.size(); i++ ){
                    Account a = al[i];
                    if(a.ParentId != null) {
                        currentParent.add(a.ParentId);
                        parentAccountList.add(a.ParentId);
                    }
                }
                level++;
            }
        }
        system.debug('\n\n parentAccountList :: ' + JSON.serialize(String.valueOF(parentAccountList)) );
        return parentAccountList;
    }//end of Method
    
    public static Set<ID> fetchPortalParentAccounts( String accId ){    
        List<Account> al            = new List<Account>{};
        List<ID> currentParent      = new List<ID>{};
        Set<ID> parentAccountList    = new Set<ID>{};
        Integer level               = 0;
        Boolean isNoParentAccounts   = false;
        
        //Add the Parent Account ID
        currentParent.add(accId);
        
        //Loop though all children Accounts
        while ( !isNoParentAccounts && level < 20){
            String queryString  = '';
            if( level == 0 ){
                al = CSM_AccountDataAccess.getParentAccInfo(currentParent, false);
            } else {
                 al = CSM_AccountDataAccess.getParentAccInfo(currentParent, false);
            } 
            //system.debug('Queries $$$$$$$ '+Limits.getQueries());
            if(Limits.getQueries() >= 90){
                parentAccountList = null;
                break;
            }else{
                if( al.size() == 0 ){
                    isNoParentAccounts = true;
                }
                else{
                    currentParent.clear();
                    for ( Integer i = 0 ; i < al.size(); i++ ){
                        Account a = al[i];
                        if(a.ParentId != null) {
                            currentParent.add(a.ParentId);
                            parentAccountList.add(a.ParentId);
                        }
                    }
                    level++;
                }
            }
        }
        system.debug('\n\n parentAccountList :: ' + JSON.serialize(String.valueOF(parentAccountList)) );
        return parentAccountList;
    }//end of Method
    /** 
    * @description: Finds the Account Hierarchy.
    * @returns the ID of all Accounts and its corresponding child Accounts for Partner 1/2 Accounts.
    */
      public static Set<Id> getAccAndChildAccIDs(Id partnerAcc1, Id partnerAcc2){
        Set<Id> partnerAccIds = new Set<Id>();
                             
         if(partnerAcc1 <> null){
             partnerAccIds.add(partnerAcc1);
             Set<ID> ChildAccountsPartnerAcc1 = fetchChildAccounts(partnerAcc1);
                if(ChildAccountsPartnerAcc1 !=  null){
                    for(ID accId :ChildAccountsPartnerAcc1 ){
                        partnerAccIds.add(accId);
                    }
                }
         }
         if(partnerAcc2 <> null){
             partnerAccIds.add(partnerAcc2); 
                Set<ID> ChildAccountsPartnerAcc2 = fetchChildAccounts(partnerAcc2);
                if(ChildAccountsPartnerAcc2 !=  null){
                    for(ID accId :ChildAccountsPartnerAcc2 ){
                        partnerAccIds.add(accId);
                    }
                }
         }
        return partnerAccIds;
    } //end of Method
    
    /** 
    * @description: Finds the Account Hierarchy.
    * @returns the ID of all Accounts and its corresponding child Accounts.
    */
    public  static Set<ID> fetchChildAccounts( String parentAccId ){    
        List<Account> al            = new List<Account>{};
        List<ID> currentParent      = new List<ID>{};
        Set<ID> childAccountList    = new Set<ID>{};
        Integer level               = 0;
        Boolean isNoChildAccounts   = false;
        
        //Add the Parent Account ID
        currentParent.add(parentAccId);
        
        //Loop though all children Accounts
        while ( !isNoChildAccounts && level <= 20){
                String queryString  = '';
                if( level == 0 ){
                     al = CSM_AccountDataAccess.getParentAccInfo(currentParent , false);
                } 
                else {
                     al = CSM_AccountDataAccess.getParentAccInfo(currentParent , true);
                } 
                if( al.size() == 0 ){
                    isNoChildAccounts = true;
                }
                else{
                    currentParent.clear();
                    for ( Integer i = 0 ; i < al.size(); i++ ){
                        Account a = al[i];
                        currentParent.add(a.id);
                        childAccountList.add(a.id);
                    }
                    level++;
                }
        }
        system.debug('\n\n childAccountList :: ' + JSON.serialize(String.valueOF(childAccountList)) );
        return childAccountList;
    }//end of Method
    
    /*
    * @description: Below method is used to fetch all the parent accounts and also check the SOQL limit. Method is created as part of US1162.
    */
    public static Map<Id,Set<Id>> getAccountHierarchy(Set<Id> selectedAccountIdSet ,Integer limitToCheck){
        Map<Id, Set<Id>> accountHierarchyMap = new Map<Id, Set<Id>>();
        for(Id accId  : selectedAccountIdSet){
            Set<Id> parentAccIdSet = CHL_Util.fetchPortalParentAccounts(accId);
            // query limits reached.
            if(parentAccIdSet == null){
                accountHierarchyMap = null;
                break;
            }else{
                accountHierarchyMap.put(accId, parentAccIdSet);
            }
        }
        return accountHierarchyMap;
    }
    
    public static List<User> currentUserDetails {
        get {
            if (currentUserDetails==null){
            	List<String> accFieldList = new List<String>{'CHL_Partner_Account_Type__c'};
				CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_TYPE_ACCOUNT, accFieldList, CSM_Constants.DML_OPERATION_READ);
				List<String> userFieldList = new List<String>{'CHL_Use_Cookies_for_Channel__c'};
				CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_USER, userFieldList, CSM_Constants.DML_OPERATION_READ);
				String queryString = 'select CHL_Use_Cookies_for_Channel__c, Contact.AccountId,Account.CHL_Partner_Account_Type__c,Account.Name,ContactId,AccountId from User where Id =\''+ UserInfo.getUserId() +'\'' + ' Limit 1';
                currentUserDetails = Database.query(queryString);        
            }
            return currentUserDetails;
        }
        private set;
    }
    
    public static List<User> getChannelPartnerUsers(Set<Id> userIds){
        return [Select id,AccountId from User where AccountId != null AND User.Profile.UserLicense.Name LIKE 'Partner Community%' 
                AND User.Profile.Name LIKE 'PRISM Channel%' AND UserType = :CHL_CONSTANTS.PARTNER_USER AND id IN: userIds];
    }
    /*
    @Description: Below method return list of users for the Account
    */
    /*public static List<User> getUsersForAccount(Id accId) {
        return [select id from User where Contact.AccountId =:accId limit 100];
    }*/
    
    public static List<User> getUsersForAccount(Id accId) {
    	string queryString = 'Select id from User where Contact.AccountId = :accId AND isActive = true AND  Id<>\''+UserInfo.getUserId()+'\'' + ' limit 10000';
    	return Database.query(queryString); 
    }
    
   
    /**
     * @description : This class is run WITHOUT sharing as the commnuity users do not have access to the login history object.
     *                  This method returns the data required for overview tab on the partner landing page.
     *                 This methods returns data for Action tiles, Expiered opportunity matrix and piple line chart
     */
     public without Sharing class UserUtility{  
        public DateTime firstLoginOfUser(){
           Datetime firstLoginTime;
           for(LoginHistory loghistory: [Select LoginTime,Status FROM LoginHistory where UserId=:userinfo.getUserId() order by LoginTime asc limit 100]){
              if(loghistory.Status == CHL_CONSTANTS.STR_SUCCESS) {
                 firstLoginTime =loghistory.LoginTime;
                 break;
               }   
            }
            
            return firstLoginTime;
        }//End of method
      }  
      
       
    /*
    * @description send mail to logged-in User's Id.
    * @Param:  Subject, Bodytext, SenderName, Obj Id.
    */
    public static void sendEmailNotificationWithUrl(String subject, String bodyText1, String bodyText2, String senderName, Set<ID> objectIdSet) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {userinfo.getUserEmail()};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName(senderName);
        mail.setSubject(subject);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        String objIdLink;
        for(ID ids : objectIdSet){
            objIdLink += ' ' + URL.getSalesforceBaseUrl().toExternalForm()+'/' + ids +'  ';
        }
        mail.setplainTextBody(bodyText1 + objIdLink  +' '+ bodyText2);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /*
    * @description: Below method is used to read the fieldset from given object. Method is created as part of US829
    * @Param: fieldsetname, objectname
    */
    public static List<Schema.FieldSetMember> getFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();   
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }
    
    
    /*
    * @description: Below method is used to fetch all the columns from the fieldset. Method is created as part of US729 and US829
    * @Param: objectname, fieldsetname
    */
    public static String getQueryStringFromFieldSet(String fieldSetName,String ObjectName) {
        String colNames = '';
        String queryString;
        /*String fieldAPIName ;
        String lookupField;
        String lookupFieldAPI = '';*/
        Set<String> fields = new Set<String>();  
        String fieldAPIName ;
        String lookupField;
        String nameSpace = CSM_Util.getNamespace();
        List <Schema.FieldSetMember> fieldSetList = CHL_Util.getFieldSet(fieldSetName, ObjectName);   
        if (ObjectName == 'Contact' ){
            fields.add('AccountId');
        }  
        for (Schema.FieldSetMember fld: fieldSetList) {
            fieldAPIName = string.valueof(fld.getFieldPath());              
            if(string.valueof(fld.getType()) == 'REFERENCE' && !fieldAPIName.contains('.') && !fieldAPIName.contains('Owner') && fieldAPIName.contains('__c')) {       
                lookupField = fieldAPIName.replace('__c', '__r');
                lookupField = lookupField+'.Name';
                fields.add(lookupField);                                    
            } else if(fieldAPIName.contains('Product2Id') && string.valueof(fld.getType()) == 'REFERENCE'){
                List < String > relatedListColName = fieldAPIName.split('\\.');
                lookupField =  relatedListColName[0] +'.Product2.Name,';
                fields.add(lookupField); 
            }   else if(fieldAPIName.contains('ParentId') && string.valueof(fld.getType()) == 'REFERENCE'){
                if(ObjectName == 'Case'){
                    lookupField = 'Parent.CaseNumber';
                    fields.add(lookupField); 
                }else {
                    lookupField = 'Parent.Name';
                    fields.add(lookupField); 
                }
            }   else if(fieldAPIName.contains('AccountId') && string.valueof(fld.getType()) == 'REFERENCE'){
                lookupField = 'Account.Name';
                fields.add(lookupField); 
            }   else if(fieldAPIName.contains('LastModifiedById') && string.valueof(fld.getType()) == 'REFERENCE'){
                lookupField = 'LastModifiedBy.Name';
                fields.add(lookupField); 
            }    
            if(CSM_AccessController.hasField(ObjectName, 'OwnerId')) {
                fields.add('Owner.Name');
            } 
            if(CSM_AccessController.hasField(ObjectName, 'Name')) {
                fields.add('Name');
            }
            if (ObjectName == CHL_Constants.OBJ_QUOTE && CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')){
                fields.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');
                fields.add(CHL_Constants.OBJ_QUOTE_TOTAL);
                fields.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c');
                fields.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c');
                fields.add(CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c');
            }
            
            if (ObjectName == nameSpace+CHL_Constants.OBJ_PT_OPPORTUNITY ){
                fields.add(nameSpace + 'CHL_Partner_Account_1__c');
                fields.add(nameSpace + 'CHL_Partner_Account_1_Type__c');
                fields.add(nameSpace + 'CHL_Partner_Account_2__c');
                fields.add(nameSpace + 'CHL_Partner_Account_2_Type__c');
                fields.add(nameSpace + 'CHL_MSRP__c');
                fields.add(nameSpace + 'CHL_Opportunity__r.AccountId');
                fields.add(nameSpace + 'CHL_Opportunity_Account_Name__c');
            }
            if (ObjectName == nameSpace + CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP){
                fields.add(nameSpace + 'CHL_Partner_Opportunity__r.CHL_Incumbent__c');
            }
            
            //add only unique fields  
            if(!fields.contains(fieldAPIName)){  
                //maintain a set of fields so that only unique fields are added in query 
                
               fields.add(fieldAPIName);                         
            }
        }
        
        if(ObjectName.equals('QuoteLineItem')){
            fields.add('Id');
            //fields.add(CHL_Util.quoteExtnNameSpace+'REN_Original_Line_Item_ID__c');
            fields.add(CHL_Util.quoteExtnNameSpace+'CHL_Cross_Sell_Id__c');
            fields.add('Product2.Name');
            fields.add('Product2.Id');
            List<REN_Field_Mappings__c> lstOfFldMapping = REN_FieldMappingsDataAccess.getFieldMappingListByConfig('QuoteLineItem','QuoteLineItem');
            Set<String> frmFldSet = new Set<String>();
            Set<String> toFldSet = new Set<String>();
            REN_Util.getFromAndToFldsToQuery(lstOfFldMapping,frmFldSet,toFldSet);
            fields.addAll(frmFldSet);
            fields.addAll(toFldSet);
        }
        for( String fs : fields ) { 
            colNames += fs+',';
        }
        colNames = colNames.removeEnd(',');
        
        queryString = 'Select  ' + colNames +  ' From '+ ObjectName;
        system.debug('\n\n QueryString :: ' + queryString);
        return queryString;
    }
        
     
   //********* Start -- Added for US1082 ***********//

    /**
      * @description : This method returns the Quarters for the current year.
    */
    public static CHL_CurrentQuarter getCurrentQuarter() {
        integer currentQuarter;
        
        //list<Period> lstFiscalPeriod = [select p.Number, f.Name from Period p, p.FiscalYearSettings f where Type = 'Quarter' and p.StartDate <=today and p.EndDate >=today limit 1]; //today
        string periodQuery = 'select p.Number, f.Name from Period p, p.FiscalYearSettings f where Type = \'Quarter\' and p.StartDate <=today and p.EndDate >=today limit 1';
        list<Sobject> lstFiscalPeriod = Database.query(periodQuery);
        if (lstFiscalPeriod!=null && !lstFiscalPeriod.isEmpty()){
            currentQuarter = (Integer)lstFiscalPeriod[0].get('Number');
        } else {
            currentQuarter = ((System.today().month() - getFiscalYearMonth()) / 3) + 1; //System.today()
        }
        CHL_CurrentQuarter curQtr = new CHL_CurrentQuarter();
        curQtr.Id = 'Q'+string.valueof(currentQuarter);
        curQtr.name = 'Q' + string.valueof(currentQuarter);
        return curQtr;
    } 
     
    
    
    public static CHL_CurrentYear getCurrentYear() {
        string currentYear;
        string currentFiscalYear = 'select p.Number, f.Name from Period p, p.FiscalYearSettings f where Type = \'Year\' and p.StartDate <=today and p.EndDate >=today limit 1';
        list<Sobject> lstFiscalPeriod = Database.query(currentFiscalYear);
        if (lstFiscalPeriod!=null && !lstFiscalPeriod.isEmpty()){
            sObject sobj = lstFiscalPeriod[0].getSObject('FiscalYearSettings');
            currentYear = (String)sobj.get('Name');
        } else {            
            currentYear = string.valueof(System.today().Year());
        }
        CHL_CurrentYear currentYearObj =  new CHL_CurrentYear();
        currentYearObj.id = currentYear;
        currentYearObj.name = currentYear;
        return currentYearObj;
    } 
    
    //US1082 : New method for Opp grid for Quater option.
    public static List<CHL_Quarters> getQuartersList()  {
        Set<String> quarterSet = new Set<String>{'Q1','Q2','Q3','Q4'};
        List<CHL_Quarters> quarterList = new List<CHL_Quarters>();       
        for(String qtr:quarterSet)  {
            CHL_Quarters qtrwrp = new CHL_Quarters();
                qtrwrp.id = qtr;
                qtrwrp.name = qtr;         
            quarterList.add(qtrwrp);
        }
        return quarterList;
    }
    
     //US1082 : New method for next\Last 10 years  of current Year.
    public static List<CHL_Years> getNextAndLastYears(Integer noOfYears)  {
        List<CHL_Years> yearList = new  List<CHL_Years>();
        Integer currYear = System.today().Year();
        for(Integer i = (-noOfYears); i <= noOfYears; i++){
            CHL_Years  yearObj = new CHL_Years();
            yearObj.id  = String.valueOf(currYear + i) ;
            yearObj.name  = yearObj.id;
            yearList.add(yearObj);
        }
        System.debug('\n\n yearList :: ' + yearList);
        return yearList;
    }
    
    //********* End for US1082 ***********//   
   
    /**
      * @description : This method returns the filter options for Opportunity types for Opportunities Tab.
    */
    public static List<CHL_PartnerOpportunityFilters.CHL_OptyTypes> getOptyTypes() {
        //Map<String,string> mapofFilter = new Map<String,string>();
        List<CHL_PartnerOpportunityFilters.CHL_OptyTypes> optyStageList = new List<CHL_PartnerOpportunityFilters.CHL_OptyTypes>();
        for(String str :CHL_Constants.PREDEFINED_FILTER_OPTIONS){
            CHL_PartnerOpportunityFilters.CHL_OptyTypes stage = new CHL_PartnerOpportunityFilters.CHL_OptyTypes();
            if(str.equalsIgnoreCase(CHL_Constants.FILTER_OPTION_OPTY_QUOTES)){
                stage.id = 'OPEN_OPPS_WITH_QUOTES';
                stage.name = str;
                optyStageList.add(stage);
            } else if(str.equalsIgnoreCase(CHL_Constants.FILTER_OPTION_OPEN_OPPORTUNITY))  {
                stage.id = 'OPEN_OPPS';
                stage.name = str;
                optyStageList.add(stage);
            } else if(str.equalsIgnoreCase(CHL_Constants.FILTER_OPTION_CLOSED_OPPORTUNITY))  {
                stage.id = 'CLOSED_OPPS';
                stage.name = str;
                optyStageList.add(stage);
            } else if(str.equalsIgnoreCase(CHL_Constants.FILTER_OPTION_WON_OPPORTUNITY))  {
                stage.id = 'WON_OPPS';
                stage.name = str;
                optyStageList.add(stage);
            } else if(str.equalsIgnoreCase(CHL_Constants.FILTER_OPTION_LOST_OPPORTUNITY)) {
                stage.id = 'LOST_OPPS';
                stage.name = str;
                optyStageList.add(stage);
            } else if(str.equalsIgnoreCase(CHL_Constants.FILTER_OPTION_STATUS_UPDATE) )  {
                stage.id = 'NEED_UPDATE';
                stage.name = str;
                optyStageList.add(stage);
            } else if(str.equalsIgnoreCase(CHL_Constants.FILTER_OPTION_NEW_LAST_WEEK) )  {
                stage.id = 'NEW';
                stage.name = str;
                optyStageList.add(stage);
            }           
        }
        return optyStageList;
    }   
    
    /**
      * @description : This method returns the date value from the GMT date time string in user timezone
    */ 
    public static Date getDateFromGMT(string inputvalue)    {
         Datetime dt = datetime.valueof(inputvalue.replace('T',' '));
         return date.valueof(dt);   
         //return dt;
    }
    
    //Below method will give Fiscal Year starts month from Organization details
    //DO NOT ADD CRUD FLS CHECK FOR THIS METHOD AS, ORGANIZATION OBJECT IS STANDARD OBJECT AND WE CAN NOT ADD PERMISSION TO THIS OBJECT
    public static Integer getFiscalYearMonth()  {
        organization orgInfo = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()];
        return orgInfo.FiscalYearStartMonth;
    }
    
    //Below Method will return true if OWD for opportunity is Private else it will return false.
    //DO NOT ADD CRUD FLS CHECK FOR THIS METHOD AS, ORGANIZATION OBJECT IS STANDARD OBJECT AND WE CAN NOT ADD PERMISSION TO THIS OBJECT
    public static Boolean isOWDForOpportunityPrivate()  {
        organization orgInfo = [select DefaultOpportunityAccess from Organization where id=:Userinfo.getOrganizationId()];
        return (orgInfo.DefaultOpportunityAccess).contains('Edit') ? false : true;
    }
    
    //Below Method will return true if OWD for Account is Private else it will return false.
    //DO NOT ADD CRUD FLS CHECK FOR THIS METHOD AS, ORGANIZATION OBJECT IS STANDARD OBJECT AND WE CAN NOT ADD PERMISSION TO THIS OBJECT
    public static Boolean isOWDForAccountPrivate()  {
        organization orgInfo = [select DefaultAccountAccess from Organization where id=:Userinfo.getOrganizationId()];
        return (orgInfo.DefaultAccountAccess).contains('Edit') ? false : true;
    }
    
    //Below Method will return true if OWD for CASE is Private else it will return false.
    //DO NOT ADD CRUD FLS CHECK FOR THIS METHOD AS, ORGANIZATION OBJECT IS STANDARD OBJECT AND WE CAN NOT ADD PERMISSION TO THIS OBJECT
    public static Boolean isOWDForCASEPrivate()  {
        organization orgInfo = [select DefaultCASEAccess from Organization where id=:Userinfo.getOrganizationId()];
        return (orgInfo.DefaultCASEAccess).contains('Edit') ? false : true;
    }
    
    
    /*Below Method will return if an object exists or not. This method is used to check if
    the object sharing is private/public read*/
    public static Boolean sObjectExists(String objectName)  {
        Map<String, Schema.SObjectType> tokens = Schema.getGlobalDescribe();
        if(tokens.containsKey(objectName)) 
          return true;
        else
          return false;  
    }
    
    //US896
    public static Set<String> getAvailableSalesStage()    {
        Map<String,Set<String>> savedSalesStages = CHL_Util.getPipelineandAvlSalesStage();
        Set<String> availableStages = new Set<String> ();
        if(savedSalesStages.containsKey(CHL_Constants.STR_AVLBL_STAGES)){
            availableStages = savedSalesStages.get(CHL_Constants.STR_AVLBL_STAGES);
        }
        return availableStages;
    }
    
      
    public static Map<String,Set<String>> getPipelineandAvlSalesStage()    {
        //List<CHL_Opportunity_Status_Log__c> opptySalesStages = CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
        Set<String> pipeLineSalesStageSet = new Set<String>();
        Set<String> avlSalesStageSet = new Set<String>();
        Set<String> excludeSalesStageSet = new Set<String>();
        String salesStage = '';
        String avlSalesStage = '';
        String excludeStage = '' ;
        Map<String,Set<String>> savedSalesStages = new Map<String,Set<String>>();
        if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null){
            for(CHL_Opportunity_Status_Log__c oppStatusLog : CHL_OpptyStatusLogDataAccess.opptyStatusLogList){
                salesStage = oppStatusLog.CHL_Display_Pipeline_Sales_Stages__c;
                avlSalesStage = oppStatusLog.CHL_Available_Sales_Stages__c;
                excludeStage = oppStatusLog.CHL_Exclude_Sales_Stages__c;
            }     
            if(salesStage != null){
                pipeLineSalesStageSet = CHL_Util.splitStages(salesStage);
                savedSalesStages.put(CHL_Constants.STR_PIPELINE_STAGES,pipeLineSalesStageSet);
            }
            if(avlSalesStage != null){
                avlSalesStageSet = CHL_Util.splitStages(avlSalesStage);
                savedSalesStages.put(CHL_Constants.STR_AVLBL_STAGES,avlSalesStageSet);
            }
            if(excludeStage != null && String.isNotBlank(excludeStage)){
                excludeSalesStageSet = CHL_Util.splitStages(excludeStage);
                savedSalesStages.put(CHL_Constants.STR_EXCLUDE_STAGES,excludeSalesStageSet);
            }
        
        }
        return savedSalesStages;
    }
    
    public static Set<String> getPipelineSalesStage()    {
     Map<String,Set<String>> savedSalesStages = CHL_Util.getPipelineandAvlSalesStage();
     Set<String> pipeLineStages = new Set<String>();
     if(savedSalesStages.containsKey(CHL_Constants.STR_PIPELINE_STAGES)){
        pipeLineStages = savedSalesStages.get(CHL_Constants.STR_PIPELINE_STAGES);
     }
     return pipeLineStages;
    }
    
    public static Set<String> splitStages(String stages){
        Set<String> salesStageSet = new Set<String>();
        if(stages != null){
            List<String>  salesList = stages.split(';');
            for(String str : salesList){
                salesStageSet.add(str);
            }
        }
        system.debug('salesStageSet : '+salesStageSet);
        return salesStageSet;
    }
    /**
        * @description : This method returns the stage picklist values for partner opportunity
        * @param : 
    */ 
    public Static List<String> fetchPartnerOppStagePicklistValues(){
          Schema.DescribeFieldResult stageFieldResult = CHL_Partner_Opportunity__c.CHL_Sales_Stage__c.getDescribe();
          List <Schema.PicklistEntry> stageValues = stageFieldResult.getPicklistValues();            
          List <string> stageNameList = new List <string>();
          for (Schema.PicklistEntry p: stageValues) {
             stageNameList.add(String.valueOf(p.getValue()));
          }
          return stageNameList;
        }
    /*
    @Description : This method will return the PDF Option set by the admin. It will fetch it from Opportunity Status Log object.
    */
    public static String getQuotePDFOption() {
        string quotePdfOptionstr = '';      
        //List<SObject> optyStatusLogList = CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();         
        if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty())   {
            quotePdfOptionstr = (String)(CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0]).get(CHL_CONSTANTS.OBJ_OPSL_QUOTE_PDF_OPTION);
        }
        return quotePdfOptionstr;
    }
    
    /*
    @Description : Below method will be used to return grid export option.
    */
    public static CHL_AngularResponeWrapper.CHL_GridConfiguration getGridExportOptions(boolean exportNeeded,String filename,boolean selectionNeeded){       
        CHL_AngularResponeWrapper.CHL_GridExportConfig gridExport = new CHL_AngularResponeWrapper.CHL_GridExportConfig();
        CHL_AngularResponeWrapper.CHL_PDFConfig pdfConfig = new CHL_AngularResponeWrapper.CHL_PDFConfig();
        pdfConfig.headerLabel = filename;
        pdfConfig.pageSize = 'A3';
        pdfConfig.maxGridWidth = 600;   
        CHL_AngularResponeWrapper.CHL_CSVConfig csvConfig = new CHL_AngularResponeWrapper.CHL_CSVConfig();
        csvConfig.fileName = filename+'.csv';   
        gridExport.pdf = pdfConfig;
        gridExport.csv = csvConfig;
        CHL_AngularResponeWrapper.CHL_GridConfiguration gridConfig = new CHL_AngularResponeWrapper.CHL_GridConfiguration();
        gridConfig.exportPdf = exportNeeded;
        gridConfig.exportCsv = exportNeeded;
        gridConfig.selection = selectionNeeded;
        gridConfig.sorting = true;
        gridConfig.exportConfig = gridExport;
        return gridConfig;
    }
  
   public static  Integer fetchUserSessionPeriod(){
        Integer numSecValid = 0;
        List<AuthSession> sessionList = new List<AuthSession>();
        sessionList = [Select NumSecondsValid from AuthSession where userType = 'PowerPartner' and  SessionType = 'ChatterNetworksAPIOnly' and UsersId=:userinfo.getUserId() order by createddate desc limit 1];
        numSecValid = sessionList.size() > 0 ? sessionList[0].NumSecondsValid : 900;
        return numSecValid;
    }
    
    //Added for US937
    public static Set<ID> incumbentPOSet(Set<ID> partnerOppIdSet){
        if(!partnerOppIdSet.isEmpty()){
            Map<Id,sObject> incumbentPOMap  = new Map<Id,sObject>(CHL_PartnerOpportunityDataAccess.getIncumbentPartnerOpty(partnerOppIdSet));
            return incumbentPOMap.keyset();
        }
        return null;
    }
    
    public static List<sObject> getObjectListByWhereClause(Set<String> fldstoQuery,string objectName, string whereClause){
        List<String> fieldList = new List<String>(fldstoQuery);
        //List<OpportunityLineItem> oliList; 
        CSM_Util.checkCRUD_FLS(objectName, fieldList, CSM_Constants.DML_OPERATION_READ);
        String sQuery = 'Select '+String.join(fieldList, ',')+ ' From '+objectName+
                          ' Where '+whereClause+ ' limit 10000 ';
        return Database.query(sQuery);
        //return oliList;  
    }
    
    /** 
    * @description: Finds the namespace for the Quote Extension managed package.
    * @returns the namespace string.
    */
    public static String quoteExtnNameSpace{
        get {
            if (quoteExtnNameSpace==null){
                quoteExtnNameSpace = '';
                try{
                    List<ApexTrigger> tr =[select NamespacePrefix from ApexTrigger where Name like:'%CHL_QuoteLineItemTrigger%'];
                    if (tr!=null && !tr.isEmpty()){
                        quoteExtnNameSpace = (String.isNotBlank(tr[0].nameSpacePrefix) ?  tr[0].nameSpacePrefix + '__' :  '');
                    }
                } catch(Exception ex) {
                    
                }
            }
            return quoteExtnNameSpace;
        }
        private set;
    }
    
    /*
    @Description: Below method is minly created for Quote Sync. This is manily created for copying Opportunity values to Quote during Quote Creation.
    @             If opportunity field values are blank it will not copy values from Oppty to Quote.    
    */
    public static sObject copyObjectUsingAdminMapping(sObject fromObject, sObject toObject, Map<String, Schema.SobjectField> fieldDescriptionMap, List<REN_Field_Mappings__c> fieldMappingList){
        if(fromObject == null || toObject == null || fieldDescriptionMap == null || fieldMappingList == null){
            //do nothing. 
        }else{
            for(REN_Field_Mappings__c fieldMapping: fieldMappingList) {
                if(fromObject.get(fieldMapping.REN_From_Field_API_Name__c) == '' || fromObject.get(fieldMapping.REN_From_Field_API_Name__c) == null){
                    toObject.put(fieldMapping.REN_To_Field_API_Name__c, toObject.get(fieldMapping.REN_To_Field_API_Name__c));
                }else{
                    toObject.put(fieldMapping.REN_To_Field_API_Name__c, fromObject.get(fieldMapping.REN_From_Field_API_Name__c));
                }
            }       
                
        }
        return toObject;
    }
    
    /** 
    * @description: Finds the permisson for download on logged in user account.
    * @returns boolean string.
    */
    public static String isDownloadable{
        get {
            if (isDownloadable==null){
                isDownloadable = '';
                try{
                    String isPreventPortalDownload;
                    Account acc = (Account)currentUserDetails[0].getSobject('Account');
        			String accId = acc <>null ? acc.id: '';
                    //String accId = currentUserDetails[0].Contact.AccountId;//fetchAccountIdOfUser(userinfo.getUserId());
                    List<Account> accList = CSM_AccountDataAccess.getAccountInformationById(accId);
                    if (!accList.isEmpty()){
                        isPreventPortalDownload = String.valueOf(accList[0].CHL_Prevent_Portal_Download__c);
                    }
                    if(isPreventPortalDownload == 'true') isDownloadable = 'false'; else isDownloadable = 'true';
                } catch(Exception ex) {
                    
                }
            }
             
            return isDownloadable;
        }
        private set;
    }
    public static List<User> getPartnerUserByCriteria(String searchCriteria,Set<Id> idsToExclude){
        List<Schema.FieldSetMember> userFieldSet = SObjectType.User.FieldSets.CHL_User_Portal_Group.getFields();
        List<String> userFieldList = new List<String>();
        String tempIds = '\''+'\'';
        String queryString = 'Select id,name,';
        for(Schema.FieldSetMember f : userFieldSet) {
        	Map<String, Schema.SObjectField> objFieldInfo = User.getSObjectType().getDescribe().fields.getMap();
            String fieldAccessibility = String.valueOf(f.getFieldPath());
			Schema.DescribeFieldResult fieldDescription = objFieldInfo.get(fieldAccessibility).getDescribe();
            if(fieldDescription.isUpdateable()){
            	userFieldList.add(f.getFieldPath());   
            }            
            queryString += f.getFieldPath() + ', ';
        }
        for(Id idsToEx :idsToExclude) {
            tempIds = tempIds+','+'\''+idsToEx+'\'';
        } 
        CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_USER, userFieldList, CSM_Constants.DML_OPERATION_READ);
        queryString = queryString.removeEnd(', ');
        if(test.isRunningTest()){
            queryString += ' from User where Name LIKE \''+ '%'+String.escapeSingleQuotes(searchCriteria)+'%'+ '\' AND ID NOT IN ('+tempIds+ ') Limit 1000';
        } else {
            queryString += ' from User where ContactId != null and Name LIKE \''+ '%'+String.escapeSingleQuotes(searchCriteria)+'%'+ '\' AND ID NOT IN ('+tempIds+ ') Limit 1000';  
        }
        return Database.query(queryString);  
    }
   
   public static List<Sobject> getHierarchyUsersByPortalGroupId(Id portalGroupId) {
        List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_MEM_ACCNT,
                                                    CHL_CONSTANTS.OBJ_PORTAL_MEM_MASTER,
                                                    CHL_CONSTANTS.OBJ_PORTAL_MEM_USER,
                                                    CHL_CONSTANTS.OBJ_PORTAL_GROUP_REL_MEM};
        
        CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, fcFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<Sobject> portalGroupMemberUserList = new List<Sobject>();
        Set<Id> usrIds = new Set<Id>();
        for(CHL_Portal_Group_Member__c userId:[select CHL_Partner_User__c from CHL_Portal_Group_Member__c Where CHL_Portal_Group__c = :portalGroupId And CHL_Related_Group_Member__c != null])
          usrIds.add(userId.CHL_Partner_User__c);
        
        if(test.isRunningTest()){
            portalGroupMemberUserList = Database.query('select Name,format(LastLoginDate),AccountId,format(CreatedDate),Account.Name from User'); 
        } else {
            portalGroupMemberUserList = Database.query('select Name,format(LastLoginDate),AccountId,format(CreatedDate),Account.Name from User Where Id IN :usrIds'); 
        }
        
                                        
        return portalGroupMemberUserList;
    } 
    
    public static List<Sobject> getIndividualUsersByPortalGroupId(Id portalGroupId) {
        List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_MEM_ACCNT,
                                                    CHL_CONSTANTS.OBJ_PORTAL_MEM_MASTER,
                                                    CHL_CONSTANTS.OBJ_PORTAL_MEM_USER,
                                                    CHL_CONSTANTS.OBJ_PORTAL_GROUP_REL_MEM};
        
        CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, fcFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<Sobject> portalGroupMemberUserList = new List<Sobject>();
        Set<Id> usrIds = new Set<Id>();
        for(CHL_Portal_Group_Member__c userId:[select CHL_Partner_User__c from CHL_Portal_Group_Member__c Where CHL_Portal_Group__c = :portalGroupId And CHL_Related_Group_Member__c = null])
          usrIds.add(userId.CHL_Partner_User__c);
        
        if(test.isRunningTest()){
            portalGroupMemberUserList = Database.query('select Account.Name,Name,format(LastLoginDate),format(CreatedDate) from User');
        } else {
            portalGroupMemberUserList = Database.query('select Account.Name,Name,format(LastLoginDate),format(CreatedDate) from User Where Id IN :usrIds'); 
        }
        
        return portalGroupMemberUserList;
    }
    public static List<User> getUserInformationById(List<Id> userIds)
    {
         return [select id,name
                   from user 
                  where Id IN :userIds LIMIT 1000];       
    }
    
    //Added to get user information as  per account.
    public static List<User> getUserFromAccount(Set<ID> accIdSet){
        return [Select id,AccountId From User where AccountId in : accIdSet limit 10000];
    }
    public static Set<Id> getUsersByPortalGroupMembers(Id portalGroupId) {
        List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_PORTAL_MEM_ACCNT,
                                                    CHL_CONSTANTS.OBJ_PORTAL_MEM_MASTER,
                                                    CHL_CONSTANTS.OBJ_PORTAL_MEM_USER,
                                                    CHL_CONSTANTS.OBJ_PORTAL_GROUP_REL_MEM};
        
        CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_PORTAL_GROUP_MEM, fcFieldList, CSM_Constants.DML_OPERATION_READ);
        
        List<Sobject> portalGroupMemberUserList = new List<Sobject>();
        Set<Id> usrIds = new Set<Id>();
        for(User userId:[select id from user where accountid in (select CHL_Partner_Account__c from CHL_Portal_Group_Member__c Where CHL_Portal_Group__c = :portalGroupId And CHL_Related_Group_Member__c = null)])
            usrIds.add(userId.Id);
          
        return usrIds;
    }
    
    public static AggregateResult[] getListWithAggregateGroupBy(String aggregateType, String aggregateField,  Set<String> fldstoQuery, 
            String objectName, string whereClause){
        List<String> fieldList = new List<String>(fldstoQuery);
        List<String> crudCheckList = new List<String>(fldstoQuery);
        crudCheckList.add(aggregateField);
       
        //List<OpportunityLineItem> oliList; 
        CSM_Util.checkCRUD_FLS(objectName, crudCheckList, CSM_Constants.DML_OPERATION_READ);
        String sQuery = 'Select '+ aggregateType + '(' +aggregateField + '), '  +
                          String.join(fieldList, ',')+ 
                        
                        ' From '+objectName+
                          ' Where '+whereClause+ 
                          ' Group By '+String.join(fieldList, ',')+
                          ' limit 10000 ';
        system.debug('Query : '+sQuery);                  
        return Database.query(sQuery);
        //return oliList;  
    }
    
    public static Map<ID, sObject> getObjectMapByWhereClause(Set<String> fldstoQuery,string objectName, string whereClause){
        return getObjectMapByWhereClause(fldstoQuery, objectName, whereClause, 10000);
    }
    
    public static Map<ID, sObject> getObjectMapByWhereClause(Set<String> fldstoQuery,string objectName, string whereClause, Integer recordLimit){
        List<String> fieldList = new List<String>(fldstoQuery);
        //List<OpportunityLineItem> oliList; 
        CSM_Util.checkCRUD_FLS(objectName, fieldList, CSM_Constants.DML_OPERATION_READ);
        String sQuery = 'Select '+String.join(fieldList, ',')+ ' From '+objectName+
                          ' Where '+whereClause+ ' limit ' + recordLimit;
        return new Map<ID, sObject>((List<sObject>)Database.query(sQuery));
    }
   
    /** 
    * @description: This is used to format (i.e add commas) input string. Added for DE1497.
    * @returns Formatted value i.e i\p --> 1234567890.90  o\p --> 1,234,567,890.90
    */ 
    public static String getFormattedValue(String value){  
        if(value == null || String.isBlank(value)){
            return null;
        }
        if(value.contains(',')){
            return value;
        }
        value = value.remove(''); 
        
        Decimal toRound = Decimal.valueOf(value);  
        system.debug('~~~: toRound:::  ' + toRound );  
        String roundedValue = String.valueOf(toround.setScale(2,RoundingMode.CEILING));
        system.debug('~~~: roundedValue:::  ' + roundedValue );  
        
        String str =  roundedValue.substringBefore('.');
        String [] strArray = convertStringToCharArray(Str);
        Integer count = 0;
        String formatedValue = '';
        Integer t = strArray.size()-1;
        for(Integer i = strArray.size();i>=1; i--){
            formatedValue = strArray[t]  + formatedValue ;
            t--;
            count++;
            if(count == 3){
                formatedValue = ',' +formatedValue ;
                count  = 0;
            }
        }
        system.debug('~~~:B4 getFormattedValue() :::  ' + formatedValue );
        formatedValue = formatedValue.removeStart(',') + '.' + roundedValue.subStringAfter('.');
        system.debug('~~~: getFormattedValue() :::  ' + formatedValue );
        return formatedValue;
    }    
    
    /** 
    * @description: This method returns the map of picklist values and labels mainly used for translation.
    */
    public static Map<String,String> getPickListValueMap(String objectName,String pickListfieldName){
        Schema.SObjectField fldDesc;
        SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
        fldDesc=sObj.getSobjectType().getDescribe().fields.getMap().get(pickListfieldName);
        if(fldDesc != null){
            List<Schema.PicklistEntry> pickListValues = fldDesc.getDescribe().getPicklistValues();
            return CHL_PartnerOverviewUtil.populatePickListValues(pickListValues);
        } else {
            return null;
        }
     }
    
    /** 
    * @description: This method returns the map of locale formats required for angular grid in the channel portal.
                    This locale format helps to format the dates and the numbers in channel community.
    */
    public static String getAngularGridLocaleForUserLocale(String userLocale){
      Map<String,String> localeMap = new Map <String,String>();
      localeMap.put('pt_PT','pt'); //Portugese
      localeMap.put('pt_BR','pt-br'); //Brazilian Portugese
      localeMap.put('en_US','en-us'); //English US
      localeMap.put('zh_CN','zh-cn'); //Simplified Chinese
      
      return localeMap.containsKey(userLocale) ? localeMap.get(userLocale) : userLocale.tolowerCase().replaceAll('_','-');
    }
    
    /** 
    * @description: This method returns the map of Picklist value and its label.
                    This map helps to get the translation of picklist values.
                    Method accepts picklist field name in Schema.DescribeFieldResult.
    */
    public static Map<String,String> getPicklistValuesMap(Schema.DescribeFieldResult fieldResult) {
        Map<String,String> picklistValueLabelMap = new Map<String,String>();
        for( Schema.PicklistEntry plVal : fieldResult.getPicklistValues()) {
            picklistValueLabelMap.put(plVal.getvalue(),plVal.getlabel());
        }
        return picklistValueLabelMap;
    }
    
    
    /** 
    * @description: This method returns the the opportunity stages by the type OPEN /CLOSED WON / CLOSED LOST
    */
    
    public static Set<String> getOpportunitySalesStageByType(String stageType){
      
      String queryStr = 'Select MasterLabel from OpportunityStage';
      String queryWhereClause = '';
      
      if(stageType.containsIgnoreCase('OPEN'))
          queryWhereClause = ' where isClosed = false';
      else if(stageType.containsIgnoreCase('WON'))    
          queryWhereClause = ' where isClosed = true AND isWon=true';
      else if(stageType.containsIgnoreCase('LOST'))
          queryWhereClause = ' where isClosed = true AND isWon=false';  
      else if(stageType.containsIgnoreCase('CLOSED'))    
          queryWhereClause = ' where isClosed = true';   
      queryStr += queryWhereClause;
      
      List<OpportunityStage> opptyStageList = Database.query(queryStr);
      Set<String> opptyStages = new Set<String>();
      for(OpportunityStage optStg:opptyStageList) {
        opptyStages.add(optStg.MasterLabel);    
      }
      /*String opptyStageByType = '';      
      for(OpportunityStage optStg:opptyStages)
          opptyStageByType += '\''+optStg.MasterLabel +'\',';
      opptyStageByType = opptyStageByType.subString(0,opptyStageByType.length()-1);*/
      return  opptyStages;   
    }
    
    
    /** 
    * @description: This method returns the map of language code and language name,
                    this map helps to find portal content for corresponding language
    */
    public static String getLanguageForUserLanguageCode(String userLangCode){
      Map<String,String> languageMap = new Map <String,String>();
      languageMap.put('fr','French'); //French
      languageMap.put('de','German'); //German
      languageMap.put('en_US','English'); //English US
      
      return languageMap.containsKey(userLangCode) ? languageMap.get(userLangCode) : userLangCode;
    }
    
    
    
     /**
     * @description : Used to get information for all languages from user object .
     */     
     public static Map<String, String> fetchUserLanguagePicklistValue(){
       Map<String, String> languageMap = new Map<String, String>();
       Schema.PicklistEntry[] languages = Schema.SObjectType.User.fields.LanguageLocaleKey.PicklistValues;
       for (PicklistEntry language : languages) {
         if(language.isActive()) {
           languageMap.put(language.getValue(), language.getLabel());
         }
       }
       return languageMap;
     }
    
    
    public static Map<String, String> getMapOfLangAndCode(){
       Map<String, String> languageMap = new Map<String, String>();
       Schema.PicklistEntry[] languages = Schema.SObjectType.User.fields.LanguageLocaleKey.PicklistValues;
       for (PicklistEntry language : languages) {
         if(language.isActive()) {
           languageMap.put(language.getLabel(),language.getValue());
         }
       }
       return languageMap;
     }

    
    
    public static Map<String,String> getActiveLanguges()    {
      //List<CHL_Opportunity_Status_Log__c> opptySalesStages = CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
      String actvLanguages = '';
      Map<String,String> savedActiveLang = new Map<String,String>();
      if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null){
          for(CHL_Opportunity_Status_Log__c oppStatusLog : CHL_OpptyStatusLogDataAccess.opptyStatusLogList){
            actvLanguages = oppStatusLog.CHL_Active_Languages__c;
          }
     
        if(actvLanguages != null && String.isNotBlank(actvLanguages)){
            Set<String> allActiveLang = CHL_Util.splitStages(actvLanguages);
            savedActiveLang = CHL_Util.splitLanguages(new List<string>(allActiveLang));
        }else{
            savedActiveLang.put('en_US','English');
        }
      }
     return savedActiveLang;
   }    
    public static Map<String,String> splitLanguages(List<String> lstLang){
        Map<String, String> mLangMap = new Map<String,String>();
        if(lstLang!=null&&lstLang.size()>0){
            for(String lang: lstLang){
                List<String> pairOfLangCode = lang.split('-');
                if(pairOfLangCode.size()>1)
                mLangMap.put(pairOfLangCode[0],pairOfLangCode[1]);
           }
        }
        
      return mLangMap;
    }
    
    public static String getFormatFieldsFromFieldSet(String fieldSetName,String ObjectName) {
        String colNames = '';
        String queryString;
        Set<String> fields = new Set<String>();  
        String fieldAPIName ;
        String lookupField;
        String nameSpace = CSM_Util.getNamespace();
        List <Schema.FieldSetMember> fieldSetList = CHL_Util.getFieldSet(fieldSetName, ObjectName);    
        for (Schema.FieldSetMember fld: fieldSetList) {
            fieldAPIName = string.valueof(fld.getFieldPath());              
            if(string.valueof(fld.getType()) == 'REFERENCE' && !fieldAPIName.contains('.') && !fieldAPIName.contains('Owner') && fieldAPIName.contains('__c')) {       
                lookupField = fieldAPIName.replace('__c', '__r');
                lookupField = lookupField+'.Name';
                fields.add(lookupField);                                    
            } else if(string.valueof(fld.getType()) == 'REFERENCE' && fieldAPIName.endsWith('Id')) {
                lookupField = fieldAPIName.removeEnd('Id');
                lookupField = lookupField+'.Name';
                fields.add(lookupField);      
            } else if(string.valueof(fld.getType()) == 'DATE' || string.valueof(fld.getType()) == 'DATETIME') {
                lookupField = 'format('+fieldAPIName+')';
                fields.add(lookupField); 
            }
            //add only unique fields  
            if(!fields.contains(fieldAPIName) && (string.valueof(fld.getType()) != 'DATE' && string.valueof(fld.getType()) != 'DATETIME')) {  
                //maintain a set of fields so that only unique fields are added in query 
               fields.add(fieldAPIName);                         
            }
        }
        for( String fs : fields ) { 
            colNames += fs+',';
        }
        colNames = colNames.removeEnd(',');
        system.debug('\n\n colNames::'+colNames);
        queryString = 'Select  ' + colNames +  ' From '+ ObjectName;
        system.debug('\n\n QueryString :: ' + queryString);
        return queryString;
    }
    
	//Added for US2383
    public static Set<String> getFieldsFromFieldSet(String fieldSetName,String ObjectName) {
        
        Set<String> fields = new Set<String>();  
        String fieldAPIName ;
        String lookupField;
        String nameSpace = CSM_Util.getNamespace();
        List <Schema.FieldSetMember> fieldSetList = CHL_Util.getFieldSet(fieldSetName, ObjectName);   
        if (ObjectName == 'Contact' ){
            fields.add('AccountId');
        }  
        if(CSM_AccessController.hasField(ObjectName, 'OwnerId')) {
            fields.add('Owner.Name');
        } 
        if(CSM_AccessController.hasField(ObjectName, 'Name') ) {
            fields.add('Name');
        }
        if (ObjectName == CHL_Constants.OBJ_QUOTE && CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')){
            fields.add(CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c');
            fields.add(CHL_Constants.OBJ_QUOTE_TOTAL);
            fields.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Quote__c');
            fields.add(CHL_Util.quoteExtnNameSpace + 'CHL_Reseller_Primary__c');
            fields.add(CHL_Util.quoteExtnNameSpace + 'CHL_MSRP__c');
        }
        
        if (ObjectName == nameSpace+CHL_Constants.OBJ_PT_OPPORTUNITY ){
            fields.add(nameSpace + 'CHL_Partner_Account_1__c');
            fields.add(nameSpace + 'CHL_Partner_Account_1_Type__c');
            fields.add(nameSpace + 'CHL_Partner_Account_2__c');
            fields.add(nameSpace + 'CHL_Partner_Account_2_Type__c');
            fields.add(nameSpace + 'CHL_MSRP__c');
        }
        if (ObjectName == nameSpace + CHL_Constants.OBJ_PT_RENEWAL_RELATIONSHIP){
            fields.add(nameSpace + 'CHL_Partner_Opportunity__r.CHL_Incumbent__c');
        }
        for (Schema.FieldSetMember fld: fieldSetList) {
            fieldAPIName = string.valueof(fld.getFieldPath());              
            if(string.valueof(fld.getType()) == 'REFERENCE' && !fieldAPIName.contains('.') && !fieldAPIName.contains('Owner') && fieldAPIName.contains('__c')) {       
                lookupField = fieldAPIName.replace('__c', '__r');
                lookupField = lookupField+'.Name';
                fields.add(lookupField);                                    
            } else if(fieldAPIName.contains('Product2Id') && string.valueof(fld.getType()) == 'REFERENCE'){
                List < String > relatedListColName = fieldAPIName.split('\\.');
                //lookupField =  relatedListColName[0] +'.Product2.Name,';
                lookupField =  relatedListColName[0] +'.Product2.Name';
                fields.add(lookupField); 
            }   else if(fieldAPIName.contains('ParentId') && string.valueof(fld.getType()) == 'REFERENCE'){
                if(ObjectName == 'Case'){
                    lookupField = 'Parent.CaseNumber';
                    fields.add(lookupField); 
                }else {
                    lookupField = 'Parent.Name';
                    fields.add(lookupField); 
                }
            }   else if(fieldAPIName.contains('AccountId') && string.valueof(fld.getType()) == 'REFERENCE'){
                lookupField = 'Account.Name';
                fields.add(lookupField); 
            }   else if(fieldAPIName.contains('LastModifiedById') && string.valueof(fld.getType()) == 'REFERENCE'){
                lookupField = 'LastModifiedBy.Name';
                fields.add(lookupField); 
            }    
            
            
            //add only unique fields  
            if(!fields.contains(fieldAPIName)){  
                //maintain a set of fields so that only unique fields are added in query 
                
               fields.add(fieldAPIName);                         
            }
        }
        
        if(ObjectName.equals('QuoteLineItem')){
            fields.add('Id');
            //fields.add(CHL_Util.quoteExtnNameSpace+'REN_Original_Line_Item_ID__c');
            fields.add(CHL_Util.quoteExtnNameSpace+'CHL_Cross_Sell_Id__c');
            fields.add('Product2.Name');
            fields.add('Product2.Id');
            List<REN_Field_Mappings__c> lstOfFldMapping = REN_FieldMappingsDataAccess.getFieldMappingListByConfig('QuoteLineItem','QuoteLineItem');
            Set<String> frmFldSet = new Set<String>();
            Set<String> toFldSet = new Set<String>();
            REN_Util.getFromAndToFldsToQuery(lstOfFldMapping,frmFldSet,toFldSet);
            fields.addAll(frmFldSet);
            fields.addAll(toFldSet);
        }

        return fields;
    }
    
    public static Set<String> getCurrencyFldsFromFldSet(String fldSetName, String sobjectName) {     	
		Set<String> currencyFldSet = new Set<String>();
		List<Schema.FieldSetMember> fldsFromFldSet = CHL_Util.getFieldSet(fldSetName, sobjectName); 
		
		for (Schema.FieldSetMember fldMember : fldsFromFldSet) {
			if (fldMember.getType() == Schema.DisplayType.Currency) {
				//the type of the field is currency, so add it to the currencyfldset
				//fieldAPIName = string.valueof(fld.getFieldPath());
				currencyFldSet.add(string.valueof(fldMember.getFieldPath()));
			}
		}
		System.debug('currencyFldSet in getCurrencyFldsSet===' + currencyFldSet);
    	return currencyFldSet;
    }
    
    //public static map<Id,String> CreateMapOfObjIdNPrice(list<sObject> sObjectList , String ObjName, set<Id> accHierarchyIdSet, String fieldSetName) {
    public static Map<Id,Map<String, String>> CreateMapOfObjIdNPrice(list<sObject> sObjectList , String ObjName, set<Id> accHierarchyIdSet, String fieldSetName) {
    	Set<String> currencyFldsFromFldSet = new Set<String>();
    	
    	currencyFldsFromFldSet = CHL_Util.getCurrencyFldsFromFldSet(fieldSetName, ObjName);
    	
		Map<Id,Map<String, String>> mapOfObjIdNcolmnameNPrice = new Map<Id,Map<String, String>>();
		String namespace = '' ;
		sObject newobj;
		String colName = '';
		String scObjFromFldName = '';
		sObject scObj;
		String scNamespace = '' ;
		if (ObjName == 'ContractLineItem') {
			for (String s : currencyFldsFromFldSet) {
				if (s.contains('.') && s.split('\\.')[0] == 'ServiceContract') {
					scObjFromFldName = 'ServiceContract';
				}
			}
		}
		for(sObject sObj:sObjectList){
			Map<String, String> mapOfColmNameNPrice = new Map<String, String>();
			/*if(ObjName == 'ServiceContract') {
				newobj = sObj.getSObject('ServiceContract');
				namespace = CSM_Util.nameSpacePrefix21;
				//columnname = 'TotalPrice';
			} else {
				newobj = sObj;
				namespace = CSM_Util.getNamespace();
				//columnname = 'Price';
			}*/
			if (String.isNotBlank(scObjFromFldName) && (scObjFromFldName == 'ServiceContract') || ObjName == 'ContractLineItem') {
				scObj = sObj.getSObject('ServiceContract');
				namespace = CSM_Util.nameSpacePrefix21;
				ObjName = 'ServiceContract';
			} else {			
				//newobj = sObj;
				namespace = CSM_Util.getNamespace();
			}

			System.debug('accHierarchyIdSet===' + accHierarchyIdSet);
			
			//if(ObjName == 'Asset' || (CSM_AccessController.hasField(ObjName, namespace + 'CHL_Partner_Account_1__c') && CSM_AccessController.hasField(ObjName, namespace + 'CHL_Partner_Account_2__c'))){
			if(ObjName == 'Asset' || (CSM_AccessController.hasField(ObjName, namespace + 'CHL_Partner_Account_1__c') && CSM_AccessController.hasField(ObjName, namespace + 'CHL_Partner_Account_2__c'))){
	    	 	system.debug('IN D IF OF hasfield : '+namespace);
	    	 	//if(accHierarchyIdSet.contains((ID)newobj.get(namespace + 'CHL_Partner_Account_1__c')) || accHierarchyIdSet.contains((ID)newobj.get(namespace + 'CHL_Partner_Account_2__c'))) {
	    	 	if (ObjName == 'ServiceContract' && (accHierarchyIdSet.contains((ID)scObj.get(namespace + 'CHL_Partner_Account_1__c'))  || accHierarchyIdSet.contains((ID)scObj.get(namespace + 'CHL_Partner_Account_2__c')))) {
	    	 		System.debug('hello1===');
	    	 		for (String fldName : currencyFldsFromFldSet) {
    	 				if (fldName.contains('.') && fldName.split('\\.')[0] == 'ServiceContract') {
    	 					System.debug('hello2===');
    	 					mapOfColmNameNPrice.put(fldName, String.valueOf(scObj.get(fldName.split('\\.')[1])));
    	 					mapOfObjIdNcolmnameNPrice.put(sObj.Id, mapOfColmNameNPrice);
    	 				} else {
    	 					System.debug('hello3===');
	    	 				mapOfColmNameNPrice.put(fldName, String.valueOf(sObj.get(fldName)));
	    	 				mapOfObjIdNcolmnameNPrice.put(sObj.Id, mapOfColmNameNPrice);
    	 				}
    	 			} 
	    	 	} else if (ObjName == 'ServiceContract' && !(accHierarchyIdSet.contains((ID)scObj.get(namespace + 'CHL_Partner_Account_1__c'))  || accHierarchyIdSet.contains((ID)scObj.get(namespace + 'CHL_Partner_Account_2__c')))) {
	    	 		System.debug('hello4===');
	    	 		for (String fldName : currencyFldsFromFldSet) {
    	 				mapOfColmNameNPrice.put(fldName, '0.0');
    	 				mapOfObjIdNcolmnameNPrice.put(sObj.Id,mapOfColmNameNPrice);
    	 			}
	    	 	} else if(accHierarchyIdSet.contains((ID)sObj.get(namespace + 'CHL_Partner_Account_1__c')) || accHierarchyIdSet.contains((ID)sObj.get(namespace + 'CHL_Partner_Account_2__c'))) {
	    	 	//if(accHierarchyIdSet.contains((ID)scObj.get(namespace + 'CHL_Partner_Account_1__c')) || accHierarchyIdSet.contains((ID)scObj.get(namespace + 'CHL_Partner_Account_2__c'))) {
    	 			//mapOfObjIdNPrice.put(sObj.Id,String.valueOf(sObj.get(columnname)));
    	 			System.debug('hello5===');
    	 			for (String fldName : currencyFldsFromFldSet) {
    	 				mapOfColmNameNPrice.put(fldName, String.valueOf(sObj.get(fldName)));
    	 				mapOfObjIdNcolmnameNPrice.put(sObj.Id, mapOfColmNameNPrice);
    	 			}    	 			
    	 		} else {
    	 			//mapOfObjIdNPrice.put(sObj.Id,'0.0');
    	 			System.debug('hello6===');
    	 			for (String fldName : currencyFldsFromFldSet) {
    	 				mapOfColmNameNPrice.put(fldName, '0.0');
    	 				mapOfObjIdNcolmnameNPrice.put(sObj.Id,mapOfColmNameNPrice);
    	 			}
    	 		}
			} else {
    	 		//mapOfObjIdNPrice.put(sObj.Id,'0.0');
    	 		System.debug('hello7===');
    	 		for (String fldName : currencyFldsFromFldSet) {
	    	 		mapOfColmNameNPrice.put(fldName, '0.0');
	    	 		mapOfObjIdNcolmnameNPrice.put(sObj.Id,mapOfColmNameNPrice);
    	 		}
    	 	}
    	 }
    	 System.debug('mapOfObjIdNcolmnameNPrice===' + mapOfObjIdNcolmnameNPrice); 
    	 return mapOfObjIdNcolmnameNPrice;
	}
	
	/** 
    * @description: This method returns the charater array of String. Added as part of DE2440.
    */
	public static String[] convertStringToCharArray(String inputStr) {
	    List<Integer> charValueList = new List<Integer>();
	    List<String> strList = new List<String> ();
	
	    for (Integer i = 0; i <= inputStr.length() - 1; i++) {
	        charValueList.add(inputStr.charAt(i));
	        System.debug(String.fromCharArray(charValueList));
	        strList.add(String.fromCharArray(charValueList));
	        charValueList.clear();
	    }
	    System.debug(strList);
	
	    String[] strArray = new String[strList.size()];
	    Integer j = 0;
	    for (String charValue: strList) {
	        strArray[j++] = charValue;
	    }
	    return strArray;
	}
	
	public static List<User> getPartnerUsersByAccount(Set<Id> accountIds){
		String userLicense = 'Partner Community%';
		String userProfile = 'PRISM Channel%';
		String userType = 'PowerPartner';
		String queryString = 'SELECT id,name,ContactId,AccountId,Email,Account.Name,Contact.AccountId FROM User WHERE User.Profile.UserLicense.Name LIKE :userLicense '+
		                ' AND User.Profile.Name LIKE :userProfile AND UserType = :userType AND AccountId IN:accountIds AND isActive = true';
		return Database.query(queryString);  
	}
	
	/* This method is used to check if QuoteAsyncBatch is currently running.  */
	public static Boolean isBatchRunning(String batchName){
		Boolean isBatchRunning = false;
		//Boolean isDataServiceUser = false;
		List<AsyncApexJob> batchJobs = REN_AsyncUtil.getRunningJobs(batchName, 'BatchApex');
		List<AsyncApexJob> scheduleJobs = REN_AsyncUtil.getRunningJobs('CHL_QuoteSyncBatchScheduledDispatcher', 'ScheduledApex');
		/*
		if(batchJobs != null && !batchJobs.isEmpty()){		
			isDataServiceUser = SS_LicenseCheck.getInstance().isCustomPermissionAssignedByUser(SS_Constants.PS_DataServicesUser, batchJobs[0].CreatedById);			
		}
		else if(scheduleJobs != null && !scheduleJobs.isEmpty()){
			isDataServiceUser = SS_LicenseCheck.getInstance().isCustomPermissionAssignedByUser(SS_Constants.PS_DataServicesUser, scheduleJobs[0].CreatedById);	
		}*/
		if((batchJobs != null && batchJobs.size() > 0) || (scheduleJobs != null && scheduleJobs.size() > 0)){
			isBatchRunning = true;
		}
		return isBatchRunning;
	}
	
	public static List<User> getPartnerUsersByAccountForSegment(Set<Id> accountIds){
		String queryString = 'SELECT id,AccountId, CHL_Use_Cookies_for_Channel__c FROM User WHERE AccountId IN:accountIds';
		return Database.query(queryString);  
	}
}