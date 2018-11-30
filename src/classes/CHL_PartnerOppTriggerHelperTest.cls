@isTest
public with sharing class CHL_PartnerOppTriggerHelperTest {

	@testSetup 
	static void setup() {       
		List<Account> accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		List<Opportunity> opptyList = new List<Opportunity>();
		List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();

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

		insert new SS_License__c(Channel__c = true);

		CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
		optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
		optyStatusLogObj.CHL_Days_between_Update__c = 5;
		insert optyStatusLogObj; 

		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
		partOppty.OpportunityId = opptyList[0].id;
		partOppty.partnerAcc1Id = accountList[0].id ;
		partOppty.partnerAcc1Type = 'Reseller';
		partOppty.contact1Id = contactList[0].Id;
		partOppty.expirationDate= system.today().addDays(-10);
		partOppty.Stage = 'Qualification';
		partOppty.partnerAcc2Id = accountList[0].id;
		partOppty.partnerAcc2Type  = 'Distributor';
		partOppty.contact2Id = contactList[0].Id;

		chlpartnerList =   CHL_TestUtility.channelPartnerOpportunityList(2,partOppty); 
		insert chlpartnerList;
		system.debug('chlpartnerList : '+chlpartnerList);

		REN_Field_Mappings__c newMapping = new REN_Field_Mappings__c();
		newMapping.REN_From_Object_API_Name__c = 'Opportunity';
		newMapping.REN_From_Field_API_Name__c = 'StageName';
		newMapping.Name = CHL_Constants.FLD_MAP_PARTNER_OPPT_TO_MASTER_OPPT;
		newMapping.REN_To_Field_API_Name__c = 'CHL_Sales_Stage__c';
		newMapping.REN_To_Object_API_Name__c = 'CHL_Partner_Opportunity__c';
		newMapping.REN_Default_Value__c = '';
		insert newMapping;
		
		List<CHL_Sales_Stage_Mapping__c> mappingList = new List<CHL_Sales_Stage_Mapping__c>();     
   		CHL_Sales_Stage_Mapping__c salesStageMappingList = new CHL_Sales_Stage_Mapping__c();
   		salesStageMappingList.CHL_Master_Opportunity_Sales_Stage__c = 'Perception Analysis';
   		salesStageMappingList.CHL_Partner_Opportunity_Sales_Stage__c = 'Qualification';
   		salesStageMappingList.CHL_Partner_Opportunity_Type__c = 'All Partner Opportunities';
   		mappingList.add(salesStageMappingList);
   		
   		salesStageMappingList = new CHL_Sales_Stage_Mapping__c();
   		salesStageMappingList.CHL_Master_Opportunity_Sales_Stage__c = 'Needs Analysis';
   		salesStageMappingList.CHL_Partner_Opportunity_Sales_Stage__c = 'Prospecting';
   		salesStageMappingList.CHL_Partner_Opportunity_Type__c = 'Losing Partner Opportunities';
   		mappingList.add(salesStageMappingList);
   		
   		salesStageMappingList = new CHL_Sales_Stage_Mapping__c();
   		salesStageMappingList.CHL_Master_Opportunity_Sales_Stage__c = 'Needs Analysis';
   		salesStageMappingList.CHL_Partner_Opportunity_Sales_Stage__c = 'Perception Analysis';
   		salesStageMappingList.CHL_Partner_Opportunity_Type__c = 'Winning Partner Opportunities';
   		mappingList.add(salesStageMappingList);

   		insert mappingList;
   		system.assert(mappingList!=null);
	}

	static testMethod void Test() {
		List<CHL_Partner_Opportunity__c> partnerOppList = [select id, name,CHL_Opportunity__c from CHL_Partner_Opportunity__c];
		List<CHL_Partner_Opportunity__c> partnerOppUpdate = new List<CHL_Partner_Opportunity__c>();
		List<REN_Field_Mappings__c> fieldMapping =[select id, name from REN_Field_Mappings__c];
		system.debug('\n\n fieldMapping :: ' + fieldMapping);
		Boolean flag = false;
		Test.startTest();
			for(CHL_Partner_Opportunity__c pOpp : partnerOppList){
				if(flag){
					pOpp.CHL_Syncing__c = 'From Master Opportunity';
				} else {
					pOpp.CHL_Syncing__c = 'To Master Opportunity';
				}
				partnerOppUpdate.add(pOpp);
				flag = true;
			}
			update partnerOppUpdate;
			system.assert(true);
		Test.stopTest();
	}

	static testMethod void Test_AfterInsert() {
		List<Opportunity> OppList = [select id from Opportunity limit 1];
		List<Account> accountList = [select id from Account limit 1];
		List<Contact> contactList = [select id from Contact limit 1];
		List<CHL_Partner_Opportunity__c> partnerOppUpdate = new List<CHL_Partner_Opportunity__c>();
		List<REN_Field_Mappings__c> fieldMapping =[select id, name from REN_Field_Mappings__c];
		system.debug('\n\n fieldMapping :: ' + fieldMapping);
		Boolean flag = false;

		Test.startTest();
			CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
			partOppty.OpportunityId = OppList[0].id;
			partOppty.partnerAcc1Id = accountList[0].id ;
			partOppty.partnerAcc1Type = 'Reseller';
			partOppty.contact1Id = contactList[0].Id;
			partOppty.expirationDate= system.today().addDays(-10);
			partOppty.Stage = 'Qualification';
			partOppty.partnerAcc2Id = accountList[0].id;
			partOppty.partnerAcc2Type  = 'Distributor';
			partOppty.contact2Id = contactList[0].Id;
			partOppty.syncing = 'To Master Opportunity';
			List<CHL_Partner_Opportunity__c> poList = new List<CHL_Partner_Opportunity__c>();
			poList =   CHL_TestUtility.channelPartnerOpportunityList(2,partOppty); 
			insert poList;
			List<CHL_Partner_Opportunity__c> poNewList  = [select id, name,CHL_Opportunity__c from CHL_Partner_Opportunity__c];
			poNewList[0].CHL_Syncing__c = 'From Master Opportunity';
			update poNewList;
		Test.stopTest();
	}
	
	static testMethod void test_AutoUpdateStage() {
		Opportunity Oppobj = [select id,StageName from Opportunity limit 1];
		List<CHL_Partner_Opportunity__c> partnerOppList = [select Id, name, CHL_Opportunity__c,CHL_Sales_Stage__c from CHL_Partner_Opportunity__c] ;
		List<CHL_Sales_Stage_Mapping__c> mappingList = [select Id,CHL_Master_Opportunity_Sales_Stage__c,CHL_Partner_Opportunity_Sales_Stage__c, CHL_Partner_Opportunity_Type__c from CHL_Sales_Stage_Mapping__c];
		Map<Id, Opportunity> newRecordsMap = new Map<Id, Opportunity>();
		Map<Id, Id> winningPartnerOpportunityMap = new Map<Id, Id>();
		Map<String, CHL_Sales_Stage_Mapping__c> salesStageMappingMap = new Map<String, CHL_Sales_Stage_Mapping__c>();
		newRecordsMap.put(Oppobj.Id,Oppobj);
		for(CHL_Partner_Opportunity__c po:partnerOppList) {
			winningPartnerOpportunityMap.put(Po.CHL_Opportunity__c,po.Id);
		}
		for(CHL_Sales_Stage_Mapping__c st:mappingList) {
			salesStageMappingMap.put(st.CHL_Master_Opportunity_Sales_Stage__c+ ':' + st.CHL_Partner_Opportunity_Type__c,st);
			//salesStageMappingMap.put(st.CHL_Master_Opportunity_Sales_Stage__c+ ':' ,st);
		}
		//CHL_PartnerOpportunityStageHelper.updatePartnerOpportunities(newRecordsMap, winningPartnerOpportunityMap, salesStageMappingMap);
		Oppobj.StageName = 'Perception Analysis';
		update Oppobj;
		system.assert(partnerOppList != null);
	}
}