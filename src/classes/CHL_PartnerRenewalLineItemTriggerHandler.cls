/**
 * Created Date		: Dec 1, 2016
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
 * Tanvi					User Story				Dec 1, 2016			1.1					@description
 *
 */
public with sharing class CHL_PartnerRenewalLineItemTriggerHandler extends CSM_TriggerManager.TriggerHandler {

    

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	// MARK: Your method goes here
	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
	 	
 		try{
 			Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;	
		 	if(hasChannelAccess == true ){
		 //		REN_RenewalRelationshipRollupHandler.recalculateMetricsOnPO(newRecords);//handleRRrolluponPO(newRecords);
		 	}
 		}
 		catch(exception ex){
	 		REN_Util.setErrorInObjects (newRecords, ex);
	 	}
 	}
 	
 	public override void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {
	 	
 		try{
 			Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;	
		 	if(hasChannelAccess == true ){
		 //		REN_RenewalRelationshipRollupHandler.recalculateMetricsOnPO(oldRecords);
		 	}
 		}
 		catch(exception ex){
	 		REN_Util.setErrorInObjects (oldRecords, ex);
	 	}
 	}
}