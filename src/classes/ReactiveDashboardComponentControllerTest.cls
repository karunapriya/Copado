/**
 * Created Date		: Aug 31, 2016
 * Developed By		: admin, Comity Designs, Inc.
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
 * admin					User Story				Aug 31, 2016			1.1					@description
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
private class ReactiveDashboardComponentControllerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
	}
	
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        ReactiveDashboardComponentController controller = new ReactiveDashboardComponentController();
        test.startTest();
            ReactiveDashboardComponentController.UserWrapper userWrap = new ReactiveDashboardComponentController.UserWrapper();
            ReactiveDashboardComponentController.PriorityWrapper prioWrap = new ReactiveDashboardComponentController.PriorityWrapper();
            ReactiveDashboardComponentController.OwnerOfficeWrapper ownerOfficeWrap = new ReactiveDashboardComponentController.OwnerOfficeWrapper();
            ReactiveDashboardComponentController.overallWrapperData overAllWrap = new ReactiveDashboardComponentController.overallWrapperData();
        	system.assertNotEquals(ReactiveDashboardComponentController.allUsersMap,null);
        test.stopTest();
    }
}