public with sharing class CSM_TimelineComponentController {
    @RemoteAction
    public static String getTimelineJsonWrapper(String accountId, String acctPlanTemplateId){
        CSM_TimeLineJSONList timelineJsonWrapper = new CSM_TimeLineJSONList();
        String opptyLocFldOnSPT = '';
        CSM_Account_Plan__c acctPlan = CSM_AccountPlanDataAccess.getAccountPlan(accountId, acctPlanTemplateId);
        List<CSM_Account_Plan_Phase__c> phaseList = CSM_AccountPlanTemplatePhasesDataAccess.populateAccountTemplatePhases(acctPlanTemplateId);
        List<Task> taskList = CSM_TaskDataAccess.getTasksByAccountAndAccountPlan(accountId, acctPlan.id);
		String namespace = CSM_Util.getNamespace();     
		   
        //find the oppty location field used on Success Plan Template
        if (acctPlan.CSM_Account_Plan_Template__r.CSM_Opp_Date__c != null) {
			opptyLocFldOnSPT = String.valueOf(acctPlan.CSM_Account_Plan_Template__r.CSM_Opp_Date__c).replace(namespace, '');
        }
        List<Opportunity> opportunityList = CSM_OpportunityDataAccess.getRenewalOpptyByAcctAndLocationOnSuccessPlan(accountId, opptyLocFldOnSPT);
        
        //List<Opportunity> opportunityList = CSM_OpportunityDataAccess.getRenewalOpportunitiesByAccount(accountId);
        timelineJsonWrapper.phases = populatePhaseData(acctPlan, phaseList);
        timelineJsonWrapper.tasks = populateTaskData(taskList);
        timelineJsonWrapper.tasks.addAll(populateOpportunityData(opportunityList, acctPlan));
        return JSON.serialize(timelineJsonWrapper);
    }
    
    private static List<CSM_TimeLinePhasesWrapper> populatePhaseData(CSM_Account_Plan__c acctPlan, List<CSM_Account_Plan_Phase__c> phaseList){
        List<CSM_TimeLinePhasesWrapper> phaseWrapperList = new List<CSM_TimeLinePhasesWrapper>();
        if (phaseList != null && !phaseList.isEmpty() && acctPlan != null && acctPlan.CSM_Phase_Start_Date__c != null)
        {
        	List<String> phaseColorList = CSM_AdminDataAccess.getAdminList(CSM_Constants.OBJ_LIST_PHASE_COLORS);
        	Integer totalColors = phaseColorList.size();
        	Integer counter = 0;
        	Datetime dtStart = null;
        	Datetime dtEnd = null;
            for(CSM_Account_Plan_Phase__c phase : phaseList){
                CSM_TimeLinePhasesWrapper wrapper = new CSM_TimeLinePhasesWrapper();
                wrapper.name = phase.CSM_Phase_Name__c;
                Integer phaseLength = phase.CSM_Length__c == null?0:Integer.valueOf(phase.CSM_Length__c);
                if(dtStart == null){
	                dtStart = Datetime.newInstance(acctPlan.CSM_Phase_Start_Date__c.year(), 
	                                    acctPlan.CSM_Phase_Start_Date__c.month(),acctPlan.CSM_Phase_Start_Date__c.day());
                }else{
                	dtStart = dtEnd;
                }
            	dtEnd = dtStart.addDays(phaseLength);
                wrapper.start = dtStart.format('yyyy-MM-dd') + 'T12:00:00+00:00';
                wrapper.endDate = dtEnd.format('yyyy-MM-dd') + 'T12:00:00+00:00';                
                wrapper.itemType = 'PHASE';
                wrapper.status = true;
                wrapper.statusType = 'Complete';
                wrapper.id = phase.id;
                wrapper.timelineElementType = 'range';
                wrapper.color = totalColors == 0?'':phaseColorList.get(counter).substring(1);
                if(counter >= totalColors-1){
                	counter = 0;
                }else{
                	counter++;
                }
                phaseWrapperList.add(wrapper);
            }
        }
        return phaseWrapperList;
    }
    
    private static List<CSM_TimeLineWrapper> populateTaskData(List<Task> taskList){
        List<CSM_TimeLineWrapper> taskWrapperList = new List<CSM_TimeLineWrapper>();
        if (taskList != null && !taskList.isEmpty())
        {
            for(Task task : taskList){
                CSM_TimeLineWrapper wrapper = new CSM_TimeLineWrapper();
                wrapper.name = '';
                if(task.isClosed && task.CSM_Completed_Date__c != null){
                	wrapper.start = Datetime.newInstance(task.CSM_Completed_Date__c.year(), 
                                    task.CSM_Completed_Date__c.month(), task.CSM_Completed_Date__c.day())
                                    .format('yyyy-MM-dd') + 'T12:00:00+00:00';   
                    wrapper.displayDate = task.CSM_Completed_Date__c.format();                                  
                                    
                } else if (!task.isClosed && task.ActivityDate != null){
                	wrapper.start = Datetime.newInstance(task.ActivityDate.year(), 
                                    task.ActivityDate.month(), task.ActivityDate.day())
                                    .format('yyyy-MM-dd') + 'T12:00:00+00:00'; 
                    wrapper.displayDate = task.ActivityDate.format();                                                   	 
                }              
                else {
	                wrapper.start = null;
	            }
                wrapper.createdOn = task.CreatedDate.format('yyyy-MM-dd') + 'T12:00:00+00:00';
                wrapper.endDate = null;
                wrapper.itemType = 'TASK';
                wrapper.status = task.isClosed;
                wrapper.statusType = task.Status;
                wrapper.id = task.id;
                wrapper.timelineElementType = 'box';
                wrapper.className = '';
                wrapper.content = '';
                wrapper.url = '';
                wrapper.description = '';
                
                if (task.Subject == null) {
                	wrapper.subject = '';
                }
                else {
                	wrapper.subject = task.Subject;
                }
                if (task.Type == null || task.Type == 'Meeting' || task.Type == 'Other') {
                	wrapper.taskType = 'Check';
                }
                else {
                	wrapper.taskType = task.Type;
                }
                if (wrapper.start != null) {
                	taskWrapperList.add(wrapper);
                }
            }
        }
        return taskWrapperList;
    }
    
    private static List<CSM_TimeLineWrapper> populateOpportunityData(List<Opportunity> opportunityList, CSM_Account_Plan__c acctPlan){
        List<CSM_TimeLineWrapper> opportunityWrapperList = new List<CSM_TimeLineWrapper>();
                
        if (opportunityList != null && !opportunityList.isEmpty() && acctPlan != null)
        {
            for(Opportunity oppty : opportunityList){
            	
                CSM_TimeLineWrapper wrapper = new CSM_TimeLineWrapper();
                String closeDateTime = 
                wrapper.name = oppty.Name;
               
                wrapper.start = acctPlan.CSM_Account_Plan_Template__r.CSM_Opp_Date__c != null
                				&& oppty.get(acctPlan.CSM_Account_Plan_Template__r.CSM_Opp_Date__c) != null
                				?((Datetime)oppty.get(acctPlan.CSM_Account_Plan_Template__r.CSM_Opp_Date__c))
                					.format('yyyy-MM-dd') + 'T12:00:00+00:00'
                				:Datetime.newInstance(oppty.CloseDate.year(), 
                                    oppty.CloseDate.month(), oppty.CloseDate.day())
                                    .format('yyyy-MM-dd') + 'T12:00:00+00:00';
                                    
                Date opptDate = acctPlan.CSM_Account_Plan_Template__r.CSM_Opp_Date__c != null
                                && oppty.get(acctPlan.CSM_Account_Plan_Template__r.CSM_Opp_Date__c) != null
                                ? (Date)oppty.get(acctPlan.CSM_Account_Plan_Template__r.CSM_Opp_Date__c)
                                :oppty.CloseDate;
                                                
             
                wrapper.displayDate = opptDate.format();
                                                                                                    
                wrapper.createdOn = oppty.CreatedDate.format('yyyy-MM-dd') + 'T12:00:00+00:00';
                wrapper.endDate = null;
                wrapper.itemType = 'OPPORTUNITY';
                wrapper.status = String.isNotBlank(oppty.StageName) 
                					&& oppty.IsWon
                					&& oppty.StageName.equalsIgnoreCase('Closed Lost')
                					?true:false;
                wrapper.statusType = String.isNotBlank(oppty.StageName) 
                                        && oppty.IsWon
                                        && oppty.StageName.equalsIgnoreCase('Closed Lost')
                                        ?CSM_Constants.TASK_COMPLETED:'';
                wrapper.id = oppty.id;
                wrapper.timelineElementType = 'box';
                wrapper.className = '';
                wrapper.content = '';
                wrapper.url = '';
                wrapper.description = '';
                wrapper.subject = oppty.Name;
                wrapper.taskType = 'Opportunity';
                opportunityWrapperList.add(wrapper);
            }
        }
        return opportunityWrapperList;
    }
    
    private class CSM_TimeLineJSONList {
        public List<CSM_TimeLinePhasesWrapper> phases;
        public List<CSM_TimeLineWrapper> tasks;
    }
   
    private class CSM_TimeLineWrapper{
        public String name;
        public String start;
        public String endDate;
        public String itemType;
        public Boolean status;
        public String statusType;
        public String id;
        public String timelineElementType;
        public String className;
        public String content;
        public String url;
        public String description;
        public String subject;
        public String taskType;
        public String createdOn;
        public String displayDate;
    }
    
    private class CSM_TimeLinePhasesWrapper{
        public String name;
        public String start;
        public String endDate;
        public Boolean status;
        public String statusType;
        public String id;
        public String timelineElementType;  
        public String itemType;
        public String color;
    }    
}