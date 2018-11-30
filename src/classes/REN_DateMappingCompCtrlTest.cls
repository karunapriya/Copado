/**
 * Created Date		: Sep 9, 2016
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
 * prashant					User Story				Sep 9, 2016			1.1					@description
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
private class REN_DateMappingCompCtrlTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		child = new REN_DateMappingCompCtrl();
		REN_DateMappingCtrl parentObj = new REN_DateMappingCtrl();
		REN_FieldMappingInputWrapper vMappigInputWrapper = new REN_FieldMappingInputWrapper('', '', system.label.REN_PREVIOUS_PRICE_CALCULATION, parentObj, '', '', '', '', '', '');
		child.fmInputWrapper = vMappigInputWrapper;
		optionList = new List<SelectOption>();
		optionList.add(new SelectOption('','Select One'));
		obj = new REN_Value_Mapping__c();
		obj.REN_Record_Key__c = REN_Constants.REN_RLI_DATE_MAP;
		obj.REN_Value__c = 'REN_Start_Date__c';
		insert obj;
		system.debug('Obj------'+obj);
		system.assertNotEquals(obj,null);
	}
	static REN_DateMappingCompCtrl child;
	static REN_Value_Mapping__c obj;
	static List<SelectOption> optionList;

    static testMethod void DateMappingCompCtrl_Positive() {
        Test.startTest();
        	testSetupMethod();
        	child.objectName = CSM_Util.getNamespace() + 'REN_Renews_To__c';
        	//child.objFieldName = CSM_Util.getNamespace() + 'REN_Renewal_Status__c';
        	child.getRenewalDate();
        	PageReference pageRef = child.save();
        	system.assertEquals(pageRef,null);
        	child.selectOptions = optionList;
        	system.debug('Obj--child.selectOptions----'+child.selectOptions);
        	delete obj;
        	child.getRenewalDate();
        Test.stopTest();
    }
    static testMethod void DateMappingCompCtrl_Negative() {
    	User CSMUser = CSM_TestDataUtility.createTestUser('Standard User');
    	testSetupMethod();
        Test.startTest();
	        system.runas(CSMUser){
	        	PageReference pageRef = child.save();
	        	system.assertEquals(pageRef,null);
	        }
        Test.stopTest();
    }
}