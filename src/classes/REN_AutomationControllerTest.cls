/**
 * Created Date		: Jun 25, 2018
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
 * Smita					US3533				Jun 25, 2018			1.1					@description
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
private class REN_AutomationControllerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
        List < Account > accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList.get(0).Id != null);
        
        Product2 prod1 = REN_TestDataUtility.createProduct(1);
        insert prod1;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 standardPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert standardPB;
        
        Opportunity testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=Test.getStandardPricebookId(),
                                                CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, REN_Earliest_Expiration_Date__c = System.Today() + 2);
        
        insert testOppty;
        
        
    	REN_RSTestDataUtility.RSConfigWrapper rsConfig = new REN_RSTestDataUtility.RSConfigWrapper();
		rsConfig.customObj = 'Opportunity' ;
		rsConfig.displayDialog = true;
		rsConfig.displayResposeDialog = true;
		rsConfig.flowName = 'Credit Balance';
		rsConfig.invokingObj = 'Opportunity';
		rsConfig.namedCredential = 'RS_Echo';
		rsConfig.namedCredentialUrlExt = '/odata/frb1/dell/opportunity/dell.CreditBalance';
		rsConfig.noOfCol = '2';
		rsConfig.responseObj = 'Opportunity';
		rsConfig.soql = 'Select Account.Id,Account.Name,Name from Opportunity where id =';
      
		REN_RS_Config__c rsConfigObj = REN_RSTestDataUtility.createRSConfig(rsConfig);
		insert rsConfigObj;
        
        REN_RSTestDataUtility.RSFieldMappingWrapper rsFieldMappingWrapper = new REN_RSTestDataUtility.RSFieldMappingWrapper();
        rsFieldMappingWrapper.configId = rsConfigObj.id;
        rsFieldMappingWrapper.customMappedField = 'Name';
        rsFieldMappingWrapper.isEditable = true;
        rsFieldMappingWrapper.oDataParam = 'Name';
        rsFieldMappingWrapper.paramType = 'Input';
        rsFieldMappingWrapper.objectFieldName = 'Name';
        rsFieldMappingWrapper.matchingField =false;
        
        REN_RS_Field_Mapping__c rsMappingObj = REN_RSTestDataUtility.createFieldMapping(rsFieldMappingWrapper);
        insert rsMappingObj;
        
        REN_RSTestDataUtility.RSFieldMappingWrapper rsOutputFieldMappingWrapper = new REN_RSTestDataUtility.RSFieldMappingWrapper();
        rsOutputFieldMappingWrapper.configId = rsConfigObj.id;
        rsOutputFieldMappingWrapper.customMappedField = 'Name';
        rsOutputFieldMappingWrapper.isEditable = true;
        rsOutputFieldMappingWrapper.oDataParam = 'Name';
        rsOutputFieldMappingWrapper.paramType = 'Output';
        rsOutputFieldMappingWrapper.objectFieldName = 'Name';
        rsOutputFieldMappingWrapper.matchingField =false;
        
        REN_RS_Field_Mapping__c rsOutputMappingObj = REN_RSTestDataUtility.createFieldMapping(rsOutputFieldMappingWrapper);
        insert rsOutputMappingObj;
        
	}
	
    static testMethod void testAutomationWithInput() {
        list<Opportunity> oppList = [select Id from Opportunity limit 1];
        PageReference pageRef = Page.REN_Automation;
		Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',oppList[0].id);
		pageRef.getParameters().put('flow','Credit Balance');
        System.assert(pageRef != null);
        Test.startTest();
        REN_AutomationController objAutomationctrl = new REN_AutomationController();
        objAutomationctrl.init();
        objAutomationctrl.submit(); 
        String response = '{"creditbalance":"100","creditlimit":"200","debtstotal":"300","externalexposure":"400","onholdorders":"500","opentransactions":"600","releasedorders":"700","remainingcredit":"800"}';   
        objAutomationctrl.showResponse(response);
        Test.stopTest();
    }
    static testMethod void testAutomationWithoutInput() {
        list<Opportunity> oppList = [select Id from Opportunity limit 1];
        List<REN_RS_Config__c> configList = [select Id,REN_Display_Dialog__c from REN_RS_Config__c limit 1];
        configList[0].REN_Display_Dialog__c = false;
        update configList;
        PageReference pageRef = Page.REN_Automation;
		Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',oppList[0].id);
		pageRef.getParameters().put('flow','Credit Balance');
        System.assert(pageRef != null);
        Test.startTest();
        REN_AutomationController objAutomationctrl = new REN_AutomationController();
         objAutomationctrl.init();
        objAutomationctrl.redirectToUrl();
        Test.stopTest();
    }
    static testMethod void testAutomationMessage() {
        list<Opportunity> oppList = [select Id from Opportunity limit 1];
        PageReference pageRef = Page.REN_Automation;
		Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',oppList[0].id);
		pageRef.getParameters().put('flow','Credit Balance');
        System.assert(pageRef != null);
        Test.startTest();
        REN_AutomationController objAutomationctrl = new REN_AutomationController();
         objAutomationctrl.init();
        objAutomationctrl.submit(); 
        String response = '{"message":"Quote Request has been submitted successfully"}';    
        objAutomationctrl.showResponse(response);
        Test.stopTest();
    }
    static testMethod void testAutomationRedirect() {
        list<Opportunity> oppList = [select Id from Opportunity limit 1];
        PageReference pageRef = Page.REN_Automation;
        String message = System.label.REN_LBL_MESSAGE;
        String target = System.label.REN_LBL_TARGET;
        String Input = System.label.REN_LBL_INPUT;
        String Output = System.Label.REN_LBL_OUTPUT;
		Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('id',oppList[0].id);
		pageRef.getParameters().put('flow','Credit Balance');
        System.assert(pageRef != null);
        Test.startTest();
        REN_AutomationController objAutomationctrl = new REN_AutomationController();
         objAutomationctrl.init();
        objAutomationctrl.submit(); 
        String response ='{"target":"https://www.google.com"}';    
        objAutomationctrl.showResponse(response);
        Test.stopTest();
    }
}