public with sharing class ProactiveRuleLineItemTriggerHandler extends TriggerManager.TriggerHandler {
    
    public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		ProactiveRuleLITriggerHandlerHelper.proactiveRulesInsertByPRLI(newRecords, newRecordsMap);
	}
	
	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
		if(Constants.PROACTIVE_RULE_LINE_ITEM_AFTER_UPDATE_TRIGGER){
	    	ProactiveRuleLITriggerHandlerHelper.proactiveRulesUpdatedByPRLI( oldRecords, newRecords, oldRecordsMap, newRecordsMap);
	    	Constants.PROACTIVE_RULE_LINE_ITEM_AFTER_UPDATE_TRIGGER = false;
		}
	}
	
	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		ProactiveRuleLITriggerHandlerHelper.populateTypeFieldOnProactiveRulesLineItem(newRecords,newRecordsMap);
	}
	
	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
		if(Constants.PROACTIVE_RULE_LINE_ITEM_BEFORE_UPDATE_TRIGGER){
	 		ProactiveRuleLITriggerHandlerHelper.populateTypeFieldOnProactiveRulesLineItem(newRecords,newRecordsMap);
	 		Constants.PROACTIVE_RULE_LINE_ITEM_BEFORE_UPDATE_TRIGGER = false;
		}
	 }
	 
	public override void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {
		ProactiveRuleLITriggerHandlerHelper.proactiveRulesUpdatedByPRLI(oldRecords,oldRecordsMap);
	}
}