/**
 * Created Date     : May 10, 2018
 * Developed By     : Tanvi Sarolkar, Comity Designs, Inc.
 *
 * Function         : @description - This class is used to handle get and post request for Quote Bulk Import service from Opportunity.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log :
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Tanvi		           US3344              May 10, 2018         1.0        description   
 *
 */
 public with sharing class REN_RSSignedURLService extends REN_JSONAPIBusinessLayer {
    
	/* This method is used to handle GET response for import Quote */
	
	public override String getResponse(Set<String> oppIdSet){
		
		REN_JSONAPIPayLoad payLoad = new REN_JSONAPIPayLoad();
	    REN_JSONAPIPayLoad.mainData mainData = new REN_JSONAPIPayLoad.mainData();
	    payLoad.data = new List<REN_JSONAPIPayLoad.mainData>();
	    payLoad.action = 'GET';
	    payLoad.links = new Map<String, String>();
	    payLoad.links.put('self' , '/s3_presigned_url'); 
        List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();     	
		payLoad.status='SUCEESS';
		try{
			Set<String> flowNames = new Set<String>{'s3_presigned_url'};
           	List<sObject> configSettingList = REN_RSIntegrationUtil.getConfigSettings(flowNames);
           	sObject configSettingObj;
           	if(configSettingList != null && !configSettingList.isEmpty()){
           		configSettingObj = configSettingList[0];
           	}          	
           	REN_RSIntegrationUtil.REN_RSIntegrationWrapper wrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();
           	String responseStr = '';
            HTTPResponse res = new HTTPResponse();
           	if(configSettingObj != null ){
               //wrapper.endPointToAppend = 'PresignedUrl';
               wrapper.action = 'GET';
               wrapper.namedCredential = String.valueOf(configSettingObj.get('REN_Named_Credential__c'));
               wrapper.namedCredentialExtn = String.valueOf(configSettingObj.get('REN_Named_Credential_URL_Extension__c'));
               REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
               res = callout.postHttpRequest(wrapper); 
           	}
	        if(res.getStatusCode() == 200){
	        	Map<String, String> urlmap = new Map<String, String>();
		    	urlmap =(Map<String, String>)JSON.deserialize(res.getbody(), Map<String, String>.class);
		        if(urlmap != null && !urlmap.isEmpty())	{
		        	mainData.type = 's3_presigned_url';
		        	mainData.id = urlmap.get('attachmentId');
			   		mainData.attributes = new Map<String,String>();
		        	mainData.attributes.put('attachmentid',urlmap.get('attachmentId'));
		        	mainData.attributes.put('url', urlmap.get('url'));
		        	payLoad.data.add(mainData);
		        } 
	        }
	        else{
	        	payLoad.status='ERROR';
            	REN_HandleOpportunityStageUpdate.updateErrorLog(system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, res.getbody(), (new List<String>(oppIdSet))[0]);
            	errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, 'Exception occured',res.getbody()));
            	payLoad.errors = errorList;
	        }
	               	        
	        
		}catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            payLoad.status='ERROR';
            REN_HandleOpportunityStageUpdate.updateErrorLog(system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, e.getMessage(), (new List<String>(oppIdSet))[0]);
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, 'Exception occured', e.getMessage()));
            payLoad.errors = errorList;
            
        }		 
		return JSON.serialize(payLoad);

	}
	
	
	/* This method is used to handle POST response  */
	
	public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad) {
     	
     	return JSON.serialize(payLoad);
    }
    
}