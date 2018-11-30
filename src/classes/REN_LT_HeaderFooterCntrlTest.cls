/**
 * Created Date		: Jan 17, 2017
 * Developed By		: Tanvi, Comity Designs, Inc.
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
 * Tanvi					User Story				Jan 17, 2017			1.1					@description
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
private class REN_LT_HeaderFooterCntrlTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
        List<Account> accList = CSM_TestDataUtility.createAccount(1);
		system.assert(accList!=null);
        List<Contact> contList = CSM_TestDataUtility.createContacts(accList[0].Id,1);
        contList[0].REN_Prefered_Language_Code__c='en_US';
        update contList;
        List<Opportunity> opptyList = CSM_TestDataUtility.createOpportunity(1, (String)accList[0].id);
		system.assert(opptyList!=null);
        OpportunityContactRole objOppConRole=new OpportunityContactRole();
        objOppConRole.OpportunityId=opptyList[0].id;
        objOppConRole.ContactId=contList[0].Id;
        objOppConRole.IsPrimary=true;
        insert objOppConRole;
        
		REN_Low_Dollar_Client__c dollarClient=new REN_Low_Dollar_Client__c();
        dollarClient.Name='Test';
        dollarClient.REN_Logo_URL__c='www.google.com';
        system.assert(dollarClient.Name!= null);
        insert dollarClient;
        
        REN_Header_Footer_Links__c headerValues=new REN_Header_Footer_Links__c();
        headerValues.REN_Client_Id__c=dollarClient.id;
        headerValues.REN_Link__c='https://f5.com/support';
    	headerValues.Name='Products';
        headerValues.REN_Link_Type__c='Header';
        headerValues.REN_Language__c='English';
        system.assert(headerValues.Name!= null);
    	insert headerValues; 
        
        REN_Header_Footer_Links__c footer=new REN_Header_Footer_Links__c();
        footer.REN_Client_Id__c=dollarClient.id;
        footer.REN_Link__c='https://f5.com/careers';
    	footer.Name='Training';
        footer.REN_Link_Type__c='Footer';
        footer.REN_Language__c='English';
        system.assert(footer.Name!= null);
    	insert footer;
        
        attachment ament=new attachment();
        ament.ParentId=dollarClient.id;
        ament.Name='Test Header footer';
        ament.body=blob.valueOf('Test Header footer');
        system.assert(ament.Name!= null);
        insert ament;
        
        insert new SS_License__c(CSM__c=true, Channel__c=true,Renew__c = true,REN_AES_Encryption_Key__c='DS0HsgIf2yp1LqOIQYIEdcMWkMhDGiRortV8N/85BKQ='); 
	}
	
     public  static testMethod void testHeader() {
    
		testSetupMethod();      
        list<Opportunity> opptyList=[select Id from Opportunity limit 1];
        SS_License__c licenseInstance=[select Id,REN_AES_Encryption_Key__c from SS_License__c limit 1];
       	OpportunityContactRole contactRole=REN_LT_HeaderFooterController.getContactLangCode(opptyList[0].Id);
       	String langCode=contactRole.Contact.REN_Prefered_Language_Code__c;
        String languages=REN_LT_HeaderFooterController.getLanguages();
        Blob key = EncodingUtil.base64Decode(licenseInstance.REN_AES_Encryption_Key__c);        
        String DecryptedOppId=REN_LT_HeaderFooterController.getDecryptedOppId(REN_Util.getEncryptedData(String.valueOf(opptyList[0].Id),key));
         
        REN_Low_Dollar_Client__c clientInfo=REN_LT_HeaderFooterController.getClientDetails();
        system.assertEquals('Test',clientInfo.Name);
        system.assertEquals('www.google.com',clientInfo.REN_Logo_URL__c);
        
        List<String> cssLinks = REN_LT_HeaderFooterController.getCSSLinks();        
        
        REN_LT_HeaderFooterController.REN_LowTouchLandingComponents landingComp = REN_LT_HeaderFooterController.getLandingComponents(langCode);
        
        REN_ToggleLowTouchConfiguration config = REN_LT_HeaderFooterController.getLTConfiguration();
         
         try{
            	Map<String,String> translatedStringMap=REN_LT_HeaderFooterController.getTranslatedStringsMap(langCode);
         }
         catch(Exception e){}                
    }
}