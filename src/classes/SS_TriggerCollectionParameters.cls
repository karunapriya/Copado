global with sharing class SS_TriggerCollectionParameters {
	
	/*global OpportunityTriggerParams oppTriggerParams;
	global RLITriggerParams rliTriggerParams;
	global OLITriggerParams oliTriggerParams;*/
	
	global class OpportunityTriggerParams {
		global Set<Id> filteredIdSet;
		global Set<String> qualifiedIdSet;
		global List<Opportunity> filteredOpportunityList;
		global List<Opportunity> qualifiedOpportunityList;		
		global Map<Id, Opportunity> newRecordsMap;
		global Map<Id, Opportunity> oldRecordsMap;
		global Map<Id, Opportunity> filteredOpportunityMap;
		global Map<Id, Opportunity> qualifiedOpportunityMap;
		global String triggerEvent;
	}
	
	global class RLITriggerParams {
		global Set<id> impactedOppIdSet {get; set;}
		global Map<ID, List<REN_Renews_To__c>> recordsMap {get; set;}
		global Map<Id, REN_Renews_To__c> newRecordsMap {get;set;}
		global Map<Id, REN_Renews_To__c> oldRecordsMap {get;set;}
		global Set<Id> productIdSet {get;set;}
		global Map<Id, List<REN_Renews_To__c>> oppty2rrListMap {get;set;}
		global Map<String, String> oppty2RenewalIDMap{get;set;}
		global String triggerEvent;
		
	}
	
    global class OLITriggerParams{
    	global List<OpportunityLineItem> newRecordList;
    	global Map<Id, OpportunityLineItem> oldRecordsMap;
       	global Map<Id,OpportunityLineItem> qualifiedOLIMap;
       	global String triggerEvent;
       	
    }
    
    global class sObjectTriggerParams{
    	global List<sObject> qualifiedRecList;
    	global Map<Id, sObject> oldRecordsMap;
		global String objectName;
		global String triggerEvent;
    }
    
    global class CaseTriggerParams {
        global Set<Id> filteredIdSet;
        global Map<Id, Case> newRecordsMap;
        global Map<Id, Case> oldRecordsMap;
        global String triggerEvent;
        global List<Case> newRecords;
        global List<Case> oldRecords;
        global List<Case> qualifiedCasesList;
        global List<Case> originalCaseStatusClosedList;
        global Set<Id> originalCaseStatusClosedID;
        global Set<Id> generateRevisionCaseID;
        global Set<Id> completeMilestoneID;
        global List<Case> generateRevisionCaseList;
        global Set<Id> empIdSet;
        global Map<Id,Opportunity> IdToOppMap;
        global List<OperationTargetLIWrapper> OptargetLIWrpList; 
    }
    
    global class OperationTargetLIWrapper {
		global Id caseId;
		global String employeeId;
		global Date startDate;
		global Date endDate;
		global String  caseRecordType;
		global String caseOrigin;
	}
    
}