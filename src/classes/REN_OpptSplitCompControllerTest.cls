@isTest(SeeAllData=false)
private class REN_OpptSplitCompControllerTest
{	
    static void setupAccount(String accountName)
	{
		Account a = new Account(Name = accountName);
		System.assert(a !=null);
		insert a;
	}
    
    static void setupOppt(String opptName, Boolean createLines)
    {	
        String accountName = 'TestOpp Account ' + opptName;
     	setupAccount(accountName);
     	Account a = [Select Id From Account Where Name = :accountName];
        System.assert(a !=null);
        
        Opportunity o = new Opportunity(Name = opptName, AccountId = a.Id, CloseDate = System.today(), StageName = 'Prospecting', Probability = 1.0);
        insert o;
        
        if(createLines)
        {
            String standardPriceBookId = Test.getStandardPricebookId();
            
            Product2 p2 = new Product2(Name='Test Product',isActive=true);
            insert p2;
            System.assert(p2.id !=null);
            Product2 p2ex = [SELECT Name FROM Product2 WHERE Id = :p2.Id];
            System.assertEquals('Test Product', p2ex.Name);
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=p2.Id, UnitPrice=99, isActive=true);
            insert pbe;
            System.assert(pbe.id !=null);
            PricebookEntry pbeex = [SELECT Pricebook2Id FROM PricebookEntry WHERE Id = :pbe.Id];
            System.assertEquals(standardPriceBookId, pbeex.Pricebook2Id);
            
            List<OpportunityLineItem> lstOL = new List<OpportunityLineItem>();
            for(Integer i=0; i<5; i++)
            {
                OpportunityLineItem newol = new OpportunityLineItem();
                newol.UnitPrice = 50000;
                newol.ServiceDate = System.today();
                newol.Description = 'Desc 1';
                newol.Quantity = 1;
                newol.PricebookEntryId = pbeex.Id;
                newol.OpportunityId = o.Id;
				newol.REN_Is_CLM_Renewal__c = true;
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
			
			CHL_Partner_Opportunity__c partOpp = CHL_TestUtility.createPartnerOpportunity(o.id);
       		insert partOpp;
       
	       	CHL_Partner_Renewal_Relationship__c pRR = new CHL_Partner_Renewal_Relationship__c();
	       	pRR.CHL_Partner_Opportunity__c = partOpp.id;
	       	pRR.CHL_Renewal_Relationship__c = renLst[0].id;
	       	insert pRR;
	     }
        
       
    }
    @isTest
    static void testNewSplit()
    {
        String opptName = 'Existing Oppt to Split 1';
        setupOppt(opptName, true);
        Opportunity o = [Select Id From Opportunity Where Name = :opptName];
        System.assert(o !=null);
        List<OpportunityLineItem> lstOL = [Select Id From OpportunityLineItem Where OpportunityId = :o.Id];
        PageReference pageRef = Page.REN_OpptSplitWizard;
        String olStr = '';
        for(OpportunityLineItem ol :lstOL)
        {
            olStr += ol.id + '-';
        }
        PageRef.getParameters().put('opptLns',olStr);
        PageRef.getParameters().put('opptId',o.id);
        Test.setCurrentPage(pageRef);
        REN_OpptSplitCompController compController = new REN_OpptSplitCompController();
        compController.getOpptTypes();
        compController.selectedOpptType = 'new';
		compController.opportunityId4Split = o.id;
		compController.oppLinesStr = olStr;
        compController.processOpptTypeChange();
		Opportunity opp = new Opportunity();
		opp.name = 'New Split Oppty';
		opp.CloseDate = System.today();
		opp.StageName = 'Prospecting';
		//compController.opLn.OpportunityId = o.id;
		//compController.opportunityPicked();
		compController.currentOpptDisplayed = opp;
        //compController.getAllOpptLines(o.id);
        compController.splitSelected();
        compController.cancel();
    }
    @isTest
	static void testcloneSplit()
    {
        String opptName = 'Clone Oppt to Split 1';
        setupOppt(opptName, true);
        Opportunity o = [Select Id From Opportunity Where Name = :opptName];
        System.assert(o !=null);
        List<OpportunityLineItem> lstOL = [Select Id From OpportunityLineItem Where OpportunityId = :o.Id];
        PageReference pageRef = Page.REN_OpptSplitWizard;
        String olStr = '';
        for(OpportunityLineItem ol :lstOL)
        {
            olStr += ol.id + '-';
        }
        PageRef.getParameters().put('opptLns',olStr);
        PageRef.getParameters().put('opptId',o.id);
        Test.setCurrentPage(pageRef);
        REN_OpptSplitCompController compController = new REN_OpptSplitCompController();
        compController.getOpptTypes();
        compController.selectedOpptType = 'clone';
		compController.opportunityId4Split = o.id;
		compController.oppLinesStr = olStr;
        compController.processOpptTypeChange();
		compController.splitSelected();
	}
	@isTest
	static void testSplit_None()
    {
        String opptName = 'Oppt to Split - None';
        setupOppt(opptName, true);
        Opportunity o = [Select Id From Opportunity Where Name = :opptName];
        System.assert(o !=null);
        List<OpportunityLineItem> lstOL = [Select Id From OpportunityLineItem Where OpportunityId = :o.Id];
        PageReference pageRef = Page.REN_OpptSplitWizard;
        String olStr = '';
        for(OpportunityLineItem ol :lstOL)
        {
            olStr += ol.id + '-';
        }
        PageRef.getParameters().put('opptLns',olStr);
        PageRef.getParameters().put('opptId',o.id);
        Test.setCurrentPage(pageRef);
        REN_OpptSplitCompController compController = new REN_OpptSplitCompController();
        compController.getOpptTypes();
        compController.selectedOpptType = 'none';
        compController.processOpptTypeChange();
	}
	@isTest
	static void testExistingOppSplit()
    {
        String opptName = 'Existing Oppt to Split 2';
        setupOppt(opptName, true);
        String opptname2 = 'Existing oppt split 2';
        setupOppt(opptname2, true);
        Opportunity o = [Select Id From Opportunity Where Name = :opptName limit 1];
        System.assert(o !=null);
        Opportunity o2 = [Select Id From Opportunity Where Name = :opptname2 limit 1];
        System.assert(o2 !=null);
        List<OpportunityLineItem> lstOL = [Select Id From OpportunityLineItem Where OpportunityId = :o.Id];
        PageReference pageRef = Page.REN_OpptSplitWizard;
        String olStr = '';
        for(OpportunityLineItem ol :lstOL)
        {
            olStr += ol.id + '-';
        }
        PageRef.getParameters().put('opptLns',olStr);
        PageRef.getParameters().put('opptId',o.id);
        Test.setCurrentPage(pageRef);
        REN_OpptSplitCompController compController = new REN_OpptSplitCompController();
        compController.getOpptTypes();
        compController.selectedOpptType = 'existing';
		compController.opportunityId4Split = o.id;
        compController.processOpptTypeChange();
		compController.oppLinesStr = olStr;
		compController.opln.OpportunityId = o2.id;
		compController.opportunityPicked();
		compController.splitSelected();
	}
	
	@isTest
	static void testRRSplitClone(){
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test Opp');
		testDataSetup.createRenewConfigurations();
	   	testDataSetup.renewDataSetup(1, 1, 1);
    	testDataSetup.resetAllTriggersTo(true);
		testDataSetup.opportunityList[0].stageName = 'Closed Won';
		update testDataSetup.opportunityList[0];
    	testDataSetup.resetAllTriggersTo(true);
		
        List<REN_Renews_To__c> lstOL = [Select r.REN_Renews_To__c, r.Id From REN_Renews_To__c r where r.REN_Asset__r.REN_Opportunity__c = :testDataSetup.opportunityList[0].Id];
        String rrs = '';
        for(REN_Renews_To__c ol :lstOL){
            rrs += ol.id + '-';
        }
        
        PageReference pageRef = Page.REN_OpptSplitWizard;
        PageRef.getParameters().put('rra','true');
        PageRef.getParameters().put('opptId',lstOL[0].REN_Renews_To__c);
        Test.setCurrentPage(pageRef);
    	
    	Test.startTest(); 
        REN_OpptSplitCompController compController = new REN_OpptSplitCompController();
        compController.isConsolidatedRR = 'true';
        compController.selectedOpptType = 'clone';
        compController.getOpptTypes();
    	System.debug('----------------------------------------------------------------------\nPrint: ' + compController);
		compController.opportunityId4Split = lstOL[0].REN_Renews_To__c;
		//compController.rrIdsStr = rrs;
        compController.processOpptTypeChange();
		compController.splitSelected();
        System.assert(lstOL[0].REN_Renews_To__c != null);
		Test.stopTest();
	}
	@isTest
	static void testRRSplitExisting(){
		REN_TestDataSetup testDataSetup = new REN_TestDataSetup('Test Opportunity');
		testDataSetup.createRenewConfigurations();
	   	testDataSetup.renewDataSetup(1, 1, 1);
    	testDataSetup.resetAllTriggersTo(true);
		testDataSetup.opportunityList[0].stageName = 'Closed Won';
		update testDataSetup.opportunityList[0];
    	testDataSetup.resetAllTriggersTo(true);
		
        List<REN_Renews_To__c> lstOL = [Select r.REN_Renews_To__c, r.Id From REN_Renews_To__c r where r.REN_Asset__r.REN_Opportunity__c = :testDataSetup.opportunityList[0].Id];
        String rrs = '';
        for(REN_Renews_To__c ol :lstOL){
            rrs += ol.id + '-';
        }
    	System.debug(lstOL + '----------------------------------------------------------------------\nrrs: ' + rrs);
        
        PageReference pageRef = Page.REN_OpptSplitWizard;
        PageRef.getParameters().put('rrs','true');
        PageRef.getParameters().put('opptId',lstOL[0].REN_Renews_To__c);
        Test.setCurrentPage(pageRef);
    	
    	Test.startTest(); 
        REN_OpptSplitCompController compController = new REN_OpptSplitCompController();
        compController.selectedOpptType = 'existing';
        //compController.oppLinesStr = rrs;
        compController.rrIdsStr = rrs;
        compController.getOpptTypes();
    	System.debug('----------------------------------------------------------------------\nPrint: ' + compController);
		compController.opportunityId4Split = lstOL[0].REN_Renews_To__c;
        compController.processOpptTypeChange();
		compController.opln.OpportunityId = testDataSetup.opportunityList[0].Id;
		compController.opportunityPicked();
        compController.splitSelected();
        
        System.assert(lstOL[0].REN_Renews_To__c != null);
        
		Test.stopTest();
	}
}