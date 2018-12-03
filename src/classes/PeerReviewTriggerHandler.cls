public with sharing class PeerReviewTriggerHandler extends TriggerManager.TriggerHandler{
	
    public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)
    {
            PeerReviewTriggerHandlerHelper.updateCaseRecordType(newRecords, newRecordsMap);
    }
    public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
    {
    	if(Constants.PEER_REVIEW_BEFORE_UPDATE_TRIGGER){
            PeerReviewTriggerHandlerHelper.updateCaseRecordType(newRecords, newRecordsMap);
            Constants.PEER_REVIEW_BEFORE_UPDATE_TRIGGER = false;
    	}
    }    
}