public with sharing class CSM_CaseTriggerHandler extends CSM_TriggerManager.TriggerHandler{

		public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, 
    	Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)
    {
    	Set<Id> accIds = new Set<Id>();
    	String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
    	Boolean hasZenithSetting = CSM_AccessController.hasObject(solExtNameSpace+'Zenith_Setting__c');
    	Boolean hasRecordTypeId = CSM_AccessController.hasField('Case','RecordTypeId');
    	List<sObject> zenithSetting = new List<sObject>();
    	if(hasZenithSetting){
    		zenithSetting = CSM_Util.getCustomSetting(new List<String>{solExtNameSpace+'Zenith_Setting__c'}, new List<String>{solExtNameSpace+'Case_Booking_Request_Record_Type_Id__c', solExtNameSpace+'Case_Quote_Request_Record_Type_Id__c', solExtNameSpace+'Case_Review_Request_Record_Type_Id__c'});	   		
    	}
    	Boolean hasZenithFeature = CSM_AccessController.hasObject(solExtNameSpace+'Zenith_Features__c');
    	List<sObject> zenithFeature = new List<sObject>();
    	if(hasZenithFeature){
    		zenithFeature = CSM_Util.getCustomSetting(new List<String>{solExtNameSpace+'Zenith_Features__c'}, new List<String>{solExtNameSpace+'Peer_Review__c', solExtNameSpace+'Auto_Submit_Case_Approval__c'});	   		
    	}
		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled; 
        Set<Id> oldContactIdSet = new Set<Id>();
        Set<Id> newContactIdSet = new Set<Id>();        
        List<Case> caseList = new List<Case>(); 
        Boolean isOWDForCASEPrivate =  CHL_Util.isOWDForCASEPrivate();
        Boolean isPartner = CSM_AccessController.hasfield('Account','isPartner');  
        Boolean hasNetwork =  CSM_AccessController.hasObject('Network');
        Map<id, Contact> oldContactMap = new Map<id, Contact>();
        Approval.ProcessResult[] processResults = null;
        List<Approval.ProcessSubmitRequest> processRequests = new List<Approval.ProcessSubmitRequest>();
        SS_TriggerCollectionParameters.CaseTriggerParams caseParams = new SS_TriggerCollectionParameters.CaseTriggerParams();
        caseParams.qualifiedCasesList = new List<Case>(); 
        caseParams.originalCaseStatusClosedList = new List<Case>(); 
        caseParams.originalCaseStatusClosedID = new Set<Id>();
        caseParams.generateRevisionCaseID = new Set<Id>();
        caseParams.completeMilestoneID = new Set<Id>();
        caseParams.generateRevisionCaseList = new List<Case>();
        if (hasCSMAccess || hasRenewAccess) {
        	Set<Id> accountIds = new Set<Id>();
            for(Case caseNew : (List<Case>)newRecords){
	        	Case caseOld=(Case)oldRecordsMap.get(caseNew.id);
	        	oldContactIdSet.add(caseOld.contactId);
	        	if(caseNew.accountId != null){
	            	accountIds.add(caseNew.accountId);
	                accIds.add(caseNew.accountId);
	            }
	            if(caseOld.accountId != null){
	            	accIds.add(caseOld.accountId);	
	            }
	            if(isOWDForCASEPrivate && isPartner && hasNetwork) {                 	
		        	if(caseOld.Id == caseNew.Id && caseOld.ContactId != caseNew.ContactId ){ 
		        		newContactIdSet.add(caseNew.contactId);
		        		caseList.add(caseNew);
		        	}	
	            }
	            if(hasZenithSetting){
	                if(hasRecordTypeId && zenithFeature[0].get(solExtNameSpace+'Peer_Review__c') == true 
	                && (caseNew.get('RecordTypeId') == zenithSetting[0].get(solExtNameSpace+'Case_Booking_Request_Record_Type_Id__c') || caseNew.get('RecordTypeId') == zenithSetting[0].get(solExtNameSpace+'Case_Quote_Request_Record_Type_Id__c')) 
	                && (caseNew.Status == 'Ready' || caseNew.Status =='Closed')
	                && caseNew.Status != caseOld.Status){
	                	caseParams.qualifiedCasesList.add(caseNew);	
	                }
	                if(zenithFeature[0].get(solExtNameSpace+'Auto_Submit_Case_Approval__c') == true
	                && caseNew.get(solExtNameSpace+'Request_Escalation__c') != caseOld.get(solExtNameSpace+'Request_Escalation__c')
	                && caseNew.get(solExtNameSpace+'Request_Escalation__c') == true){
	                	Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
	                    req.setObjectId(caseNew.Id);
	                    processRequests.add(req);	
	                } 
	                if(hasRecordTypeId && caseNew.get('RecordTypeId') == zenithSetting[0].get(solExtNameSpace+'Case_Review_Request_Record_Type_Id__c')
	                && (caseNew.Status == 'Closed' ||caseNew.Status == 'Closed - Unsuccessfully')
	                && caseNew.Status != caseOld.Status){
	                	caseParams.originalCaseStatusClosedList.add(caseNew);
	                	if(zenithFeature[0].get(solExtNameSpace+'Peer_Review__c') == true
	                	 && caseNew.get(solExtNameSpace+'Original_Case_1P__c') != null) {
	                    	caseParams.originalCaseStatusClosedList.add(caseNew);
	                	}	
	                }
	                else if(hasRecordTypeId && caseNew.get('RecordTypeId') == zenithSetting[0].get(solExtNameSpace+'Case_Review_Request_Record_Type_Id__c')
	                && caseNew.Status == 'Review Failed'
	                && caseNew.Status != caseOld.Status){
	                	caseParams.generateRevisionCaseID.add(caseNew.Id);	
	                	if(zenithFeature[0].get(solExtNameSpace+'Peer_Review__c') == true){
	                    	caseParams.generateRevisionCaseList.add(caseNew);
	                	}
	                }
	                else if((caseNew.Status == 'Closed - Unsuccessfully' || caseNew.Status == 'Closed' ||caseNew.Status == 'Closed Automatically')
	                    && caseNew.Status != caseOld.Status){
	                	caseParams.completeMilestoneID.add(caseNew.Id);
	                }
	            }                                  
            }           
            if (Schema.sObjectType.CSM_Account_Plan__c.isAccessible()){
            	//Only want this to run if user has access to csm/task creation. 
                CSM_TaskCreationTriggerUtil.CreatePlayActivities(accountIds, newRecords, CSM_Constants.OBJ_CASE);
            }
            //Below code added for SF 295: to update account fields
            if(accIds != null && !accIds.isEmpty()) {
            	Set<Id> acctIds = getAccountIdsWithSuccessPlan(accIds);
               	if (!acctIds.IsEmpty()){
                	processCasesForAccountAccess((List<Case>)newRecords, acctIds);                   
	                CSM_UpdateAccountFieldsUtil.UpdateAccFieldsForCases(acctIds);
               	}
            }
        }
		if(oldContactIdSet != null && !oldContactIdSet.isEmpty() && isPartner){
	    	oldContactMap = new Map<id, Contact>(CSM_ContactDataAccess.getPartnerContact(oldContactIdSet));	    	
	    }
		if(caseList != null && !caseList.isEmpty()){
			CSM_CaseTriggerHelper.processCaseSharing(caseList, newContactIdSet, oldContactMap, oldRecordsMap);
		}
		if(hasZenithSetting && (!caseParams.qualifiedCasesList.isEmpty() || !caseParams.originalCaseStatusClosedList.isEmpty() || !caseParams.generateRevisionCaseID.isEmpty() ||  !caseParams.completeMilestoneID.isEmpty())){
			caseParams.triggerEvent = 'onAfterUpdate';
        	(new SS_FeatureInvocation()).invoke((String.isBlank(solExtNameSpace) ? '' : (solExtNameSpace.replace('__','.'))) + 'CaseTriggerInvocationHandler', caseParams);
		}
		if(processRequests != null && !processRequests.isEmpty()){
			processResults = Approval.process(processRequests, true);
		}	           
	}
	
    public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {
		String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
        Boolean hasZenithSetting = CSM_AccessController.hasObject(solExtNameSpace+'Zenith_Setting__c');
        SS_TriggerCollectionParameters.CaseTriggerParams caseParams = new SS_TriggerCollectionParameters.CaseTriggerParams();
        caseParams.newRecords =newRecords;
        caseParams.oldRecordsMap = (Map<ID, Case>)oldRecordsMap;

        if(hasZenithSetting){
			caseParams.triggerEvent = 'onBeforeUpdate';
        	(new SS_FeatureInvocation()).invoke((String.isBlank(solExtNameSpace) ? '' : (solExtNameSpace.replace('__','.'))) + 'CaseTriggerInvocationHandler', caseParams);
		}
    }
    
    public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
        String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
        Boolean hasOpptyField = CSM_AccessController.hasField('Case', solExtNameSpace + 'Opportunity__c' );
        
        CSM_CaseTriggerHelper.CaseRelatedDetailsWrapper caseRelWrapObj = new CSM_CaseTriggerHelper.CaseRelatedDetailsWrapper();
        caseRelWrapObj.oppIdSet = new Set<Id>();
        caseRelWrapObj.filteredCaseList = new List<Case>();
        caseRelWrapObj.opptyIdSet = new Set<Id>();
        caseRelWrapObj.ownerIdSet = new Set<String>();
        caseRelWrapObj.accountIdSet = new Set<String>();
        
        for(Case csObj : (List<Case>)newRecords){
            if(csObj.accountId != null)
            {
                caseRelWrapObj.accountIdSet.add(csObj.accountId);
            }
            
            if(hasOpptyField && csObj.get(solExtNameSpace + 'Opportunity__c') != null){
                caseRelWrapObj.oppIdSet.add((Id)csObj.get(solExtNameSpace + 'Opportunity__c'));
                
                if(csObj.status!=null){
                    caseRelWrapObj.opptyIdSet.add((Id)csObj.get(solExtNameSpace + 'Opportunity__c'));
                    caseRelWrapObj.filteredCaseList.add(csObj);
                }
            } 
            
            if(csObj.ownerId != null){
                caseRelWrapObj.ownerIdSet.add(csObj.ownerId);
            }
            
        }
        caseRelWrapObj.caseLst = newRecords;   
        
        CSM_CaseTriggerHelper.processBeforeInsert(caseRelWrapObj);
        CSM_CaseTriggerHelper.updateSubjectOfCase(caseRelWrapObj);
    }

	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)
	{
		try {
			Set<Id> accIds = new Set<Id>();
			Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
			Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
            Set<Id> newContactIdSet = new Set<Id>();  
			//MF 11/10/2013 Added this check to only execute the task creation when the user has account Plan / CSM
			// Assumption is if they have account plan access, they should have access to play, play tasks etc...
			if (hasCSMAccess || hasRenewAccess) {
				for(Case csObj : (List<Case>)newRecords)
				{
					newContactIdSet.add(csObj.contactId);
					if(csObj.accountId != null)
					{
						accIds.add(csObj.accountId);
					}

				}

				//Below code added for SF 295: to update account fields
				if(accIds != null && !accIds.isEmpty()) {
					Set<Id> acctIds = getAccountIdsWithSuccessPlan(accIds);
					if (!acctIds.IsEmpty()){
						processCasesForAccountAccess((List<Case>)newRecords, acctIds);                   
						CSM_UpdateAccountFieldsUtil.UpdateAccFieldsForCases(acctIds);
					}
				}
			}

			if(CHL_Util.isOWDForCASEPrivate() && CSM_AccessController.hasfield('Account','isPartner') && CSM_AccessController.hasObject('Network')) {
				CSM_CaseTriggerHelper.processCaseSharing((List<Case>)newRecords, newContactIdSet, null, null);
			}		            
		}
		catch (exception ex)
		{
			if (!newRecords.isEmpty()){
				for (Integer i = 0; i < newRecords.size(); i++)
				{
					newRecords[i].addError(ex.getMessage());
				} 
			}
		}
	}

	public override void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap){
		Set<Id> accIds = new Set<Id>();
		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
		Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		Set<Id> acctIds = new Set<Id>();

		//MF 11/10/2013 Added this check to only execute the task creation when the user has account Plan / CSM
		// Assumption is if they have account plan access, they should have access to play, play tasks etc...
		if (hasCSMAccess || hasRenewAccess) {
			for(Case csObj : (List<Case>)oldRecords){
				if(csObj.accountId != null){
					accIds.add(csObj.accountId);
				}
			}
			//Below code added for SF 295: to update account fields
			if(accIds != null && !accIds.isEmpty()) {
				Set<Id> acctIdSPSet = getAccountIdsWithSuccessPlan(accIds);
				if (!acctIdSPSet.IsEmpty()){
					processCasesForAccountAccess((List<Case>)oldRecords, acctIdSPSet);                   
					CSM_UpdateAccountFieldsUtil.UpdateAccFieldsForCases(acctIdSPSet);
				}
			}
		}
	}

	public override void onAfterUnDelete(List<sObject> newRecords){
		Set<Id> accIds = new Set<Id>();
		Boolean hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
		Boolean hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		Set<Id> acctIds = new Set<Id>();

		//MF 11/10/2013 Added this check to only execute the task creation when the user has account Plan / CSM
		// Assumption is if they have account plan access, they should have access to play, play tasks etc...
		if (hasCSMAccess || hasRenewAccess) {
			for(Case csObj : (List<Case>)newRecords){
				if(csObj.accountId != null){
					accIds.add(csObj.accountId);
				}
			}

			//Below code added for SF 295: to update account fields
			if(accIds != null && !accIds.isEmpty()) {
				Set<Id> acctIdSPSet = getAccountIdsWithSuccessPlan(accIds);
				if (!acctIdSPSet.IsEmpty()){
					processCasesForAccountAccess((List<Case>)newRecords, acctIdSPSet);                   
					CSM_UpdateAccountFieldsUtil.UpdateAccFieldsForCases(acctIdSPSet);
				}
			}            
		}
	}

	private void processCasesForAccountAccess(List<Case> cases, Set<Id> accIds){
		Map<Id,Boolean> accountAccessMap = CSM_AccessController.isEditRecordAccess(accIds, userinfo.getUserId());
		if (!accountAccessMap.IsEmpty()) {
			for(Case caseObj : cases){
				if (accountAccessMap.containsKey(caseObj.accountId)){
					boolean editAccessFlag = accountAccessMap.get(caseObj.accountId);
					if(!editAccessFlag){
						accIds.remove((Id)caseObj.get('accountId'));
					}
				}
			}
		}
	}
    
	private Set<Id> getAccountIdsWithSuccessPlan(Set<Id> accIds){
		Set<Id> acctIds = new Set<Id>();
		List<String> acctPlanFieldList = new List<String>{CSM_Constants.OBJ_AP_ACCOUNT,
			CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_AP_ID};
			List<CSM_Account_Plan__c> apList = CSM_AccountPlanDataAccess.getActiveAccountPlans(accIds, acctPlanFieldList);
			if (!apList.IsEmpty()){
				for (CSM_Account_Plan__c ap : apList){
					acctIds.add(ap.CSM_AccountId__c);
				}
			}
		return acctIds;
	}
}