/**
 * @author       Chandra Prakash (Chandra@comitydesigns.com)    
 * @date         28/05/2015
 * @description  REN_TestDataSetup: This class should be used as as centralized test data creation. 
 *               Developer should follow pattern and standards for defining new methods.
 */
//@isTest(SeeAllData=true)
public class REN_TestDataSetup {
            private static String TEST_DATA_NAME = 'C_1_200_5-%';


    //@isTest 
    public static void testLoadAutoRenew() {
        //RENTestDataSetup testDataSetup = new RENTestDataSetup(testName);
        //testDataSetup.renewDataSetup(1, 1, 1);
        List <Account >accountList = [SELECT Id, Name FROM Account where Name like :TEST_DATA_NAME];
        List <Opportunity >lstOpp = [SELECT Id, Name, StageName, accountId FROM Opportunity where Name like :TEST_DATA_NAME AND REN_Is_CLM_Renewal__c = false  AND StageName != 'Closed Won' limit 100];
        for(Opportunity opp: lstOpp){
            //opp.REN_Append_Renewal_Opportunity__c = '006j000000NfWY6';
            //opp.REN_Append_Service_Contract__c = '810j0000000PEfM';
            opp.StageName = 'Closed Won';
        }
        system.debug('\nStart Test~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n' );
            update lstOpp;
        system.debug('\nEnd Test~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n' );
    }
    /*
    static testMethod void testTestDataSetup() {
        REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
        testDataSetup.createRenewConfigurations();
        testDataSetup.renewDataSetup(1, 1, 1);
    }
    */
    public String prefixName{get{ return prefixName==null?'':prefixName;} set;}
    
    public List<Product2> product2List{get; set;}
    public List<PricebookEntry> pricebookEntryList{get; set;}
    
    public Map<String, REN_Renew_Configuration__c> renewConfigurationMap{get; set;}
    
    public List<Account> accountList{get; set;}
    public List<Opportunity> opportunityList{get; set;}
    public List<OpportunityLineItem> opportunityLineItemList{get; set;}
    public List<REN_Renew_Configuration__c> renewConfigList{get; set;}
    public List<REN_Batch_Activity__c> batchActivityList{get; set;}
    public List<REN_Consolidation_Request__c> consolidationRequestList{get; set;}
    public List<REN_Consolidation_Request_Source__c> consolidationRequestSourceList{get; set;}
    
    
    public REN_TestDataSetup() {}
    public REN_TestDataSetup(String prefixName) {
        this.prefixName = prefixName;
    }
    
    public List<sObject> setFieldsData(List<sObject> objectList, String fieldName, Object fieldValue) {
        for(sObject obj: objectList){
            obj.put(fieldName, fieldValue);
        }
        return objectList;
    }
    
    public Map<String, REN_Renew_Configuration__c> createRenewConfigurations(){
        renewConfigurationMap = new Map<String, REN_Renew_Configuration__c>();
        List<REN_Renew_Configuration__c> renewConfigurationList = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(null);
        if(renewConfigurationList != null){
            for(REN_Renew_Configuration__c rConfig: renewConfigurationList){
                renewConfigurationMap.put(rConfig.REN_Record_Key__c, rConfig);
            }
        }       
        
        renewConfigurationMap.put(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY, createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,'StageName=\'Closed Won\'', renewConfigurationMap));
        renewConfigurationMap.put(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET , createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET,'StageName=\'Closed Won\'', renewConfigurationMap));
        renewConfigurationMap.put(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT , createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT,'StageName=\'Closed Won\'', renewConfigurationMap));
        renewConfigurationMap.put(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT , createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT,'',renewConfigurationMap));
        renewConfigurationMap.put(REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT , createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT,'', renewConfigurationMap));
        renewConfigurationMap.put(REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT , createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT,'', renewConfigurationMap));
        renewConfigurationMap.put(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET , createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET,'', renewConfigurationMap));
        renewConfigurationMap.put(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM, createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM,'', renewConfigurationMap));
        upsert renewConfigurationMap.values();
        return renewConfigurationMap;
    }
    
    public REN_Renew_Configuration__c createRenewConfigurationByRecordKey(String recordKey, String filterCondition, Map<String, REN_Renew_Configuration__c> renewConfigurationMap){
        string renUpdateOn = '';
        if(recordKey == REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY)   {
                renupdateon = 'Asset - Existing;Contract Lines - Existing;Contract Lines - New';
        }
        REN_Renew_Configuration__c renewConfig = renewConfigurationMap.get(recordKey);
        if(renewConfig == null){
            renewConfig = new REN_Renew_Configuration__c();
        }
        //renewConfig.Name = recordKey;
        renewConfig.REN_Record_Key__c = recordKey; 
        renewConfig.REN_Is_Active__c = true;
        renewConfig.REN_Update_On__c = renUpdateOn;
        renewConfig.REN_Filter_Criteria__c = filterCondition;
        return renewConfig;
    }   
    
    public void resetAllTriggersTo(boolean isActive) {
         
        REN_Util.resetTriggersTo(isActive);
        
    }

    public List<Product2> createProduct(Integer recordCount){
        product2List = new List<Product2>();
        for (integer i=1; i<=recordCount; i++){
            Product2 prod = new Product2();
            prod.Name = prefixName + 'Test Product_' + i;
            prod.IsActive = true;
            prod.ProductCode = 'TP' + i;
            product2List.add(prod);
        }
        insert product2List;
        return product2List;
    }
    
    public List<PricebookEntry> createPricebookEntry(List<Product2> product2ListParam, Id pricebook2Id){
        if(pricebook2Id == null){
        	pricebook2Id = Test.getStandardPricebookId();
        }
        pricebookEntryList = new List<PricebookEntry>();
        Integer i = 1;
        for(Product2 a: product2ListParam){
            PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = a.id;
            pbe.Pricebook2Id = pricebook2Id;
            pbe.UnitPrice = i++ * 100 + 1;
            pbe.IsActive = true;
            pricebookEntryList.add(pbe);
        }
        
        Database.insert(pricebookEntryList);
        Map<ID, Product2> product2Map = new Map<ID, Product2> (product2ListParam);
        pricebookEntryList = [Select p.Name, p.Product2Id, p.Pricebook2Id, p.Id From PricebookEntry p where p.Pricebook2Id = :pricebook2Id AND  Product2Id in :product2Map.keySet()];
        return pricebookEntryList;
    }
    
    public List<Account> createAccount(Integer recordCount) {
        accountList = new List<Account>();
        for (integer i=1; i<=recordCount; i++){
            Account newAccount = new Account();
            newAccount.Name = prefixName + 'Test-Account ' + i;
            accountList.add(newAccount);
        }
        insert accountList;
        return accountList;    
    }  
    
    public List<Opportunity> createOpportunity(Integer recordCountForEachAccount, List<Account> accountListParam){
        opportunityList = new List<Opportunity>();
        if(accountListParam == null){
            accountListParam = new List<Account>();
        }
        if(accountListParam.isEmpty()){
            accountListParam.add(new Account());
        }
        for(Account a: accountListParam){
            for(integer i=1; i<=recordCountForEachAccount; i++){
                Opportunity newOpportunity = new Opportunity();
                newOpportunity.accountId = a.id;
                newOpportunity.Name = prefixName + 'Original Opp ' + i + DateTime.now().millisecond();
                newOpportunity.CloseDate = System.Today();
                newOpportunity.StageName = 'Qualification';
                newOpportunity.Type = 'New Customer';
                opportunityList.add(newOpportunity);
            }
        }
        insert opportunityList;
        return opportunityList;
    }    

    public List<OpportunityLineItem> createOpportunityLineItem(Integer recordCountForEachOpportunity, List<Opportunity> opportunityListParam, List<PricebookEntry> pricebookEntryListParam){
        opportunityLineItemList = new List<OpportunityLineItem>();
        for(Opportunity a: opportunityListParam){
            for(integer i=1; i<=recordCountForEachOpportunity; i++){                
                opportunityLineItemList.add(new OpportunityLineItem(OpportunityId = a.Id, Quantity = i, TotalPrice = i * 100 + 1, PricebookEntryId = pricebookEntryListParam[i-1].Id,
                REN_Start_Date__c = System.today(), REN_End_Date__c = System.today()+1 )
                );
            }
        }
        insert opportunityLineItemList;
        List<OpportunityLineItem> oliList = [Select PricebookEntry.product2Id,id,OpportunityId from OpportunityLineItem where OpportunityId IN :opportunityList];
        List<REN_Renews_To__c> renLst= new List<REN_Renews_To__c>();
        System.assertnotequals(oliList,null);
        Asset asset = new Asset();
        asset.AccountId = opportunityList[0].AccountId;
        asset.Product2Id = oliList[0].PricebookEntry.product2Id;
        asset.REN_Opportunity__c = opportunityList[0].id;
        asset.Name = 'Test Asset';
        asset.Price = 20.00;
        asset.Quantity = 2;
        insert asset;
        
        for(integer i=0;i<oliList.size();i++){
                REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
                renRelationObj.Name = 'Ren-OPP';
                renRelationObj.REN_Asset__c = asset.Id;
                renRelationObj.REN_Renews_To__c = oliList[i].OpportunityId;
                //renRelationObj.REN_Renewal_Product_Line_Id__c = oliList[i].Id;
                renRelationObj.REN_Product__c = oliList[i].PricebookEntry.product2Id;
                renLst.add(renRelationObj);
        }
        insert renLst;
        
        return opportunityLineItemList;
    }
    
    public List<Opportunity> renewDataSetup(Integer totalAccounts, Integer noOfOpportunityInEachAccount, Integer noOfOpportunityLineItemInEachOppty) {
        createProduct(noOfOpportunityLineItemInEachOppty);
        createPricebookEntry(product2List, null);
        createAccount(totalAccounts);
        createOpportunity(noOfOpportunityInEachAccount, accountList);
        createOpportunityLineItem(noOfOpportunityLineItemInEachOppty, opportunityList, pricebookEntryList);
        
        System.debug(LoggingLevel.WARN,'\n\n~@~ Created Data: ' 
          + '\n product2List: ' + product2List.size() + ':- ' + product2List
          + '\n accountList: ' + accountList.size() + ':- ' + accountList
          + '\n opportunityList: ' + opportunityList.size() + ':- ' + opportunityList
          + '\n opportunityLineItemList: ' + opportunityLineItemList.size() + ':- ' + opportunityLineItemList
        );        
        
        return opportunityList;
    }

    /**
    REN_TestDataSetup dataSetup = new REN_TestDataSetup('REN-1-1-1');
    dataSetup.renewLoadDataSetup(1,1,1);
    
    TODO: Replace global with public once lode testing is done. 
    */
    public List<Opportunity> renewLoadDataSetup(Integer totalAccounts, Integer noOfOpportunityInEachAccount, Integer noOfOpportunityLineItemInEachOppty) {
        return renewDataSetup(totalAccounts, noOfOpportunityInEachAccount, noOfOpportunityLineItemInEachOppty);
    }
    
    /** It is mainly useful for Filter & Group records
    */
    public List<REN_Renew_Configuration__c> createRenewConfiguration(Integer totalRecords, String configType, String recordKey){
        renewConfigList = new List<REN_Renew_Configuration__c>();
        for (integer i=1; i<=totalRecords; i++){
            REN_Renew_Configuration__c renewConfig = new REN_Renew_Configuration__c();
            //renewConfig.Name = prefixName + configType + ': recordKey-' + i;
            renewConfig.REN_View_Name__c = prefixName + configType + ': recordKey-' + i;
            renewConfig.REN_Record_Key__c = totalRecords ==1? recordKey: renewConfig.REN_View_Name__c;
            renewConfig.REN_Is_Active__c = true;
            renewConfig.REN_Configuration_Type__c = configType;
            renewConfig.REN_Filter_Criteria__c = configType=='Grouping'? 'AccountId': 'Name != \'abc\' OR PurchaseDate = YESTERDAY';
            renewConfig.RLM_Filter_Logic__c  = configType=='Grouping'? '1,2': '1 OR 2';
            renewConfig.REN_Description__c = 'This is ' + renewConfig.REN_View_Name__c;
            renewConfigList.add(renewConfig);
        }
        insert renewConfigList;
        List<REN_Line_Criteria__c> lineCriteriaList = new List<REN_Line_Criteria__c>();
        for(REN_Renew_Configuration__c c: renewConfigList){
            lineCriteriaList.add(new REN_Line_Criteria__c(
                RLM_LineNo__c = 1,
                RLM_Field_Display_Name__c =  configType=='Grouping'? 'Account' :'Asset Name',
                RLM_Field_Name__c = configType=='Grouping'? 'Account':'Name',
                RLM_Field_Type__c = 'STRING',
                RLM_Object_API_Name__c = 'Asset',
                RLM_Operator__c = configType=='Grouping'? '':'!=',
                RLM_Values__c = configType=='Grouping'? '':'abc',
                REN_Renew_Configuration__c = c.id
            ));
            lineCriteriaList.add(new REN_Line_Criteria__c(
                RLM_LineNo__c = 2,
                RLM_Field_Name__c = 'PurchaseDate',
                RLM_Field_Display_Name__c = 'Purchase Date',
                RLM_Field_Type__c = 'DATE',
                RLM_Object_API_Name__c = 'Asset',
                RLM_Operator__c = configType=='Grouping'? '':'=',
                RLM_Date_Literal_String__c = configType=='Grouping'? '':'YESTERDAY',
                REN_Renew_Configuration__c = c.id
            ));
        }
        insert lineCriteriaList;
        return renewConfigList;
    }
    
    /** Below method will be used to create Batch Activity Records  **/
    public List<REN_Batch_Activity__c> createBatchActivity(Integer totalRecords, REN_Renew_Configuration__c groupRec, REN_Renew_Configuration__c sourceFilterRec, DateTime jobStartDate, string pbId){
        batchActivityList = new List<REN_Batch_Activity__c>();
        for (integer i=1; i<=totalRecords; i++){
            REN_Batch_Activity__c newBatch = new REN_Batch_Activity__c();
            newBatch.REN_Grouping__c = groupRec.id;
            newBatch.REN_Source_Record_Filter__c = sourceFilterRec.id;
            newBatch.REN_Job_Start_Date__c = jobStartDate;
            newBatch.REN_Pricebook__c = pbId;
            newBatch.REN_Closed_Date_Depends_On__c = 'CreatedDate';
            //newBatch.Name = 'TestBatch' + i;
            batchActivityList.add(newBatch);
        }
        insert batchActivityList;
        return batchActivityList;
    }
    public List<REN_Consolidation_Request__c> createConsolidationRequest(Integer totalRecords, List<Opportunity> oppList){
        consolidationRequestList = new List<REN_Consolidation_Request__c>();
        for (integer i=1; i<=totalRecords; i++){
            REN_Consolidation_Request__c rec = new REN_Consolidation_Request__c();
            rec.name = prefixName + i;
            rec.REN_Target_Opportunity__c = oppList[0].id;
            /*
            for (Opportunity opp: oppList){
                if(oppList[0].id != opp.id){
                    List<REN_Consolidation_Request_Source__c> consolidationRequestSourceList{get; set;}
                }
            }*/
            consolidationRequestList.add(rec);
        }
        insert consolidationRequestList;
        return consolidationRequestList;
    }
    
    public void renewBatchData()
    {
        List <Account> accountList = CSM_TestDataUtility.createAccount(1);
        system.assert(accountList != null);
        system.assert(!accountList.isEmpty());
        
        List <Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
        system.assert(opportunityList != null);
        system.assert(!opportunityList.isEmpty());
        
        String standardPriceBookId = Test.getStandardPricebookId();
        
        Product2 p2 = new Product2(Name = 'Test Product', isActive = true,ProductCode ='IN7080');
        insert p2;
        system.assert(p2.Id != null);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = p2.Id, UnitPrice = 99, isActive = true);
        insert pbe;
        system.assert(pbe.Id != null);
        
        List <OpportunityLineItem> opliList = new List <OpportunityLineItem> ();
                 OpportunityLineItem newol = new OpportunityLineItem();
                      newol.UnitPrice = 50000;
                      newol.ServiceDate = System.today();
                      newol.Description = 'Desc 1';
                      newol.Quantity = 1;
                      newol.PricebookEntryId = pbe.Id;
                      newol.OpportunityId = opportunityList[0].Id;
                opliList.add(newol);
                
                newol = new OpportunityLineItem();
                      newol.UnitPrice = 50000;
                      newol.ServiceDate = System.today();
                      newol.Description = 'Desc 2';
                      newol.Quantity = 1;
                      newol.PricebookEntryId = pbe.Id;
                      newol.OpportunityId = opportunityList[0].Id;
                opliList.add(newol);
                
                newol = new OpportunityLineItem();
                      newol.UnitPrice = 50000;
                      newol.ServiceDate = System.today();
                      newol.Description = 'Desc 1';
                      newol.Quantity = 1;
                      newol.PricebookEntryId = pbe.Id;
                      newol.OpportunityId = opportunityList[1].Id;
                opliList.add(newol);
                
                newol = new OpportunityLineItem();
                      newol.UnitPrice = 50000;
                      newol.ServiceDate = System.today();
                      newol.Description = 'Desc 2';
                      newol.Quantity = 1;
                      newol.PricebookEntryId = pbe.Id;
                      newol.OpportunityId = opportunityList[1].Id;
                opliList.add(newol);
        insert opliList;
        
        Asset asset = new Asset();
        asset.AccountId = accountList.get(0).Id;
        asset.Product2Id = p2.id;
        asset.REN_Opportunity__c = opportunityList[0].id;
        asset.Name = 'Test Asset';
        asset.Price = 20.00;
        asset.Quantity = 2;
        insert asset;
        
        /*CSM_Admin__c csmAdmin = new CSM_Admin__c();
        csmAdmin.Name = CSM_Constants.CSM_ADMIN;
        csmAdmin.REN_Oppt_Resolution_Realtime_Threshold__c = 1;
        insert csmAdmin;*/
        
        List<REN_Renewal_Processing_Status__c> renewalProcessStatus = new List<REN_Renewal_Processing_Status__c>();
                REN_Renewal_Processing_Status__c record = new REN_Renewal_Processing_Status__c();
                record.REN_Source_Opportunity__c = opportunityList[0].id;
                record.REN_Renewal_Opportunity__c = opportunityList[0].id;
            renewalProcessStatus.add(record);
            insert renewalProcessStatus;
        
    }
    
    public List<REN_Segment__c> createSegments(Integer totalRecords, String segmentType){
        List<REN_Segment__c> segments = new List<REN_Segment__c>();
        
        for(Integer i = 1; i <= totalRecords; i++) {
            REN_Segment__c segment = new REN_Segment__c();
            segment.Name = 'Segment ' + i;
            segment.REN_Description__c = 'Description ' + i;
            
            if(String.isNotEmpty(segmentType)) {
                segment.REN_Type__c = segmentType;
            }
            
            segments.add(segment);
        }
        
        insert segments;
        return segments;
    }
    
     public void consolidateOpportunityBatchData(){
        List <Account> accountList = CSM_TestDataUtility.createAccount(1);
        system.assert(accountList != null);
        system.assert(!accountList.isEmpty());
        
        List <Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
        system.assert(opportunityList != null);
        system.assert(!opportunityList.isEmpty());
        
        String standardPriceBookId = Test.getStandardPricebookId();
        
        Product2 p2 = new Product2(Name = 'Test Product1', isActive = true,ProductCode ='IN7080');
        insert p2;
        system.assert(p2.Id != null);
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = p2.Id, UnitPrice = 99, isActive = true);
        insert pbe;
        system.assert(pbe.Id != null);
        
        List <OpportunityLineItem> oliList = new List <OpportunityLineItem> ();
                 OpportunityLineItem newol = new OpportunityLineItem();
                      newol.UnitPrice = 500;
                      newol.ServiceDate = System.today();
                      newol.Description = 'Desc 1';
                      newol.Quantity = 1;
                      newol.PricebookEntryId = pbe.Id;
                      newol.OpportunityId = opportunityList[0].Id;
                oliList.add(newol);
                
                newol = new OpportunityLineItem();
                      newol.UnitPrice = 600;
                      newol.ServiceDate = System.today();
                      newol.Description = 'Desc 2';
                      newol.Quantity = 1;
                      newol.PricebookEntryId = pbe.Id;
                      newol.OpportunityId = opportunityList[0].Id;
                oliList.add(newol);
                insert oliList;
        
        REN_Consolidation_Request__c consolidateReq = new REN_Consolidation_Request__c();
        consolidateReq.REN_Target_Opportunity__c= opportunityList[1].id;
        consolidateReq.REN_Processing_Completed__c=false;
        insert consolidateReq;
        
        REN_Consolidation_Request_Source__c consolidateChild = new REN_Consolidation_Request_Source__c();
        consolidateChild.REN_Consolidation_Request__c = consolidateReq.id;
        consolidateChild.REN_Source_Opportunity__c = opportunityList[0].id ;
        insert consolidateChild;
    }
}