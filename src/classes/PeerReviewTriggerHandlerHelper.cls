public with sharing class PeerReviewTriggerHandlerHelper {
    public static void updateCaseRecordType( List<sObject> newRecords, Map<ID, sObject> newRecordsMap ){
	   	Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
	    for(sObject pr : newRecords) {
	        if(pr.get('Case_Record_Type__c') == ZS.Case_Quote_Request_Record_Type_Id__c)  pr.put('Case_Record_Type_Name__c','Quote Request');
	        else if (pr.get('Case_Record_Type__c') == ZS.Case_Booking_Request_Record_Type_Id__c) pr.put('Case_Record_Type_Name__c','Booking Request');
	        else pr.put('Case_Record_Type__c','');
	    }
    }
}