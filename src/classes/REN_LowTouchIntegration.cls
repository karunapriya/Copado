/**
 * Created Date     : Feb ,18 2018
 * Developed By     : Vishal, Comity Designs, Inc.
 *
 * Function         : @description - Low Touch Integration Class to get the Refresh token, Access token etc
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Vishal                   User Story              Feb 18, 2018    1.0         Low Touch oAuth refresh token save to custom settings   
 *
 */
 public with sharing class REN_LowTouchIntegration {

	public static String accessToken {get; private set;}
     
    /*
    	@Get the Authorization Code from URL
    */
	public static HttpResponse makeGetCallout(string endPointURL) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endPointURL);
		request.setMethod('GET');
		HttpResponse response = http.send(request);
		return response;
	}
	
	/**
		 @Determines the true API hostname for a Salesforce org using the Identity API.
		 @eg 'https://pod.salesforce.com' (most orgs)
		 @eg 'https://custom.my.salesforce.com' (my domain)
		 @eg 'https://custom--dev.pod.my.salesforce.com' (sandbox orgs)
	*/
	public static String getProtocolAndHost() {
		//memoize
		String uid = UserInfo.getUserId();
		String sid = UserInfo.getSessionId();
		String oid = UserInfo.getOrganizationId();
		String base = Url.getSalesforceBaseUrl().toExternalForm();

        //use getSalesforceBaseUrl within batches and schedules (not Visualforce), and fix inconsistent protocol
        if (sid == null) {
        	return base.replaceFirst('http:', 'https:');
        }

        //within test context use url class, else derive from identity response
        PageReference api = new PageReference('/id/' + oid + '/' + uid + '?access_token=' + sid);
        String content = Test.isRunningTest() ? '{"urls":{"profile":"' + base + '"}}' : api.getContent().toString();
        Url profile = new Url(content.substringBetween('"profile":"', '"'));
        String protocolAndHost = profile.getProtocol() + '://' + profile.getHost();
        return protocolAndHost;
	}
	
	
	
	/**
		@description Get Refresh token based on Authorization code and save it to Custom Settings
		@return AuthResponse (private class - although not required to be returned)
	*/  
    public static string getRefreshToken(String authCode, String oAuthURL)	{
    	String refreshToken = null;
        // Get the SS License object where refresh token can be saved.
        SS_License__c ssLicenseObj = SS_License__c.getOrgDefaults(); 
        // AuthResponse
        AuthResponse authResp;
	    if (ssLicenseObj != null && ssLicenseObj.REN_Low_Touch_Consumer_Key__c != null && ssLicenseObj.REN_Low_Touch_Consumer_Secret__c != null)	{
	    	     
	        // Parameters required for authorization code based on clientId, secret and redirect URL
	        String[] params = new String[] {authCode, ssLicenseObj.REN_Low_Touch_Consumer_Key__c, ssLicenseObj.REN_Low_Touch_Consumer_Secret__c, ssLicenseObj.REN_Domain__c+ApexPages.currentPage().getUrl()};
	        String payload = String.format('code={0}&grant_type=authorization_code&client_id={1}&client_secret={2}&redirect_uri={3}', params);
	        System.debug('Payload -> '+payload);
	        // Get oauth code based on HTTP request
	        HttpResponse res = HttpSend(payload, oAuthURL, 'POST');	        
	        System.debug('Res -> '+res);
	        // Response code
	        if(res.getStatusCode() == 200)	{	        	
	        	// Get the response body and retrieve refresh token
	            String body = res.getBody();
	        	System.debug('Response = '+body);
	            authResp = parseAuthResponse(body);
	            
	            if (authResp != null && authResp.refresh_token != null)	{	            	
		            refreshToken = authResp.refresh_token;					
				}
	        }
        }
        return refreshToken;
    }
    
    /*
    	@Description : Retrive the access token based on Refresh token.
    */
    public static String getAccessToken() {
    	//REN_LowTouchIntegration ltIntegration = new REN_LowTouchIntegration();
		organization orgInfo = [select IsSandbox from Organization where id=:Userinfo.getOrganizationId()];
    	String environmentURL = orgInfo.IsSandbox ? 'https://test.salesforce.com' : 'https://login.salesforce.com';
    	String oAuthURL = environmentURL + '/services/oauth2/token';
        accessToken = null;
    	SS_License__c ssLicenseObj = SS_License__c.getOrgDefaults();
		String communityURL = '';
		if(CSM_AccessController.hasObject('Network'))	{
	        List<sObject> lstOfCommunities = Database.query('SELECT Name,UrlPathPrefix,Id FROM Network where name =\'PRISMDigitalRenewals\''); //
	        if(lstOfCommunities!=null && !lstOfCommunities.isEmpty())	{
	            communityURL = Network.getLoginUrl((Id)lstOfCommunities.get(0).get('Id'));
	        }	     
        } 
	    if(ssLicenseObj != null && ssLicenseObj.REN_Low_Touch_Consumer_Key__c != null && ssLicenseObj.REN_Low_Touch_Consumer_Secret__c != null)	{
            //String url = 'https://login.salesforce.com/services/oauth2/token';
			String[] params = new String[] {ssLicenseObj.REN_Low_Touch_Consumer_Key__c, ssLicenseObj.REN_Low_Touch_Consumer_Secret__c, communityURL, ssLicenseObj.REN_LowTouchRefreshToken__c};
			String payload = String.format('grant_type=refresh_token&client_id={0}&client_secret={1}&redirect_uri={2}&refresh_token={3}', params);
			HttpResponse res = HttpSend(payload, oAuthURL, 'POST');
			if(res.getStatusCode() == 200)	{
	            String body = res.getBody();
                AuthResponse authResp = parseAuthResponse(body);
                accessToken = authResp.access_token;
	        	System.debug('Response access token = '+body);
			}			
        }        
		
		return accessToken;
	}
	
	/**
		@description Built HTTP request using HttpSend 
		@param JSONPayload for http request
		@param EndPoint for http request
		@param Method GET or POST
		@return HttpResponse 
	*/  
    private static HttpResponse HttpSend(String JsonPayload, String endPoint, String method)	{
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setTimeout(30*1000);
       
        req.setMethod(method);
        
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        if (method == 'POST')	{
            req.setBody(JSonPayload);
        }
        HttpResponse res;
        // Send the request, and return a response 
        if(!Test.isRunningTest()) {
    		res = h.send(req);
        } else {
	        res = new HttpResponse();
	        res.setBody('{"id":"https://login.salesforce.com"}');
	        res.setStatusCode(200);
	        res.setStatus('200');
        }
        return res;
    }
    
    /**
		@description SafeJSONMapCast - cast the value using MAP<String, Object> 
		@param object that we need to cast
		@return Map<String, Object>
	*/  
    private static Map<String, Object> SafeJSONMapCast(Object objTemp)	{
	    return (objTemp != null) ? (Map<String, Object>)objTemp : null;
    }
    
    /**
		@description parseAuthResponse - Parse through the response body and retrieve refresh token, access token and instance URL 
		@param responseBody - based on the http request response body is sent 
		@return AuthResponse
	*/ 
    private static AuthResponse parseAuthResponse(String responseBody)	{
        Map<String, Object> authMap = SafeJSONMapCast(JSON.deserializeUntyped(responseBody));
        
        String refreshToken = string.valueof(authMap.get('refresh_token'));
        String accessTokenStr = string.valueof(authMap.get('access_token'));
        String instanceUrl = string.valueof(authMap.get('instance_url'));
        
        AuthResponse resp = new AuthResponse();
        resp.refresh_token = refreshToken;
        resp.access_token = accessTokenStr;
        resp.instance_url = instanceUrl;
        resp.orgId = UserInfo.getOrganizationId();
        
        return resp;
    }
    
    

    /**
		@description Class AuthResponse - Required to parse the AuthResponse 
	*/ 
    public with sharing class AuthResponse {
		public String instance_url {get; set;}
		public String refresh_token {get; set;}
		public String access_token {get; set;} 
		public String userId {get; set;}
		public String orgId {get; set;}
	}
    
   
}