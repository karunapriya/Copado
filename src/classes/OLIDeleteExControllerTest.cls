@isTest
public with sharing class OLIDeleteExControllerTest {
    
    @testSetup  
    static void setup(){
        
        List<Account> accountList = new List<Account>();
        Account newAccount = new Account();
        newAccount.Name =  'Test-Account ' ;
        accountList.add(newAccount);
        insert accountList;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.accountId = accountList[0].id;
        newOpportunity.Name = 'Original Opp ';
        newOpportunity.CloseDate = System.Today();
        newOpportunity.StageName = 'Contacted';
        newOpportunity.Type = 'New Customer';
        newOpportunity.Amount= 1000;
        newOpportunity.Business_Line__c = 'Core';
        newOpportunity.Client_Region__c = 'USA';
        newOpportunity.Client_Territory__c = 'USA';
        newOpportunity.Country__c = 'India';
        newOpportunity.SSI_Theatre__c = 'APJ';
        newOpportunity.Pricebook2Id = Test.getStandardPricebookId();

        opportunityList.add(newOpportunity);
        insert opportunityList;
         
        List<Product2> productList = TestUtility.createProducts(2);
        insert productList;
        
        List<PricebookEntry> pbeList = TestUtility.createPricebookEntry(productList,Test.getStandardPricebookId());
        insert pbeList;

        List <OpportunityLineItem> opliList = TestUtility.createOplis(opportunityList,pbeList);
        insert opliList;
        
        //create a quote
        List<Quote> qtList = new List<Quote>();
        Quote qt = new Quote(name = 'Test q1', opportunityid = opportunityList[0].id, pricebook2id = opportunityList[0].Pricebook2Id);
        qtList.add(qt);
        insert qtList;
        
        //create a quote line item
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qtList[0].Id;
        qli.Product2Id = productList[0].id;
        qli.Quantity = 1.0;
        qli.UnitPrice = 10.0;
        qli.PricebookEntryId = pbeList[0].id;
        insert qli;
        system.assertEquals(true, qli.id != null);
    }
    
    static testMethod void testQuoteSync(){
        Test.startTest();
            List<Opportunity> opptyList = [select Id, name,Pricebook2Id,description from opportunity limit 1];
        
            List<Quote> quoteList = [SELECT Id FROM Quote LIMIT 1];
            if(quoteList != null && !quoteList.isEmpty()){
                opptyList[0].put('SyncedQuoteId', quoteList[0].Id);
                update opptyList;
            }                       

            string opptyQuery = 'select Id, name, Pricebook2Id,description, SyncedQuoteId from opportunity limit 1';
            List<sObject> opptyList2 = Database.query(opptyQuery);
            
            OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            
            Test.setCurrentPageReference(Page.OpportunityLineDel);                     
            ApexPages.currentPage().getParameters().put('id',oli.Id);          
            ApexPages.StandardController sc = new ApexPages.StandardController(oli); 
               
            OLIDeleteExController oliDelCtrl = new OLIDeleteExController(sc);
            oliDelCtrl.removeSyncedQuote();
            oliDelCtrl.cancelAndReturnToOppt();
            
        	List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        
            system.assertEquals(true, oliList.isEmpty());
           	system.assertEquals(0, oliList.size());          
        Test.stopTest();
    }    
}