/**
* Created Date      : Jun 14, 2018
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
* Smita                 US3533              Jun 14, 2018            1.1                 @description
*
*/
public with sharing class REN_AutomationController {
    
    public List<string> fieldapiname{get;set;}
    public REN_RS_Config__c configSettingObj{get;set;}
    public sObject requestObj{get;set;}
    public sObject responseObj{get;set;}
    String objId;
    REN_RSIntegrationUtil.REN_RSConfigWrapper RSConfigWrapper;
    public Map<String,Boolean> isEditableMap{get;set;}
    Map<String,String> fieldParamMap;
    public boolean hasResponse{get;set;}
    public List<String> resFieldapiname{get;set;}
    public string ObjName{get;set;}
    sObject invokeObjRec;
    List<REN_RS_Field_Mapping__c> fieldmaping;
    public List<String> messageList {get;set;}
    Map<String,Schema.SObjectField> fieldMap;
    public Map<String,Boolean> fieldPicklistType {get;set;}
    public Map<String,String> fieldPicklistLabel {get;set;}
    //public Map<String,String> fieldPicklistDefaultValue {get;set;}
    public Map<String,List<SelectOption>> fieldPicklistValues {get;set;}
    String url;
    Map<String, REN_RS_Field_Mapping__c> fieldMappingMap;
    public Map<String, Boolean> isFieldRequiredInFS{get;set;}
    public boolean hasError{get;set;}
    public String submitButton{get;set;}
    public String cancelButton{get;set;}
    public String translatedFlowName {get;set;}
        
    public REN_AutomationController(){
        String flowName = ApexPages.currentPage().getParameters().get('flow');
        objId = ApexPages.currentPage().getParameters().get('id');
        objId = String.escapeSingleQuotes(objId);
        ObjName = ((Id)objId).getSObjectType().getDescribe().getName();
        //wrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();
        RSConfigWrapper = new REN_RSIntegrationUtil.REN_RSConfigWrapper();
        hasResponse = false;
        hasError = false;
        List<REN_RS_Config__c> configSettingList = REN_RSIntegrationUtil.getRSConfiguration(new List<String>{flowName}, new List<String>{ObjName});
        Map<String, String> translatedStringMap = REN_RSLanguageSupportDataAccess.getMapOfTranslatedStrings(new Set<String>{UserInfo.getLanguage()}, new List<String>{'REN_Translated_Text__c', 'REN_English_Text__c', 'REN_Language_Code__c'});
    	translatedFlowName = translatedStringMap != null && translatedStringMap.containsKey(flowName) ? translatedStringMap.get(flowName) : flowName;
    	if(configSettingList != null && !configSettingList.isEmpty()){
            configSettingObj = configSettingList[0];
            submitButton = (configSettingObj.REN_Button_Text_for_Submit__c != null && configSettingObj.REN_Button_Text_for_Submit__c != '')?configSettingObj.REN_Button_Text_for_Submit__c : System.label.CHL_LBL_SUBMIT;
            cancelButton = (configSettingObj.REN_Button_Text_for_Cancel__c != null && configSettingObj.REN_Button_Text_for_Cancel__c != '')?configSettingObj.REN_Button_Text_for_Cancel__c : System.label.CSM_LBL_CANCEL;
        	submitButton = translatedStringMap != null && translatedStringMap.containsKey(submitButton) ? translatedStringMap.get(submitButton) : submitButton;
        	cancelButton = translatedStringMap != null && translatedStringMap.containsKey(cancelButton) ? translatedStringMap.get(cancelButton) : cancelButton;
        } else {
            hasError = true;
        }
    }
    
    public List<String> getFields(list<REN_RS_Field_Mapping__c> fieldmaping){
        fieldapiname = new list<String>();
        fieldPicklistLabel = new Map<String,String>();
        //fieldPicklistDefaultValue = new Map<String,String>();
        fieldPicklistType = new Map<String,Boolean>();
        fieldPicklistValues = new Map<String,List<SelectOption>>();
        isEditableMap = new Map<String,Boolean>();
        fieldParamMap = new Map<String,String>();
        fieldMappingMap = new Map<String, REN_RS_Field_Mapping__c>();
        fieldMap = Schema.getGlobalDescribe().get(configSettingObj.REN_Custom_Object__c).getDescribe().fields.getMap();
        requestObj = Schema.getGlobalDescribe().get(configSettingObj.REN_Custom_Object__c).newSObject();
        isFieldRequiredInFS = new Map<String, Boolean>();
        List<Schema.FieldSetMember> fieldSetMemberList;
        String baseURL = REN_LowTouchIntegration.getProtocolAndHost();
        String[] objectAndField;
        sObject sRelatedObject;
        String csmNamespace = CSM_Util.getNamespace();
        String defaultValue;
        String urlPath;
        String[] urlAndFieldValue;
        Map<String, Schema.FieldSet> requestObjectFSMap = Schema.getGlobalDescribe().get(configSettingObj.REN_Custom_Object__c).getDescribe().fieldSets.getMap();
        if(String.isNotBlank(configSettingObj.REN_Field_Set_Name__c) && configSettingObj.REN_Field_Set_Name__c != null && requestObjectFSMap != null && requestObjectFSMap.containsKey(configSettingObj.REN_Field_Set_Name__c) ) {
            fieldSetMemberList = CHL_Util.getFieldSet(configSettingObj.REN_Field_Set_Name__c, configSettingObj.REN_Custom_Object__c);
        }
        Map<String,String> renewalStatusValuesMap = REN_ValueMappingDataAccess.getRenewalStatus();
        for(REN_RS_Field_Mapping__c fldMapObj:fieldmaping){
            fieldMappingMap.put(fldMapObj.REN_Param_Type__c+'_'+fldMapObj.REN_Custom_Mapped_Field__c, fldMapObj);        
            if(fldMapObj.REN_Param_Type__c == System.label.REN_LBL_INPUT){  
                fieldParamMap.put(fldMapObj.REN_Custom_Mapped_Field__c,fldMapObj.REN_oData_Param__c);
                Schema.DescribeFieldResult fd = fieldMap.get(fldMapObj.REN_Custom_Mapped_Field__c).getDescribe();
                
                // Get the picklist field and get the values to be displayed on the screen
                // We still needs to filter the values here
                if (fd.getType()==Schema.DisplayType.PICKLIST){
                    if (fldMapObj.REN_Picklist_Object__c!=null && fldMapObj.REN_Picklist_Field__c!=null){
                        List<SelectOption> options = new List<SelectOption>();
                        Schema.DescribeFieldResult fdPickListType = Schema.getGlobalDescribe().get(fldMapObj.REN_Picklist_Object__c).getDescribe().fields.getMap().get(fldMapObj.REN_Picklist_Field__c).getDescribe();
                        options.add(new SelectOption(' ',System.label.CSM_LBL_NONE));
                        if (fdPickListType.getType() == Schema.DisplayType.PICKLIST){
                            List<Schema.PicklistEntry> fdPickListValues = fdPickListType.getPicklistValues();
                            //System.debug('fdPickListValues -> '+fdPickListValues);
                            for( Schema.PicklistEntry f : fdPickListValues) {
                                if(fldMapObj.REN_Picklist_Object__c == csmNamespace+'REN_Renews_To__c' && fldMapObj.REN_Picklist_Field__c == csmNamespace+'REN_Renewal_Status__c' && renewalStatusValuesMap != null && !renewalStatusValuesMap.isEmpty() && fldMapObj.REN_Picklist_Filter__c != null){
                                    if (f.isActive() && renewalStatusValuesMap.containsKey(f.getLabel()) && renewalStatusValuesMap.get(f.getLabel()) == fldMapObj.REN_Picklist_Filter__c) {
                                        options.add(new SelectOption(f.getLabel(), f.getValue()));
                                    }   
                                }
                                else{
                                    if (f.isActive()) {
                                        options.add(new SelectOption(f.getLabel(), f.getValue()));
                                    }
                                }
                                
                            }  
                        }
                        fieldPicklistValues.put(fd.getName(), options);
                        
                        // We got this label in place because we were getting wrong label for the select list
                        fieldPicklistLabel.put(fd.getName(), fd.getLabel());
                        defaultValue = fldMapObj.REN_PickList_Default_Value__c != null && String.isNotBlank(fldMapObj.REN_PickList_Default_Value__c) ? fldMapObj.REN_PickList_Default_Value__c : ' ';
                    } 
                    if(String.isNotBlank(fldMapObj.REN_Object_Field_Name__c) && fldMapObj.REN_Object_Field_Name__c != null) {
                    	requestObj.put(fd.getName(),invokeObjRec.get(fldMapObj.REN_Object_Field_Name__c));
                    }  else {
                        if(fldMapObj.REN_Picklist_Object__c != null && fldMapObj.REN_Picklist_Field__c != null) {
                            requestObj.put(fd.getName(), defaultValue);
                        } else {
                            requestObj.put(fd.getName(), null);
                        }
                    }
                } else {
	                if(fldMapObj.REN_Object_Field_Name__c != null && (fldMapObj.REN_Object_Field_Name__c.startswith('$') || fldMapObj.REN_Object_Field_Name__c.contains('$')) ) {
	                	fldMapObj.REN_Object_Field_Name__c = (fldMapObj.REN_Object_Field_Name__c).containsIgnoreCase('$baseURL') ? (fldMapObj.REN_Object_Field_Name__c.toLowerCase()).replace('$baseurl', baseURL) : fldMapObj.REN_Object_Field_Name__c;
	                    //fldMapObj.REN_Object_Field_Name__c = (fldMapObj.REN_Object_Field_Name__c).containsIgnoreCase('$Id') ? (fldMapObj.REN_Object_Field_Name__c.toLowerCase()).replace('$id', objId) : fldMapObj.REN_Object_Field_Name__c;
	                    fldMapObj.REN_Object_Field_Name__c = (fldMapObj.REN_Object_Field_Name__c).containsIgnoreCase('$UserId') ? (fldMapObj.REN_Object_Field_Name__c.toLowerCase()).replace('$userid', UserInfo.getUserId()) : fldMapObj.REN_Object_Field_Name__c;
	                    urlPath = (fldMapObj.REN_Object_Field_Name__c).contains('/$') && !(fldMapObj.REN_Object_Field_Name__c).containsIgnoreCase('$UserId') ? fldMapObj.REN_Object_Field_Name__c.replace('/$','/=') : fldMapObj.REN_Object_Field_Name__c;
	                    if(urlPath.contains('=')){
	                    	urlAndFieldValue = urlPath.split('=');
	                    	fldMapObj.REN_Object_Field_Name__c = urlAndFieldValue != null && CSM_AccessController.hasField(ObjName, urlAndFieldValue[1]) ? urlAndFieldValue[0] + invokeObjRec.get(urlAndFieldValue[1]) : null; 
	                    }
	                    requestObj.put(fd.getName(),fldMapObj.REN_Object_Field_Name__c);                   	       
	                }else if(String.isBlank(fldMapObj.REN_Object_Field_Name__c) || fldMapObj.REN_Object_Field_Name__c == null) {
	                    requestObj.put(fd.getName(), null);
	                }else if(fldMapObj.REN_Object_Field_Name__c.indexOf('.')>-1) {
	                    objectAndField = (fldMapObj.REN_Object_Field_Name__c).split('\\.');
	                    sRelatedObject = invokeObjRec.getSObject(objectAndField[0].tolowercase());
	                    if(sRelatedObject != null) {                        
	                        requestObj.put(fd.getName(),sRelatedObject.get(objectAndField[1].tolowercase()));
	                    }
	                }else {                    
	                    requestObj.put(fd.getName(),invokeObjRec.get(fldMapObj.REN_Object_Field_Name__c));
	                }
                }
            }
        }
        System.debug('requestObj - > '+requestObj);
        List<REN_RS_Field_Mapping__c> fieldMappingList  = getFieldMappingList(fieldSetMemberList , System.label.REN_LBL_INPUT);  
        for(REN_RS_Field_Mapping__c fld:fieldMappingList){
            if(fld.REN_Param_Type__c == System.label.REN_LBL_INPUT){
                Schema.DescribeFieldResult fd = fieldMap.get(fld.REN_Custom_Mapped_Field__c).getDescribe();
                // As long as we have picklist object and picklist field we will include this to fieldPicklistType
                // We ignore picklist values like currency since it does not come from a list that are on the object
                if (fld.REN_Picklist_Object__c!=null && fld.REN_Picklist_Field__c!=null){
                    fieldPicklistType.put(fd.getName(), fd.getType()==Schema.DisplayType.PICKLIST);
                } else {
                    fieldPicklistType.put(fd.getName(), false);
                }
                fieldapiname.add(fd.getName());
                isEditableMap.put(fd.getName(),fld.REN_Editable__c);
                if(!(isFieldRequiredInFS != null && isFieldRequiredInFS.containsKey(fd.getName()))) {
                    isFieldRequiredInFS.put(fd.getName(), false);
                }
            }    
        }
        return fieldapiname;
    }
    
    public list<sObject> getObjectDetails(String soqlString){
        soqlString+= '\''+ String.escapeSingleQuotes(objId)+'\''+'limit 1';       
        return database.query(soqlString);        
    }
    
    public pageReference submit(){
        hasResponse = true; 
        PageReference pr = null;
        try{
            if(fieldParamMap != null && requestObj != null){
            	RSConfigWrapper.fieldParamMap = fieldParamMap;
                RSConfigWrapper.requestObj = requestObj;
                RSConfigWrapper.isFieldRequiredMap = isFieldRequiredInFS;
                REN_RSIntegrationUtil.REN_RSIntegrationWrapper wrapper = REN_RSIntegrationUtil.constructJson(RSConfigWrapper);
                if((wrapper.jsonData).equalsIgnoreCase('ERROR')) {
                    //hasError = true;
                    hasResponse = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, system.Label.REN_ERR_REQUIRED_FIELDS));
                } else {
                    REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
                    HTTPResponse res = new HTTPResponse();
                    res = callout.postHttpRequest(wrapper);
                    //system.debug('res---'+res.getBody()); 
                    pr = handleRedirection(res);       
                }   
            } else {
                hasError = true;
                hasResponse = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,System.label.REN_LBL_CONFIGURATION_ISSUE));
            }        
        }catch(Exception e){
            hasError = true;
            hasResponse = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,System.label.REN_LBL_CONFIGURATION_ISSUE));    
        }                                       
        return pr;
    }
    
    public pageReference showResponse(string response){
        resFieldapiname = new List<String>();
        PageReference pr = null;
        Map<String, String> responsemap = new Map<String, String>();
        responsemap =(Map<String, String>)JSON.deserialize(response, Map<String, String>.class);
        system.debug('response :: '+response);
        if(responsemap != null && !responsemap.isEmpty()){
            if(responsemap.containskey(System.label.REN_LBL_TARGET)){
                url = responsemap.get(System.label.REN_LBL_TARGET);
                system.debug('url :: '+url);
                pr = redirectToUrl();
            }
            else if(responsemap.containskey(System.label.REN_LBL_MESSAGE)){ 
                hasResponse = true;
                messageList = new List<String>();
                for(String mes:responsemap.keySet()){
                    messageList.add(responsemap.get(mes));                        
                }
            }
            else if(fieldmaping != null && !fieldmaping.isEmpty()){
                hasResponse = true;
                if(configSettingObj.REN_Response_Object__c != null){
                    responseObj = Schema.getGlobalDescribe().get(configSettingObj.REN_Response_Object__c).newSObject();
                    Map<String,Schema.SObjectField> responsefieldMap = Schema.getGlobalDescribe().get(configSettingObj.REN_Response_Object__c).getDescribe().fields.getMap();
                    Map<String, Schema.FieldSet> responseObjectFSMap = Schema.getGlobalDescribe().get(configSettingObj.REN_Response_Object__c).getDescribe().fieldSets.getMap();
                    List<Schema.FieldSetMember> fsListForResponseObject;
                    if(String.isNotBlank(configSettingObj.REN_Response_Object_Field_Set_Name__c) && configSettingObj.REN_Response_Object_Field_Set_Name__c != null && responseObjectFSMap != null && responseObjectFSMap.containsKey(configSettingObj.REN_Response_Object_Field_Set_Name__c)) {
                        fsListForResponseObject = CHL_Util.getFieldSet(configSettingObj.REN_Response_Object_Field_Set_Name__c, configSettingObj.REN_Response_Object__c);
                    }
                    List<REN_RS_Field_Mapping__c> fieldMappingList = getFieldMappingList(fsListForResponseObject , System.label.REN_LBL_OUTPUT);
                    for(REN_RS_Field_Mapping__c outputMapping: fieldMappingList){ 
                    	//system.debug('outputMapping.REN_Custom_Mapped_Field__c :: '+outputMapping.REN_Custom_Mapped_Field__c);
                        if(outputMapping.REN_Param_Type__c == System.label.REN_LBL_OUTPUT){
                            Schema.DescribeFieldResult fd = responsefieldMap.get(outputMapping.REN_Custom_Mapped_Field__c).getDescribe();
                            resFieldapiname.add(fd.getName());    
                            if(fd.getType().equals(Schema.DisplayType.DOUBLE) || fd.getType().equals(Schema.DisplayType.CURRENCY) || fd.getType().equals(Schema.DisplayType.PERCENT)){
                                if(responsemap.get(outputMapping.REN_oData_Param__c) != null) {
                                	responseObj.put(fd.getName(), Decimal.valueOf(responsemap.get(outputMapping.REN_oData_Param__c).replaceAll('[^.\\d]','')));   
                                } else {
                                	responseObj.put(fd.getName(), null);
                                }  
                           }else{
                                responseObj.put(fd.getName(), responsemap.get(outputMapping.REN_oData_Param__c)); 
                           }
                        }                        
                    }
                }                
            }        
        } 
        return pr;
    }

    public pageReference redirectToUrl(){
        if(url != null){
            return new pageReference(url);    
        }else{
           return new PageReference('/'+objId); 
        }        
    }  
    
    public pageReference init() {
        
        pageReference pr;           
        try{
            if(configSettingObj != null){
        		RSConfigWrapper.configObj = configSettingObj;
        		RSConfigWrapper.objectName = configSettingObj.REN_Custom_Object__c;
                
                // Added fields from RS Field Mapping
                list<String> requestedFields=new List<String>{'REN_oData_Param__c','REN_Custom_Mapped_Field__c','REN_Editable__c','REN_Param_Type__c','REN_Object_Field_Name__c', 'REN_Picklist_Object__c', 'REN_Picklist_Field__c','REN_Picklist_Filter__c','REN_PickList_Default_Value__c'};
                fieldmaping = REN_RSConfigurationDataAccess.getFieldMapping(new Set<String>{configSettingObj.Id},requestedFields);
                invokeObjRec = (getObjectDetails(configSettingObj.REN_SOQL__c)).get(0);
                fieldapiname = getFields(fieldmaping);
                if(!configSettingObj.REN_Display_Dialog__c){
                    //system.debug('fieldParamMap :: '+fieldParamMap);  
                    if(fieldParamMap != null && requestObj != null){
                        //wrapper.jsonData = REN_RSIntegrationUtil.constructJson(new list<String>{configSettingObj.REN_Custom_Object__c}, fieldParamMap, new List<sObject>{requestObj}, isFieldRequiredInFS);                         
                    	RSConfigWrapper.fieldParamMap = fieldParamMap;
                		RSConfigWrapper.requestObj = requestObj;
                		RSConfigWrapper.isFieldRequiredMap = isFieldRequiredInFS;
                    }            
                    REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
                    HTTPResponse res = new HTTPResponse();
                    res = callout.postHttpRequest(REN_RSIntegrationUtil.constructJson(RSConfigWrapper));  
                    hasResponse = true;
                    pr = handleRedirection(res);              
                }
            } else{
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,System.label.REN_LBL_CONFIGURATION_ISSUE));    
            }  
        }catch(Exception e){
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,System.label.REN_LBL_CONFIGURATION_ISSUE));    
        }                   
        return pr;
    }
    
    private List<REN_RS_Field_Mapping__c> getFieldMappingList(List<Schema.FieldSetMember> fieldSetMemList, String fldType){
    	List<REN_RS_Field_Mapping__c> fieldMappingList = new List<REN_RS_Field_Mapping__c>();
        if(fieldSetMemList != null && !fieldSetMemList.isEmpty()) {
            for(Schema.FieldSetMember fieldSetMember: fieldSetMemList){
                if(fieldMappingMap != null && !fieldMappingMap.isEmpty() && fieldMappingMap.containsKey(fldType+'_'+String.valueof(fieldSetMember.getFieldPath()))) {
                	fieldMappingList.add(fieldMappingMap.get(fldType+'_'+String.valueof(fieldSetMember.getFieldPath())));
                    isFieldRequiredInFS.put(String.valueof(fieldSetMember.getFieldPath()),fieldSetMember.getRequired());
                }
            }
        } else {
            fieldMappingList = fieldmaping;
        }
        return fieldMappingList;
    }
    public PageReference handleRedirection(HTTPResponse res){
    	pageReference pr;
    	if(res.getStatusCode() == 200 && configSettingObj.REN_Display_Response_Dialog__c){
        	pr = showResponse(res.getBody());    
        }else if(res.getStatusCode() == 200 && !configSettingObj.REN_Display_Response_Dialog__c){
        	pr = redirectToUrl(); 
        }
        else{          
        	if(configSettingObj.REN_Display_Response_Dialog__c)  {
       			REN_MessageWrapper messageWrapper = new REN_MessageWrapper();
                messageWrapper = (REN_MessageWrapper)JSON.deserialize(res.getBody(),REN_MessageWrapper.class);
                REN_MessageWrapper.error er=messageWrapper.error;
                String[] errStr = er.message.split(',');
                for(String str:errStr){
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,str));   
                }     
             } else {
             	pr = redirectToUrl(); 
             }           
        }
        return pr;    	   	
    }
}