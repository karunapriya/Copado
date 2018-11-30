@isTest
private class CSM_CaseTriggerTest {
	

	static testMethod void Test_CaseTrigger_Positive() {
		List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		Case caseObj = CSM_TestDataUtility.createCase(accountList[0].Id);
		insert caseObj;
		system.assert(caseObj.Id != null);
	}
}