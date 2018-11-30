@isTest
private class REN_ConsolidateOpportunityControllerTest 
{
	static void setupAccount(String accountName)
	{
		Account a = new Account(Name = accountName);
		System.assert(a !=null);
		insert a;
	}
	
	
	static void setupOppt(Id accId, String opptName, Boolean createLines, String customPricebookName)
    {
        Opportunity o = new Opportunity(Name = opptName, CloseDate = System.today(), 
            StageName = 'Prospecting', Probability = 1.0, AccountId = accId);
        insert o;
        if(createLines)
        {
        	Pricebook2 customPB;
        	if (customPricebookName != null)
            {
            	customPB = new Pricebook2(Name=customPricebookName, isActive=true);
                insert customPB;
            }
            String standardPriceBookId = Test.getStandardPricebookId();
            Product2 p2 = new Product2(Name='Test Product',isActive=true);
            insert p2;
            System.assert(p2.id !=null);
            Product2 p2ex = [SELECT Name FROM Product2 WHERE Id = :p2.Id];
            System.assertEquals('Test Product', p2ex.Name);
            
            PricebookEntry standardPbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=p2.Id, UnitPrice=99, isActive=true);
            insert standardPbe;
            System.assert(standardPbe.id !=null);
            PricebookEntry standardPbeex = [SELECT Pricebook2Id FROM PricebookEntry WHERE Id = :standardPbe.Id];
            System.assertEquals(standardPriceBookId, standardPbeex.Pricebook2Id);
            
            Boolean simplifiedDataModelEnabled;
            SS_License__c licenseInstance = SS_License__c.getOrgDefaults();
		    if (licenseInstance != null) {
			    simplifiedDataModelEnabled = licenseInstance.Simplified_Data_Model_Is_Enabled__c;
		    }
            
            PricebookEntry customPbeex = null;
            if (customPricebookName != null)
            {
                PricebookEntry customPbe = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p2.Id, 
                UnitPrice = 100, IsActive = true, UseStandardPrice = false);
                insert customPbe;   
                System.assert(customPbe.id !=null);
	            customPbeex = [SELECT Pricebook2Id FROM PricebookEntry WHERE Id = :customPbe.Id];
	            System.assertEquals(customPB.Id, customPbeex.Pricebook2Id);  
            }
            
            List<OpportunityLineItem> lstOL = new List<OpportunityLineItem>();
            for(Integer i=0; i<5; i++)
            {
                OpportunityLineItem newol = new OpportunityLineItem();
                newol.UnitPrice = 50000;
                newol.ServiceDate = System.today();
                newol.Description = 'Desc 1';
                newol.Quantity = 1;
                if (customPbeex == null)
                {
                    newol.PricebookEntryId = standardPbeex.Id;
                }
                else
                {
                	newol.PricebookEntryId = customPbeex.Id;
                }
                newol.OpportunityId = o.Id;
                
                if(simplifiedDataModelEnabled){
                	newol.REN_Is_CLM_Renewal__c = false;
                } else {
                	newol.REN_Is_CLM_Renewal__c = true;
                }
                
                lstOL.add(newol);
            }
            insert lstOL;
            
            List<REN_Renews_To__c> renLst = new List<REN_Renews_To__c>(); 
        	for(integer i=0;i<lstOL.size();i++){
		        REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
				renRelationObj.Name = 'Ren-OPP';
				//renRelationObj.REN_Asset__c = asset.Id;
				renRelationObj.REN_Renews_To__c = o.Id;
				//renRelationObj.REN_Renewal_Product_Line_Id__c = lstOL[i].Id;
			    renRelationObj.REN_Product__c = p2.id;
				renLst.add(renRelationObj);
        	}
			insert renLst;
			
			/*CHL_Partner_Opportunity__c partOpp = CHL_TestUtility.createPartnerOpportunity(o.id);
       		insert partOpp;
       
	       	CHL_Partner_Renewal_Relationship__c pRR = new CHL_Partner_Renewal_Relationship__c();
	       	pRR.CHL_Partner_Opportunity__c = partOpp.id;
	       	pRR.CHL_Renewal_Relationship__c = renLst[0].id;
	       	insert pRR; */
	     }
    }
        
     @isTest
     static void testEmptyOpportunityList()
     {
     	PageReference pageRef = Page.REN_ConsolidateOpportunityRedirect;
     	Test.setCurrentPage(pageRef);
     	
     	List<Opportunity> lst = new List<Opportunity>();        
        REN_ConsolidateOpptyRedirectController redirectController = new REN_ConsolidateOpptyRedirectController(new ApexPages.StandardSetController(lst));
     	
     	System.assert(redirectController.returnPage() == null);
     	
     	System.assert(redirectController.consolidateOpportunity() == null);
     }
     
     @isTest
     static void testOpportunityListWithAccount()
     {   
     	String accountName = 'Test Account';
     	setupAccount(accountName);
     	Account a = [Select Id From Account Where Name = :accountName];
        System.assert(a !=null);
        
        String oppName = 'Test Opportunity';
        setupOppt(a.Id, oppName, true, null);
        Opportunity o = [Select Id,StageName,CloseDate,Name From Opportunity Where Name = :oppName];
        System.assert(o !=null);
        
      
        oppName = 'Test Opportunity2';
        setupOppt(a.Id, oppName, true, null);
        List<Opportunity> oList = [Select Id,StageName,CloseDate,Name From Opportunity Where AccountId = :a.Id];
        System.assert(!oList.isEmpty());
        
        PageReference pageRef = Page.REN_ConsolidateOpportunityRedirect;
        pageRef.getParameters().put('Id',a.id);
     	Test.setCurrentPage(pageRef);
     	
     	ApexPages.StandardSetController ssController = new ApexPages.StandardSetController(
     	    new List<Opportunity>());
     	ssController.setSelected(oList);
     	
        REN_ConsolidateOpptyRedirectController redirectController = 
            new REN_ConsolidateOpptyRedirectController(ssController);
        System.assert(redirectController.returnPage() != null);
        
        redirectController.selectedOpportunityIds = o.Id;
        System.assert(redirectController.consolidateOpportunity() != null);
        
        o.REN_Is_Consolidated__c = true;
        update o;
        System.assert(redirectController.consolidateOpportunity() == null);
     }
     
     @isTest
     static void testConsolidatePageRealTime()
     {
     	String accountName = 'Test Account';
     	setupAccount(accountName);
     	Account a = [Select Id From Account Where Name = :accountName];
        System.assert(a !=null);
        
        String oppName = 'Test Opportunity';
        setupOppt(a.Id, oppName, true, null);
        Opportunity target = [Select Id,StageName,CloseDate,Name From Opportunity Where Name = :oppName];
        System.assert(target !=null);
        
      
        oppName = 'Test Opportunity2';
        setupOppt(a.Id, oppName, true, null);
        List<Opportunity> oList = [Select Id,StageName,CloseDate,Name From Opportunity Where AccountId = :a.Id];
        System.assert(!oList.isEmpty());
     	
     	
     	PageReference pageRef = Page.REN_ConsolidateOpportunity;
        pageRef.getParameters().put('parentId',a.id);
        pageRef.getParameters().put('opptyIds',oList[0].Id + '-' + oList[1].Id);
     	Test.setCurrentPage(pageRef);
     	
     	
     	CSM_Admin__c csmAdmin = CSM_AdminDataAccess.getCSMAdminInstance();
     	csmAdmin.REN_Consolidate_Real_Oli_Thresh__c = 30;
     	upsert csmAdmin;
     	REN_ConsolidateOpportunityController controller = new REN_ConsolidateOpportunityController();
        REN_ConsolidateOpportunityController controllerObj = new REN_ConsolidateOpportunityController();
     	System.assert(!controller.getOpptTypes().isEmpty());
     	
     	controller.selectedOpptType = OpportunityType.EXISTING.name();
     	PageReference pfTest = controller.processOpptTypeChange();
     	System.assert(pfTest == null);
     	
        controllerObj.selectedOpptType = OpportunityType.EXISTING.name();
        pfTest = controllerObj.processOpptTypeChange();
     	System.assert(pfTest == null);
         
     	controller.selectedOpptType = OpportunityType.NEW_OPP.name();
        pfTest = controller.processOpptTypeChange();
     	System.assert(pfTest == null);
     	
     	controller.selectedOpptType = OpportunityType.NONE.name();
     	pfTest = controller.processOpptTypeChange();
     	System.assert(pfTest == null);
     	
     	List<OpportunityLineItem> existLineList = [Select Id, OpportunityId From OpportunityLineItem
     	  Where OpportunityId = :oList[0].Id];
     	controller.newExistingOpp = existLineList[0];
     	pfTest = controller.opportunityPicked();
     	System.assert(pfTest == null);
         
        List<OpportunityLineItem> existLineObjList = [Select Id From OpportunityLineItem
     	  Where OpportunityId = :oList[0].Id];
     	controllerObj.newExistingOpp = existLineObjList[0];
     	pfTest = controllerObj.opportunityPicked();
     	System.assert(pfTest == null);
     	
     	oppName = 'Test Opportunity3';
        setupOppt(a.Id, oppName, true, null);
        List<Opportunity> oList3 = [Select Id,StageName,CloseDate,Name From Opportunity Where name = :oppName];
        system.debug('oList3---'+oList3);
        List<OpportunityLineItem> oLineList = [Select Id, OpportunityId From OpportunityLineItem
     	  Where OpportunityId = :oList3[0].Id];
        System.assert(!oLineList.isEmpty());
       
        controller.targetOppt = target;
        controller.currentOpptDisplayed = target;
     	
     	controller.newExistingOpp = oLineList[0];
     	pfTest = controller.opportunityPicked();
     	System.assert(pfTest == null);
     	
     	pfTest = controller.cancel();
     	System.assert(pfTest != null);
     	
        //controller.selectedOpptType = OpportunityType.EXISTING.name();
     	pfTest = controller.consolidateRealTime();      
     	System.assert(pfTest != null);
           	
     	//test different price books
     	oppName = 'Test Opportunity4';
        setupOppt(a.Id, oppName, true, 'Custom Price');
        oList3= [Select Id,StageName,CloseDate,Name From Opportunity Where name = :oppName];
        oLineList = [Select Id, OpportunityId From OpportunityLineItem
     	  Where OpportunityId = :oList3[0].Id];
     	controller.newExistingOpp = oLineList[0];
     	pfTest = controller.opportunityPicked();
     	System.assert(pfTest == null);
     	
     	//test consolidated opportunity picked
     	oppName = 'Test Consolidated';
        setupOppt(a.Id, oppName, true, null);
        oList3= [Select Id,StageName,CloseDate,Name From Opportunity Where name = :oppName];
        oList3[0].REN_Is_Consolidated__c = true;
        update oList3;
        oLineList = [Select Id, OpportunityId From OpportunityLineItem
     	  Where OpportunityId = :oList3[0].Id];
     	controller.newExistingOpp = oLineList[0];
     	pfTest = controller.opportunityPicked();
     	System.assert(pfTest == null);
     	
     	oList3[0].REN_Is_Consolidated__c = false;
     	oList3[0].StageName = 'Closed Won';
     	update oList3;
     	pfTest = controller.opportunityPicked();
     	System.assert(pfTest == null);
     	
     	oList3[0].StageName = 'Prospecting';
     	update oList3;
     	
     	controller.consolidateOpps();
    }
    
     @isTest
     static void testConsolidatePageRequest()
     {
     	String accountName = 'Test Account';
     	setupAccount(accountName);
     	Account a = [Select Id From Account Where Name = :accountName];
        System.assert(a !=null);
        
        String oppName = 'Test Opportunity';
        setupOppt(a.Id, oppName, true, null);
        Opportunity o = [Select Id,StageName,CloseDate,Name From Opportunity Where Name = :oppName];
        System.assert(o !=null);
        
      
        oppName = 'Test Opportunity2';
        setupOppt(a.Id, oppName, true, null);
        List<Opportunity> oList = [Select Id,StageName,CloseDate,Name From Opportunity Where AccountId = :a.Id];
        System.assert(!oList.isEmpty());
     	
     	
     	PageReference pageRef = Page.REN_ConsolidateOpportunity;
        pageRef.getParameters().put('parentId',a.id);
        pageRef.getParameters().put('opptyIds',oList[0].Id + '-' + oList[1].Id);
     	Test.setCurrentPage(pageRef);
     	
     	
     	CSM_Admin__c csmAdmin = CSM_AdminDataAccess.getCSMAdminInstance();
     	csmAdmin.REN_Consolidate_Real_Oli_Thresh__c = 1;
     	upsert csmAdmin;
     	REN_ConsolidateOpportunityController controller = new REN_ConsolidateOpportunityController();
     	System.assert(!controller.getOpptTypes().isEmpty());
     	
     	controller.selectedOpptType = OpportunityType.EXISTING.name();
     	PageReference pfTest = controller.processOpptTypeChange();
     	System.assert(pfTest == null);
     	
     	oppName = 'Test Opportunity3';
        setupOppt(a.Id, oppName, true, null);
        List<Opportunity> oList3 = [Select Id,StageName,CloseDate,Name From Opportunity Where name = :oppName];
        List<OpportunityLineItem> oLineList = [Select Id, OpportunityId From OpportunityLineItem
     	  Where OpportunityId = :oList3[0].Id];
        System.assert(!oLineList.isEmpty());
        
     	controller.newExistingOpp = oLineList[0];
     	pfTest = controller.opportunityPicked();
     	System.assert(pfTest == null);
     	
     	pfTest = controller.requestConsolidation();
     	pfTest = controller.redirectAfterConsolidation();
     	System.assert(pfTest != null);
     	
     	 
    }
    private enum OpportunityType {NONE, NEW_OPP, EXISTING}
}