public with sharing class REN_LowTouchAccess {
    //Client Id based on the connected app in your org currently but once managed package is created it will always have one clientid	
    private String clientId = '3MVG9xOCXq4ID1uENR_n0vamNcUe9ZLvV5u6WlgtJadkZc0g2oPziiYw_zmgIZ2nM1snEstkjU8uv83t1cCgR';
    
    //Client Secret based on the connected app in your org currently but once managed package is created it will always have one Client Secret	
    private String clientSecret = '8901595080838278142';
	
	public AuthResponse authResp {get; private set;}
	public String at {get; set;}
	
	public PageReference getAccessToken(){
    	List<SS_License__c> LTSetting = [Select REN_Domain__c, REN_LowTouchRefreshToken__c  From SS_License__c s limit 1];
    	if (!LTSetting.isEmpty()){
    		String url= 'https://login.salesforce.com/services/oauth2/token';
	        String[] params = new String[] {clientId, clientSecret, LTSetting[0].REN_Domain__c+ApexPages.currentPage().getUrl(), LTSetting[0].REN_LowTouchRefreshToken__c};
			String payload = String.format('grant_type=refresh_token&client_id={0}&client_secret={1}&redirect_uri={2}&refresh_token={3}', params);
			HttpResponse res = HttpSend(payload, url, 'POST');
			if(res.getStatusCode() == 200){
	        	System.debug('Response access token = '+res.getBody());
	        	authResp = parseAuthResponse(res.getBody());
	        	at = authResp.access_token;
			}
    	}	
    	return null;
	}
	
	/**
		* @description Built HTTP request using HttpSend 
		* @param JSONPayload for http request
		* @param EndPoint for http request
		* @param Method GET or POST
		* @return HttpResponse 
		*/  
    private HttpResponse HttpSend(String JsonPayload, String endPoint, String method)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setTimeout(30*1000);
       
        req.setMethod(method);
        
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        if (method == 'POST')
        {
            req.setBody(JSonPayload);
        }
        HttpResponse res;
        // Send the request, and return a response 
        if(!Test.isRunningTest()){
            res = h.send(req);
        }else{
            res = new HttpResponse();
            res.setBody('{"id":"https://login.salesforce.com"}');
            res.setStatusCode(200);
            res.setStatus('200');
        }
        return res;
    }
    
    /**
		* @description SafeJSONMapCast - cast the value using MAP<String, Object> 
		* @param object that we need to cast
		* @return Map<String, Object>
		*/  
    private Map<String, Object> SafeJSONMapCast(Object objTemp) 
	{
	    return (objTemp != null) ? (Map<String, Object>)objTemp : null;
    }
        
    /**
		* @description parseAuthResponse - Parse through the response body and retrieve refresh token, access token and instance URL 
		* @param responseBody - based on the http request response body is sent 
		* @return AuthResponse
		*/ 
    private AuthResponse parseAuthResponse(String responseBody){
        Map<String, Object> authMap = SafeJSONMapCast(JSON.deserializeUntyped(responseBody));
        
        String refreshToken = string.valueof(authMap.get('refresh_token'));
        String accessToken = string.valueof(authMap.get('access_token'));
        String instanceUrl = string.valueof(authMap.get('instance_url'));
        
        AuthResponse resp = new AuthResponse();
        resp.refresh_token = refreshToken;
        resp.access_token = accessToken;
        resp.instance_url = instanceUrl;
        resp.orgId = UserInfo.getOrganizationId();
        
        return resp;
    }
    
    /**
		* @description Class AuthResponse - Required to parse the AuthResponse 
		*/ 
    private with sharing class AuthResponse {
		//public String id{get;set;}
		//public String issued_at{get;set;}
		//public String scope{get;set;}
		public String instance_url{get;set;}
		public String refresh_token{get;set;}
		//public String signature{get;set;} 
		public String access_token{get;set;} 
		public String userId{get;set;}
		public String orgId{get;set;}
	}
    
}