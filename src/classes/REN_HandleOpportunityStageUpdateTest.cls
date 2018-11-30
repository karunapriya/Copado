/**
 * Created Date		: Jan 20, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Test Coverage for REN_HandleOpportunityStageUpdate
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US1970/US2008			Jan 20, 2017	1.1			 		Added in sprint 703
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Comity Designs, Inc. 2017 - All Rights Reserved.
 */
@isTest
private class REN_HandleOpportunityStageUpdateTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
		List<Account> accList = CSM_TestDataUtility.createAccount(1);
		system.assert(accList.get(0).Id != null);
        List<Contact> contList = CSM_TestDataUtility.createContacts(accList[0].Id,1);
        contList[0].REN_Prefered_Language_Code__c='en_US';
        update contList;
		Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;
		system.assert(prod.Id != null);
		Id pricebookId = Test.getStandardPricebookId();
		PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId, Product2Id = prod.Id,
        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        List<Opportunity> testOppList = new List<Opportunity>();
		for (Integer i = 0; i < 1; i++) {
			testOppList.add(new Opportunity(Name = 'TestOpp' + i, StageName = 'Prospecting',
			CloseDate = System.Today(), AccountId = accList[0].Id, Type = 'New Customer', Amount=5000, Pricebook2Id = pricebookId));
		}
		insert testOppList;
		REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
		renRelationObj.Name = 'Partner Renewal';
		renRelationObj.REN_Renewal_Status__c = 'Open';
		renRelationObj.REN_Renews_To__c = testOppList[0].Id;
		insert renRelationObj;
	}
	
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
         list<Opportunity> opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
         list<REN_Renews_To__c> rliList = [Select Id,REN_Renewal_Status__c from REN_Renews_To__c limit 1];
      	 Map<String,String> mapOfStrings = new Map<String,String>();  
         REN_HandleOpportunityStageUpdate.getOpportunity(opp[0].Id);
         String urlToDocSign = REN_HandleOpportunityStageUpdate.updatePOReceivedStatus(opp[0].Id);
         System.assert(String.isNotBlank(urlToDocSign));
         
         //List<REN_Field_Mappings__c> poRejectListOption = REN_HandleOpportunityStageUpdate.getPORejectOption();
         //System.assertEquals(poRejectListOption.size(), 0);
         String rejectReasons = REN_HandleOpportunityStageUpdate.getPORejectOptionMap();
         
         System.assert(REN_HandleOpportunityStageUpdate.updateOppRejectStatus(opp[0].Id, 'Won','test'));
         
         REN_ToggleLowTouchConfiguration wrapper = REN_HandleOpportunityStageUpdate.getLTConfiguration();
         
         String clientName = REN_HandleOpportunityStageUpdate.getClientName();
         
         REN_HandleOpportunityStageUpdate.updateErrorLog('Test', 'Test', opp[0].Id);
         
         List<REN_OpportunityWrapper> oppWrp = REN_HandleOpportunityStageUpdate.getOppDetail(opp[0].Id,mapOfStrings);
         
         opp[0].StageName = 'Closed Won';
         update opp[0];
         
         opp[0].StageName = 'PO Received';
         update opp[0];
        
        REN_HandleOpportunityStageUpdate.updateOppStageOnLoad(opp[0].Id,'FR','');
    }

    static testMethod void testPaymentFlow() {
        // TO DO: implement unit test
         list<Opportunity> opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
         String returnStr = REN_HandleOpportunityStageUpdate.getPaymentInfo(opp[0].Id,'FR');
         System.assert(String.isNotBlank(returnStr));
         List<REN_LT_RenewalConfirmationWrapper> wList = REN_HandleOpportunityStageUpdate.getOppRecordDetails(opp[0].Id + '', 's');
         System.assert(wList[0].opportunityObj.StageName == 'PO Received');
        
         
    }

    //Below test method is created to include custom labels used in lightning components in package. US2008
    static testMethod void testLabels() {
		String CustomLabels1 = Label.REN_NO_QUOTE_SYNCED_QUOTE + ''+Label.REN_NO_CON_FOUND+''+Label.REN_PAYMENT_OPT+''+Label.REN_BUY_RENE_DESC+''+Label.REN_PAY_VIA_PO+''+Label.REN_BUY_NOW;
		String CustomLabels2 = Label.REN_SC_EXPIRE_MSG + ''+Label.REN_SERVICE+''+Label.REN_BASIC_CVRG+''+Label.REN_EXP_DT+''+Label.REN_RENEWAL_AMT+''+Label.REN_CHAT+''+Label.REN_DO_NOT_RENEW;
		String CustomLabels3 = Label.REN_CON_PRTNR + ''+Label.REN_CALL_ME+''+Label.REN_NOT_RENEW_MSG+''+Label.REN_FWD_TO_BUYER_MSG+''+Label.REN_REVIEW_QUOTE_MSG+''+Label.REN_TIME_TO_PROCESS+Label.REN_LT_REJECT_PO_MSG;
		String CustomLabels4 = Label.REN_STG_SUCC_CREATED_MSG + ''+Label.REN_STG_NOT_UPD_MSG+''+Label.REN_SC_NOT_RENEWED_MSG+''+Label.REN_SC_REASON_MSG+''+Label.REN_REJECT_PROD_MSG1+''+Label.REN_REJECT_PROD_MSG2;
		CustomLabels4 += Label.REN_PORejectList+Label.REN_LBL_FILE_NOT_SUPPORTED+Label.REN_LBL_MISSING_OPP_ID+Label.REN_LBL_MISSING_FILE+Label.REN_LBL_CHAT_NOW+Label.REN_LBL_CHAT_UNAVAILABLE;
        CustomLabels4 += Label.REN_LBL_NO_SERVICE_MAPPINGS_DESCRIPTION_LINE1+Label.REN_LBL_NO_SERVICE_MAPPINGS_DESCRIPTION_BULLET1+Label.REN_LBL_NO_SERVICE_MAPPINGS_DESCRIPTION_BULLET2+Label.REN_LBL_NO_SERVICE_MAPPINGS_DESCRIPTION_BULLET3;
        CustomLabels4 += Label.REN_LBL_SIGNED_PO_CONFIRMATION+Label.REN_LBL_SELECT_FILE+Label.CHL_LBL_OPP_CLOSED;
        String custLabel5 = Label.REN_LBL_SELECT_FILE + Label.REN_LBL_LOADING + Label.REN_QUOTE+ Label.REN_CONTACT_NAME+Label.REN_LT_Pay+Label.REN_PAY_VIA_CREDIT_CARD+Label.REN_OR+Label.REN_SIGN_PO_VIA_DOCUSIGN+Label.REN_OTHER_OPTIONS;
        custLabel5 += Label.REN_ERR_REQUIRED_FIELDS + Label.REN_DISPLAY_NAME_CANNOT_BLANK + Label.REN_DISPLAY_NAME_UNIQUE + Label.REN_LBL_SELECT_FILE+ Label.REN_LBL_LOADING+ Label.REN_QUOTE + Label.REN_CONTACT_NAME+Label.REN_ERR_REQUIRED_FIELDS;
        custLabel5 += Label.CHL_LBL_CONTACT_ME + Label.CHL_LBL_STAGE_ONLOAD;
        custLabel5 += Label.CSM_LBL_NO_FC_ASSIGNED + Label.CSM_LBL_TYPE_CHANGE_VALIDATION;
		system.assert(CustomLabels1 != null);
	}
	//Added for Low touch admin data access code coverage
	 static testMethod void myUnitTest2() {
      REN_TestDataSetup testdata=new REN_TestDataSetup();
      List<Account> accList=testdata.createAccount(2);
      List<Opportunity> oppList=[Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
      list<Contact> contList=[select ID from Contact limit 1];
      OpportunityContactRole objOppConRole=new OpportunityContactRole();
      objOppConRole.OpportunityId=oppList[0].id;
      objOppConRole.ContactId=contList[0].Id;
      objOppConRole.IsPrimary=true;
      insert objOppConRole;
      system.assert(accList != null);
      system.assert(oppList != null);
      List<Id> oppIds=new List<Id>();
      Map<String,String> mapOfStrings = new MAp<String,String>();
      for(Opportunity opp:oppList)
      {
      	oppIds.add(opp.id);
      }
      Test.startTest();
      REN_HandleOpportunityStageUpdate.getOppDetail(oppIds[0],mapOfStrings);
      REN_HandleOpportunityStageUpdate.updateOppStageOnLoad(oppIds[0],'FR','unsubscribe');
      Test.stopTest();
        
    }
	
}