/**
 * Created Date		: Nov 2, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Data access class for Batch filter activity page
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 *
 */
public with sharing class CSM_BatchFilterActivityDataAccess {

	private static List<String> fieldsList = new List<String> {
													CSM_Constants.OBJ_BF_NAME,
			    									CSM_Constants.OBJ_BF_IS_ACTIVE,
			    									CSM_Constants.OBJ_BF_BATCH_JOB_NAME,
			    									CSM_Constants.OBJ_BF_CURRENCY_CODE,	
			    									CSM_Constants.OBJ_BF_DESCRIPTION,
			    									CSM_Constants.OBJ_BF_DISPLAY_NAME,
			    									CSM_Constants.OBJ_BF_END_BOUNDARY_CRITERIA,
			    									CSM_Constants.OBJ_BF_FILTER_LOGIC,	
			    									CSM_Constants.OBJ_BF_OBJECT_NAME,
			    									CSM_Constants.OBJ_BF_QUERY_CRITERIA
			    								};
	
	/*
	** @Description: Gets all batch filter records
	*/
    public static List<CSM_Batch_Filter__c> getAllRecords() {
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_BF, fieldsList, CSM_Constants.DML_OPERATION_READ);
         
        String query =	'SELECT ' +
		        			CSM_Constants.OBJ_BF_IS_ACTIVE + ', ' +
		    				CSM_Constants.OBJ_BF_BATCH_JOB_NAME + ', ' +
		    				CSM_Constants.OBJ_BF_DESCRIPTION + ', ' +
		    				CSM_Constants.OBJ_BF_OBJECT_NAME + ', ' +
		    				CSM_Constants.OBJ_BF_DISPLAY_NAME + ', ' +
		    				CSM_Constants.OBJ_BF_CREATED_BY_NAME + ', ' +
		    				'FORMAT(' + CSM_Constants.OBJ_BF_CREATED_DATE + '), ' +
		    				CSM_Constants.OBJ_BF_LAST_MODIFIED_BY_NAME + ', ' +
		    				'FORMAT(' + CSM_Constants.OBJ_BF_LAST_MODIFIED_DATE + ') ' +
						'FROM ' +
							CSM_Constants.OBJ_BF + ' ' +
						'ORDER BY ' +
							CSM_Constants.OBJ_BF_DISPLAY_NAME;
		
		List<CSM_Batch_Filter__c> batchFilters = database.query(query);
		System.debug('### getAllRecords - Total size: ' + batchFilters.size());
		return batchFilters;
    }
    
    /*
	** @Description: Deletes batch filter records
	** @param ids: Ids of the batch filter records to be deleted
	*/
    public static void deleteRecords(Set<String> ids) {
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_BF, fieldsList, CSM_Constants.DML_OPERATION_DELETE);
    	
    	System.debug('### deleteRecords - Ids: ' + ids);
    	
    	delete 	[SELECT
    				Id
				FROM
					CSM_Batch_Filter__c
				WHERE
					Id IN :ids];
    }
    
    /*
	** @Description: Clones batch filter records
	** @param ids: Ids of the batch filter records to be cloned
	*/
    public static void cloneRecords(Set<String> ids) {
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_BF, fieldsList, CSM_Constants.DML_OPERATION_INSERT);
    	
    	System.debug('### cloneRecords - Ids: ' + ids);
    	
		List<CSM_Batch_Filter__c> batchFilters = 	[SELECT
				    									Name,
				    									CSM_Batch_Job_Name__c,
				    									RLM_Currency_Code__c,
				    									CSM_Description__c,
				    									CSM_Display_Name__c,
				    									CSM_End_Boundary_Criteria__c,
				    									RLM_Filter_Logic__c,
				    									CSM_Object_Name__c,
				    									CSM_Query_Criteria__c
				    								FROM
				    									CSM_Batch_Filter__c
				    								WHERE
				    									Id IN :ids];

		for(CSM_Batch_Filter__c batchFilter : batchFilters) {
	    	List<CSM_Batch_Filter_Criteria__c> batchFilterCriterias = 	[SELECT
								    										Name,
								    										RLM_Criteria__c,
								    										RLM_Date_Literal_Number__c,
								    										RLM_Date_Literal_String__c,
								    										RLM_Date_String__c,
								    										RLM_DateTime_Value__c,
								    										RLM_Date_Value__c,
								    										RLM_Field_Display_Name__c,
								    										RLM_Field_Name__c,
								    										RLM_Field_Type__c,
								    										RLM_LineNo__c,
								    										RLM_Operator__c,
								    										RLM_Is_Specific_Date__c,
								    										RLM_Value__c
								    									FROM
								    										CSM_Batch_Filter_Criteria__c
								    									WHERE
								    										CSM_Batch_Filter__c = :batchFilter.Id];
	
	    	CSM_Batch_Filter__c clonedBatchFilter = batchFilter.clone(false, true);
	    	clonedBatchFilter.CSM_Display_Name__c = Label.CSM_LBL_CLONE_PREFIX + ' ' + clonedBatchFilter.CSM_Display_Name__c;
	    	clonedBatchFilter.CSM_IsActive__c = false;
	    	insert clonedBatchFilter;
	    	
	    	System.debug('### cloneRecords - cloned batch filter Id: ' + clonedBatchFilter.Id);
	    	
	    	if(batchFilterCriterias.size() > 0) {
		    	List<CSM_Batch_Filter_Criteria__c> clonedBatchFilterCriterias = new List<CSM_Batch_Filter_Criteria__c>();
		    	
		    	for(CSM_Batch_Filter_Criteria__c eachBatchFilterCriteria : batchFilterCriterias) {
		    		CSM_Batch_Filter_Criteria__c clonedBatchFilterCriteria = eachBatchFilterCriteria.clone(false, true);
		    		clonedBatchFilterCriteria.CSM_Batch_Filter__c = clonedBatchFilter.Id;
		    		
		    		clonedBatchFilterCriterias.add(clonedBatchFilterCriteria);
		    	}
		    	
		    	insert clonedBatchFilterCriterias;
		    	
		    	System.debug('### cloneRecords - cloned batch filter criteria size: ' + clonedBatchFilterCriterias.size());
	    	}
		}
    }
    
    /*
	** @Description: Activates batch filter records
	** @param ids: Ids of the batch filter records to be activated
	*/
    public static void activateRecords(Set<String> ids) {
    	setRecordsActive(ids, true);
    }
    
    /*
	** @Description: Deactivates batch filter records
	** @param ids: Ids of the batch filter records to be deactivated
	*/
    public static void deactivateRecords(Set<String> ids) {
    	setRecordsActive(ids, false);
    }
    
    /*
	** @Description: Helper method to activate or deactivate batch filter records
	** @param ids: Ids of the batch filter records to be activated or deactivated
	** @param status: true - activate the batch filter records, false - deactivate the batch filter records
	*/
    private static void setRecordsActive(Set<String> ids, Boolean status) {
    	CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_BF, fieldsList, CSM_Constants.DML_OPERATION_UPDATE);   	
    	
    	System.debug('### setRecordsActive - ids: ' + ids);
    	System.debug('### setRecordsActive - status: ' + status);
    	
    	List<CSM_Batch_Filter__c> batchFilters = 	[SELECT
		    											CSM_Batch_Job_Name__c,
		    											CSM_IsActive__c
													FROM
														CSM_Batch_Filter__c
													WHERE
														Id IN :ids];
							
		/*for(CSM_Batch_Filter__c batchFilter : batchFilters) {
	    	batchFilter.CSM_IsActive__c = status;
    	}
    		
	    update batchFilters;*/
    	
    	if(status) {
    		for(CSM_Batch_Filter__c batchFilter : batchFilters) {
	    		List<CSM_Batch_Filter__c> deactivateBatchFilters = 	[SELECT
																		CSM_IsActive__c
																	FROM
																		CSM_Batch_Filter__c
																	WHERE
																		CSM_Batch_Job_Name__c = :batchFilter.CSM_Batch_Job_Name__c AND
																		CSM_IsActive__c = true AND
																		Id != :batchFilter.Id];
	    		
	    		for(CSM_Batch_Filter__c deactivateBatchFilter : deactivateBatchFilters) {
	    			deactivateBatchFilter.CSM_IsActive__c = false;
	    		}
	    		  		
	    		batchFilter.CSM_IsActive__c = true;
	    		deactivateBatchFilters.add(batchFilter);
	    		update deactivateBatchFilters;
    		}
    	} else {
    		for(CSM_Batch_Filter__c batchFilter : batchFilters) {
	    		batchFilter.CSM_IsActive__c = false;
    		}
    		
	    	update batchFilters;
    	}
    }
}