@isTest
private class REN_AccountToAssetsCompContlrTest {
	
		private static Id testAccountId;
		private static  Id opportunityId;

  static testMethod void myUnitTest() {
        
       try{
        	Test.startTest();
        	DataSetup();
        	
        	REN_AccountToAssetsCompController AccAssetCompContlrObj = new REN_AccountToAssetsCompController();
        
        	AccAssetCompContlrObj.accountId = testAccountId;
        
        	AccAssetCompContlrObj.sortExpression = 'Name';
	    	AccAssetCompContlrObj.sortDirection =  'ASC';
        	AccAssetCompContlrObj.getAssetForAccountId();
        
        	AccAssetCompContlrObj.getThis();
        
        	AccAssetCompContlrObj.sortDirection =  'DESC';
        	AccAssetCompContlrObj.getAssetForAccountId();
        
        	Test.stopTest();
        
         }catch(Exception e){
         	system.debug('Exception : ' + e.getMessage());
         }
        
    }
    
   static testMethod void DataSetup() {
			
			List<Account> accList = CSM_TestDataUtility.createAccount(1);
       		system.assert(accList.get(0).Id != null);
       
       		Product2 prod = REN_TestDataUtility.createProduct(1);
       		insert prod;
       		system.assert(prod.Id != null);
		
			Asset asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);		                
        	insert asset;
        
        	Opportunity opport = new Opportunity();
        	opport.AccountId = testAccountId;
        	opport.StageName = 'Prospecting';
        	opport.CloseDate = System.today();
        	opport.Name = 'Opportunity Test';
        	insert opport;
        	
        	opportunityId = opport.Id;
        	List<Asset> assetList = REN_AssetDataAccess.getAssetDetailsById(new List<String>{asset.Id}, new Set<String>{'id'});
        	system.assert(assetList != null);
        	
        	REN_Renews_To__c renRelationObj  = new REN_Renews_To__c();
        	renRelationObj.Name  = 'Ren-OPP';
        	renRelationObj.REN_Asset__c = asset.Id;
        	renRelationObj.REN_Renews_To__c = opportunityId;
        	insert renRelationObj;
        	system.assert(renRelationObj != null);
        
       
    }
    
    
    
   
}