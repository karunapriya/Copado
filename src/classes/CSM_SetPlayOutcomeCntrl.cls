public with sharing class CSM_SetPlayOutcomeCntrl {
    
    public boolean hasCSMAccess {get; private set;}
    public boolean hasRenewAccess {get; private set;}
    public string playOutcomeValue {get;set;}
    public string taskId{get;set;}
    public string successPlanPlayId;
    public string taskStatus;
    public string playOutcome{get;set;} 
    public boolean isError{get;set;}  //US2411
    public string errorString {get; set;}
  
    public CSM_SetPlayOutcomeCntrl(ApexPages.StandardController sc) {
        hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
        Task taskDetail = (Task )sc.getRecord();
        taskId = taskDetail.id;
        successPlanPlayId = taskDetail.CSM_SuccessPlan_Play__c;
        taskStatus =  taskDetail.Status; 
        isError= false;
        errorString = 'false';
         if(taskDetail.IsClosed){
             isError = false;
             errorString = 'false';
             List<csm_successplan_play__c> spplOutcome = CSM_SuccessPlanPlayDataAccess.getPlayOutcomeForSppl(successPlanPlayId);
             if(spplOutcome != null && !spplOutcome.isEmpty()){
                 playOutcome = spplOutcome[0].csm_play_outcome__c;        
             }else{
                 playOutcome = 'orphantask';
             }
         } else {
             isError = true;
             errorString = 'true';
         }
    }
    
    public List<SelectOption> getPlayOutcomeValues() {          
        sObject sobj = new CSM_SuccessPlan_Play__c();
        List<SelectOption> options = CSM_Util.getPicklistValues(sobj,'CSM_Play_Outcome__c');
        options.add(new SelectOption('','--None--')); 
        options.sort();
        return options;
    }
    
    public PageReference Save() {
        if(!String.isblank(successPlanPlayId)) {
            if(String.isBlank(playOutcomeValue)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_ERR_SET_PLAYOUTCOME)); 
            } else {
                List<Task> taskList = CSM_TaskDataAccess.getTasksForSPPL(new set<Id>{successPlanPlayId});
                List<Task> taskListToUpdate = new List<Task>();
                if(!taskList.isEmpty()) {
                    for(Task tsk:taskList) {
                      if(!tsk.isClosed){    
                        tsk.Status = taskStatus;
                        taskListToUpdate.add(tsk);
                      } 
                    }
                    CSM_TaskDataAccess.updateTasks(taskListToUpdate);
                }

                 CSM_Constants.ACCOUNT_PLAN_PLAYBOOK_TRIGGER = false;

                 integer countClosedTasks = taskList.size();
                 integer countTotalTasks = taskList.size();

                 CSM_SuccessPlanPlayDataAccess.setPlayOutcome(new set<Id>{successPlanPlayId}, playOutcomeValue, countClosedTasks, countTotalTasks);     
            }   
        }
        return null;
    }
    
    public PageReference Cancel() {
        PageReference pageRef = new PageReference('/' + taskId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}