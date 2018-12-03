/**
 * Created Date     : Nov 10, 2016
 * Developed By     : Sheetal, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Sheetal                  User Story              Nov 10, 2016            1.1                 @description
 *
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
 *
 * Comity Designs, Inc. 2016 - All Rights Reserved.
 */
@isTest
private class CHL_CreateDistributorQuoteExtCtrlTest {

    /**
     * Method to create test records once and use for all the methods in this test class
     */ 
    @testSetup 
    static void testSetupMethod() {
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Opportunity> opptyList = new List<Opportunity>();
        List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();

        Account acct = new Account();
        acct.Name = 'Partner Test Acc1';
        acct.BillingState = 'GA';
        accountList.add(acct);
        
        acct = new Account();
        acct.Name = 'Partner Test Acc2';
        acct.BillingState = 'GA';
        accountList.add(acct);
        
        insert accountList;
        system.assert(accountList != null);
        
        System.assert(accountList != null);

        Contact con = new Contact();
        con.LastName = 'Partner Contact Test1';
        con.Email = 'testpartnercontact@test.com';
        con.AccountId = accountList[0].id;
        contactList.add(con);
        
        con = new Contact();
        con.LastName = 'Partner Contact Test2';
        con.Email = 'testpartnercontact@test.com';
        con.AccountId = accountList[1].id;
        contactList.add(con);
        insert contactList;
        
        system.assert(contactList != null);

        Opportunity opp = new Opportunity();
        opp.Name = 'opportunity for Partner Test';
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.today().adddays(10);
        opp.Amount = 400;
        opp.AccountId = accountList[0].id;
        opptyList.add(opp);
        insert opptyList; 
        system.assert(opptyList != null);

        CHL_Partner_Opportunity__c parOptyObj = new CHL_Partner_Opportunity__c(); 
        parOptyObj.Name = 'testParOpp';
        parOptyObj.CHL_Opportunity__c = opptyList[0].id;
        insert parOptyObj;
        
        Quote newQuoteRecord = new Quote();
        newQuoteRecord.name = 'Test';
        newQuoteRecord.OpportunityId = opptyList[0].id;
        newQuoteRecord.CHL_Partner_Opportunity__c = parOptyObj.id;
        newQuoteRecord.CHL_Partner_Account_1__c = accountList[0].id;
        newQuoteRecord.CHL_Partner_Account_2__c = accountList[1].id;
        newQuoteRecord.CHL_Partner_Account_1_Type__c = 'Reseller';
        newQuoteRecord.CHL_Partner_Account_2_Type__c = 'Distributor';
        newQuoteRecord.CHL_Reseller_Quote__c = newQuoteRecord.id;
        insert newQuoteRecord;
        
        CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
        optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
        optyStatusLogObj.CHL_Days_between_Update__c = 5;
        optyStatusLogObj.CHL_Days_before_Expiration__c = 1;
        insert optyStatusLogObj;
       
        optyStatusLogObj.CHL_Enable_2_Tier_Pricing__c = true;
        update optyStatusLogObj;
        system.assert(optyStatusLogObj != null);
        
    }
    
    static testMethod void myUnitTest() {
        List<Quote> quoteRecord = [select id, CHL_Partner_Primary__c from quote limit 1];
        system.assert(quoteRecord != null);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteRecord[0]);
        CHL_CreateDistributorQuoteExtCtrl ctrl = new CHL_CreateDistributorQuoteExtCtrl(sc);
        ctrl.CreateQuote();
    }
    static testMethod void myUnitTest_Negative() {
        List<User> stdUser = [select id from user limit 1];
        List<Quote> quoteRecord = [select id, CHL_Partner_Primary__c from quote limit 1];
        system.assert(quoteRecord != null); 
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteRecord[0]);
        CHL_CreateDistributorQuoteExtCtrl ctrl = new CHL_CreateDistributorQuoteExtCtrl(sc);
        system.runAs(stdUser[0]) {
            ctrl.CreateQuote();
        }
    }
    static testMethod void myUnitTest_Validations() {
        List<Quote> quoteRecord = [select id, CHL_Partner_Primary__c from quote limit 1];
        system.assert(quoteRecord != null);
        quoteRecord[0].CHL_Partner_Account_1_Type__c = '';
        quoteRecord[0].CHL_Partner_Account_2_Type__c = '';
        update quoteRecord;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteRecord[0]);
        CHL_CreateDistributorQuoteExtCtrl ctrl = new CHL_CreateDistributorQuoteExtCtrl(sc);
        ctrl.CreateQuote();
        
        quoteRecord[0].CHL_Partner_Account_1_Type__c = 'Reseller';
        quoteRecord[0].CHL_Partner_Account_2_Type__c = 'Reseller';
        update quoteRecord;
        ctrl.CreateQuote();
        
        quoteRecord[0].CHL_Partner_Account_1_Type__c = 'Distributor';
        quoteRecord[0].CHL_Partner_Account_2_Type__c = 'Distributor';
        quoteRecord[0].CHL_Reseller_Quote__c = null;
        update quoteRecord;
        ctrl.CreateQuote();
    }
}