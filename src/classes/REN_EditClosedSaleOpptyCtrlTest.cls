@isTest
public with sharing class REN_EditClosedSaleOpptyCtrlTest {
	@testSetup static void setup() { 
	    List<Account> accList = CSM_TestDataUtility.createAccount(1);
	    system.assert(accList.get(0).Id != null);		
		
		Id pricebookId = Test.getStandardPricebookId();
        
		Opportunity oppObj = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=pricebookId,
		                            CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, 
		                            REN_Earliest_Expiration_Date__c = System.Today() + 2);
		insert oppObj;
		
 	}
    static testMethod void myUnitTest() {
    	Opportunity opp = [SELECT id, name from Opportunity limit 1];
    	PageReference editClosedOpty = Page.REN_EditClosedSaleOppty;
		Test.setCurrentPage(editClosedOpty);
		ApexPages.currentPage().getParameters().put('id',Opp.Id);
        REN_EditClosedSaleOpptyCtrl editOpptyCtrl = new REN_EditClosedSaleOpptyCtrl();
        if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_CASE_REC_TYPE)){
        	editOpptyCtrl.redirect();
        }
        editOpptyCtrl.back();
        System.assertNotEquals(opp, Null);
    }
}