@isTest
public class CHL_PartnerCommunityUserUtilityTest implements HttpCalloutMock{

  static testMethod void testUserUtilities() {
     
     CHL_PartnerCommunityUserUtility userUtil = new CHL_PartnerCommunityUserUtility();
     
     test.startTest();
     String str = userUtil.portalFavIconURL;
     Test.setMock(HttpCalloutMock.class, new CHL_PartnerCommunityUserUtilityTest());
        
        
     CSM_Admin__c mycs = CSM_Admin__c.getValues(UserInfo.getOrganizationId());
     if(mycs == null) {
        mycs = new CSM_Admin__c(CHL_Segment_API_Key__c= 'testtocken');
        insert mycs;
     }
        
        
        
     system.assertEquals(userUtil.login(),null);
     
     userUtil.changePassword();
     userUtil.forgotPassword();
     CHL_PartnerCommunityUserUtility.makeChangeCallout();
     
     String loginPage = CHL_PartnerCommunityUserUtility.loginPage;
     String forgotPasswordPage = CHL_PartnerCommunityUserUtility.forgotPasswordPage;
     
     system.assertEquals(loginPage,Page.CHL_PartnerLogin.getUrl()+'?lang='+ApexPages.currentPage().getParameters().get('lang'));
     system.assertEquals(forgotPasswordPage,Page.CHL_PartnerForgotPassword.getUrl());
     test.stopTest();
  }
  
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://api.segment.io/v1/batch', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"test":"testdata"}');
        res.setStatusCode(200);
        return res;
    }
}