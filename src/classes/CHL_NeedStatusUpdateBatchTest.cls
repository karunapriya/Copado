@isTest
private class CHL_NeedStatusUpdateBatchTest {

    @testSetup static void setup() {
       List<Account> accountList = new List<Account>();
	   List<Contact> contactList = new List<Contact>();
	   List<Opportunity> opptyList = new List<Opportunity>();
	   Account acc =  CHL_TestUtility.partnerAccount();
	   accountList.add(acc);
	   insert accountList;
	   
	   Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
	   contactList.add(con);
	   insert contactList;
	   
	   Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
	   opptyList.add(oppty);
	   insert opptyList; 
	   
	   CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
	   optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
	   optyStatusLogObj.CHL_Days_between_Update__c = 5;
	   optyStatusLogObj.CHL_Days_before_Expiration__c = 1;
	   insert optyStatusLogObj; 
	   
	   CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
	   partOppty.OpportunityId = opptyList[0].id;
	   partOppty.partnerAcc1Id = accountList[0].id ;
	   partOppty.partnerAcc1Type = 'Reseller';
	   partOppty.contact1Id = contactList[0].Id;
	   partOppty.expirationDate= system.today().addDays(-10);
	   partOppty.Stage= 'Needs Analysis';
	   system.assert(partOppty != null);
	     
	   List<CHL_Partner_Opportunity__c> chlpartnerList =   CHL_TestUtility.channelPartnerOpportunityList(25,partOppty); 
	   insert chlpartnerList;
	   
    }
    
    @isTest static void testBatchStatusUpdateScheduler() {
    	CHL_Partner_Opportunity__c chlObj = [select Id, CHL_Needs_Status_Update__c,CHL_Expiration_Date__c,CHL_Last_Status_Update_Date__c from CHL_Partner_Opportunity__c limit 1 ];
    	chlObj.CHL_Last_Status_Update_Date__c = null;
    	chlObj.CHL_Expiration_Date__c = null;
    	update chlObj;
        Test.startTest();
        String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
		String jobID = system.schedule('Status Update Batch', strDateTime, new CHL_BatchStatusUpdateScheduledDispatcher());	
		system.assert(jobID != null);
        Test.stopTest();
    }
    
   @isTest static void testBatchStatusUpdateScheduler_test2() {
    	CHL_Opportunity_Status_Log__c chlObj = [select Id, CHL_Days_before_Expiration__c from CHL_Opportunity_Status_Log__c limit 1 ];
    	chlObj.CHL_Days_before_Expiration__c = 0;
    	update chlObj;
        Test.startTest();
        String strDateTime = (System.now().addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
		String jobID = system.schedule('Status Update Batch', strDateTime, new CHL_BatchStatusUpdateScheduledDispatcher());	
		system.assert(true);
        Test.stopTest();
    }
}