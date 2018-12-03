global with sharing class CaseCreationSchedule implements Schedulable {
    public String thisProRuleId;
    public String thisProactiveRuleOutput;
    
    public CaseCreationSchedule(String proRuleId) {
        thisProRuleId = proRuleId;
    }
    
    public CaseCreationSchedule(String proRuleId, String proRuleOutput) 
    {
    	thisProRuleId = proRuleId;
        thisProactiveRuleOutput = proRuleOutput;
    }
    
    
    global void execute(SchedulableContext sc) {
        CaseCreationBatch ccb = new CaseCreationBatch();
        ccb.queryString = thisProactiveRuleOutput;
        ccb.proRuleId = thisProRuleId;
        System.debug('##### ccb.queryString: ' + ccb.queryString);
        Integer batchSize = Util.getCustomListSetting('SE_CaseCreationBatch');
        batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
        Database.executeBatch(ccb, batchSize);
    }
}