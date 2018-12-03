global with sharing class OpportunityUpdateCloseDateBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set <String> stageSet = new Set <String>{'No Service', 'House Account', 'Closed Sale', 'Open - Consolidated'};
        return Database.getQueryLocator([SELECT Id, CloseDate FROM Opportunity WHERE StageName NOT IN :stageSet AND CloseDate <= :Date.today()]);
    }
   
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        for(Opportunity opp : scope){
            opp.CloseDate = opp.CloseDate.addDays(30);  
        }
        
        Database.update(scope, false);
    }   
    
    global void finish(Database.BatchableContext BC) {
        //after the update has finished, schedule back the batch apex to the original time if the time has been changed
        System.debug('#### FINISHED');
        CronTrigger ct = [SELECT Id, StartTime, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'OpportunityUpdateCloseDateSchedule' LIMIT 1];
        if(ct.StartTime.time().hour() != 0){
            System.abortJob(ct.Id); 
            OpportunityUpdateCloseDateSchedule.batchExecute('0 0 0 * * ?');
        }
    }
}