public with sharing class TestQuoteSyncDataSetup {                                                            
    private static List<String> OPPORTUNITY_STAGES = new List<String>{'Not Contacted',
                                                        'Contacted',
                                                        'Quote Request',
                                                        'In Review',
                                                        'Quote Completed',
                                                        'Quote Delivered',
                                                        'Customer Commitment',
                                                        'PO Received'};
                                                        
    private String namespace = '';
    private String recordNamePrefix = '';
    private String OppName = '';
    private String OppNameString = '';
    
    public TestQuoteSyncDataSetup(String recordNamePrefix){
        this.recordNamePrefix = recordNamePrefix;
        this.OppName = '_Test RLI_';
        this.OppNameString = '%'+recordNamePrefix+'%';
    }
    
    public void createOpportunitiesWithProducts(Integer totalOpportunitiesForAccount,integer noOfProductsForOppty){
        List<Account> accountList = new List<Account>{new Account(Name=this.recordNamePrefix + 'Account')};
        insert accountList;
        List<Contact> Conlist = new List<Contact>();
        for(integer i=0;i<accountList.size();i++)
        {
         Contact con=new Contact();
            con.AccountId=accountList[i].id;
            con.FirstName=('con'+(i+1));
            con.LastName=('conLast'+(i+1));
            Conlist.add(con);
        }
        insert Conlist;
        List<Product2> productsList = createProduct(noOfProductsForOppty);
        List<PricebookEntry> pbeList = createPricebookEntry(productsList, null);
        List<Opportunity> opportunityList = new List<Opportunity>();        
        for(Account account : accountList){
            for(Integer i = 1; i<=totalOpportunitiesForAccount; i++){
                Integer randomNo = Math.round(Math.random()*6);
                Opportunity oppty = new Opportunity(Name=this.recordNamePrefix + i, 
                                                    StageName=OPPORTUNITY_STAGES[randomNo], 
                                                    CloseDate=system.today().adddays(10),
                                                    AccountId=account.Id,
                                                    REN_Earliest_Expiration_Date__c=Date.newInstance(2016, randomNo+1, 16));
                opportunityList.add(oppty);
            }
        }
        insert opportunityList;
        createOplis(opportunityList, pbeList);
        createSameOplis(opportunityList,noOfProductsForOppty);
    }
    
    
    
    private void createOplis(List<Opportunity> opportunityList, List<PricebookEntry> pbeList){
        List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
        integer i;
        for(Opportunity oppty : opportunityList){
            i =1;
            for(PricebookEntry pbe : pbeList){
                i++;
                Integer randomProdIndex = Math.round(Math.random()*6);
                opliList.add(new OpportunityLineItem(OpportunityId = oppty.Id,Description='DESC '+oppty.Name+i, Quantity = i, UnitPrice = pbe.UnitPrice, 
                                                    PricebookEntryId = pbe.Id,REN_Start_Date__c = Date.newInstance(2017, 3, randomProdIndex),
                                                    REN_End_Date__c = Date.newInstance(2017, 4, randomProdIndex)));
            }
        }
        insert opliList;
    }
    
    private void createSameOplis(List<Opportunity> opportunityList, Integer noOfProducts){
        List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
        List<Pricebook2> pbList = [Select p.Name, p.IsStandard, p.IsActive, p.Id From Pricebook2 p where p.IsStandard = true and p.IsActive = true LIMIT 1];
        Id pricebook2Id = pbList[0].id;
        List<PricebookEntry> pbeList = [Select p.Name, p.Product2Id, p.Pricebook2Id, p.Id, p.UnitPrice  
                                From PricebookEntry p 
                                Where p.Pricebook2Id = :pricebook2Id AND Product2Id IN (select Id from Product2 where IsActive = true ) limit 1];
        
        for(Opportunity oppty : opportunityList){
        
            for(integer p=1;p<=noOfProducts;p++) {
                for(PricebookEntry pbe : pbeList){
                    Integer randomProdIndex = Math.round(Math.random()*6);
                    opliList.add(new OpportunityLineItem(OpportunityId = oppty.Id,Description='DESC '+oppty.Name+p, Quantity = 1, UnitPrice = 100, 
                                                        PricebookEntryId = pbe.Id,REN_Start_Date__c = Date.newInstance(2017, 3, randomProdIndex),
                                                        REN_End_Date__c = Date.newInstance(2017, 4, randomProdIndex)));
                }
            }
        }
        insert opliList;
        //updateOriginalIds(opliList);
    }
    
    public void updateOriginalIds() {
        List<OpportunityLineItem> opliListToUpdate = [select Id, REN_Original_Line_Item_ID__c from OpportunityLineItem where REN_Original_Line_Item_ID__c = null AND Createddate = today AND OpportunityId in (select Id From Opportunity Where Name Like:this.OppNameString)];
        for(OpportunityLineItem oli:opliListToUpdate) {
            oli.REN_Original_Line_Item_ID__c = oli.id; //
            //opliListToUpdate.add(oli);
        }
        update opliListToUpdate;
    }
    
    private List<Product2> createProduct(Integer recordCount){
        List<Product2> product2List = new List<Product2>();
        for (integer i=1; i<=recordCount; i++){
            Product2 prod = new Product2();
            prod.Name = this.recordNamePrefix + '_DataLoad' + i;
            prod.IsActive = true;
            prod.ProductCode = 'TP' + i;
            product2List.add(prod);
        }
        insert product2List;
        return product2List;
    }
    
    private List<PricebookEntry> createPricebookEntry(List<Product2> product2List, Id pricebook2Id){
        
        if(pricebook2Id == null){
            List<Pricebook2> pbList = [Select p.Name, p.IsStandard, p.IsActive, p.Id From Pricebook2 p where p.IsStandard = true and p.IsActive = true LIMIT 1];
            if(pbList != null && !pbList.isEmpty()){
                pricebook2Id = pbList[0].id;
            }
        }
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        Integer i = 1;
        for(Product2 a: product2List){
            PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = a.id;
            pbe.Pricebook2Id = pricebook2Id;
            pbe.UnitPrice = (i * 1000 )+ 1;
            pbe.IsActive = true;
            i = i+1;
            pricebookEntryList.add(pbe);
        }
        
        Database.insert(pricebookEntryList);
        pricebookEntryList = [Select p.Name, p.Product2Id, p.Pricebook2Id, p.Id, p.UnitPrice  
                                From PricebookEntry p 
                                Where p.Pricebook2Id = :pricebook2Id AND Product2Id IN:product2List];
        return pricebookEntryList;
    }
    
    public void createRLIs() {
        List<OpportunityLineItem> opliList = [select Id,opportunityId, Product2Id,REN_Start_Date__c,REN_End_Date__c,REN_Original_Line_Item_ID__c from OpportunityLineItem where Createddate = today AND OpportunityId in (select Id From Opportunity Where Name Like:this.OppNameString)];
        List<REN_Renews_To__c> rliList = new List<REN_Renews_To__c>();
        for(OpportunityLineItem oli:opliList) {
            Integer randomNoQuote = Math.round(Math.random()*8);
            REN_Renews_To__c rli = new REN_Renews_To__c();
            rli.REN_Product__c  = oli.Product2Id;
            rli.REN_Renewal_Product_Line_Id__c = oli.id;
            rli.REN_Original_Line_Item_ID__c = oli.REN_Original_Line_Item_ID__c;
            rli.REN_End_Date__c = oli.REN_End_Date__c;
            rli.REN_Start_Date__c = oli.REN_Start_Date__c;
            rli.REN_Renews_To__c = oli.opportunityId;
            rliList.add(rli);
        }
        insert rliList;
    }
    
    public void createQuotes(integer quotesPerPO){
        List<Opportunity> OpptyList = [select Id,REN_Earliest_Expiration_Date__c from Opportunity where createddate = today];
        List<Sobject> quoteList =  new List<Sobject>();
        List<Pricebook2> pbList = [Select p.Name, p.IsStandard, p.IsActive, p.Id From Pricebook2 p where p.IsStandard = true LIMIT 1];
		integer quoteCount = 0;
        for(Opportunity Oppty : OpptyList){
			quoteCount = quoteCount +1;
            for(Integer i=0; i<quotesPerPO; i++){               
                Sobject quoteObj = Schema.getGlobalDescribe().get('Quote').newSObject(); 
                quoteObj.put('Name', this.recordNamePrefix+quoteCount);               
                quoteObj.put('Description', 'DESC_Test_SyncQuote'+quoteCount);
                quoteObj.put('OpportunityId', Oppty.id);
                quoteObj.put('Pricebook2Id', pbList[0].Id);
                quoteObj.put('ExpirationDate', Oppty.REN_Earliest_Expiration_Date__c);
                if(i==0) {
                    quoteObj.put('CHL_Partner_Primary__c', true);
                } else {
                    quoteObj.put('CHL_Partner_Primary__c', false);
                }
                quoteList.add(quoteObj);
            }
        }
        insert quoteList; 
    }
    
    public void createQuoteLineItems() {
        List<Sobject> quoteList = [select Id,Name,OpportunityId from quote where createddate = today AND Name Like:this.OppNameString];
        Map<Id, Opportunity> renewOpptyMap = new Map<Id, Opportunity>([Select Id, name,
                                                StageName, AccountId, 
                                                Amount, CloseDate, REN_Earliest_Expiration_Date__c,
                                                Probability,
                                                (Select Id From Renew_To__r)
                                             From Opportunity 
                                             Where Name Like:this.OppNameString AND Createddate = today ]);
        Map<Id, OpportunityLineItem> OpptyLineItemMap = new Map<Id, OpportunityLineItem>([Select Id,Product2Id,OpportunityId, 
                                                        Quantity, ListPrice, PricebookEntryId,CHL_MSRP__c,REN_Original_Line_Item_ID__c from OpportunityLineItem
                                                        where OpportunityId in :renewOpptyMap.keyset()]);
        List<Sobject> quoteItemList = new List<Sobject>();
        for(sObject objQuote:quoteList) {
            for(OpportunityLineItem oli:OpptyLineItemMap.values()) {
                Integer randomNoQuote = Math.round(Math.random()*8);
                if(oli.opportunityId == objQuote.get('OpportunityId')) {
                    Sobject quoteLineObj = Schema.getGlobalDescribe().get('QuoteLineItem').newSObject();
                    quoteLineObj.put('QuoteId', objQuote.get('Id'));
                    quoteLineObj.put('Product2Id', oli.Product2Id);
                    quoteLineObj.put('Quantity', Oli.Quantity);
                    quoteLineObj.put('UnitPrice', oli.ListPrice);
                    quoteLineObj.put('PricebookEntryId', oli.PricebookEntryId);
                    quoteLineObj.put('CHL_MSRP__c', 100 * randomNoQuote);
                    quoteLineObj.put('CHL_Start_Date__c',Date.newInstance(2017, 3, randomNoQuote));
                    quoteLineObj.put('CHL_END_Date__c',Date.newInstance(2017, 4, randomNoQuote));
                    quoteLineObj.put('REN_Original_Line_Item_ID__c',oli.REN_Original_Line_Item_ID__c);
                    quoteLineObj.put('Discount',randomNoQuote);
                    quoteLineObj.put('Description','DESC'+objQuote.get('Name'));
                    quoteItemList.add(quoteLineObj);
                    system.debug('quoteItemList:  '+quoteItemList);
                }
            }
        }       
        insert quoteItemList;
    }
    
    public void updateQuoteSync() {
        List<sObject> SobjectList = [select Id, OpportunityId from Quote where createddate = today AND Name Like:this.OppNameString];
        Map<String,String> oppToQuoteMap = new Map<String,String>();
        for(SObject sobj:SobjectList ) {
            oppToQuoteMap.put((String)sobj.get('OpportunityId'),(String)sobj.get('Id'));
        }
        List<Opportunity> oppList = [select Id, SYNCEDQUOTEID from opportunity where Id in:oppToQuoteMap.keyset()];
        for(Opportunity opp: oppList) {
            opp.SYNCEDQUOTEID = oppToQuoteMap.get(opp.Id);
        }
        update oppList ;
    }
}