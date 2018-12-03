/**
 * Created Date		: Dec 3, 2016
 * Developed By		: Nkonkar, Comity Designs, Inc.
 *
 * Function			: @description - Data access class for REN_Consolidation_Request__c object
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nkonkar					User Story				Dec 3, 2016			1.1					@description
 *
 */
public with sharing class REN_ConsolidationRequestDataAccess {

    public static List<REN_Consolidation_Request__c> getConsolidationRequestList(){
    	List<String> fieldList = new List<String>{
    		'REN_Target_Opportunity__c', 'REN_Target_Opportunity__c', 'REN_Number_of_OLIs__c', 'REN_Number_of_RLIs__c', 'REN_No_of_Source_Opportunities__c', 
    		'REN_Consolidation_Request_Id__c', 'REN_Processing_Completed__c', 'REN_Processed_On__c','CreatedDate', 'CreatedById', 'REN_No_of_Errors__c'
    	};
    	CSM_Util.checkCRUD_FLS('REN_Consolidation_Request__c', fieldList, CSM_Constants.DML_OPERATION_READ);  
    	return Database.query('Select id, REN_Target_Opportunity__c, REN_Target_Opportunity__r.Name, REN_Number_of_OLIs__c, REN_Number_of_RLIs__c, REN_No_of_Source_Opportunities__c, ' 
    		+ ' REN_Consolidation_Request_Id__c, REN_Processing_Completed__c, Format(REN_Processed_On__c),LastModifiedById, Format(CreatedDate), CreatedById, CreatedBy.Name, ' 
    		+ ' REN_No_of_Errors__c from REN_Consolidation_Request__c Order by CreatedDate DESC LIMIT 10000');
    }
    
    public static void insertConsolidationRequest(List<REN_Consolidation_Request__c> consolidationRequests, List<String> fieldList)
    {
    	CSM_Util.checkCRUD_FLS('REN_Consolidation_Request__c', fieldList, CSM_Constants.DML_OPERATION_INSERT);  
        insert consolidationRequests;
    }
    
    public static void insertConsolidationRequestSource(List<REN_Consolidation_Request_Source__c> consolidationRequestSources, List<String> fieldList)
    {
    	CSM_Util.checkCRUD_FLS('REN_Consolidation_Request_Source__c', fieldList, CSM_Constants.DML_OPERATION_INSERT);  
        insert consolidationRequestSources;
    }
    
   
    
}