public with sharing class CaseTriggerHandler extends TriggerManager.TriggerHandler {
    public static boolean isInsertRequest = false; // It has been added as temperory fix for US1788 validations, because while inserting case records, WorkFlows updates same record and causes this some validations throws errors.
	//It has to be solved in future release.

    public override void onBeforeInsert(List<sObject> newRecords,Map<ID, sObject> newRecordsMap){
            /*try{
            	Set<String> oppIdSet = new Set<String>();
            	Set<String> userIdSet = new Set<String>();
            	Set<String> accountIdSet = new Set<String>();            	
            	List<Case> caseLst = (List<Case>)newRecords;
            	for(Case newCase : caseLst){
            		if(newCase.Opportunity__c != null){
                		oppIdSet.add(newCase.Opportunity__c);
           			}
           			userIdSet.add(newCase.OwnerId);
           			accountIdSet.add(newCase.AccountId);
           			
            	}
            	CaseTriggerHandlerHelper csTrigHelper = new CaseTriggerHandlerHelper();
                csTrigHelper.processBeforeInsert(oppIdSet, accountIdSet, caseLst);                
                csTrigHelper.updateSubjectOfCase(oppIdSet, accountIdSet, userIdSet, caseLst);
                isInsertRequest = true;
            }catch(Exception e){
                Util.setErrorInObjects(newRecords,e);
            }*/
    }
    
    public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {
            /*try{
            	if(Constants.CASE_BEFORE_UPDATE_TRIGGER){
		            Constants.CASE_BEFORE_UPDATE_TRIGGER = false;
		            List<Case> caseLst = new List<Case>();
		            caseLst = newRecords;
		            CaseTriggerHandlerHelper csTrigHelper = new CaseTriggerHandlerHelper();
		            csTrigHelper.processBeforeUpdate(caseLst,oldRecordsMap);
	            	csTrigHelper.caseValidationOnUsers(caseLst,oldRecordsMap);
            	}
            }catch(Exception e){
                Util.setErrorInObjects(newRecords,e);
            }*/
    }
    
    public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)  {
    	/*try{
    		if(Constants.CASE_AFTER_UPDATE_TRIGGER){
    			Constants.CASE_AFTER_UPDATE_TRIGGER = false;
	        	List<Case> caseLst = new List<Case>();
	            caseLst = newRecords;
	            CaseTriggerHandlerHelper csTrigHelper = new CaseTriggerHandlerHelper();
	            csTrigHelper.processAfterUpdate(newRecordsMap, oldRecordsMap);
    		}
		}catch(Exception e){
            Util.setErrorInObjects(newRecords,e);
        }*/
    }
    
}