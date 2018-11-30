/**
 * Created Date		: Sep 12, 2016
 * Developed By		: prashant, Comity Designs, Inc.
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
 * prashant					User Story				Sep 12, 2016			1.1					@description
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
private class REN_DateMappingCtrlTest {

	/**value
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	 static testMethod void dateMappingCtrl_Positive() {
        REN_DateMappingCtrl controller = new REN_DateMappingCtrl();
        	Test.startTest();
        		Test.setCurrentPage(Page.REN_DateMapping);
        		controller.thisController = new REN_BaseMainController();
        		system.assert(controller.getThis() != null);
    			REN_BaseMainController baseMainCtrl = controller.thisController;
    			REN_DateMappingCompCtrl vmc = new REN_DateMappingCompCtrl();
	        	controller.setBaseChildController(vmc);
	        	controller.setBaseChildControllerMap('vmc', controller.getBaseChildController());
	        	controller.tabCategory = 'Renewal';
        		PageReference pageRef = controller.saveDateMapping();
        		pageRef = controller.redirectToMappingsPage();
        	Test.stopTest();
    }
    static testMethod void dateMappingCtrl_Negative() {
        REN_DateMappingCtrl controller = new REN_DateMappingCtrl();
        	Test.startTest();
        		controller.objectName = 'REN_Renews_To__c';
        		Test.setCurrentPage(Page.REN_DateMapping);
        		controller.thisController = new REN_BaseMainController();
        		system.assert(controller.getThis() != null);
    			REN_BaseMainController baseMainCtrl = controller.thisController;
    			REN_DateMappingCompCtrl vmc = new REN_DateMappingCompCtrl();
	        	controller.setBaseChildController(vmc);
        		PageReference pageRef = controller.saveDateMapping();
        	Test.stopTest();
    }
}