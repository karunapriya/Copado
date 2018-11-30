/**
 * Created Date		: Dec 13, 2016
 * Developed By		: Nkonkar, Comity Designs, Inc.
 *
 * Function			: @description - Test class for REN_ConsolidateOpportunityBatch
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nkonkar					User Story				Dec 13, 2016			1.1					@description
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
private class REN_ConsolidateOpportunityBatchTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */
	 static testMethod void myUnitTest() {
       
    	 Test.startTest();
    	 List<CHL_Opportunity_Status_Log__c> opptyStatusLogList = CHL_TestUtility.createOppStatusLog();
		 insert opptyStatusLogList;
	     REN_TestDataSetup batchData=new REN_TestDataSetup();
	     batchData.consolidateOpportunityBatchData();  
	     
	    Database.executeBatch(new REN_ConsolidateOpportunityBatch());
        Test.stopTest();  
        
    } 
		
    
}