public with sharing class CSM_PlaybookTriggerHandler extends CSM_TriggerManager.TriggerHandler {
    public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {
 		try {
 			Set<Id> playbookIds = new Set<Id>();
	 		for(sObject newObj : newRecords) {
		    	playbookIds.add((Id)newObj.get(CSM_Constants.OBJ_APT_ID));
		    }
		    List<CSM_Account_Plan_Playbook__c> successPlanPlaybookRecords = CSM_AccountPlanPlaybookDataAccess.getAccountPlanPlaybooksByPlaybook(playbookIds);		
		    if(!successPlanPlaybookRecords.isEmpty() && successPlanPlaybookRecords != null) {
		    	CSM_Account_Plan_Playbook__c newRecord;
		    	List<CSM_Account_Plan_Playbook__c> successPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
	    		for(SObject newObj :newRecords) {
	    			for(CSM_Account_Plan_Playbook__c succPlanPlaybookRec : successPlanPlaybookRecords) {
	    				if(newObj.get('Id') == succPlanPlaybookRec.CSM_Playbook__c 
	    				&& newObj.get(CSM_Constants.OBJ_PLAYBOOK_ISACTIVE) != oldRecordsMap.get(newObj.id).get('CSM_IsActive__c')) {
	    					succPlanPlaybookRec.CSM_IsActive__c = (Boolean)newObj.get(CSM_Constants.OBJ_PLAYBOOK_ISACTIVE);
	    				}
	    			}
	    		}
		    	successPlanPlaybookList = CSM_AccountPlanPlaybookDataAccess.updateAccountPlanPlaybookList(successPlanPlaybookRecords);
	    	}
 		} catch(exception ex) {
 			REN_Util.setErrorInObjects (oldRecords, ex);
	 	}
 	}
}