/**
 * Created Date		: Apr 6, 2017
 * Developed By		: admin, Comity Designs, Inc.
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
 * admin					User Story				Apr 6, 2017			1.1					@description
 *
 */
public with sharing class REN_LT_ErrorLogDataAccess {
    public static void insertErrorLog(List<REN_Error_Log__c> errorLogList){
        List<String> errorLogFieldList = new List<String>{'REN_Error_Description__c', 'REN_Flow__c', 'REN_OpportunityId__c'};
            CSM_Util.checkCRUD_FLS('REN_Error_Log__c', errorLogFieldList,CSM_Constants.DML_OPERATION_INSERT);
            if(!errorLogList.isEmpty()){
                insert errorLogList;
            }
    }
}