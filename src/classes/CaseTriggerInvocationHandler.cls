/**
 * Created Date		: Aug 23, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: smitah@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					US3726				Aug 23, 2018			1.1					@description
 *
 */
global with sharing class CaseTriggerInvocationHandler extends SS_FeatureInvocation.FeatureHandler {
	global override void featureInvocation(Object parameters) {
		SS_TriggerCollectionParameters.CaseTriggerParams caseTriggerParam = (SS_TriggerCollectionParameters.CaseTriggerParams) parameters;			
		if(caseTriggerParam.triggerEvent.equalsIgnoreCase('onAfterUpdate')){
			if(caseTriggerParam.qualifiedCasesList != null && !caseTriggerParam.qualifiedCasesList.isEmpty()){
				PeerReviewUtils.peerReviewTracker(caseTriggerParam.qualifiedCasesList);				
			}
			if(!caseTriggerParam.originalCaseStatusClosedList.isEmpty() || !caseTriggerParam.generateRevisionCaseID.isEmpty() ||  !caseTriggerParam.completeMilestoneID.isEmpty()){
				CaseTriggerHandlerHelper.completeMilestone(parameters);
			}
		}
        if(caseTriggerParam.triggerEvent.equalsIgnoreCase('onBeforeUpdate')){ 
        	CaseTriggerHandlerHelper caseHelper = new CaseTriggerHandlerHelper();
        	caseHelper.processBeforeUpdate(caseTriggerParam.newRecords, caseTriggerParam.oldRecordsMap);   
        }
        if(caseTriggerParam.triggerEvent.equalsIgnoreCase('onBeforeInsert')){
            if(caseTriggerParam.newRecords != null && caseTriggerParam.empIdSet != null){
                CaseTriggerHandlerHelper.getOperationLineItems(caseTriggerParam.newRecords,caseTriggerParam.empIdSet);
            }
            
            if(caseTriggerParam.qualifiedCasesList != null && !caseTriggerParam.qualifiedCasesList.isEmpty() && caseTriggerParam.IdToOppMap != null && !caseTriggerParam.IdToOppMap.isEmpty()){
                List<Opportunity> oppList = CaseTriggerHandlerHelper.updateReviewRequestCase(caseTriggerParam.qualifiedCasesList,caseTriggerParam.IdToOppMap);
                OpportunityDataAccess.updateOpportunityList(oppList, new List<String>{'Ops_Stage__c'});
            }
        }
	}
}