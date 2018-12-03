@isTest
private class CHL_PortalContentBusinessLayerTest {

	@testSetup static void setup() {   
		CHL_Portal_Content__c pc = new CHL_Portal_Content__c();
			pc.name = 'Training Material';
			pc.CHL_Description__c = 'Testing';
			pc.CHL_Category__c = 'Training';
			pc.CHL_Type__c = 'Weblink';
			pc.CHL_Weblink_URL__c = 'www.google.com';
		insert pc;
		
		system.assert(pc.id != null);
		
		Attachment attach=new Attachment();    
	    attach.Name='Unit Test Attachment';
	    Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
	    attach.body=bodyBlob;
	    attach.parentId=pc.id;
	    insert attach;
	}
    static testMethod void categoryTest() {
       List<CHL_Portal_Content__c> portalContentList = CHL_PortalContentDataAccess.portalContentsList;
       CHL_CommunityLandingController.getContentLinks('');
       portalContentList[0].CHL_Type__c = 'Attachment';
       update portalContentList;
       system.assert(portalContentList != null);
       CHL_PortalContentBusinessLayer.getPortalContents(''); 
    }
    
    static testMethod void blankCategoryTest() {
       List<CHL_Portal_Content__c> portalContentList = CHL_PortalContentDataAccess.portalContentsList;
       portalContentList[0].CHL_Category__c = '';
       update portalContentList;
       system.assert(portalContentList != null);
       CHL_PortalContentBusinessLayer.getPortalContents(''); 
    }
}