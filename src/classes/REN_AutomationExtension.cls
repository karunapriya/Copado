/**
* Created Date      : Oct 4, 2018
* Developed By      : Smita, Comity Designs, Inc.
*
* Function          : @description - Description about the functionality that the class provides
* Support Email     : email
* Version           : 1.0
*
* Modification Log
*
* Developer Name            User Story              Date            Version             Description
*____________________________________________________________________________________________________
*
* Smita                 US3851              Oct 4, 2018            1.1                 @description
*
*/
global with sharing class REN_AutomationExtension {
global class QuoteParameter{
        @InvocableVariable(required=true)
        global Id QuoteId;
        @InvocableVariable(required=true)
        global String flowName;
    }
    
	@InvocableMethod 
	public static void invoke(List<QuoteParameter> QuoteParameter) {
        calloutmethod(new List<String>{QuoteParameter[0].flowName}, new List<String>{QuoteParameter[0].QuoteId} );
    }

    @future(callout=true)
    global static void calloutmethod(List<String> flowNameList, List<String> quoteIdList){
        CSM_TriggerManager.disableAllTriggers();
        String flowName = flowNameList[0];
        Id quoteId = (Id)quoteIdList[0];
        String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
        List<REN_RS_Config__c> configSettingList = REN_RSIntegrationUtil.getRSConfiguration(new List<String>{flowName}, new List<String>{'Quote'});
        REN_RSIntegrationUtil.REN_RSConfigWrapper RSConfigWrapper= new REN_RSIntegrationUtil.REN_RSConfigWrapper();
        if(configSettingList != null && !configSettingList.isEmpty()){
        	RSConfigWrapper.configObj = configSettingList[0];
            RSConfigWrapper.jsonString = '"quoteId":"'+quoteId+'"';
            REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
            HttpResponse res = callout.postHttpRequest(REN_RSIntegrationUtil.constructJson(RSConfigWrapper));
            Boolean chatterIsEnabled = REN_ChatterUtil.isChatterEnabled();
            List<sObject> chatterFeedItems = new List<sObject>();
            List<Opportunity> oppList = CHL_Util.getObjectListByWhereClause(new Set<String>{'OwnerId'},'Opportunity','Id IN (select OpportunityId from '+CHL_Constants.OBJ_QUOTE+' where Id IN ( \''+String.join(new List<String>{quoteId}, '\',\'')+'\') )');	
            if(res != null && res.getStatusCode() != 200){               
                REN_MessageWrapper messageWrapper = new REN_MessageWrapper();
                REN_RSIntegrationUtil.updateQuote(new Set<Id>{QuoteId}, new List<String>{'In Review'}, true);
                messageWrapper = (REN_MessageWrapper)JSON.deserialize(res.getBody(),REN_MessageWrapper.class);
                REN_MessageWrapper.error er=messageWrapper.error;
                REN_LowTouchUtil.updateErrorLog(System.Label.REN_LBL_DELL_AUTOMATION, er.message, quoteId);
                String[] errStr = er.message.split(',');
                for(String str:errStr){
                    String postMsg = String.format(str, new String[]{String.valueOf(System.now()), oppList[0].ownerId , quoteId});
                    chatterFeedItems.add(REN_ChatterUtil.addChatterMessage(oppList[0].ownerId, postMsg, URL.getSalesforceBaseUrl().toExternalForm()+'/'+ quoteId));
                }
                if (!chatterFeedItems.isEmpty()){
                    REN_ChatterUtil.saveChatterMessages(chatterFeedItems);
            	} 
            }
            else{
                String templateName = flowName == system.Label.REN_LBL_APPROVE ? 'Discount_Approval_Approve' : 'Discount_Approval_Reject'; 
                String status = flowName == system.Label.REN_LBL_APPROVE ? 'Completed' : 'Rejected';
                REN_RSIntegrationUtil.updateQuote(new Set<Id>{QuoteId}, new List<String>{status}, false);
                List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName =: templateName];
                if(!lstEmailTemplates.isEmpty()){
               		REN_Util.sendEmailNotificationUsingTemplate(new Set <Id>{oppList[0].ownerId}, lstEmailTemplates[0].id, quoteId);   
                }
            }
        }               
    }
}