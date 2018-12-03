/**
 * Created Date     : Dec 5, 2016
 * Developed By     : Dheeraj, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj                  US1836              Dec 5, 2016         1.1                 @description
 *
 */
public with sharing class CHL_SegmentCallout {

    

     public CHL_SegmentCallout(){}
    
     public void sendCalloutToSegmentIdentity(String jsonData,String endPoint){
                    
        // create an HTTPrequest object    
        HttpRequest req = new HttpRequest();
        // set up the HTTP request with a method, endpoint, header, and body
        req.setMethod('POST');
       
        req.setEndpoint(endPoint);
        CSM_Admin__c admin_setting = CSM_Admin__c.getOrgDefaults();
        if(String.isNotBlank(admin_setting.CHL_Segment_API_Key__c)){
            req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(admin_setting.CHL_Segment_API_Key__c)));
            req.setHeader('Content-Type', 'application/json');
            req.setBody(jsonData);
            Http http = new Http();
            if(!Test.isRunningTest()){
                HTTPResponse res = http.send(req);
            }
        }
        //System.debug('Fulfillment service returned '+ res.getBody());
            
    }
}