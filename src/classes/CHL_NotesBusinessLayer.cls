public with sharing class CHL_NotesBusinessLayer {
	
	/**
      * @description :This method returns the data for Task associated with the partner Opportunity in community.
                      Added for US3116
    */
    public static object getTaskList(string inputvalue)    {
    	CHL_AngularTabsInputWrapper tabInputObj = new CHL_AngularTabsInputWrapper();
        tabInputObj = (CHL_AngularTabsInputWrapper)JSON.deserialize(inputValue, CHL_AngularTabsInputWrapper.class);
        List<CHL_NotesTabsDetailsWrapper> noteDetailWrapperList = getTaskWrapperList(tabInputObj.oppId);        
		//system.debug('\n\n @@calling noteDetailWrapperList :: ' + JSON.serialize(noteDetailWrapperList));
		return noteDetailWrapperList;
    }
    
    
    /**
      * @description :This method will create task for Partner opportunity on click of Send button and then return list of all tasks associated to that PO.
                      Added for US3116
    */
     public static object createTaskForOpportunity(string inputvalue)    {
    	CHL_AngularTabsInputWrapper tabInputObj = new CHL_AngularTabsInputWrapper();
        tabInputObj = (CHL_AngularTabsInputWrapper)JSON.deserialize(inputValue, CHL_AngularTabsInputWrapper.class);
        //List<CHL_NotesTabsDetailsWrapper> noteDetailWrapperList;
        if(String.isNotBlank(tabInputObj.note)) {
	        List<Task> taskList = new List<Task>();
	        List<CHL_Partner_Opportunity__C> poList = CHL_PartnerOpportunityDataAccess.getPartnerOpportunityDataById(new Set<Id>{tabInputObj.oppId} );
	        Id relatedOppty = poList != null && !poList.isEmpty() && poList[0].CHL_Opportunity__c != null ? poList[0].CHL_Opportunity__c : null;
	        Task taskObj = new Task(CSM_Related_Opportunity__c = relatedOppty, Status ='Completed', Type = 'Status Update', Subject = 'Status Update',
							        CHL_Status_Update__c = true, WhatId = tabInputObj.oppId, CHL_Related_Partner_Opportunity__c = tabInputObj.oppId,
							        Description = tabInputObj.note, ActivityDate = date.today());
			taskList.add(taskObj);
			CSM_Constants.TASK_TRIGGER = false;
			List<Database.SaveResult> taskListToinsert = database.insert(taskList, false);	
			if(taskListToinsert[0].isSuccess()) {
				for(CHL_Partner_Opportunity__C poObj: poList) {
					poObj.CHL_Status__c = tabInputObj.note;
					poObj.CHL_Last_Status_Update_Date__c = Date.valueof(system.now());
	                poObj.CHL_Needs_Status_Update__c = false;
		 			//poListToUpdate.add(poObj);	
				}
				CHL_Constants.PARTNEROPPORTUNITY_BEFORE_TRIGGER = false;
	 			CHL_Constants.PARTNEROPPORTUNITY_AFTER_TRIGGER = false;	
	 			CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(poList);	
			}	        
	        //noteDetailWrapperList = getTaskWrapperList(tabInputObj.oppId);   
        } 
        return null;
    }
    
    /*public static object getNotesList(string inputvalue)    {
        CHL_AngularTabsInputWrapper tabInputObj = new CHL_AngularTabsInputWrapper();
        tabInputObj = (CHL_AngularTabsInputWrapper)JSON.deserialize(inputValue, CHL_AngularTabsInputWrapper.class);
        String partnerOpportunityId = tabInputObj.oppId;
        List<CHL_NotesTabsDetailsWrapper> noteDetailWrapperList = new List<CHL_NotesTabsDetailsWrapper>();
		List<Note> notesList = CHL_NoteDataAccess.getNoteListByPartnerOpp(partnerOpportunityId);
		if(notesList != null){
			for(Note noteObj : notesList){
				CHL_NotesTabsDetailsWrapper noteDetailWrapperObj = new CHL_NotesTabsDetailsWrapper();
					noteDetailWrapperObj.note = noteObj.Body;
	                noteDetailWrapperObj.createdBy = noteObj.CreatedBy.name;
					Date currentDateVal = Date.valueOf(noteObj.CreatedDate);
					noteDetailWrapperObj.creationDate = currentDateVal.format();
					noteDetailWrapperObj.recordId = noteObj.Id;
					noteDetailWrapperList.add(noteDetailWrapperObj);
			}
		}
		system.debug('\n\n @@calling noteDetailWrapperList :: ' + JSON.serialize(noteDetailWrapperList));
		return noteDetailWrapperList;
    }*/
	
	/**
      * @description :This method returns the data of CaseComments associated with the cases in community.
                      Added for US904.
    */
	public static object getCaseCommentsList(string inputvalue) {
		CHL_AngularTabsInputWrapper tabInputObj = new CHL_AngularTabsInputWrapper();
		tabInputObj = (CHL_AngularTabsInputWrapper)JSON.deserialize(inputValue, CHL_AngularTabsInputWrapper.class);
		List<CHL_NotesTabsDetailsWrapper> caseCommentWrapperList = new List<CHL_NotesTabsDetailsWrapper>();
		List<CaseComment> caseCommentList = CHL_NoteDataAccess.getCaseCommentByCaseId(tabInputObj.requestId);
		system.debug('\n\n\n caseCommentList  :: ' + caseCommentList);
		if (caseCommentList != null) {
			for (CaseComment caseCommentObj: caseCommentList) {
				CHL_NotesTabsDetailsWrapper caseCommentWrapperObj = new CHL_NotesTabsDetailsWrapper();
				caseCommentWrapperObj.note = caseCommentObj.CommentBody;
				caseCommentWrapperObj.createdBy = caseCommentObj.CreatedBy.name;
				Date currentDateVal = Date.valueOf(caseCommentObj.CreatedDate);
				caseCommentWrapperObj.creationDate = currentDateVal.format();
				caseCommentWrapperObj.recordId = caseCommentObj.Id;
				String userId = UserInfo.getUserId();
				if (caseCommentObj.CreatedById == userId) {
					caseCommentWrapperObj.fromPartner = true;
				} else {
					caseCommentWrapperObj.fromPartner = false;
				}
				caseCommentWrapperList.add(caseCommentWrapperObj);
			}
		}
		system.debug('\n\n @@calling caseCommentWrapperList :: ' + JSON.serialize(caseCommentWrapperList));
		return caseCommentWrapperList;
	}

	private static List<CHL_NotesTabsDetailsWrapper> getTaskWrapperList(String partnerOpportunityId){
		List<Task> taskList = CSM_TaskDataAccess.getTaskListByPartnerOpp(new Set<Id>{partnerOpportunityId});
		List<CHL_NotesTabsDetailsWrapper> noteDetailWrapperList = new List<CHL_NotesTabsDetailsWrapper>();
		if(taskList != null){
			for(Task taskObj : taskList){
				CHL_NotesTabsDetailsWrapper noteDetailWrapperObj = new CHL_NotesTabsDetailsWrapper();
				noteDetailWrapperObj.note = taskObj.Description;
                noteDetailWrapperObj.createdBy = taskObj.CreatedBy.name;
				Date currentDateVal = Date.valueOf(taskObj.CreatedDate);
				noteDetailWrapperObj.creationDate =currentDateVal.format();
				noteDetailWrapperObj.recordId = taskObj.Id;
				if (taskObj.CreatedById == UserInfo.getUserId()) {
					noteDetailWrapperObj.fromPartner = true;
				} else {
					noteDetailWrapperObj.fromPartner = false;
				}
				noteDetailWrapperList.add(noteDetailWrapperObj);
			}
		}
		return noteDetailWrapperList;
	}
}