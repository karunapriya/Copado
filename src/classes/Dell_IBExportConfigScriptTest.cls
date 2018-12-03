/**
 * Created Date		: Jun 29, 2018
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: This test class created for code coverage of Dell_IBExportConfigScript
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US3471				    Jun 29, 2018    1.1					This test class created for code coverage of Dell_IBExportConfigScript
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
private class Dell_IBExportConfigScriptTest {

	static testMethod void testCreateRSConfiguration() {       
        Test.startTest();   
        
        Dell_IBExportConfigScript.createIBExportConfiguration();    
        
        //ServiceSource1__
        String baseNamespace = 'ServiceSource1__';
        Set<String> flowNameList = new Set<String>{'IB Export','Generate IB Export','IB Export Download'};
    	String queryString = 'Select Id, ' + baseNamespace + 'REN_Invoking_Object__c, ' + baseNamespace + 'REN_Named_Credential__c, ' + 
        baseNamespace + 'REN_Named_Credential_URL_Extension__c, ' + baseNamespace + 'REN_Field_Set_Name__c, ' + baseNamespace + 'REN_Flow_Name__c, ' + 
        baseNamespace + 'REN_Columns__c, ' + baseNamespace + 'REN_Custom_Object__c, ' + baseNamespace + 'REN_Custom_Permission_Name__c, ' + 
        baseNamespace + 'REN_Display_Dialog__c, ' + baseNamespace + 'REN_SOQL__c from ' + baseNamespace + 'REN_RS_Config__c where ' + 
        baseNamespace + 'REN_Flow_Name__c IN : flowNameList';
        
	    List<sObject> rsConfigList = Database.query(queryString);
	    
        System.assert(rsConfigList != null);
        
        Dell_IBExportConfigScript.createIBExportConfiguration();
        
        Test.stopTest();
    }
    
}