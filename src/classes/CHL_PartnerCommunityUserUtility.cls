/**
  This class is shipped as part of channel package to enable partners use the service source branded user utility functionalities like:
   - Login to partner community
   - Reset password in partner community.
   - Change password in partner community.
*/

public with sharing class CHL_PartnerCommunityUserUtility {

    public String username {get; set;}   
    public String password {get; set;}
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;} 
    public Boolean isSuccess {get; set;}
    public Boolean loginError{get;set;}
    private static final String GA_SEGMENT_EVENT_ENDPOINT = 'https://api.segment.io/v1/track';
    public static String forgotPasswordPage {get{ forgotPasswordPage = Page.CHL_PartnerForgotPassword.getUrl(); 
                                                 return forgotPasswordPage;
                                                }
                                                set;
                                              } 
    
    public static String loginPage {get{ loginPage = Page.CHL_PartnerLogin.getUrl(); 
                                                 return loginPage+'?lang='+ApexPages.currentPage().getParameters().get('lang');
                                                }
                                                set;
                                              }                                           
    //DE1669 : below methood is used to get the url of Fav Icon from documents.
    public string portalFavIconURL {
        get{
            List<Document> documentList = [Select Id From Document where DeveloperName = 'Channel_Portal_Fav_Icon' limit 1];
            if(documentList != null && documentList.size() > 0){
                portalFavIconURL = Site.getPathPrefix()+'/servlet/servlet.FileDownload?file='+documentList[0].Id;
            } else {
                portalFavIconURL = '';
            }
            return portalFavIconURL; 
        }
        set;
    }
    
    public PageReference login() {
        PageReference result = null;
        result = Site.login(username, password, null);                 

        if (result == null){
            loginError = true;
            makeFailureCallout(Label.CHL_GA_LOGIN_EVENT, Label.CHL_GA_LOGIN_ACTION, Label.CHL_GA_LOGIN_CATEGORY,Label.CHL_GA_FAILURE_LABEL, username);
        }else{
            loginError = false;
            makeSegmentCallout(Label.CHL_GA_LOGIN_EVENT,Label.CHL_GA_LOGIN_ACTION,Label.CHL_GA_LOGIN_CATEGORY,Label.CHL_GA_SUCCESS_LABEL,username);
        }
        return result;
    }
    
    public void forgotPassword() {
        isSuccess = Site.forgotPassword(username);
        if(isSuccess){
            makeSegmentCallout(Label.CHL_GA_FORGOT_PASSWORD,Label.CHL_GA_FORGOT_PASS_ACTION,Label.CHL_GA_FORGOT_PASSWORD_CATEGORY,Label.CHL_GA_FORGOT_PASSWORD_LABEL,username);
        }
    }
    
    public PageReference changePassword() {
        PageReference result = null;
        result = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
        if(result != null){
            makeChangeCallout();
        }
        return result;
    }

    @future(callout=true)
    public static void makeChangeCallout() {
       makeSegmentCallout(Label.CHL_GA_CHANGE_PASS,Label.CHL_GA_CHANGE_PASS_ACTION,Label.CHL_GA_CHANGE_PASS_CATEGORY,Label.CHL_GA_SUCCESS_LABEL,null);        
    }
    
    @future(callout=true)
    public static void makeFailureCallout(String eventName, String actionName, String actionCategory,String label, String userName) {
         makeSegmentCallout(eventName,actionName,actionCategory,label,userName);                               
    }

    
    public static void makeSegmentCallout(String calloutEvent, String calloutAction, String actionCategory, String label, String userEmail){
        CHL_SegmentEventHandler.WrapperClass segmentWrapper = new CHL_SegmentEventHandler.WrapperClass(calloutEvent,calloutAction,actionCategory,label,null,null,userEmail);
        CHL_SegmentEventHandler eventHandler = CHL_SegmentEventHandler.newInstance();
        String jsonString = eventHandler.getEventStructure(segmentWrapper);
        
        CHL_SegmentCallout segmentCallout = new CHL_SegmentCallout();
        segmentCallout.sendCalloutToSegmentIdentity(jsonString, GA_SEGMENT_EVENT_ENDPOINT);
    }
}