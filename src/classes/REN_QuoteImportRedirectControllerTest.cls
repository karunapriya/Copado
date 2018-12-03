/**
 * Created Date		: Aug 6, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: Test class for Quote Import redirect page.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Comity					US3657				Aug 6, 2018			1.1					@description
 *
 */
@isTest
private class REN_QuoteImportRedirectControllerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void testSetupMethod() {
        Account Acc=new Account(name='testacc');
        insert Acc;
        system.assert(Acc!=NULL);
        Opportunity opp=new Opportunity();
        opp.accountid=Acc.id;
        opp.name='Testop';
        opp.StageName='Contacted';
        opp.Type = 'New Customer';
        opp.CloseDate = System.Today(); 
        insert opp;
        
        
		Quote quoteObj1 = new Quote();
        quoteObj1.Name = 'testquote2';
        quoteObj1.OpportunityId = opp.id;
        insert quoteObj1;
        
    }
	
	/**Redirection of Quote import form Opportunity**/
    static testMethod void quoteFromOppTest() {
    	Test.startTest();
    	List<Quote> Qt=[select id,opportunityid from Quote limit 1];
        system.assert(Qt!=NULL);
        List<Opportunity> oppList = [select id,SyncedQuoteid from Opportunity where id =:(Qt[0].opportunityid)];
        ApexPages.CurrentPage().getparameters().put('Id', oppList[0].Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Qt);
    	REN_QuoteImportRedirectController controller = new REN_QuoteImportRedirectController(sc);
        PageReference pref = controller.returnPage();
    	Test.stopTest();
    	
    }
    
    
}