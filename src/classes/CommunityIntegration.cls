public class CommunityIntegration {
    
    public with sharing class AuthResponse {
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
    
    public PageReference init() {
    	// Get the codes from the call back from salesforce
		String authCode = ApexPages.currentPage().getParameters().get('code'); 
        System.debug('authCode - ' + authCode);
        if (authCode != null){
            AuthResponse oAuthResponse = retriveRefreshTokenUsingCode(authCode);
            System.debug('AuthResponse - ' + oAuthResponse);
        }
        return null;
    }
    
    public String getoAuthUrlForCode(){
        
        return 'https://ldlt-qa-dev-ed.my.salesforce.com/services/oauth2/authorize?response_type=code&client_id=3MVG9xOCXq4ID1uGMycswRCH.bYdlOMFZ63_f9sKQdIXVwlbAsqpS2ZtnCqVWGBOsicoiN3E5tW4u_Y8.YF7K&redirect_uri=https://ldlt-qa-dev-ed.my.salesforce.com/apex/AuthorizeCommunity&state=mystate';
        
    }
    
    public AuthResponse retriveRefreshTokenUsingCode(String authCode){
        AuthResponse authResp;
        String responseBody = '';
        String url = 'https://login.salesforce.com/services/oauth2/token';
        String[] params = new String[] {authCode,'3MVG9xOCXq4ID1uGMycswRCH.bYdlOMFZ63_f9sKQdIXVwlbAsqpS2ZtnCqVWGBOsicoiN3E5tW4u_Y8.YF7K', '8003496201933324381', 'https://ldlt-qa-dev-ed.my.salesforce.com/apex/AuthorizeCommunity'};
        String payload = String.format('code={0}&grant_type=authorization_code&client_id={1}&client_secret={2}&redirect_uri={3}', params);
        HttpResponse res = HttpSend(payload, url, 'POST');
        
        if(res.getStatusCode() == 200){
            String body = res.getBody();
        	System.debug('Response = '+body);
            authResp = parseAuthResponse(body);
            List<REN_Admin_Low_Touch__c> LTSetting = [Select Refresh_Token__c  From REN_Admin_Low_Touch__c s limit 1];
            
            if (!LTSetting.isEmpty()){
                LTSetting[0].Refresh_Token__c = authResp.refresh_token;
				upsert LTSetting;
            }
        }
        return authResp;
    }
    
    public static HttpResponse HttpSend(String JsonPayload, String endPoint, String method)
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
    public Map<String, Object> SafeJSONMapCast(Object objTemp) 
	{
	    return (objTemp != null) ? (Map<String, Object>)objTemp : null;
    }
    
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

}