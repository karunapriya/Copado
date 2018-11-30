public with sharing class CSM_TaskBusinessLayer extends CSM_BusinessLayer {

	private String VIEW_NAME_ACTIVITY_HISTORY = 'ActivityHistory'; 
	private String ATTRIB_ACTIVITY_TYPE = 'ActivityType'; 
	private CSM_User_Preferences__c userPreferenceObj = new CSM_User_Preferences__c();
	
	public CSM_TaskBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
		super(inputWrapper);
		userPreferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(UserInfo.getUserId(), 'CSM_Success_Task_Filter__c,CSM_Success_Task_Grid_Columns__c,CSM_Success_Plan_Activity_Grid_Columns__c');
		
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
		return getTaskWrapperList();
	}
	
	private CSM_GridResponseWrapper getTaskWrapperList() {
		//business logic for setting up Lists for <CSM_GridRowWrapper> and <CSM_GridColumnWrapper>
		CSM_GridResponseWrapper taskWrapperList = new CSM_GridResponseWrapper();
		
		List<sObject> taskList;
		System.debug('ZZZ -'+this.inputWrapper.viewName);
		taskWrapperList.header = setTaskHeader();
		if (this.inputWrapper.viewName.length()==0){
			taskList = getTaskList();
			//setup the CSM_GridColumnWrapper object for header values, 
			//since this is specific for Task, we know what the headers need to set specifically
			
			taskWrapperList.hasCheckbox = true;
			taskWrapperList.hasAction = true;
			taskWrapperList.hasDetail = true;
		} else if (VIEW_NAME_ACTIVITY_HISTORY.equalsIgnoreCase(this.inputWrapper.viewName)){
			taskList = CSM_AccountDataAccess.getActiveHistory(this.inputWrapper.params.accountId);
		}
		//setup the CSM_GridRowWrapper for the column values to be fed in it, maintain the order in which the headers are created.
		taskWrapperList.row = setTaskRows(taskList, taskWrapperList.header);
		return taskWrapperList;
	}
	
	private List<CSM_GridRowWrapper> setTaskRows(List<sObject> taskList, List<CSM_GridColumnWrapper> colList) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();

		if(taskList != null && !taskList.isEmpty()) {
			Set<Id> recIds = new Set<Id>();
			
			for(sObject sObj : taskList) {
				 recIds.add((Id)sObj.get('Id'));
			}
			
			Map<Id,Boolean> recAccessMap = CSM_AccessController.hasEditRecordAccess(recIds,userinfo.getUserId());
			
			for(sObject sObj : taskList) {
				System.debug('ZZZ - '+sObj);
				CSM_GridRowWrapper row = new CSM_GridRowWrapper();
				
				if (this.inputWrapper.viewName.length()==0){
					row.playSelected = (String)sObj.get('CSM_Play__c');
					row.taskState = (Boolean)sObj.get('IsClosed');
					if (sObj.getSObject('CSM_Account_Plan__r') != null) {
						row.accountId = (String)sObj.getSObject('CSM_Account_Plan__r').get('CSM_AccountId__c');
					}
				}
				row.id = (String)sObj.get('Id');
				row.sObj = sObj;
				row.hasAccess = false;
				row.namespace = CSM_Util.getNamespace();
				if (recAccessMap.containsKey(row.id)){
					row.hasAccess = (Boolean)recAccessMap.get(row.id);
				} 
				row.isMC = CSM_Util.checkMCEnabled();
				row.columns = new List<CSM_GridColumnWrapper>();
				if (colList!=null){
					row.columns = colList;
					/*
					for (CSM_GridColumnWrapper colOrig : colList){
						CSM_GridColumnWrapper col = colOrig.clone();
						if (col.valueCol.contains('.') && col.valueCol != 'recordtype.name'){
							String[] objSplit = col.valueCol.split('\\.');
							if (objSplit!=null && objSplit.size()==2){
								try {
									col.value = String.valueOf(sObj.getSObject(objSplit[0]).get(objSplit[1]));
								} catch (Exception ex) {
									
								}
							}
						    else {
							  if (ATTRIB_ACTIVITY_TYPE.equalsIgnoreCase(col.valueCol)){
								  col.value = 'Task';	
							  } else {
								col.value = String.valueOf(sObj.get(col.valueCol));//String.valueOf(sObj.getSObject('recordtype').get('name'));
							  }
						    }
						}else if(col.valueCol == 'recordtype.name' && sObj.getSObject('recordtype') != null){
							col.value = String.valueOf(sObj.getSObject('recordtype').get('name'));						
						}else{
							if (ATTRIB_ACTIVITY_TYPE.equalsIgnoreCase(col.valueCol)){
								col.value = 'Task';	
							} else {
								if(col.valueCol != 'recordtype.name'){
									col.value = String.valueOf(sObj.get(col.valueCol));								
								}
							}
						}
						
						if (col.isDateCol!=null && col.isDateCol){
							if (String.isNotBlank(col.value))
							{
		                        Boolean tempIsDateTime = CSM_Util.isDateTime(col.value);
		                        Boolean tempIsDate = CSM_Util.isDate(col.value);
		                        if (tempIsDateTime || tempIsDate) {
		                            Datetime currentDateVal = null;
		                                
		                            if (tempIsDateTime)
		                            {
		                                currentDateVal = Datetime.valueOf(col.value);
		                            }
		                            else 
		                            {
		                                Date tempDate = Date.valueOf(col.value);
		                                currentDateVal = Datetime.newInstance(tempDate.year(), tempDate.month(),tempDate.day());
		                            }
		                            col.value = CSM_Util.getLocaleFormattedDateValue(userLocale,currentDateVal , localeMap);
		                            col.hiddenDate = String.valueOfGmt(currentDateVal);
		                        }
							}
							else 
							{
								col.value = '';
		                        col.hiddenDate = '';
							}
	                    }   
					
						if (col.lookUpIdCol!=null && col.lookUpIdCol.length()>0){
							col.lookUpId = String.valueOf(sObj.get(col.lookUpIdCol));
						}
						if(col.apiname == 'id'){
						   if(recAccessMap.containsKey(row.id)){
						      col.value = ''+recAccessMap.get(row.id); 
						   }
						}
						row.columns.add(col);
					}	
					*/
					gridRowWrapper.add(row);
				}
			}
		}
		
		return gridRowWrapper;
	}
	
	private List<CSM_GridColumnWrapper> setTaskHeader() {
		String namespace = CSM_Util.getNamespace();
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();
		String successTasksColumnStr = '';
		String successPlanActHistStr = '';
		if(userPreferenceObj != null){
			if(userPreferenceObj.CSM_Success_Task_Grid_Columns__c != null){
				successTasksColumnStr = userPreferenceObj.CSM_Success_Task_Grid_Columns__c.toLowerCase();
				system.debug(successTasksColumnStr+'Entire List in Business Layer');
			}
			if (userPreferenceObj.CSM_Success_Plan_Activity_Grid_Columns__c != null) {
				successPlanActHistStr = userPreferenceObj.CSM_Success_Plan_Activity_Grid_Columns__c.toLowerCase();
			}
		}
		
		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		//Completion Date
		CSM_GridColumnWrapper colDate = new CSM_GridColumnWrapper();
		if (VIEW_NAME_ACTIVITY_HISTORY.equalsIgnoreCase(this.inputWrapper.viewName)){
			colDate.apiName = 'CSM_Completed_Date__c';
			colDate.label = System.Label.CSM_LBL_COMPLETION_DATE;
			colDate.valueCol = 'CSM_Completed_Date__c';
			colDate.isSortable = true;
			colDate.isDateCol = true;
			system.debug(colDate.apiName+'-- Visible');
			colDate.isVisible = true;
			if(successPlanActHistStr.containsIgnoreCase('CSM_Completed_Date__c')){
				system.debug(colDate.apiName+'-- notVisible');
				colDate.isVisible = false;
			}
			gridClmWrapper.add(colDate);
			
		}
		
		
		//Activity Date
		colDate = new CSM_GridColumnWrapper();
		colDate.apiName = 'ActivityDate';
		colDate.label = System.Label.CSM_LBL_DUE_DATE;
		colDate.valueCol = 'ActivityDate';
		colDate.isSortable = true;
		colDate.isDateCol = true;
		system.debug(colDate.apiName+'-- Visible');
		colDate.isVisible = true;
		if (VIEW_NAME_ACTIVITY_HISTORY.equalsIgnoreCase(this.inputWrapper.viewName)){
			if(successPlanActHistStr.containsIgnoreCase('ActivityDate')){
				system.debug(colDate.apiName+'-- notVisible');
				colDate.isVisible = false;
			}
		} else {
			if(successTasksColumnStr.containsIgnoreCase('activitydate')){
				system.debug(colDate.apiName+'-- notVisible');
				colDate.isVisible = false;
			}
		}
		gridClmWrapper.add(colDate);
		
		
		//Subject
		CSM_GridColumnWrapper colSubject = new CSM_GridColumnWrapper();
		colSubject.apiName = 'Subject';
		colSubject.label = System.Label.CSM_LBL_SUBJECT;
		colSubject.valueCol = 'Subject';
		colSubject.lookUpIdCol = 'Id';
		colSubject.isSortable = true;
		colSubject.customColumnSorter = 'customColumnSorter';
		system.debug(colSubject.apiName+'-- Visible');
		colSubject.isVisible = true;
		if (VIEW_NAME_ACTIVITY_HISTORY.equalsIgnoreCase(this.inputWrapper.viewName)){
			if(successPlanActHistStr.containsIgnoreCase('Subject')){
				system.debug(colSubject.apiName+'-- notVisible');
				colSubject.isVisible = false;
			}
		} else {
			if(successTasksColumnStr.containsIgnoreCase('Subject')){
				system.debug(colSubject.apiName+'-- notVisible');
				colSubject.isVisible = false;
			}
		}
		gridClmWrapper.add(colSubject);
		
		//Access
		CSM_GridColumnWrapper colAccess = new CSM_GridColumnWrapper();
		colAccess.apiName = 'Id';
		colAccess.label = 'Access';
		colAccess.valueCol = 'Id';
		colAccess.isSortable = true;
		gridClmWrapper.add(colAccess);
		
		if (VIEW_NAME_ACTIVITY_HISTORY.equalsIgnoreCase(this.inputWrapper.viewName)){
			//Related To
			CSM_GridColumnWrapper colPlay = new CSM_GridColumnWrapper();
			colPlay.apiName = 'CSM_Play_Display_Name';
			colPlay.label = System.Label.CSM_LBL_PLAY;
			colPlay.valueCol = 'CSM_Play__r.CSM_Display_Name__c';
			colPlay.lookUpIdCol = namespace+'CSM_Play__c';
			colPlay.isSortable = true;
			colPlay.customColumnSorter = 'customColumnSorter';
			//system.debug(colPlay.apiName+'-- Visible');
			colPlay.isVisible = true;
			colPlay.filterControl = 'select';
			if(successPlanActHistStr.containsIgnoreCase('CSM_Play__c')){
				//system.debug(colPlay.apiName+'-- notVisible');
				colPlay.isVisible = false;
			}
			gridClmWrapper.add(colPlay);
					
		} else {
			//Related To
			CSM_GridColumnWrapper colRelatedTo = new CSM_GridColumnWrapper();
			colRelatedTo.apiName = 'WhatId';
			colRelatedTo.label = System.Label.CSM_LBL_RELATEDTO;
			colRelatedTo.valueCol = 'What.Name';
			colRelatedTo.lookUpIdCol = 'WhatId';
			colRelatedTo.isSortable = true;
			colRelatedTo.customColumnSorter = 'customColumnSorter';
			//system.debug(colRelatedTo.apiName+'-- Visible');
			colRelatedTo.isVisible = true;
			if(successTasksColumnStr.containsIgnoreCase('WhatId')){
				//system.debug(colRelatedTo.apiName+'-- notVisible');
				colRelatedTo.isVisible = false;
			}
			gridClmWrapper.add(colRelatedTo);	
			
	
			
		}
		
		//Playbook
		if (VIEW_NAME_ACTIVITY_HISTORY.equalsIgnoreCase(this.inputWrapper.viewName)){
			CSM_GridColumnWrapper colPlaybook = new CSM_GridColumnWrapper();
			colPlaybook.apiName = 'CSM_SuccessPlan_Play__c';
			colPlaybook.label = 'Playbook';
			colPlaybook.valueCol = 'CSM_SuccessPlan_Play__r.CSM_SuccessPlan_Playbook__r.CSM_Playbook__r.CSM_Display_Name__c';
			colPlaybook.isSortable = true;
			colPlaybook.customColumnSorter = 'customColumnSorter';
			colPlaybook.lookUpIdCol = namespace+'CSM_SuccessPlan_Play__c';
			colPlaybook.filterControl = 'select';
			colPlaybook.isVisible = false;
			colPlaybook.isDateCol = false;
		    gridClmWrapper.add(colPlaybook);
		}
				
		//Assigned To
		CSM_GridColumnWrapper colAssignedTo = new CSM_GridColumnWrapper();
		colAssignedTo.apiName = 'OwnerId';
		colAssignedTo.label = System.Label.CSM_LBL_ASSIGNEDTO;
		colAssignedTo.valueCol = 'Owner.Name';
		colAssignedTo.lookUpIdCol = 'OwnerId';
		colAssignedTo.isSortable = true;
		colAssignedTo.customColumnSorter = 'customColumnSorter';
		//system.debug(colAssignedTo.apiName+'-- Visible');
		colAssignedTo.isVisible = true;
		if (VIEW_NAME_ACTIVITY_HISTORY.equalsIgnoreCase(this.inputWrapper.viewName)) {
			colAssignedTo.filterControl = 'select';
			if(successPlanActHistStr.containsIgnoreCase('OwnerId')){
				//system.debug(colAssignedTo.apiName+'-- notVisible');
				colAssignedTo.isVisible = false;
			}
		} else {
			if(successTasksColumnStr.containsIgnoreCase('OwnerId')){
				//system.debug(colAssignedTo.apiName+'-- notVisible');
				colAssignedTo.isVisible = false;
			}
		}
		gridClmWrapper.add(colAssignedTo);		


		if (!VIEW_NAME_ACTIVITY_HISTORY.equalsIgnoreCase(this.inputWrapper.viewName)){
			if(CSM_Util.getRecordTypeExists(new Task())){
				//Record Type
				CSM_GridColumnWrapper colRecordType = new CSM_GridColumnWrapper();
				colRecordType.apiName = 'RecordType.Name';
				colRecordType.label = System.Label.CSM_LBL_RECORD_TYPE;
				colRecordType.valueCol = 'RecordType.Name';
				colRecordType.isDateCol = false;		
				colRecordType.isSortable = true;
				colRecordType.customColumnSorter = 'customColumnSorter';
				colRecordType.isVisible = true;
				if(String.isBlank(successTasksColumnStr) 
					|| successTasksColumnStr.containsIgnoreCase('RecordType.Name')){
					colRecordType.isVisible = false;
				}
				gridClmWrapper.add(colRecordType);	
			}
		}

		
		if (VIEW_NAME_ACTIVITY_HISTORY.equalsIgnoreCase(this.inputWrapper.viewName)){
			//Task Type
			CSM_GridColumnWrapper colTaskType = new CSM_GridColumnWrapper();
			colTaskType.apiName = 'Type';
			colTaskType.label = System.Label.CSM_LBL_TASK_TYPE;
			colTaskType.valueCol = 'Type';
			colTaskType.isDateCol = false;		
			colTaskType.isSortable = true;
			colTaskType.customColumnSorter = 'customColumnSorter';
			colTaskType.isVisible = true;
			colTaskType.filterControl = 'select';
			if(successPlanActHistStr.containsIgnoreCase('Type')){
				colTaskType.isVisible = false;
			}
			gridClmWrapper.add(colTaskType);	

			if(CSM_Util.getRecordTypeExists(new Task())){
				//Record Type
				CSM_GridColumnWrapper colRecordType = new CSM_GridColumnWrapper();
				colRecordType.apiName = 'RecordType_Name';
				colRecordType.label = System.Label.CSM_LBL_RECORD_TYPE;
				colRecordType.valueCol = 'RecordType.Name';
				colRecordType.isDateCol = false;		
				colRecordType.isSortable = true;
				colRecordType.customColumnSorter = 'customColumnSorter';
				colRecordType.isVisible = true;
				colRecordType.filterControl = 'select';
				if(String.isBlank(successPlanActHistStr) 
					|| successPlanActHistStr.containsIgnoreCase('RecordType.Name')){
					colRecordType.isVisible = false;
				}
				gridClmWrapper.add(colRecordType);	
			}
			
			//Related To
			/*CSM_GridColumnWrapper colActivityType = new CSM_GridColumnWrapper();
			colActivityType.apiName = 'ActivityType';
			colActivityType.label = System.Label.CSM_LBL_ACTIVITY_TYPE;
			colActivityType.valueCol = 'ActivityType';
			colActivityType.isSortable = true;
			system.debug(colActivityType.apiName+'-- Visible');
			colActivityType.isVisible = true;
			if(successPlanActHistStr.contains('activitytype')){
				system.debug(colActivityType.apiName+'-- notVisible');
				colActivityType.isVisible = false;
			}
			gridClmWrapper.add(colActivityType);*/
				
			//Related To
			CSM_GridColumnWrapper colTaskState = new CSM_GridColumnWrapper();
			colTaskState.apiName = 'CSM_Task_State__c';
			colTaskState.label = System.Label.CSM_LBL_TASK_STATE;
			colTaskState.valueCol = 'CSM_Task_State__c';
			colTaskState.isSortable = true;
			colTaskState.customColumnSorter = 'customColumnSorter';
			//system.debug(colTaskState.apiName+'-- Visible');
			colTaskState.isVisible = true;
			colTaskState.filterControl = 'select';
			if(successPlanActHistStr.containsIgnoreCase('csm_task_state__c')){
				//system.debug(colTaskState.apiName+'-- notVisible');
				colTaskState.isVisible = false;
			}
			gridClmWrapper.add(colTaskState);
			
			//Play Exit Date
			CSM_GridColumnWrapper colPlayExitState = new CSM_GridColumnWrapper();
			colPlayExitState.apiName = 'CSM_Play_Exit_Date__c';
			colPlayExitState.label = System.Label.CSM_LBL_PLAY_EXIT_DATE;
			colPlayExitState.valueCol = 'CSM_Play_Exit_Date__c';
			colPlayExitState.isSortable = true;
			colPlayExitState.isDateCol = true;
			//system.debug(colPlayExitState.apiName+'-- Visible');
			colPlayExitState.isVisible = true;
			if(successPlanActHistStr.containsIgnoreCase('CSM_Play_Exit_Date__c')){
				//system.debug(colPlayExitState.apiName+'-- notVisible');
				colPlayExitState.isVisible = false;
			}
			CSM_GridColumnWrapper hasPlayCol = new CSM_GridColumnWrapper();
			hasPlayCol.apiName = 'CSM_Play__c';
			hasPlayCol.label = System.Label.CSM_LBL_HAS_PLAY;
			hasPlayCol.valueCol = 'CSM_SuccessPlan_Play__r.CSM_Play__c';
			hasPlayCol.isDateCol = false;		
			hasPlayCol.isSortable = true;
			hasPlayCol.isVisible = true;
			hasPlayCol.filterControl = 'select';
			if(successPlanActHistStr.contains('CSM_Play__c')){
				hasPlayCol.isVisible = false;
			}
			gridClmWrapper.add(hasPlayCol);
			gridClmWrapper.add(colPlayExitState);					
		} else {
			//Status
			CSM_GridColumnWrapper colStatus = new CSM_GridColumnWrapper();
			colStatus.apiName = 'Status';
			colStatus.label = System.Label.REN_LBL_SCLI_STATUS;
			colStatus.valueCol = 'Status';
			colStatus.isSortable = true;
			colStatus.customColumnSorter = 'customColumnSorter';
			//system.debug(colStatus.apiName+'-- Visible');
			colStatus.isVisible = true;
			if(successTasksColumnStr.containsIgnoreCase('Status')){
				//system.debug(colStatus.apiName+'-- notVisible');
				colStatus.isVisible = false;
			}
			gridClmWrapper.add(colStatus);
			
			//IsClosed
			CSM_GridColumnWrapper colIsClosed = new CSM_GridColumnWrapper();
			colIsClosed.apiName = 'IsClosed';
			colIsClosed.label = 'IsClosed';
			colIsClosed.valueCol = 'IsClosed';
			colIsClosed.isVisible = false;
			colIsClosed.isSwitchable = false;
			gridClmWrapper.add(colIsClosed);
		}
		System.debug('Grid Header $$$$$$$ ' + gridClmWrapper);
		return gridClmWrapper;
	} 	
	
	private List<sObject> getTaskList() {
		List<sObject> taskList = new List<sObject>();
		String taskOrViewId = '';
		if(String.isNotBlank(this.inputWrapper.params.taskOrViewId))
		{
		    taskOrViewId = String.escapeSingleQuotes(this.inputWrapper.params.taskOrViewId);
		}
		System.debug('ZZZ - taskOrViewId ' + taskOrViewId);
		System.debug('ZZZ - userPreferenceObj ' + userPreferenceObj);
		/*if (userPreferenceObj != null && userPreferenceObj.CSM_Success_Task_Filter__c != null &&
			taskOrViewId != userPreferenceObj.CSM_Success_Task_Filter__c) {
			taskOrViewId = userPreferenceObj.CSM_Success_Task_Filter__c;
		}*/
		System.debug('ZZZ - taskOrViewId ' + taskOrViewId);
		
		if (String.isNotBlank(taskOrViewId)){
			List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
			try {
				fcViewList = CSM_FocusCategoryViewDataAccess.findFCVByViewID(String.escapeSingleQuotes(taskOrViewId));	
			} catch (exception ex) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			}
			if (fcViewList != null && !fcViewList.isEmpty()){
				CSM_Focus_Category_View__c fcView = fcViewList[0];
				if (fcView.CSM_SOQL__c != null){
					try {
                       	fcView.CSM_SOQL__c = CSM_Util.processMyFCVSOQL(fcView.CSM_SOQL__c, fcView.CSM_Filter_By_Owner_Value__c);
						
						Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_SUCCESS_TASKS); 
            
						if (fcView.CSM_SOQL__c!=null && ((String)fcView.CSM_SOQL__c).length()>0 && !((String)fcView.CSM_SOQL__c).toUpperCase().contains('LIMIT')){
                    		fcView.CSM_SOQL__c += ' LIMIT ' + limitVal;
                    	}
                    	 system.debug('query' + fcView.CSM_SOQL__c);
                    	 
                        taskList = database.query(fcView.CSM_SOQL__c);
					} catch (Exception ex){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_EDIT_FC_AND_SAVE));
					}
				}
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Label.CSM_MSG_SELECT_OBJECT_TO_PROCEED));
		}
		system.debug('taskList::' + taskList);
		return taskList;
	}
}