/**
 * @author    	: Sanket Supe (sanket@comitydesigns.com)     
 * @date        : 08/18/2017
 * @description : CSM_LeadTriggerHandler trigger handler for CSM_LeadTrigger
 */

public with sharing class CSM_LeadTriggerHandler extends CSM_TriggerManager.TriggerHandler {
    
	public override void onAfterUpdate (List<sObject> oldRecords, List<sObject> newRecords, 
	 					 Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {
		try { 
	 			Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
				if (hasRenewAccess){
					CSM_LeadTriggerHelper.getConvertedLead(newRecords);
				
					if(CSM_AccessController.hasField('TASK', CSM_Util.nameSpacePrefixSolnExtn + 'Account__c') 
			   			&& CSM_AccessController.hasField('Lead', CSM_Util.nameSpacePrefixSolnExtn + 'Lead_Lookup_Account_1__c')) {
			   			Map <id, sObject> lstOfEffectedLead = new Map<id, sObject>();
						for(sObject obj: newRecords){
							if(oldRecordsMap.get(''+obj.get('id')).get(CSM_Util.nameSpacePrefixSolnExtn + 'Lead_Lookup_Account_1__c') != newRecordsMap.get(''+obj.get('id')).get(CSM_Util.nameSpacePrefixSolnExtn + 'Lead_Lookup_Account_1__c')){
								lstOfEffectedLead.put(obj.id, obj);
							}
						}
						if(lstOfEffectedLead!=null && !lstOfEffectedLead.isEmpty()){
							CSM_LeadTriggerHelper.updatedLeadRecord(lstOfEffectedLead);
						}
			   		}
				}
				
		} catch (exception ex) {
		 		for (Integer i = 0; i < newRecords.size(); i++)
			 		{
			 			newRecords[i].addError(ex.getMessage());
			 		} 
		  }
				
	}
}