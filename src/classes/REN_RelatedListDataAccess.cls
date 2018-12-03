public with sharing class REN_RelatedListDataAccess {

	public static List<REN_Related_List__c> getRelatedListRecordsByConfig(String mappingName){
		List<REN_Related_List__c> relatedListRecords = new List<REN_Related_List__c>();
		List<String> relatedListFieldList = new List<String>{REN_Constants.OBJ_RL_OBJ_API_NAME, 
													REN_Constants.OBJ_RL_RELATED_LIST_TYPE};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RL, relatedListFieldList, CSM_Constants.DML_OPERATION_READ);
    	relatedListRecords = [Select Id, Name, REN_Object_API_Name__c, REN_Related_List_Type__c 
    						From REN_Related_List__c limit 100];
        						//From REN_Related_List__c Where Name =:mappingName];
	
		return relatedListRecords;
	}
	
	public static List<REN_Related_List__c> upsertRelatedListRecords(List<REN_Related_List__c> relatedListRecords){
		List<String> relatedListFieldList = new List<String>{REN_Constants.OBJ_RL_OBJ_API_NAME, 
													REN_Constants.OBJ_RL_RELATED_LIST_TYPE};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RL, relatedListFieldList, CSM_Constants.DML_OPERATION_UPSERT);
        upsert relatedListRecords;
		return relatedListRecords;
	}
	
	 public static void deleteRelatedListRecords(List<REN_Related_List__c> relatedListRecords)
     {
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_RL,null, CSM_Constants.DML_OPERATION_DELETE);
        delete relatedListRecords; 
     } 
}