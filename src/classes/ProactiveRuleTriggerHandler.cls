public with sharing class ProactiveRuleTriggerHandler extends TriggerManager.TriggerHandler {
	
	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
		if(Constants.PROACTIVE_RULE_AFTER_UPDATE_TRIGGER){
	    	ProactiveRuleTriggerHandlerHelper.updateProactiveRule( oldRecords, newRecords, oldRecordsMap, newRecordsMap);
	    	Constants.PROACTIVE_RULE_AFTER_UPDATE_TRIGGER = false;
		}
	}
	
	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
		if(Constants.PROACTIVE_RULE_BEFORE_UPDATE_TRIGGER){
    		ProactiveRuleTriggerHandlerHelper.updateBeforeProactiveRuleCriteriaList(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
    		Constants.PROACTIVE_RULE_BEFORE_UPDATE_TRIGGER = false;
		}
    }
}