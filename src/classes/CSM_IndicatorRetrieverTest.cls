@isTest
public with sharing class CSM_IndicatorRetrieverTest {
	public static List<CSM_Account_Plan_Template__c> accPlanTemplates;
	public static List<Account> accountList;
	public static List<CSM_Account_Plan__c> accPlans;
	public static List<CSM_Indicator_Group__c> indicatorGroupList;
	public static List<CSM_Indicator__c> indicatorList;
	public static List<CSM_Account_Plan_Template_Indicator__c> acctPlanTemplateIndicatorList;
	public static List<Opportunity> opportunityList;

	static testMethod void indicatorRetriverTest() {
		CSM_TestUtility.setup();
		setup();
		Test.startTest();
				
		CSM_IndicatorRetriever retriver = new CSM_IndicatorRetriever();
		List<CSM_IndicatiorThumbnailWrapper> wrapperList = retriver.getIndicatorWrapperList(accPlanTemplates[0].Id, accountList[0].Id);
		System.assert(wrapperList!=null);
        
		wrapperList = retriver.getIndicatorWrapperList(accPlanTemplates[0].Id, accountList[1].Id);
		System.assert(wrapperList!=null);

		wrapperList = retriver.getIndicatorWrapperList(accPlanTemplates[0].Id, accountList[2].Id);
		System.assert(wrapperList!=null);

        
		Test.stopTest();
	}

	static testMethod void indicatorRetriverTest1() {
		//CSM_TestUtility.setup();
		setup1();
		Test.startTest();
				
		CSM_IndicatorRetriever retriver = new CSM_IndicatorRetriever();
		List<CSM_IndicatiorThumbnailWrapper> wrapperList = retriver.getIndicatorWrapperList(accPlanTemplates[0].Id, accountList[0].Id);
		System.assert(wrapperList!=null);
        
		wrapperList = retriver.getIndicatorWrapperList(accPlanTemplates[0].Id, accountList[1].Id);
		System.assert(wrapperList!=null);

		wrapperList = retriver.getIndicatorWrapperList(accPlanTemplates[0].Id, accountList[2].Id);
		System.assert(wrapperList!=null);

		Test.stopTest();
	}
	
	static void setup(){
		indicatorGroupList = CSM_TestDataUtility.createIndicatorGroups();
       	indicatorList = CSM_TestDataUtility.createIndicators(indicatorGroupList[0].id,6);
		accPlanTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
		acctPlanTemplateIndicatorList = CSM_TestDataUtility.createAcctPlanIndicators(accPlanTemplates[0].id, indicatorList);
		
		
		accountList = CSM_TestDataUtility.createAccount(3);		
		
		accountList[0].Ownership = 'Private';
		accountList[0].NumberOfEmployees = 5;
		accountList[0].AnnualRevenue = 1500;
		accountList[0].CSM_Last_Health_Status__c = System.Today();
		
		accountList[1].Ownership = 'Public';
		accountList[1].NumberOfEmployees = 1006;
		accountList[1].AnnualRevenue = 100;	
		accountList[1].CSM_Last_Health_Status__c = System.Today().addDays(3);			


		accountList[2].Ownership = 'Default';
		accountList[2].NumberOfEmployees = 2500;
		accountList[2].AnnualRevenue = 2500;	
		accountList[2].CSM_Last_Health_Status__c = System.Today().addDays(7);			

			
		update accountList;	
		
		opportunityList = CSM_TestDataUtility.createOpportunity(4, accountList[0].Id);
		for (Opportunity o: opportunityList)
		{
			o.TotalOpportunityQuantity = 5;
		}
		update opportunityList;				
		accPlans = CSM_TestDataUtility.createAccountPlan(accountList, accPlanTemplates[0].Id);
		
	}
	
	static void setup1(){
		indicatorGroupList = CSM_TestDataUtility.createIndicatorGroups();
       	indicatorList = CSM_TestDataUtility.createIndicators(indicatorGroupList[0].id,7);
		accPlanTemplates = CSM_TestDataUtility.createAccountPlanTemplateData(1);
		acctPlanTemplateIndicatorList = CSM_TestDataUtility.createAcctPlanIndicators(accPlanTemplates[0].id, indicatorList);
		for(CSM_Account_Plan_Template_Indicator__c ind:acctPlanTemplateIndicatorList){
			ind.CSM_Criteria_1_To_Value__c = null;			
			ind.CSM_Criteria_2_To_Value__c = null;
			ind.CSM_Criteria_3_To_Value__c = null;						
		}
		update acctPlanTemplateIndicatorList;
		
		accountList = CSM_TestDataUtility.createAccount(3);		
		
		accountList[0].Ownership = 'Private';
		accountList[0].NumberOfEmployees = 1;
		accountList[0].AnnualRevenue = 1;
		accountList[0].CSM_Last_Health_Status__c = System.Today();
		
		accountList[1].Ownership = 'Public';
		accountList[1].NumberOfEmployees = 1001;
		accountList[1].AnnualRevenue = 1001;	
		accountList[1].CSM_Last_Health_Status__c = System.Today().addDays(3);			


		accountList[2].Ownership = 'Default';
		accountList[2].NumberOfEmployees = 2001;
		accountList[2].AnnualRevenue = 2001;	
		accountList[2].CSM_Last_Health_Status__c = System.Today().addDays(7);			

			
		update accountList;	
		
		opportunityList = CSM_TestDataUtility.createOpportunity(4, accountList[0].Id);
		for (Opportunity o: opportunityList)
		{
			o.TotalOpportunityQuantity = 5;
		}
		update opportunityList;				
		accPlans = CSM_TestDataUtility.createAccountPlan(accountList, accPlanTemplates[0].Id);
		
	}
	
}