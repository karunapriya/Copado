public with sharing class CSM_PlaybookPlayCompController {
	public CSM_DataGridAttribute playbookGridAttribute {get; set;}
	public CSM_DataGridAttribute successPlanPlayGridAttribute {get; set;}
	public List<String> playbookId {get; set;}
	public boolean playCriteriaExists {get; set;}	
	public String plybookId {get; set;}
	private set<String> playsForRefresh;
	private Map<String,csm_successplan_play__c> playtoSppl;	
		
    public String accountId {
    	get {
    		return accountId;
    	}
    	set {
    		accountId = value;
    		setGridAttribute();
    	}
    }
    public String acctPlanId {
    	get {
        	return acctPlanId;
        }
	    set {
	    	acctPlanId = value;
	    	setGridAttribute();
	    }
    }
    private void setGridAttribute() {
    	playCriteriaExists = false;
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
     	gridInputParams.accountId = accountId;
     	gridInputParams.accountPlanId = acctPlanId;
     	
     	Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
     	
        playbookGridAttribute = new CSM_DataGridAttribute();
        playbookGridAttribute.gridToolbarId = CSM_Constants.GRID_ATTR_PLAYBOOK_TOOLBAR;
        playbookGridAttribute.tableName = CSM_Constants.GRID_ATTR_PLAYBOOK_SP;
        playbookGridAttribute.objectType = Schema.SObjectType.CSM_PLaybook__c.label;
        playbookGridAttribute.viewName = CSM_Constants.GRID_ATTR_SUCCESS_PLAN_DETAIL;
        playbookGridAttribute.stateSave = CSM_Constants.GRID_ATTR_TRUE;
        playbookGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
        playbookGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
        playbookGridAttribute.showExport = CSM_Constants.GRID_ATTR_FALSE;
        playbookGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_FALSE;
        playbookGridAttribute.params = JSON.serialize(gridInputParams);	
        playbookGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
        
        successPlanPlayGridAttribute = new CSM_DataGridAttribute();
        successPlanPlayGridAttribute.tableName = CSM_Constants.GRID_ATTR_SUCC_PLAN_PLAY;
        //successPlanPlayGridAttribute.gridToolbarId = CSM_Constants.GRID_ATTR_PLAYBOOK_TOOLBAR;
        successPlanPlayGridAttribute.objectType = CSM_Constants.GRID_ATTR_TYPE_SUCC_PLAN_PLAY;
        successPlanPlayGridAttribute.viewName = CSM_Constants.GRID_ATTR_SUCCESS_PLAN_DETAIL;
        successPlanPlayGridAttribute.stateSave = CSM_Constants.GRID_ATTR_TRUE;
        successPlanPlayGridAttribute.hasSearch = CSM_Constants.GRID_ATTR_TRUE;
        successPlanPlayGridAttribute.hasShowColumns = CSM_Constants.GRID_ATTR_TRUE;
        successPlanPlayGridAttribute.showExport = CSM_Constants.GRID_ATTR_FALSE;
        successPlanPlayGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_FALSE;
        successPlanPlayGridAttribute.params = JSON.serialize(gridInputParams);
        successPlanPlayGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    }
    public PageReference addPlayBook() {
		try {
			//If the user has the ability to add a playbook to Success Plan playbook, redirect to that page
			if(CSM_AcctPlanTemplatePlaybooksDataAccess.addPlaybookAvailable())
			{
				PageReference pageRefTemp = Page.CSM_AccountSuccessPlan;
				String rUrl = pageRefTemp.getURL() + '?' + CSM_Constants.OBJ_IG_ID + '=' + acctPlanId +'%26'+CSM_Constants.SELECTED_TAB+'='+CSM_Constants.SELECTED_TAB_PLAYS;
				PageReference pageRef = Page.CSM_AddPlaybook;
				pageRef.getParameters().put(CSM_Constants.RET_TO_URL, rUrl);
				pageRef.getParameters().put(CSM_Constants.ACCT_PLAN_ID,acctPlanId);
				pageRef.getParameters().put(CSM_Constants.TITLE_PARAM, EncodingUtil.urlEncode(Label.CSM_LBL_ACCT_PLAN_TEMPLATE, CSM_Constants.UTF_8));
				pageRef.getParameters().put(CSM_Constants.ADD_PARAM,'true');
				pageRef.setRedirect(true);
				return pageRef;
			}
		} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
	public PageReference removePlaybookAssociation() {
		List<CSM_Account_Plan_Playbook__c> acctPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
		playbookid = new List<String>();
		playbookid.add(plyBookId);
		boolean isSuccessFulDelete;
		try {
			acctPlanPlaybookList = CSM_AccountPlanPlaybookDataAccess.getAcctPlanPlaybooksByPlaybookIdAndAcctPlanId(playbookId, acctPlanId);
			isSuccessFulDelete = CSM_AcctPlanTemplatePlaybooksDataAccess.deleteAcctPlanTemplatePlaybook(acctPlanPlaybookList);
			
			if (isSuccessFulDelete) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_LBL_ACCT_PLAN + ' ' + Label.CSM_PLAYBOOK_DELETE));
			}

		} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
	
	public PageReference validateRefresh() {
 		try {
 			List<String> pbList = new List<String>();
 			pbList.add(plyBookId);
 			system.debug('idddddds - ' + pbList + '      ' + acctPlanId + '     ' +  accountId);			
 			List<csm_playbookplay__c> pbPlays = CSM_PlaybookPlayDataAccess.getPlaybookPlaybyPlayBook(pbList);//[select Id,csm_play__r.CSM_Query_Criteria__c from csm_playbookplay__c where csm_playbook__c in: pbList];
 			if(pbPlays != null && !pbPlays.isEmpty()){
 				for(csm_playbookplay__c pbPlay: pbPlays){
 					if(pbPlay.csm_play__r.CSM_Query_Criteria__c != null && pbPlay.csm_play__r.CSM_Query_Criteria__c != ''){
 						playCriteriaExists = true;
 						return null;
 					}
 				}
 			}			                    
 		} catch (exception ex) {
 			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
 		}
  		return null;
  	}

	public PageReference refreshPlaybook() {
		//try {
			createTasksForRefresh();
			PageReference pageRef = Page.CSM_AccountSuccessPlan;
			//String rUrl = pageRef.getURL() + '?' + CSM_Constants.OBJ_IG_ID + '=' + acctPlanId +'%26'+CSM_Constants.SELECTED_TAB+'='+CSM_Constants.SELECTED_TAB_PLAYS;
			pageRef.getParameters().put(CSM_Constants.OBJ_IG_ID, acctPlanId);

			pageRef.setRedirect(true);
			return pageRef;
		/*} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}*/
		return null;
	}
	
	
    private void createTasksForRefresh(){
    	
    	List<CSM_TaskWrapper> taskWrapperList = new List<CSM_TaskWrapper>();
		CSM_PlaybookBusinessLayer pbBusinessLayer = new CSM_PlaybookBusinessLayer(null);
		List<CSM_Account_Plan_Playbook__c> acctPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> pbList = new List<String>();	
		pbList.add(plyBookId);	
		system.debug('iddds - ' + pbList + '      ' + acctPlanId + '     ' +  accountId);
		acctPlanPlaybookList = CSM_AccountPlanPlaybookDataAccess.getAcctPlanPlaybooksByPlaybookIdAndAcctPlanId(pbList, acctPlanId);				

		Map<String,String> sppbToPlaybook = pbBusinessLayer.retrieveReEntrantPlaybooks(acctPlanPlaybookList);
		List<String> spplIds = new List<String>();
		if(sppbToPlaybook != null && !sppbToPlaybook.isEmpty()){
			for(String spplSppb: sppbToPlaybook.keySet()){
				List<String> strSpplSppb = spplSppb.split(':');
				spplIds.add(strSpplSppb[0]);
			}
		}
		Set<Id> spplIdsSet = new set<Id>();
		spplIdsSet.addAll((List<id>)spplIds);
		processSpplForRefresh(spplIdsSet);
		set<id> acctSet = new Set<id>();

		acctSet.add(accountId);
		List<CSM_Account_Plan__c> accountPlan = CSM_AccountPlanDataAccess.getActiveAccountPlans(acctSet);
 		List<CSM_Play_Task__c> playTaskList = CSM_PlayTaskDataAccess.getActiveTasks(playsForRefresh);
		
        for(CSM_Play_Task__c pt : playTaskList){
            CSM_TaskWrapper newWrapper = new CSM_TaskWrapper();
            newWrapper.AccountId = accountId;
            newWrapper.Subject = pt.Name; 
            newWrapper.comments = pt.CSM_Description__c;
            newWrapper.taskType = pt.CSM_type__c;
            newWrapper.recordTypeId = String.valueof(pt.CSM_Record_Type__c);
            newWrapper.AccountPlanId = acctPlanId;
            if(pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_ACCOUNT_OWNER){
                newWrapper.assignToPerson = accountPlan[0].CSM_Account_Owner_Id__c;
            }
             else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_ACCOUNT_MANAGER) {
				newWrapper.assignToPerson = accountPlan[0].CSM_Account_Manager__c;
			}
            else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_CSM_CONTACT){
                newWrapper.assignToPerson = accountPlan[0].CSM_Contact__c;
            }
            else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_SUPPORT_CONTACT){
                newWrapper.assignToPerson = accountPlan[0].CSM_Support_Contact__c;
            }
            else if(pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_CSM_MANAGER){
                newWrapper.assignToPerson = accountPlan[0].CSM_Manager__c; 
            }
            else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_CUSTOMER_SUCCESS_MANAGER){
                newWrapper.assignToPerson = accountPlan[0].CSM_Customer_Success_Manager__c;    
            }
            else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_EXEC_SPONSOR){
                newWrapper.AssignToPerson = accountPlan[0].CSM_Exec_Sponsor__c;
            }
            else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_RENEWAL_MANAGER){
                newWrapper.AssignToPerson = accountPlan[0].CSM_Renewal_Manager__c;
            }
            else if (pt.CSM_Assign_To__c == CSM_Constants.ASSIGN_RENEWAL_CONTACT){
                newWrapper.AssignToPerson = accountPlan[0].CSM_Renewal_Contact__c;
            }
            //If those got assigned as null set to account owner
            if(newWrapper.AssignToPerson == null){
                newWrapper.AssignToPerson = accountPlan[0].CSM_Account_Owner_Id__c;
            }
            system.debug('newWrapper.AssignToPerson :' + newWrapper.AssignToPerson);
            newWrapper.playTaskId = pt.id;
            newWrapper.playId = pt.csm_play__c;
            if(pt.CSM_Days_Until_Due__c != null){
                Date theDate = System.Today();
                newWrapper.ActivateDate = theDate.addDays(Integer.valueOf(pt.CSM_Days_Until_Due__c));
            }
            //Object references 
            newWrapper.PlayTask = pt;
            newWrapper.AccountPlan = accountPlan[0];
            //newWrapper.Play = thePlay;
            //newWrapper.PlaybookPlay = thePlaybookPlay;
            //newWrapper.PlaybookPlayId = thePlaybookPlay.Id;
            if(playtoSppl !=null && !playtoSppl.isEmpty()){
				newWrapper.successPlanPlay = playtoSppl.get(pt.csm_play__c);	                
            }            
        	taskWrapperList.add(newWrapper);
        }
 
		System.debug('\n\ntaskWrapperList: ' + taskWrapperList);
		if(taskWrapperList != null && !taskWrapperList.isEmpty()){
			CSM_TaskDataAccess.createUpdateTaskListFromWrapper(taskWrapperList);
		}

    }
	

 	 public void processSpplForRefresh(Set<Id> spplIds){
	 	playsForRefresh = new set<String>();
		playtoSppl = new Map<String,csm_successplan_play__c>();
			 	
	 	if(!spplIds.isEmpty()){
	 		List<CSM_SuccessPlan_Play__c> spplList = new List<CSM_SuccessPlan_Play__c>();
	 		List<CSM_SuccessPlan_Play__c> spplListNew = new List<CSM_SuccessPlan_Play__c>();
	 		List<CSM_SuccessPlan_Play__c> openSpplList = new List<CSM_SuccessPlan_Play__c>();	 		
	 		
	 		Set<String> noNewSppls = new Set<String>();
	 		Set<String> noNewTasks = new Set<String>();	 
	 		Set<String> spplWithTasks = new Set<String>();	 				
	 				 		
	 		openSpplList = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListNoNewSPPL(spplIds);//[select Id, CSM_Previous_SPPL__c from csm_successplan_play__c where CSM_Previous_SPPL__c in : spplIds and csm_status__c != 'Completed'];
	 		if(!openSpplList.isEmpty()){
		 		for(CSM_SuccessPlan_Play__c openSppl: openSpplList){
		 			noNewSppls.add(openSppl.CSM_Previous_SPPL__c);
		 			spplWithTasks.add(openSppl.Id);
		 			spplIds.add(openSppl.Id);
		 		}
	 		}

			List<Task> taskList = new List<Task>();
	 		taskList = CSM_TaskDataAccess.getTasksForSPPLRefresh(spplWithTasks);//[select Id,csm_successplan_play__c from Task where  csm_successplan_play__c in:spplWithTasks ];
	 		//openSpplList = [select Id,CSM_Previous_SPPL__c from csm_successplan_play__c where CSM_Previous_SPPL__c in : spplIds and csm_status__c != 'Completed' and Id in:spplWithTasks ];
	 		/*if(!openSpplList.isEmpty()){
		 		for(CSM_SuccessPlan_Play__c openSppl: openSpplList){
		 			noNewTasks.add(openSppl.Id);
		 			spplIds.add(openSppl.Id);		 			
		 		}
	 		}*/

	 		if(taskList != null && !taskList.isEmpty()){
		 		for(Task tsk: taskList){
		 			noNewTasks.add(tsk.csm_successplan_play__c);
		 			//spplIds.add(tsk.csm_successplan_play__c);		 			
		 		}
	 		}

	 		
	 		spplList = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayListForTasks(spplIds, true);
		 	if(!spplList.isEmpty()){
			 	for(CSM_SuccessPlan_Play__c sppl: spplList){
			 		if(sppl.CSM_Play__r.CSM_Play_ReEntry__c && sppl.csm_status__c == 'Completed' && !noNewSppls.contains(sppl.Id)){
						CSM_SuccessPlan_Play__c insertSppl = new CSM_SuccessPlan_Play__c();
						insertSppl.CSM_Display_Name_Text__c = sppl.CSM_Display_Name_Text__c;
						insertSppl.CSM_Play__c = sppl.CSM_Play__c;
						insertSppl.CSM_Playbook_Play__c = sppl.CSM_Playbook_Play__c;
						insertSppl.CSM_SuccessPlan_Playbook__c = sppl.CSM_SuccessPlan_Playbook__c;
						insertSppl.CSM_Previous_SPPL__c = sppl.Id;
						spplListNew.add(insertSppl);
					}else if(!noNewTasks.contains(sppl.Id) && sppl.csm_status__c != 'Completed'){
						playsForRefresh.add(sppl.CSM_Play__c);
						playtoSppl.put(sppl.csm_play__c,sppl);
			 		}
			 	}
		 	}
 			
			if(!spplListNew.isEmpty() || !playsForRefresh.isEmpty()){
				
	 			List<CSM_Task_Processing__c> taskProcessList = new List<CSM_Task_Processing__c>();
	 			List<String> spplIdLst = new List<String>();
	 			for(Id spPlayId:spplIds){
	 				spplIdLst.add(spPlayId); 			
	 			}
	
				taskProcessList = CSM_TaskProcessingDataAccess.getTskProcRecordsForDelete(spplIdLst);//[select Id from CSM_Task_Processing__c where CSM_SuccessPlan_Play__c in: spplIdList];
				if(!taskProcessList.isEmpty()){
					CSM_TaskProcessingDataAccess.deleteTaskProcRecords(taskProcessList);
				}
				
				CSM_SuccessPlanPlayDataAccess.insertSuccessPlanPlayList(spplListNew);
				//playtoSppl = new Map<String,csm_successplan_play__c>();
				for(csm_successplan_play__c sppl:spplListNew){
					playsForRefresh.add(sppl.CSM_Play__c);					
					playtoSppl.put(sppl.csm_play__c,sppl);
				}
			}
	 	}
 	 }

	
	
     public PageReference addPlayBookSkipCriteria() {
		PageReference pageRef = addPlayBook();
		if(pageRef != null){
			pageRef.getParameters().put('skip','true');
		}
		return pageRef;
	 }
}