global with sharing class OpportunityUpdateCloseDateSchedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        Set <String> stageSet = new Set <String>{'No Service', 'House Account', 'Closed Sale', 'Open - Consolidated'};
        Datetime execTime = (System.now()).addMinutes(60);
        String cronExp = execTime.second() + ' ' + execTime.minute() + ' ' + execTime.hour() + ' ' + execTime.day() + ' ' + execTime.month() + ' ? ' + execTime.year();    
            
        //check if there is at least 1 unresolved oppty closing today, else nothing happens, just continue with the schedule on the next day
        if([SELECT count() FROM Opportunity WHERE StageName NOT IN :stageSet AND CloseDate <= :Date.today() LIMIT 1] > 0){
                
            //check if there are less than 5 batch apex in the queue
            if([SELECT count () FROM AsyncApexJob WHERE (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing') AND JobType = 'BatchApex'] < 5){
                //execute batch here...
                OpportunityUpdateCloseDateBatch ub = new OpportunityUpdateCloseDateBatch();
                database.executebatch(ub);
            }
            else{
                //if there are 5 or more batch apex in the queue, schedule the batch after 1 hour (?)
                CronTrigger ct = [SELECT Id, StartTime, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'OpportunityUpdateCloseDateSchedule' LIMIT 1];
                System.abortJob(ct.Id);
                batchExecute(cronExp);
            }
        }
        
     }
    
    global static void batchExecute(String runSched){
        OpportunityUpdateCloseDateSchedule us = new OpportunityUpdateCloseDateSchedule();
        System.schedule('OpportunityUpdateCloseDateSchedule', runSched, us);
    }
}