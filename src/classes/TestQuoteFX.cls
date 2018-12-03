@isTest
public class TestQuoteFX{
    
    @testSetup public static void createQuoteFXData() {
        
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware', IsActive = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
                                                            Pricebook2Id = pricebookId, Product2Id = prod.Id,
                                                            UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        Account acc = new Account(Name = 'testAccount');     
        insert acc;

        List<Opportunity> opptList = new List<Opportunity>();
        for(integer i = 0; i < 100; i++){
            Opportunity o = new Opportunity();
            o.Name = 'Test Oppt' + i;
            o.Pricebook2Id = pricebookId;
            o.StageName = 'Closed Won';
            o.CloseDate = System.today();
            o.AccountId = acc.Id;
            opptList.add(o);
        }
        insert opptList;
        System.assert(opptList[0].id != null);
        /*
        List<OpportunityLineItem> opptLineList = new List<OpportunityLineItem>();
        for(integer i = 0; i < opptList.size(); i++){
            OpportunityLineItem ol = new OpportunityLineItem();
            ol.OpportunityId = opptList[i].Id;
            ol.PriceBookEntryId = standardPrice.Id;
            ol.Quantity = 1;
            ol.TotalPrice = 100;
            opptLineList.add(ol);
        }
        insert opptLineList;
        */
        List<Quote> quoteList = new List<Quote>();
        for(Integer i = 0; i < 100; i++) {            
           Quote quoteObj = new Quote();
           quoteObj.Name = 'Test Quote' + i; 
           quoteObj.OpportunityId = opptList[i].id;
           quoteObj.Pricebook2Id =  opptList[i].Pricebook2Id;
           //quoteObj.Quote_Fx_Currency__c = 'EUR';
           quoteList.add(quoteObj);
        }
        /*
        for(Integer i = 100; i < 200; i++) {            
           Quote quoteObj = new Quote();
           quoteObj.Name = 'Test Quote' + i; 
           quoteObj.OpportunityId = opptList[i].id;
           quoteObj.Pricebook2Id =  opptList[i].Pricebook2Id;
           //quoteObj.Quote_Fx_Currency__c = 'GBP';
           quoteList.add(quoteObj);
        }
        */
        insert quoteList;
        Quote quoteObjUpd = (Quote) quoteList.get(1);
        //quoteObjUpd.Quote_Fx_Currency__c = 'USD';
        update quoteObjUpd;
        
        List<QuoteLineItem> quoteLineList = new List<QuoteLineItem>();
        for(integer i = 0; i < opptList.size(); i++){
            QuoteLineItem qli = new QuoteLineItem();
            qli.QuoteId = quoteList[i].Id;
            qli.PriceBookEntryId = standardPrice.Id;
            qli.Quantity = 1;
            qli.UnitPrice = 100;
            quoteLineList.add(qli);
        }
        insert quoteLineList;
        
        //Sync Quotes
        for(integer i = 0; i < opptList.size(); i++){
            opptList[i].SyncedQuoteId = quoteList[i].Id;
        }
        update opptList;
    }
    
    @isTest static void testQuoteFXValueUnavailableUpdate() {
        List<QuoteLineItem> qliLst = [Select Id From QuoteLineItem limit 200];
        system.debug('qliLst size : ' + qliLst.size());
        for(QuoteLineItem ql :qliLst){
            ql.Quantity = 2;
        }
        update qliLst;
        System.assert(qliLst[0].id != null);
    }
    
    @isTest static void testQuoteFXValueAvailableUpdate() {
        List<QuoteLineItem> qliLst = [Select Id From QuoteLineItem limit 200];
        system.debug('qliLst size : ' + qliLst.size());
        for(QuoteLineItem ql :qliLst){
            //ql.Quote_Fx__c = 100;
        }
        update qliLst;
        System.assert(qliLst[0].id != null);
    }
    
    @isTest static void testQuoteFXValueUnavailableInsert() {
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        
        Product2 prod = [select Id, Name from Product2 Where Name = 'Laptop X200' Limit 1];
        
        PricebookEntry standardPrice = [Select Id From PricebookEntry Where Product2Id = :prod.Id AND Pricebook2Id = :Test.getStandardPricebookId() limit 1];
        
        for(Quote ql :[Select Id From Quote limit 200]){
            QuoteLineItem qli = new QuoteLineItem();
            qli.QuoteId = ql.Id;
            qli.PriceBookEntryId = standardPrice.Id;
            qli.Quantity = 1;
            qli.UnitPrice = 100;
            qliList.add(qli);
        }
        insert qliList;
        System.assert(qliList[0].id != null);
    }
    
    @isTest static void testQuoteFXValueAvailableInsert() {
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        Product2 prod = [select Id, Name from Product2 Where Name = 'Laptop X200' Limit 1];
        
        PricebookEntry standardPrice = [Select Id From PricebookEntry Where Product2Id = :prod.Id AND Pricebook2Id = :Test.getStandardPricebookId() limit 1];
        
        for(Quote ql :[Select Id From Quote limit 200]){
            QuoteLineItem qli = new QuoteLineItem();
            qli.QuoteId = ql.Id;
            qli.PriceBookEntryId = standardPrice.Id;
            qli.Quantity = 1;
            qli.UnitPrice = 0;
            qli.Local_Currency_Amount__c = 100;
            qliList.add(qli);
        }
        insert qliList;
        System.assert(qliList[0].id != null);
    }
    
  /*  @isTest static void testQuoteFXOpptCloseDateUpdate() {
        List<Opportunity> lstOppt = [Select Id From Opportunity limit 200];
        for(Opportunity o :lstOppt){
            o.CloseDate = date.newinstance(2016, 2, 17);
        }
        update lstOppt;
    }*/

}