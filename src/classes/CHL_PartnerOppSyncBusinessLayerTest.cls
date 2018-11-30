/**
 * Created Date		: Feb 8, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Test Coverage for CHL_PartnerOpportunitySyncBusinessLayer
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2046					Feb 8, 2017		1.1					Added as part of sprint 705
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
 * Comity Designs, Inc. 2017 - All Rights Reserved.
 */
@isTest
public class CHL_PartnerOppSyncBusinessLayerTest {
    @testSetup static void setup() { 
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Opportunity> opptyList = new List<Opportunity>();
        
        Account acc =  CHL_TestUtility.partnerAccount();
        accountList.add(acc);
        insert accountList;
        
        System.assert(accountList != null);
        
        Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
        Contact con2 =  CHL_TestUtility.partnerContact(accountList[0].id);
        contactList.add(con);
        contactList.add(con2);
        insert contactList;
        
        Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
        opptyList.add(oppty);
        insert opptyList; 
        CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
        optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
        optyStatusLogObj.CHL_Days_between_Update__c = 5;
        optyStatusLogObj.CHL_Available_Sales_Stages__c = 'Qualification,Needs Analysis;Closed Won';
        optyStatusLogObj.CHL_Show_Oppty_for_Unavailable_Stage__c = true;
        insert optyStatusLogObj; 
        
        CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
        partOppty.OpportunityId = opptyList[0].id;
        partOppty.partnerAcc1Id = accountList[0].id ;
        partOppty.partnerAcc1Type = 'Reseller';
        partOppty.contact1Id = contactList[0].Id;
        partOppty.expirationDate= system.today().addDays(-10);
        partOppty.Stage= 'Qualification';
        system.assert(partOppty != null);
        
        List<CHL_Partner_Opportunity__c> chlpartnerList =   CHL_TestUtility.channelPartnerOpportunityList(2,partOppty); 
        insert chlpartnerList;
    }
    static testmethod void partnerOpportunityTest()
    { 
        Test.startTest();
	        List<CHL_Partner_Opportunity__c> PartneroppList=[select Id,CHL_Opportunity__c,CHL_Syncing__c from CHL_Partner_Opportunity__c];
	        system.assert(PartneroppList!=null);
	        CSM_CustomGridInputWrapper inputWrapper=new CSM_CustomGridInputWrapper();       
	        inputWrapper.objType='PARTNER_OPPORTUNITY';
	        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
	        gridInputParams.opptyId = PartneroppList[0].CHL_Opportunity__c;
	        inputWrapper.params=gridInputParams;
	        system.assert(inputWrapper!=null);
	        CHL_PartnerOpportunitySyncBusinessLayer objPOSyncBusinessLayer=new CHL_PartnerOpportunitySyncBusinessLayer(inputWrapper);
	        objPOSyncBusinessLayer.retrieveSObjectWrapperList();
	        system.assert(true);
        test.stopTest();
    }          
}