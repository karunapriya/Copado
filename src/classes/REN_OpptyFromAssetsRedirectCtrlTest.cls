@isTest
public with sharing class REN_OpptyFromAssetsRedirectCtrlTest {

    @testSetup 
    static void setUpData() {
		List<Account> accList = CSM_TestDataUtility.createAccount(1);
		system.assert(accList.get(0).Id != null);
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
			CloseDate = System.Today(), AccountId = accList[0].Id, Type = 'New Customer', Pricebook2Id = pricebookId));
		}
		insert testOppList;
        List<asset> testasset = new List<asset>();
        for (Integer i = 0; i < 2; i++) {
			testasset.add(new Asset(AccountId = accList[0].id, Product2Id = prod.id, Name = 'Test Asset'+i, Price = 20.00, Quantity = 2));
		}
		insert testasset;
        
		system.assert(asset.Id != null);
    }
    
    static testMethod void Test_returnPage(){
        try
        {
            list<Opportunity> opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
            PageReference pageRef = Page.REN_OpptyFromAssetsRedirect;
            pageRef.getParameters().put('id', String.valueOf(opp[0].Id));
            Test.setCurrentPage(pageRef);
            String fnd = 'Test Asset' + '%';
            List<Asset> assetRecord = [select id from asset where name like :fnd];
            REN_OpptyFromAssetsRedirectController controller;
            if(opp != null){
                ApexPages.StandardSetController sc = new ApexPages.StandardSetController(assetRecord);
                sc.setSelected(assetRecord);
                controller = new REN_OpptyFromAssetsRedirectController(sc);		   
            }
             
            Test.startTest();
            PageReference pageRefe = controller.returnPage();
          	system.assert(pageRefe != null);
            Test.stopTest();
        }
			catch(Exception e ){
    			system.debug('Exception : ' + e.getMessage());
      		  }
    }
    
    static testMethod void Test_returnPage_Negative(){
        try
        {
            list<Opportunity> opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
            List<Asset> assetRecord = [select id from asset where name = 'Test Asset0' limit 1];
            REN_OpptyFromAssetsRedirectController controller;
            if(opp != null){
                ApexPages.StandardSetController sc = new ApexPages.StandardSetController(assetRecord);
                controller = new REN_OpptyFromAssetsRedirectController(sc);		   
            }
            Test.startTest();
            PageReference pageRef = controller.returnPage();
          	system.assert(pageRef == null);
            Test.stopTest();
        }
        catch(Exception e ){
            system.debug('Exception : ' + e.getMessage());
        	}
    }
    
    static testMethod void Test_returnPage_Nonselectedids(){
        try
        {
          
            list<Opportunity> opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
            PageReference pageRef = Page.REN_OpptyFromAssetsRedirect;
            pageRef.getParameters().put('id', String.valueOf(opp[0].Id));
            Test.setCurrentPage(pageRef);
            
            List<Asset> assetRecord = [select id from asset where name = 'Test Asset0' limit 1];
            REN_OpptyFromAssetsRedirectController controller;
            if(opp != null){
                ApexPages.StandardSetController sc = new ApexPages.StandardSetController(assetRecord);
                controller = new REN_OpptyFromAssetsRedirectController(sc);		   
            }
            Test.startTest();
            PageReference pageRefe = controller.returnPage();
          	system.assert(pageRefe == null);
            Test.stopTest();
        }
        catch(Exception e ){
            system.debug('Exception : ' + e.getMessage());
        	}
    }
    
    static testMethod void Test_returnPage_Selectedids(){
        try
        {
            list<Opportunity> opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
            List<Asset> assetRecord = [select id from asset where name = 'Test Asset0' limit 1];
            REN_OpptyFromAssetsRedirectController controller;
            if(opp != null){
                ApexPages.StandardSetController sc = new ApexPages.StandardSetController(assetRecord);
                sc.setSelected(assetRecord);
                controller = new REN_OpptyFromAssetsRedirectController(sc);		   
            }
            Test.startTest();
            PageReference pageRef = controller.returnPage();
          	system.assert(pageRef != null);
            Test.stopTest();
        }
        catch(Exception e ){
            system.debug('Exception : ' + e.getMessage());
        	}
    }
    
     static testMethod void Test_generateOpportunity(){
         try
         {
             list<Opportunity> opp = [Select Id From Opportunity Where Name =:'TestOpp0' limit 1];
             PageReference pageRef = Page.REN_OpptyFromAssetsRedirect;
             pageRef.getParameters().put('id', String.valueOf(opp[0].Id));
             Test.setCurrentPage(pageRef);
             
             List<Asset> assetRecord = [select id from asset where name = 'Test Asset0' limit 1];
             REN_OpptyFromAssetsRedirectController controller;
             if(opp != null){
                 ApexPages.StandardSetController sc = new ApexPages.StandardSetController(assetRecord);
                 sc.setSelected(assetRecord);
                 controller = new REN_OpptyFromAssetsRedirectController(sc);		   
             }
             
             Test.startTest();
             controller.selectedAssetIds = assetRecord[0].id;
             PageReference pageRefe = controller.generateOpportunity();
             system.assert(pageRefe != null);
             Test.stopTest();
         }
         catch(Exception e ){
             system.debug('Exception : ' + e.getMessage());
         }
     }
    
    
    
}