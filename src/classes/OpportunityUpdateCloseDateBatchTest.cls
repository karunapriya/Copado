@isTest
private class OpportunityUpdateCloseDateBatchTest {
    static testMethod void testBatch(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account acc = new Account(Name = 'Test Account');
        Database.insert(acc);
        
        List<Opportunity> oppsList = new List<Opportunity>();
        
        for(Integer i = 0; i < 200; i++){
            
        	Opportunity opp = new Opportunity(Account = acc, AccountId = acc.Id, Name = 'Test Opp-' + String.valueOf(i), 
                                          CurrencyIsoCode = 'USD', CloseDate = Date.today(),//Date.newInstance(2016, 1, 15), 
                                          StageName = 'Not Contacted', OwnerId = thisUser.Id, PO_Number__c = '12345');
            oppsList.add(opp);
        }
        
        Database.insert(oppsList);
        set<ID> oppId = new set<ID>();
        for(Opportunity opp: oppsList){
        	oppId.add(opp.id);
        }
        
        Test.startTest();
        OpportunityDataAccess.getOpportunityMapById(oppId);
        Datetime execTime = (System.now()).addSeconds(3);
        String cronExp = execTime.second() + ' ' + execTime.minute() + ' ' + execTime.hour() + ' ' + execTime.day() + ' ' + execTime.month() + ' ? ' + execTime.year();
        OpportunityUpdateCloseDateSchedule os = new OpportunityUpdateCloseDateSchedule();
        System.assert(cronExp != null);
        System.schedule('OpportunityUpdateCloseDateSchedule', cronExp, os);
        Test.stopTest();
        
    }
}