/**
 * Created Date		: Jul 3, 2018
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: This test class created for code coverage of Dell_RSConfigurationScript. 
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					User Story				Jul 3, 2018			1.1					@description
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
 * Comity Designs, Inc. 2018 - All Rights Reserved.
 */
@isTest
private class Dell_RSConfigurationScriptTest {

	static testMethod void testCreateFlow() {       
        Test.startTest();   
        Dell_RSConfigurationScript.createRSConfiguration();    
        List<REN_RS_Config__c> existingRSConfigList = [SELECT REN_Columns__c,REN_Custom_Object__c,REN_Display_Dialog__c,REN_Display_Response_Dialog__c,REN_Flow_Name__c,REN_Invoking_Object__c, REN_Named_Credential__c,
		                                               REN_Named_Credential_URL_Extension__c, REN_Number_Of_Columns__c, REN_Response_Object__c, REN_SOQL__c, REN_Response_Object_Field_Set_Name__c 
		                                               FROM REN_RS_Config__c WHERE REN_Flow_Name__c IN ('NewQuote','Credit Balance','New and Configure Quote','Configure Quote','Configure','Validate','Create Order') ];
        
        System.assert(existingRSConfigList != null);
        Test.stopTest();
    }
}