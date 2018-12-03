/**
* @description    Test class for CHL_PartnerOpportunityBusinessLayer        
*/
@isTest
private with sharing class CHL_PartnerOpportunityBusinessLayerTest {

	@testSetup static void setup() {       
		List<Account> accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		List<Opportunity> opptyList = new List<Opportunity>();
		//List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();

		Account acc =  CHL_TestUtility.partnerAccount();
		accountList.add(acc);
		insert accountList;
		
		System.assert(accountList != null);

		Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
		Contact con2 =  CHL_TestUtility.partnerContact(accountList[0].id);
		contactList.add(con);
		contactList.add(con2);
		insert contactList;

		Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
		opptyList.add(oppty);
		insert opptyList; 

		CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
		optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
		optyStatusLogObj.CHL_Days_between_Update__c = 5;
		optyStatusLogObj.CHL_Available_Sales_Stages__c = 'Qualification,Needs Analysis;Closed Won';
		optyStatusLogObj.CHL_Show_Oppty_for_Unavailable_Stage__c = true;
		insert optyStatusLogObj; 
		
		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
	   	partOppty.OpportunityId = opptyList[0].id;
	   	partOppty.partnerAcc1Id = accountList[0].id ;
	   	partOppty.partnerAcc1Type = 'Reseller';
	   	partOppty.contact1Id = contactList[0].Id;
	   	partOppty.expirationDate= system.today().addDays(-10);
	   	partOppty.Stage= 'Qualification';
	   	system.assert(partOppty != null);
	     
	   	List<CHL_Partner_Opportunity__c> chlpartnerList =   CHL_TestUtility.channelPartnerOpportunityList(2,partOppty); 
	   	insert chlpartnerList;
	   	
	   	/*User partnerUser1 = CHL_TestUtility.createTestPartnerUser('Channel Community','con@partner.com',contactList[0].Id);
	   	insert partnerUser1;
	    User partnerUser2 = CHL_TestUtility.createTestPartnerUser('Channel Community','con2@partner.com',contactList[1].Id);
	   	insert partnerUser2;
	   	
	    String nameSpace = CSM_Util.getNamespace();
   	    String partnerObjStr = nameSpace <>''?nameSpace +''+CHL_Constants.OBJ_PT_Opportunity_Share:CHL_Constants.OBJ_PT_Opportunity_Share;       		
	    if(CHL_Util.sObjectExists(partnerObjStr))	{ 
    		sObject poSObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_PT_Opportunity_Share).newSObject();
    		poSObj.put(CHL_CONSTANTS.STR_USERGROUPID , partnerUser1.Id) ;                
            poSObj.put(CHL_CONSTANTS.STR_ROWCAUSE , CHL_CONSTANTS.STR_SHARE_REASON) ; 
            poSObj.put(CHL_CONSTANTS.STR_PARENT , chlpartnerList[0].Id) ;
            poSObj.put(CHL_CONSTANTS.STR_ACCESSLEVEL , CHL_CONSTANTS.STR_EDIT) ; 
            insert poSObj;
            sObject poSObj2 = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_PT_Opportunity_Share).newSObject();
    		poSObj2.put(CHL_CONSTANTS.STR_USERGROUPID , partnerUser2.Id) ;                
            poSObj2.put(CHL_CONSTANTS.STR_ROWCAUSE , CHL_CONSTANTS.STR_SHARE_REASON) ; 
            poSObj2.put(CHL_CONSTANTS.STR_PARENT , chlpartnerList[1].Id) ;
            poSObj2.put(CHL_CONSTANTS.STR_ACCESSLEVEL , CHL_CONSTANTS.STR_EDIT) ; 
            insert poSObj2;
		}*/
		
		opptyList = [select Id, name,Pricebook2Id from Opportunity limit 1];
		if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
	       	//To create Quote Obj.
	   		Sobject quoteObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE).newSObject() ; 
	    	quoteObj.put('Name', 'TestQ1') ; 
	    	quoteObj.put(CHL_Constants.STR_OPPOTUNITYID, opptyList[0].id) ;
	    	quoteObj.put(REN_Constants.OBJ_OPP_PRICEBOOK_ID, opptyList[0].Pricebook2Id) ;
	    	if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_PT_OPPORTUNITY)) {
	        	quoteObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_PARTNER_OPPORTUNITY, chlpartnerList[0].id) ;
	   		}
	    	if(CSM_AccessController.hasField(CHL_Constants.OBJ_QUOTE, CHL_Util.quoteExtnNameSpace + CHL_CONSTANTS.OBJ_QUOTE_PARTNER_PRIMARY)) {
	    		quoteObj.put(CHL_Util.quoteExtnNameSpace + CHL_Constants.OBJ_QUOTE_PARTNER_PRIMARY, true) ;
	    	}
	    	insert quoteObj;
	    	Sobject quotePDFObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_QUOTE_PDF).newSObject() ;
	    	quotePDFObj.put(CHL_Constants.OBJ_QUOTELI_QUOTEID,quoteObj.id);
	    	quotePDFObj.put('Document',Blob.toPDf('Test PDF content'));
		    insert quotePDFObj;
		    Attachment att = new Attachment(ParentId=quoteObj.Id,Name='Test Att', Body=Blob.toPDf('Test PDF content'));
		    insert att;
 		}
		//CSM_User_Preferences__c userPref = new CSM_User_Preferences__c(CSM_User__c=partnerUser1.id,CHL_Viewed_New_Opportunities_Date__c=system.today().addDays(-5));
		//insert userPref;
	}

	static testMethod void Opportunity_Grid_PositiveTest() {
		List<Contact> contactList = [select Id, name from contact limit 1];
		Opportunity oppty = [select Id,REN_Is_CLM_Renewal__c  from Opportunity limit 1];
		oppty.REN_Is_CLM_Renewal__c = true;
		update oppty;
		List<CHL_Partner_Opportunity__c> partnerObjList = [select Id, CHL_Partner_Account_1_Contact__c,CHL_Last_Status_Update_Date__c,CHL_FY__c,CHL_EQ__c,CHL_Sales_Stage__c,CHL_Expiration_Date__c from CHL_Partner_Opportunity__c limit 1];
		partnerObjList[0].CHL_EQ__c = 4;
		partnerObjList[0].CHL_FY__c = '2016';
		CHL_Constants.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
        CHL_Constants.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;
		update partnerObjList;
		
		Test.startTest();	
			String inputValue = '{"gridType":"CHANNEL_OPPS","queryParams":null,"query":{"name":"Predicate Query","hasLogic":false,"filters":[{"value":"","values":[{"id":"2016","name":"2016"}],"minValue":"","maxValue":"","predicate":{"type":"SELECT","objectType":"YEAR","apiName":"CHL_FY__c","isUsable":true},"operator":{"id":"IN","value":"Is in"},"index":1},{"value":"","values":[{"id":"Q4","name":"Q4"}],"minValue":"","maxValue":"","predicate":{"type":"SELECT","objectType":"QUARTER","apiName":"CHL_EQ__c","isUsable":true},"operator":{"id":"IN","value":"Is in"},"index":2},{"value":"","values":[{"id":"Qualification","name":"Qualification"}],"minValue":"","maxValue":"","predicate":{"type":"SELECT","objectType":"SALES_STAGE","apiName":"CHL_Sales_Stage__c","isUsable":true},"operator":{"id":"IN","value":"Is in"},"index":3},{"value":"2017-01-02T18:30:00.000Z","values":[],"minValue":"","maxValue":"","predicate":{"type":"DATE","objectType":"EXPIRATION_DATE","apiName":"CHL_Expiration_Date__c","isUsable":true},"operator":{"value":"is before","id":"BEFORE"},"index":4}],"logic":"1 OR 2 OR 3 OR 4"}}';
			CHL_CommunityLandingController.getResponseForGrid(inputValue);
			system.assert(inputValue != null);
			inputValue = '{"gridType":"CHANNEL_OPPS","queryParams":null,"query":{"name":"Predefined Query","hasLogic":false,"filters":[{"value":"2017-01-01T12:16:38.480Z","values":[],"minValue":"","maxValue":"","predicate":{"type":"DATE","objectType":"CREATED_AT","apiName":"","isUsable":false},"operator":{"value":"is after","id":"AFTER"},"index":1}]}}';
			CHL_CommunityLandingController.getResponseForGrid(inputValue);
			inputValue = '{"gridType":"CHANNEL_OPPS","queryParams":null,"query":{"name":"Predefined Query","hasLogic":false,"filters":[{"value":"YES","values":[],"minValue":"","maxValue":"","predicate":{"type":"BOOLEAN","objectType":"NEEDS_UPDATE","apiName":"CHL_Needs_Status_Update__c","isUsable":true},"operator":{"id":"EQUALS","value":"Is equal to"},"index":1}]}}';
			CHL_CommunityLandingController.getResponseForGrid(inputValue);
			inputValue = '{"gridType":"CHANNEL_OPPS","queryParams":null,"query":{"name":"Predefined Query","hasLogic":false,"filters":[{"value":"YES","values":[],"minValue":"","maxValue":"","predicate":{"type":"BOOLEAN","objectType":"NEEDS_UPDATE","apiName":"CHL_Needs_Status_Update__c","isUsable":true},"operator":{"id":"EQUALS","value":"Is equal to"},"index":1},{"value":"","values":[{"id":"Q4","name":"Q4"}],"minValue":"","maxValue":"","predicate":{"type":"SELECT","objectType":"QUARTER","apiName":"CHL_EQ__c","isUsable":true},"operator":{"id":"IN","value":"Is in"},"index":2},{"value":"","values":[{"id":"2016","name":"2016"}],"minValue":"","maxValue":"","predicate":{"type":"SELECT","objectType":"YEAR","apiName":"CHL_FY__c","isUsable":true},"operator":{"id":"IN","value":"Is in"},"index":3},{"value":"","values":[{"id":"USA","name":"USA"}],"minValue":"","maxValue":"","predicate":{"type":"SELECT","objectType":"COUNTRY","isUsable":false,"apiName":""},"operator":{"id":"IN","value":"Is in"},"index":4},{"value":"","values":[{"id":"Prospecting","name":"Prospecting"}],"minValue":"","maxValue":"","predicate":{"type":"SELECT","objectType":"SALES_STAGE","apiName":"CHL_Sales_Stage__c","isUsable":true},"operator":{"id":"IN","value":"Is in"},"index":5}]}}';
			CHL_CommunityLandingController.getResponseForGrid(inputValue);
			inputValue = '{"gridType":"CHANNEL_OPPS","queryParams":null,"query":{"name":"Date Query","hasLogic":false,"filters":[{"value":"","values":[],"minValue":"2016-11-30T18:30:00.000Z","maxValue":"2017-01-30T18:30:00.000Z","predicate":{"type":"DATE","objectType":"CLOSE_DATE","apiName":"CHL_Close_Date__c","isUsable":true},"operator":{"value":"is between","id":"BETWEEN"},"index":1}]}}';
			CHL_CommunityLandingController.getResponseForGrid(inputValue);
			inputValue = '{"gridType":"CHANNEL_OPPS","queryParams":null,"query":{"name":"Quote Query","hasLogic":false,"filters":[{"value":"YES","values":[],"minValue":"","maxValue":"","predicate":{"type":"BOOLEAN","objectType":"HAS_QUOTE","apiName":"","isUsable":true},"operator":{"id":"EQUALS","value":"Is equal to"},"index":1}]}}';
			CHL_CommunityLandingController.getResponseForGrid(inputValue);
			inputValue = '{"gridType":"CHANNEL_OPPS","queryParams":null,"query":{"name":"","hasLogic":false,"filters":[{"value":"4","values":[],"minValue":"","maxValue":"","predicate":{"type":"NUMBER","objectType":"","apiName":"CHL_EQ__c","isUsable":true},"operator":{"id":"EQUALS","value":"Is equal to"},"index":1}]}}';
			CHL_CommunityLandingController.getResponseForGrid(inputValue);
			CHL_Opportunity_Status_Log__c opsl = [select Id, CHL_Enable_2_Tier_Pricing__c from CHL_Opportunity_Status_Log__c limit 1];
			opsl.CHL_Enable_2_Tier_Pricing__c = true;
			update opsl;
			inputValue = '{"gridType":"CHANNEL_OPPS","queryParams":null,"query":{"name":"Quote Query","hasLogic":false,"filters":[{"value":"NO","values":[],"minValue":"","maxValue":"","predicate":{"type":"BOOLEAN","objectType":"HAS_QUOTE","apiName":"","isUsable":true},"operator":{"id":"EQUALS","value":"Is equal to"},"index":1},{"value":"","values":[{"id":"001j000000xsvE2AAI","name":"test"}],"minValue":"","maxValue":"","predicate":{"type":"SELECT","objectType":"ACCOUNT","apiName":"CHL_Opportunity_Account_Name__c","isUsable":true},"operator":{"id":"IN","value":"Is in"},"index":2}]}}';
			CHL_CommunityLandingController.getResponseForGrid(inputValue);
		Test.stopTest();
	}
	
	
	
	/*static testMethod void Opportunity_Grid_NegativeTest() {
		User CSMUser = CSM_TestDataUtility.createTestUser('CSM');
		Test.startTest();	
		system.runas(CSMUser){
			try {
				CHL_GridInputWrapper inputWrapper = new CHL_GridInputWrapper();
				CHL_GridInputWrapper.CHL_CustomGridParams gridParams = new CHL_GridInputWrapper.CHL_CustomGridParams();			
				gridParams.currentQuarter = 'Q4';
				gridParams.oppsType = 'NEW';
				inputWrapper.queryParams = gridParams;
				CHL_PartnerOpportunityBusinessLayer pobl = new CHL_PartnerOpportunityBusinessLayer(inputWrapper);
				CHL_AngularResponeWrapper wrp = new CHL_AngularResponeWrapper();
				wrp = pobl.constructGridWrapper(); 
			}
			catch  (Exception ex) {
	 			system.assert(true);
	 		}
		}
		Test.stopTest();
	}*/
	
	static testMethod void Opportunity_Details_Test() {
		CHL_Partner_Opportunity__c partnerObj = [select Id, CHL_Partner_Account_1_Contact__c,CHL_Last_Status_Update_Date__c from CHL_Partner_Opportunity__c limit 1];
		Test.startTest();
		String inputValue = '{"oppId":"'+partnerObj.Id+'"}';
		//CHL_GridInputWrapper inputWrapper = new CHL_GridInputWrapper();
		//CHL_PartnerOpportunityBusinessLayer pobl = new CHL_PartnerOpportunityBusinessLayer(inputWrapper);
		Object wrp = CHL_PartnerOpportunityBusinessLayer.getOpportunityDetails(inputValue);
		System.assert(inputValue != null);
		Test.stopTest();
	}
}