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
 * Nidhi					DE2063				Jan 30, 2017			1.1			   Attachment Helper
 *
 */
public with sharing class REN_AttachmentTriggerHelper {

	public static void createAttachmentOnOpp(List<sObject> newRecords) {
		Set<Id> docSignStatusId = new Set<Id>();
		Map<Id, Attachment> mapOfStatusToAtch = new Map<Id, Attachment>();
		List<Attachment> attachmentList = newRecords;
		for(Attachment atch : attachmentList){
			Id parentId = atch.parentId;
			System.debug(parentId.getSObjectType().getDescribe().getName());
			if(parentId.getSObjectType().getDescribe().getName().equals('dsfs__DocuSign_Status__c')){
				docSignStatusId.add(atch.parentId);
				mapOfStatusToAtch.put(atch.parentId, atch);
			}
		}
		if(docSignStatusId.size()>0){
			Map<Id,sObject> mapOfStatus = new Map<Id,sObject>();
			String queryString = 'Select id,dsfs__Opportunity__c from dsfs__DocuSign_Status__c where Id IN: docSignStatusId';
			if(CSM_AccessController.hasObject('dsfs__DocuSign_Status__c')){
				List<sObject> docuSignList = Database.query(queryString); 
				if(docuSignList != null ){
					for(sObject sObj : docuSignList){
						mapOfStatus.put(String.valueOf(sObj.get('Id')),sObj );
					}
				}
			} 
			
        // No need to add ParentId FLS Check, it is not supprted.
       	// List<String> fieldList = new List<String>{'parentId'};
    	//CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ATTACHMENT, fieldList, CSM_Constants.DML_OPERATION_INSERT);
           
			List<Attachment> lstOfAtchToClone = new List<Attachment>();
			for(Id stId :mapOfStatus.keySet()){
				Attachment cloneAtch = mapOfStatusToAtch.get(stId).clone();
				sObject Obj2 = mapOfStatus.get(stId);
				cloneAtch.parentId = String.valueOf(Obj2.get('dsfs__Opportunity__c'));
				lstOfAtchToClone.add(cloneAtch);
			}
			insert lstOfAtchToClone;
		}
	}

}