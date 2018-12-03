/**
 * Created Date		: Nov 5, 2016
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: Used for performing various DML operation and validates the user permission on Batch Filter Criteria(CSM_Batch_Filter_Criteria__c) object.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					US1481				Nov 5, 2016			1.1					@description
 *
 */


public with sharing class CSM_BatchFilterCriteriaDataAccess {
	
   /**
    * @description : This method returns the detail of batch filter criteria object as per the ID passed as parameter.
    * @param Set of batch filter Id.
   */
   public static List<CSM_Batch_Filter_Criteria__c> populateBatchFilterCriteriaInformation(String batchFilterId){
		List<String> criteriaFieldList = new List<String>{'RLM_Date_Value__c','RLM_Values__c','RLM_Field_Name__c','RLM_Is_Specific_Date__c','RLM_Date_Literal_String__c','RLM_Field_Type__c',
															'RLM_LineNo__c','CSM_Batch_Filter__c','RLM_Operator__c','RLM_Field_Display_Name__c','RLM_Date_Literal_Number__c'};
        CSM_Util.checkCRUD_FLS('CSM_Batch_Filter_Criteria__c', criteriaFieldList, CSM_Constants.DML_OPERATION_READ);       
        return [SELECT id, RLM_Date_Value__c, RLM_Values__c, RLM_Field_Name__c, RLM_Is_Specific_Date__c, RLM_Date_Literal_String__c,
        					RLM_Field_Type__c, RLM_LineNo__c, CSM_Batch_Filter__r.Id, CSM_Batch_Filter__c,	RLM_Operator__c, RLM_Field_Display_Name__c, RLM_Date_Literal_Number__c,
        					RLM_DateTime_Value__c
							from CSM_Batch_Filter_Criteria__c
							where CSM_Batch_Filter__c = :batchFilterId
							order by RLM_LineNo__c
							limit 100];
      
	}
	
	/**
    * @description : This method is used to create/update records for batch filter criteria object.
    * @param List of batch filter criteria object.
    */
	public static void saveBatchFilterCriteria(List<CSM_Batch_Filter_Criteria__c> batchFilterCriteriaList){
		List<String> criteriaFieldList = new List<String>{'RLM_Date_Value__c','RLM_Values__c','RLM_Field_Name__c','RLM_Is_Specific_Date__c','RLM_Date_Literal_String__c','RLM_Field_Type__c',
															'RLM_LineNo__c','CSM_Batch_Filter__c','RLM_Operator__c','RLM_Field_Display_Name__c','RLM_Date_Literal_Number__c'};
        CSM_Util.checkCRUD_FLS('CSM_Batch_Filter_Criteria__c', criteriaFieldList, CSM_Constants.DML_OPERATION_UPSERT);       
        upsert batchFilterCriteriaList;
	}
	
	/**
    * @description : This method is used to delete records for batch filter criteria object.
    * @param List of batch filter criteria object.
    */
	public static boolean deleteBatchFilterCriteria(List<CSM_Batch_Filter_Criteria__c> batchFilterCriteriaList){
        boolean isSuccess = false;
        List<String> criteriaFieldList = new List<String>{'RLM_Date_Value__c','RLM_Values__c','RLM_Field_Name__c','RLM_Is_Specific_Date__c','RLM_Date_Literal_String__c','RLM_Field_Type__c',
															'RLM_LineNo__c','CSM_Batch_Filter__c','RLM_Operator__c','RLM_Field_Display_Name__c','RLM_Date_Literal_Number__c'};
        CSM_Util.checkCRUD_FLS('CSM_Batch_Filter_Criteria__c', criteriaFieldList,  CSM_Constants.DML_OPERATION_Delete);

    	delete batchFilterCriteriaList;
    	isSuccess = true;
        return 	isSuccess;
	}		
    
}