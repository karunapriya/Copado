public with sharing class CHL_TestDataSetup {
    
    private static List<String> OPPORTUNITY_STAGES = new List<String>{'Prospecting', 
                                                            'Qualification', 
                                                            'Needs Analysis', 
                                                            'Value Proposition', 
                                                            'Id. Decision Makers', 
                                                            'Perception Analysis', 
                                                            'Proposal/Price Quote', 
                                                            'Negotiation/Review', 
                                                            'Closed Won', 
                                                            'Closed Lost'};
    private String namespace = '';
    private String recordNamePrefix = '';
    
    public CHL_TestDataSetup(String recordNamePrefix){
        this.recordNamePrefix = recordNamePrefix;
    }
    
    public void createAccountHierarchy(Integer levels, Integer contactsPerAccount){
        List<Account> accountList = new List<Account>();
        User ChannelUser = getChannelUser();
        for(Integer i = 1; i <= levels; i++){
            Account acc = new Account(Name=this.recordNamePrefix + 'Account' + i,ownerId = '005o0000002WiGk' );
            accountList.add(acc);
        }
        insert accountList;
        //setHierarchy(accountList);
        //createRelatedContacts(accountList, contactsPerAccount);
    }
    
    private void setHierarchy(List<Account> accountList){
        Id previousAccountId;
        for(Integer i = 0; i < accountList.size(); i++){
            Account account = accountList.get(i);
            if(i == 0){
                previousAccountId = account.Id;
                continue;
            }else{
                account.ParentId = previousAccountId;
                previousAccountId = account.Id;
            }
        }
        update accountList;
    }
    
    private void createRelatedContacts(List<Account> accountList, Integer contactsPerAccount){
        List<Contact> contactList = new List<Contact>();
        for(Account account : accountList){
            for(Integer i = 1; i<=contactsPerAccount; i++){
                Contact contact = new Contact(LastName = account.Name + i , 
                                        email='dataload@harderning.com', Phone='1234567890', MobilePhone='1234567890',
                                        AccountId=account.Id);
                contactList.add(contact);
            }
        }
        insert contactList;
    }
    private user getChannelUser() {
        Profile pObj = [select Id, name from profile where name like 'Channel' limit 1];
        if(pObj != null) {
            return [select Id from user where profileId = :pObj.Id and isActive = true limit 1];
        } else {
            return [select Id from user where Id = :UserInfo.getUserID()];
        }
    } 
    
    public void createOpportunitiesWithProducts(Integer totalOpportunitiesForAccount){
        List<Account> accountList = new List<Account>{new Account(Name=this.recordNamePrefix + '_MO_DataLoad Account')};
        insert accountList;
        List<Product2> productsList = createProduct(2);
        List<PricebookEntry> pbeList = createPricebookEntry(productsList, null);
        List<Opportunity> opportunityList = new List<Opportunity>();
        User ChannelUser = getChannelUser();
        for(Account account : accountList){
            for(Integer i = 1; i<=totalOpportunitiesForAccount; i++){
                Integer randomNo = Math.round(Math.random()*8);
                Opportunity oppty = new Opportunity(Name=this.recordNamePrefix + 'DLOpportunity' + i, 
                                                    StageName=OPPORTUNITY_STAGES[randomNo], 
                                                    CloseDate=system.today().adddays(10),
                                                    AccountId=account.Id,
                                                    ownerId = ChannelUser.Id,
                                                    REN_Earliest_Expiration_Date__c=Date.newInstance(2016, randomNo+1, 16));
                opportunityList.add(oppty);
            }
        }
        insert opportunityList;
        createOplis(opportunityList, pbeList);
    }
    
    private void createOplis(List<Opportunity> opportunityList, List<PricebookEntry> pbeList){
        List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
        for(Opportunity oppty : opportunityList){
            for(PricebookEntry pbe : pbeList){
                opliList.add(new OpportunityLineItem(OpportunityId = oppty.Id, Quantity = 2, TotalPrice = 20, PricebookEntryId = pbe.Id));
            }
        }
        insert opliList;
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
            List<Pricebook2> pbList = [Select p.Name, p.IsStandard, p.IsActive, p.Id From Pricebook2 p where p.IsStandard = true LIMIT 1];
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
            pbe.UnitPrice = i++ * 100 + 1;
            pbe.IsActive = true;
            pricebookEntryList.add(pbe);
        }
        
        Database.insert(pricebookEntryList);
        pricebookEntryList = [Select p.Name, p.Product2Id, p.Pricebook2Id, p.Id 
                                From PricebookEntry p 
                                Where p.Pricebook2Id = :pricebook2Id AND Product2Id IN:product2List];
        return pricebookEntryList;
    }
    
    public void generateRenewalOpportunity(){
        List<Opportunity> opportunityList = [Select Id, 
                                                StageName, AccountId, 
                                                Amount, CloseDate, REN_Earliest_Expiration_Date__c,
                                                Probability
                                             From Opportunity 
                                             Where Name Like '%CHANNELL1DL%'];
        for(Opportunity oppty : opportunityList){
            oppty.StageName = 'Closed Won';
        }
        update opportunityList;
    }
    
    public void createPartnerOpportunity(Integer parterOpptyPerMO){ 
        List<Contact> contactList = [Select Id, AccountId, Account.Name From Contact Where LastName LIKE '%CHANNELL1%'];
        List<CHL_Partner_Opportunity__c> partnerOpptyList = new List<CHL_Partner_Opportunity__c>();
        Map<Id, Opportunity> renewOpptyMap = new Map<Id, Opportunity>([Select Id, name,
                                                StageName, AccountId, 
                                                Amount, CloseDate, REN_Earliest_Expiration_Date__c,
                                                Probability,
                                                (Select Id From Renew_To__r)
                                             From Opportunity 
                                             Where REN_Is_CLM_Renewal__c=:true]);
        User ChannelUser = getChannelUser();
        integer OptyCount = 0;          
        for(Opportunity oppty : renewOpptyMap.values()){
            for(Integer i=0; i<parterOpptyPerMO; i++){
                Integer randomContactIndex = Math.round(Math.random()*(contactList.size() - 1));
                if(randomContactIndex <= 0){
                    randomContactIndex = 0;
                }
                //Contact randomContact1 = contactList.get(randomContactIndex);
                //Contact randomContact2 = contactList.get(randomContactIndex);
                Integer randomNo = Math.round(Math.random()*8);
                CHL_Partner_Opportunity__c partnerOppty = new CHL_Partner_Opportunity__c();
                string poName =  'US1862'+ ' - ' +oppty.Name ;
                partnerOppty.Name = poName.length() > 80 ? poName.substring(0,79) : poName; 
                partnerOppty.ownerId = ChannelUser.Id;  
                partnerOppty.CHL_Opportunity__c = '006o000000N2sS1';
                partnerOppty.CHL_Partner_Account_1__c = '001o000000ewjXR';
                //partnerOppty.CHL_Partner_Account_2__c = randomContact2.AccountId;
                partnerOppty.CHL_Partner_Account_1_Contact__c = '003o000000i4lKa';
                //partnerOppty.CHL_Partner_Account_2_Contact__c = randomContact2.Id;
                partnerOppty.CHL_Partner_Account_1_Type__c = 'Reseller';
                partnerOppty.CHL_Partner_Account_2_Type__c = 'Distributor';
                partnerOppty.CHL_Incumbent__c = Math.mod(i, 2)==0?true:false;
                partnerOppty.CHL_Amount__c = oppty.Amount;
                partnerOppty.CHL_Close_Date__c = oppty.CloseDate;
                partnerOppty.CHL_Probability__c = oppty.Probability;
                partnerOppty.CHL_Sales_Stage__c = OPPORTUNITY_STAGES[randomNo];
                /*if(i == 0 && OptyCount == ((OptyCount/2)*2)) {
                    partnerOppty.CHL_Syncing__c = 'To Master Opportunity';
                } else if(i == 0 && OptyCount != ((OptyCount/2)*2)) {
                    partnerOppty.CHL_Syncing__c = 'From Master Opportunity';
                }*/
                partnerOppty.CHL_Expiration_Date__c = Date.newInstance(2016, randomContactIndex+1, 16);
                partnerOpptyList.add(partnerOppty);
            }
            OptyCount = OptyCount + 1;
        }
        insert partnerOpptyList;
        createPartnerRenewalRelationship(partnerOpptyList, renewOpptyMap);
        createQuotes(partnerOpptyList,2,renewOpptyMap);
    }
    
    private void createPartnerRenewalRelationship(List<CHL_Partner_Opportunity__c> partnerOpptyList, Map<Id, Opportunity> renewOpptyMap){
        List<CHL_Partner_Renewal_Relationship__c> prrList = new List<CHL_Partner_Renewal_Relationship__c>();
        for(CHL_Partner_Opportunity__c partnerOppty : partnerOpptyList){
            List<REN_Renews_To__c> renewalRelationList = renewOpptyMap.get(partnerOppty.CHL_Opportunity__c).Renew_To__r;
            for(REN_Renews_To__c renRelation : renewalRelationList){
                CHL_Partner_Renewal_Relationship__c partnerRR = new CHL_Partner_Renewal_Relationship__c(
                                                                CHL_Partner_Opportunity__c = partnerOppty.Id,
                                                                CHL_Renewal_Relationship__c = renRelation.Id);
                prrList.add(partnerRR);
            }
        }
        insert prrList;
    }
    
    private void createQuotes(List<CHL_Partner_Opportunity__c> partnerOpptyList, integer quotesPerPO,Map<Id, Opportunity> renewOpptyMap){
        List<Sobject> quoteList =  new List<Sobject>();
        List<Pricebook2> pbList = [Select p.Name, p.IsStandard, p.IsActive, p.Id From Pricebook2 p where p.IsStandard = true LIMIT 1];
        User ChannelUser = getChannelUser();    
        for(CHL_Partner_Opportunity__c partnerOppty : partnerOpptyList){
            for(Integer i=0; i<quotesPerPO; i++){               
                Sobject quoteObj = Schema.getGlobalDescribe().get('Quote').newSObject();
                quoteObj.put('Name', 'DataLOad_Quote'+i);
                quoteObj.put('OpportunityId', partnerOppty.CHL_Opportunity__c);
                quoteObj.put('Pricebook2Id', pbList[0].Id);
                quoteObj.put('ExpirationDate', partnerOppty.CHL_Expiration_Date__c);
                quoteObj.put('CHL_Partner_Opportunity__c', partnerOppty.id);
                //quoteObj.put('OwnerId', ChannelUser.id);
                if(i==0) {
                    quoteObj.put('CHL_Partner_Primary__c', true);
                } else {
                    quoteObj.put('CHL_Partner_Primary__c', false);
                }
                quoteList.add(quoteObj);
            }
        }
        insert quoteList;
        Map<Id, OpportunityLineItem> OpptyLineItemMap = new Map<Id, OpportunityLineItem>([Select Id,Product2Id,OpportunityId, 
                                                        Quantity, ListPrice, PricebookEntryId,CHL_MSRP__c from OpportunityLineItem
                                                        where OpportunityId in :renewOpptyMap.keyset()]);
        createQuoteLineItems(quoteList,OpptyLineItemMap);           
    }
    
    private void createQuoteLineItems(List<Sobject> quoteList, Map<Id, OpportunityLineItem> OpptyLineItemMap) {
        List<Sobject> quoteItemList = new List<Sobject>();
        for(sObject objQuote:quoteList) {
            for(OpportunityLineItem oli:OpptyLineItemMap.values()) {
                if(oli.opportunityId == objQuote.get('OpportunityId')) {
                    Sobject quoteLineObj = Schema.getGlobalDescribe().get('QuoteLineItem').newSObject();
                    quoteLineObj.put('QuoteId', objQuote.get('Id'));
                    quoteLineObj.put('Product2Id', oli.Product2Id);
                    quoteLineObj.put('Quantity', Oli.Quantity);
                    quoteLineObj.put('UnitPrice', oli.ListPrice);
                    quoteLineObj.put('PricebookEntryId', oli.PricebookEntryId);
                    quoteLineObj.put('CHL_MSRP__c', oli.CHL_MSRP__c);
                    quoteItemList.add(quoteLineObj);
                }
            }
        }       
        insert quoteItemList;
    }
}