/**
 * Created Date		: Nov 21, 2016
 * Developed By		: abirjepatil, Comity Designs, Inc.
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
 * abirjepatil					User Story				Nov 21, 2016			1.1					@description
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
private class CSM_BatchFilterTriggerHandlerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		insert new SS_License__c(CSM__c = true);		
		csm_batch_filter__c batchFilter = new csm_batch_filter__c();
		batchFilter.CSM_Object_Name__c =  'Account';
		batchFilter.CSM_Batch_Job_Name__c = 'CSM_BatchCreatePlayScheduledDispatcher';
		batchFilter.csm_isactive__c = true;
		system.assert(batchFilter!=null);
		insert batchFilter;
	}
	
    static testMethod void myUnitTest() {
		csm_batch_filter__c batchFilter = new csm_batch_filter__c();
		batchFilter.CSM_Object_Name__c =  'Account';
		batchFilter.CSM_Batch_Job_Name__c = 'CSM_BatchCreatePlayScheduledDispatcher';
		batchFilter.csm_isactive__c = true;
		
		Test.startTest();
			insert batchFilter;
		Test.stopTest();
		
		integer i = [select count() from csm_batch_filter__c where CSM_Batch_Job_Name__c = 'CSM_BatchCreatePlayScheduledDispatcher' and csm_isactive__c = true];
		system.assert(i == 1);		
        
    }
    static testMethod void myUnitTest1() {

		csm_batch_filter__c batchFilter = new csm_batch_filter__c();
		batchFilter.CSM_Object_Name__c =  'Account';
		batchFilter.CSM_Batch_Job_Name__c = 'CSM_BatchCreatePlayScheduledDispatcher';
		batchFilter.csm_isactive__c = false;
		
		insert batchFilter;

		csm_batch_filter__c batchFilter1 = [select Id, csm_isactive__c from csm_batch_filter__c where CSM_Batch_Job_Name__c = 'CSM_BatchCreatePlayScheduledDispatcher' and csm_isactive__c = false];
		batchFilter1.csm_isactive__c = true;

		/*CSM_TriggerEnablement__c cTriggerEnablement  = CSM_TriggerEnablement__c.getOrgDefaults();
		cTriggerEnablement.CSM_BatchFilterTrigger__c = true;
		upsert cTriggerEnablement;*/
			
		Test.startTest();
			CSM_Constants.BatchFilter_TRIGGER = true;		
			update batchFilter1;
		Test.stopTest();
		
		integer i = [select count() from csm_batch_filter__c where CSM_Batch_Job_Name__c = 'CSM_BatchCreatePlayScheduledDispatcher' and csm_isactive__c = true];
		system.assert(i == 1);		
        
    }
    
}