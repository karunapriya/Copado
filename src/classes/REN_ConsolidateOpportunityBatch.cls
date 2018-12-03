/**
 * Created Date     : Dec 2, 2016
 * Developed By     : Nkonkar, Comity Designs, Inc.
 *
 * Function         : @description - Batch will run for consolidating the opportunities in Bulk.
 * Support Email    : servicesource@comitydesigns.com
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Nkonkar                  User Story              Dec 2, 2016         1.1                 @description
 *
 */
global with sharing class REN_ConsolidateOpportunityBatch implements REN_IScheduleDispatched, Database.Batchable<SObject>, Database.Stateful{
        
	global REN_ConsolidateOpportunityBatch(){}
	Set<Id> consolidationRequests = new Set<Id>();
	List<Opportunity> targetOpptyList;
    
    public void execute(SchedulableContext SC){   
        String batchprocessid = Database.executeBatch(this, 1);
        //System.abortJob(SC.getTriggerId());
    }
    
    global Database.QueryLocator Start(Database.BatchableContext BC) {
        
        String queryString = 'Select REN_Consolidation_Request__c, REN_Consolidation_Request__r.REN_Target_Opportunity__c, REN_Consolidation_Request__r.REN_Target_Opportunity__r.Name, REN_Source_Opportunity__c ' +
        				+ 'From REN_Consolidation_Request_Source__c where REN_Consolidation_Request__r.REN_Processing_Completed__c = false';
        if (Test.IsRunningTest()){
        	queryString += ' LIMIT 1';
        }
        return Database.getQueryLocator(queryString);
    }   

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
		CSM_TriggerManager.disableAllTriggers();
		List<REN_Consolidation_Request_Source__c> crsList = (List<REN_Consolidation_Request_Source__c>)scope;
        Map<String, Id> sourceToTargetOpptyMap = new Map<String, Id>();
        Map<String, String> sourceToTargetOpptyNameMap = new Map<String, String>();
        Set<ID> allSourceOppIdSet = new Set<Id>();
        Set<ID> allTargetOppIdSet = new Set<Id>();
        Map<Id, REN_Consolidation_Request_Source__c> reqSourceToOppIdMap = new Map<Id, REN_Consolidation_Request_Source__c>();
        
        REN_Consolidation_Request_Source__c consolReqSource = crsList[0];
    	consolidationRequests.add(consolReqSource.REN_Consolidation_Request__c);
        sourceToTargetOpptyMap.put(consolReqSource.REN_Source_Opportunity__c, consolReqSource.REN_Consolidation_Request__r.REN_Target_Opportunity__c);
        sourceToTargetOpptyNameMap.put(consolReqSource.REN_Source_Opportunity__c, consolReqSource.REN_Consolidation_Request__r.REN_Target_Opportunity__r.Name);   	
    	reqSourceToOppIdMap.put(consolReqSource.REN_Source_Opportunity__c,consolReqSource);
	    allSourceOppIdSet.add(consolReqSource.REN_Source_Opportunity__c);
	    allTargetOppIdSet.add(consolReqSource.REN_Consolidation_Request__r.REN_Target_Opportunity__c);
		
    	Savepoint sp = Database.setSavepoint(); 
        try{
        	if(sourceToTargetOpptyMap != null && !sourceToTargetOpptyMap.isEmpty()){
        		List<Opportunity> sourceOpptyList = REN_OpportunityDataAccess.getOpportunityWithRRnLI(allSourceOppIdSet);
        		
        		Integer validOliCount = 0;
        		for(opportunity oppt : sourceOpptyList){
        			validOliCount = 0;
        			Map<ID, REN_Renews_To__c> rrMap = new Map<ID, REN_Renews_To__c>();
        			if(!SS_Constants.isSimplifiedDataModelEnabled){
	                	if(oppt.Renew_To__r != null && oppt.Renew_To__r.size() > 0){
	                		rrMap = new Map<ID, REN_Renews_To__c>(oppt.Renew_To__r);
	                	}
        			}
        			
        			Map<ID, OpportunityLineItem> oliMap = new Map<ID, OpportunityLineItem>();
        			if(oppt.OpportunityLineItems != null && !oppt.OpportunityLineItems.isEmpty()){
                		oliMap = new Map<ID, OpportunityLineItem>(oppt.OpportunityLineItems);
                		for(OpportunityLineItem oli : oppt.OpportunityLineItems){
                			if(oli.REN_Renewable_Line_Item__c != null  && rrMap.containsKey(oli.REN_Renewable_Line_Item__c)){
    							validOliCount++;
    						}
                		}           	
        			}
        			
                	SS_License__c productIdSetting = SS_License__c.getOrgDefaults();
        			if(SS_Constants.isSimplifiedDataModelEnabled && productIdSetting.Renewal_Amount_Product_Id__c!=null){
        				if(oppt.Renew_To__r.size() > 0)
        					validOliCount++;
        			}
                	reqSourceToOppIdMap.get(oppt.id).REN_Number_of_RLIs__c = oppt.Renew_To__r.size();
                	reqSourceToOppIdMap.get(oppt.id).REN_Number_of_OLIs__c = validOliCount;               		
                }
                targetOpptyList = REN_OpportunityDataAccess.getFilteredRecordsList('Opportunity',
                															 						new Set<String>{'id','StageName','Pricebook2Id','Probability'}, 
                															 						allTargetOppIdSet, 
                																					null, 
                																					null,
                																					null);																				
				String errorMsg = '';
		 		errorMsg = REN_ConsolidateHandler.finalConsolidation(null,null, REN_Constants.STR_CONSOLIDATE, sourceOpptyList, targetOpptyList[0]);
		 		
		 		if(String.isNotBlank(errorMsg)){
		 			Database.rollback(sp);
		 			REN_ConsolidateHandler.updateErrorMessageOnCRS(crsList, errorMsg, true);
		 		} else {
		 			CHL_ManageSplitConsolidatePRR.handlePRRSplitAndConsolidate(null, sourceOpptyList, targetOpptyList[0], REN_Constants.STR_CONSOLIDATE,true);
		 			REN_ConsolidateHandler.createChatterFeeds(sourceToTargetOpptyNameMap, sourceToTargetOpptyMap);
		            REN_ConsolidateHandler.updateErrorMessageOnCRS(crsList, '', false);
		 		}
			}
        }catch(Exception ex){
        	Database.rollback(sp);
        	REN_ConsolidateHandler.updateErrorMessageOnCRS(crsList, ex.getMessage(), true);
    	}
    }
        
    global void finish(Database.BatchableContext batchContext){
		if(consolidationRequests != null){
			REN_ConsolidateHandler.updateConsolidationRequests(consolidationRequests);
		}
		if(targetOpptyList != null){
		     CHL_ManageSplitConsolidatePRR.createQuoteAndQLIs(targetOpptyList);
		}
    }
}