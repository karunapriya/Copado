@isTest
public with sharing class CSM_HlthStatHeatmapCmptCntrlTest
{
	static testMethod void testTimeline() {
		
		setUp();
		Test.startTest();	
    	
    	CSM_HealthStatusHeatmapComponentCntrl controller = new CSM_HealthStatusHeatmapComponentCntrl();
    	controller.userWrapper = new CSM_UserPreferencesFilterWrapper(); 
    	System.assertNotEquals(controller.getHeatmapData(), null);
    	
    	CSM_UserPreferencesFilterWrapper wrapper = new CSM_UserPreferencesFilterWrapper();
    	wrapper.attObjectType = 'Account';
        wrapper.attrFieldName = 'Last Health Status';
        wrapper.attrFieldType = 'DATE';
        wrapper.attrFieldValue = null;
        wrapper.attrFieldUserId = null;
        wrapper.attrFieldDateValue = Date.today().addDays(-200);
    	controller.userWrapper = wrapper;
    	controller.getHealthCategories();
    	
    	controller.xPoint = 0;
    	controller.yPoint = CSM_Constants.OBJ_A_UNDETERMINED;
    	
    	System.assertNotEquals(controller.displayAccountHealthStatus(), null);

  
    	Test.stopTest();
	}
	static testMethod void testTimelineNegative() {
		
		setUp();
		User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');   	
    	system.runAs(restrictedUser){
		Test.startTest();	
    	
    	CSM_HealthStatusHeatmapComponentCntrl controller = new CSM_HealthStatusHeatmapComponentCntrl();
    	controller.userWrapper = new CSM_UserPreferencesFilterWrapper(); 
    	System.assertNotEquals(controller.getHeatmapData(), null);
    	
    	CSM_UserPreferencesFilterWrapper wrapper = new CSM_UserPreferencesFilterWrapper();
    	wrapper.attObjectType = 'Account';
        wrapper.attrFieldName = 'Last Health Status';
        wrapper.attrFieldType = 'DATE';
        wrapper.attrFieldValue = null;
        wrapper.attrFieldUserId = null;
        wrapper.attrFieldDateValue = Date.today().addDays(-200);
    	controller.userWrapper = wrapper;
    	controller.getHealthCategories();
    	
    	controller.xPoint = 0;
    	controller.yPoint = CSM_Constants.OBJ_A_UNDETERMINED;
    	
    	System.assertNotEquals(controller.displayAccountHealthStatus(), null);

  
    	Test.stopTest();
    	}
	}
	static void setUp() 
	{
		Account account1 = new Account();
		account1.name = 'healthyTestAccount';
		account1.CSM_Health_Status__c = 'Healthy';
		insert account1;
		CSM_TestUtility.insertAccountPlan(account1.Id);
		
		Account account2 = new Account();
		account2.name = 'lowAdoptionTestAccount';
		account2.CSM_Health_Status__c = 'Low Adoption';
		insert account2;
		CSM_TestUtility.insertAccountPlan(account2.Id);
		
		Account account3 = new Account();
		account3.name = 'pendingChurnAccount';
		account3.CSM_Health_Status__c = 'Pending Churn';
		insert account3;
		CSM_TestUtility.insertAccountPlan(account3.Id);
		
		Account account4 = new Account();
		account4.name = 'firstTestAccount';
		insert account4;
		CSM_TestUtility.insertAccountPlan(account4.Id);
		
		Account account5 = new Account();
		account5.name = 'healthyTestAccount2';
		account5.CSM_Health_Status__c = 'Healthy';
		
		account5.CSM_Last_Health_Status__c = Date.today().addDays(-200);
		insert account5;
        CSM_TestUtility.insertAccountPlan(account5.Id);
		
		Account account6 = new Account();
		account6.name = 'lowAdoptionTestAccount2';
		account6.CSM_Health_Status__c = 'Low Adoption';
		account6.CSM_Last_Health_Status__c = Date.today().addDays(-200);
		insert account6;
		CSM_TestUtility.insertAccountPlan(account6.Id);
		
		Account account7 = new Account();
		account7.name = 'pendingChurnAccount2';
		account7.CSM_Health_Status__c = 'Pending Churn';
		account7.CSM_Last_Health_Status__c = Date.today().addDays(-200);
		insert account7;
		CSM_TestUtility.insertAccountPlan(account7.Id);
		
		Account account8 = new Account();
		account8.name = 'firstTestAccoun2t';
		account8.CSM_Last_Health_Status__c = Date.today().addDays(-200);
        insert account8;
		CSM_TestUtility.insertAccountPlan(account8.Id);
		
		Account account9 = new Account();
		account9.name = 'firstTestAccoun3t';
		account9.CSM_Last_Health_Status__c = Date.today().addDays(-100);
        insert account9;
		CSM_TestUtility.insertAccountPlan(account9.Id);	
		
		Account account10 = new Account();
		account10.name = 'firstTestAccoun4t';
		account10.CSM_Last_Health_Status__c = Date.today().addDays(-50);
        insert account10;
		CSM_TestUtility.insertAccountPlan(account10.Id);
		
		Account account11 = new Account();
		account11.name = 'firstTestAccoun5t';
		account11.CSM_Last_Health_Status__c = Date.today().addDays(-0);
        insert account11;
		CSM_TestUtility.insertAccountPlan(account11.Id);
		
		Account account12 = new Account();
		account12.name = 'firstTestAccoun6t';
		account12.CSM_Last_Health_Status__c = Date.today().addDays(-90);
        insert account12;
		CSM_TestUtility.insertAccountPlan(account12.Id);
		
		Account account13 = new Account();
		account13.name = 'firstTestAccoun7t';
		account13.CSM_Last_Health_Status__c = Date.today().addDays(-20);
        insert account13;
		CSM_TestUtility.insertAccountPlan(account13.Id);
		
	}
}