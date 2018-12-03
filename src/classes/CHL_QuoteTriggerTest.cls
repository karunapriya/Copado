@isTest
private class CHL_QuoteTriggerTest {

    @testSetup 
    static void setup() {
    //    insert new SS_License__c(Channel__c = true);
    
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Opportunity> opptyList = new List<Opportunity>();
        List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();
    
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Partner Account';
            
        accountList.add(newAccount);
        insert accountList;
    
        System.assert(accountList != null);
    
        Contact con = new Contact(LastName='Test Contact',AccountId=accountList[0].id);
        contactList.add(con);
        insert contactList;
    
        
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.accountId = accountList[0].id;
        newOpportunity.Name = 'New Master Oppty';
        newOpportunity.CloseDate = System.Today();
        newOpportunity.StageName = 'Qualification';
        opptyList.add(newOpportunity);
        insert opptyList; 
    
        String standardPriceBookId = Test.getStandardPricebookId();
        system.debug('\n\n Standred pricebookID :: ' + standardPriceBookId);
    
        Product2 p2 = new Product2(Name = 'Test Product', isActive = true,ProductCode ='IN7080');
        insert p2;
        system.assert(p2.Id != null);
    
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = p2.Id, UnitPrice = 99, isActive = true);
        insert pbe;
        system.assert(pbe.Id != null);
    
        List <OpportunityLineItem> opliList = new List <OpportunityLineItem> ();
            OpportunityLineItem newol = new OpportunityLineItem();
            newol.OpportunityId = opptyList[0].id;
            newol.UnitPrice = 99;
            newol.ServiceDate = System.today();
            newol.Description = 'Desc 1';
            newol.Quantity = 15;
            newol.PricebookEntryId = pbe.Id;
        insert newol;
        System.assert(newol.Id!=null);
        
    }
    
    
    static testMethod void quoteTriggerTest() {
        
        Test.startTest();
                List<Opportunity> opptyList = [select id from Opportunity limit 1 ];
                System.assert(opptyList != null);
                List<OpportunityLineItem> oliList = [select OpportunityId,UnitPrice,ServiceDate,Description,Quantity,PricebookEntryId,Product2Id from OpportunityLineItem limit 1 ];
                List<PricebookEntry> pbe = [select id from PricebookEntry limit 1 ];
    
                String standardPriceBookId = Test.getStandardPricebookId();
    
              
                    SObject quote = Schema.getGlobalDescribe().get('Quote').newSObject();
                    quote.put('Name', 'Test Quote');
                    quote.put('OpportunityId', opptyList[0].id);
                    quote.put('Pricebook2Id',standardPriceBookId);
                  //  quote.put('CHL_Partner_Primary__c', true);
                    insert quote;
    
                    quote.put('name','Test Quote1') ; 
                    update quote;
    
                    Sobject quoteLineObj = Schema.getGlobalDescribe().get('QuoteLineItem').newSObject();
                    quoteLineObj.put('QuoteId', quote.Id);
                    quoteLineObj.put('Product2id', oliList[0].Product2Id);
                    quoteLineObj.put('Quantity', oliList[0].Quantity);
                    quoteLineObj.put('UnitPrice', oliList[0].UnitPrice);
                    quoteLineObj.put('PriceBookEntryId', pbe[0].Id);
                    insert quoteLineObj;
    
                    quoteLineObj.put('Quantity',15);
                    update quoteLineObj;
            Test.stopTest();      
        
    }
}