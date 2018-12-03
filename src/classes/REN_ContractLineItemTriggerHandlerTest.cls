@isTest(SeeAllData=true)
private class REN_ContractLineItemTriggerHandlerTest {

    static List<Product2> productList;
    static List<PricebookEntry> pbEntryList;
    static List<Account> accountList;
    static List<SObject> serviceContractList;
    static List<SObject> contractLineItemList;

    static void setUp(){
    	CSM_Constants.OPPORTUNITY_TRIGGER = false;
        productList = new List<Product2>();
        CSM_Constants.ACCOUNT_TRIGGER = false;
        accountList = CSM_TestDataUtility.createAccount(1);
        CSM_TestDataUtility.associateRenewalOppty=true;
        serviceContractList = CSM_TestDataUtility.createServiceContract(2, accountList[0].id);
        if (serviceContractList!=null && !serviceContractList.isEmpty()){
            system.assert(accountList.get(0).Id != null);
            for(Integer i=0; i < 5; i++){
                productList.add(REN_TestDataUtility.createProduct(i));
            }
            insert productList;
            pbEntryList = new List<PricebookEntry>();
            for(Product2 prod : productList){
                pbEntryList.add(REN_TestDataUtility.createPBEntry(prod.Id));
            }
            insert pbEntryList;
            if (CSM_AccessController.hasObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM)){
                SObject contractLineItem;
                contractLineItemList = new List<SObject>();
                for(PricebookEntry pbr : pbEntryList){
                    contractLineItem = CSM_AccessController.newSObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
                    contractLineItem.put(REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID,pbr.Id);
                    contractLineItem.put(REN_Constants.OBJ_SCLI_QUANTITY,1);
                    contractLineItem.put(REN_Constants.OBJ_OLI_UNITPRICE,pbr.UnitPrice);
                    contractLineItem.put(REN_Constants.OBJ_SCLI_STARTDATE,Date.Today());
                    contractLineItem.put(REN_Constants.OBJ_SCLI_ENDDATE,Date.Today().addYears(1));
                    contractLineItem.put(REN_Constants.OBJ_SCLI_SERVICECONTRACTID, serviceContractList[0].Id);
                    contractLineItemList.add(contractLineItem); 
                }
            }       
            
            List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
            renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
            //renewConfigurationList.add(REN_TestDataUtility.createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,'StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c=false'));
            //renewConfigurationList.add(REN_TestDataUtility.createRenewConfigurationbyRecordKey(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT,'StageName=\'Closed Won\' AND REN_Is_CLM_Renewal__c=false'));
            upsert renewConfigurationList;
            List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS, 'DATE', 'StartDate', 'CloseDate', 'ServiceContract', 'Opportunity', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS, 'REFERENCE', 'OwnerId', 'OwnerId', 'ServiceContract', 'Opportunity', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS, 'STRING', 'Name', 'Name', 'ServiceContract', 'Opportunity', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS, 'BOOLEAN', 'IsPrivate', null, 'ServiceContract', 'Opportunity', true, 'false'));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS, 'PICKLIST', 'StageName', null, 'ServiceContract', 'Opportunity', true, 'Closed Won'));
            
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY, 'REFERENCE', 'OwnerId', 'OwnerId', 'Opportunity', 'ServiceContract', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY, 'STRING', 'Name', 'Name', 'Opportunity', 'Opportunity', true, ''));
            
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY, 'DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'ContractLineItem', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY, 'STRING', 'Description', '', 'OpportunityLineItem', 'ContractLineItem', true, 'Test Data'));

            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS, 'DOUBLE', 'Quantity', 'Quantity', 'ContractLineItem', 'OpportunityLineItem', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_OPPT_TO_SERVICE_CONTRACTS, 'DOUBLE', 'UnitPrice', 'UnitPrice', 'ContractLineItem', 'OpportunityLineItem', true, ''));

            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'Asset', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'UnitPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
            fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'TotalPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
            REN_FieldMappingsDataAccess.upsertFieldMappings(fMappingList);
        }
    }
    
    static testMethod void Test_InsertContractLineItems(){

        Test.startTest();
        setUp();
        if (contractLineItemList!=null && !contractLineItemList.isEmpty()){
        	system.debug('contractLineItemList -'+contractLineItemList);
            
            insert contractLineItemList;
            Map<ID, sObject> newRecordsMap = new Map<ID, sObject>();
            newRecordsMap.putAll(contractLineItemList);
            List<SObject> oldContractLineItemList = new List<SObject>();
            oldContractLineItemList.addAll(contractLineItemList);
            REN_ContractLineItemTriggerHandler cliH = new REN_ContractLineItemTriggerHandler();
            cliH.onAfterInsert(contractLineItemList, newRecordsMap);
            System.assert(contractLineItemList!=null);
            
            REN_Constants.CONTRACTLINEITEM_TRIGGER = true;
            update contractLineItemList;
            Map<ID, sObject> oldRecordsMap = new Map<ID, sObject>();
            oldRecordsMap.putAll(oldContractLineItemList);
            newRecordsMap.putAll(contractLineItemList);
            cliH.onAfterUpdate(oldContractLineItemList, contractLineItemList, oldRecordsMap, newRecordsMap);
            
            REN_Constants.CONTRACTLINEITEM_TRIGGER = true;
            delete contractLineItemList;

            oldRecordsMap = new Map<ID, sObject>();
            oldRecordsMap.putAll(oldContractLineItemList);
            cliH.onBeforeDelete(oldContractLineItemList, oldRecordsMap);
        }
        Test.stopTest();
    }
}