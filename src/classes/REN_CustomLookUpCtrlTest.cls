/**
 * Created Date		: Jun 21, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
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
 * Dilip					User Story				Jun 21, 2018			1.1					@description
 *
 */
@isTest
public with sharing class REN_CustomLookUpCtrlTest implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"@odata.context":"https://sbx.dev.ssi-cloud.com/odata/frb1/dell/$metadata#core_organizations(_id,displayName)","value":[{"_id":"557ab","displayName":"HALLMARK, INC_US14530103"},{"_id":"557ab0","displayName":"HALLMARK43415"},{"_id":"557ab0","displayName":"HALLION INC_US33512052"}]}');
        response.setStatusCode(200);
        system.assert(true);
        return response;
	}
    
    public static testmethod void myUnitTest(){
        ApexPages.currentPage().getParameters().put('filterVal','Test');
        ApexPages.currentPage().getParameters().put('relationshipName','Test');
        ApexPages.currentPage().getParameters().put('isRSReq','true');
        
        REN_RS_Config__c rsConfigObj = new REN_RS_Config__c(REN_Flow_Name__c = 'IB Export');
        insert rsConfigObj;
        
        REN_RS_Lookup_Field_Mapping__c rsLookupFieldObj = new REN_RS_Lookup_Field_Mapping__c(REN_Object_API_Name__c = 'Test', REN_RS_Configuration__c = rsConfigObj.Id, REN_Named_Credential__c = 'Test', REN_Named_Credential_URL_Extension__c = 'Test');
    	insert rsLookupFieldObj;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new REN_CustomLookUpCtrlTest());
        REN_CustomLookUpCtrl customLookupObj = new REN_CustomLookUpCtrl();
        system.assert(customLookupObj.lookupfieldWrapperList != null);
        customLookupObj.searchValue = 'Test';
        customLookupObj.showSearchResult();
        system.assert(customLookupObj.lookupfieldWrapperList != null);
        Test.stopTest(); 
        
    }
    
    public static testmethod void accountUnitTest(){
        ApexPages.currentPage().getParameters().put('filterVal','Test');
        ApexPages.currentPage().getParameters().put('relationshipName','Account');
        ApexPages.currentPage().getParameters().put('isRSReq','false');
        
        Account accObj = new Account(Name = 'Test');
        insert accObj;
        
        Test.startTest();
        
        REN_CustomLookUpCtrl customLookupObj = new REN_CustomLookUpCtrl();
        system.assert(customLookupObj.lookupfieldWrapperList != null);
        customLookupObj.searchValue = 'Test';
        customLookupObj.showSearchResult();
        system.assert(customLookupObj.lookupfieldWrapperList != null);
        Test.stopTest(); 
        
    }
}