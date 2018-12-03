public with sharing class REN_RenewalRelationshipRollupHandler{
    /*
    public static void rollupRRonOpportunity(List <REN_Renews_To__c> rrList){  	
        Set<ID> impactedOppIdSet = new Set<ID>();
        for(REN_Renews_To__c rr: rrList){
            if(rr.REN_Renews_To__c != null){
                impactedOppIdSet.add(rr.REN_Renews_To__c);
            }
        }
        REN_OpportunityMetricsBusiness.resetMetricsFields(impactedOppIdSet);
    }
    */
    //This method is used to for metric recalculate in case of both old and new records.
    /*public static Set<id> rollupRRonAllAffectedOpportunities(Map<ID, REN_Renews_To__c> oldRecordsMap, Map<ID, REN_Renews_To__c> newRecordsMap){
 		Set<id> impactedOppIdSet = new Set<id>();
 		for(REN_Renews_To__c rr: newRecordsMap.Values()){
 			if(rr.REN_Renews_To__c != null){
                impactedOppIdSet.add(rr.REN_Renews_To__c);
            }
 			if(rr.REN_Renews_To__c != oldRecordsMap.get(rr.id).REN_Renews_To__c && oldRecordsMap.get(rr.id).REN_Renews_To__c != null){
                impactedOppIdSet.add((id)oldRecordsMap.get(rr.id).REN_Renews_To__c);
            }
 		}
 		return impactedOppIdSet;
    }*/

    public static Set<ID> resetFields(Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap, String comparableFieldName){
        Set<ID> changedRecIdSet = new Set<ID>();
        String endDateField = CSM_Util.getNameSpace() + 'REN_Is_End_Date_Modified__c'; 
        for(sObject newRec: newRecordsMap.values()){
            if(oldRecordsMap.get(newRec.id).get(comparableFieldName) != newRec.get(comparableFieldName)){
                changedRecIdSet.add(newRec.id);
                newRec.put(endDateField, true);
            }
            REN_Renews_To__c rr = (REN_Renews_To__c)newRec;
            if(rr.REN_Previous_Price__c != null && rr.REN_Renewal_Target_Multiplier__c != null){
                rr.REN_Renewal_Target__c = rr.REN_Previous_Price__c * rr.REN_Renewal_Target_Multiplier__c;
            }else{
                rr.REN_Renewal_Target__c = 0;
            }
        }
        return changedRecIdSet;
    }
  
}