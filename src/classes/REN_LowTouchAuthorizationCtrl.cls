/**
 * Created Date     : April ,6 2018
 * Developed By     : Tanvi, Comity Designs, Inc.
 *
 * Function         : @description - This is controller for LowTouch Authorization Page, to authorize low touch community and to save refresh token to custom settings
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Tanvi                   US3310              April ,6 2018	    1.0         Low Touch oAuth refresh token save to custom settings   
 *
 */
public with sharing class REN_LowTouchAuthorizationCtrl {
	
	//Need to put all the static string within constants
    private static String CODE = 'code';
    
    private Boolean updatedRefreshToken {get; set;}
	public string lowTouchConsumerKey { get; set;}
    public string lowTouchConsumerSecret {get;set;}    
    public Boolean isSectionHidden {get;set;}
    public String helpParam {get; set;}     
    public final String OAUTH_URL = '/services/oauth2/authorize?response_type=code';    
	public final String SALESFORCE_LOGIN_URL;
    public String oAuthUrl{get;set;}
    
    public REN_LowTouchAuthorizationCtrl() {
        
        
        SS_License__c ssLicenseObj = SS_License__c.getOrgDefaults();
        if(ssLicenseObj.REN_Low_Touch_Consumer_Key__c != null && ssLicenseObj.REN_Domain__c != null && ssLicenseObj.REN_Domain__c != '' && ssLicenseObj.REN_Low_Touch_Consumer_Secret__c != null && ssLicenseObj.REN_Low_Touch_Consumer_Key__c != '' && ssLicenseObj.REN_Low_Touch_Consumer_Secret__c != '') {
        	this.isSectionHidden = true; 
        }
        else{
        	this.isSectionHidden = false;
        }
    	helpParam = CSM_Constants.HELP_LOW_TOUCH;
    	organization orgInfo = [select IsSandbox from Organization where id=:Userinfo.getOrganizationId()];
        this.SALESFORCE_LOGIN_URL = orgInfo.IsSandbox ? 'https://test.salesforce.com' : 'https://login.salesforce.com';
    }
    
    /**
		* @description After the oauth code is received, retrieve the refresh token and save it to the custom settings
		* @return PageReference
		*/   
    public PageReference init() {
    	if (updatedRefreshToken == null || updatedRefreshToken == false){
	    	// Get the codes from the call back from salesforce
			String authCode = ApexPages.currentPage().getParameters().get(CODE); 
	        System.debug('authCode - ' + authCode+'this.SALESFORCE_LOGIN_URL :: '+this.SALESFORCE_LOGIN_URL);
	        if (authCode != null){
	        	helpParam = CSM_Constants.HELP_LOW_TOUCH;
	        	try {
		        	//REN_LowTouchIntegration ltIntegration = new REN_LowTouchIntegration();
		        	String refreshToken = REN_LowTouchIntegration.getRefreshToken(authCode, this.SALESFORCE_LOGIN_URL + '/services/oauth2/token');
		        	if(refreshToken != null && String.isNotBlank(refreshToken)) {
	        			SS_License__c ssLicenseObj = SS_License__c.getOrgDefaults(); 
	    				ssLicenseObj.REN_LowTouchRefreshToken__c = refreshToken;
						upsert ssLicenseObj;
		        		updatedRefreshToken = true;
           				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.REN_LT_AUTHORIZATION_SUCCESS));
		        	} else {
		        		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_LT_AUTHORIZATION_EXCEPTION));
		        	}
		        } catch (Exception ex){
                   
		        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		        } 	
	        }
        } 
        return null;
    }
  
    
    /**
		* @description Get oAuth URL based on client id to get the authorization code.  Called from the UI on button link. Also Update the domain in custom setting.
		* @Load the page again with URL with authorization code
		*/  
	public PageReference getDomain() {		
        SS_License__c ssLicenseObj = SS_License__c.getOrgDefaults();
        PageReference detailpage;
        try {
		    if (ssLicenseObj != null && ssLicenseObj.REN_Low_Touch_Consumer_Key__c != null){
	    		//Get oAuth URL based on client id to get the authorization code.	
		    	Integer statusCode = getDetails(ssLicenseObj);
				if (statusCode != 400) {
					detailpage = new PageReference(this.oAuthUrl);
				} else{
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_LT_AUTHORIZATION_EXCEPTION));
                }		    	
				
	        } else {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_LT_AUTHORIZATION_ERROR));
            } 
        } catch (Exception ex){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }    
		return detailpage;
	}
    
    /*get details of oauth url**/
    public  Integer getDetails(SS_License__c ssLicenseObj) {
    	String nameSpacePrefix = CSM_Util.getNamespace();
    	this.oAuthUrl = this.SALESFORCE_LOGIN_URL + this.OAUTH_URL + '&client_id='+ ssLicenseObj.REN_Low_Touch_Consumer_Key__c + '&redirect_uri='+ssLicenseObj.REN_Domain__c+ApexPages.currentPage().getUrl()+'&state=mystate'; ///apex/'+nameSpacePrefix+'REN_LowTouchAuthorization
        Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(oAuthUrl);
		request.setMethod('GET');
        HttpResponse response = http.send(request);
        system.debug('response :: '+response.getbody());
        return response.getStatusCode();
        
    }
    
    /**save consumer key and cosumer secret into custom setting from connected app**/
    public void saveSetting() {
        try{ 
            
            String domain = REN_LowTouchIntegration.getProtocolAndHost();
	     	SS_License__c ssLicenseObj = SS_License__c.getOrgDefaults();
            if(ssLicenseObj != null) {
            	ssLicenseObj.REN_Low_Touch_Consumer_Key__c = this.lowTouchConsumerKey;
            	ssLicenseObj.REN_Low_Touch_Consumer_Secret__c = this.lowTouchConsumerSecret; 
                ssLicenseObj.REN_Domain__c = domain;
            }
            Integer StatusCode = getDetails(ssLicenseObj);
            if(StatusCode == 400){
             	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_CONSUMER_KEY_AND_SECRET));    
            }
            else{
            	this.isSectionHidden = true;
                upsert ssLicenseObj;
            }
	    }  
     	catch(Exception e){
     		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
		}
       
      
    }
    
   
    
}