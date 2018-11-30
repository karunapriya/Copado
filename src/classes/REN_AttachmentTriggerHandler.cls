/**
 * Created Date		: Jan 30, 2017
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: This class will act as a helper class for AttachmentTrigger.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					DE2063				Jan 30, 2017			1.1			   Attachment Handler
 *
 */
public with sharing class REN_AttachmentTriggerHandler extends CSM_TriggerManager.TriggerHandler{
	
	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)	{
 		try	{
 			REN_AttachmentTriggerHelper.createAttachmentOnOpp(newRecords);
 		}
 		catch(exception ex){
	 		REN_Util.setErrorInObjects (newRecords, ex); 
	 	}
 	}
    
}