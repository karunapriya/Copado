@isTest
private class EditClosedSaleRedirectCtrlTest {
	
	@testSetup static void setup() { 
	    Account acc = new Account();
	    acc.name = 'Test Account';
	    insert acc;
	    system.assert(acc.Id != null);		
		
		Id pricebookId = Test.getStandardPricebookId();
        
		Opportunity oppObj = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=pricebookId,
		                            CloseDate = System.Today(), AccountId = acc.Id, Type = 'New Customer', Amount = 100, Probability = 90);
		insert oppObj;
		
 	}
    static testMethod void returnPage_Test() {
    	Opportunity opp = [SELECT id, name, StageName from Opportunity limit 1];
    	System.assertNotEquals(opp.id,null);
        PageReference editClosedOpty = Page.EditClosedSaleRedirect;
		Test.setCurrentPage(editClosedOpty);
		ApexPages.currentPage().getParameters().put('id',opp.Id);
    	ApexPages.StandardController sc = new ApexPages.standardController(opp);
        EditClosedSaleRedirectCtrl editCSCtrl = new EditClosedSaleRedirectCtrl(sc);
       	editCSCtrl.returnPage();
    }
}