@isTest
private class REN_OpptSplitTest
{
    
    static void setupOppt(String opptName, Boolean createLines)
    {
        Opportunity o = new Opportunity(Name = opptName, CloseDate = System.today(), StageName = 'Prospecting', Probability = 1.0);
        insert o;
        if(createLines)
        {
            String standardPriceBookId = Test.getStandardPricebookId();
            
            Product2 p2 = new Product2(Name='Test Product',isActive=true);
            insert p2;
            Product2 p2ex = [SELECT Name FROM Product2 WHERE Id = :p2.Id];
            System.assertEquals('Test Product', p2ex.Name);
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=p2.Id, UnitPrice=99, isActive=true);
            insert pbe;
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
        }
    }
    
    static testMethod void testNewSplit()
    {
        String opptName = 'Existing Oppt to Split 1';
        setupOppt(opptName, true);
        Opportunity o = [Select Id From Opportunity Where Name = :opptName];
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
	static testMethod void testcloneSplit()
    {
        String opptName = 'Clone Oppt to Split 1';
        setupOppt(opptName, true);
        Opportunity o = [Select Id From Opportunity Where Name = :opptName];
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
	static testMethod void testSplit_None()
    {
        String opptName = 'Oppt to Split - None';
        setupOppt(opptName, true);
        Opportunity o = [Select Id From Opportunity Where Name = :opptName];
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
}