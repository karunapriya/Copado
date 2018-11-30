/**
 * Created Date		: Nov 22, 2018
 * Developed By		: Smita, Comity Designs, Inc.
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
 * Smita					User Story				Nov 22, 2018			1.1					@description
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
private class REN_MergeControllerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
        List < Account > accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList.get(0).Id != null);
        
        REN_RSTestDataUtility.RSConfigWrapper rsConfig = new REN_RSTestDataUtility.RSConfigWrapper();
		rsConfig.flowName = 'Search And Add';
        rsConfig.displayDialog = true;
        rsConfig.displayResposeDialog = true;
		rsConfig.invokingObj = 'Account';
		rsConfig.namedCredential = 'RS_ODATA';
		rsConfig.namedCredentialUrlExt = '/odata/frb1/dell//ExternalAccount/dell.CustomSearch';
      
		REN_RS_Config__c rsConfigObj = REN_RSTestDataUtility.createRSConfig(rsConfig);
		insert rsConfigObj;
        
        system.debug(rsConfigObj != null);
        
        REN_RSTestDataUtility.RSFieldMappingWrapper rsFieldMappingWrapper = new REN_RSTestDataUtility.RSFieldMappingWrapper();
        rsFieldMappingWrapper.configId = rsConfigObj.id;
        rsFieldMappingWrapper.customMappedField = 'Name';
        rsFieldMappingWrapper.isEditable = true;
        rsFieldMappingWrapper.oDataParam = 'Name';
        rsFieldMappingWrapper.objectFieldName = 'Name';
        rsFieldMappingWrapper.matchingField =true;
        
        REN_RS_Field_Mapping__c rsMappingObj = REN_RSTestDataUtility.createFieldMapping(rsFieldMappingWrapper);
        insert rsMappingObj;
        
        REN_RSTestDataUtility.RSFieldMappingWrapper rsFieldMappingWrapper1 = new REN_RSTestDataUtility.RSFieldMappingWrapper();
        rsFieldMappingWrapper1.configId = rsConfigObj.id;
        rsFieldMappingWrapper1.customMappedField = 'Type';
        rsFieldMappingWrapper1.isEditable = false;
        rsFieldMappingWrapper1.oDataParam = 'Type';
        rsFieldMappingWrapper1.objectFieldName = 'Type';
        rsFieldMappingWrapper1.matchingField =false;
        
        REN_RS_Field_Mapping__c rsMappingObj1 = REN_RSTestDataUtility.createFieldMapping(rsFieldMappingWrapper1);
        insert rsMappingObj1;
        
        REN_RSTestDataUtility.RSFieldMappingWrapper rsFieldMappingWrapper2 = new REN_RSTestDataUtility.RSFieldMappingWrapper();
        rsFieldMappingWrapper2.configId = rsConfigObj.id;
        rsFieldMappingWrapper2.customMappedField = 'CSM_Account_Has_Success_Plan__c';
        rsFieldMappingWrapper2.isEditable = false;
        rsFieldMappingWrapper2.oDataParam = 'CSM_Account_Has_Success_Plan__c';
        rsFieldMappingWrapper2.objectFieldName = 'CSM_Account_Has_Success_Plan__c';
        rsFieldMappingWrapper2.matchingField =false;
        
        REN_RS_Field_Mapping__c rsMappingObj2 = REN_RSTestDataUtility.createFieldMapping(rsFieldMappingWrapper2);
        insert rsMappingObj2;
        
        
        REN_RSTestDataUtility.RSFieldMappingWrapper rsFieldMappingWrapper4 = new REN_RSTestDataUtility.RSFieldMappingWrapper();
        rsFieldMappingWrapper4.configId = rsConfigObj.id;
        rsFieldMappingWrapper4.customMappedField = 'CSM_Number_of_New_Cases__c';
        rsFieldMappingWrapper4.isEditable = false;
        rsFieldMappingWrapper4.oDataParam = 'CSM_Number_of_New_Cases__c';
        rsFieldMappingWrapper4.objectFieldName = 'CSM_Number_of_New_Cases__c';
        rsFieldMappingWrapper4.matchingField =false;
        
        REN_RS_Field_Mapping__c rsMappingObj4 = REN_RSTestDataUtility.createFieldMapping(rsFieldMappingWrapper4);
        insert rsMappingObj4;
        
        
	}
	
    static testMethod void testMerge() {
        List<Account>  accList = [select Id,Name,type from Account limit 1];
        List<REN_RS_Field_Mapping__c> fieldMappingList = [select REN_RS_Config__c,REN_Custom_Mapped_Field__c,REN_Editable__c,REN_oData_Param__c,REN_Param_Type__c,REN_Object_Field_Name__c,REN_RS_Matching_Field__c from REN_RS_Field_Mapping__c limit 10];
        system.assert(fieldMappingList != null);
        sObject externalAcc = Schema.getGlobalDescribe().get('Account').newSObject();
        externalAcc.put('Name','Account1');
        externalAcc.put('Type','Prospect');
       	externalAcc.put('CSM_Account_Has_Success_Plan__c',false);
        externalAcc.put('CSM_Number_of_New_Cases__c',1);
        
       	REN_ConfigSettings configSettings = new  REN_ConfigSettings();
        configSettings.recordList = new List<sObject>();
        configSettings.fieldMappingList = fieldMappingList;
        configSettings.recordList.add(externalAcc);
        configSettings.recordList.add(accList[0]);
        configSettings.objApiName = 'Account';  
        PageReference pageRef = Page.REN_Merge;
        Test.setCurrentPageReference(pageRef);
        REN_MergeController mergeCtrl = new REN_MergeController();
        Test.startTest();
        mergeCtrl.param = JSON.serialize(configSettings);
        mergeCtrl.setRecords();
        mergeCtrl.selectedValuesJson = '';
        mergeCtrl.selectedValuesJson = '{"Name":"Account1"}';
        mergeCtrl.mergeAccounts();
        Test.stopTest();
    }
     static testMethod void testMergeNeg() {
        List<Account>  accList = [select Id,Name,type from Account limit 1];
        List<REN_RS_Field_Mapping__c> fieldMappingList = [select REN_RS_Config__c,REN_Custom_Mapped_Field__c,REN_Editable__c,REN_oData_Param__c,REN_Param_Type__c,REN_Object_Field_Name__c,REN_RS_Matching_Field__c from REN_RS_Field_Mapping__c limit 10];
        system.assert(fieldMappingList != null);
        sObject externalAcc = Schema.getGlobalDescribe().get('Account').newSObject();
        externalAcc.put('Name','Account1');
        externalAcc.put('Type','Prospect');
        
       	REN_ConfigSettings configSettings = new  REN_ConfigSettings();
        configSettings.recordList = new List<sObject>();
        configSettings.fieldMappingList = fieldMappingList;
        configSettings.recordList.add(externalAcc);
        configSettings.recordList.add(accList[0]);
        configSettings.objApiName = 'Account';  
        PageReference pageRef = Page.REN_Merge;
        Test.setCurrentPageReference(pageRef);
        REN_MergeController mergeCtrl = new REN_MergeController();
        Test.startTest();
        mergeCtrl.setRecords();
        mergeCtrl.selectedValuesJson = null;
        mergeCtrl.mergeAccounts();
        Test.stopTest();
    }
}