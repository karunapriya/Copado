/**
 * Created Date		: Apr 9, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: Test class for REN_LowTouchAuthorizationCtrl.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Bhagyashri				US3244				Apr 9, 2018			1.1					Test class for REN_LowTouchAuthorizationCtrl.
 *

 */
@isTest(SeeAllData = true)
//NOTE:This class have see all data true purposely as we cannot create connected app in test class from where we required Consumer Key and Consumer Secret.//

public class REN_LowTouchAuthorizationCtrlTest implements HttpCalloutMock {

	/**
	 * Method to create https response 
	 */ 
	public static HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        return response; 
    }
    
    /**
	 * This method will call particular controller and its methods.
	 */
	static testMethod void myUnitTest() {
        REN_LowTouchAuthorizationCtrl ltaCtrl =  new REN_LowTouchAuthorizationCtrl();
        Test.setMock(HttpCalloutMock.class, new REN_LowTouchAuthorizationCtrlTest());
        SS_License__c ssLicenseObj = SS_License__c.getOrgDefaults();
        String domain = REN_LowTouchIntegration.getProtocolAndHost();
       	PageReference pageRef = Page.REN_LowTouchAuthorization;
        Test.setCurrentPage(pageRef);
        String oauthULR = ltaCtrl.SALESFORCE_LOGIN_URL + ltaCtrl.OAUTH_URL + '&client_id='+ ssLicenseObj.REN_Low_Touch_Consumer_Key__c + '&redirect_uri='+domain+'/apex/REN_LowTouchAuthorization&state=mystate';
        Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(oauthULR);
		request.setMethod('GET');
		HttpResponse response = REN_LowTouchAuthorizationCtrlTest.respond(request);
        response.setStatusCode(200);
        ltaCtrl.getDomain();
        ApexPages.currentPage().getParameters().put('code',response.getBody());
        ltaCtrl.init();
        System.assertEquals(ltaCtrl.init(), Null);
    }
    
     /**
	 * This method will call negative scenario from controller.
	 */
    static testMethod void myUnitTestNegative() {
        REN_LowTouchAuthorizationCtrl ltaCtrl =  new REN_LowTouchAuthorizationCtrl();
        string oauthULR = '';
        Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(oauthULR);
		request.setMethod('GET');
		HttpResponse response = REN_LowTouchAuthorizationCtrlTest.respond(request);
        response.setStatusCode(200);
        ltaCtrl.getDomain();
        ApexPages.currentPage().getParameters().put('code','');
        ltaCtrl.init();
        System.assertEquals(ltaCtrl.init(), Null);
     }
     
     
     /**
	 * This method will cover savesetting method of ctrl
	 */
    static testMethod void myUnitTestSaveSetting() {
        REN_LowTouchAuthorizationCtrl ltaCtrl =  new REN_LowTouchAuthorizationCtrl();
        string oauthULR = '';
        Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(oauthULR);
		request.setMethod('GET');
		HttpResponse response = REN_LowTouchAuthorizationCtrlTest.respond(request);
        response.setStatusCode(200);
        ltaCtrl.saveSetting();
        ApexPages.currentPage().getParameters().put('code','');
        ltaCtrl.init();
        System.assertEquals(ltaCtrl.init(), Null);
     }
     
     
     
}