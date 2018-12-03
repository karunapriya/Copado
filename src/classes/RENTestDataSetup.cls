/**
 * @author       Chandra Prakash (Chandra@comitydesigns.com)    
 * @date         28/05/2015
 * @description  RENTestDataSetup: This class should be used as as centralized test data creation. 
 *               Developer should follow pattern and standards for defining new methods.
 */
public class RENTestDataSetup {
    
    public String prefixName{get{ return prefixName==null?'':prefixName;} set;}
    
    public List<Product2> product2List{get; set;}
    public List<PricebookEntry> pricebookEntryList{get; set;}
    
    public Map<String, REN_Renew_Configuration__c> renewConfigurationMap{get; set;}
    
    public List<Account> accountList{get; set;}
    public List<Opportunity> opportunityList{get; set;}
    public List<OpportunityLineItem> opportunityLineItemList{get; set;}
    public List<REN_Renew_Configuration__c> renewConfigList{get; set;}
    public List<REN_Batch_Activity__c> batchActivityList{get; set;}
    
    
    public RENTestDataSetup() {}
    public RENTestDataSetup(String prefixName) {
        this.prefixName = prefixName;
    }
    
    public List<sObject> setFieldsData(List<sObject> objectList, String fieldName, Object fieldValue) {
        for(sObject obj: objectList){
            obj.put(fieldName, fieldValue);
        }
        return objectList;
    }
    /*
    public Map<String, REN_Renew_Configuration__c> createRenewConfigurations(){
        renewConfigurationMap = new Map<String, REN_Renew_Configuration__c>();
        List<REN_Renew_Configuration__c> renewConfigurationList = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(null);
        if(renewConfigurationList != null){
            for(REN_Renew_Configuration__c rConfig: renewConfigurationList){
                renewConfigurationMap.put(rConfig.REN_Record_Key__c, rConfig);
            }
        }       
        
        renewConfigurationMap.put('Opportunity_To_Renew_Opportunity', createRenewConfigurationbyRecordKey('Opportunity_To_Renew_Opportunity','StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c != true', renewConfigurationMap));
        renewConfigurationMap.put('Opportunity_To_Asset' , createRenewConfigurationbyRecordKey('Opportunity_To_Asset','StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c != true', renewConfigurationMap));
        renewConfigurationMap.put('Opportunity_To_Service_Contract' , createRenewConfigurationbyRecordKey('Opportunity_To_Service_Contract','StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c != true', renewConfigurationMap));
        renewConfigurationMap.put('Opportunity_Product_To_Renew_Opportunity_Product' , createRenewConfigurationbyRecordKey('Opportunity_Product_To_Renew_Opportunity_Product','',renewConfigurationMap));
        renewConfigurationMap.put('Asset_To_Renew_Opportunity_Product' , createRenewConfigurationbyRecordKey('Asset_To_Renew_Opportunity_Product','', renewConfigurationMap));
        renewConfigurationMap.put('Contract_Line_Item_To_Renew_Opportunity_Product' , createRenewConfigurationbyRecordKey('Contract_Line_Item_To_Renew_Opportunity_Product','', renewConfigurationMap));
        renewConfigurationMap.put('Opportunity_Product_To_Asset' , createRenewConfigurationbyRecordKey('Opportunity_Product_To_Asset','', renewConfigurationMap));
        renewConfigurationMap.put('Opportunity_Product_To_Contract_Line_Item', createRenewConfigurationbyRecordKey('Opportunity_Product_To_Contract_Line_Item','', renewConfigurationMap));
        upsert renewConfigurationMap.values();
        return renewConfigurationMap;
    }
    */
    public REN_Renew_Configuration__c createRenewConfigurationByRecordKey(String recordKey, String filterCondition, Map<String, REN_Renew_Configuration__c> renewConfigurationMap){
        string renUpdateOn = '';
        if(recordKey == 'Opportunity_To_Renew_Opportunity') {
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
         /*
        ServiceSource1.CSM_Constants.ACCOUNT_PLAN_TRIGGER = isActive;
        ServiceSource1.CSM_Constants.ACCOUNT_TRIGGER = isActive;
        ServiceSource1.CSM_Constants.CASE_TRIGGER = isActive;
        ServiceSource1.CSM_Constants.OPPORTUNITY_TRIGGER = isActive;
        ServiceSource1.CSM_Constants.OPPORTUNITY_TRIGGER_BEFORE = isActive;
        ServiceSource1.CSM_Constants.PLAY_CRITERIA_TRIGGER = isActive;
        ServiceSource1.CSM_Constants.PLAY_RESULT_TRIGGER = isActive;
        ServiceSource1.CSM_Constants.TASK_TRIGGER = isActive;
        ServiceSource1.REN_Constants.ASSET_TRIGGER = isActive;
        ServiceSource1.REN_Constants.CONTRACTLINEITEM_TRIGGER = isActive;
        ServiceSource1.REN_Constants.OPPORTUNITYLINEITEM_TRIGGER = isActive;
        //TODO: Add all here
        */
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
            List<Pricebook2> pbList = [Select p.Name, p.IsStandard, p.IsActive, p.Id From Pricebook2 p where p.IsStandard = true LIMIT 1];
            if(pbList != null && !pbList.isEmpty()){
                pricebook2Id = pbList[0].id;
            }
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
                newOpportunity.Name = prefixName + 'Original Opp ' + i;
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
                RLM_Value__c = configType=='Grouping'? '':'abc',
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
}