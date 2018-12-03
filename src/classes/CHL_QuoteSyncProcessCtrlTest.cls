@isTest
public with sharing class CHL_QuoteSyncProcessCtrlTest {
    @TestSetup 
    static void Setup(){
        Account Acc=new Account(name='testacc');
        insert Acc;
        system.assert(Acc!=NULL);
        Opportunity opp=new Opportunity();
        opp.accountid=Acc.id;
        opp.name='Testop';
        opp.StageName='Contacted';
        opp.Type = 'New Customer';
        opp.CloseDate = System.Today(); 
        insert opp;
        Quote quoteObj = new Quote();
        quoteObj.Name = 'testquote1';
        quoteObj.OpportunityId = opp.id;
        insert quoteObj;
        Quote quoteObj1 = new Quote();
        quoteObj1.Name = 'testquote2';
        quoteObj1.OpportunityId = opp.id;
        insert quoteObj1;
    }
   
    static testMethod void Test_Quotesyncprocessmoreselected(){
        List<Quote> Qt=[select id,opportunityid from Quote limit 2];
        system.assert(Qt!=NULL);
        List<Opportunity>opptoupdate=[select id,SyncedQuoteid from Opportunity where id =:(Qt[0].opportunityid)];
        CHL_QuoteSyncProcessController controller;
        
        if(Qt != null){
            ApexPages.CurrentPage().getparameters().put('Id', opptoupdate[0].Id);
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Qt);
            sc.setSelected(Qt);
            controller = new CHL_QuoteSyncProcessController(sc);           
        }
        system.debug('SelectedQuote id++++++++++'+controller.selectedquoteId);
        Test.startTest();
        controller.Quotesyncprocess();
        Test.stopTest();
    }
    
    static testMethod void Test_Quotesyncprocess(){
        List<Quote> Qt=[select id,opportunityid from Quote limit 1];
        system.assert(Qt!=NULL);
        List<Opportunity>opptoupdate=[select id,SyncedQuoteid from Opportunity where id =:(Qt[0].opportunityid)];
        CHL_QuoteSyncProcessController controller;
        if(Qt != null){
            ApexPages.CurrentPage().getparameters().put('Id', opptoupdate[0].Id);
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Qt);
            sc.setSelected(Qt);
            controller = new CHL_QuoteSyncProcessController(sc);           
        }
        Test.startTest();
        controller.Quotesyncprocess();
        Test.stopTest();
    }
    
    static testMethod void Test_NegativeQuotesyncprocess(){
        List<Quote> Qt=[select id,opportunityid from Quote limit 1];
        system.assert(Qt!=NULL);
        
        List<Opportunity>opptoupdate=[select id,SyncedQuoteid from Opportunity where id =:(Qt[0].opportunityid)];
        CHL_QuoteSyncProcessController controller;
        if(Qt != null){
             ApexPages.CurrentPage().getparameters().put('Id', opptoupdate[0].Id);
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Qt);
            sc.setSelected(Qt);
            controller = new CHL_QuoteSyncProcessController(sc);           
        }
        controller.selectedquoteId=null;
        Test.startTest();
        controller.Quotesyncprocess();
        Test.stopTest();
        
    }
}