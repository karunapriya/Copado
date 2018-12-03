global with sharing class REN_FiscalYearOppBatchDispatcher implements Schedulable {
    
    public Set<ID> impactedOppId {get;set;}
    public Static Integer batchInterval = 15;
    global void execute(SchedulableContext sc){
        Integer batchSize = CSM_Util.getCustomListSetting('REN_FiscalYearOppBatch');
        batchSize = (batchSize == null || batchSize == 0) ? 200 : batchSize;
        boolean isFlexQueueAvailable = REN_AsyncUtil.isFlexQueueAvailable();
        if(impactedOppId != null){
            if(isFlexQueueAvailable){
                REN_FiscalYearOppBatch batchClass = new REN_FiscalYearOppBatch();
                batchClass.impactedOppId = this.impactedOppId;
                batchClass.schedulableContextObj = sc;
                System.debug('SchedulableContextID: ' + SC +'\n\n3- Call REN_FiscalYearOppBatchDispatcher: executeBatch: ' + impactedOppId);
                Database.executeBatch(batchClass, batchSize);
            }else{
                Datetime dt = Datetime.now().addMinutes(batchInterval);
                String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                REN_FiscalYearOppBatchDispatcher schedulerClass = new REN_FiscalYearOppBatchDispatcher();
                schedulerClass.impactedOppId = this.impactedOppId;
                String schedulerName = 'FiscalYearOnOpportunity_'+dt.format('yyyyMMddHHmmss');
                System.debug(impactedOppId + '\n\n2- Call REN_FiscalYearOppBatchDispatcher: Schedule: ' + schedulerName);
                String jobID = System.Schedule(schedulerName, timeForScheduler, schedulerClass);
                System.abortJob(SC.getTriggerId());
            }
        }else{
        	System.abortJob(SC.getTriggerId());
        }
    }
}