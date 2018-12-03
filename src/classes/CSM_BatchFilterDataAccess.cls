/**
 * Created Date		: Nov 5, 2016
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: Used for performing various DML operation and validates the user permission on Batch Filter(CSM_Batch_Filter__c) object.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					US1481				Nov 5, 2016			1.1					@description
 * Aditya					US1780				Dec 2, 2016			1.1					Moved batch filter activity data access methods to here
 *
 */

public with sharing class CSM_BatchFilterDataAccess {
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
	//private static List<String> fieldCriteriaList = new List<String> {};
	
	/**
    * @description : This method returns the detail of batch filter object as per the ID passed as parameter.
    * @param Set of batch filter Id.
   */
	public static List<CSM_Batch_Filter__c> getBatchFilterById(Set<String> batchFilterIdSet) {
        List<String> batchFilterFieldList = new List<String>{'CSM_Batch_Job_Name__c', 'CSM_Description__c','CSM_Display_Name__c','CSM_IsActive__c','CSM_Object_Name__c','RLM_Currency_Code__c','RLM_Filter_Logic__c','CSM_End_Boundary_Criteria__c'};
        CSM_Util.checkCRUD_FLS('CSM_Batch_Filter__c', batchFilterFieldList, CSM_Constants.DML_OPERATION_READ);
        return [select CSM_Batch_Job_Name__c,CSM_Description__c,CSM_Display_Name__c,CSM_IsActive__c,CSM_Object_Name__c, RLM_Filter_Logic__c, CreatedBy.Name, FORMAT(CreatedDate), LastModifiedBy.Name, FORMAT(LastModifiedDate) ,RLM_Currency_Code__c,CSM_End_Boundary_Criteria__c  from CSM_Batch_Filter__c where id IN:batchFilterIdSet LIMIT 10000];
    }
    
    /**
    * @description : This method returns the all the Active batch filter records as per the ApexJob(Dispatcher Class) name passed as parameter.
    * @param Set of ApexJob Name (DispatcherClass name).
   */
    public static List<CSM_Batch_Filter__c> getBatchFilterByJobName(Set<String> jobNameSet) {
        
        List<String> batchFilterFieldList = new List<String>{'CSM_Batch_Job_Name__c', 'CSM_Description__c','CSM_Display_Name__c','CSM_IsActive__c','CSM_Object_Name__c','CSM_Query_Criteria__c'};
        CSM_Util.checkCRUD_FLS('CSM_Batch_Filter__c', batchFilterFieldList, CSM_Constants.DML_OPERATION_READ);
        return [select CSM_Batch_Job_Name__c,CSM_IsActive__c,CSM_Object_Name__c,CSM_Query_Criteria__c  from CSM_Batch_Filter__c where CSM_Batch_Job_Name__c IN:jobNameSet and CSM_IsActive__c = true LIMIT 10000];
    }

    public static List<CSM_Batch_Filter__c> getAllBatchFilterByJobName(Set<String> jobNameSet, Set<String> ignoreIds) {
        
        List<String> batchFilterFieldList = new List<String>{'CSM_Batch_Job_Name__c', 'Id'};
        CSM_Util.checkCRUD_FLS('CSM_Batch_Filter__c', batchFilterFieldList, CSM_Constants.DML_OPERATION_READ);
        if(!ignoreIds.isEmpty()){
	        return [select Id, CSM_Batch_Job_Name__c  from CSM_Batch_Filter__c where CSM_Batch_Job_Name__c IN:jobNameSet  and CSM_IsActive__c = true and Id not in: ignoreIds LIMIT 10000];        
        }else{
	        return [select Id, CSM_Batch_Job_Name__c  from CSM_Batch_Filter__c where CSM_Batch_Job_Name__c IN:jobNameSet  and CSM_IsActive__c = true LIMIT 10000];        
        }

    }

    
    /**
    * @description : This method create/update records for batch filter object.
    * @param List of batch filter object.
   */
    public static void saveBatchFilter(List<CSM_Batch_Filter__c> batchFilterList){
		List<String> batchFilterFieldList = new List<String>{'CSM_Batch_Job_Name__c', 'CSM_Description__c',
			'CSM_Display_Name__c','CSM_IsActive__c','CSM_Object_Name__c', 'CSM_End_Boundary_Criteria__c', 
			'CSM_Query_Criteria__c'};
        CSM_Util.checkCRUD_FLS('CSM_Batch_Filter__c', batchFilterFieldList, CSM_Constants.DML_OPERATION_UPSERT);
		upsert batchFilterList;
	}
    
    /**
    * @description : This method create records for batch filter object.
    * @param List of batch filter object.
   */
    /*public static void insertBatchFilter(List<CSM_Batch_Filter__c> batchFilterList) {
        List<String> batchFilterFieldList = new List<String>{'CSM_Batch_Job_Name__c', 'CSM_Description__c','CSM_Display_Name__c','CSM_IsActive__c','CSM_Object_Name__c'};
        CSM_Util.checkCRUD_FLS('CSM_Batch_Filter__c', batchFilterFieldList, CSM_Constants.DML_OPERATION_INSERT);
		insert batchFilterList;
    }*/
    
     /**
    * @description : This method update records for batch filter object.
    * @param List of batch filter object.
   */
    public static void updateBatchFilter(List<CSM_Batch_Filter__c> batchFilterList) {
        List<String> batchFilterFieldList = new List<String>{'CSM_Batch_Job_Name__c', 'CSM_Description__c','CSM_Display_Name__c','CSM_IsActive__c','CSM_Object_Name__c'};
        CSM_Util.checkCRUD_FLS('CSM_Batch_Filter__c', batchFilterFieldList, CSM_Constants.DML_OPERATION_UPDATE);
		update batchFilterList;
    }
    
    /*
	** @Description: Gets all batch filter records
	*/
    public static List<CSM_Batch_Filter__c> getAllBatchFilters() {
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
    public static void deleteBatchFilters(Set<String> ids) {
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
    public static void cloneBatchFilters(Set<String> ids) {
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
								    										RLM_Values__c
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
		    	
		    	//CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_BATCH_FILTER_CRITERIA, fieldCriteriaList, CSM_Constants.DML_OPERATION_INSERT);
		    	insert clonedBatchFilterCriterias;
		    	
		    	System.debug('### cloneRecords - cloned batch filter criteria size: ' + clonedBatchFilterCriterias.size());
	    	}
		}
    }
    
    /*
	** @Description: Activates batch filter records
	** @param ids: Ids of the batch filter records to be activated
	*/
    public static void activateBatchFilters(Set<String> ids) {
    	setRecordsActive(ids, true);
    }
    
    /*
	** @Description: Deactivates batch filter records
	** @param ids: Ids of the batch filter records to be deactivated
	*/
    public static void deactivateBatchFilters(Set<String> ids) {
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
							
		for(CSM_Batch_Filter__c batchFilter : batchFilters) {
	    	batchFilter.CSM_IsActive__c = status;
    	}
    		
	    update batchFilters;
    }
}