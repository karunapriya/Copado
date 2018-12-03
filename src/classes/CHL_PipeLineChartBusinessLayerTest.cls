@isTest
private class CHL_PipeLineChartBusinessLayerTest {

	@testSetup static void setup() {   
	   List<Account> accountList = new List<Account>();
	   List<Contact> contactList = new List<Contact>();
	   List<Opportunity> opptyList = new List<Opportunity>();
       
	   Account acc =  CHL_TestUtility.partnerAccount();
	   accountList.add(acc);
	   insert accountList;
	   System.assert(accountList != null);
	   Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
	   contactList.add(con);
	   insert contactList;
	   
	   Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
	   opptyList.add(oppty);
	   insert opptyList; 
	   
	   CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
	   optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
	   optyStatusLogObj.CHL_Days_between_Update__c = 5;
	   optyStatusLogObj.CHL_Available_Sales_Stages__c = 'Needs Analysis;Closed Won';
	   optyStatusLogObj.CHL_Display_Pipeline_Sales_Stages__c = 'Needs Analysis;Closed Won';
	   optyStatusLogObj.CHL_Show_Oppty_for_Unavailable_Stage__c = true;
	   insert optyStatusLogObj; 
	   
	   CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
	   partOppty.OpportunityId = opptyList[0].id;
	   partOppty.partnerAcc1Id = accountList[0].id ;
	   partOppty.partnerAcc1Type = 'Reseller';
	   partOppty.contact1Id = contactList[0].Id;
	   partOppty.partnerAcc2Id =  accountList[0].id;
	   partOppty.partnerAcc2Type = 'Distributor';
	   partOppty.contact2Id = contactList[0].Id;
	   partOppty.expirationDate= system.today().addDays(-10);
	   partOppty.Stage= 'Needs Analysis'; 
	   
	   List<CHL_Partner_Opportunity__c> chlpartnerList =   CHL_TestUtility.channelPartnerOpportunityList(2,partOppty); 
	   insert chlpartnerList;
	   
	   CHL_TestUtility.WrapperPartnerOpportunity partOpptyWithUpdates = new CHL_TestUtility.WrapperPartnerOpportunity();
	   partOpptyWithUpdates.OpportunityId = opptyList[0].id;
	   partOpptyWithUpdates.partnerAcc1Id = accountList[0].id ;
	   partOpptyWithUpdates.partnerAcc1Type = 'Reseller';
	   partOpptyWithUpdates.contact1Id = contactList[0].Id;
	   partOpptyWithUpdates.partnerAcc2Id =  accountList[0].id;
	   partOpptyWithUpdates.partnerAcc2Type = 'Distributor';
	   partOpptyWithUpdates.contact2Id = contactList[0].Id;
	   partOpptyWithUpdates.expirationDate= system.today().addDays(-10);
	   partOpptyWithUpdates.Stage= 'Needs Analysis'; 
	   partOpptyWithUpdates.statusUpdate = true;
	   
	   List<CHL_Partner_Opportunity__c> chlpartnerWithUpdateList =   CHL_TestUtility.channelPartnerOpportunityList(2,partOpptyWithUpdates); 
	   insert chlpartnerWithUpdateList;
    }

    static testMethod void ChartFilterTest() {
    	Set < String > resellerRepSet = new Set < String > ();
		resellerRepSet.add('003j000000SoBaSAAV');
	   	resellerRepSet.add('003j000000SoBaSAAV');
		Set < String > quarterSet = new Set < String > ();
		quarterSet.add('Q2');
		Set < String > distributerRepSet = new Set < String > ();
		distributerRepSet.add('003j000000SoBaSAAV');
		Set < String > countrySet = new Set < String > ();
		countrySet.add('India');
		countrySet.add('US');
       
       Test.startTest();
	       CHL_GridInputWrapper inputWrapper = new  CHL_GridInputWrapper();
		   CHL_GridInputWrapper.CHL_CustomGridParams gridWrapparObj = new CHL_GridInputWrapper.CHL_CustomGridParams();
	       gridWrapparObj.resellerReps = resellerRepSet;
		   gridWrapparObj.distributorReps = distributerRepSet;
		   gridWrapparObj.countries = countrySet;
		   gridWrapparObj.quarters = quarterSet;
		   inputWrapper.queryParams = gridWrapparObj;
		   System.assertNotEquals(gridWrapparObj,null);
	       CHL_PipeLineChartBusinessLayer pipeLineObj = new  CHL_PipeLineChartBusinessLayer(inputWrapper);
	       pipeLineObj.constructChartWrapper();
       Test.stopTest();
    }
    
     static testMethod void ChartWithAllFilterTest() {
     	Set<String> resellerRepSet = new Set<String>();
     	resellerRepSet.add('All');
	    Set<String> quarterSet = new Set<String>();    
		CHL_CurrentQuarter currentQtr = CHL_Util.getCurrentQuarter();
		quarterSet.add(currentQtr.id);
    
    	Set<String> yearSet = new Set<String>();
		CHL_CurrentYear currentYearObj = CHL_Util.getCurrentYear();
		yearSet.add(currentYearObj.Id);
    	
		Set<String> distributerRepSet = new Set<String>();
		distributerRepSet.add('All');
		Set<String> countrySet = new Set<String>();
		countrySet.add('All');
		
	   Test.startTest();
	   		CHL_CurrentQuarter currentQtrObj = CHL_Util.getCurrentQuarter();
	   		String str = currentQtrObj.id;
	   		String currentQtrValue = str.remove('Q');
	   
	   		CHL_CurrentYear currentyear = CHL_Util.getCurrentYear();
	   		String curryear = currentyear.id;
	   
	   		List<CHL_Partner_Opportunity__c> chlpartnerList  = [select CHL_EQ__c,CHL_FY__c,CHL_Amount__c,CHL_Sales_Stage__c from CHL_Partner_Opportunity__c ];
	   		chlpartnerList[0].CHL_EQ__c = Integer.valueof(currentQtrValue.trim());
	   		chlpartnerList[0].CHL_FY__c = curryear;
	   		chlpartnerList[0].CHL_Amount__c = 1000;
	   		chlpartnerList[0].CHL_Needs_Status_Update__c = true;
	   		chlpartnerList[1].CHL_EQ__c =Integer.valueof(currentQtrValue.trim());
	   		chlpartnerList[1].CHL_FY__c = curryear;
	   		chlpartnerList[1].CHL_Amount__c = 1000;
	   		chlpartnerList[1].CHL_Needs_Status_Update__c = false;
			update chlpartnerList;
	   
			CHL_GridInputWrapper inputWrapper = new  CHL_GridInputWrapper();
			CHL_GridInputWrapper.CHL_CustomGridParams gridWrapparObj = new CHL_GridInputWrapper.CHL_CustomGridParams();	       
			gridWrapparObj.resellerReps = resellerRepSet;
			gridWrapparObj.distributorReps = distributerRepSet;
			gridWrapparObj.countries = countrySet;
			gridWrapparObj.quarters = quarterSet;
			gridWrapparObj.years = yearSet;
			inputWrapper.queryParams = gridWrapparObj;
		   
			System.assertNotEquals(gridWrapparObj,null);
			CHL_PipeLineChartBusinessLayer pipeLineObj = new  CHL_PipeLineChartBusinessLayer(inputWrapper);
			pipeLineObj.constructChartWrapper();
       Test.stopTest();
     }
   
}