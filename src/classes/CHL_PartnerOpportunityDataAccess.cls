/**
* @description    CHL_PartnerOpportunityDataAccess validates the user permission on the partner
*                 opportunity records that are being queried for.             
*/

public with sharing class CHL_PartnerOpportunityDataAccess {
    
    public static List<CHL_Partner_Opportunity__c> getPartnerOptyByOpportunityId(Set<Id> oppIdSet) {
        List<String> partnerOpportunityFieldList = new List<String>{'CHL_Opportunity__c', 'CHL_Sales_Stage__c','CHL_Syncing__c','CHL_Partner_Account_1_Contact__c','CHL_Partner_Account_2_Contact__c'};
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PARTNER_OPPORTUNITY, partnerOpportunityFieldList, CSM_Constants.DML_OPERATION_READ);
        return [Select CHL_Opportunity__c, CHL_Sales_Stage__c, Name, CHL_Color_Commit__c, CHL_Close_Date__c, CHL_Expiration_Date__c, CHL_EQ__c, 
        CHL_FY__c, CHL_Partner_Account_1_Type__c, CHL_Partner_Account_2_Type__c,
        CHL_Partner_Account_1__c,CHL_Incumbent__c,
        CHL_Partner_Account_2__c,CHL_Syncing__c,
        CHL_Partner_Account_1_Contact__c,CHL_Partner_Account_2_Contact__c from CHL_Partner_Opportunity__c where CHL_Opportunity__c IN:oppIdSet LIMIT 10000];
    }
  
    public static List<CHL_Partner_Opportunity__c> getPartnerOptyByOpportunity(Set<Id> oppIdSet) {
        List<String> partnerOpportunityFieldList = new List<String>{CHL_Constants.OBJ_PO_SYNCING,'CHL_Opportunity__c' };
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PARTNER_OPPORTUNITY, partnerOpportunityFieldList, CSM_Constants.DML_OPERATION_READ);
        List<CHL_Partner_Opportunity__c> partnerOppList = [Select Id, CHL_Syncing__c,CHL_Opportunity__c 
                                                            from CHL_Partner_Opportunity__c 
                                                            where (CHL_Opportunity__c IN:oppIdSet and  CHL_Syncing__c != null) order by lastmodifieddate desc LIMIT 10000];
        return partnerOppList;
    }
  
    //Set to fetch all Available stages for community portal
    //public static set<String> availableStages = CHL_Util.getAvailableSalesStage(); //!= null ? CHL_Util.getAvailableSalesStage() : new set<String> ()
    
    /**
    * @description : This method returns a list of SHARE records that can be of type 
    *                 opportunityshare or partneropportunityshare records.
    * @param List of users who need the access for opportunity and partner opportunity
    * @param List of Opportunity / Partner Opportunity records
    * @param The object type the share record belongs to : Opportunity / Partner Opportunity
   */
    
    public static List<SObject> generateRecordShareList(List<Id> userIds,List<SObject> partnerOpportunities,String SObjectType,List<Id> publicGroupIds) {
       List<SObject> partnerShareRecsList = new List<SObject>();
       //String partnerOptyId, userId;
       for(SObject parOppty:partnerOpportunities){
           for(Id UserId : userIds){
                sObject sObj = Schema.getGlobalDescribe().get(SObjectType).newSObject() ;  
                sObj.put(CHL_CONSTANTS.STR_USERGROUPID , UserId) ;              
                if(SObjectType == CHL_CONSTANTS.OBJ_OPPORTUNITYSHARE){
                    sObj.put(CHL_CONSTANTS.STR_OPPOTUNITYID , parOppty.id) ;
                    sObj.put(CHL_CONSTANTS.STR_OPPOTUNITYACCESS , CHL_CONSTANTS.STR_EDIT) ;   
                    sObj.put(CHL_CONSTANTS.STR_ROWCAUSE , CHL_CONSTANTS.STR_MANUAL);
                }              
                partnerShareRecsList.add(sObj);
           }
           for(Id publicGroupId : publicGroupIds){
                sObject sObj = Schema.getGlobalDescribe().get(SObjectType).newSObject() ;  
                sObj.put(CHL_CONSTANTS.STR_USERGROUPID , publicGroupId) ;              
                if(SObjectType == CHL_CONSTANTS.OBJ_OPPORTUNITYSHARE){
                    sObj.put(CHL_CONSTANTS.STR_OPPOTUNITYID , parOppty.id) ;
                    sObj.put(CHL_CONSTANTS.STR_OPPOTUNITYACCESS , CHL_CONSTANTS.STR_EDIT) ;   
                    sObj.put(CHL_CONSTANTS.STR_ROWCAUSE , CHL_CONSTANTS.STR_MANUAL);
                }                     
                partnerShareRecsList.add(sObj);
           }
       }
       
       return partnerShareRecsList;
    }//End of method
   
     /**
    * @description : This is a utility method that can be used for granting access to the partner opportuntiy
    *                and the assocaited master opportunity. This method returns the share records for the
    *                partner opportunities and its associated master opportunities.
    * @param List of users who need the access for opportunity and partner opportunity
    * @param List of Partner Opportunity records.
   */ 
    public static ShareRecordWrapper prepareRecordShareList(List<Id> userIds,List<CHL_Partner_Opportunity__c> partnerOpportunities,List<Id> publicGroupIds) {
     
        Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>();
        String nameSpace=CSM_Util.getNamespace();
        String partnerObjStr = nameSpace <>''?nameSpace +''+CHL_Constants.OBJ_PT_Opportunity_Share:CHL_Constants.OBJ_PT_Opportunity_Share;
        ShareRecordWrapper recShareWrapper = new ShareRecordWrapper();
       
        for(CHL_Partner_Opportunity__c parOppty:partnerOpportunities){
            opptyMap.put(parOppty.CHL_Opportunity__c,new Opportunity(id=parOppty.CHL_Opportunity__c));
        }
        CHL_InsertPartnerOptyShareRecord partnerOptyShare = new CHL_InsertPartnerOptyShareRecord();
        
            
        if(CHL_Util.sObjectExists(partnerObjStr)){ 
            //recShareWrapper.partnerOpptyShare = generateRecordShareList(userIds,partnerOpportunities,partnerObjStr);
            partnerOptyShare.createPartnerOptyShareList(userIds,partnerOpportunities,publicGroupIds);
        }
       /* @ Below code modified for US1381 (Channel Portal - Pro-grammatically Share Partner Opportunities with Channel Users)
             Added try-Catch block for sharing opportunity without checking if OWD is private. 
             If OWD is Public read/write for opportunity, then it will not create share records due to try-catch block.
        */
        //try { try-catch reverted as part of DE1572
            if(CHL_Util.isOWDForOpportunityPrivate() ){     
                recShareWrapper.opptyShare=  generateRecordShareList(userIds,opptyMap.values(),CHL_Constants.OBJ_OpportunityShare,publicGroupIds);
            }
        /*catch(Exception ex){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage());
            ApexPages.addMessage(msg);
        }*/
        return recShareWrapper;
    }//End of method
    
    //Wrapper class for Opportunity and partner opportunity share records
    
    public class ShareRecordWrapper{
           public List<SObject> opptyShare = new List<SObject>();
           public List<SObject> partnerOpptyShare = new List<SObject>();
    }
    
   /**
    * @description : This  method that can be used for obtaining the Renewal relationship details i.e  asset and ServiceContract for the particular Opportunity.
    * @param OopportunityId
    * @param List of Renewal Relationship records.
   */  
   public static list<REN_Renews_To__c> getRenewedRelationsDetailByOppId(String oppID){
        List<REN_Renews_To__c> renewalRelationList = new List<REN_Renews_To__c>();
        List<String> renewRelationFields = new List<String>{REN_Constants.OBJ_REN_RENEWS_TO_ASSET, 
                                                            REN_Constants.OBJ_REN_RENEWS_TO_RENEWS_TO
                                                           };
        
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REN_RENEWS_TO, renewRelationFields, CSM_Constants.DML_OPERATION_READ); 
        String columnString = CSM_Util.getColumns(REN_Constants.OBJ_REN_RENEWS_TO);
        columnString += ', REN_Product__r.name, REN_Asset__r.name, REN_Asset__r.Quantity ';
        if (CSM_AccessController.hasField('REN_Renews_To__c', CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c')){
            columnString += ',' + CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__r.name';
        }
        String queryString = 'Select ' + columnString + ' from ' + REN_Constants.OBJ_REN_RENEWS_TO + ' where REN_Renews_To__c =: oppID limit 1000';
        renewalRelationList = Database.query(queryString);
        return renewalRelationList;
        
    }
    
    
    /**
    * @description : This method returns the records from Partner Opportunity object, matching the partner Opportunity Ids
    * @param Partner Opportunity Ids
   */ 
    public static List<CHL_Partner_Opportunity__c> getPartnerOpportunityDataById(set<Id> partnerOptyIds){
        
        List<CHL_Partner_Opportunity__c> partnerOptyList = new List<CHL_Partner_Opportunity__c>();
        CSM_Util.checkCRUD_FLS(CSM_Util.getNamespace() + CHL_Constants.OBJ_PARTNER_OPPORTUNITY, CHL_Constants.PARTNER_OPP_FEILD_LIST, CSM_Constants.DML_OPERATION_READ); 
        String columnString = CSM_Util.getColumns(CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY);
        columnString = columnString + ' , '+CSM_Util.getNamespace() +CHL_Constants.OBJ_PO_RESELLER_REP_NAME_COL + ', '+ CSM_Util.getNamespace() +CHL_Constants.OBJ_PO_DISTRIBUTOR_REP_NAME_COL + ',' + CSM_Util.getNamespace() + 'CHL_Opportunity__r.accountID';
        String queryString = 'Select ' + columnString + ' from ' + CSM_Util.getNamespace() + CHL_Constants.OBJ_PARTNER_OPPORTUNITY + ' where Id in :partnerOptyIds limit 10000' ;
        system.debug('\n\n~~~~ queryString: FOR partnerOptyIds ' + queryString +partnerOptyIds);
        partnerOptyList = Database.query(queryString);
        return partnerOptyList;
    }//end of Method
    
     //Added For US1490 
    public static List<CHL_Partner_Opportunity__c> getPartnerOppDetailForOptyGrid(set<Id> partnerOptyIds){
        List<CHL_Partner_Opportunity__c> partnerOptyList = new List<CHL_Partner_Opportunity__c>();
        CSM_Util.checkCRUD_FLS(CSM_Util.getNamespace() + CHL_Constants.OBJ_PARTNER_OPPORTUNITY, CHL_Constants.PARTNER_OPP_FEILD_LIST, CSM_Constants.DML_OPERATION_READ); 
        String columnToSelect = CHL_PartnerOpportunityBusinessLayer.getOptyGridFieldsInSOQL(); //Added US1490
        String queryString;
        queryString = 'Select ' + columnToSelect + ' from ' + CSM_Util.getNamespace() + CHL_Constants.OBJ_PARTNER_OPPORTUNITY + ' where Id in :partnerOptyIds limit 10000' ;
        system.debug('\n\n~~~~ queryString: FOR partnerOptyIds ' + queryString +partnerOptyIds);
        partnerOptyList = Database.query(queryString);
        return partnerOptyList;
    }//end of Method
    
   
    //*************** US1119 ****** Chart updation ****************** 
     public static List<AggregateResult> getChartDataByFilter(String whereClause){
        String queryString;
        String qtrAndYearClause;
        String nameSpace = CSM_Util.getNamespace();
        boolean is2TierPricingEnable = false;
        Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <> null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
        if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty()){
            is2TierPricingEnable  = (Boolean)(CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0]).get(nameSpace+'CHL_Enable_2_Tier_Pricing__c');
            //currentUserAccountType = CHL_Util.currentUserDetails[0].Account.CHL_Partner_Account_Type__c;
        }
        CSM_Util.checkCRUD_FLS(nameSpace +CHL_Constants.OBJ_PARTNER_OPPORTUNITY, CHL_Constants.PARTNER_OPP_FEILD_LIST, CSM_Constants.DML_OPERATION_READ);   
        if(string.isBlank(whereClause)) {
            whereClause = '';
        } else {
            whereClause = ' Where ' + whereClause + ' AND CHL_Opportunity__r.REN_Is_CLM_Renewal__c = true';
        }   
        if(CHL_Constants.STR_RESELLER.equalsIgnoreCase(currentUserAccountType) && is2TierPricingEnable) {
            queryString = 'Select CHL_Sales_Stage__c, SUM(CHL_MSRP__c) Total, CHL_Needs_Status_Update__c From '+ nameSpace +'CHL_Partner_Opportunity__c c ' + whereClause +' group by c.CHL_Sales_Stage__c,CHL_Needs_Status_Update__c limit 10000';
        } else {    
            queryString = 'Select CHL_Sales_Stage__c, SUM(CHL_Amount__c) Total, CHL_Needs_Status_Update__c From '+ nameSpace +'CHL_Partner_Opportunity__c c ' + whereClause +' group by c.CHL_Sales_Stage__c,CHL_Needs_Status_Update__c limit 10000';
        }
            system.debug('whereClause : '+whereClause+'::\n'+queryString);
        //}
        List<AggregateResult> aggResultList = Database.query(queryString);
        return aggResultList;
    }
 
   /**
    * @description : This method returns the partner opportunites where the NEEDS STATUS update is TRUE. This methods returns the partner 
    *                opportunity count which the user has access to.
    * @param : 
    */  
    public Static Integer fetchNeedsStatusUpdate(){
        //Set<String> availableStages = CHL_Util.getAvailableSalesStage();
        List<CHL_Opportunity_Status_Log__c> opptyStatusLogList = CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PARTNER_OPPORTUNITY, new List<String>{CHL_Constants.OBJ_PO_NEED_STATUS_UPDATE,CHL_Constants.OBJ_PO_SALES_STAGE}, CSM_Constants.DML_OPERATION_READ);
        if(!opptyStatusLogList.isEmpty() && opptyStatusLogList[0].CHL_Show_Oppty_for_Unavailable_Stage__c == true) {
            return [Select Count() from CHL_Partner_Opportunity__c where CHL_Opportunity__r.REN_Is_CLM_Renewal__c = true AND CHL_Needs_Status_Update__c = true AND CHL_Sales_Stage__c <>null limit 10000];
        } else {
            Set<String> availableStages = CHL_Util.getAvailableSalesStage();
            return [Select Count() from CHL_Partner_Opportunity__c where CHL_Opportunity__r.REN_Is_CLM_Renewal__c = true AND CHL_Needs_Status_Update__c = true AND CHL_Sales_Stage__c in :availableStages limit 10000];
        }
        
        
    }//end of Method
   
    /**
    * @description : This method count of partner opportunites and sum of Amount by sales stage.
    */
   // To fetch fetchExpiredMatrix - return
    public static List<AggregateResult> getAllExpiredPartnerOpportunities(){
        set<String> pipeLineStages = CHL_Util.getPipelineSalesStage();
        List<String> partnerOppFieldList = new List<String> {CHL_Constants.OBJ_PO_SALES_STAGE,
                                                            CHL_Constants.OBJ_PO_AMOUNT};
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PARTNER_OPPORTUNITY, partnerOppFieldList, CSM_Constants.DML_OPERATION_READ);
        String nameSpace = CSM_Util.getNamespace();
        boolean is2TierPricingEnable = false;        
        Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <> null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
        List<AggregateResult> renOppList = new List<AggregateResult>();
        if(CHL_OpptyStatusLogDataAccess.opptyStatusLogList != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty()){
            is2TierPricingEnable  = (Boolean)(CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0]).get(nameSpace+'CHL_Enable_2_Tier_Pricing__c');
            //currentUserAccountType = CHL_Util.currentUserDetails[0].Account.CHL_Partner_Account_Type__c;
        }
        Set<String> excludeStageSet = CHL_Util.getOpportunitySalesStageByType('CLOSED');
        //List<String> excludeStagesList = new List<String>{'Closed Won'};//excludeStage
        system.debug('excludeStage : '+excludeStageSet);
        if(CHL_Constants.STR_RESELLER.equalsIgnoreCase(currentUserAccountType) && is2TierPricingEnable) {
            renOppList = [select CHL_Sales_Stage__c stage, count(id) oppCounts ,sum(CHL_MSRP__c) sumAmount FROM CHL_Partner_Opportunity__c where CHL_Opportunity__r.REN_Is_CLM_Renewal__c = true AND CHL_Sales_Stage__c NOT IN :excludeStageSet and CHL_Expiration_Date__c <:system.today() AND CHL_Expiration_Date__c <>null AND CHL_Sales_Stage__c in :pipeLineStages  group by CHL_Sales_Stage__c limit 10000];
        } else {
            renOppList = [select CHL_Sales_Stage__c stage, count(id) oppCounts ,sum(CHL_Amount__c) sumAmount FROM CHL_Partner_Opportunity__c where CHL_Opportunity__r.REN_Is_CLM_Renewal__c = true AND CHL_Sales_Stage__c NOT IN :excludeStageSet and CHL_Expiration_Date__c <:system.today() AND CHL_Expiration_Date__c <>null AND CHL_Sales_Stage__c in :pipeLineStages group by CHL_Sales_Stage__c limit 10000]; // AND CHL_Sales_Stage__c in :pipeLineStages
        }
        system.debug('renOppList : '+renOppList);
        return renOppList;
    }//end of Method
    
    
   /**
    * @description : This method returns the records from Partner Opportunity object with the list  of Notes created.Added DE868
    * @param Partner Opp ID.
   */ 
   public static Map<ID, CHL_Partner_Opportunity__c> getNotesByPartnerOppID(Set<String> pOppIdSet){
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PARTNER_OPPORTUNITY, new List<String>{CHL_Constants.OBJ_PO_NAME,CHL_Constants.FL_ID}, CSM_Constants.DML_OPERATION_READ);
        Map<ID, CHL_Partner_Opportunity__c> pOppNotesMap = new Map<ID, CHL_Partner_Opportunity__c> ([Select c.Name, c.Id, (Select Body, CreatedDate From Notes order by CreatedDate desc) From CHL_Partner_Opportunity__c c where id in :pOppIdSet]);
        return pOppNotesMap;
   }//end of Method
    
    /**
    * @description : This method returns the detail of Partner Opportunity object such as Resellers/distributors/stages which will be used on Overview tab
    * @param List of coloums and where condition.
   */ 
    public static List<CHL_Partner_Opportunity__c> getPartnerOppDetails(List<String> partnerOppColList, String whereCondition ){
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PARTNER_OPPORTUNITY, CHL_Constants.PARTNER_OPP_FEILD_LIST, CSM_Constants.DML_OPERATION_READ);
        String colNames = '';
        
        for(String col : partnerOppColList){
            colNames  += col + ',';
        }
        
        String coloum = colNames.removeEnd(',');
        String queryString = 'SELECT '+ coloum +  ' FROM '+ CSM_Util.getNamespace() +'CHL_Partner_Opportunity__c ' + whereCondition + ' limit 10000';
        system.debug('\n\n @@ queryString:: ' + queryString);
        List<CHL_Partner_Opportunity__c>  partnerOppList = Database.query(queryString);
        return partnerOppList;
    }//end of Method
    
    /**
    * @description : This method returns COUNT of the new channel partner opportunities created from last week, for the logged in user contact
    */      
    public static Integer fetchLastWeekOpportunitiesCount(){ 
        List<CHL_Opportunity_Status_Log__c> opptyStatusLogList = CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PARTNER_OPPORTUNITY, new List<String>{CHL_Constants.OBJ_PO_DISTRIBUTOR_REP,CHL_Constants.CASE_CREATED_DATE,CHL_Constants.OBJ_PO_RESELLER_REP,CHL_Constants.OBJ_PO_SALES_STAGE}, CSM_Constants.DML_OPERATION_READ);
        //String contactID = (String)CHL_Util.currentUserDetails[0].get('ContactId');//CHL_Util.fetchContactIdOfUser(userInfo.getUserId());
        //and ((CHL_Partner_Account_1_Contact__c=:contactID or CHL_Partner_Account_2_Contact__c=:contactID) or (CHL_Partner_Account_1_Contact__c=null AND CHL_Partner_Account_2_Contact__c=null)) 
        if(!opptyStatusLogList.isEmpty() && opptyStatusLogList[0].CHL_Show_Oppty_for_Unavailable_Stage__c == true) {
            return [Select Count() from CHL_Partner_Opportunity__c where CreatedDate=THIS_WEEK and CHL_Opportunity__r.REN_Is_CLM_Renewal__c = true AND CHL_Sales_Stage__c <>null limit 10000];
        } else {
            Set<String> availableStages = CHL_Util.getAvailableSalesStage();
            return [Select Count() from CHL_Partner_Opportunity__c where CreatedDate=THIS_WEEK and CHL_Opportunity__r.REN_Is_CLM_Renewal__c = true AND CHL_Sales_Stage__c in :availableStages limit 10000];
        }
        return null;
      }
      
    /**
    * @description : It is created as part of US908, This method returns the records from Partner Opportunity object, records related to account of MO 
    * @param accountId to filter based on Account of Master opportunity
    */ 
    public static List<CHL_Partner_Opportunity__c> getPartnerOpportunityDataByAccount(string accountId){
        Set<String> availableStages = CHL_Util.getAvailableSalesStage();
        //Added for US1024
        string whereClauseforStage = getWhereClauseforStage(availableStages);
        List<CHL_Partner_Opportunity__c> partnerOptyList = new List<CHL_Partner_Opportunity__c>();
        CSM_Util.checkCRUD_FLS(CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY, CHL_Constants.PARTNER_OPP_FEILD_LIST, CSM_Constants.DML_OPERATION_READ); 
        String columnString = CHL_PartnerOpportunityBusinessLayer.getOptyGridFieldsInSOQL();
        //columnString = columnString + ' , '+CHL_Constants.OBJ_PO_RESELLER_REP_NAME_COL + ', '+ CHL_Constants.OBJ_PO_DISTRIBUTOR_REP_NAME_COL+ ' , CHL_Opportunity__r.AccountId';
        String queryString = 'Select ' + columnString + ' from ' + CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY + ' where ' + CSM_Util.getNamespace() +CHL_Constants.OBJ_PO_MO_ACCOUNT + '  =:accountId AND '+ whereClauseforStage +' limit 10000' ;
        system.debug('\n\n~~~~ queryString: FOR NEEDS UPDATE 11 :: ' + queryString );
        partnerOptyList = Database.query(queryString);
        return partnerOptyList;
    }
    
    public static void updatePartnerOpportunity(List<CHL_Partner_Opportunity__c> listToUpdate) {        
        CSM_Util.checkCRUD_FLS(CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY, CHL_Constants.PARTNER_OPP_FEILD_LIST, CSM_Constants.DML_OPERATION_UPDATE); 
        update listToUpdate;
    }
    
    public static List<Database.SaveResult> updatePartnerOpportunity(List<CHL_Partner_Opportunity__c> partnerOpptyToUpdate, Boolean allOrNone) {        
        List<String> updateFieldList = new List<String>{CHL_Constants.OBJ_PO_AMOUNT};//, CHL_Constants.OBJ_QUOTELI_MSRP}; 
        CSM_Util.checkCRUD_FLS(CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY, updateFieldList, CSM_Constants.DML_OPERATION_UPDATE); 
        return Database.update(partnerOpptyToUpdate, allOrNone);
    }
    
     public static List<SObject> insertPartnerOpportunity(List<SObject> partnerOppList) {       
        CSM_Util.checkCRUD_FLS(CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY, CHL_Constants.PARTNER_OPP_FEILD_LIST, CSM_Constants.DML_OPERATION_INSERT); 
        insert partnerOppList;
        return partnerOppList;
    }
    
    public static void insertShareRecords(Id partnerAcc1, Id partnerAcc2,CHL_Partner_Opportunity__c partnerOppObj,List<Id> publicGroupIds){
        CHL_PartnerOpportunityDataAccess.ShareRecordWrapper shareRecWrapper = new CHL_PartnerOpportunityDataAccess.ShareRecordWrapper();
        Set<Id> partnerAccIds = new Set<Id> ();
        
        //To fetch Account  and all the child Accounts ID.
        partnerAccIds = CHL_Util.getAccAndParentAccIDs(partnerAcc1, partnerAcc2);
        List<ID> userID = new List<Id>();

        for (User u: [Select id from User where Contact.AccountId in : partnerAccIds AND isActive = true])
            userID.add(u.id);
            shareRecWrapper = CHL_PartnerOpportunityDataAccess.prepareRecordShareList(userID, new List <CHL_Partner_Opportunity__c> {
            partnerOppObj
        },publicGroupIds);
        try {
            insert shareRecWrapper.opptyShare;
        } 
        catch(Exception ex){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage());
            ApexPages.addMessage(msg);
        }
        //insert shareRecWrapper.partnerOpptyShare; //This is commented, as share records for partner opportunity will be inserted in withoutsharing class, to add custom share reason.
    }
    
    /*
    @Description: Below method will get call from Opportunity trigger, if any of it's partner opportunity is having syncing option as 'From Master Opporunity'
    */
    public static List<CHL_Partner_Opportunity__c> getPartnerOptyFromSync(Set<Id> oppIdSet) {
        List<String> partnerOpportunityFieldList = new List<String>{CHL_Constants.OBJ_PO_SYNCING , 'CHL_Opportunity__c'};
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PARTNER_OPPORTUNITY, partnerOpportunityFieldList, CSM_Constants.DML_OPERATION_READ);
        List<CHL_Partner_Opportunity__c> partnerOppList = [Select Id, CHL_Syncing__c,CHL_Opportunity__c from CHL_Partner_Opportunity__c where CHL_Syncing__c like 'From%' and CHL_Opportunity__c in :oppIdSet limit 1000];
        return partnerOppList;
    }
    
    /*
    @Description: Return the list of Incumbent PO. Added for US937
    */
    public static List<CHL_Partner_Opportunity__c> getIncumbentPartnerOpty(Set<ID> partnerOppIdSet) {
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_PARTNER_OPPORTUNITY,new List<String>{'id',CHL_Constants.OBJ_PO_INCUMBENT}, CSM_Constants.DML_OPERATION_READ);
        List<CHL_Partner_Opportunity__c> partnerOppList = [select Id from CHL_Partner_Opportunity__c where id in :partnerOppIdSet and CHL_Incumbent__c = true];
        return partnerOppList;
    }
    
  
    //created below method for US1024
    public static string getWhereClauseforStage(set<String> availableStages) {
        //List<CHL_Opportunity_Status_Log__c> opptyStatusLogList = CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
        List<String> poSalesStages = CHL_Util.fetchPartnerOppStagePicklistValues();
        string whereClauseforStage = '';
        if(!CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty() 
                && CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0].CHL_Show_Oppty_for_Unavailable_Stage__c == true) {
            whereClauseforStage = 'CHL_Sales_Stage__c IN ( \''+String.join(poSalesStages, '\',\'')+'\')' ; //'CHL_Sales_Stage__c <> null';
        } else {
            whereClauseforStage = 'CHL_Sales_Stage__c in :availableStages';
        }
        return whereClauseforStage;
    }
        
    //Below without sharing class is created to share PO record, as we have created custom sharing reason, User who not have access will face permission issue
    public without sharing class CHL_InsertPartnerOptyShareRecord {
    
        public void createPartnerOptyShareList(List<Id> userIds,List<SObject> partnerOpportunities,List<Id> publicGroupIds) {
            List<SObject> partnerShareRecsList = new List<SObject>();
            for(SObject parOppty:partnerOpportunities){
                for(Id UserId : userIds)    {
                    sObject poSObj = Schema.getGlobalDescribe().get(CSM_Util.getNamespace()+CHL_Constants.OBJ_PT_Opportunity_Share).newSObject();
                    poSObj.put(CHL_CONSTANTS.STR_USERGROUPID , UserId) ;                
                    poSObj.put(CHL_CONSTANTS.STR_ROWCAUSE , CSM_Util.getNamespace()+CHL_CONSTANTS.STR_SHARE_REASON) ; 
                    poSObj.put(CHL_CONSTANTS.STR_PARENT , parOppty.Id) ;
                    poSObj.put(CHL_CONSTANTS.STR_ACCESSLEVEL , CHL_CONSTANTS.STR_EDIT) ; 
                    partnerShareRecsList.add(poSObj);
                }
                for(Id publicGroupId : publicGroupIds)  {
                    sObject poSObj = Schema.getGlobalDescribe().get(CSM_Util.getNamespace()+CHL_Constants.OBJ_PT_Opportunity_Share).newSObject();
                    poSObj.put(CHL_CONSTANTS.STR_USERGROUPID , publicGroupId) ;                
                    poSObj.put(CHL_CONSTANTS.STR_ROWCAUSE , CSM_Util.getNamespace()+CHL_CONSTANTS.STR_SHARE_REASON) ; 
                    poSObj.put(CHL_CONSTANTS.STR_PARENT , parOppty.Id) ;
                    poSObj.put(CHL_CONSTANTS.STR_ACCESSLEVEL , CHL_CONSTANTS.STR_EDIT) ; 
                    partnerShareRecsList.add(poSObj);
                }
            }
            insert partnerShareRecsList;
        }

    }   
    public static List<SObject> getPartnerOpportunityBySOSL(CHL_GridInputWrapper inputWrapper)
    {
        List<SObject> partnerOpportunityList = new List<SObject>();
        String nameSpacePrefix = CSM_Util.getNamespace();
        Integer queryLimit = inputWrapper.lm == 5 ? 5 : 2000;
        String queryString = 'FIND\''+ inputWrapper.queryParams.q +'*\' IN All Fields Returning '+nameSpacePrefix+'CHL_Partner_Opportunity__c ('+CHL_PartnerOpportunityBusinessLayer.getOptyGridFieldsInSOQL()+' ORDER BY Name Asc) Limit '+queryLimit;
        List<List<SObject>>searchList = search.query(queryString);
        system.debug('searchList::'+searchList.size()+'::'+searchList);
        if(searchList != null && !searchList.isEmpty() && searchList.size()>0){
            partnerOpportunityList.addAll(searchList[0]);
        }
        return partnerOpportunityList;
    }
    
    public static List<CHL_Partner_Opportunity__c> getPartnerOpportunitiesByCriteria(String whereClause) {
        system.debug('where clause :::::'+whereClause);
        String columnString = CHL_PartnerOpportunityBusinessLayer.getOptyGridFieldsInSOQL();
        string whereClauseforStage = '';
        Set<String> availableStages = CHL_Util.getAvailableSalesStage();
        whereClauseforStage = getWhereClauseforStage(availableStages);
        if(String.isNotBlank(whereClause)) {
            if(whereClause.ContainsIgnoreCase('Quote')) { //This condition is temporary fix as HAS_QUOTE Predicate not works with Parenthesis, It should get remove once we create new field for quote.
                whereClause = ' Where ('+ whereClause + ' AND CHL_Opportunity__r.REN_Is_CLM_Renewal__c = true AND '+whereClauseforStage+')';
            } else {
                if(whereClause.contains(system.label.CSM_LBL_ALL)) {
                    Set<String> excludeStageSet = CHL_Util.getOpportunitySalesStageByType('CLOSED');
                    whereClause = whereClause.replace('IN (\''+system.label.CSM_LBL_ALL+'\')', ' NOT IN :excludeStageSet ');
                }
                whereClause = ' Where ('+ whereClause + ') AND (CHL_Opportunity__r.REN_Is_CLM_Renewal__c = true AND '+whereClauseforStage+')';
            }
        }
        String queryString = 'Select ' + columnString + ' from ' + CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY + whereClause;
        system.debug('\n\n~~~~ queryString: getPartnerOpportunitiesByCriteria:: ' + queryString );
        return Database.query(queryString);
    }
    
    
    
    public static list<CHL_Partner_Opportunity__c> getPoDetailsbyFieldset(set<string> oppIds, String fieldSetName) {
    	
        List<CHL_Partner_Opportunity__c> partnerOptyList = new List<CHL_Partner_Opportunity__c>();
        CSM_Util.checkCRUD_FLS(CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY, CHL_Constants.PARTNER_OPP_FEILD_LIST, CSM_Constants.DML_OPERATION_READ); 
        String queryString = CHL_Util.getFormatFieldsFromFieldSet(fieldSetName, CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY);
        queryString = queryString + '  where CHL_Opportunity__c IN :oppIds limit 1000';
        //queryString = 'SELECT ' + queryString.removeStart(',');
        List<CHL_Partner_Opportunity__c> PartnerOpportunityList= Database.query(queryString);
        return PartnerOpportunityList;     
    }
    
    public static List<CHL_Partner_Opportunity__c> getPOListbyFields(Set<Id> oppIds, Set<String> requestedFieldsSet) {
    	List<String> fieldsList =  new List<String>();
        fieldsList.addAll(requestedFieldsSet);
		CSM_Util.checkCRUD_FLS(CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY, fieldsList, CSM_Constants.DML_OPERATION_READ);        
		String queryString = CSM_Util.getSOQLString(CSM_Util.getNamespace() +CHL_Constants.OBJ_PARTNER_OPPORTUNITY, requestedFieldsSet, 'CHL_Opportunity__c IN:oppIds', null, null);
        List<CHL_Partner_Opportunity__c> PartnerOpportunityList = Database.query(queryString);
        return PartnerOpportunityList;     
    }
}