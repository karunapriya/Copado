public with sharing class CSM_AccountPlanTriggerHandler extends CSM_TriggerManager.TriggerHandler {
	
	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
	 	try {
	 		CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        	Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
            Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
            if (hasCSMAccess || hasRenewAccess){
		 		Set<Id> accountIdSet = getAccountList(newRecords);

		 		CSM_AccountPlanTriggerHelper.createSPPlayBook(newRecords);		 		
		 		CSM_TaskCreationTriggerUtil.CreatePlayActivities(accountIdSet, newRecords, CSM_Constants.OBJ_AP);
		 		setPlanExistsFlagOnAccount(accountIdSet, true);		 		
            }
	 	}
	 	catch (Exception ex){
	 		REN_Util.setErrorInObjects (newRecords, ex);
	 	}
	 }
	 
	 public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
	 {
	 	try {
	 		CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
	 		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
            Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
            if (hasCSMAccess || hasRenewAccess){
				Set<Id> newAccountIds = new Set<Id>();
		 		CSM_AccountPlanTriggerHelper.deleteSPPlayBook(newRecords,oldRecordsMap);
				setHasPlanFlagOnAccountOnUpdate(newRecords, oldRecordsMap, newAccountIds);		 				 		
		 		CSM_TaskCreationTriggerUtil.CreatePlayActivities(newAccountIds, newRecords, CSM_Constants.OBJ_AP);
            }
	 	}
	 	catch (exception ex){
	 		REN_Util.setErrorInObjects (newRecords, ex);
	 	}
	 }
	 
	  public override void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap)
	 {
	 	try {
	 		CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = false;
	 		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
            Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
            if (hasCSMAccess || hasRenewAccess){
            	List<String> deleteRecordIds = new List<String>();
	 			for(sObject oldObj : oldRecords) {
		    		deleteRecordIds.add((String)oldObj.get('Id'));
		    	}
				List<CSM_Account_Plan_Playbook__c> acctPlanPlyBookLst = CSM_AccountPlanPlaybookDataAccess.getAcctPlanPlaybooksByAccPlanId(deleteRecordIds);
				CSM_AccountPlanPlaybookDataAccess.deleteAcctPlanPlaybook(acctPlanPlyBookLst);
			}
	 	}
	 	catch (exception ex){
	 		REN_Util.setErrorInObjects (oldRecords, ex);
	 	}
	 }

	 public override void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap)
	 {
	 	try {
	 		CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
	 		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
            Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
            if (hasCSMAccess || hasRenewAccess){
				setPlanExistsFlagOnAccount(getAccountList(oldRecords), false);
            }
	 	}
	 	catch (exception ex){
	 		REN_Util.setErrorInObjects (oldRecords, ex);
	 	}
	 }

	public override void onAfterUnDelete(List<sObject> newRecords)
	{
	 	try {
	 		CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = false;
        	Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
            Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
            if (hasCSMAccess || hasRenewAccess){
		 		setPlanExistsFlagOnAccount(getAccountList(newRecords), true);
            }
	 	}
	 	catch (exception ex){
	 		REN_Util.setErrorInObjects (newRecords, ex);
	 	}
	}
	 
	private void setHasPlanFlagOnAccountOnUpdate(List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Set<Id> newAccountIds){
		List<Account> accountForUpdate = new List<Account>();
		for(CSM_Account_Plan__c ap : (List<CSM_Account_Plan__c>)newRecords){
			CSM_Account_Plan__c oldAp = (CSM_Account_Plan__c)oldRecordsMap.get(ap.Id);
			if(ap.CSM_AccountId__c != oldAp.CSM_AccountId__c){
				if(oldAp.CSM_AccountId__c != null){
					accountForUpdate.add(new Account (Id = oldAp.CSM_AccountId__c, CSM_Account_Has_Success_Plan__c = false));
				}
				if(ap.CSM_AccountId__c != null){
					accountForUpdate.add(new Account (Id = ap.CSM_AccountId__c, CSM_Account_Has_Success_Plan__c = true));
				}
			}
			newAccountIds.add(ap.CSM_AccountId__c);
		}
		if(!accountForUpdate.isEmpty()){
			CSM_AccountDataAccess.updateAccounts(accountForUpdate);
		}
	}
	 
	private Set<Id> getAccountList(List<CSM_Account_Plan__c> recordList){
	 	Set<Id> accountIdSet = new Set<Id>();
	 	for(CSM_Account_Plan__c p : (List<CSM_Account_Plan__c>) recordList){
	 		accountIdSet.add(p.CSM_AccountId__c);
	 	}
	 	return accountIdSet;
	}

	private void setPlanExistsFlagOnAccount(Set<Id> accountIds, Boolean hasSuccessPlan){
		List<Account> finalAccountHavingPlan = new List<Account>();
		for (Id accountId : accountIds){
			finalAccountHavingPlan.add(new Account (Id = accountId, CSM_Account_Has_Success_Plan__c = hasSuccessPlan));			
		}
		CSM_AccountDataAccess.updateAccounts(finalaccountHavingPlan);
	}
}