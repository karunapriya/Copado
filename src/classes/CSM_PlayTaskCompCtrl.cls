/**
* @author         Mike Faust (mike@comitydesigns.com)
* @date           08.22.2014
* @description    CSM_PlayTaskCompCtrl component controller class for CSM_PlayTask component
*/
public with sharing class CSM_PlayTaskCompCtrl {
	
	private List<CSM_PlayTaskWrapper> PlayTaskWrapperList;
	private List<CSM_Play_Task__c> playTaskList;
	
	public Integer wrapperSize {get; set;}
	public Integer seqNumberToUpdate {get; set;}
	public List<SelectOption> optionsList{get;set;}
	public String helpParam {get; set;}
	public List<SelectOption> typeOptionsList{get;set;}
	public List<SelectOption> recordTypeOptionsList{get;set;}
	
	public CSM_PlayTaskCompCtrl() {
		wrapperSize = 0;
		helpParam = CSM_Constants.HELP_PLAY_TASK;
		
		
	}
	
	/**
	 * @description play management controller reference
	 * @return CSM_PlayManagementCtrl
	 */
	public CSM_PlayManagementCtrl CSM_PlayManagementCtrl
	{
		get; 
		set {
			if(value != null)
			{
				CSM_PlayManagementCtrl = value;
			}
		}
	}
	
	/**
	 * @description play reference
	 * @return CSM_Play__c
	 */
	public CSM_Play__c play
	{
		get; 
		set {
			if(value != null)
			{
				this.play = value;
				if (CSM_PlayManagementCtrl != null)
			    {
				    CSM_PlayManagementCtrl.setPlayTaskComponentController(this);
			    }	
			} 
			
		}
	}
	
	/**
	 * @description gets play tasks and builds wrapper class
	 */
	private void populateTask() {
		try
		{
			playTaskList = new List<CSM_Play_Task__c>();
			PlayTaskWrapperList = new List<CSM_PlayTaskWrapper>();
			playTaskList = CSM_PlayTaskDataAccess.populatePlayTaskInformation(play.id);
			for (CSM_Play_Task__c p : playTaskList)
			{
				playTaskWrapperList.add(new CSM_PlayTaskWrapper(p, playTaskWrapperList.size() +1));
			}
			wrappersize = playTaskWrapperList.size();
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			
		}		
	}
	
	/**
	 * @description returns the play task wrapper list
	 * @return List<PlayTaskWrapper>
	 */
	public List<CSM_PlayTaskWrapper> getPlayTaskWrapperList(){
		if(playTaskWrapperList == null)
		{
			populateOptionsList();
			populateTaskTypeOptionList();
			populateRecordTypeOptionList();
			populateTask();
		} 
		return this.playTaskWrapperList;
	}
	
	/**
	 * @description creates new instance of play task
	 * @return PageReference
	 */
	public PageReference newTask() {
		try {
			CSM_Play_Task__c newTask = new CSM_Play_Task__c(csm_play__c=play.id, csm_isActive__c=true);       					
    		playTaskWrapperList.add(new CSM_PlayTaskWrapper(newTask,playTaskWrapperList.size()+1));
    		wrapperSize = playTaskWrapperList.size();
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
	
	/**
	 * @description saves play tasks
	 * @return PageReference
	 */
	public PageReference saveTasks() {
		try {
	    	boolean isValid = true;
	    	List<CSM_Play_Task__c> taskToUpsert = new List<CSM_Play_Task__c>();
	    	for (CSM_PlayTaskWrapper w : playTaskWrapperList)
	    	{
	    		taskToUpsert.add(w.playTask);
	    	}
	    	if(isValid)
	    	{
	    		playTaskList = CSM_PlayTaskDataAccess.savePlayTask(taskToUpsert);
	    		playTaskWrapperList.clear();
	    		populateTask();
	    		
	    	}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
    	return null;
    } 
    
    /**
	 * @description delete play task
	 * @return PageReference
	 */
    public PageReference deleteTask()
    {
    	List<CSM_Play_Task__c> taskToDelete = new List<CSM_Play_Task__c>();
    	try {	
    		Integer playTaskNumberToRemove = -1;
	    	if(seqNumberToupdate != null)
	    	{
	    		
	    		for(integer i=0; i< playTaskWrapperList.size(); i++)
	    		{
	    			if(seqNumbertoUpdate == playTaskWrapperList[i].seqNum)
	    			{
	    				if(playTaskWrapperList[i].playTask.id != null)
	    				{
	    					taskToDelete.add(playTaskWrapperList[i].playTask);
	    				}else{
		    				playTaskWrapperList.remove(i);
		    				wrapperSize = playTaskWrapperList.size();
	    					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_PLAY_TASK_REMOVED_FROM_PLAY));		    				
	    				}
	    				playTaskNumberToRemove = i;
	    			}	
	    		}
	    	}
    	
	    	if(!taskToDelete.isEmpty())
	    	{
	    		boolean successful = CSM_PlayTaskDataAccess.deletePlayTask(taskToDelete);
	    		if(successful == true)
	    		{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_PLAY_TASK_REMOVED_FROM_PLAY));	    			
	    			if (playTaskNumberToRemove!=-1) {
						system.debug('step4-' + playTaskNumberToRemove);	    				
	    				playTaskWrapperList.remove(playTaskNumberToRemove);
	    				wrapperSize = playTaskWrapperList.size();
	    			}
	    			//playTaskWrapperList.clear();
	    			//populateTask();
	    		} else {
	    			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_CANNOT_REMOVE_PLAY_TASK_FROM_PLAY));
	    		}
	    	}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
    	return null;
    }
    
    private void populateOptionsList(){
		this.optionsList = new List<SelectOption>();
		this.optionsList.add(new SelectOption('', '--None--'));
    	if(this.play != null){
    		//if(CSM_Constants.OBJ_ACCOUNT.equals(this.play.CSM_Object_Name__c) || CSM_Constants.OBJ_AP.equals(this.play.CSM_Object_Name__c)){
    			this.optionsList.add(new SelectOption(CSM_Constants.ASSIGN_ACCOUNT_MANAGER, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_ACCOUNT_MANAGER)));
    			this.optionsList.add(new SelectOption(CSM_Constants.ASSIGN_ACCOUNT_OWNER, CSM_Constants.ASSIGN_ACCOUNT_OWNER));
    			
    			String csmReplacementLabel = CSM_AdminDataAccess.getCSMAdminInstance().CSM_SP_LBL_CSM__c;
				String csmContactLabel = CSM_Constants.ASSIGN_CSM_CONTACT;
				if (String.isNotBlank(csmReplacementLabel))
				{
					csmContactLabel = csmReplacementLabel;
				}
    			this.optionsList.add(new SelectOption(CSM_Constants.ASSIGN_CSM_CONTACT, csmContactLabel));
    			
    			this.optionsList.add(new SelectOption(CSM_Constants.ASSIGN_SUPPORT_CONTACT, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_SUPPORT_CONTACT)));
    			this.optionsList.add(new SelectOption(CSM_Constants.ASSIGN_CSM_MANAGER, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CSM_MANAGER)));
    			this.optionsList.add(new SelectOption(CSM_Constants.ASSIGN_CUSTOMER_SUCCESS_MANAGER, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_CUSTOMER_SUCCESS_MGR)));
    			this.optionsList.add(new SelectOption(CSM_Constants.ASSIGN_EXEC_SPONSOR, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_EXEC_SPONSOR)));
    			this.optionsList.add(new SelectOption(CSM_Constants.ASSIGN_RENEWAL_MANAGER, CSM_Util.getLabelReplacement(CSM_Constants.OBJ_AP_RENEWAL_MANAGER)));
    			
    			String renewalContactReplacementLabel = CSM_AdminDataAccess.getCSMAdminInstance().CSM_SP_LBL_RenewalRep__c;
				String renewalContactLabel = CSM_Constants.ASSIGN_RENEWAL_CONTACT;
				if (String.isNotBlank(renewalContactReplacementLabel))
				{
					renewalContactLabel = renewalContactReplacementLabel;
				}
    			this.optionsList.add(new SelectOption(CSM_Constants.ASSIGN_RENEWAL_CONTACT, renewalContactLabel));
    			
    			//US2317 starts
    			Map<String, String> userLkpPlayTaskMap = CSM_Util.getUserLookupsForSObject(CSM_Constants.OBJ_AP);
    			if (userLkpPlayTaskMap != null && !userLkpPlayTaskMap.isEmpty()) {
    				for (String fldAPIName : userLkpPlayTaskMap.keySet()) {
    					this.optionsList.add(new SelectOption(fldAPIName, userLkpPlayTaskMap.get(fldAPIName)));
    				}
    			}
    			//US2317 ends

    		/*}else if(CSM_Constants.OBJ_OPPORTUNITY.equals(this.play.CSM_Object_Name__c)){
    			this.optionsList.add(new SelectOption(REN_Constants.ASSIGN_OPPORTUNITY_OWNER, REN_Constants.ASSIGN_OPPORTUNITY_OWNER));
    			this.optionsList.add(new SelectOption(REN_Constants.ASSIGN_RENEWAL_SALES_AM, REN_Constants.ASSIGN_RENEWAL_SALES_AM));
    			this.optionsList.add(new SelectOption(REN_Constants.ASSIGN_RENEWAL_SALES_REP, REN_Constants.ASSIGN_RENEWAL_SALES_REP));
    			this.optionsList.add(new SelectOption(REN_Constants.ASSIGN_SALES_OPS_AM, REN_Constants.ASSIGN_SALES_OPS_AM));
    			this.optionsList.add(new SelectOption(REN_Constants.ASSIGN_SALES_OPS_REP, REN_Constants.ASSIGN_SALES_OPS_REP));
    		}*/
    	}
    }	
    
    //US520
     private void populateTaskTypeOptionList(){
     	this.typeOptionsList = new List<SelectOption>();
		this.typeOptionsList.add(new SelectOption('', '--None--'));
		
     	Schema.DescribeFieldResult fieldResult1 = Task.type.getDescribe();
		List<Schema.PicklistEntry> typeOptionList = fieldResult1.getPicklistValues();
		
		for(Schema.PicklistEntry option :typeOptionList){
			this.typeOptionsList.add(new SelectOption(String.valueOf(option.getlabel()), String.valueOf(option.getValue())));
		}
		system.debug('PickList value ::'+ typeOptionsList);
     }
     //US1097
     private void populateRecordTypeOptionList() {
		this.recordTypeOptionsList = new List<SelectOption>();
		//this.recordTypeOptionsList.add(new SelectOption('', '--None--'));
		Schema.DescribeSObjectResult objectResult = Task.sObjectType.getDescribe();
		List<Schema.RecordTypeInfo> recordTypeList = objectResult.getRecordTypeInfos();
		for(Schema.RecordTypeInfo option :recordTypeList) {
			if(option.isDefaultRecordTypeMapping() && option.getName() != 'Master' && option.isAvailable()) {
				this.recordTypeOptionsList.add(new SelectOption(String.valueOf(option.getRecordTypeId()), String.valueOf(option.getName())));
				break;
			}
		}
		for(Schema.RecordTypeInfo option :recordTypeList) {
			if(!option.isDefaultRecordTypeMapping() && option.getName() != 'Master' && option.isAvailable()) {
				this.recordTypeOptionsList.add(new SelectOption(String.valueOf(option.getRecordTypeId()), String.valueOf(option.getName())));
			}
		}
		system.debug('Record Type PickList value ::--->'+ recordTypeOptionsList);
     }
}