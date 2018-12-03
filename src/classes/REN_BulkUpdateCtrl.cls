/**
 * Created Date		: Aug 23, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dilip					User Story				Aug 23, 2018			1.1					@description
 *
 */
public with sharing class REN_BulkUpdateCtrl {
	public String selectedRecords {get;set;}
    public String filterCriteriaStr {get;set;}
    Set<String> recordIdSet {get;set;}
    public sObject selectedObject {get;set;}
    public List<Schema.FieldSetMember> fieldSetMemberList {get;set;}
    private List<String> updatableFieldList;
    private REN_Custom_Search_Config__c customSearchObj;
    public String successMessage {get;set;}
    String objectName;
    Boolean updateAllRec;
    
    public REN_BulkUpdateCtrl(){
        try{
            objectName = ApexPages.currentPage().getParameters().get('objectName');
            updateAllRec = Boolean.valueOf(ApexPages.currentPage().getParameters().get('updateAllRecords'));
            updatableFieldList = new List<String>();
            customSearchObj = REN_Custom_Search_Config__c.getValues(objectName);
            selectedObject = Schema.getGlobalDescribe().get(objectName).newSObject();
            System.debug('**customSearchObj ' + customSearchObj);            
            if(customSearchObj != null && customSearchObj.REN_Mass_Update_FieldSet_Name__c != null){
                fieldSetMemberList = CHL_Util.getFieldSet(customSearchObj.REN_Mass_Update_FieldSet_Name__c, objectName);  
                
                if(fieldSetMemberList != null && !fieldSetMemberList.isEmpty()){
                    for(Schema.FieldSetMember fld : fieldSetMemberList){
                        updatableFieldList.add(fld.getFieldPath());
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.REN_Mass_Update_FieldSet_Error, new String[]{customSearchObj.REN_Mass_Update_FieldSet_Name__c, objectName})));
                }
            }
            
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));  
            System.debug('**ex ' + ex.getStackTraceString());
        }
    }
    
    public void setRecords(){
        recordIdSet = REN_Util.convertCSVtoSet(this.selectedRecords, '-');
        System.debug('**filterCriteriaStr ' + this.filterCriteriaStr);
    }
    
    public void updateRecords(){
        List<Opportunity> recordsToUpdate = new List<Opportunity>();
        try{
            List<sObject> updateList = new List<sObject>();
            if(this.recordIdSet != null && !this.recordIdSet.isEmpty()){
                
                //This block to process records in real time mode.
                if(customSearchObj != null && customSearchObj.REN_RS_Request_Limit_Threshold__c != null && recordIdSet.size() <= (Integer)customSearchObj.REN_RS_Request_Limit_Threshold__c && updateAllRec == false){
                    for(String recordId : this.recordIdSet){
                        
                        sObject tempsObject = Schema.getGlobalDescribe().get(objectName).newSObject();
                        for(Schema.FieldSetMember fieldMem : fieldSetMemberList){
                            
                            if(selectedObject.get(fieldMem.getFieldPath()) != null){
                                tempsObject.put(fieldMem.getFieldPath(), selectedObject.get(fieldMem.getFieldPath()));
                            }
                        }
                        tempsObject.put('Id', recordId);
                        updateList.add(tempsObject);
                    }
                    
                    if(!updateList.isEmpty()){
                        REN_Util.updateSObjectRecords(updateList,updatableFieldList,objectName);
                    }
                }else{// This block is to send request to RS
                    System.debug('**To RS request');
                    
                    sendUpdateRequestToRS();
                }
                    

            }
            
        }catch(Exception ex){
            System.debug('**ex ' + ex.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));      
		}
        
    }
    
    public void sendUpdateRequestToRS(){
    	String reqBodyStr = '';
        
        if(this.filterCriteriaStr == null || String.isBlank(this.filterCriteriaStr)){
            this.filterCriteriaStr = '{"filter":""}';
        }
                    
        //Set criteria in this case
        if(updateAllRec){
            reqBodyStr = this.filterCriteriaStr;
            reqBodyStr = reqBodyStr.substring(0, (reqBodyStr.length()-1)) + ',';
        }else{//Set Ids in this case
            reqBodyStr = '{"filter":"IN(Id,[\'' + String.join(new List<String>(this.recordIdSet), '\',\'')  + '\']) and StageName ne \'Closed Sale\'", ';//DE3431 - Provision
        }
        
        reqBodyStr += '"userId":"' + UserInfo.getUserId() + '","update":{"';
		for(Schema.FieldSetMember fieldMem : fieldSetMemberList){
                
            if(selectedObject.get(fieldMem.getFieldPath()) != null){
                reqBodyStr += fieldMem.getFieldPath() + '":"' + selectedObject.get(fieldMem.getFieldPath()) + '","';
            }
        }
        reqBodyStr = reqBodyStr.substring(0, (reqBodyStr.length()-2)) + '} }';
        
		System.debug('**reqBodyStr ' + reqBodyStr);  
        
        List<REN_RS_Config__c> configSettingList = REN_RSConfigurationDataAccess.getConfigByObjNFlow(new Set<String>{Label.REN_Bulk_Update}, new Set<String>{objectName}, new List<String>{'REN_Named_Credential__c','REN_Named_Credential_URL_Extension__c','REN_RS_Request_Timeout_Limit__c'});
        
        if(configSettingList != null && !configSettingList.isEmpty()){
            String baseNamespace = CSM_Util.getNamespace();
            REN_RSIntegrationUtil.REN_RSIntegrationWrapper updateWrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();
            updateWrapper.namedCredential = configSettingList[0].REN_Named_Credential__c;
            updateWrapper.namedCredentialExtn = configSettingList[0].REN_Named_Credential_URL_Extension__c;
            updateWrapper.timeout = (configSettingList[0].REN_RS_Request_Timeout_Limit__c != null ? (Integer)configSettingList[0].REN_RS_Request_Timeout_Limit__c : null);
            updateWrapper.jsonData = reqBodyStr;
            updateWrapper.action = 'POST';
            updateWrapper.auditTag = REN_RSIntegrationUtil.constructUniqueString();
            System.debug('**Req ' + updateWrapper);
            REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
            HttpResponse resp = callout.postHttpRequest(updateWrapper, true);
            
            if(resp != null && resp.getStatusCode() == 400){
                String badRequestErrorCode = REN_Util.jsonStrParser(new List<String>{resp.getBody()},'code');
                if(badRequestErrorCode == 'OD400'){
                	String errorMsg = REN_Util.jsonStrParser(new List<String>{resp.getBody()},'message');
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_REJECT_PROD_MSG2));
                } else {
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_Mass_Update_Request_Error));
                }
            }else if(resp == null || resp.getStatusCode() != 200){
            	if(!ApexPages.hasMessages()) {
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_Mass_Update_Request_Error));	
            	}
            }else{
                System.debug('**resp ' + resp + '   body   ' + resp.getBody());
                successMessage = REN_Util.jsonStrParser(new List<String>{resp.getBody()},'value');
                successMessage += '. '+ Label.REN_LBL_BULKUPDATE_SUCCESS_MSG;
    		}
        }
    }
}