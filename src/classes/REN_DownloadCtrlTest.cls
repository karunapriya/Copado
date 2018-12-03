@isTest
public with sharing class REN_DownloadCtrlTest implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"attachmentId":"Test","url":"Test","success":"Test"}');
        response.setStatusCode(200);
        system.assert(true);
        return response;
	}
    
    public static testmethod void downloadUnitTest(){
        
        REN_RS_Config__c rsConfig = new REN_RS_Config__c(REN_Flow_Name__c = 'IB Export Download', REN_Named_Credential__c = 'Test', REN_Named_Credential_URL_Extension__c = 'Test');
        insert rsConfig;
        
        System.assert(rsConfig != null);
        Test.startTest();
        System.currentPageReference().getParameters().put('attachmentId', 'Test');
        Test.setMock(HttpCalloutMock.class, new REN_DownloadCtrlTest());

        REN_DownloadCtrl downObj = new REN_DownloadCtrl();
        PageReference pageObj = downObj.authenticateAndDownload();
        System.assert(downObj.ibReportURL != null);
		Test.stopTest(); 
    }
    
    public static testmethod void downloadFalseUnitTest(){
        
        REN_RS_Config__c rsConfig = new REN_RS_Config__c(REN_Flow_Name__c = 'IB Export Download', REN_Named_Credential__c = 'Test', REN_Named_Credential_URL_Extension__c = 'Test');
        insert rsConfig;
        
        System.assert(rsConfig != null);
        
        System.currentPageReference().getParameters().put('attachmentId', 'Test');
        
        REN_DownloadCtrl downObj = new REN_DownloadCtrl();
        PageReference pageObj = downObj.authenticateAndDownload();
        
        System.assert(downObj.ibReportURL == null);
		
    }
}