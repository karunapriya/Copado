/**
 * Created Date		: Jun 25, 2018
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: @description - This is test class for REN_DynamicButtonsCtrl
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Tanvi					US3532				Jun 25, 2018			1.1					@description
 *
 * Comity Designs, Inc. 2018 - All Rights Reserved.
 */
@isTest
private class REN_DynamicButtonsCtrlTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		List<Account> accList = CSM_TestDataUtility.createAccount(1);
	    system.assert(accList.get(0).Id != null);
	    
	    Opportunity oppObj = new Opportunity(Name = 'TestOpp', StageName = 'Quote Delivered',
		                            CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, 
		                            REN_Earliest_Expiration_Date__c = System.Today() + 2);
		insert oppObj;		
		
		REN_RSTestDataUtility.RSConfigWrapper rsConfig = new REN_RSTestDataUtility.RSConfigWrapper();
		rsConfig.customObj = 'Credit_Balance_Request__c' ;
		rsConfig.displayDialog = true;
		rsConfig.displayResposeDialog = true;
		rsConfig.flowName = 'Credit Balance';
		rsConfig.invokingObj = 'Opportunity';
		rsConfig.namedCredential = 'RS_Echo';
		rsConfig.namedCredentialUrlExt = '/odata/frb1/dell/opportunity/dell.CreditBalance';
		rsConfig.noOfCol = '2';
		rsConfig.responseObj = 'Credit_Balance_Response__c';
		rsConfig.soql = 'Select Account.client_company_id__c,Account.account_picklist_1__c from Opportunity where id =';
		
		REN_RS_Config__c rsConfigObj = REN_RSTestDataUtility.createRSConfig(rsConfig);
		insert rsConfigObj;
	}
	
    static testMethod void showButtonsTest() {
        // TO DO: implement unit test
        Opportunity oppty = [select Id, stagename from opportunity limit 1];
        system.assert(oppty.Id != null);
        
        REN_RS_Config__c rsConfigObj = [select Id from REN_RS_Config__c limit 1];
        system.assert(rsConfigObj.Id != null);
		
		REN_RS_Dynamic_Button__c rsDynamicButton = REN_RSTestDataUtility.createRSDynamicButton('/apex/REN_Automation?flow=Credit Balance&id=','stagename = \'Quote Delivered\'','Credit Balance',rsConfigObj.Id);
		insert rsDynamicButton;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
        REN_DynamicButtonsCtrl dynamicbutton = new REN_DynamicButtonsCtrl(sc);
        
        PageReference pageRef = Page.REN_DynamicButtons;
        pageRef.getParameters().put('id', String.valueOf(oppty.Id));
        Test.setCurrentPage(pageRef);
        
        dynamicbutton.buttonValue = 'Credit Balance';
        dynamicbutton.redirectToVFPage();
    }
    
    static testMethod void noConfigurationTest() {
    	Opportunity oppty = [select Id, stagename from opportunity limit 1];
        system.assert(oppty.Id != null);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
        REN_DynamicButtonsCtrl dynamicbutton = new REN_DynamicButtonsCtrl(sc);
        
        PageReference pageRef = Page.REN_DynamicButtons;
        pageRef.getParameters().put('id', String.valueOf(oppty.Id));
        Test.setCurrentPage(pageRef);
    }
    
    static testMethod void negativeTest() {
        // TO DO: implement unit test
        Opportunity oppty = [select Id, stagename from opportunity limit 1];
        system.assert(oppty.Id != null);
        
        REN_RS_Config__c rsConfigObj = [select Id from REN_RS_Config__c limit 1];
        system.assert(rsConfigObj.Id != null);
		
		REN_RS_Dynamic_Button__c rsDynamicButton = REN_RSTestDataUtility.createRSDynamicButton('/apex/REN_Automation?flow=Credit Balance&id=','stagename = Quote Delivered','Credit Balance',rsConfigObj.Id);
		insert rsDynamicButton;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppty);
        REN_DynamicButtonsCtrl dynamicbutton = new REN_DynamicButtonsCtrl(sc);
        
        PageReference pageRef = Page.REN_DynamicButtons;
        pageRef.getParameters().put('id', String.valueOf(oppty.Id));
        Test.setCurrentPage(pageRef);
        
        dynamicbutton.buttonValue = 'Credit Balance';
        dynamicbutton.redirectToVFPage();
    }
}