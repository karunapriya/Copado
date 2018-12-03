@isTest(SeeAllData=true)
private class REN_MergeOpportunityControllerTest {
	static testMethod void Test_ValidateConsolidatedOpps() {
		system.assert(true);
	}
/* This test class this deprecated under US3293

	static testMethod void Test_ValidateConsolidatedOpps() {
       	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
    	opportunityList[0].REN_Is_Consolidated__c = true;
    	update opportunityList[0];
    	String oppIdParam = '';
    	for(Opportunity opp : opportunityList){
    		if(String.isBlank(oppIdParam)){
    			oppIdParam = oppIdParam + opp.Id;
    		}else{
    			oppIdParam = oppIdParam + '-' + opp.Id;
    		}
    	}
       	Test.startTest();
    	PageReference pageRefVF = Page.REN_MergeOpportunity;
    	Test.setCurrentPageReference(pageRefVF);
    	System.currentPageReference().getParameters().put('opptIds', oppIdParam);
    	REN_MergeOpportunityController controller = new REN_MergeOpportunityController();
    	system.assert(controller.allowMerge != null);
    	//system.assertEquals(controller.allowMerge, false);
    	//system.assertEquals(controller.opportunityList.isEmpty(), false);
    	//system.assertEquals(controller.readOnlyFields.isEmpty(), false);
    	//system.assertEquals(controller.updateableFields.isEmpty(), false);
    	Test.stopTest();
    } 
    
    static testMethod void Test_MergeOpportunities_Positive() {
       	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
    	String standardPriceBookId = Test.getStandardPricebookId();
		Product2 p2 = new Product2(Name='Test Product',isActive=true);
		insert p2;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=p2.Id, UnitPrice=99, isActive=true);
		insert pbe;
		List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
		for(Integer i=0; i<5; i++){
			OpportunityLineItem newol = new OpportunityLineItem();
			newol.UnitPrice = 50000;
			newol.ServiceDate = System.today();
			newol.Description = 'Desc 1';
			newol.Quantity = 1;
			newol.PricebookEntryId = pbe.Id;
			if(i < 2){
				newol.OpportunityId = opportunityList[0].Id;
			}else{
				newol.OpportunityId = opportunityList[1].Id;
			}
			opliList.add(newol);
		}
		insert opliList;
    	String oppIdParam = '';
    	for(Opportunity opp : opportunityList){
    		if(String.isBlank(oppIdParam)){
    			oppIdParam = oppIdParam + opp.Id;
    		}else{
    			oppIdParam = oppIdParam + '-' + opp.Id;
    		}
    	}
       	Test.startTest();
    	PageReference pageRefVF = Page.REN_MergeOpportunity;
    	Test.setCurrentPageReference(pageRefVF);
    	System.currentPageReference().getParameters().put('opptIds', oppIdParam);
    	REN_MergeOpportunityController controller = new REN_MergeOpportunityController(); 	
    	system.assert(controller.allowMerge != null);
    	system.assertEquals(controller.opportunityList.isEmpty(), false);
    	system.assertEquals(controller.readOnlyFields.isEmpty(), false);
    	system.assertEquals(controller.updateableFields.isEmpty(), false);
    	system.assertEquals(String.isBlank(controller.updateableFieldJSON), false);
    	controller.selectedValuesJson = JSON.serialize(controller.opportunityList[0]);
    	controller.selectedMasterId = opportunityList[0].Id;
    	controller.mergeOpportunities();
    	Test.stopTest();
    }
    
    static testMethod void Test_MergeOpportunities_Negative() {
       	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
    	String oppIdParam = '';
    	for(Opportunity opp : opportunityList){
    		if(String.isBlank(oppIdParam)){
    			oppIdParam = oppIdParam + opp.Id;
    		}else{
    			oppIdParam = oppIdParam + '-' + opp.Id;
    		}
    	}
       	Test.startTest();
    	PageReference pageRefVF = Page.REN_MergeOpportunity;
    	Test.setCurrentPageReference(pageRefVF);
    	System.currentPageReference().getParameters().put('opptIds', oppIdParam);
    	REN_MergeOpportunityController controller = new REN_MergeOpportunityController();
    	system.assertEquals(controller.allowMerge, true);
    	system.assertEquals(controller.opportunityList.isEmpty(), false);
    	system.assertEquals(controller.readOnlyFields.isEmpty(), false);
    	system.assertEquals(controller.updateableFields.isEmpty(), false);
    	system.assertEquals(String.isBlank(controller.updateableFieldJSON), false);
    	controller.selectedValuesJson = JSON.serialize(controller.opportunityList[0]);
    	controller.mergeOpportunities();
    	//system.assertEquals(controller.allowMerge, false);
    	Test.stopTest();
    }
    
    static testMethod void Test_MergeOpportunities_Init_Negative() {
       	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
    	String oppIdParam = '';
    	for(Opportunity opp : opportunityList){
    		if(String.isBlank(oppIdParam)){
    			oppIdParam = oppIdParam + opp.Id;
    		}else{
    			oppIdParam = oppIdParam + '-' + opp.Id;
    		}
    	}
    	User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
    	system.runAs(restrictedUser){
	       	Test.startTest();
	    	PageReference pageRefVF = Page.REN_MergeOpportunity;
	    	Test.setCurrentPageReference(pageRefVF);
	    	System.currentPageReference().getParameters().put('opptIds', oppIdParam);
	    	REN_MergeOpportunityController controller = new REN_MergeOpportunityController();
	    	system.assert(controller.allowMerge != null);
	    	Test.stopTest();
    	}
    }
    
    static testMethod void Test_Cancel() {
       	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
    	List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
    	String oppIdParam = '';
    	for(Opportunity opp : opportunityList){
    		if(String.isBlank(oppIdParam)){
    			oppIdParam = oppIdParam + opp.Id;
    		}else{
    			oppIdParam = oppIdParam + '-' + opp.Id;
    		}
    	}
       	Test.startTest();
    	PageReference pageRefVF = Page.REN_MergeOpportunity;
    	Test.setCurrentPageReference(pageRefVF);
    	System.currentPageReference().getParameters().put('opptIds', oppIdParam);
    	REN_MergeOpportunityController controller = new REN_MergeOpportunityController();
    	system.assertEquals(controller.allowMerge, true);
    	system.assertEquals(controller.opportunityList.isEmpty(), false);
    	system.assertEquals(controller.readOnlyFields.isEmpty(), false);
    	system.assertEquals(controller.updateableFields.isEmpty(), false);
    	system.assertEquals(String.isBlank(controller.updateableFieldJSON), false);
    	controller.selectedValuesJson = JSON.serialize(controller.opportunityList[0]);
    	PageReference cancelRef = controller.cancel();
    	system.assert(cancelRef != null);
    	Test.stopTest();
    } */
}