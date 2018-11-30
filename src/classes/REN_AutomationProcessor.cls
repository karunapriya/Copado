public class REN_AutomationProcessor {
    public REN_CreditBalance__c cb {get; set;}
    public String idAttrib {get; set;}
    public String fieldSetName {get;set;}
    public String result {get;set;}
    
    public Map<String,String> mapFSlabel {get;set;}
    private void getLabels(){
		Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        //In this example I have hard coded the object name  
        Schema.sObjectType sObjType = globalDescription.get('REN_CreditBalance__c');  
          
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        mapFSlabel = new Map<String,String>();
        Map<String , Schema.SObjectField> mapFieldList = r1.fields.getMap();  
        Integer i = 0;  
        for(Schema.SObjectField field : mapFieldList.values())  
		{  
            Schema.DescribeFieldResult fieldResult = field.getDescribe();  
            mapFSlabel.put(fieldResult.getName(), fieldResult.getLabel());
            i++;  
		}  
	}
                               
    public REN_AutomationProcessor (){
    	String idVal = ApexPages.currentPage().getParameters().get('Id');
        List<Opportunity> opp = [SELECT Id, Account.BUID__c, (SELECT Id, Name FROM Quotes WHERE IsSyncing=true) FROM Opportunity WHERE Id=:idVal];
		cb = new REN_CreditBalance__c();
        cb.REN_Opportunity__c = opp[0].Id;
        cb.REN_BUID__c  = opp[0].Account.BUID__c;
        cb.REN_Quote__c = opp[0].Quotes[0].Id;
        List<String> fields = new List<String>();
        fields.add('REN_Opportunity__c');
        fields.add('REN_BUID__c');
		fields.add('REN_Quote__c');
        fieldSetName = 'REN_CreditBalance__c.FieldSets.CBFields';
        getLabels();
        result = '';
    } 
    
    public PageReference submitFlow(){
        result = '';
		String jsonStr = '{"filter":"OpportunityId eq \''+cb.REN_Opportunity__c +'\' AND BUID eq \'' + cb.REN_BUID__c + '\' AND QuoteId eq \''+cb.REN_Quote__c + '\'';
        jsonStr += '","select":"OpportunityId, BUID, QuoteId"}';
        System.debug('JSON - '+jsonStr);
		HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json'); 
        req.setHeader('Accept','*/*');
        req.setEndpoint('https://sqa.dev.ssi-cloud.com/odata/frb1/dell_report/app_coveredassets/dell.Echo');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json'); 
        req.setBody(jsonStr);
        req.setTimeout(120000);
        // Because we didn't set the endpoint as a named credential, 
        // our code has to specify:
        // - The required username and password to access the endpoint
        // - The header and header information
        
        //String username = 'username@test.com';
        //String password = 'passwordddd';
        
        //Blob headerValue = Blob.valueOf(username + ':' + password);
        
		Blob headerValue = Blob.valueOf('bruce.lewis@dell.com' + ':' + 'passwordone');
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        System.debug('  authorizationHeader - '+authorizationHeader);
        req.setHeader('Authorization', authorizationHeader);
        
        // Create a new http object to send the request object
        // A response object is generated as a result of the request  
        System.debug('Req - '+req);
        try {
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Request Sent');
            System.debug('Response - ' +res.getBody()); 
            System.debug('Header Keys - ' +res.getHeaderKeys()); 
            System.debug('Status - ' +res.getStatusCode()); 
            // check response 
            if ((res.getStatusCode() == 200 || res.getStatusCode() == 201) && res.getBody() != null && res.getBody() != null) {
                result = res.getBody();
                System.debug('result -'+result);
                return null;
            } 
		} catch (Exception ex){
            System.debug('ex - '+ex);
        }
        return null;
    }
}