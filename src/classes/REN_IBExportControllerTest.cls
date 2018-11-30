/**
 * Created Date		: May 10, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
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
 * Bhagyashri					User Story				May 10, 2018			1.1					@description
 *
 */
@isTest
public with sharing class REN_IBExportControllerTest {

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
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 standardPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert standardPB;
        
        Opportunity testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=standardPB.id,
                                                CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, REN_Earliest_Expiration_Date__c = System.Today() + 2);
        
        insert testOppty;
        Product2 prod = REN_TestDataUtility.createProduct(1);
        insert prod;
        
        PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod1.Id);
        insert price1;
        system.assert(price1.Id != null);
        
        system.assert(prod.Id != null);
        OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = testOppty.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
        insert opptyLineItem;
        
        Asset asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);
        asset.REN_Oppty_Line_Item_Id__c = opptyLineItem.Id;
        insert asset;
        
        insert new REN_RS_Config__c(REN_Flow_Name__c = 'IB Export', REN_Invoking_Object__c = 'IBReport__c', REN_Field_Set_Name__c = 'REN_Generate_IB_Export', REN_Columns__c = 'REN_IB_Export_Filterablee', REN_Named_Credential__c = 'RS_Echo', REN_Named_Credential_URL_Extension__c = 'Test');
        insert new REN_RS_Config__c(REN_Flow_Name__c = 'Generate IB Export', REN_Invoking_Object__c = 'IBReport__c', REN_Field_Set_Name__c = 'REN_Generate_IB_Export', REN_Columns__c = 'REN_IB_Export_Filterablee', REN_Named_Credential__c = 'RS_Echo', REN_Named_Credential_URL_Extension__c = 'Test');
	}
	
    public static testMethod void myUnitTest() {
        List<Asset> assetList = [select Id,name from Asset limit 1];
        system.assert(assetList != null);
        
        REN_IBExportController ibEportObject = new REN_IBExportController();
        system.assert(ibEportObject != null);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new REN_CustomLookUpCtrlTest());
        
        PageReference pgRef1 = ibEportObject.findFor();
        system.assert(pgRef1 == null);
        
        PageReference pgRef = ibEportObject.createIBExport();
        system.assert(pgRef == null);
        
        Test.stopTest();
        
    }
}