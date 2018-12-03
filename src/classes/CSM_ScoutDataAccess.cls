public with sharing class CSM_ScoutDataAccess {
	
	public static List<SObject> getScoutCustomerList(set<Id> accountIds){
		List<SObject> sobjList;
		if(accountIds != null && !accountIds.isEmpty()){
			List<String> scoutAcctFieldList = new List<String>{'ScoutForSREV__Customer_Reference_Id__c', 'ScoutForSREV__Customer_Instance_Code__c'};
			CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_SA_SREV_CUSTOMER, scoutAcctFieldList, CSM_Constants.DML_OPERATION_READ);
			String soql = 'SELECT ID, ScoutForSREV__Customer_Reference_Id__c, ScoutForSREV__Customer_Instance_Code__c FROM ScoutForSREV__Scout_Customer__c WHERE ScoutForSREV__Customer_Reference_Id__c IN :accountIds LIMIT 100';
			sobjList = Database.query(soql);
		}
		return sobjList;
	}
	
	public static List<SObject> getScoutAccountList(set<Id> accountIds){
		List<SObject> sobjList;
		if(accountIds != null && !accountIds.isEmpty()){
			system.debug('accountIds $$$$$$$ '+accountIds);
			List<String> scoutAcctFieldList = new List<String>{CSM_Constants.OBJ_A_SA_CUST, CSM_Constants.OBJ_A_SA_BUSINESS};
			CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_ACCOUNT, scoutAcctFieldList, CSM_Constants.DML_OPERATION_READ);
			String soql = 'SELECT ID, ScoutAnalytics__CustomerInstanceCode__c, ScoutAnalytics__Businessunit_did__c FROM ACCOUNT WHERE Id IN :accountIds LIMIT 100';
			sobjList = Database.query(soql);
			system.debug('sobjList $$$$$$$ '+sobjList);
		}
		return sobjList;
	}
}