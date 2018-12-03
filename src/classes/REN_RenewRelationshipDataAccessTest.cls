@isTest(SeeAllData=true)
private class REN_RenewRelationshipDataAccessTest
{
    static testMethod void test_RenewRelationshipdataAccess_Positive()
    {
        Test.startTest();
        List<Account> accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList.get(0).Id != null);
		Opportunity testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting',
			CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer');
		
		insert testOppty;
        Product2 prod = REN_TestDataUtility.createProduct(1);
        insert prod;

		//Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
		String standardPriceBookId = Test.getStandardPricebookId();
		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPriceBookId, UnitPrice = 1.0, IsActive = true, Product2Id = prod.Id);
		insert price1;
		system.assert(price1.Id != null);
		
        system.assert(prod.Id != null);
		OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = testOppty.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id);
		insert opptyLineItem;
			
		Asset asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);		
		asset.REN_Oppty_Line_Item_Id__c = opptyLineItem.Id;                
        insert asset;
        
		string productId = opptyLineItem.Id;
		
        REN_Renews_To__c renRelationObj  = new REN_Renews_To__c();
    	renRelationObj.Name  = 'Ren-OPP';
    	renRelationObj.REN_Asset__c = asset.Id;
    	renRelationObj.REN_Renews_To__c = testOppty.Id;
		//renRelationObj.REN_Renewal_Product_Line_Id__c = productId;
	    renRelationObj.REN_Product__c = prod.id;
    	insert renRelationObj;
		
		List<REN_Renews_To__c> lstRenew = new List<REN_Renews_To__c>();
		List<REN_Renews_To__c> lstRenewtoupsert = new List<REN_Renews_To__c>();
		lstRenew.add(renRelationObj);
		
		//REN_RenewRelationshipDataAccess controller= new REN_RenewRelationshipDataAccess();
		lstRenewtoupsert = REN_RenewRelationshipDataAccess.upsertRenewalRelationship(lstRenew);
		system.assert(lstRenewtoupsert != null);
		
		REN_RenewRelationshipDataAccess.updateRenewalRelationship(lstRenew);
		
		
		product2 prod2 = REN_TestDataUtility.createProduct(1);
        insert prod2;
		system.assert(prod2.Id != null);
		
		PricebookEntry price2 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPriceBookId, UnitPrice = 1.0, IsActive = true, Product2Id = prod2.Id);
		insert price2;
		system.assert(price2.Id != null);
		
		OpportunityLineItem opptyLineItem2 = new OpportunityLineItem(OpportunityId = testOppty.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price2.Id);
		insert opptyLineItem2;
		
		Map<string,string> opptylinemap = new map<string,string>();
		opptylinemap.put(opptyLineItem.id,opptyLineItem2.id);
		
		List<REN_Renews_To__c> lstRenewtoupdate = new List<REN_Renews_To__c>();
		//lstRenewtoupdate = REN_RenewRelationshipDataAccess.getRenewalRelationships(opptylinemap);
		system.assert(lstRenewtoupdate != null);
		
		set<String> assetIds = new set<String>();
		assetIds.add(asset.id);
		List<REN_Renews_To__c> lstRenewto_Assets = new List<REN_Renews_To__c>();
		lstRenewto_Assets = REN_RenewRelationshipDataAccess.getRenewalRelationshipsWithAssetRenewal(assetIds);
		system.assert(lstRenewto_Assets != null);
		Test.stopTest();
	}
	
	/*static testMethod void test_RenewRelationshipdataAccess_Negative()	{		
		Test.startTest();
		List<REN_Renews_To__c> lstRenew = new List<REN_Renews_To__c>();
		List<REN_Renews_To__c> lstRenewtoUpsert = new List<REN_Renews_To__c>();
		User restrictedUser = CSM_TestDataUtility.createTestUser('CSM');
    	system.runAs(restrictedUser){
    		
    		lstRenewtoupsert = REN_RenewRelationshipDataAccess.upsertRenewalRelationship(lstRenew);
    		system.assert(lstRenewtoupsert == null);
    		Map<string,string> opptylinemap = new map<string,string>();
    		lstRenewtoupsert ls(opptylinemap);   
    		system.assert(lstRenewtoupsert == null); 		
    		set<Id> assetIds = new set<Id>();
    		lstRenewtoupsert = REN_RenewRelationshipDataAccess.getRenewalRelationshipsWithAssetRenewal(assetIds);
    		system.assert(lstRenewtoupsert == null);
    		REN_RenewRelationshipDataAccess.updateRenewalRelationship(lstRenew);
    	}
    	Test.stopTest();
	}*/
}