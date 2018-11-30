/**
 * Created Date		: May 16, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: smitah@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					US3344			May 16, 2018			1.1					@description
 *
 */
public with sharing class REN_s3_presigned_urlService extends REN_JSONAPIBusinessLayer{
/* This method is used to handle GET response for import Quote */
	
	public override String getResponse(Set<String> oppIdSet){
		
		REN_JSONAPIPayLoad payLoad = new REN_JSONAPIPayLoad();
	    REN_JSONAPIPayLoad.mainData mainData = new REN_JSONAPIPayLoad.mainData();
	    payLoad.data = new List<REN_JSONAPIPayLoad.mainData>();
	    payLoad.action = 'GET';
	    payLoad.links = new Map<String, String>();
	    payLoad.links.put('self' , '/s3_presigned_url'); 
        List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();     	
		payLoad.status='SUCCESS';
		try{
			String whereCondition = 'WHERE REN_Flow_Name__c= \'s3_presigned_url\'';
	        List<String> configFields = new List<String>{'REN_Named_Credential__c','REN_Named_Credential_URL_Extension__c','REN_Field_Set_Name__c','REN_Flow_Name__c','REN_Columns__c','REN_Custom_Object__c','REN_Custom_Permission_Name__c','REN_Display_Dialog__c','REN_SOQL__c','REN_Number_Of_Columns__c','REN_Invoking_Object__c','REN_Response_Object__c','REN_Display_Response_Dialog__c'};
	        List<REN_RS_Config__c> configSettingList = REN_RSConfigurationDataAccess.getRSConfigration(configFields,new List<String>{whereCondition});        
           	REN_RS_Config__c configSettingObj;
           	if(configSettingList != null && !configSettingList.isEmpty()){
           		configSettingObj = configSettingList[0];
           	}          	
           	REN_RSIntegrationUtil.REN_RSIntegrationWrapper wrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();
           	String responseStr = '';
            HTTPResponse res = new HTTPResponse();
           	if(configSettingObj != null ){
               wrapper.action = 'GET';
               wrapper.namedCredential = configSettingObj.REN_Named_Credential__c;
               wrapper.namedCredentialExtn = configSettingObj.REN_Named_Credential_URL_Extension__c;
               REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
               res = callout.postHttpRequest(wrapper); 
           	}
	        if(res != null && res.getStatusCode() == 200){
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
	        	REN_MessageWrapper messageWrapper = new REN_MessageWrapper();
                messageWrapper = (REN_MessageWrapper)JSON.deserialize(res.getBody(),REN_MessageWrapper.class);
                REN_MessageWrapper.error er = messageWrapper.error;
	        	ID oppId = null;
            	REN_LowTouchUtil.updateErrorLog(system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, er.message, oppId);
            	errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, 'Exception occured',er.message));
            	payLoad.errors = errorList;
	        }
	               	        
	        
		}catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            payLoad.status='ERROR';
            ID oppId = null;
            REN_LowTouchUtil.updateErrorLog(system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString(), oppId);
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