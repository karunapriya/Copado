/**
 * Created Date		: Jun 14, 2018
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: @description - This is ctrl extension for dynamic button VF Page created as part of US3531. This is global class, if in future if RS team wants to invoke same flows from ifferent object, then they can do so without creation package.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Tanvi					US3531				Jun 14, 2018			1.1					@description
 *
*/
global with sharing class REN_DynamicButtonsCtrl {

    private sObject obj;
    private Map<String, String> buttonsMap;
    global Set<String> buttonsKeys {get; private set;}
    global String buttonValue {get; set;}
    global String redirectValue {get; private set;}
    global Map<String, Boolean> buttonNCustomPermissionMap {get; set;}
    
    /*
    @Description: Below Method construct map of Button Label & its corresponding action, It have one more map for button label & its corresponding custom permission. If user does not have that custom permission then corresponding button appears disabled on VF Page.
    			  It have SOQL inside FOR Loop , but we can not avoid it, as we need to check if that button is satisfying the critera of the record. It will always run for 1 record. At any point there won't be more than 10 buttons so it won't hit governor limit.	
    */
    global REN_DynamicButtonsCtrl(ApexPages.StandardController stdController) {
    	try {
	    	this.obj = stdController.getRecord();
	    	Id recId = (ID)this.obj.get('Id');
	        String objName = this.obj.getSObjectType().getDescribe().getName();
	        Boolean isCustomPermissionAssigned;
	        List<REN_RS_Dynamic_Button__c> buttonConfigList = REN_RSDynamicButtonDataAccess.getRSButtons(new Set<String>{objName} , new List<String>{'REN_RS_Configuration__c','REN_RS_Action__c','REN_RS_Button_Criteria__c','REN_RS_Button_Label__c'});
	        if(buttonConfigList != null && !buttonConfigList.isEmpty()) {
		        buttonsMap = new Map<String, String>();
		        buttonNCustomPermissionMap = new Map<String, Boolean>();
		        String whereCluase ='';
		        String buttonURL;
		        Map<String, String> translatedStringMap = REN_RSLanguageSupportDataAccess.getMapOfTranslatedStrings(new Set<String>{UserInfo.getLanguage()}, new List<String>{'REN_Translated_Text__c', 'REN_English_Text__c', 'REN_Language_Code__c'});
	        	String buttonLabel;
	        	for (REN_RS_Dynamic_Button__c button : buttonConfigList){
		            whereCluase = button.REN_RS_Button_Criteria__c != null && String.isNotBlank(button.REN_RS_Button_Criteria__c) ? ' AND ' + button.REN_RS_Button_Criteria__c  : '';
		            List<SObject> recList = CHL_Util.getObjectListByWhereClause(new Set<String>{'Id'}, objName, 'Id=\''+String.escapeSingleQuotes(recId) + '\'' +whereCluase); 
		            isCustomPermissionAssigned = button.REN_RS_Configuration__r.REN_Custom_Permission_Name__c != null && String.isNotBlank(button.REN_RS_Configuration__r.REN_Custom_Permission_Name__c) ? SS_LicenseCheck.getInstance().isDynamicCustomPermissionAssigned(button.REN_RS_Configuration__r.REN_Custom_Permission_Name__c) : true;
		            buttonLabel = translatedStringMap != null && translatedStringMap.containsKey(button.REN_RS_Button_Label__c) ? translatedStringMap.get(button.REN_RS_Button_Label__c) : button.REN_RS_Button_Label__c;
		            if (!recList.isEmpty()){
		            	if((UserInfo.getUserType()).equalsIgnoreCase('PowerPartner')){
		            		buttonURL = button.REN_RS_Action__c;
		            		buttonURL = buttonURL.replace('/apex', Site.getBaseUrl());
		            		buttonsMap.put(buttonLabel, buttonURL);	
		            	}else{
		            		buttonsMap.put(buttonLabel, button.REN_RS_Action__c);	
		            	}
		                buttonNCustomPermissionMap.put(buttonLabel, isCustomPermissionAssigned);
		            }
		        }
		        if(buttonsMap != null && !buttonsMap.isEmpty()) {
		        	buttonsKeys = buttonsMap.keySet();
		        }
	        } else {
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, system.label.REN_ERR_CONFIGURATION_MISSING));
	        }
    	} catch (Exception ex){
                   
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        } 
    	
    }
    
    global PageReference redirectToVFPage(){
        this.redirectValue = buttonsMap != null && !buttonsMap.isEmpty() ? buttonsMap.get(buttonValue)+this.obj.Id : '';
        return null;
    }
}