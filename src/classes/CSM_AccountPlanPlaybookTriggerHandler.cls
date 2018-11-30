public with sharing class CSM_AccountPlanPlaybookTriggerHandler extends CSM_TriggerManager.TriggerHandler {

	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)
	{	
	 	try {
	 		List<CSM_Account_Plan_Playbook__c> splanPbookLst = (List<CSM_Account_Plan_Playbook__c>)newRecords;
	 		List<String> playbookToQueryLst = new List<String>();
	 		Map<Id,CSM_Playbook__c> playBookMap = new Map<Id,CSM_Playbook__c>();
	 		for(CSM_Account_Plan_Playbook__c splanPbook : splanPbookLst){
				if(splanPbook.CSM_Account_Plan__c == null){
	    			splanPbook.CSM_Account_Plan_Template_1__c = splanPbook.CSM_Account_Plan_Template__c;
				}
				playbookToQueryLst.add(splanPbook.CSM_Playbook__c);
			}
			if(playbookToQueryLst != null && !playbookToQueryLst.isEmpty()){
				playBookMap = new Map<Id,CSM_Playbook__c>(CSM_PlaybooksDataAccess.getPlaybookList(playbookToQueryLst));
			}
			String activeFlag = CSM_Util.getNameSpace() + CSM_Constants.OBJ_PLAYBOOK_ISACTIVE;
			for(sObject newRec: newRecords){
				if(playBookMap.containsKey((Id)newRec.get(CSM_Constants.OBJ_PLAYBOOK))) {
					CSM_Playbook__c playbook = playBookMap.get((Id)newRec.get(CSM_Constants.OBJ_PLAYBOOK)); 
					newRec.put(activeFlag, playbook.CSM_IsActive__c);
				}
			}
			CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;
	 	} catch(exception ex) {
	 		REN_Util.setErrorInObjects (newRecords, ex);
	 	}
	}
	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)
	 {
	 	CSM_AccountPlanPlaybookTriggerHelper.processSPlanPlayBook(newRecords);
	 }
	 
	 public override void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {
 		system.debug(Logginglevel.ERROR, '\n\n~~~~ onBeforeDelete:' + oldRecordsMap);
 		try{
 			List<CSM_Account_Plan_Playbook__c> splanPbookLst = (List<CSM_Account_Plan_Playbook__c>)oldRecords;
		 	List<String> deleteRecordIds = new List<String>();
		 	List<String> templateIdLst = new List<String>();
		 	List<String> playbookIdLst = new List<String>();
	 		for(CSM_Account_Plan_Playbook__c oldObj : splanPbookLst) {
		    	deleteRecordIds.add(oldObj.Id);
		    	if(oldObj.CSM_Account_Plan__c == null && oldObj.CSM_Account_Plan_Template__c != null 
		    		&& oldObj.CSM_Playbook__c != null){
		    		playbookIdLst.add(oldObj.CSM_Playbook__c);
		    		templateIdLst.add(oldObj.CSM_Account_Plan_Template__c);
		    	}
		    }
		    if(!playbookIdLst.isEmpty() && !templateIdLst.isEmpty()){
		    	List<CSM_Account_Plan_Playbook__c> spPBookLst = CSM_AccountPlanPlaybookDataAccess.getAcctPlanPlaybooksByTmpltIDandPlBookId(templateIdLst,playbookIdLst,splanPbookLst);
		    	if(spPBookLst != null && !spPBookLst.isEmpty()){
		    		CSM_AccountPlanPlaybookDataAccess.deleteAcctPlanPlaybook(spPBookLst);
		    	}
		    	//trigger will not be recursive as ACCOUNT_PLAN_PLAYBOOK_TRIGGER is set to false
		    }
		    /*List<CSM_Task_Processing__c> tskProLst = CSM_TaskProcessingDataAccess.getTskProcRecordsWithSPPlay(deleteRecordIds);
		    if(tskProLst != null && !tskProLst.isEmpty()){
		    	CSM_TaskProcessingDataAccess.deleteTaskProcRecords(tskProLst);
		    }*/
		 	
 		}catch(exception ex){
 			REN_Util.setErrorInObjects (oldRecords, ex);
	 	}
 	}
 	
 	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {
 		try{
 			Set<Id> sptIds = new Set<Id>();
 			List<CSM_Account_Plan_Playbook__c> newSpPbList = (List<CSM_Account_Plan_Playbook__c>)newRecords;
	 		for(CSM_Account_Plan_Playbook__c newObj : newSpPbList) {
	 			CSM_Account_Plan_Playbook__c oldSpPb = (CSM_Account_Plan_Playbook__c)oldRecordsMap.get(newObj.Id);
	 			if(newObj.CSM_IsActive__c != oldSpPb.CSM_IsActive__c){
			    	sptIds.add(newObj.CSM_Account_Plan_Template__c);
	 			}
		    }
		    if(!sptIds.isEmpty()){
		    	List<CSM_Account_Plan_Playbook__c> spPbToUpdateList = new List<CSM_Account_Plan_Playbook__c>();
			    List<CSM_Account_Plan_Playbook__c> successPlanPlaybookRecords = CSM_AccountPlanPlaybookDataAccess.getSuccessPlanPlaybookBySPTId(sptIds);		
			    if(!successPlanPlaybookRecords.isEmpty() && successPlanPlaybookRecords != null) {
			    	for(CSM_Account_Plan_Playbook__c newObj : newSpPbList) {
				    	for(CSM_Account_Plan_Playbook__c succPlanPlaybookRec : successPlanPlaybookRecords) {
				    		if(newObj.Id != succPlanPlaybookRec.Id 
				    			&& newObj.CSM_Account_Plan_Template__c == succPlanPlaybookRec.CSM_Account_Plan_Template__c 
				    			&& newObj.CSM_Playbook__c == succPlanPlaybookRec.CSM_Playbook__c){
				    			succPlanPlaybookRec.CSM_IsActive__c = newObj.CSM_IsActive__c;
				    			spPbToUpdateList.add(succPlanPlaybookRec);
				    			break;
				    		}
			    		}
			    	}
			    	if(!spPbToUpdateList.isEmpty()){
				    	CSM_AccountPlanPlaybookDataAccess.updateAccountPlanPlaybookList(spPbToUpdateList);
			    	}
		    	}
	    	}
 		}catch(exception ex){
 			if(!Test.isRunningTest()) {
 				REN_Util.setErrorInObjects (oldRecords, ex);
 			}
	 	}
 	}
}