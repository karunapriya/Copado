@isTest
private class CHL_AttachmentBusinessLayerTest {

	@testSetup 
	static void setup() {       
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();

        Account acc =  CHL_TestUtility.partnerAccount();
        accountList.add(acc);
        insert accountList;
        
        System.assert(accountList != null);

        Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
        contactList.add(con);
        insert contactList;
        
        Case caseObj = new Case(
        ContactId = contactList[0].id,
        AccountId = accountList[0].id,
        Status = 'Open',
        Origin = 'Phone');
        insert caseObj;
        
        Attachment attach=new Attachment();    
	    attach.Name='Unit Test Attachment';
	    Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
	    attach.body=bodyBlob;
	    attach.parentId=caseObj.id;
	    insert attach;
    }
    
    
    static testMethod void Attachment_PositiveTest() {
    	List<Case> caseObj = [select id from Case ];
	    CHL_GridInputWrapper gridInputWrapper = new CHL_GridInputWrapper();
		CHL_GridInputWrapper.CHL_CustomGridParams qp = new CHL_GridInputWrapper.CHL_CustomGridParams();
		qp.requestId = caseObj[0].id;
		CHL_AttachmentBusinessLayer attachmentBLObj = new CHL_AttachmentBusinessLayer(gridInputWrapper);
		attachmentBLObj.inputWrapper.queryParams = qp;    	
        Test.startTest();   
            CHL_AngularResponeWrapper resWrapper = attachmentBLObj.constructGridWrapper();
			system.assert(resWrapper != null);
        Test.stopTest();
    }
}