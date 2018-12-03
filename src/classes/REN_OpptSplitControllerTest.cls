@isTest(SeeAllData = false)
private class REN_OpptSplitControllerTest
{
    static testMethod void testPageLoad()
    {
        Product2 prod1 = new Product2(Name = 'Test Product 1', IsActive = true);
		insert prod1;
		
		 Id pricebookId = Test.getStandardPricebookId();
       	 PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id,
           	 UnitPrice = 10000, IsActive = true);
       	 insert standardPrice;
        
         Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
         insert customPB;
		//Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		
		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = customPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod1.Id);
		insert price1;
		
		Account a = new Account(Name = 'RENEW DIRECT Test Account A');
		insert a; 
		
		Opportunity currentOpportunity = new Opportunity(Name = 'TestOpp', StageName = 'Qualified', 
											CloseDate = System.Today(), AccountId = a.Id, Type = 'New Customer');
		
		insert currentOpportunity;
		List<OpportunityLineItem> testOppLineItemsList = new List<OpportunityLineItem>();
		for(Integer i = 0; i < 2; i++)
		{
			testOppLineItemsList.add(new OpportunityLineItem(OpportunityId = currentOpportunity.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id));
		}
		insert testOppLineItemsList;
		
        ApexPages.StandardController cntlr = new ApexPages.StandardController(currentOpportunity);
        REN_OpptSplitController renControl = new REN_OpptSplitController(cntlr);
        
        PageReference pageRef = Page.REN_OpptSplitWizard;
        pageRef.getParameters().put('opptId', String.valueOf(currentOpportunity.Id));
        pageRef.getParameters().put('opptLns', String.valueOf(testOppLineItemsList[0].Id + '-' + testOppLineItemsList[0].Id)); 
        //00ko0000003b2d8-00ko0000003b2lO
        Test.setCurrentPage(pageRef);
        System.assert(pageRef!=null);
    }
}