@isTest
private class REN_OppLineItemListControllerTest {
	static List<REN_OpptLineWrapper> opptLineWrapperList;

    static void dataSetUp() {
        
        List <Account> accountList = CSM_TestDataUtility.createAccount(1);
		system.assert(accountList != null);
		system.assert(!accountList.isEmpty());
		
		List <Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
		system.assert(opportunityList != null);
		system.assert(!opportunityList.isEmpty());
		String standardPriceBookId = Test.getStandardPricebookId();
		
		Product2 p2 = new Product2(Name = 'Test Product', isActive = true,ProductCode ='IN7080');
		insert p2;
		system.assert(p2.Id != null);
		
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = p2.Id, UnitPrice = 99, isActive = true);
		insert pbe;
		system.assert(pbe.Id != null);
		
		List <OpportunityLineItem> opliList = new List <OpportunityLineItem> ();
			OpportunityLineItem newol = new OpportunityLineItem();
		  	newol.OpportunityId =opportunityList[0].id;
		  	newol.UnitPrice = 50000;
		  	newol.ServiceDate = System.today();
		  	newol.Description = 'Desc 1';
		  	newol.Quantity = 1;
		  	newol.PricebookEntryId = pbe.Id;
		insert newol;
		System.assert(newol.Id!=null);
		opptLineWrapperList = new List <REN_OpptLineWrapper>();
			REN_OpptLineWrapper opptLineWrapper= new REN_OpptLineWrapper(); 
				opptLineWrapper.opLine = newol;
				opptLineWrapper.customId= 1;
				opptLineWrapper.isSelected= true;
				opptLineWrapper.sourceOpptId= '11';
				opptLineWrapper.sourceOpptLnId= '22';
				opptLineWrapper.opportunityProduct = '33';
		opptLineWrapperList.add(opptLineWrapper);
		
		REN_OpptLineWrapper opptLineWrapper1= new REN_OpptLineWrapper(); 
				opptLineWrapper.opLine = newol;
				opptLineWrapper.customId= 2;
				opptLineWrapper.isSelected= true;
				opptLineWrapper.sourceOpptId= '11';
				opptLineWrapper.sourceOpptLnId= '22';
				opptLineWrapper.opportunityProduct = '33';
		opptLineWrapperList.add(opptLineWrapper1);
		System.assert(opptLineWrapperList!=null);
    } 
    
     static testMethod void myUnitTest() {
     	dataSetUp();
     	Test.startTest();
	     	REN_OpportunityLineItemListController controller = new REN_OpportunityLineItemListController();
	     	controller.opliWrapperList = opptLineWrapperList;
	     	controller.numberOfRowToRemove = 0;
	    PageReference pageRef = controller.removeOpli(); 
	    System.assert(pageRef==null);
	    Test.stopTest();
     }
     
      static testMethod void opportunityDetailControllerTest() {
      	List <Account> accountList = CSM_TestDataUtility.createAccount(1);
     	List <Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
     	Test.startTest();
	     	REN_OpportunityDetailController controller = new REN_OpportunityDetailController();
	     	controller.opportunityObject = opportunityList[0];
	    System.assert(controller.opportunityObject!=null);
     	Test.stopTest();
     }
     static testmethod void myUnitTest1()
    {       
        Product2 prod = REN_TestDataUtility.createProduct(1);
		insert prod;
		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = test.getStandardPricebookId(), UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
		insert price1;
        List<Account> accList = CSM_TestDataUtility.createAccount(1);
		system.assert(accList!=null);
		List<Opportunity> opptyList = CSM_TestDataUtility.createOpportunity(1, (String)accList[0].id);
		system.assert(opptyList!=null);
        OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = opptyList[0].Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
		insert opptyLineItem;
        list<REN_OpptLineWrapper> objWrapper=new list<REN_OpptLineWrapper>();
        REN_OpptLineWrapper obj=new REN_OpptLineWrapper();
        obj.opLine =opptyLineItem;
        obj.isSelected=true;
        obj.product2Id=prod.Id;
        obj.sourceOpptId=opptyList[0].id;
        objWrapper.add(obj);
        REN_OpptLineWrapper obj1=new REN_OpptLineWrapper();
        obj1.opLine =opptyLineItem;
        obj1.isSelected=true;
        obj1.product2Id=prod.Id;
        obj1.sourceOpptId=opptyList[0].id;
        objWrapper.add(obj1);
        Test.startTest();
        REN_OpportunityLineItemListController controller=new REN_OpportunityLineItemListController();
        controller.opliWrapperList=objWrapper;
        System.assert(controller.opliWrapperList!=null);
        controller.numberOfRowToRemove=1;
        controller.removeOpli();
        Test.stopTest();
    }
}