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
private class CHL_SetPrimaryOnQuoteExtnControllerTest {

    /**
     * Method to create test records once and use for all the methods in this test class
     */ 
    @testSetup 
    static void testSetupMethod() {
        Opportunity newOppty = new Opportunity();
        newOppty.name = 'Test';
        newOppty.StageName = 'Prospecting';
        newOppty.CloseDate = system.today();
        insert newOppty;
        system.assert(newOppty != null);
        
        Quote newQuoteRecord = new Quote();
        newQuoteRecord.name = 'Test';
        newQuoteRecord.OpportunityId = newOppty.id;
        insert newQuoteRecord;
        system.debug(newQuoteRecord != null);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(
            FirstName = 'Test'
            , LastName = 'User'
            , Username = 'csm-renew-test@email.com'
            , Email = 'test@email.com'
            , IsActive = true
            , Alias = 'tuser'
            , TimeZoneSidKey = 'GMT'
            , LocaleSidKey = 'en_US'
            , EmailEncodingKey = 'ISO-8859-1'
            , LanguageLocaleKey = 'en_US'
            , ProfileId = p.id);
    }
    
    static testMethod void myUnitTest() {
        List<Quote> quoteRecord = [select id, CHL_Partner_Primary__c from quote limit 1];
        system.assert(quoteRecord != null);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteRecord[0]);
        CHL_SetPrimaryOnQuoteExtnController ctrl = new CHL_SetPrimaryOnQuoteExtnController(sc);
        ctrl.saveAndReturn();
    }
    static testMethod void myUnitTest_Negative() {
        List<User> stdUser = [select id from user limit 1];
        system.assert(stdUser != null);
        List<Quote> quoteRecord = [select id, CHL_Partner_Primary__c from quote limit 1];
        system.assert(quoteRecord != null); 
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteRecord[0]);
        CHL_SetPrimaryOnQuoteExtnController ctrl = new CHL_SetPrimaryOnQuoteExtnController(sc);
        system.runAs(stdUser[0]) {
            ctrl.saveAndReturn();
        }
    }
}