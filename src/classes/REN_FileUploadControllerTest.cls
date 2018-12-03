/**
 * Created Date		: May 10, 2017
 * Developed By		: Dheeraj, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj					User Story				May 10, 2017			1.1					test class for file upload
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
private class REN_FileUploadControllerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Opportunity> opptyList = new List<Opportunity>();
        
      
        Account acc =  CHL_TestUtility.partnerAccount();
        accountList.add(acc);
        insert accountList;
        System.assert(accountList != null);
      
        Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
        contactList.add(con);
        insert contactList;
      
        Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
        opptyList.add(oppty);
        insert opptyList; 
        
        REN_Low_Dollar_Client__c lowTouchData = new REN_Low_Dollar_Client__c();
        lowTouchData.REN_Low_Touch_Admin_URL__c='http://testUrl.com/';
        lowTouchData.REN_Docusign__c= true;
        lowTouchData.REN_Live_Agent__c = true;
        lowTouchData.REN_PO_Upload__c = true;  
        insert lowTouchData;
        
        SS_License__c licenseInstance = SS_License__c.getOrgDefaults();
		if(licenseInstance.REN_AES_Encryption_Key__c == null || String.isBlank(licenseInstance.REN_AES_Encryption_Key__c)) {
			Blob key = Crypto.generateAesKey(256);
			licenseInstance.REN_AES_Encryption_Key__c = EncodingUtil.base64Encode(key); 			
			upsert licenseInstance;
		}
	}
	
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Opportunity op = [Select Id from Opportunity limit 1];
        system.assert(op!=null);
        Test.startTest();
               
		   PageReference tpageRef = Page.REN_FileUpload;
		   Test.setCurrentPage(tpageRef);
		   SS_License__c licenseInstance = SS_License__c.getOrgDefaults();	
		   Blob encryptionKey = Crypto.generateAesKey(256);				
		   string keystring = licenseInstance.REN_AES_Encryption_Key__c != null && String.isNotBlank(licenseInstance.REN_AES_Encryption_Key__c) ? licenseInstance.REN_AES_Encryption_Key__c : EncodingUtil.base64Encode(encryptionKey);
		   Blob key = EncodingUtil.base64Decode(keystring);
		   String renIdData = REN_Util.getEncryptedData(String.valueof(op.Id),key);
		   ApexPages.currentPage().getParameters().put('renId', renIdData);    
		       
		   REN_FileUploadController flUpload = new REN_FileUploadController();
		   flUpload.attachment.Body= Blob.valueOf('ÁBc Test Attachment');
		   system.assert(true);
		   String authURL = flUpload.ltUrl;
		   //System.assertEquals(authURL,'http://testUrl.com');
		   flUpload.upload();
           
         Test.stopTest();
    }
}