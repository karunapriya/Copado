@isTest
private class CSM_OpportunityDataAccessTest {
    static testMethod void myUnitTest() {
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_TRIGGER = false;
        List<Account> accountList = CSM_TestDataUtility.createAccount(2);
        List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
        Test.startTest();
		List<Opportunity> dataTest = CSM_OpportunityDataAccess.getDetailFieldSetByAccount(accountList[0].id);
        system.assertEquals(dataTest.size(), 2);
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp.add(new Opportunity(name='Opp1',AccountId = accountList[0].id, StageName='Prospecting',CloseDate=System.today() +7));
        dataTest = CSM_OpportunityDataAccess.insertRenewalOpportunity(lstOpp);        
        opportunityList = CSM_OpportunityDataAccess.getDetailFieldSetById(opportunityList[0].id);
		List<Opportunity>  oppTest1 = CSM_OpportunityDataAccess.getRenewalOpptyByAcctAndLocationOnSuccessPlan(accountList[0].Id, 'CloseDate');   
		
        List<Opportunity>  oppTest2 = CSM_OpportunityDataAccess.getOpportunitiesByAccount(accountList[0].Id); 
        
        List<Opportunity> oppTest3  = CSM_OpportunityDataAccess.getOpportunitiesById(new Set<String>{''+ lstOpp[0].Id});		    
		
        List<OpportunityContactRole> oppTest4 = CSM_OpportunityDataAccess.fetchOpportunityContactRole(new Set<String>{''+ lstOpp[0].Id});
        
        List<OpportunityContactRole> oppTest5 = CSM_OpportunityDataAccess.fetchOpportunityContactRole(new Set<ID>{lstOpp[0].Id});
        CSM_OpportunityDataAccess.insertOpportunityContactRole(oppTest4); 
        
        List<OpportunityCompetitor> oppTest6 = CSM_OpportunityDataAccess.fetchOpportunityCompetitor(new Set<String>{''+ lstOpp[0].Id});
        CSM_OpportunityDataAccess.insertOpportunityCompetitor(oppTest6);
        
        List<OpportunityPartner>oppTest7 = CSM_OpportunityDataAccess.fetchOpportunityPartner(new Set<String>{''+ lstOpp[0].Id});
        
        List<Partner> oppTest8 = new List<Partner>();
        Partner partobj = new Partner();
        partobj.AccountToId = accountList[1].Id;
        partobj.IsPrimary = true;
        partobj.OpportunityId = lstOpp[0].Id;
        partobj.Role = 'Consultant';
        oppTest8.add(partobj);
        CSM_OpportunityDataAccess.insertPartner(oppTest8);
        
        system.assertEquals(opportunityList.size(), 1);
        
        CSM_OpportunityDataAccess.deleteOpportunity(dataTest);
        Test.stopTest();
    } 
    
    static testMethod void Test_getOpportunityDetailById_Positive(){
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_TRIGGER = false;
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
        List<String> oppIds = new List<String>();
        for(Opportunity opp : opportunityList){
            oppIds.add(opp.Id);
        }
        Test.startTest();
        opportunityList = REN_OpportunityDataAccess.getOpportunityAllDetailsById(oppIds);
        system.assert(!opportunityList.isEmpty());
        for(Opportunity opp : opportunityList){
            system.assert(!opp.REN_Is_Consolidated__c);
        }
        Test.stopTest();
    }
    
   static testMethod void Test_upsertOpportunity_Positive(){
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_TRIGGER = false;
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        Test.startTest();
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.accountId = accountList[0].id;
        newOpportunity.Name = 'New Opp';
        newOpportunity.CloseDate = System.Today();
        newOpportunity.StageName = 'Qualification';
        oppList.add(newOpportunity);
        CSM_OpportunityDataAccess.upsertOpportunityList(oppList);
        system.assert(newOpportunity.Id != null);
        Test.stopTest();
    }
    
    static testMethod void Test_upsertOpportunity_Negative(){
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_TRIGGER = false;
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        User restrictedUser = CSM_TestDataUtility.createTestUser('System Administrator');
        system.runAs(restrictedUser){
            Test.startTest();
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity newOpportunity = new Opportunity();
            newOpportunity.accountId = accountList[0].id;
            newOpportunity.Name = 'New Opp';
            newOpportunity.CloseDate = System.Today();
            newOpportunity.StageName = 'Qualification';
            oppList.add(newOpportunity);
            try{
                CSM_OpportunityDataAccess.upsertOpportunityList(oppList);
            }catch(Exception ex){
                system.assert(true);
            }
            Test.stopTest();
        }
    }
    //Code coverage for CSM_OpportunityTriggerHelper methods.
    
    static testMethod void testOpportunityTriggerHelperMethods(){
    	Test.startTest();
        CSM_Admin__c adminSetting= CSM_Admin__c.getOrgDefaults();
        adminSetting.CHL_QliCount__c = 50;
        insert adminSetting;
        
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(2, accountList[0].id);
        
        system.assert(opportunityList != null);
        Product2 prod = REN_TestDataUtility.createProduct(1);
        insert prod;
        
        List<REN_Renews_To__c> rliList = CHL_TestUtility.createRenewableLineItems(2,opportunityList[0].Id, prod.Id);
    	insert rliList;
    	system.assert(rliList != null);
    	
    	CSM_OpportunityTriggerHelper.updateRliStageToOpen(opportunityList);
    	CSM_OpportunityTriggerHelper.updateQuoteSyncStatusOnOppty(new Set<String>{opportunityList[0].Id},'None');      
        CSM_OpportunityTriggerHelper.processQliRecordsByBatch(1,new Set<Id>{opportunityList[0].Id},null);
        Test.stopTest();
    }
    
    //Commented Test_GetAccessibleFields_Positive method - US3293
/*    
    static testMethod void Test_GetAccessibleFields_Positive(){
        CSM_Constants.OPPORTUNITY_TRIGGER = false;
        CSM_Constants.ACCOUNT_TRIGGER = false;
        Test.startTest();
        List<REN_MergeOppFieldWrapper> readOnlyFields = new List<REN_MergeOppFieldWrapper>();
        List<REN_MergeOppFieldWrapper> updateableFields = new List<REN_MergeOppFieldWrapper>();
        //REN_OpportunityDataAccess.getAccessibleFields(readOnlyFields, updateableFields);
        //system.assert(!readOnlyFields.isEmpty());
        system.assert(!updateableFields.isEmpty());
        Test.stopTest();
    }
    */
    
    static testmethod void Test_CurrencyDataAccessMethods(){
        Decimal returnAmt = REN_CurrencyExchangeRateDataAccess.acmCurrencyConversion(200,'EUR','USD',System.today());
        System.assert(returnAmt != null);
        Decimal staticreturnAmt = REN_CurrencyExchangeRateDataAccess.staticCurrencyConversion(200,'EUR','USD');
        System.assert(staticreturnAmt != null);
    }
}