@isTest
public with sharing class CSM_IndicatorThumbnailsControllerTest {
	public static List<CSM_Account_Plan_Template__c> accPlanTemplates;
	public static List<Account> accountList;
	public static List<CSM_Account_Plan__c> accPlans;
	
	static testMethod void testPlayWidget(){
		CSM_TestUtility.setup();
		setup();		
	    Test.startTest();
	       	
	   	CSM_IndicatorThumbnailsController controller = new CSM_IndicatorThumbnailsController();
	   	if(accountList[0].Id != null && accPlanTemplates[0].Id != null){
	       		controller.getIndicatorWrapperList();
	       		controller.accountId=accountList[0].Id;
	       		controller.getAcctObject();
	       	}
	   	System.assert(controller.getIndicatorWrapperList().size() == 0);
	    Test.stopTest();
	}
	
	static void setup(){
		accPlanTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
		accountList = CSM_TestDataUtility.createAccount(1);
		accPlans = CSM_TestDataUtility.createAccountPlan(accountList, accPlanTemplates[0].Id);
	}
}