/**
 * Created Date		: Nov 30, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Data access for Segment object
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1861					Nov 30, 2016	1.0					Initial development
 *
 */
public with sharing class REN_SegmentDataAccess {
	
	private static List<String> readFieldsList = new List<String> {
													REN_Constants.OBJ_SE_NAME,
													REN_Constants.OBJ_SE_DESCRIPTION,
													REN_Constants.OBJ_SE_TYPE,
													REN_Constants.OBJ_SE_VALUE,
													REN_Constants.OBJ_SE_LAST_FILTER,
													REN_Constants.OBJ_SE_QR_CREATED,
													REN_Constants.OBJ_SE_QR_SUBMITTED
													, 'REN_Task_Batch_Status__c'
													, 'REN_Start_Date__c'
													, 'REN_End_Date__c'
													, 'REN_Status__c'
													, 'REN_Duration__c'
			    								};
	
	private static List<String> writeFieldsList = new List<String> {
													REN_Constants.OBJ_SE_NAME,
													REN_Constants.OBJ_SE_DESCRIPTION,
													REN_Constants.OBJ_SE_TYPE,
													REN_Constants.OBJ_SE_VALUE,
													REN_Constants.OBJ_SE_QR_CREATED,
													REN_Constants.OBJ_SE_QR_SUBMITTED
													, 'REN_Task_Batch_Status__c'
			    								};
    
	/*
	** @Description: Gets all segment records
	*/
    public static List<REN_Segment__c> getAllSegments() {
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_SEGMENT, readFieldsList, CSM_Constants.DML_OPERATION_READ);
         
        String query =	'SELECT ' +
        					'REN_Task_Batch_Status__c, ' +
		        			REN_Constants.OBJ_SE_NAME + ', ' +
		    				REN_Constants.OBJ_SE_DESCRIPTION + ', ' +
		    				REN_Constants.OBJ_SE_TYPE + ', ' +
		    				REN_Constants.OBJ_SE_QR_CREATED + ', ' +		    				
		    				REN_Constants.OBJ_SE_QR_SUBMITTED + ', ' +		    				
		    				'FORMAT(' + REN_Constants.OBJ_SE_VALUE + '), ' +
		    				REN_Constants.OBJ_SE_NUMBER_OF_SEGMENT_MEMBERS + ', ' +
		    				REN_Constants.OBJ_SE_LAST_MODIFIED_BY_NAME + ', ' +
		    				'FORMAT(' + CSM_Constants.OBJ_BF_LAST_MODIFIED_DATE + ') ' +
						'FROM ' +
							REN_Constants.OBJ_SEGMENT + ' ' +
						'ORDER BY ' +
							CSM_Constants.OBJ_BF_LAST_MODIFIED_DATE + ' DESC ' +
						'LIMIT ' +
							'2000';
		
		List<REN_Segment__c> segments = database.query(query);
		return segments;
    }

	/*
	** @Description: Gets Quote Request related flags for a given segment
	*/
    public static List<REN_Segment__c> getQuoteRequestDetails(string segmentId) {
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_SEGMENT, readFieldsList, CSM_Constants.DML_OPERATION_READ);
		List<Ren_segment__c> segmentLst = [select id, REN_QuoteRequest_Submitted__c,REN_QuoteRequest_Created__c from ren_segment__c where id =: segmentId];         

		return segmentLst;
    }
    
	public static List<REN_Segment__c> saveSegments(List<REN_Segment__c> segments) {
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_SEGMENT, writeFieldsList, CSM_Constants.DML_OPERATION_UPSERT);
		
		upsert segments;	
		return segments;
	}

	/*
	** @Description: Gets segments by Id
	*/
    public static List<REN_Segment__c> getSegmentsById(Set<String> segmentIds) {
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_SEGMENT, readFieldsList, CSM_Constants.DML_OPERATION_READ);
        
        return [SELECT
        			Name,
        			REN_Number_of_Segment_Members__c,
        			REN_Description__c,
        			REN_Type__c,
        			REN_Value__c,
        			CreatedBy.Name,
        			FORMAT(CreatedDate),
        			LastModifiedBy.Name,
        			REN_QuoteRequest_Created__c,
        			REN_QuoteRequest_Submitted__c,
        			FORMAT(LastModifiedDate),
        			REN_Last_Filter__c,
        			REN_Task_Batch_Status__c,
        			REN_Start_Date__c,
        			REN_End_Date__c,
        			REN_Status__c,
        			REN_Duration__c
        		FROM
        			REN_Segment__c
        		WHERE
        			Id IN :segmentIds];
    }

	/*
	** @Description: Deletes segment and segment member records
	** @Param ids: Ids of the segment records to be deleted
	*/
    public static void deleteSegments(Set<String> ids) {
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_SEGMENT, writeFieldsList, CSM_Constants.DML_OPERATION_DELETE);
    	    	
    	delete 	[SELECT
    				Id
				FROM
					REN_Segment__c
				WHERE
					Id IN :ids];
    }
    
}