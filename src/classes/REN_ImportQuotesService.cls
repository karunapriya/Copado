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
 public with sharing class REN_ImportQuotesService extends REN_JSONAPIBusinessLayer {
    
	/* This method is used to handle GET response for import Quote */
	
	public override String getResponse(Set<String> oppIdSet){
		return null;
	}
	
	
	/* This method is used to handle POST response  */
	
	public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad) {
        REN_JSONAPIPayLoad payloadParent = payLoad;
        List<REN_JSONAPIPayLoad.mainData> mainData = payloadParent.data;
        Map<String,String> inputFormMap = new Map<String,String>();
        String opptyCurrency = '';
    	inputFormMap = (Map<String,String>)JSON.deserialize(JSON.serialize(mainData[0].attributes), Map<String,String>.class);
     	List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();     	
		payloadParent.status='SUCCESS';
        try{
        	String whereCondition = 'WHERE REN_Flow_Name__c= \'Quote Import\'';
	        List<String> configFields = new List<String>{'REN_Named_Credential__c','REN_Named_Credential_URL_Extension__c','REN_Field_Set_Name__c','REN_Flow_Name__c','REN_Columns__c','REN_Custom_Object__c','REN_Custom_Permission_Name__c','REN_Display_Dialog__c','REN_SOQL__c','REN_Number_Of_Columns__c','REN_Invoking_Object__c','REN_Response_Object__c','REN_Display_Response_Dialog__c'};
	        List<REN_RS_Config__c> configSettingList = REN_RSConfigurationDataAccess.getRSConfigration(configFields,new List<String>{whereCondition});        
           	REN_RS_Config__c configSettingObj;
           	if(configSettingList != null && !configSettingList.isEmpty()){
           		configSettingObj = configSettingList[0];
           	}
           	if(UserInfo.isMultiCurrencyOrganization()){
           		List<Opportunity> opptyList = REN_OpportunityDataAccess.getOpportunityDetailsForCurrency(new Set<String>{inputFormMap.get('oppid')});
           		if(opptyList != null && !opptyList.isEmpty()){
           			opptyCurrency = (String)opptyList[0].get('CurrencyIsoCode');
           		}
           	}
           	REN_RSIntegrationUtil.REN_RSIntegrationWrapper wrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();
            HTTPResponse res = new HTTPResponse();
           	if(configSettingObj != null ){
               wrapper.action = 'POST';
               wrapper.namedCredential = configSettingObj.REN_Named_Credential__c;
               wrapper.namedCredentialExtn = configSettingObj.REN_Named_Credential_URL_Extension__c;
               wrapper.jsonData = '{"oppId":"'+inputFormMap.get('oppid')+'","caseId":"'+inputFormMap.get('caseId')+'","lineItemsAttachment":"'+inputFormMap.get('attachmentid')+'","dateFormat":"'+inputFormMap.get('dateformat')+'","delimiter":"'+inputFormMap.get('delimiter')+'","numberFormat":"'+inputFormMap.get('numberformat')+'","currency":"'+opptyCurrency+'"}' ;
               REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
               res = callout.postHttpRequest(wrapper); 
               Boolean chatterIsEnabled = REN_ChatterUtil.isChatterEnabled();
               List<sObject> chatterFeedItems = new List<sObject>();
                if (res != null && chatterIsEnabled && res.getStatusCode() == 200)
                {
                	Map<String, String> urlmap = new Map<String, String>();
		    		urlmap =(Map<String, String>)JSON.deserialize(res.getbody(), Map<String, String>.class);
                    String postMsg = String.format(urlmap.get('value'), new String[]{String.valueOf(System.now()), UserInfo.getName(), inputFormMap.get('oppid')});
                    chatterFeedItems.add(REN_ChatterUtil.addChatterMessage(inputFormMap.get('oppid'), postMsg, null));
                }
                if (!chatterFeedItems.isEmpty())
            	{
            		REN_ChatterUtil.saveChatterMessages(chatterFeedItems);
            	}
            }
        	if(res != null && res.getStatusCode() != 200){
                payloadParent.status='ERROR';
                REN_MessageWrapper messageWrapper = new REN_MessageWrapper();
                messageWrapper = (REN_MessageWrapper)JSON.deserialize(res.getBody(),REN_MessageWrapper.class);
                REN_MessageWrapper.error er = messageWrapper.error;
            	REN_LowTouchUtil.updateErrorLog(system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, er.message, (Id)inputFormMap.get('oppid'));
            	errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, 'Exception occured',er.message));
            	payLoadParent.errors = errorList;
            }
        }catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            payloadParent.status='ERROR';
            REN_LowTouchUtil.updateErrorLog(system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, e.getMessage()+ ';\nStack Trace:' + e.getStackTraceString(), (Id)inputFormMap.get('oppid'));
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.REN_LBL_IMPORT_QUOTE_FROM_OPPORTUNITY, 'Exception occured', e.getMessage()));
            payLoadParent.errors = errorList;
            
        }
        system.debug('JSON.serialize(payLoadParent)==='+JSON.serialize(payLoadParent));
		return JSON.serialize(payLoadParent);
    }    
}