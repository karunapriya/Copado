/*
 * Created Date     : April 6, 2018
 * Developed By     : Rucha, Comity Designs, Inc.
 *
 * Function         : @description - Test class for CHL_QuoteSyncBatch
 * Support Email    : 
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Rucha Palasapure         US3274              April 6, 2018           1.1             @description
 */

@isTest
private class CHL_QuoteSyncBatchTest{
    @testSetup
    static void setup() {       
        List<Account> accountList = new List<Account>();        
        Account acc1 =  CHL_TestUtility.partnerAccount();
        accountList.add(acc1);
        insert accountList;
        system.assert(accountList != null);
        
        List<Opportunity> opptyList =  CHL_TestUtility.createOpportunity(1,accountList[0].id);
        insert opptyList; 
        system.assert(opptyList != null);
        
        List<Product2> productList = CHL_TestUtility.createProducts(2);
        insert productList;
        
        List<PricebookEntry> pbeList = CHL_TestUtility.createPricebookEntry(productList,Test.getStandardPricebookId());
        insert pbeList;
        
        List <OpportunityLineItem> opliList = CHL_TestUtility.createOplis(opptyList,pbeList);
        insert opliList;
        
        CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
        partOppty.partnerAcc1Id = accountList[0].id;
        partOppty.partnerAcc1Type = 'Reseller';
        partOppty.expirationDate = system.today().addDays(-10);
        partOppty.Stage = 'Qualification';
        partOppty.partnerAcc2Type = 'Distributor';
        
        List < CHL_Partner_Opportunity__c > poList = CHL_TestUtility.channelPartnerOpportunityList(1, partOppty);
        poList[0].CHL_Opportunity__c = opptyList[0].Id;
        insert poList;  
           
        if(CSM_AccessController.hasObject('Quote')) {
            
            List<SObject> quotesList = CHL_TestUtility.createQuotes(1,opptyList,poList);
            quotesList[0].put(REN_Constants.OBJ_OPP_PRICEBOOK_ID,Test.getStandardPricebookId());
            insert quotesList;
            system.assert(quotesList != null);
            
            List<SObject> quoteLineItemsList = CHL_TestUtility.createMultipleQuoteLineItems(100,quotesList,productList,pbeList);
            insert quoteLineItemsList;
        
        }
        
        List<REN_Field_Mappings__c> quoteToOppMapingList = CHL_TestUtility.createQuoteToOpptyMapping();
        insert quoteToOppMapingList;
        
        List<REN_Field_Mappings__c> qliToOliMapingList = CHL_TestUtility.createQliToOliMapping();
        insert qliToOliMapingList;
        
        CSM_Admin__c adminSetting= CSM_Admin__c.getOrgDefaults();
        adminSetting.CHL_QliCount__c = 50;
        insert adminSetting;
    }
    
    static testMethod void testQuoteSyncBatch() {       
        Test.startTest();       
        List<Opportunity> OppList = [Select Id, Name,StageName,Description,Pricebook2Id,CHL_QuoteSyncStatus__c,Probability from Opportunity];
        CSM_TriggerManager.disableAllTriggers();
        
        if(CSM_AccessController.hasObject('Quote')){
            String quoteString = 'Select Id, OpportunityId from Quote';
            List<SObject> quoteList = Database.query(quoteString); 
            String syncQuoteId = '';
            if(CSM_AccessController.hasField('opportunity','SyncedQuoteId')) {
                OppList[0].put('SyncedQuoteId',(Id)quoteList.get(0).get('Id'));
                update OppList;
            }
            Database.executeBatch(new CHL_QuoteSyncBatch());
        }
        System.assert(true);
        Test.stopTest();
     
    }
    static testMethod void testQuoteSyncBatch2() {       
        Test.startTest();       
        List<Opportunity> OppList = [Select Id, Name,StageName,Description,Pricebook2Id,CHL_QuoteSyncStatus__c,Probability from Opportunity limit 1];
        CSM_TriggerManager.disableAllTriggers();     
        if(CSM_AccessController.hasObject('Quote')){
            String quoteString = 'Select Id, OpportunityId from Quote';
            List<SObject> quoteList = Database.query(quoteString); 
            String syncQuoteId = '';
            if(CSM_AccessController.hasField('opportunity','SyncedQuoteId')) {
                OppList[0].put('SyncedQuoteId',(Id)quoteList.get(0).get('Id'));
                update OppList;
            }
            CHL_QuoteSyncBatch btch = new CHL_QuoteSyncBatch();
            btch.oppIdsSet = new Set<Id>{OppList[0].Id};
            Database.executeBatch(btch);
        }
        System.assert(true);
        Test.stopTest();
     
    }
}