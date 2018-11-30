/**
 * Created Date		: Jun 20, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
 *
 * Function			: @description - This controller used to send http request to get the specific object records. This records are shown in a popup window.
 					  This functionality is resemble to salesforce standard lookup functionality.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dilip					US3545				Jun 20, 2018			1.1					@description
 *
 */
public with sharing class REN_CustomLookUpCtrl {
	public String searchValue{get;set;}
    public boolean onError{get;set;}
    private REN_RSIntegrationUtil.REN_RSIntegrationWrapper wrapper;
    public List<LookupfieldWrapper> lookupfieldWrapperList{get;set;}
    public String isRSRequired {get; set;}
    public String relationshipName {get; set;}
    
    public REN_CustomLookUpCtrl(){
        try{
            onError = true;
            searchValue = ApexPages.currentpage().getparameters().get('filterVal');
            relationshipName = ApexPages.currentpage().getparameters().get('relationshipName');
            isRSRequired = ApexPages.currentPage().getparameters().get('isRSReq');
            if(isRSRequired == 'false') {
            	getStandardRelInfo(relationshipName);
            } else {
            	getRelationshipInfo(relationshipName);	
            }
        }catch(Exception ex){
            onError = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input - '+ex.getMessage());
			ApexPages.addMessage(myMsg);
            System.debug('**ex ' + ex.getStackTraceString());
        }
    }
    
    public List<LookupfieldWrapper> getRelationshipInfo(String relationshipName){
        lookupfieldWrapperList = new List<LookupfieldWrapper>();
        wrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();
        System.debug('** ' + searchValue + '  ' + relationshipName);
        if(relationshipName != null && String.isNotBlank(relationshipName)){
            List<REN_RS_Config__c> rsConfigList = [Select Id, (Select Id, REN_Named_Credential__c, REN_Named_Credential_URL_Extension__c from RS_Lookup_Field_Mappings__r where REN_Object_API_Name__c =: relationshipName) from REN_RS_Config__c where REN_Flow_Name__c = 'IB Export'];
            System.debug('** ' + rsConfigList);
            if(rsConfigList != null && !rsConfigList.isEmpty()){
                List<REN_RS_Lookup_Field_Mapping__c> rsLookupFieldMapList = rsConfigList[0].RS_Lookup_Field_Mappings__r;
                
                if(rsLookupFieldMapList != null && !rsLookupFieldMapList.isEmpty()){
                    System.debug('** ' + rsLookupFieldMapList[0]);
                    wrapper.action = 'GET';
                    wrapper.namedCredential = rsLookupFieldMapList[0].REN_Named_Credential__c;
                    wrapper.namedCredentialExtn = rsLookupFieldMapList[0].REN_Named_Credential_URL_Extension__c; 
                    
                    getSearchResponse();
                }else{
                    onError = false;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_Config_Setting_Error, new List<String>{relationshipName}));
                    ApexPages.addMessage(myMsg);
                }
                    
            }
        }
        return lookupfieldWrapperList;
    }
    
    public void getSearchResponse(){
        System.debug('** ' + searchValue);
        if(searchValue != null && String.isNotBlank(searchValue) && isRSRequired == 'true'){
            //String encodedUrlStr = EncodingUtil.urlEncode('$top=50&$select=_id,displayName&$filter=startswith(displayName,\'' + searchValue.replace(' ','%20') + '\')', 'UTF-8');
            String encodedUrlStr = '$top=50&$select=_id,displayName&$filter=startswith(displayName,\'' + EncodingUtil.urlEncode(searchValue, 'UTF-8').replace('+', '%20') + '\')';
            wrapper.endPointToAppend = '?' + encodedUrlStr;
            
            REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
            HttpResponse resp = callout.postHttpRequest(wrapper);
            
            parseResponse(resp);
            
        } else if (searchValue != null && String.isNotBlank(searchValue) && isRSRequired == 'false') {
        	getStandardRelInfo(relationshipName);
        }
        
    }
    
    public PageReference showSearchResult(){
        try{
        	getSearchResponse();
        }catch(Exception ex){
            onError = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input - '+ex.getMessage());
			ApexPages.addMessage(myMsg);
            System.debug('**ex ' + ex.getStackTraceString());
        }
        return null;
    }
    
    public class LookupfieldWrapper{
        public String recordId{get;set;}
        public String displayName{get;set;}
    }  
    
    private void parseResponse(HttpResponse resp){
    	if(resp == null || resp.getStatusCode() != 200){
            onError = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_IBExport_Response_Error);
            ApexPages.addMessage(myMsg);
            
        }else{
            String responseStr = resp.getBody();  
            System.debug('**responseStr ' + responseStr);
            
            lookupfieldWrapperList = new List<LookupfieldWrapper>();
            
            JSONParser parser = JSON.createParser(responseStr);
            LookupfieldWrapper lookupfieldWrapperObj = new LookupfieldWrapper();
            
            while (parser.nextToken() != null){
                Boolean newRecordflag = false;
                if(parser.getCurrentToken() == JSONToken.START_ARRAY){
                    while (parser.nextToken() != null) {
                        if(parser.getCurrentToken() == JSONToken.START_OBJECT && newRecordflag == true && lookupfieldWrapperObj.recordId != null){
                            lookupfieldWrapperList.add(lookupfieldWrapperObj);
                            lookupfieldWrapperObj = new LookupfieldWrapper();
                        }
                        
                        if(parser.getText().equalsIgnoreCase('_id')){
                            parser.nextToken();
                            lookupfieldWrapperObj.recordId = parser.getText();
                        }else if(parser.getText().equalsIgnoreCase('displayName')){
                            parser.nextToken();
                            lookupfieldWrapperObj.displayName = parser.getText();
                        }
                        
                        newRecordflag = true;
                    }
                }
            }
            if(lookupfieldWrapperObj.recordId != null){
                lookupfieldWrapperList.add(lookupfieldWrapperObj);
                System.debug('** ' + lookupfieldWrapperList);
            }
        }
    }
    
    public List<LookupfieldWrapper> getStandardRelInfo(String relationshipName){
        lookupfieldWrapperList = new List<LookupfieldWrapper>();
        LookupfieldWrapper lookupfieldWrapperObj = new LookupfieldWrapper();
        if(relationshipName != null && String.isNotBlank(relationshipName)){
        	List<SObject> objectList;
        	String whereClause = String.isNotBlank(searchValue) ? ' where name like ' + '\'%' + String.escapeSingleQuotes(searchValue) + '%\'' : '';
        	relationshipName = String.isNotBlank(relationshipName) && relationshipName.equalsIgnoreCase('Group') ? 'User' :  String.escapeSingleQuotes(relationshipName);
        	String finalQuery = String.isNotBlank(relationshipName) ? 'select Id, name from '+relationshipName + whereClause + ' Limit 50' : '';
        	/*if(relationshipName == 'Account') {
        		finalQuery = 'select id, name from Account' + whereClause + ' Limit 50';
        	} else if(relationshipName == 'User') {
        		finalQuery = 'select id, name from User' + whereClause + ' Limit 50';
        	}*/
        	system.debug('finalQuery**'+finalQuery);
           	objectList = Database.query(finalQuery);
           	
            System.debug('objectList **' + objectList);
            if(objectList != null && !objectList.isEmpty()){
                for(SObject obj : objectList) {
                	lookupfieldWrapperObj = new LookupfieldWrapper();
                	lookupfieldWrapperObj.recordId = (String)obj.get('Id');
                	lookupfieldWrapperObj.displayName = (String)obj.get('Name');
                	lookupfieldWrapperList.add(lookupfieldWrapperObj);
                }    
            }
        }
        return lookupfieldWrapperList;
    }
}