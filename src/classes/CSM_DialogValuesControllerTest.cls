/**
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
 */
@isTest
private class CSM_DialogValuesControllerTest {

    static testMethod void focusCategoryTest() {
		CSM_Admin__c adm = new CSM_Admin__c();
		adm.CSM_Focus_Category_Objects__c = 'Account;Opportunity;Task;Case;CSM_Account_Plan__c';
		insert adm;
		
		Test.startTest();
		CSM_FocusCategoryViewListCtrl fcvCtrl = new CSM_FocusCategoryViewListCtrl();
		CSM_DialogValuesController ctrl = new CSM_DialogValuesController(fcvCtrl);
		object response = CSM_DialogValuesController.getResponseForDialogBoxValues('{"objectType":"' + CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES + '"}');
		//system.debug(response);
    	Test.stopTest();
    	
    	system.assert(response != null);
	}
	
	static testMethod void opptSyncTest() {
		Test.startTest();
		List<CHL_Partner_Opportunity__c> partnerOpps = new List<CHL_Partner_Opportunity__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(partnerOpps);
		CHL_PartnerOpportunitySyncCtrl opptCtrl = new CHL_PartnerOpportunitySyncCtrl(sc);
		CSM_DialogValuesController ctrl = new CSM_DialogValuesController(opptCtrl);
		object response = CSM_DialogValuesController.getResponseForDialogBoxValues('{"objectType":"' + CSM_Constants.STR_PARTNER_SYNCING + '"}');
		system.debug(response);
    	
    	
    	system.assert(response != null);
    	Test.stopTest();
	}
}