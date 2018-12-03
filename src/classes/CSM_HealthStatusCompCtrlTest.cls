/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CSM_HealthStatusCompCtrlTest {
	
	@testsetup
	static void setup(){
		List<Account> accountList = CSM_TestDataUtility.createAccount(10);
		accountList[0].CSM_Number_of_Cases__c = 10;
        upsert accountList;
        List<CSM_Account_Plan_Template__c> testTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
        System.assert(!testTemplates.isEmpty());
        CSM_TestDataUtility.createAccountPlan(accountList, testTemplates[0].Id);
        CSM_TestUtility.addCSMAdmin();
        system.assert(accountList.size() > 0);
	}

    static testMethod void myUnitTest() {
        //accountList[0].CSM_Last_Health_Status__c = System.today();
        CSM_UserPreferencesFilterWrapper wrapper = new CSM_UserPreferencesFilterWrapper();
        wrapper.attrFieldName = 'Last Health Status';
        wrapper.attrFieldType = 'DATE';
        wrapper.attrFieldValue = null;
        wrapper.attrFieldUserId = null;
        wrapper.attrFieldDateValue = System.today();
        CSM_TestUtility.addCSMAdmin();
        CSM_HealthStatusCompCtrl con = new CSM_HealthStatusCompCtrl();
    	con.userWrapper = new CSM_UserPreferencesFilterWrapper();      
    	Test.startTest();
        String jsonData = con.pieData;
        String colorData = con.colorData;
        system.assertNotEquals(jsonData,null); 
        con.healthStatusType = 'Undetermined';
        PageReference pageRef = con.displayDetails();
        
        con.userWrapper = wrapper;
        String jsonData1 = con.pieData;
        system.assertNotEquals(jsonData1,null);
        
        system.assertEquals(null, CSM_AccountDataAccess.getHealthInformationForAllAccounts());
        system.assertEquals(null, CSM_AccountDataAccess.getAccountsByHealthStatus('test'));
        system.assertEquals(null, CSM_AccountDataAccess.getAccountsByHealthStatusFilters('test', 'test','test','test', 'test', new Set<Id>()));
        system.assertEquals(null, CSM_AccountDataAccess.getAccountsByHealthStatusWithFilter('test', 'test','test','test'));
        system.assertEquals(null, CSM_AccountDataAccess.getAccountsByHealthStatusAndDateRange('test', system.today(), system.today()));
        system.assertEquals(null, CSM_AccountDataAccess.getAccountsByHealthStatusAndDateRangeWithFilter('test', system.today(), system.today(), 'test', 'test', 'test'));
        
        
        Test.stopTest();
    }
    
    static testMethod void getHealthInformationUserLookUpTest() {
        //List<Account> accountList = CSM_TestDataUtility.createAccount(10);
        //accountList[0].CSM_Last_Health_Status__c = System.today();
        CSM_TestUtility.addCSMAdmin();
        CSM_HealthStatusCompCtrl con = new CSM_HealthStatusCompCtrl();
    	con.userWrapper = new CSM_UserPreferencesFilterWrapper();      
    	CSM_UserPreferencesFilterWrapper userPrefWrapper = new CSM_UserPreferencesFilterWrapper();
    	userPrefWrapper.attObjectType = 'Account';
    	userPrefWrapper.attrFieldDateValue = System.today();
    	userPrefWrapper.attrFieldName  = 'CreatedByID';
    	userPrefWrapper.attrFieldValue = 'UserLookupField';
    	userPrefWrapper.attrFieldUserId = userinfo.getUserId();
    	Test.startTest();
        String jsonData = con.pieData;
        String colorData = con.colorData;
        system.assertNotEquals(jsonData,null); 
        con.healthStatusType = 'Undetermined';
        PageReference pageRef = con.displayDetails();
        
        con.userWrapper = userPrefWrapper;
        String jsonData1 = con.pieData;
        system.assertNotEquals(jsonData1,null);
        
        Test.stopTest();
    }
    
    static testMethod void getHealthInformationNonUserLookUpTest() {
        CSM_HealthStatusCompCtrl con = new CSM_HealthStatusCompCtrl();
    	con.userWrapper = new CSM_UserPreferencesFilterWrapper();      
    	CSM_UserPreferencesFilterWrapper userPrefWrapper = new CSM_UserPreferencesFilterWrapper();
    	userPrefWrapper.attObjectType = 'Account';
    	userPrefWrapper.attrFieldType = 'Double';
    	userPrefWrapper.attrFieldDateValue = System.today();
    	userPrefWrapper.attrFieldName  = 'CSM_Number_of_Cases__c';
    	userPrefWrapper.attrFieldValue = '10';
    	userPrefWrapper.attrFieldUserId = userinfo.getUserId();
    	Test.startTest();
        String jsonData = con.pieData;
        String colorData = con.colorData;
        system.assertNotEquals(jsonData,null); 
        con.healthStatusType = 'Undetermined';
        PageReference pageRef = con.displayDetails();
        
        con.userWrapper = userPrefWrapper;
        String jsonData1 = con.pieData;
        system.assertNotEquals(jsonData1,null);
        
        Test.stopTest();
    }
    
    static testMethod void getHealthInformationSuccessPlanTest() {
        CSM_HealthStatusCompCtrl con = new CSM_HealthStatusCompCtrl();
    	con.userWrapper = new CSM_UserPreferencesFilterWrapper();      
    	CSM_UserPreferencesFilterWrapper userPrefWrapper = new CSM_UserPreferencesFilterWrapper();
    	userPrefWrapper.attObjectType = 'Success Plan';
    	userPrefWrapper.attrFieldType = 'Reference';
    	userPrefWrapper.attrFieldName  = 'CreatedByID';
    	userPrefWrapper.attrFieldUserId = userinfo.getUserId();
    	Test.startTest();
        String jsonData = con.pieData;
        String colorData = con.colorData;
        system.assertNotEquals(jsonData,null); 
        con.healthStatusType = 'Undetermined';
        PageReference pageRef = con.displayDetails();
        
        con.userWrapper = userPrefWrapper;
        String jsonData1 = con.pieData;
        system.assertNotEquals(jsonData1,null);
        
        Test.stopTest();
    }
}