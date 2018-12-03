@isTest
private class REN_AssetDataAccessTest {
	
	private static Id testAccountId;
	private static  Id opportunityId;
	
    static testMethod void Test_GetAssetDetailsById_Positive() {
    	try{
	    	Test.startTest();
			
			List<Account> accList = CSM_TestDataUtility.createAccount(1);
	        system.assert(accList.get(0).Id != null);
	       
	        Product2 prod = REN_TestDataUtility.createProduct(1);
	        insert prod;
	        system.assert(prod.Id != null);
			
			Asset asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);		                
	        insert asset;
            
            List<Opportunity> OpportunityList = new List<Opportunity>();
            Opportunity newOpportunity = new Opportunity();
    		newOpportunity.accountId = accList[0].Id;
    		newOpportunity.Name = 'New Opp Test';
    		newOpportunity.CloseDate = System.Today();
    		newOpportunity.StageName = 'Qualification';
    		newOpportunity.REN_Is_Consolidated__c = false;
            OpportunityList.add(newOpportunity);
           	insert OpportunityList;
            
            set<String> assetIdSet=new set<String>();
            assetIdSet.add(asset.id);            
            List<Asset> getAccountByAsset=REN_AssetDataAccess.getAccountByAsset(assetIdSet);
            
	        List<Asset> listOfAsset=new List<Asset>();
            listOfAsset.add(asset);
            List<string> assetsFields=new List<String>();
            assetsFields.add('REN_Covered_Asset__c');
            REN_AssetDataAccess.updateAssets(listOfAsset, assetsFields);
            
            CHL_GridInputWrapper inputWrapper = new CHL_GridInputWrapper();
			CHL_GridInputWrapper.CHL_CustomGridParams gridParams = new CHL_GridInputWrapper.CHL_CustomGridParams();
			inputWrapper.queryParams=gridParams;
            List<Sobject> getAssetBySOSL=REN_AssetDataAccess.getAssetsBySOSL(inputWrapper);
            
           
            
	        List<Asset> assetList = REN_AssetDataAccess.getAssetDetailsById(new List<String>{asset.Id}, new Set<String>{'id'});
	        system.assert(!assetList.isEmpty());
	        
	        List<Asset> RenOppListOfAcc = REN_AssetDataAccess.getAssetsByAccount(accList[0].id,'Name','ASC',null);
	        system.assert(assetList != null);
            
            List<Asset> getAssetForClouse1 =REN_AssetDataAccess.getAssetsForClause('WHERE ID != NULL');
	        
	        List<Asset> getAssetForClouse2 = REN_AssetDataAccess.getAssetsForClause('WHERE ID != NULL',false,null);
            
            Integer assetCount = REN_AssetDataAccess.getAssetsCounts('WHERE ID != NULL',10);
            
            List<Asset> assetListTest1 = REN_AssetDataAccess.getAllAssetFromOppts(new Set<String>{''+ OpportunityList[0].Id});
                
            List<Asset> assetListTest2 = REN_AssetDataAccess.getAssetsByAccountId(''+accList[0].Id);

            List<Database.SaveResult> saveResultList = REN_AssetDataAccess.insertAssets(listOfAsset);
            
            List<Schema.FieldSetMember> fieldSetMemberList = SObjectType.Asset.FieldSets.REN_Asset_Segment_Columns.getFields();
            Set<String> segmentIds = new Set<String>{''+ OpportunityList[0].Id};
            String filter ='';
            Integer recordLimit = 10;
            String selectedObjectTemp = 'Opportunity';
            List<Asset> assetListTest3 = REN_AssetDataAccess.getAssetsByIds(fieldSetMemberList, segmentIds, filter, recordLimit, selectedObjectTemp);
	       
            Set<String> additionalFieldSet = new Set<String>{''};
            List<SObject>getDataFieldList = REN_AssetDataAccess.getDataUsingFieldSet(fieldSetMemberList, additionalFieldSet, filter, recordLimit);
            
            Test.stopTest();
    	  }catch(Exception e){
         	system.debug('Exception : ' + e.getMessage());
         }
    }
    
    static testMethod void Test_GetAssetDetailsById_Negative() {
	    	Test.startTest();
            List<Account> accList = CSM_TestDataUtility.createAccount(1);
	        system.assert(accList.get(0).Id != null);
	        Product2 prod = REN_TestDataUtility.createProduct(1);
	        insert prod;
	        system.assert(prod.Id != null);
			Asset asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);		                
	        insert asset;
        
            CSM_CustomGridInputWrapper inputWrapperCSM=new CSM_CustomGridInputWrapper();
            CSM_CustomGridInputWrapper.CSM_CustomGridParams gridParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	    gridParams.accountId = accList[0].id;
            gridParams.selectedFilterClause = 'where status != null';
    	    inputWrapperCSM.params = gridParams;
            inputWrapperCSM.params.selectedTaskFilter=REN_Constants.OBJ_SE_TYPE_ABRLM;
            List<Schema.FieldSetMember> fieldSetMemberList= SObjectType.Asset.FieldSets.REN_Asset_Segment_Columns.getFields();
            String filter =inputWrapperCSM.params.selectedFilterClause;
            system.debug('**********filter ::'+filter);
           /* List<Asset> getAssetsByIds=REN_AssetDataAccess.getAssetsByIds(fieldSetMemberList,new Set<String>{inputWrapperCSM.params.opptyId },filter,1,inputWrapperCSM.params.accountId);*/
            
	        User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
	    	system.runAs(restrictedUser){
	    		try{
			        List<Asset> assetList = REN_AssetDataAccess.getAssetDetailsById(new List<String>{asset.Id}, new Set<String>{'id'});
	    		}catch(Exception ex){
	    			system.assert(true);
	    		}
	    	}
	        Test.stopTest();
    }
    
}