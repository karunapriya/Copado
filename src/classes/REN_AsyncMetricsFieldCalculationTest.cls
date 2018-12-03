@isTest
public class REN_AsyncMetricsFieldCalculationTest{
    
    @testSetup static void setup(){
        Account account = CHL_TestUtility.partnerAccount();
        insert account;
        List<Opportunity> oppList = CHL_TestUtility.createOpportunity(2, account.Id);
        insert oppList;
        List<Product2> productList = CHL_TestUtility.createProducts(1);
        insert productList;
        List<PricebookEntry> pbeList = CHL_TestUtility.createPricebookEntry(productList,Test.getStandardPricebookId());
        insert pbeList;
        
        List <OpportunityLineItem> opliList = CHL_TestUtility.createOplis(oppList,pbeList);
        insert opliList;
        
        System.assertEquals(productList.size(), 1);
    }
    
    static testmethod void batchForRliAndOli(){
        Set<ID> oppoIdSet = new Set<ID>();
        List<Opportunity> oppList = new List<Opportunity>([Select id from Opportunity where name like '%TestOpp%']);
        System.assert(!oppList.isEmpty());
        oppList[0].REN_Is_CLM_Renewal__c = true;
        oppList[0].REN_Renewal_Metrics_Status__c = 'Not Calculated';
        oppList[0].REN_Metrics_Calculation_Date__c = System.now().addMinutes(-1 * (REN_AsyncMetricsFCalculationDispatcher.batchInterval+1));
        update oppList;
        oppoIdSet.add(oppList[0].Id);
        List<Product2> productList = CHL_TestUtility.createProducts(1);
        insert productList;
        List<REN_Renews_To__c> rliList = CHL_TestUtility.createRenewableLineItems(2,oppList[0].Id,productList[0].Id);
        insert rliList;
        REN_AsyncUtil.scheduleMetricsFieldCalculation();
        REN_AsyncMetricsFieldCalBatch batch = new REN_AsyncMetricsFieldCalBatch();
        REN_AsyncMetricsFCalculationDispatcher batchSchedule = new REN_AsyncMetricsFCalculationDispatcher();
        //System.schedule('jobName','0 5 * * * ? ', batchSchedule);
        batch.calculationType = 'RLI-OLI';
        Database.executeBatch(batch);
        
        REN_FiscalYearOppBatch fiscalBatch = new REN_FiscalYearOppBatch();
        fiscalBatch.impactedOppId = oppoIdSet;
        Database.executeBatch(fiscalBatch);
    }
    
    static testmethod void batchForRliAndOliFailureId(){
        List<Opportunity> oppList = new List<Opportunity>([Select id from Opportunity where name like '%TestOpp%']);
        System.assert(!oppList.isEmpty());
        oppList[0].REN_Renewal_Metrics_Status__c = '';
        update oppList;
        Set<ID> oppoIdSet = new Set<ID>();
        oppoIdSet.add(oppList[0].Id);
        
        REN_AsyncMetricsFieldCalBatch batch = new REN_AsyncMetricsFieldCalBatch();
        batch.calculationType = 'RLI-OLI';
        batch.failureRecordSet = oppoIdSet;
        batch.impactedOpportunitySet = oppoIdSet;
        Database.executeBatch(batch);
    }
    
    static testmethod void batchForOli(){
        List<Opportunity> oppList = new List<Opportunity>([Select id from Opportunity where name like '%TestOpp%']);
        System.assert(!oppList.isEmpty());
        oppList[0].REN_Renewal_Metrics_Status__c = 'Not Calculated';
        oppList[0].REN_Metrics_Calculation_Date__c = System.now().addMinutes(-1 * (REN_AsyncMetricsFCalculationDispatcher.batchInterval+1));
        update oppList;
        Set<ID> oppoIdSet = new Set<ID>();
        oppoIdSet.add(oppList[0].Id);
        REN_AsyncUtil.scheduleMetricsFieldCalculationForOLI(oppoIdSet);
        
        List<OpportunityLineItem> opliList = new List<OpportunityLineItem>([SELECT id from OpportunityLineItem where opportunityId IN: oppoIdSet]);
        System.assert(!opliList.isEmpty());
        REN_AsyncMetricsFieldCalBatch batch = new REN_AsyncMetricsFieldCalBatch();
        batch.calculationType = 'OLI';
        Database.executeBatch(batch);
    }
    
    static testmethod void batchForOliFailureId(){
        List<Opportunity> oppList = new List<Opportunity>([Select id from Opportunity where name like '%TestOpp%']);
        System.assert(!oppList.isEmpty());
        oppList[0].REN_Renewal_Metrics_Status__c = '';
        update oppList;
        Set<ID> oppoIdSet = new Set<ID>();
        oppoIdSet.add(oppList[0].Id);
        REN_AsyncUtil.scheduleMetricsFieldCalculationForOLI(oppoIdSet);
        
        List<OpportunityLineItem> opliList = new List<OpportunityLineItem>([SELECT id from OpportunityLineItem where opportunityId IN: oppoIdSet]);
        System.assert(!opliList.isEmpty());
        REN_AsyncMetricsFieldCalBatch batch = new REN_AsyncMetricsFieldCalBatch();
        batch.calculationType = 'OLI';
        batch.failureRecordSet = oppoIdSet;
        Database.executeBatch(batch);
    }
    
    static testmethod void batchForRli(){
        List<Opportunity> oppList = new List<Opportunity>([Select id from Opportunity where name like '%TestOpp%']);
        System.assert(!oppList.isEmpty());
        oppList[0].REN_Renewal_Metrics_Status__c = 'Not Calculated';
        oppList[0].REN_Metrics_Calculation_Date__c = System.now().addMinutes(-1 * (REN_AsyncMetricsFCalculationDispatcher.batchInterval+1));
        update oppList;
        Set<ID> oppoIdSet = new Set<ID>();
        oppoIdSet.add(oppList[0].Id);
        List<Product2> productList = CHL_TestUtility.createProducts(1);
        insert productList;
        List<REN_Renews_To__c> rliList = CHL_TestUtility.createRenewableLineItems(2,oppList[0].Id,productList[0].Id);
        insert rliList;
        
        REN_AsyncMetricsFieldCalBatch batch = new REN_AsyncMetricsFieldCalBatch();
        batch.calculationType = 'RLI';
        Database.executeBatch(batch);
    }
    
    static testmethod void batchForRliFailureid(){
        List<Opportunity> oppList = new List<Opportunity>([Select id from Opportunity where name like '%TestOpp%']);
        System.assert(!oppList.isEmpty());
        oppList[0].REN_Renewal_Metrics_Status__c = '';
        update oppList;
        Set<ID> oppoIdSet = new Set<ID>();
        oppoIdSet.add(oppList[0].Id);
        List<Product2> productList = CHL_TestUtility.createProducts(1);
        insert productList;
        List<REN_Renews_To__c> rliList = CHL_TestUtility.createRenewableLineItems(2,oppList[0].Id,productList[0].Id);
        insert rliList;
        
        REN_AsyncMetricsFieldCalBatch batch = new REN_AsyncMetricsFieldCalBatch();
        batch.calculationType = 'RLI';
        batch.failureRecordSet = oppoIdSet;
        Database.executeBatch(batch);
    }
    
    static testmethod void coverScheduleExecute(){
        REN_AsyncMetricsFieldCalculation batch = new REN_AsyncMetricsFieldCalBatch();
        batch.execute(null);
        System.assert(batch != Null);
    }
    
    static testmethod void coverDispatcherExecute(){
        Test.startTest();
        REN_AsyncMetricsFCalculationDispatcher pr = new REN_AsyncMetricsFCalculationDispatcher();
        String sch = '0 0 22 * * ?';
        system.schedule('Test Password Reminder', sch, pr);
        Test.stopTest();
        System.assert(pr != Null);
    }
    
    static testmethod void fiscalYDispatcherFlexNA(){
        
        List<Opportunity> oppList = new List<Opportunity>([Select id from Opportunity where name like '%TestOpp%']);
        Set<ID> oppoIdSet = new Set<ID>();
        oppoIdSet.add(oppList[0].Id);
        Test.startTest();
        Test.enqueueBatchJobs(101);
        for(Integer i=0; i<102; i++){
            REN_FiscalYearOppBatchDispatcher fiscalYearDispatcher = new REN_FiscalYearOppBatchDispatcher();
            fiscalYearDispatcher.impactedOppId = oppoIdSet;
            String cronExp = '0 0 0 ? * * 2018/1';
            System.schedule('TEST'+i, cronExp, fiscalYearDispatcher);
        }
        List<AsyncApexJob> scheduledJobs = REN_AsyncUtil.getRunningJobs('REN_FiscalYearOppBatchDispatcher', 'ScheduledApex');
        System.debug('scheduledJobs == ' + scheduledJobs);
        Test.stopTest();
        System.assert(!scheduledJobs.isEmpty());
	}
}