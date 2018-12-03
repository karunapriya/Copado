/**
 * Created Date		: Apr 10, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					User Story				Apr 10, 2018			1.1					@description
 *
 *
 * Comity Designs, Inc. 2018 - All Rights Reserved.
 */
@isTest
private class CHL_CreateQuoteAndQLIBatchTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
        List<Account> accountList = new List<Account>();        
        Account acc1 =  CHL_TestUtility.partnerAccount();
        accountList.add(acc1);
        insert accountList;
        system.assert(accountList != null);
        
        List<Opportunity> opptyList =  CHL_TestUtility.createOpportunity(1,accountList[0].id);
        insert opptyList; 
        system.assert(opptyList != null);
        
        List<Product2> productList = CHL_TestUtility.createProducts(2);
        insert productList;
        
        List<PricebookEntry> pbeList = CHL_TestUtility.createPricebookEntry(productList,Test.getStandardPricebookId());
        insert pbeList;
        
        List <OpportunityLineItem> opliList = CHL_TestUtility.createOplis(opptyList,pbeList);        
        insert opliList;
        
        CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
        partOppty.partnerAcc1Id = accountList[0].id;
        partOppty.partnerAcc1Type = 'Reseller';
        partOppty.expirationDate = system.today().addDays(-10);
        partOppty.Stage = 'Qualification';
        partOppty.partnerAcc2Type = 'Distributor';
        
        List < CHL_Partner_Opportunity__c > poList = CHL_TestUtility.channelPartnerOpportunityList(1, partOppty);
        poList[0].CHL_Opportunity__c = opptyList[0].Id;
        insert poList;     
        if(CSM_AccessController.hasObject('Quote')) {
        	List<SObject> quotesList = CHL_TestUtility.createQuotes(1,opptyList,poList);
        	quotesList[0].put(REN_Constants.OBJ_OPP_PRICEBOOK_ID,Test.getStandardPricebookId());
        	insert quotesList;
        	system.assert(quotesList != null);
        
        	List<SObject> quoteLineItemsList = CHL_TestUtility.createMultipleQuoteLineItems(100,quotesList,productList,pbeList);
        	insert quoteLineItemsList;    
        }
        List<REN_Field_Mappings__c> OpptyToQuoteMapingList = CHL_TestUtility.createOpptyToQuoteMapping();
        insert OpptyToQuoteMapingList;
        
        List<REN_Field_Mappings__c> oliToQliMapingList = CHL_TestUtility.createOliToQliMapping();
        insert oliToQliMapingList;
        
        CSM_Admin__c adminSetting= CSM_Admin__c.getOrgDefaults();
        adminSetting.CHL_QliCount__c = 50;
        insert adminSetting;
        
        CSM_TriggerEnablement__c triggEnable = CSM_TriggerEnablement__c.getOrgDefaults();
        triggEnable.REN_Bypass_Metrics_Field_Calculations__c = false;
        insert triggEnable;
	}
	
    static testMethod void createQuoteAndQliPositive() {  
    	List<Opportunity> OppList = [Select Id, Name,StageName,Description,Pricebook2Id,CHL_QuoteSyncStatus__c,Probability from Opportunity limit 1];
        if(CSM_AccessController.hasObject('Quote')){
	    	String quoteString = 'Select Id, OpportunityId from Quote limit 1';
	    	List<SObject> quoteList = Database.query(quoteString); 
	    	String qliString = 'select Id from QuoteLineItem limit 1';
	    	List<sObject> qliList = Database.query(qliString);
	        CHL_CreateQuoteAndQLIBatch quoteQLIBatch = new CHL_CreateQuoteAndQLIBatch();
	    	quoteQLIBatch.quoteIdSet = new Set<Id>{quoteList[0].id};
	    	quoteQLIBatch.isOppUpdateRequired = true;
	        system.assert(quoteQLIBatch.quoteIdSet != null);
	        Test.startTest(); 
        	Database.executeBatch(quoteQLIBatch);
        	CHL_CreateQuoteAndQLIBatchHelper.updateSyncedAfterCreationFlag(new list<String>{string.valueOf(qliList[0].id)});          		
   			CHL_CreateQuoteAndQLIBatchHelper.rollupMsrp(new list<String>{string.valueOf(qliList[0].id)}, false, 1000);
	       	Test.stopTest();
        }
    }
    static testMethod void createQuoteAndQliNeg(){  
   		List<Opportunity> OppList = [Select Id, Name,StageName,Description,Pricebook2Id,CHL_QuoteSyncStatus__c,Probability from Opportunity limit 1];
        if(CSM_AccessController.hasObject('Quote')){
	    	String quoteString = 'Select Id, OpportunityId from Quote limit 1';
	    	List<SObject> quoteList = Database.query(quoteString); 
	    	String qliString = 'select Id from QuoteLineItem limit 1';
	    	List<sObject> qliList = Database.query(qliString);
	        CHL_CreateQuoteAndQLIBatch quoteQLIBatch = new CHL_CreateQuoteAndQLIBatch();
	    	quoteQLIBatch.isOppUpdateRequired = true;
	    	quoteQLIBatch.quoteIdSet = null;
	        Test.startTest(); 
	        system.assert(quoteQLIBatch != null);
        	Database.executeBatch(quoteQLIBatch);          		
   			CHL_CreateQuoteAndQLIBatchHelper.rollupMsrp(new list<String>{string.valueOf(qliList[0].id)}, false, 1000);
	       	Test.stopTest();
        }
    }
}