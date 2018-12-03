@isTest
public class CHL_ManageSplitConsolidatePRRTest {
	@testSetup static void setup() { 
		List<Account> accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		
		Account acc1 =  CHL_TestUtility.partnerAccount();
		Account acc2 =  CHL_TestUtility.partnerAccount();
		accountList.add(acc1);
		accountList.add(acc2);
		insert accountList;
		system.assert(accountList != null);
		
		Contact con1 =  CHL_TestUtility.partnerContact(accountList[0].id);
		Contact con2 =  CHL_TestUtility.partnerContact(accountList[1].id);
		contactList.add(con1);
		contactList.add(con2);
		insert contactList;
	
		List<Opportunity> opptyList =  CHL_TestUtility.createOpportunity(2,accountList[0].id);
		insert opptyList; 			
		
		List<Product2> productList = CHL_TestUtility.createProducts(2);
		insert productList;
        
		List<PricebookEntry> pbeList = CHL_TestUtility.createPricebookEntry(productList,Test.getStandardPricebookId());
		insert pbeList;
		
		List <OpportunityLineItem> opliList = CHL_TestUtility.createOplis(opptyList,pbeList);
		insert opliList;

		List<REN_Field_Mappings__c> poMappingList = CHL_TestUtility.createPOMapping();
		insert poMappingList;
		
		List<REN_Field_Mappings__c> quoteMapingList = CHL_TestUtility.createOppToQuoteMapping();
		insert quoteMapingList;
		
		List<REN_Field_Mappings__c> qliMapingList = CHL_TestUtility.createRLIToQLIMapping();
		insert qliMapingList;
		
		List<CHL_Opportunity_Status_Log__c> opptyStatusLogList = CHL_TestUtility.createOppStatusLog();
		insert opptyStatusLogList;

		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
		partOppty.partnerAcc1Id = accountList[0].id;
		partOppty.partnerAcc1Type = 'Reseller';
		partOppty.contact1Id = contactList[0].Id;
		partOppty.expirationDate = system.today().addDays(-10);
		partOppty.Stage = 'Qualification';
		partOppty.partnerAcc2Id = accountList[1].id;
		partOppty.partnerAcc2Type = 'Distributor';
		partOppty.contact2Id = contactList[1].Id;
		
		List < CHL_Partner_Opportunity__c > poList = CHL_TestUtility.channelPartnerOpportunityList(2, partOppty);
		poList[0].CHL_Opportunity__c = opptyList[0].Id;
		poList[1].CHL_Opportunity__c = opptyList[1].Id;
		insert poList;	   
		
		List<REN_Renews_To__c> souceRliList =  CHL_TestUtility.createRenewableLineItems(2,opptyList[0].Id,productList[0].Id);
		insert souceRliList;
		
		List<REN_Renews_To__c> targetRliList =  CHL_TestUtility.createRenewableLineItems(2,opptyList[1].Id,productList[1].Id);
		insert targetRliList;
		
		List<CHL_Partner_Renewal_Relationship__c> sourcePRRList = CHL_TestUtility.createPartnerRenewableLineItems(poList[0].Id, souceRliList);
		insert sourcePRRList;
		
		List<CHL_Partner_Renewal_Relationship__c> targetPRRList = CHL_TestUtility.createPartnerRenewableLineItems(poList[1].Id, targetRliList);
		insert targetPRRList;
	}
	
	@isTest
	static void testSplitWithMatchingPAs(){
		String currencyCode = '';
		if(CSM_AccessController.hasField('opportunity',  'CurrencyIsoCode')) {
			currencyCode = ',CurrencyIsoCode';
		}
		String queryString= 'select id, Name,StageName,Description,Pricebook2Id'+ currencyCode +',Probability from Opportunity limit 2';
		List<Opportunity> OppList = Database.query(queryString);
		
		List<REN_Renews_To__c> souceRliList = [Select Id, Name, REN_Renews_To__c from REN_Renews_To__c where REN_Renews_To__c =:OppList[0].Id limit 1];
		List<Product2> prodList = [Select Id, Name from Product2 limit 1];
		List<Opportunity> sourceOppList = new List<Opportunity>{OppList[0]};
		Test.startTest();
			SS_License__c productIdSetting= SS_License__c.getOrgDefaults();
			productIdSetting.Renewal_Amount_Product_Id__c = prodList.get(0).Id;
			productIdSetting.Simplified_Data_Model_Is_Enabled__c=true;
			insert productIdSetting;
			
			CHL_ManageSplitConsolidatePRR.handlePRRSplitAndConsolidate(souceRliList, sourceOppList, OppList[1], 'Split');
			List<REN_Renews_To__c> targetRliList = [Select Id, Name, REN_Renews_To__c from REN_Renews_To__c where REN_Renews_To__c =:OppList[1].Id];
			system.assert(targetRliList != null);
			
			List<CHL_Partner_Renewal_Relationship__c> targetPRRList = [Select Id, CHL_Renewal_Relationship__c from CHL_Partner_Renewal_Relationship__c where CHL_Renewal_Relationship__c IN:targetRliList];			
			system.assert(targetPRRList != null);
		Test.stopTest();
	}

	@isTest
	static void testSplitWithNotMatchingPAs(){
		String currencyCode = '';
		if(CSM_AccessController.hasField('opportunity',  'CurrencyIsoCode')) {
			currencyCode = ',CurrencyIsoCode';
		}
		String queryString= 'select id, Name,StageName,Description,Pricebook2Id'+ currencyCode +',Probability from Opportunity limit 2';
		List<Opportunity> OppList = Database.query(queryString);
		
		List<REN_Renews_To__c> souceRliList = [Select Id, Name, REN_Renews_To__c from REN_Renews_To__c where REN_Renews_To__c =:OppList[0].Id];
		List<Opportunity> sourceOppList = new List<Opportunity>{OppList[0]};
		List<CHL_Partner_Opportunity__c > poList = [Select Id, CHL_Partner_Account_1__c,CHL_Partner_Account_2__c,CHL_Partner_Account_1_Contact__c,CHL_Partner_Account_2_Contact__c from CHL_Partner_Opportunity__c limit 2];
		poList[0].CHL_Partner_Account_1__c = null;
		poList[0].CHL_Partner_Account_2__c = null;
		poList[0].CHL_Partner_Account_1_Contact__c = null;
		poList[0].CHL_Partner_Account_2_Contact__c = null;
		poList[0].put('CHL_Syncing__c','From Master Opportunity'); 
		update poList[0];
		Test.startTest();
			CHL_ManageSplitConsolidatePRR.handlePRRSplitAndConsolidate(souceRliList, sourceOppList, OppList[1], 'Split');
			List<REN_Renews_To__c> targetRliList = [Select Id, Name, REN_Renews_To__c from REN_Renews_To__c where REN_Renews_To__c =:OppList[1].Id];
			system.assert(targetRliList != null);
			
			List<CHL_Partner_Renewal_Relationship__c> targetPRRList = [Select Id, CHL_Renewal_Relationship__c from CHL_Partner_Renewal_Relationship__c where CHL_Renewal_Relationship__c IN:targetRliList];			
			system.assert(targetPRRList != null);
		Test.stopTest();
	}
	
	@isTest
	static void testConsolidateWithMatchingPAs(){
		String currencyCode = '';
		if(CSM_AccessController.hasField('opportunity',  'CurrencyIsoCode')) {
			currencyCode = ',CurrencyIsoCode';
		}
		String queryString= 'select id, Name,StageName,Description,Pricebook2Id'+ currencyCode +',Probability from Opportunity limit 2';
		List<Opportunity> OppList = Database.query(queryString);
		
		List<REN_Renews_To__c> souceRliList = [Select Id, Name, REN_Renews_To__c from REN_Renews_To__c where REN_Renews_To__c =:OppList[0].Id];
		List<Opportunity> sourceOppList = new List<Opportunity>{OppList[0]};
		Test.startTest();
			CHL_ManageSplitConsolidatePRR.handlePRRSplitAndConsolidate(null, sourceOppList, OppList[1], 'Consolidate');
			List<REN_Renews_To__c> targetRliList = [Select Id, Name, REN_Renews_To__c from REN_Renews_To__c where REN_Renews_To__c =:OppList[1].Id];
			system.assert(targetRliList != null);
			
			List<CHL_Partner_Renewal_Relationship__c> targetPRRList = [Select Id, CHL_Renewal_Relationship__c from CHL_Partner_Renewal_Relationship__c where CHL_Renewal_Relationship__c IN:targetRliList];			
			system.assert(targetPRRList != null);
		Test.stopTest();
	}
}