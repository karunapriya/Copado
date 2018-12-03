public with Sharing class CRUDCheckController {
   
    public pageReference updateOppty() {
        List<String> opptyFieldList = new List<String>{'Description'};
        try {
            List<Opportunity> opptyList = [SELECT Name, Description FROM Opportunity WHERE Name = 'new SO' Limit 1];
            opptyList[0].Description = 'Test';
            CSM_Util.checkCRUD_FLS('Opportunity', opptyFieldList, CSM_Constants.DML_OPERATION_UPDATE);
            update opptyList;
            System.debug('No Error occurred');
        } catch (Exception ex){
            String str = 'Error occurred - '+ex;
            ApexPages.addMessages(ex);
            System.debug(str);
        }
        return null;
    }
    
    
   public String accountName { get; set; }
    public static Account account { get; set; }
    public CRUDCheckController() { attach = new Attachment(); } // empty constructor
    
    @RemoteAction
    public static Account getAccount(String accountName) {
        account a = [SELECT Id, Name, Phone, Type, NumberOfEmployees 
                   FROM Account limit 1];
        return a;
    }
    
    public Attachment attach {get;set;}
    
    public void uploadFile(){
      attach.parentId= '0061N00000TnHFv';
      insert attach;
    }
    
    public String myresponse{get;set;}
    
        
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
    
    public void makeCallOut(){
    
       try
       {
           List<REN_Admin_Low_Touch__c> LTSetting = [Select Refresh_Token__c  From REN_Admin_Low_Touch__c s limit 1];

           String url = 'https://login.salesforce.com/services/oauth2/token';
           String[] params = new String[] {'3MVG9xOCXq4ID1uGMycswRCH.bYdlOMFZ63_f9sKQdIXVwlbAsqpS2ZtnCqVWGBOsicoiN3E5tW4u_Y8.YF7K', '8003496201933324381', LTSetting[0].Refresh_Token__c, 'https://ldlt-qa-dev-ed.my.salesforce.com/apex/AuthorizeCommunity'};
           String payload = String.format('grant_type=refresh_token&client_id={0}&client_secret={1}&refresh_token={2}&redirect_uri={3}', params);
           System.debug('payload - '+payload);
           HttpResponse res = HttpSend(payload, url, 'POST');
           System.debug('res >>>'+res);
           String accessToken;
           if(res.getStatusCode() == 200){
               AuthResponse body = parseAuthResponse(res.getBody());
               accessToken = body.access_token;
               System.debug('Access Response = '+accessToken);
           }
           
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setMethod('POST');
    		
            req.setHeader('content-type', 'text/html');
            req.setHeader('Content-Length','1024');
            req.setBody('{}');
            req.setTimeout(100000);
            url = 'https://ldlt-qa-dev-ed.my.salesforce.com/services/apexrest/updateAccountDescription';
            system.debug('Response URL'  +url);   
            req.setEndpoint(url);   
            //req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
            req.setHeader('Authorization', 'OAuth '+accessToken);
            
            System.debug('Check - '+req);
            HTTPResponse resp = http.send(req);
            myresponse= accessToken + '  \n '   +resp.getBody();
        
        }
        catch(System.CalloutException e){
         ApexPages.addMessages(e);
        System.debug('Sorry, You have an error ' + e.getMessage());
        } 
    }
	    
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
    
    public void AuthorizeCommunity(){
    
    }
    
}