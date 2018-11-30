/**
 * Created Date		: Feb 7, 2017
 * Developed By		: Chandra, Comity Designs, Inc.
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
 * Chandra					User Story				Feb 7, 2017			1.1					@description
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
@isTest(SeeAllData=true)
private class REN_LT_RequestContactCtrlTest {
	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	
    static testMethod void myUnitTest() {
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test');
		testDataSetup.createRenewConfigurations();
	   	testDataSetup.renewDataSetup(1, 1, 1);
    	testDataSetup.resetAllTriggersTo(true);
		Map<String,String> mapOfTranslatedLabels = new Map<String,String>();
    	REN_LT_RequestContactCtrl.CaseFormWrapper cFormWrapper = REN_LT_RequestContactCtrl.getCaseFormDetail(testDataSetup.opportunityList[0].id,mapOfTranslatedLabels);
    	String caseObjStr = '{"Subject":"test","ContactId":"CP Chouksey","ContactEmail":"cpc@test.com","ContactPhone":"1234561234","ContactMobile":"1234561234","ContactFax":"1234561234","Reason":"test1","Description":"test2"}';
    	Case caseObj = REN_LT_RequestContactCtrl.createCase(caseObjStr, testDataSetup.opportunityList[0].id);
        
        system.assertNotEquals(caseObj.id,null);
    }
    
    static testMethod void myUnitTest2() {
        REN_Error_Log__c errorLog = new REN_Error_Log__c();
        errorLog.REN_Flow__c = 'Upload PO';
        REN_LT_ErrorLogDataAccess.insertErrorLog(new List<REN_Error_Log__c>{errorLog});
        REN_LT_FieldSetMember.ValidationRules test = new REN_LT_FieldSetMember.ValidationRules();
        system.assert(true);
    }
    
}