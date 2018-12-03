/**
 * Created Date		: April 26, 2018
 * Developed By		: Rucha Palasapure, Comity Designs, Inc.
 *
 * Function			: This class is used to send POST request for IB Report Creation.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Rucha					US3342				April 26, 2018	  1.1			 Added in sprint 757
**/

public with sharing class REN_IBReportCallout {
	
    public system.HttpResponse postHttpRequest(String jsonData,String endPointToAppend, String action){
    	/*String namedCredential = 'IB_Report';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:'+ namedCredential +'/'+endPointToAppend); 
        req.setMethod(action);
        req.setHeader('Content-Type','application/json'); */
        //req.setHeader('Accept','*/*');
        /*if(action == 'POST' && jsonData != null){
        	req.setBody(jsonData);
        }
        Blob headerValue = Blob.valueOf('{!$Credential.UserName}' + ':' + '{!$Credential.Password}');
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        System.debug('Req - '+req);
        try {
            Http http = new Http();
            HTTPResponse response = http.send(req);
            System.debug('Response :: '+ response);
            return response;
		}
		catch (Exception ex){
            System.debug('ex - '+ex);
        }*/
        return null;
    }
}