/**
 * Created Date		: Jan 17, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Test Coverage for REN_LowTouchHerokuConnectionCtrl
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US1981				    Jan 17, 2017	1.1					Added class in sprint 701
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
private class REN_LowTouchHerokuConnectionCtrlTest  implements HttpCalloutMock{

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	public static REN_LowTouchHerokuConnectionCtrl controller;
	@testSetup 
	static void testSetupMethod() {
    	REN_Low_Dollar_Client__c adminRecord = new REN_Low_Dollar_Client__c(Name='test',REN_Low_Touch_Admin_URL__c= 'https://login.salesforce.com', REN_OAuth_Credentials__c = 'test');
        insert adminRecord;
        system.assert(adminRecord!=null);
	}
	
    static testMethod void myUnitTest() {
        Test.setMock(HttpCalloutMock.class, new REN_LowTouchHerokuConnectionCtrlTest());  
    	List<REN_Low_Dollar_Client__c> listAdminRecord = REN_LowTouchClientDataAccess.getLowDollarClientDetails();           
        REN_Low_Dollar_Client__c adminRecord = null;
        if(listAdminRecord != null && listAdminRecord.size()>0){
            adminRecord = listAdminRecord.get(0);
        }else{
            adminRecord = new REN_Low_Dollar_Client__c(Name='test',REN_Low_Touch_Admin_URL__c= 'https://login.salesforce.com', REN_OAuth_Credentials__c = 'test');
            insert adminRecord;
            system.assert(adminRecord!=null);
        }          	
       	controller = new REN_LowTouchHerokuConnectionCtrl();
        controller.recordId = adminRecord.id;
        
        PageReference pageRef = Page.REN_OpptSplitWizard;
        Test.setCurrentPage(pageRef);
        controller.authorizeHerokuOrg();
        system.assert(pageRef != null);
        
        controller.recordId = '';
        controller.authorizeHerokuOrg();
        
        controller.recordId = adminRecord.id;
        makeCallout();        

    }
    
    @future(callout=true)
    public static void makeCallout() {
        controller.deleteOAuthRecord();        
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"test":"testdata"}');
        res.setStatusCode(200);
        system.assert(res!= null);
        return res;
    }
}