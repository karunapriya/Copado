/**
 * Created Date		: Jan 9, 2017
 * Developed By		: prashant, Class used to write method which execute according to Event.
 *
 * Function			: @description - Description about the functionality that the class provides.
 * Support Email 	: prashant@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * prashant					US1961				Jan 9, 2017			1.1					@description
 * 
 */
public with sharing class REN_DocuSignStatusTriggerHandler extends CSM_TriggerManager.TriggerHandler{
    /**
	 * @description : Method used to call helper method "updateOpportunityAndCreateCaseWhenDocuSignStatusCompleted".
     * @param :oldRecords,newRecords,oldRecordsMap,newRecordsMap
     * @return :null
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, 
	 									Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
 	{
 		/*try
 		{
 			if(CSM_AccessController.hasObject(REN_Constants.OBJ_DSFS_DOCUSIGN_STATUS)) {
		 		REN_DocuSignStatusTriggerHelper.updateOpportunityAndCreateCase(newRecordsMap, oldRecordsMap);
 			}
 		}
 		catch(exception ex)	{
		 	REN_Util.setErrorInObjects (newRecords, ex);
	 	}*/
 	}
 	
 	public override void onAfterInsert( List<sObject> newRecords, Map<ID, sObject> newRecordsMap)
 	{
 		try
 		{
 			if(CSM_AccessController.hasObject(REN_Constants.OBJ_DSFS_DOCUSIGN_STATUS)) {
		 		REN_DocuSignStatusTriggerHelper.updateOpportunityAndCreateCase(newRecordsMap, null);
 			}
 		}
 		catch(exception ex)	{
		 	REN_Util.setErrorInObjects (newRecords, ex);
	 	}
 	}
}