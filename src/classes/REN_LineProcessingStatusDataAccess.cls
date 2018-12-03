/**
 * Created Date		: Sep 1, 2016
 * Developed By		: Chandra, Comity Designs, Inc.
 *
 * Function			: @description - Line Processing Status Data Access class
 * Support Email 	: chandra@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Chandra					User Story				Sep 1, 2016			1.1					@description
 * 
 */
public with sharing class REN_LineProcessingStatusDataAccess {

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
    public static void upsertLineProcessingStatusList(List<REN_Line_Processing_Status__c> lpsList, List<String> fieldSetforCrudFlsCkeck){
        CSM_Util.checkCRUD_FLS('REN_Line_Processing_Status__c', fieldSetforCrudFlsCkeck,CSM_Constants.DML_OPERATION_UPSERT);
        if(!lpsList.isEmpty()){
        	upsert lpsList;
        }
    }
	public static void updateLineProcessingStatusList(List<SObject> lpsList){
    	List<String> lpsfieldList = new List<String>{'REN_Source_OLI_Id__c',
			'REN_Source_Asset__c','REN_Product__c','REN_OLI_Qualified__c', 'REN_Asset_Qualified__c', 'REN_CLI_Qualified__c', 'REN_Asset_RLI_Qualified__c', 'REN_CLI_RLI_Qualified__c','REN_Failure__c','REN_Failure_Msg__c'};
        CSM_Util.checkCRUD_FLS('REN_Line_Processing_Status__c', lpsfieldList,CSM_Constants.DML_OPERATION_UPDATE);
        if(!lpsList.isEmpty()){
        	update lpsList;
        }
    }
    public static List<REN_Line_Processing_Status__c> getLineProcStatusListBySrcOLI(Set<Id> opliId){
    	List<REN_Line_Processing_Status__c> lrpList = new List<REN_Line_Processing_Status__c>();
    	List<String> lpsfieldList = new List<String>{'REN_Renewal_Processing_Status__c','REN_Source_OLI_Id__c',
			'REN_Source_Asset__c','REN_Product__c','REN_OLI_Qualified__c', 'REN_Asset_Qualified__c', 'REN_CLI_Qualified__c', 'REN_Asset_RLI_Qualified__c', 'REN_CLI_RLI_Qualified__c','REN_Failure__c','REN_Failure_Msg__c'};
        CSM_Util.checkCRUD_FLS('REN_Line_Processing_Status__c', lpsfieldList,CSM_Constants.DML_OPERATION_READ);
        lrpList = [select REN_Renewal_Processing_Status__c from REN_Line_Processing_Status__c where REN_Source_OLI_Id__c IN :opliId];
        return lrpList;
    }
}