/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class QuoteFxConversionHandlerTest {

    
    public static List<Product2> product2List;
    public static List<PricebookEntry> pricebookEntryList;
    
    public static Map<String, REN_Renew_Configuration__c> renewConfigurationMap;
    
    public static List<Account> accountList;
    public static List<Opportunity> opportunityList;
    public static List<OpportunityLineItem> opportunityLineItemList;
    public static List<Sobject> newQuoteLst {get;set;}
    public static List<QuoteLineItem> QuoteLineItemLst;
    
    public static List<Opportunity> testDataSetup(Integer totalAccounts, Integer noOfOpportunityInEachAccount, Integer noOfOpportunityLineItemInEachOppty) {
        product2List = createProduct(noOfOpportunityLineItemInEachOppty);
        pricebookEntryList = createPricebookEntry(product2List, null);
        accountList = createAccount(totalAccounts);
        opportunityList = createOpportunity(noOfOpportunityInEachAccount, accountList);
        opportunityLineItemList = createOli(noOfOpportunityInEachAccount, opportunityList, pricebookEntryList);
        newQuoteLst = createQuotes(noOfOpportunityInEachAccount , opportunityList);
        QuoteLineItemLst = createQuoteLineItems(newQuoteLst, opportunityLineItemList);
        System.debug('QuoteLineItemLst ----------'+QuoteLineItemLst);
        
        return opportunityList;
    }
    
    public static List<Product2> createProduct(Integer recordCount){
        product2List = new List<Product2>();
        for (integer i=1; i<=recordCount; i++){
            Product2 prod = new Product2();
            prod.Name =  'Test Product_' + i;
            prod.IsActive = true;
            prod.ProductCode = 'TP' + i;
            product2List.add(prod);
        }
        insert product2List;
        System.assert(product2List != null);
        return product2List;
    }
    
    public static List<PricebookEntry> createPricebookEntry(List<Product2> product2ListParam, Id pricebook2Id){
        
        if(pricebook2Id == null){
            List<Pricebook2> pbList = [select id, name, isActive from Pricebook2 where IsStandard = true ];
            if(pbList != null && !pbList.isEmpty()){
                pricebook2Id = pbList[0].id;
            }
        }
        pricebookEntryList = new List<PricebookEntry>();
        Integer i = 1;
        for(Product2 a: product2ListParam){
            PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = a.id;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            pbe.UnitPrice = i++ * 100 + 1;
            pbe.IsActive = true;
            pricebookEntryList.add(pbe);
        }
        
        insert pricebookEntryList;
        System.assert(pricebookEntryList != null);
        return pricebookEntryList;
    }
    
    public static List<Account> createAccount(Integer recordCount) {
        accountList = new List<Account>();
        for (integer i=1; i<=recordCount; i++){
            Account newAccount = new Account();
            newAccount.Name =  'Test-Account ' + i;
            accountList.add(newAccount);
        }
        insert accountList;
        System.assert(accountList != null);
        return accountList;    
    }  
    public static List<OpportunityLineItem> createOli(Integer oliCount, List<Opportunity> opportunityList, List<PricebookEntry> pricebookEntryListParam){
         List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
         for(Opportunity oppty : opportunityList){
            for(integer i=1; i<=1; i++){
                opliList.add(new OpportunityLineItem(OpportunityId = oppty.Id, Quantity = 2, TotalPrice = 20, PricebookEntryId = pricebookEntryListParam[0].Id));
            }
        }
        insert opliList;
        return opliList;
    }
    public static List<Opportunity> createOpportunity(Integer recordCountForEachAccount, List<Account> accountListParam){
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
                newOpportunity.Name =  'Original Opp ' + i;
                newOpportunity.CloseDate = System.Today();
                newOpportunity.StageName = 'Qualification';
                newOpportunity.Type = 'New Customer';
                opportunityList.add(newOpportunity);
            }
        }
        insert opportunityList;
        System.assert(opportunityList != null);
        return opportunityList;
    }    
    
    public static List<sObject> createQuotes(integer noOfQuotesPerOppty, List<Opportunity> opptyList) {
        List<sObject> quoteList = new List<sObject>();
        if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
            for(integer i=1;i<=noOfQuotesPerOppty;i++) {            
                //To create Quote Obj.
                Sobject quoteObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject() ; 
                quoteObj.put('Name', 'Test Quote'+i) ; 
                quoteObj.put('OpportunityId', opptyList[0].id) ;
                quoteObj.put('Pricebook2Id', Test.getStandardPricebookId()) ;
                quoteList.add(quoteObj);
            }
        }
        insert quoteList;
        return quoteList;
    }
    
    public static List<Sobject> createQuoteLineItems(List<Sobject> quoteList, List<OpportunityLineItem> OpptyLineItems) {
        List<Sobject> quoteItemList = new List<Sobject>();
        if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
            for(sObject objQuote:quoteList) {
                for(OpportunityLineItem oli:OpptyLineItems) {
                    if(oli.opportunityId == objQuote.get('OpportunityId')) {
                        Sobject quoteLineObj = Schema.getGlobalDescribe().get('QuoteLineItem').newSObject();
                        quoteLineObj.put('QuoteId', objQuote.get('Id'));
                        quoteLineObj.put('Product2Id', oli.Product2Id);
                        quoteLineObj.put('Quantity', oli.Quantity);
                        quoteLineObj.put('UnitPrice', 100);
                        quoteLineObj.put('PricebookEntryId', oli.PricebookEntryId);
                        quoteItemList.add(quoteLineObj);
                    }
                }
            }   
        }
        insert quoteItemList;
        return quoteItemList;
    }
    
    static testMethod void validateObjectFieldsToUpdateTest() {
        testDataSetup(1,1,1);
        test.startTest();
        SS_TriggerCollectionParameters.sObjectTriggerParams qliParam = new SS_TriggerCollectionParameters.sObjectTriggerParams();
        List<sObject> qliList = newQuoteLst;
        qliParam.qualifiedRecList = new List<sObject>(qliList);
        qliParam.oldRecordsMap= new Map<Id, sObject>(qliList);
        qliParam.triggerEvent = 'onBeforeUpdate';
        qliParam .objectName = 'QuoteLineItem';
        QuoteTriggerInvocationHandler quoteHandler = new QuoteTriggerInvocationHandler();
        quoteHandler.featureInvocation(qliParam);
        QLITriggerInvocationHandler qliHandler = new QLITriggerInvocationHandler();
        qliHandler.featureInvocation(qliParam);
        test.stopTest();
        
    }
    
    
    
}