public with sharing class REN_ServiceContractTriggerHandler extends CSM_TriggerManager.TriggerHandler {
	
 	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
	 	if(REN_Constants.SERVICE_CONTRACT_BEFORE_TRIGGER){
			REN_Constants.SERVICE_CONTRACT_BEFORE_TRIGGER = false;
	 		try{
		        Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		        Boolean hasAccountField = CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + 'REN_Related_Account__c');
			 	if(hasRenewAccess == true){
					for(SObject sContract: newRecords){
						if(hasAccountField && sContract.get('AccountId') != sContract.get(CSM_Util.nameSpacePrefix21 +'REN_Related_Account__c')){
							sContract.put(CSM_Util.nameSpacePrefix21 +'REN_Related_Account__c',sContract.get('AccountId'));
						}
					}
			 	}
	 		}
	 		catch(exception ex){
		 		REN_Util.setErrorInObjects (newRecords, ex);
		 	}
		}
 	}
 	
 	public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
	 	if(REN_Constants.SERVICE_CONTRACT_BEFORE_TRIGGER){
			REN_Constants.SERVICE_CONTRACT_BEFORE_TRIGGER = false;
	 		try{
		        Boolean hasRenewAccess =  SS_LicenseCheck.getInstance().isRenewEnabled;
		        Boolean hasAccountField = CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + 'REN_Related_Account__c');
			 	if(hasRenewAccess == true){
					for(SObject sContract: newRecords){
						if(hasAccountField && sContract.get('AccountId') != sContract.get(CSM_Util.nameSpacePrefix21 +'REN_Related_Account__c')){
							sContract.put(CSM_Util.nameSpacePrefix21 +'REN_Related_Account__c',sContract.get('AccountId'));
						}
					}
			 	}
	 		}
	 		catch(exception ex){
		 		REN_Util.setErrorInObjects (newRecords, ex);
		 	}
		}
 	}
    
}