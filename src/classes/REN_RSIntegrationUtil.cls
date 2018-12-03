/**
 * Created Date		: Apr 27, 2018
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
 * Smita					US3345				Apr 27, 2018			1.1					@description
 *
 */
public with sharing class REN_RSIntegrationUtil {
	
	public with sharing class REN_RSIntegrationWrapper {
        public String jsonData;
        public String endPointToAppend;
        public String action;
        public String namedCredential;
        public String namedCredentialExtn;
        public Integer timeout;
        public boolean getTimeOutException = false;
        public String auditTag;
    }
    
    public with sharing class REN_RSConfigWrapper{
    	public string objectName;
    	public Map<String,String> fieldParamMap;
    	public sObject requestObj;
    	public Map<String, Boolean> isFieldRequiredMap;
    	public string jsonString;
    	public REN_RS_Config__c configObj;
    }
    
    // Common method for web service request
	public system.HttpResponse postHttpRequest(REN_RSIntegrationWrapper wrapper){
    	HttpRequest req = new HttpRequest();
    	req.setEndpoint('callout:'+ wrapper.namedCredential + wrapper.namedCredentialExtn + (String.isNotBlank(wrapper.endPointToAppend)?'/'+wrapper.endPointToAppend:''));
        req.setMethod(wrapper.action);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','*/*');
        if(wrapper.auditTag != null && String.isNotBlank(wrapper.auditTag)) {
        	req.setHeader('audit-tag',wrapper.auditTag);
        }
        if(wrapper.timeout != null){
            req.setTimeout(wrapper.timeout);
        }else{
            req.setTimeout(60000);    
        }
       	if(wrapper.action == 'POST' && wrapper.jsonData != null){
        	req.setBody(wrapper.jsonData);
        }
        try {
            Http http = new Http();
            HTTPResponse response = http.send(req);
            System.debug('Response :: '+ response);
            return response;
		}
		catch (System.CalloutException ex){
			system.debug('ex.getMessage() :: '+ex.getMessage());
			if(String.valueOf(ex.getMessage()).equalsIgnoreCase('Read timed out') && wrapper.getTimeOutException) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.REN_LBL_RETRY_MSG));	
			}
        }
        return null;
    }
    
    public system.HttpResponse postHttpRequest(REN_RSIntegrationWrapper wrapper, Boolean getTimeOutException){
    	wrapper.getTimeOutException = getTimeOutException;
    	return postHttpRequest(wrapper);
    }
    
    
    //It returns configuration object according to the flow name passed to method
	public static List<sObject> getConfigSettings(Set<String> flowNames){
		String baseNamespace = CSM_Util.getNamespace();
        
		List<String> fieldNameList = new List<String>{baseNamespace + 'REN_Named_Credential__c', baseNamespace + 'REN_Named_Credential_URL_Extension__c', baseNamespace + 'REN_Field_Set_Name__c', 
			baseNamespace + 'REN_Flow_Name__c', baseNamespace + 'REN_Columns__c', baseNamespace + 'REN_Custom_Object__c', baseNamespace + 'REN_Custom_Permission_Name__c', baseNamespace + 'REN_Display_Dialog__c', baseNamespace + 'REN_SOQL__c'};
		
		CSM_Util.checkCRUD_FLS(baseNamespace + 'REN_RS_Config__c', fieldNameList, CSM_Constants.DML_OPERATION_READ);
		
		if(!flowNames.isEmpty()){
			
            String queryString = 'Select ' + baseNamespace + 'REN_Named_Credential__c, ' + baseNamespace + 'REN_Named_Credential_URL_Extension__c, ' + baseNamespace + 'REN_Field_Set_Name__c, ' + baseNamespace + 'REN_Flow_Name__c, ' + baseNamespace + 'REN_Columns__c, ' + baseNamespace + 'REN_Custom_Object__c, ' + baseNamespace + 'REN_Custom_Permission_Name__c, ' + baseNamespace + 'REN_Display_Dialog__c, ' + baseNamespace + 'REN_SOQL__c from ' + baseNamespace + 'REN_RS_Config__c where ' + baseNamespace + 'REN_Flow_Name__c IN :flowNames limit 10';
			
            List<sObject> configurationObjList = Database.query(queryString);
			system.debug('configurationObjList:::'+configurationObjList);
			if(!configurationObjList.isEmpty())
				return configurationObjList;
		}
		
		return null;
	}
	
	public static REN_RSIntegrationWrapper constructJson(REN_RSConfigWrapper RSConfigWrapper){
		String parameter;
		Map<String,Schema.SObjectField> fieldMap = new Map<String,Schema.SObjectField>();
		REN_RSIntegrationWrapper wrapper = new REN_RSIntegrationWrapper();
		REN_RS_Config__c configObj = RSConfigWrapper.configObj;
        wrapper.namedCredential = configobj.REN_Named_Credential__c;
        wrapper.namedCredentialExtn = configObj.REN_Named_Credential_URL_Extension__c;
        wrapper.action = 'POST';
        if(RSConfigWrapper.objectName != null){
       		fieldMap = Schema.getGlobalDescribe().get(RSConfigWrapper.objectName).getDescribe().fields.getMap();	
        }
        sObject requestObj = RSConfigWrapper.requestObj;
        parameter = '{';
        String formattedDate;
        DateTime currentDateNTime = system.now();
        Boolean isError = false;
        if(RSConfigWrapper.fieldParamMap != null && !RSConfigWrapper.fieldParamMap.isEmpty()){
        	for(String param:RSConfigWrapper.fieldParamMap.keySet()){	
	           	Schema.DescribeFieldResult fd = fieldMap.get(param).getDescribe();
	        	if(fd.getType().equals(Schema.DisplayType.BOOLEAN) && Boolean.Valueof(requestObj.get(param)) == false && RSConfigWrapper.isFieldRequiredMap != null && RSConfigWrapper.isFieldRequiredMap.containsKey(param) && RSConfigWrapper.isFieldRequiredMap.get(param) == true) {
	        		isError = true;
	        	} else if(fd.getType().equals(Schema.DisplayType.PICKLIST) && String.Valueof(requestObj.get(param)) == ' ' && RSConfigWrapper.isFieldRequiredMap != null && RSConfigWrapper.isFieldRequiredMap.containsKey(param) && RSConfigWrapper.isFieldRequiredMap.get(param) == true){
		       		isError = true;
		       	}else {
		           	if(fd.getType().equals(Schema.DisplayType.DATE) || fd.getType().equals(Schema.DisplayType.DATETIME)){
		           		formattedDate = (DateTime)requestObj.get(param) != null ? ((DateTime)requestObj.get(param)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') : ((DateTime)currentDateNTime).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
		               	parameter+= '"'+RSConfigWrapper.fieldParamMap.get(param)+'":"'+formattedDate+'",';    
		           	}	else if(fd.getType().equals(Schema.DisplayType.DOUBLE) ||  fd.getType().equals(Schema.DisplayType.BOOLEAN) || fd.getType().equals(Schema.DisplayType.CURRENCY) ){
		               	parameter+= '"'+RSConfigWrapper.fieldParamMap.get(param)+'":'+requestObj.get(param)+',';    
		           	}	else{
		               	parameter+= '"'+RSConfigWrapper.fieldParamMap.get(param)+'":"'+requestObj.get(param)+'",';  
		           	}    
	        	}        
        	//system.debug('param :: '+param + 'VALUE :: '+requestObj.get(param));    
       		}	
        }else{
        	parameter += RSConfigWrapper.jsonString;	
        }
        
       if(isError) {
       		parameter = 'ERROR';
       } else {
	       parameter=parameter.removeEnd(',');
	       parameter+='}';   
       }
       system.debug('parameter :: '+parameter);
       wrapper.jsonData =  parameter; 
       return wrapper;
    }
    
    public static List<REN_RS_Config__c> getRSConfiguration(List<String> flowList, List<String> invokingObjectList){
		String whereCondition = 'WHERE REN_Flow_Name__c=\''+String.escapeSingleQuotes(flowList[0])+'\' AND REN_Invoking_Object__c=\''+String.escapeSingleQuotes(invokingObjectList[0])+'\'';
        List<String> configFields = new List<String>{'REN_Named_Credential__c','REN_Named_Credential_URL_Extension__c','REN_Field_Set_Name__c','REN_Flow_Name__c','REN_Columns__c','REN_Custom_Object__c','REN_Custom_Permission_Name__c','REN_Display_Dialog__c','REN_SOQL__c','REN_Number_Of_Columns__c','REN_Invoking_Object__c','REN_Response_Object__c','REN_Display_Response_Dialog__c','REN_Response_Object_Field_Set_Name__c','REN_Button_Text_for_Submit__c','REN_Button_Text_for_Cancel__c'};
        List<REN_RS_Config__c> configSettingList = REN_RSConfigurationDataAccess.getRSConfigration(configFields,new List<String>{whereCondition});
		return configSettingList;
	}
	
    /*public static void updateQuote(Set<Id> quoteIdSet, List<String> statusList, Boolean requiresApproval){
        String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
        String quoteExtNameSpace = CHL_Util.quoteExtnNameSpace;
        List<ProcessInstanceStep> ProcessInstanceStep = REN_Util.getProcessInstanceSteps(quoteIdSet);
    	Map<Id,sObject> quoteToUpdate =CHL_QuoteDataAccess.getQuoteMapById(quoteIdSet, new Set<String>{'Status', solExtNameSpace+'Quote_Checkbox_8__c',quoteExtNameSpace+'REN_Discount_Approval_Comments__c'});
        for(sObject objQuote : quoteToUpdate.values()){
        	objQuote.put('Status',statusList[0]);
            if(!requiresApproval && ProcessInstanceStep != null){
            	objQuote.put(quoteExtNameSpace+'REN_Discount_Approval_Comments__c',ProcessInstanceStep[0].Comments);
            }else{
          		objQuote.put(solExtNameSpace+'Quote_Checkbox_8__c',requiresApproval);
            }
        }
        CHL_QuoteDataAccess.updateQuotes(quoteToUpdate.values());
    }*/
    
    public static String constructUniqueString(){
    	// Below code added to generate unique string for DE3391
		String CharList = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
		Integer position;				
		// length of random strings
		Integer LengthRequired = 8;
		String uniqueString = '';
		for(Integer i = 0; i < LengthRequired; i++) {				
		    position = Integer.valueof(String.valueof(Math.roundToLong(CharList.length()*Math.random()))) -1;				
		    // the random Strings
		    position = position < 0 ? 0 : position;
		    uniqueString += CharList.substring(position,position+1);
			
		}
		system.debug('STRING :: '+uniqueString);
		return uniqueString;
    }
}