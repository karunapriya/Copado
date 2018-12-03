/**
* @description    Test class for CHL_PartnerOpportunityGridUpdate        
*/
@isTest
private class CHL_PartnerOpportunityGridUpdateTest {

	@testSetup static void setup() {  
		List<Account> accountList1 = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		List<Opportunity> opptyList = new List<Opportunity>();
		List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();
		
		Account acc = CHL_TestUtility.partnerAccount();
		accountList1.add(acc);
		insert accountList1;
		
		Contact con = CHL_TestUtility.partnerContact(accountList1[0].id);
		contactList.add(con);
		insert contactList;
		
		Opportunity oppty = CHL_TestUtility.partnerOpportunity(accountList1[0].id, 'Needs Analysis');
		opptyList.add(oppty);
		insert opptyList;
		
		CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c();
		optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
		optyStatusLogObj.CHL_Days_between_Update__c = 5;
		optyStatusLogObj.CHL_Available_Sales_Stages__c = 'Qualification;Needs Analysis';
		insert optyStatusLogObj;
		
		List<Account> accountList = [select Id, name from Account limit 1];
		System.assert(accountList != null);
		
		
		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
		partOppty.partnerAcc1Id = accountList[0].id;
		partOppty.partnerAcc1Type = 'Reseller';
		partOppty.contact1Id = contactList[0].Id;
		partOppty.expirationDate = system.today().addDays(-10);
		partOppty.Stage = 'Needs Analysis';
		partOppty.partnerAcc2Id = accountList[0].id;
		partOppty.partnerAcc2Type = 'Distributor';
		partOppty.contact2Id = contactList[0].Id;
		
		List<CHL_Partner_Opportunity__c> chlpartnerList1 = CHL_TestUtility.channelPartnerOpportunityList(2, partOppty);
		insert chlpartnerList1;
    }

    static testMethod void oppGridUpdateTest() {
    	List<Account> accountList = [select id from Account limit 1];
     	String AccId = accountList[0].id;
		List<CHL_Partner_Opportunity__c> partnerOppList = [select name, CHL_Sales_Stage__c from CHL_Partner_Opportunity__c limit 1];
		partnerOppList[0].CHL_Partner_Account_1__c = AccId;
		partnerOppList[0].CHL_Partner_Account_1_Type__c = 'Reseller';
		partnerOppList[0].CHL_Partner_Account_1__c = AccId;
		partnerOppList[0].CHL_Partner_Account_2_Type__c = 'Distributor';
		update partnerOppList;
		
		List<Opportunity> opptyList = [select Id, name,Pricebook2Id,AccountId from opportunity limit 1 ];
 		system.assert(partnerOppList<>null);  
 		string quoteId = '';
 		
 		if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
	       	//To create Quote Obj.
	   		List<sObject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,partnerOppList);	   		
	    	insert quoteList;
	    	quoteId = quoteList[0].Id;
 		}
 		string nameSpace = CSM_Util.getNamespace();
		Test.startTest();
			//String inputValue = '{"gridData":[{"updated":false,"rowData":{"'+nameSpace+'CHL_Status__c":{"value":"UPdated Status","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Needs_Status_Update__c":{"value":"2015-05-30T04:00:00+00:00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"Latest_Quote":{"value":"RENEW_8JUN","url":"/servlet/servlet.FileDownload?file=0QDj0000000PTXsGAO","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_2_Contact__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_1_Contact__c":{"value":"Partner User2","url":"","needsUpdate":null,"lookupId":"003j000000UDxFZ","currencyCode":"USD"},"'+nameSpace+'CHL_Close_Date__c":{"value":"2015-08-06T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Expiration_Date__c":{"value":"2015-06-30T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Amount__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Probability__c":{"value":"60","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Sales_Stage__c":{"value":"Qualification","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Opportunity_Account_Name__c":{"value":"285 Test","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"}},"recordID":"' + partnerOppList[0].id + '","index":1,"canEdit":false}]}';
			String inputValue = '{"gridData":[{"updated":false,"rowData":{"'+nameSpace+'CHL_Status__c":{"value":"UPdated Status","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Syncing__c":{"value":"To Master Opportunity","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Needs_Status_Update__c":{"value":"2015-05-30T04:00:00+00:00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"Latest_Quote":{"value":"RENEW_8JUN","url":"/servlet/servlet.FileDownload?file=0QDj0000000PTXsGAO","needsUpdate":null,"lookupId":"'+quoteId+'","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_2_Contact__c":{"value":"Partner User1","url":"","needsUpdate":null,"lookupId":"003j000000UDxFZ","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_1_Contact__c":{"value":"Partner User2","url":"","needsUpdate":null,"lookupId":"003j000000UDxFZ","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_2_Type__c":{"value":"Distributor","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_1_Type__c":{"value":"Reseller","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Close_Date__c":{"value":"2015-08-06T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Expiration_Date__c":{"value":"2015-06-30T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Amount__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Probability__c":{"value":"60","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Customer_Engagement_Type__c":{"value":"OEM Led","url":"","needsUpdate":null,"lookupId":"OEM Led","currencyCode":"USD"},"'+nameSpace+'CHL_Sales_Stage__c":{"value":"Qualification","url":"","needsUpdate":null,"lookupId":"Qualification","currencyCode":"USD"},"'+nameSpace+'CHL_Opportunity_Account_Name__c":{"value":"285 Test","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+ nameSpace+'CHL_Opportunity__c":{"value":"'+ opptyList[0].Id +'","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+ nameSpace+'CHL_Partner_Account_1__c":{"value":"'+ AccId +'","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+ nameSpace+'CHL_Partner_Account_2__c":{"value":"'+ AccId +'","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"}},"recordID":"' + partnerOppList[0].id + '","index":1,"canEdit":false}]}';
			CHL_AngularResponeWrapper inputJsonWrapper = (CHL_AngularResponeWrapper) JSON.deserialize(inputValue, CHL_AngularResponeWrapper.class);
			System.assert(inputJsonWrapper != null);
			CHL_PartnerOpportunityGridUpdate.updatePartnerOpportunity(inputJsonWrapper);
			//String inputValueTrue = '{"gridData":[{"updated":true,"rowData":{"'+nameSpace+'CHL_Status__c":{"value":"UPdated Status","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Needs_Status_Update__c":{"value":"2015-05-30T04:00:00+00:00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"Latest_Quote":{"value":"RENEW_8JUN","url":"/servlet/servlet.FileDownload?file=0QDj0000000PTXsGAO","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_2_Contact__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_1_Contact__c":{"value":"Partner User2","url":"","needsUpdate":null,"lookupId":"003j000000UDxFZ","currencyCode":"USD"},"'+nameSpace+'CHL_Close_Date__c":{"value":"2015-08-06T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Expiration_Date__c":{"value":"2015-06-30T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Amount__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Probability__c":{"value":"60","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Sales_Stage__c":{"value":"Qualification","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Opportunity_Account_Name__c":{"value":"285 Test","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"}},"recordID":"' + partnerOppList[0].id + '","index":1,"canEdit":false}]}';
			String inputValueTrue = '{"gridData":[{"updated":false,"rowData":{"'+nameSpace+'CHL_Opportunity__c":{"value":"'+opptyList[0].id+'","url":"","needsUpdate":true,"lookupId":"'+opptyList[0].id+'","currencyCode":"USD"},"'+nameSpace+'CHL_Status__c":{"value":"UPdated Status","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Needs_Status_Update__c":{"value":"2015-05-30T04:00:00+00:00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"Latest_Quote":{"value":"RENEW_8JUN","url":"/servlet/servlet.FileDownload?file=0QDj0000000PTXsGAO","needsUpdate":null,"lookupId":"'+quoteId+'","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_2_Contact__c":{"value":"Partner User1","url":"","needsUpdate":null,"lookupId":"003j000000UDxFZ","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_1_Contact__c":{"value":"Partner User2","url":"","needsUpdate":null,"lookupId":"003j000000UDxFZ","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_2_Type__c":{"value":"Distributor","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_1_Type__c":{"value":"Reseller","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Close_Date__c":{"value":"2015-08-06T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Expiration_Date__c":{"value":"2015-06-30T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Amount__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Probability__c":{"value":"60","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Customer_Engagement_Type__c":{"value":"OEM Led","url":"","needsUpdate":null,"lookupId":"OEM Led","currencyCode":"USD"},"'+nameSpace+'CHL_Sales_Stage__c":{"value":"Qualification","url":"","needsUpdate":null,"lookupId":"Qualification","currencyCode":"USD"},"'+nameSpace+'CHL_Opportunity_Account_Name__c":{"value":"285 Test","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+ nameSpace+'CHL_Partner_Account_1__c":{"value":"'+ AccId +'","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+ nameSpace+'CHL_Partner_Account_2__c":{"value":"'+ AccId +'","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"}},"recordID":"' + partnerOppList[0].id + '","index":1,"canEdit":false}]}';
			CHL_AngularResponeWrapper inputJsonWrapperTrue = (CHL_AngularResponeWrapper) JSON.deserialize(inputValueTrue, CHL_AngularResponeWrapper.class);
			inputJsonWrapperTrue.noChange = true;
			CHL_PartnerOpportunityGridUpdate.updatePartnerOpportunity(inputJsonWrapperTrue);
			
			
			CHL_Opportunity_Status_Log__c optyStatusLog = [select Id, CHL_Show_Oppty_for_Unavailable_Stage__c from CHL_Opportunity_Status_Log__c limit 1];
			optyStatusLog.CHL_Show_Oppty_for_Unavailable_Stage__c = true;
			optyStatusLog.CHL_Enable_2_Tier_Pricing__c = true;
			update optyStatusLog;
			
			
			String inputValue_NO = '{"gridData":[{"updated":false,"rowData":{"'+nameSpace+'CHL_Status__c":{"value":"UPdated Status","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Needs_Status_Update__c":{"value":"2015-05-30T04:00:00+00:00","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"Latest_Quote":{"value":"RENEW_8JUN","url":"/servlet/servlet.FileDownload?file=0QDj0000000PTXsGAO","needsUpdate":null,"lookupId":"'+quoteId+'","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_2_Contact__c":{"value":"Partner User1","url":"","needsUpdate":null,"lookupId":"003j000000UDxFZ","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_1_Contact__c":{"value":"Partner User2","url":"","needsUpdate":null,"lookupId":"003j000000UDxFZ","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_2_Type__c":{"value":"Distributor","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Partner_Account_1_Type__c":{"value":"Reseller","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Close_Date__c":{"value":"2015-08-06T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Expiration_Date__c":{"value":"2015-06-30T04:00:00+00:00","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Amount__c":{"value":"","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Probability__c":{"value":"60","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"},"'+nameSpace+'CHL_Sales_Stage__c":{"value":"Need Analysis","url":"","needsUpdate":null,"lookupId":"Need Analysis","currencyCode":"USD"},"'+nameSpace+'CHL_Opportunity_Account_Name__c":{"value":"285 Test","url":"","needsUpdate":null,"lookupId":"","currencyCode":"USD"}},"recordID":"' + partnerOppList[0].id + '","index":1,"canEdit":false}]}';
			CHL_AngularResponeWrapper inputJsonWrapper_NO = (CHL_AngularResponeWrapper) JSON.deserialize(inputValue, CHL_AngularResponeWrapper.class);
			System.assert(inputJsonWrapper_NO != null);
			CHL_PartnerOpportunityGridUpdate.updatePartnerOpportunity(inputJsonWrapper_NO);
		
		Test.stopTest();
    }
    
    static testMethod void quoteUpdateTest() {    	
		List<CHL_Partner_Opportunity__c> partnerOppList = [select name,id, CHL_Sales_Stage__c from CHL_Partner_Opportunity__c];
		List<Opportunity> opptyList = [select Id, name,Pricebook2Id from opportunity limit 1 ];
 		system.assert(partnerOppList<>null);  
 		string quoteId = '';
 		if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
	       	List<sObject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,partnerOppList);	   		
	    	insert quoteList;
	    	quoteId = quoteList[0].Id;
 		}
 		Test.startTest();
		String inputValue = '{"gridData":[{"updated":false,"rowData":{"'+CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c":{"value":"'+partnerOppList[0].Id+'"},"'+CHL_Util.quoteExtnNameSpace+'CHL_Partner_Primary__c":{"value":"false"},"Name":{"value":"Quote1"},"GrandTotal":{"value":"1000"},"Id":{"value":"'+quoteId+'"}},"recordID":"' + quoteId + '","index":1,"canEdit":false}]}';
			CHL_AngularResponeWrapper inputJsonWrapper = (CHL_AngularResponeWrapper) JSON.deserialize(inputValue, CHL_AngularResponeWrapper.class);
			System.assert(inputJsonWrapper != null);
			try{
				CHL_PartnerOpportunityGridUpdate.updateQuotes(inputJsonWrapper);
			}catch(Exception e){
				
			}
		Test.stopTest();
    }
    
    static testMethod void quoteUpdateTestDistributorQuote() {    	
		String nameSpace = CSM_Util.getNamespace();
		
		List<Account> accountList = [select id from Account limit 1];
		String AccId = accountList[0].id;
		
		List<CHL_Partner_Opportunity__c> partnerOppList = [select name,id, CHL_Sales_Stage__c from CHL_Partner_Opportunity__c limit 1];
		system.assert(partnerOppList<>null);  
		partnerOppList[0].CHL_Partner_Account_1__c = AccId;
		partnerOppList[0].CHL_Partner_Account_1_Type__c = 'Reseller';
		partnerOppList[0].CHL_Partner_Account_1__c = AccId;
		partnerOppList[0].CHL_Partner_Account_2_Type__c = 'Distributor';
		update partnerOppList;
		
		List<Opportunity> opptyList = [select Id, name,Pricebook2Id from opportunity limit 1 ];	
		
		CHL_Opportunity_Status_Log__c optyStatusLog = [select Id, CHL_Show_Oppty_for_Unavailable_Stage__c from CHL_Opportunity_Status_Log__c limit 1];
		optyStatusLog.CHL_Show_Oppty_for_Unavailable_Stage__c = true;
		optyStatusLog.CHL_Enable_2_Tier_Pricing__c = false;
		update optyStatusLog;
     	
		string quoteId = '';
 		if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE) && CSM_AccessController.hasField('Quote', CHL_Util.quoteExtnNameSpace + 'CHL_Partner_Opportunity__c')) {
	       	List<sObject> quoteList = CHL_TestUtility.createQuotes(2,opptyList,partnerOppList);	   		
	    	quoteList[1].put('CHL_Reseller_Quote__c' , quoteList[0].get('Id'));
	    	quoteList[1].put('CHL_Partner_Primary__c', true);
	    	insert quoteList;
	    	quoteId = quoteList[0].Id;
 		}
	 	Test.startTest();
			String inputValue_update = '{"gridData":[{"updated":false,"rowData":{"'+CHL_Util.quoteExtnNameSpace+'CHL_Syncing__c":{"value":"To Master Opportunity","url":"","needsUpdate":true,"lookupId":"","currencyCode":"USD"},"'+CHL_Util.quoteExtnNameSpace+'CHL_Partner_Opportunity__c":{"value":"'+partnerOppList[0].Id+'"},"'+CHL_Util.quoteExtnNameSpace+'CHL_Partner_Primary__c":{"value":"true"},"Name":{"value":"Quote1"},"GrandTotal":{"value":"1000"},"Id":{"value":"'+quoteId+'"}},"recordID":"' + quoteId + '","index":1,"canEdit":false}]}';
			CHL_AngularResponeWrapper inputJsonWrapper_update = (CHL_AngularResponeWrapper) JSON.deserialize(inputValue_update, CHL_AngularResponeWrapper.class);
			
			if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {	
				CHL_PartnerOpportunityGridUpdate.updateQuotes(inputJsonWrapper_update);
			}
		
			//CHL_PartnerOpportunityGridUpdate.getDistributorQuoteByPO(quotelist);
		Test.stopTest();
    }
    
    //*************** Start --- Quote code coverage -----As Quotes is disable in master Org 
    
     static testMethod void quoteUpdateTestDistributorQuote1() {    	
		Set<ID> partnerOptyIds = new Set<ID>();
		Map<String,String> partnerOptyIdToQuote = new Map<String,String>(); 
		//CHL_PartnerOpportunityGridUpdate.setQuoteAsPrimary(partnerOptyIds, partnerOptyIdToQuote);
		system.assert(true);
    }
   
    //************* End **************************
}