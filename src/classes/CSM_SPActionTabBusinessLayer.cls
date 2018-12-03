public with sharing class CSM_SPActionTabBusinessLayer extends CSM_BusinessLayer {
	
	private static final String DEFAULT_SORT_EXPRESSION = 'ActivityDate';
	private CSM_User_Preferences__c userPreferenceObj = new CSM_User_Preferences__c();
	
	public CSM_SPActionTabBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
		super(inputWrapper);
		userPreferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(UserInfo.getUserId(),'CSM_Success_Plan_Actions_Filter__c,CSM_Success_Plan_Actions_Grid_Columns__c');
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
		return getTaskWrapperList();
	}
	private CSM_GridResponseWrapper getTaskWrapperList() {
		//business logic for setting up Lists for <CSM_GridRowWrapper> and <CSM_GridColumnWrapper>
		CSM_GridResponseWrapper taskWrapperList = new CSM_GridResponseWrapper();
		
		List<Task> taskList;
		System.debug('ZZZ -'+this.inputWrapper.viewName);
		
		//setup the CSM_GridColumnWrapper object for header values, 
		taskWrapperList.header = setTaskHeader();

		taskWrapperList.hasAction = true;
		taskWrapperList.hasDetail = true;		
		
		taskList = getTaskList();
		
		taskWrapperList.row = setTaskRows(taskList, taskWrapperList.header);

		//setup the CSM_GridRowWrapper for the column values to be fed in it, maintain the order in which the headers are created.
		/*if (!taskList.isEmpty()) {
			taskWrapperList.row = setTaskRows(taskList, taskWrapperList.header);
		}*/
		return taskWrapperList;
	}
	
	private List<CSM_GridColumnWrapper> setTaskHeader() {
		String namespace = CSM_Util.getNamespace();
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();
		String successPlanActionStr = '';
		if(userPreferenceObj != null){
			if(userPreferenceObj.CSM_Success_Plan_Actions_Grid_Columns__c != null){
				successPlanActionStr = userPreferenceObj.CSM_Success_Plan_Actions_Grid_Columns__c.toLowerCase();
				
				system.debug(successPlanActionStr+'Entire List in Business Layer');
			} 
		}
		if(!successPlanActionStr.contains('recordtype.name')){
			successPlanActionStr += 'recordtype.name';
		}
		if(!successPlanActionStr.contains('type')){
			successPlanActionStr += 'type';
		}
		
		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		//Completion Date
		CSM_GridColumnWrapper colDate = new CSM_GridColumnWrapper();
		
		//Activity Date
		colDate = new CSM_GridColumnWrapper();
		colDate.apiName = 'ActivityDate';
		colDate.label = System.Label.CSM_LBL_DUE_DATE;
		colDate.valueCol = 'ActivityDate';
		colDate.isSortable = true;
		colDate.isDateCol = true;
		colDate.isVisible = true;
		if(successPlanActionStr.contains('ActivityDate')){
			system.debug(colDate.apiName+'-- notVisible');
			colDate.isVisible = false;
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
		colSubject.isVisible = true;
		if(successPlanActionStr.contains('Subject')){
			system.debug(colSubject.apiName+'-- notVisible');
			colSubject.isVisible = false;
		}
		gridClmWrapper.add(colSubject);
		
		//Play Name
		CSM_GridColumnWrapper colPlay = new CSM_GridColumnWrapper();
		colPlay.apiName = 'CSM_Play_Display_Name';
		colPlay.label = System.Label.CSM_LBL_PLAY;
		colPlay.valueCol = 'CSM_Play__r.CSM_Display_Name__c';
		colPlay.isSortable = true;
		colPlay.customColumnSorter = 'customColumnSorter';
		colPlay.lookUpIdCol = namespace+'CSM_Play__c';
		system.debug(colPlay.apiName+'-- Visible');
		colPlay.isVisible = true;
		colPlay.filterControl = 'select';
		if(successPlanActionStr.contains('CSM_Play__r.CSM_Display_Name__c')){
			system.debug(colPlay.apiName+'-- notVisible');
			colPlay.isVisible = false;
		}
		gridClmWrapper.add(colPlay);
		
		//Playbook
		CSM_GridColumnWrapper colPlaybook = new CSM_GridColumnWrapper();
		colPlaybook.apiName = 'CSM_SuccessPlan_Play__c';
		colPlaybook.label = 'Playbook';
		colPlaybook.valueCol = 'CSM_SuccessPlan_Play__r.CSM_SuccessPlan_Playbook__r.CSM_Playbook__r.CSM_Display_Name__c';
		colPlaybook.isSortable = true;
		colPlaybook.customColumnSorter = 'customColumnSorter';
		colPlaybook.filterControl = 'select';
		colPlaybook.lookUpIdCol = namespace+'CSM_SuccessPlan_Play__c';
		colPlaybook.isVisible = false;
		colPlaybook.isDateCol = false;		
		
		
		gridClmWrapper.add(colPlaybook);
			
		//Assigned To
		CSM_GridColumnWrapper colAssignedTo = new CSM_GridColumnWrapper();
		colAssignedTo.apiName = 'Ownerid';
		colAssignedTo.label = System.Label.CSM_LBL_ASSIGNEDTO;
		colAssignedTo.valueCol = 'Owner.Name';
		colAssignedTo.isSortable = true;
		colAssignedTo.customColumnSorter = 'customColumnSorter';
		colAssignedTo.lookUpIdCol = 'OwnerId';
		colAssignedTo.filterControl = 'select'; 
		system.debug(colAssignedTo.apiName+'-- Visible');
		colAssignedTo.isVisible = true;
		if(successPlanActionStr.contains('Ownerid')){
			system.debug(colAssignedTo.apiName+'-- notVisible');
			colAssignedTo.isVisible = false;
		}
		gridClmWrapper.add(colAssignedTo);	
		
		//Related To
		CSM_GridColumnWrapper colRelatedTo = new CSM_GridColumnWrapper();
		colRelatedTo.apiName = 'WhatId';
		colRelatedTo.label = System.Label.CSM_LBL_RELATEDTO;
		colRelatedTo.valueCol = 'What.Type';
		colRelatedTo.isSortable = true;
		colRelatedTo.customColumnSorter = 'customColumnSorter';
		colRelatedTo.filterControl = 'select'; 
		system.debug(colRelatedTo.apiName+'-- Visible');
		colRelatedTo.isVisible = true;
		if(successPlanActionStr.contains('WhatId')){
			system.debug(colRelatedTo.apiName+'-- notVisible');
			colRelatedTo.isVisible = false;
		}
		gridClmWrapper.add(colRelatedTo);
		
		
		
		
		//Status			
		CSM_GridColumnWrapper colStatus = new CSM_GridColumnWrapper();
		colStatus.apiName = 'Status';
		colStatus.label = System.Label.REN_LBL_SCLI_STATUS;
		colStatus.valueCol = 'Status';
		colStatus.isSortable = true;
		colStatus.customColumnSorter = 'customColumnSorter';
		colStatus.isVisible = true;
		colStatus.filterControl = 'select'; 
		if(successPlanActionStr.contains('Status')){
			system.debug(colStatus.apiName+'-- Not Visible');
			colStatus.isVisible = false;
		}
		gridClmWrapper.add(colStatus);
		
		//Play Status
		CSM_GridColumnWrapper colPlayStatus = new CSM_GridColumnWrapper();
		colPlayStatus.apiName = 'CSM_Play_Status__c';
		colPlayStatus.label = System.Label.CSM_LBL_PLAY_STATUS;
		colPlayStatus.valueCol = 'CSM_Play_Status__c';
		colPlayStatus.isSortable = true;
		colPlayStatus.customColumnSorter = 'customColumnSorter';
		colPlayStatus.isVisible = true;
		colPlayStatus.filterControl = 'select';
		if(successPlanActionStr.contains('CSM_Play_Status__c')){
			system.debug(colPlayStatus.apiName+'-- Not Visible');
			colPlayStatus.isVisible = false;
		}
		gridClmWrapper.add(colPlayStatus);
		
		//Access
		CSM_GridColumnWrapper colAccess = new CSM_GridColumnWrapper();
		colAccess.apiName = 'id';
		colAccess.label = 'Access';
		colAccess.valueCol = 'id';
		colAccess.isSortable = true;
		gridClmWrapper.add(colAccess);
				
		//Play Enter Date
		CSM_GridColumnWrapper colPlayEnterDate = new CSM_GridColumnWrapper();
		colPlayEnterDate.apiName = 'CSM_Play_Enter_Date__c';
		colPlayEnterDate.label = System.Label.CSM_LBL_PLAY_ENTER_DATE;
		colPlayEnterDate.valueCol = 'CSM_Play_Enter_Date__c';
		colPlayEnterDate.isDateCol = true;		
		colPlayEnterDate.isSortable = true;
		colPlayEnterDate.isVisible = true;
		if(successPlanActionStr.contains('CSM_Play_Enter_Date__c')){
			system.debug(colPlayEnterDate.apiName+'-- Not Visible');
			colPlayEnterDate.isVisible = false;
		}
		gridClmWrapper.add(colPlayEnterDate);	
		
		
		//Task Type
		CSM_GridColumnWrapper colTaskType = new CSM_GridColumnWrapper();
		colTaskType.apiName = 'Type';
		colTaskType.label = System.Label.CSM_LBL_TASK_TYPE;
		colTaskType.valueCol = 'Type';
		colTaskType.isDateCol = false;		
		colTaskType.isSortable = true;
		colTaskType.isVisible = false;
		colTaskType.filterControl = 'select';
		if(successPlanActionStr.contains('Type')){
			system.debug(colPlayEnterDate.apiName+'-- Not Visible');
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
			colRecordType.isVisible = false;
			colRecordType.filterControl = 'select';
			if(successPlanActionStr.contains('RecordType.Name')){
				colRecordType.isVisible = false;
			}
			gridClmWrapper.add(colRecordType);	
		}
		
				//Task Type
		CSM_GridColumnWrapper hasPlayCol = new CSM_GridColumnWrapper();
		hasPlayCol.apiName = 'CSM_Play__c';
		hasPlayCol.label = System.Label.CSM_LBL_HAS_PLAY;
		hasPlayCol.valueCol = 'CSM_SuccessPlan_Play__r.CSM_Play__c';
		hasPlayCol.isDateCol = false;		
		hasPlayCol.isSortable = true;
		hasPlayCol.isVisible = true;
		hasPlayCol.filterControl = 'select';
		if(successPlanActionStr.contains('CSM_Play__c')){
			system.debug(colPlayEnterDate.apiName+'-- Not Visible');
			colTaskType.isVisible = false;
		}
		gridClmWrapper.add(hasPlayCol);

		
		return gridClmWrapper;
		//Play Exit Date
		/*CSM_GridColumnWrapper colPlayExitDate = new CSM_GridColumnWrapper();
		colPlayExitDate.apiName = 'CSM_Play_Exit_Date__c';
		colPlayExitDate.label = System.Label.CSM_LBL_PLAY_EXIT_DATE;
		colPlayExitDate.valueCol = 'CSM_Play_Exit_Date__c';
		colPlayExitDate.isDateCol = true;
		colPlayExitDate.isSortable = true;
		//colPlayExitDate.isSwitchable = false;
		gridClmWrapper.add(colPlayExitDate);*/

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

				row.id = (String)sObj.get('Id');
				row.playSelected = (String)sObj.get('CSM_Play__c');
                row.hasAccess = false;
                row.isMC = CSM_Util.checkMCEnabled();
				row.namespace = CSM_Util.getNamespace();
				if(recAccessMap.containsKey(row.id)){
					row.hasAccess = (Boolean)recAccessMap.get(row.id);
				}
				
				sObject temp = sObj.getSObject('CSM_Account_Plan__r');
				if (temp != null) {
					row.accountId = (String)temp.get('CSM_AccountId__c');
				}
				//row.accountId = (String)sObj.getSObject('CSM_Account_Plan__r').get('CSM_AccountId__c');
				row.sObj = sObj;
				row.columns = new List<CSM_GridColumnWrapper>();
				if (colList!=null){
					row.columns = colList;
					/*
					for (CSM_GridColumnWrapper colOrig : colList){
						CSM_GridColumnWrapper col = colOrig.clone();
						if (col.valueCol.contains('.')){
							String[] objSplit = col.valueCol.split('\\.');
							if (objSplit!=null && objSplit.size()==2){
								try {
									col.value = String.valueOf(sObj.getSObject(objSplit[0]).get(objSplit[1]));
								} catch (Exception ex) {
									
								}
							}
						} else {
							col.value = String.valueOf(sObj.get(col.valueCol));
						}
						
						if (col.isDateCol!=null && col.isDateCol && String.isNotBlank(col.value)){
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
	 	


	private List<Task> getTaskList() {	
		List<Task> accountPlanTaskList = new List<Task>();
		String acctId = String.escapeSingleQuotes(this.inputWrapper.params.accountId);
		String selTaskFilter = String.escapeSingleQuotes(this.inputWrapper.params.selectedTaskFilter);
		System.debug('ZZZ - selTaskFilter ' + selTaskFilter);
		//System.debug('ZZZ - userPreferenceObj.CSM_Success_Plan_Actions_Filter__c ' + userPreferenceObj.CSM_Success_Plan_Actions_Filter__c);
		if (userPreferenceObj != null && userPreferenceObj.CSM_Success_Plan_Actions_Filter__c != null &&
			selTaskFilter != userPreferenceObj.CSM_Success_Plan_Actions_Filter__c) {
			selTaskFilter = userPreferenceObj.CSM_Success_Plan_Actions_Filter__c;
		}
		System.debug('ZZZ - selTaskFilter ' + selTaskFilter);
		
		String sortExp = String.escapeSingleQuotes(DEFAULT_SORT_EXPRESSION);
		String sortDir = String.escapeSingleQuotes(CSM_Constants.SORT_DIRECTION_DESCENDING);
		accountPlanTaskList = CSM_TaskDataAccess.getNotCompletedTasksByAccountPlan(acctId, selTaskFilter, sortExp, sortDir);		
		system.debug('accountPlanTaskList is::' + accountPlanTaskList);
		system.debug('accountPlanTaskSize is::' + accountPlanTaskList.size());
		return accountPlanTaskList;
	}
	
}