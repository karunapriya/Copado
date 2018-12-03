/**
 * Created Date		: Jun 26, 2018
 * Developed By		: Tanvi, Comity Designs, Inc.
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
 * Tanvi					User Story				Jun 26, 2018			1.1					@description
 *
 */
public with sharing class REN_RSTestDataUtility {

    

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	// MARK: Your method goes here
	public static REN_RS_Config__c createRSConfig(RSConfigWrapper rsConfig) {
    	//List<REN_RS_Config__c> rsConfigList = new List<REN_RS_Config__c>();
    	//for(integer i=0;i<noOfRecords; i++){
    		REN_RS_Config__c rsConfigObj = new REN_RS_Config__c();
    		//rsConfigObj.REN_Columns__c = columnsName;
		    rsConfigObj.REN_Custom_Object__c = rsConfig.customObj;
		    rsConfigObj.REN_Display_Dialog__c = rsConfig.displayDialog;
		    rsConfigObj.REN_Display_Response_Dialog__c  = rsConfig.displayResposeDialog;
		    rsConfigObj.REN_Flow_Name__c = rsConfig.flowName;
		    rsConfigObj.REN_Invoking_Object__c = rsConfig.invokingObj;
		    rsConfigObj.REN_Named_Credential__c = rsConfig.namedCredential;
		    rsConfigObj.REN_Named_Credential_URL_Extension__c = rsConfig.namedCredentialUrlExt;
		    rsConfigObj.REN_Number_Of_Columns__c = rsConfig.noOfCol;
		    rsConfigObj.REN_Response_Object__c = rsConfig.responseObj;
		    rsConfigObj.REN_SOQL__c = rsConfig.soql;
		    rsConfigObj.REN_RS_Record_Limit__c = rsConfig.recordLimit;
		    //rsConfigList.add(rsConfigObj);
    	//}
    	return rsConfigObj;
	}
    public static REN_RS_Field_Mapping__c createFieldMapping(RSFieldMappingWrapper rsFieldsMapping){
    	REN_RS_Field_Mapping__c rsMappingObj = new REN_RS_Field_Mapping__c();
        rsMappingObj.REN_RS_Config__c = rsFieldsMapping.configId;
        rsMappingObj.REN_Custom_Mapped_Field__c = rsFieldsMapping.customMappedField;
        rsMappingObj.REN_Editable__c = rsFieldsMapping.isEditable;
        rsMappingObj.REN_oData_Param__c = rsFieldsMapping.oDataParam;
        rsMappingObj.REN_Param_Type__c = rsFieldsMapping.paramType;
        rsMappingObj.REN_Object_Field_Name__c = rsFieldsMapping.objectFieldName;
        rsMappingObj.REN_RS_Matching_Field__c = rsFieldsMapping.matchingField;
        return rsMappingObj;
    }
	
	public static REN_RS_Dynamic_Button__c  createRSDynamicButton(String actionName, String buttonCriteria, String buttonLabel, Id rsConfigId) {
		REN_RS_Dynamic_Button__c dynamicButtonObj = new REN_RS_Dynamic_Button__c();
		dynamicButtonObj.REN_RS_Action__c = actionName;
	    dynamicButtonObj.REN_RS_Button_Criteria__c =  buttonCriteria;
	    dynamicButtonObj.REN_RS_Button_Label__c = buttonLabel;
	    dynamicButtonObj.REN_RS_Configuration__c = rsConfigId;
	    return dynamicButtonObj;
	}
	
	
	public class RSConfigWrapper	{
         public String customObj;
         public Boolean displayDialog;
         public Boolean displayResposeDialog;
         public String flowName;
         public String invokingObj;
         public String namedCredential;
         public String namedCredentialUrlExt;
         public String noOfCol;
         public String responseObj;
         public String soql;
         public Integer recordLimit;
         
    }
    public class RSFieldMappingWrapper{
        public Id configId;
        public String customMappedField;
        public boolean isEditable;
        public String oDataParam;
        public String paramType;
        public String objectFieldName;
        public boolean matchingField;
    }
}