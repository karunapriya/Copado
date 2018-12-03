public with sharing class ProactiveRuleLITriggerHandlerHelper {
	
    //boolean updatePActiveRule = ;
    public static void proactiveRulesUpdatedByPRLI(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
	    List<String> prToRegenerateList = new List<String>();
	    list<Proactive_Rule_Line_Item__c> proactiveRuleLst = new list<Proactive_Rule_Line_Item__c> ();
	    proactiveRuleLst = newRecords;
	    Proactive_Rule_Line_Item__c oldPrl;
	    for(Proactive_Rule_Line_Item__c prl : proactiveRuleLst) {
	        oldPrl = (Proactive_Rule_Line_Item__c)oldRecordsMap.get(prl.Id);
	        if(prl.Field__c != oldPrl.Field__c 
	            || prl.Operator__c != oldPrl.Operator__c 
	            || prl.Value__c != oldPrl.Value__c ) {
	            prToRegenerateList.add(prl.Proactive_Rule__c);
	        }
	    }
	    
	    if(prToRegenerateList.size() > 0) {
	    	ProactiveRuleUtils.regenerateProRuleOutput(prToRegenerateList,true);
	    }
    }
    
    public static void proactiveRulesUpdatedByPRLI(List<sObject> oldRecords,Map<ID, sObject> oldRecordsMap){
	    List<String> prToRegenerateList = new List<String>();
	    list<Proactive_Rule_Line_Item__c> proactiveRuleLst = new list<Proactive_Rule_Line_Item__c> ();
	    proactiveRuleLst = oldRecords;
	    Proactive_Rule_Line_Item__c oldPrl;
	    for(Proactive_Rule_Line_Item__c prl : proactiveRuleLst) {
	         prToRegenerateList.add(prl.Proactive_Rule__c);
	   }
	    
	    if(prToRegenerateList.size() > 0) {
	    	ProactiveRuleUtils.regenerateProRuleOutput(prToRegenerateList,true);
	    }
    }
    
    public static void proactiveRulesInsertByPRLI(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		List<String> prToRegenerateList = new List<String>();
	    list<Proactive_Rule_Line_Item__c> proactiveRuleLst = new list<Proactive_Rule_Line_Item__c> ();
	    proactiveRuleLst = newRecords;
	    for(Proactive_Rule_Line_Item__c prl : proactiveRuleLst) {
	            prToRegenerateList.add(prl.Proactive_Rule__c);
	    }
	    
	    if(prToRegenerateList.size() > 0) {
	    	ProactiveRuleUtils.regenerateProRuleOutput(prToRegenerateList,true);
	    }
    }
    
    public static void populateTypeFieldOnProactiveRulesLineItem(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
	    Map<String, Schema.SObjectField> oppSchemaMap = Schema.SObjectType.Opportunity.fields.getMap();
	    Map<String, String> fieldTypeMap = new Map<String, String>();
	    for(Schema.SObjectField sfield : oppSchemaMap.Values()) {
	        fieldTypeMap.put(String.valueOf(sfield.getDescribe().getName()), String.valueOf(sfield.getDescribe().getSoapType()));
	    }
	    List<Proactive_Rule_Line_Item__c> proactiveRulesLineItemList = new List<Proactive_Rule_Line_Item__c>();
	    proactiveRulesLineItemList = newRecords;
	    for(Proactive_Rule_Line_Item__c prl : proactiveRulesLineItemList) {
	        prl.Type__c = fieldTypeMap.get(prl.Field__c);
	    }
	    	
	 }
}