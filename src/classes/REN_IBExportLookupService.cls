/**
 * Created Date     : June, 04 2018
 * Developed By     : Vishal, Comity Designs, Inc.
 *
 * Function         : @description - Handling Lookup based on user's search
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Vishal                   User Story              June, 04 2018    1.0         Handling Lookup based on user's search   
 *
 */
 public with sharing class REN_IBExportLookupService extends REN_JSONAPIBusinessLayer {
	
	public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
    	return null;
    }
    
    /***This method will return JSON for all LT Languages**/
    /***Example - {"data": [{"type": "FieldName","id": "1234","attributes": {"Id": "1234","displayName": "Leena"}},
    						{"type": "FieldName","id": "1234","attributes": {"Id": "1234","displayName": "Leena"}},
    						{"type": "FieldName","id": "1234","attributes": {"Id": "1234","displayName": "Leena"}}
    						],"links":{"self":"/IBExportLookup"},"action": "GET"}
	/***This method will retuen JSON for picklist field**/	
 	public override String getResponse(Set<String> paramSet) {
 		REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
	    /*payLoadParent.data = new List<REN_JSONAPIPayLoad.mainData>();
	    try{
	    	
	    	String referenceObjName = null;
	    	String fieldAPIName = null;
	    	String searchString = null;
	    	
	    	if(paramSet != null && !paramSet.isEmpty()){
	    		List<String> paramList = new List<String>(paramSet);
	    		List<String> paramSplitList = paramList[0].split(',');
	    		
	    		if(paramSplitList != null && !paramSplitList.isEmpty() && paramSplitList.size() >= 2){
	    			searchString = paramSplitList[0];
	    			fieldAPIName = paramSplitList[1];
	    			referenceObjName = paramSplitList[2];
	    		}
	    	}
	    	
	    	// We will get it from Opportunity Status log for now, JJ will provide more input if this is not the case
	    	List<REN_LT_Active_Languages__c> activeLanguagesList =  REN_LT_Active_Languages__c.getall().values();
	    	if (!activeLanguagesList.isEmpty() && activeLanguagesList != null){
	    		REN_JSONAPIPayLoad.mainData payLoad;
	    		
	    		if(searchString != null && referenceObjName != null && String.isNotBlank(referenceObjName) && fieldAPIName != null && String.isNotBlank(fieldAPIName)){
                
	            	List<sObject> rsLookupFlMapList = REN_RSLookupFieldMappingDataAccess.getLookupFieldMapSetting(new Set<String>{referenceObjName});
	            	
	                if(rsLookupFlMapList != null && !rsLookupFlMapList.isEmpty()){
	                    System.debug('** ' + rsLookupFlMapList[0]);
	                    String baseNamespace = CSM_Util.getNamespace();
				
	                    REN_RSIntegrationUtil.REN_RSIntegrationWrapper lookupwrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();
	                    lookupwrapper.namedCredential = (String)rsLookupFlMapList[0].get(baseNamespace + 'REN_Named_Credential__c');
	                    lookupwrapper.namedCredentialExtn = (String)rsLookupFlMapList[0].get(baseNamespace + 'REN_Named_Credential_URL_Extension__c');
	                    lookupwrapper.endPointToAppend = '?$select=_id,displayName&$filter=startswith(' + fieldAPIName + '\'' + searchString + '\'';
	                    lookupwrapper.action = 'POST';
	                    
	                    REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
	                	HttpResponse resp = callout.postHttpRequest(lookupwrapper);
	                    
	                    String respStr = '{"@odata.context": "http://sbx.dev.ssi-cloud.com/odata/frb1/dell/$metadata#core_organizations(_id,displayName)","value": [{"_id": "51a6855a72338ce8f002bdcd","displayName": "CITY OF SPOKANE_CN044"},{"_id": "51a6855a72338ce8f002bddf","displayName": "CITY OF NEW YORK_CN046"},{"_id": "51a6855b72338ce8f002beae","displayName": "CITY OF JACKSON_CN077"}]}';
	                    
	                    if(resp != null || resp.getStatusCode() == 200){
	                        JSONParser parser = JSON.createParser(resp.getBody());
	                        payLoad = new REN_JSONAPIPayLoad.mainData();
	                        
	                        while (parser.nextToken() != null){
	                            Boolean newRecordflag = false;
	                            if(parser.getCurrentToken() == JSONToken.START_ARRAY){
	                                while (parser.nextToken() != null) {
	                                    if(parser.getCurrentToken() == JSONToken.START_OBJECT && newRecordflag == true){
	                                        payLoadParent.data.add(payLoad);
	                                        payLoad = new REN_JSONAPIPayLoad.mainData();
	                                    }
	                                    
	                                    if(parser.getText().equalsIgnoreCase('_id')){
	                                        parser.nextToken();
	                                        payLoad.Id = parser.getText();
	                                    }else if(parser.getText().equalsIgnoreCase('displayName')){
	                                        parser.nextToken();
	                                        payLoad.attributes = new Map<String,String>();
	                                        payLoad.attributes.put('displayname', parser.getText());
	                                    }
	                                    
	                                    newRecordflag = true;
	                                }
	                            }
	                        }
	                        payLoadParent.data.add(payLoad);
	                    
	                        System.debug('** ' + payLoadParent.data);
	                    }
	                    
	                }
	                
	            }
	    		
	    		payLoadParent.action = 'GET';
			    payLoadParent.links = new Map<String, String>();
			    payLoadParent.links.put('Self','/IBExportLookup');  
			    payLoadParent.status = 'SUCCESS';
	    	}
	    }catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>(); 
            payloadParent.status='ERROR';
            Id oppId = null;
            REN_LowTouchUtil.updateErrorLog(system.Label.CHL_LBL_STAGE_ONLOAD, e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString(), null);
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, 'Exception occured', e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString()));
            payLoadParent.errors = errorList;
            
        }*/
        return JSON.serialize(payLoadParent);	    
	 }
	 
	 /*public with sharing class REN_LookupValues{
	 	public string Id {get; set;}
	 	public string displayName {get; set;}
	 } */       
}