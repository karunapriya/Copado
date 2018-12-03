/**
 * Created Date		: Nov 22, 2016
 * Developed By		: abirjepatil, Comity Designs, Inc.
 *
 * Function			: Test class for Generate Opportunity button.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * abirjepatil					US1779				Nov 22, 2016			1.1					@description
 *
*/
@isTest
private class REN_GenerateOppSvcCntrctRedirectCtrlTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		system.assert(true);
	}
	
    static testMethod void myUnitTest() {
        Test.startTest();
		ServiceContract sc = new ServiceContract();        
        REN_GenerateOppSvcContractRedirectCtrl ctrl = new REN_GenerateOppSvcContractRedirectCtrl(new ApexPages.StandardController(sc));
		PageReference pageRef = ctrl.returnPage();
        Test.stopTest();		        
        
        system.assert(pageRef != null);
    }
}