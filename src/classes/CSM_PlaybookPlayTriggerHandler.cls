public with sharing class CSM_PlaybookPlayTriggerHandler extends CSM_TriggerManager.TriggerHandler {
    public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)	{
 		try	{
 			Set<Id> playbookIds = new Set<Id>();
	 		for(sObject newObj : newRecords) {
		    	playbookIds.add((Id)newObj.get('CSM_Playbook__c'));
		    }
		    List<CSM_Account_Plan_Playbook__c> successPlanPlaybookRecords = CSM_AccountPlanPlaybookDataAccess.getAccountPlanPlaybooksByPlaybookIds(playbookIds);
		    Map<Id,Set<Id>> successPlanPlayMap = new Map<Id,Set<Id>>();		
		    if(!successPlanPlaybookRecords.isEmpty() && successPlanPlaybookRecords != null) {
		    	Set<Id> spPlaybookId = new Set<Id>();
		    	for(CSM_Account_Plan_Playbook__c succPlanPlayRec:successPlanPlaybookRecords) {
		    		if(successPlanPlayMap != null && !successPlanPlayMap.containsKey(succPlanPlayRec.CSM_Playbook__c)) {
		    			successPlanPlayMap.put(succPlanPlayRec.CSM_Playbook__c,new Set<Id>{succPlanPlayRec.Id});
		    		} 
		    		else if(successPlanPlayMap != null && successPlanPlayMap.containsKey(succPlanPlayRec.CSM_Playbook__c)){
						spPlaybookId = successPlanPlayMap.get(succPlanPlayRec.CSM_Playbook__c);
						spPlaybookId.add(succPlanPlayRec.Id);
						successPlanPlayMap.put(succPlanPlayRec.CSM_Playbook__c, spPlaybookId);
					}
		    	}
		    	CSM_SuccessPlan_Play__c newRecord;
		    	List<CSM_SuccessPlan_Play__c> successPlanPlayRecords = new List<CSM_SuccessPlan_Play__c>();
	    		for(SObject newObj :newRecords) {
	    			if(successPlanPlayMap.containsKey((String)newObj.get('CSM_Playbook__c'))) {
	    				Set<Id> mapValuesSet = successPlanPlayMap.get((Id)newObj.get('CSM_Playbook__c'));
	    				for(Id mapValues:mapValuesSet) {
	    					newRecord = new CSM_SuccessPlan_Play__c();
	    					newRecord.CSM_Play__c = (Id)newObj.get('CSM_Play__c');
		    				newRecord.CSM_Playbook_Play__c = (Id)newObj.get('Id');
		    				newRecord.CSM_SuccessPlan_Playbook__c = mapValues;
		    				successPlanPlayRecords.add(newRecord);
	    				}
	    			}
	    		}
                // VCP - Required so that we do not call the parent trigger
                CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;
		    	successPlanPlayRecords = CSM_SuccessPlanPlayDataAccess.insertSuccessPlanPlayList(successPlanPlayRecords);
		    }
 		} catch(exception ex) {
	 		REN_Util.setErrorInObjects (newRecords, ex); 
	 	}
 	}
 	public override void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap)	{
 		try	{
 			Set<Id> deleteRecordIds = new Set<Id>();
	 		for(sObject oldObj : oldRecords) {
		    	deleteRecordIds.add((Id)oldObj.get('Id'));
		    }
		    CSM_SuccessPlanPlayDataAccess.deleteSPPlayListByPlaybookPlay(deleteRecordIds);
 		} catch(exception ex) {
	 		REN_Util.setErrorInObjects (oldRecords, ex); 
	 	}
 	}
}