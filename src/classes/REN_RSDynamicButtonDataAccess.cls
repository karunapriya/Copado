/**
 * Created Date		: Jun 15, 2018
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
 * Tanvi					User Story				Jun 15, 2018			1.1					@description
 *
 */
public with sharing class REN_RSDynamicButtonDataAccess {

    

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	// MARK: Your method goes here
	
	public static List<REN_RS_Dynamic_Button__c> getRSButtons(Set<String> invokingObjectSet, List<String> requestedFieldsList){
		
		CSM_Util.checkCRUD_FLS('REN_RS_Dynamic_Button__c', requestedFieldsList, CSM_Constants.DML_OPERATION_READ);
		return [SELECT REN_RS_Button_Label__c, REN_RS_Action__c, REN_RS_Button_Criteria__c, REN_RS_Configuration__r.REN_Custom_Permission_Name__c FROM REN_RS_Dynamic_Button__c WHERE REN_RS_Configuration__r.REN_Invoking_Object__c IN :invokingObjectSet limit 100];
	}
}