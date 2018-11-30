/**
 * Created Date		: Apr 24, 2018
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
 * Smita					US3249				Apr 24, 2018			1.1					@description
 *
 
 */
@isTest
private class REN_BulkImportLandingControllerTest {

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
        Product2 prod = REN_TestDataUtility.createProduct(1);
        insert prod;
        
        Case caseObj = CSM_TestDataUtility.createCase(accList[0].Id);
		insert caseObj;
		
		SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
        productIdSetting.Renewal_Amount_Product_Id__c = prod.Id;
        
        upsert productIdSetting;

	}
	
    static testMethod void testCancelSimplifiedDataModelOn() {
        insert new SS_License__c(Simplified_Data_Model_Is_Enabled__c = false);
        Test.startTest();
        REN_BulkImportLandingController obj = new REN_BulkImportLandingController();
        system.assert(obj != null);
        obj.cancelImport();
        Test.stopTest();
    }
    static testMethod void testClosedOpp() {
        insert new SS_License__c(Simplified_Data_Model_Is_Enabled__c = true);
        SS_Validations__c ssValidations = SS_Validations__c.getOrgDefaults();
    	ssValidations.REN_No_Split_allowed_for_Opp_Stage__c = 'Closed Sale';
    	upsert ssValidations;
        List<Opportunity> oppList = [select Id,StageName from Opportunity limit 1];
        system.assert(oppList != null);
        PageReference pageRef = Page.REN_BulkImportLanding;
        pageRef.getParameters().put('oppId', oppList[0].id);
        Test.setCurrentPage(pageRef);
        oppList[0].StageName = 'Closed Sale';
        update oppList;
        system.assert(oppList != null);
        Test.startTest();
        REN_BulkImportLandingController obj = new REN_BulkImportLandingController();
        Test.stopTest();
    }
     static testMethod void testClosedCase() {
        insert new SS_License__c(Simplified_Data_Model_Is_Enabled__c = true);
        List<Case> caseList = [select Id,status from Case limit 1];
 		List<Opportunity> oppList = [select Id,StageName from Opportunity limit 1];
         system.assert(oppList != null);
        caseList[0].status='closed';
        update caseList;
        PageReference pageRef = Page.REN_BulkImportLanding;
        pageRef.getParameters().put('caseId', caseList[0].id);
         pageRef.getParameters().put('oppId', oppList[0].id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        REN_BulkImportLandingController obj = new REN_BulkImportLandingController();
        obj.cancelImport();
        Test.stopTest();
    }
    static testmethod void testQuoteRequestGetMethod(){
		List<Opportunity> oppList = [select id,Pricebook2Id from opportunity limit 1];
	    system.assert(oppList != null);
	    Test.startTest();
        String inputValue = '{"links":{"self":"/opportunity/'+ oppList[0].id+'/bulkQuotes"},"action":"GET"}';
        system.assert(inputValue != null);
        REN_BulkImportLandingController.gateway(inputValue);
        Test.stopTest();
	}
	static testmethod void testQuoteRequestPostMethod(){
		List<Opportunity> oppList = [select id from opportunity limit 1];
	    system.assert(oppList != null);
	    Test.startTest();
        String inputValue = '{"status":null,"meta":{"definitions":{"quote":{"type":"object","title":"quote","required":["name"],"relationships":{},"properties":{"opportunityId":{"type":"STRING","title":"opportunityId","order":0,"display":"false","dbRequired":"false","apiName":"opportunityId"},"caseId":{"type":"STRING","title":"caseId","order":0,"display":"false","dbRequired":"false","apiName":"caseId"},"primary":{"type":"STRING","title":"primary","order":1,"display":"false","dbRequired":"false","apiName":"primary"},"expirationdate":{"type":"DATETIME","title":"Expiration Date","order":5,"display":"true","dbRequired":"false","apiName":"expirationdate"},"case__c":{"type":"REFERENCE","title":"Case","order":4,"display":"true","dbRequired":"false","apiName":"case__c"},"ren_quoteamount__c":{"type":"NUMBER","title":"Quote Amount","order":3,"display":"true","dbRequired":"false","apiName":"ren_quoteamount__c"},"local_currency_code__c":{"type":"SELECT","title":"Local Currency Code","order":2,"display":"true","dbRequired":"false","apiName":"local_currency_code__c"},"name":{"type":"STRING","title":"Quote Name","order":1,"display":"true","dbRequired":"true","apiName":"name"},"quote_type__c":{"type":"SELECT","title":"Quote Type","order":0,"display":"true","dbRequired":"false","apiName":"quote_type__c"}}}}},"links":{"self":"/opportunities/'+oppList[0].id+'/bulkquotes"},"included":null,"errors":null,"data":[{"type":"quote","relationships":null,"links":{"data_file_template":"","local_currency_code__c":"/options/quote/local_currency_code__c","quote_type__c":"/options/quote/quote_type__c"},"id":null,"attributes":{"primary":"false","caseId":"","opportunityId":"0064100000PabPFAAZ","expirationdate":"2018-06-21T00:00:00.000Z","case__c":null,"ren_quoteamount__c":200,"local_currency_code__c":"USD","name":"Q1","quote_type__c":"Direct"}}],"action":"POST"}';
        system.assert(inputValue != null);
        REN_BulkImportLandingController.gateway(inputValue);
        Test.stopTest();
	}
    static testmethod void testOptionServiceMethod(){
	    Test.startTest(); 
        String inputValue = '{"links":{"self":"/options/quote/quote_type__c"},"action":"GET"}';
        system.assert(inputValue != null);
		REN_BulkImportLandingController.gateway(inputValue);
        Test.stopTest();
    }
    static testmethod void testSignedUrlServiceMethod(){
	    Test.startTest(); 
        String inputValue = '{"links":{"self":"/s3_presigned_url"},"action":"GET"}';
        system.assert(inputValue != null);
		REN_BulkImportLandingController.gateway(inputValue);
        Test.stopTest();
    }
    static testmethod void testimportQuoteServiceMethod(){
	    Test.startTest(); 
        String inputValue = '{"links":{"self":"/importquotes"},"data":[{"type":"import-quotes","id":"2493f90c-2f3c-4aa3-b2a3-54a2303e3fb6","attributes":{"attachmentid":"2493f90c-2f3c-4aa3-b2a3-54a2303e3fb6","oppid":"0061N00000Xr4PT","dateformat":"MM/dd/yy","numberformat":"1","delimiter":"COMMA"}}],"action":"POST"}';
		system.assert(inputValue != null);
        REN_BulkImportLandingController.gateway(inputValue);
        Test.stopTest();
    }
    
}