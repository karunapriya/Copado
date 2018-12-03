/**
 * Created Date		: Jan 31, 2017
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: Test class for DocuSign functionality.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					US2018				Jan 31, 2017			1.1			   TestClass
 *
 */
@isTest
private class REN_DocuSignApiCallTest {

	@testSetup
	static void setup() {       
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
		system.assert(opptyList != null);

		OpportunityContactRole oppContactobj = new OpportunityContactRole();
		oppContactobj.Role='Decision Maker';
		oppContactobj.OpportunityId = opptyList[0].id;
		oppContactobj.ContactId = contactList[0].id;
		oppContactobj.Isprimary=true;
		insert oppContactobj;

		REN_DocuSign_Config__c dsConfig = new REN_DocuSign_Config__c();
		dsConfig.REN_Acount_ID__c = 'TestAccount';
		dsConfig.REN_IntegratorKey__c = 'TestAccount';
		dsConfig.REN_EmailSubject__c = 'TestEmail';
		//dsConfig.REN_ReturnURL__c = 'TestreturnUrl';
		dsConfig.REN_EmailSubject__c = 'TestreturnUrl';
		dsConfig.REN_RESTAPIUrl__c = 'TestreturnUrl';
		//dsConfig.REN_HeaderContent__c = 'TestreturnUrl';
		dsConfig.REN_RecipientAuthenticationMethod__c = 'email';
		dsConfig.REN_SignHereAnchorString__c = 'TestreturnUrl';
		dsConfig.REN_SignHereAnchorXOffset__c = '200';
		dsConfig.REN_SignHereAnchorYOffset__c = '150';
		//dsConfig.REN_SignHereName__c = 'Sign here';
		dsConfig.REN_SignHereXPosition__c = '100';
		dsConfig.REN_SignHereYPosition__c= '100';
		insert dsConfig;
		
		SS_License__c ssLicenseObj = new SS_License__c();
		ssLicenseObj.REN_DocuSignUserName__c = 'TestAccount';
		ssLicenseObj.REN_DocuSignPassword__c = 'TestAccount';
		insert ssLicenseObj;
	}

	static testMethod void testCallout() {
		// create fake response to be sent from the class that implements HttpCalloutMock.
		List<Opportunity> oppList = [Select id from Opportunity];
		REN_DocuSignApiCall dsObj = new REN_DocuSignApiCall();

		REN_DocuSignWrapper.InputWrapper  inputWrapperObj = new REN_DocuSignWrapper.InputWrapper();
		inputWrapperObj.email = 'a@c.com';
		inputWrapperObj.userName = 'userName';
		inputWrapperObj.returnUrl = 'ReturnUrl';
		inputWrapperObj.oppId = oppList[0].id;
		inputWrapperObj.clientUserId = '1';
		inputWrapperObj.DocumentText= Blob.valueof('This is test method to test this functionality');
		
        Map<String,String> mapOfTranslation = new Map<String,String>();
        mapOfTranslation.put('en_US','en_US');
        
		REN_DocuSignApiCall.DocuSignCustomSettings dsCustomSettingObj = new REN_DocuSignApiCall.DocuSignCustomSettings(mapOfTranslation);
		String checkCustomSeting = dsCustomSettingObj.checkConfig();
		String autoHeader = dsCustomSettingObj.getAutoHeader();
		Test.startTest();
			dsObj.sendEnvelope(new set<Id>{oppList[0].id});
			Test.setMock(HttpCalloutMock.class, new REN_DocuSignCalloutTest());
			REN_DocuSignApiCall docuSignApiObj = new REN_DocuSignApiCall();
			system.assert(true);
			HTTPResponse httpResponse = docuSignApiObj.getHTTPResponse(inputWrapperObj,autoHeader,'en' ,mapOfTranslation, 'https://demo.docusign.net/restapi/v2/accounts/');
			String expectedResult = 'TestDocuSign';
			System.assertEquals(200, httpResponse.getStatusCode());
		Test.StopTest();
	} 

	static testMethod void testCallout_Embedded() {
		// create fake response to be sent from the class that implements HttpCalloutMock.
		List<Opportunity> oppList = [Select id from Opportunity];
		REN_DocuSignApiCall dsObj = new REN_DocuSignApiCall();

		REN_DocuSignWrapper.InputWrapper  inputWrapperObj = new REN_DocuSignWrapper.InputWrapper();
		inputWrapperObj.email = 'a@c.com';
		inputWrapperObj.userName = 'userName';
		inputWrapperObj.returnUrl = 'ReturnUrl';
		inputWrapperObj.oppId = oppList[0].id;
		inputWrapperObj.clientUserId = '1';
		inputWrapperObj.DocumentText= blob.valueof('This is test method to test this functionality');
		
		REN_LabelTranslatorAPI tranlatorApi = new REN_LabelTranslatorAPI ();
        Map<String,String> mapOfTranslation = new Map<String,String>();
        mapOfTranslation.put('en','en');
        
		REN_DocuSignApiCall.DocuSignCustomSettings dsCustomSettingObj = new REN_DocuSignApiCall.DocuSignCustomSettings(mapOfTranslation);
		String checkCustomSeting = dsCustomSettingObj.checkConfig();
		String autoHeader = dsCustomSettingObj.getAutoHeader();

		Test.startTest();
			dsObj.sendEnvelope(new set<Id>{oppList[0].id});
			Test.setMock(HttpCalloutMock.class, new REN_DocuSignCalloutTest());
			REN_DocuSignApiCall docuSignApiObj = new REN_DocuSignApiCall();
			system.assert(true);
			HTTPResponse httpResponse = docuSignApiObj.getEmbeddedResponse(inputWrapperObj, autoHeader, '12345', 'en', mapOfTranslation, 'https://demo.docusign.net/restapi/v2/accounts/');
			String expectedResult = 'TestDocuSign';
			System.assertEquals(200, httpResponse.getStatusCode());
		Test.StopTest();
	} 
}