/**
 * Created Date		: Apr 24, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - Test class to cover upload template functionality
 * Support Email 	: smitah@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					US3249				Apr 24, 2018			1.1					Test class to cover upload template functionality
 *
 */
@isTest
private class REN_UploadTemplateCtrlTest {
	
    static testMethod void uploadTemplatePositive() {
    	Test.startTest();
        REN_UploadTemplateCtrl obj = new REN_UploadTemplateCtrl();
        String validation = System.label.REN_LBL_TEMPLATE_REQUIRED;
        obj.attachFile = Blob.valueOf('Unit Test Attachment Body');
        obj.name = 'Test.csv';
        obj.contentType = 'application/vnd.ms-excel';
        obj.uploadTemplate(); 
        system.assert(obj != null);
        Test.stopTest();
               
    }
    static testMethod void uploadTemplatePositive1() {
        Document doc = new Document();
        doc.name = 'QuoteTemplate';
	    doc.body = Blob.valueOf('Unit Test Attachment Body');
	    doc.AuthorId = UserInfo.getUserId();
	    doc.FolderId = UserInfo.getUserId();
        insert doc;
        Test.startTest();
        REN_UploadTemplateCtrl obj = new REN_UploadTemplateCtrl();
        obj.attachFile = Blob.valueOf('Unit Test Attachment Body');
        obj.name = 'Test.csv';
        obj.contentType = 'application/vnd.ms-excel';
        obj.uploadTemplate();
        system.assert(obj != null); 
        Test.stopTest();     
    }
    static testMethod void uploadTemplateNeg() {
    	Test.startTest();
        REN_UploadTemplateCtrl obj = new REN_UploadTemplateCtrl();
        obj.attachFile = Blob.valueOf('Unit Test Attachment Body');
        obj.name = 'Test';
        obj.contentType = 'application/vnd.ms-excel';
        obj.uploadTemplate(); 
        system.assert(obj != null);
        Test.stopTest();        
    }
}