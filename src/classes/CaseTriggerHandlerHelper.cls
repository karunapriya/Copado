public with sharing class CaseTriggerHandlerHelper {
    Zenith_Setting__c ZS = Zenith_Setting__c.getOrgDefaults();
    Zenith_Features__c ZF = Zenith_Features__c.getOrgDefaults();
    private Boolean setCloseFlag = false;
    private set<String> mParentCaseId;
    Map<Id, boolean> mapOfCaseToCloseFlag = new Map<Id, boolean>();
    
    public static void updateInReviewStatus(Set<String> parentCaseIdSet){
    	String baseNameSpace = Util.baseNameSpace;
        if(parentCaseIdSet != null && !parentCaseIdSet.isEmpty()) {
            Set<Id> oppIdSet = new Set<Id>();
            List<Quote> quoteList = QuoteDataAccess.getQuoteByCase(parentCaseIdSet);
            for(Quote q: quoteList){
                q.Review_Status__c = 'In Review';
                if(q.IsSyncing == true){
                    oppIdSet.add(q.OpportunityId);                      
                }
            }
            if(oppIdSet != null ){
                List<Opportunity> opportunityList = OpportunityDataAccess.getOpportunityDetailsById(oppIdSet, new List<String>{baseNameSpace+'CHL_Bypass_Validation_For_Quote_Async__c'}, null);
                if(opportunityList != null && !opportunityList.isEmpty()){
                    for(Opportunity opp : opportunityList){
                        opp.put(baseNameSpace+'CHL_Bypass_Validation_For_Quote_Async__c', true);
                    }
                    OpportunityDataAccess.updateOpportunityList(opportunityList, new List<String>{baseNameSpace+'CHL_Bypass_Validation_For_Quote_Async__c'});                                         
                }
            }
            if(quoteList!=null){
                QuoteDataAccess.updateQuoteList(quoteList);
            }
        }
    }
    
     public void processBeforeUpdate(List<Case> caseLst,Map<ID, sObject> oldRecordsMap){
        boolean closedFlag ;
        Case oldCase;
        Map<Id,Id> caseToOppMap = new Map<Id,Id>();
        List<Case> caseToUpdate = new List<Case>();
        List<Case> reviewReqcase = new List<Case>();
        Set<Id> mOppId = new Set<Id>();
        List<sObject> caseList = new List<sObject>();
        Map<Id,sObject> oldMap = new Map<Id,sObject>();
        List<Case> filteredCaseList = new List<Case>();
        List<BusinessHours> businessHoursList = BusinessHoursDataAccess.getBusinessHoursListByDefault(true);
        BusinessHours bh = businessHoursList[0]; //added by Raphael, US1419
        Set<Id> empIdSet = new Set<Id>();
        for(Case newCase : caseLst) {
        	oldCase = (case)oldRecordsMap.get(newCase.Id);
        	if (!businessHoursList.isEmpty()){
        		addErrorToCase(newCase);
            	if((newCase.OwnerId != oldCase.OwnerId || newCase.ClosedDate != oldCase.ClosedDate || newCase.Status != oldCase.Status || newCase.Origin != oldCase.Origin)
                && (newCase.Status == 'Review Failed' || newCase.Status == 'Closed' || newCase.Status == 'Closed - Unsuccessfully' || newCase.Status == 'Closed Automatically')) {
                	empIdSet.add(newCase.OwnerId);
                	filteredCaseList.add(newCase);
            	}
            
        	/*** added by Raphael, US1419 ***/
        		if(ZF.Populate_Total_Resolved_Business_Hour__c && newCase.Status != oldCase.Status 
            	&& (newCase.Status == 'Review Failed' || newCase.Status == 'Closed' || newCase.Status == 'Closed - Unsuccessfully' || newCase.Status == 'Closed Automatically' || newCase.Status == 'Ready')){
            
            		newCase.Total_Resolved_Business_Hour_min__c = Util.defaultDifferentInMin(bh.Id, newCase.CreatedDate, System.Now());        
        		}
        		setClosedFlag(newCase,oldCase);
    		}
           		/*** end, US1419 ***/
            if(newCase.Opportunity__c!=null && newCase.status!=null){
            	if(oldRecordsMap!=null){
            		if(oldCase.get('status')!=newCase.status || oldCase.get(Util.solnExtnNameSpace+'Opportunity__c')!=newCase.Opportunity__c){
                    	caseToOppMap.put(newCase.id,newCase.Opportunity__c);
                        mOppId.add(newCase.Opportunity__c);
                        caseToUpdate.add(newCase);
                    }            		
            	}
            }           	
        }
        getOperationLineItems(filteredCaseList, empIdSet);
        Map<Id,Opportunity> mapOfOpp = new Map<Id,Opportunity>(OpportunityDataAccess.getOpportunityDetailsById(mOppId, new List<String>{'Ops_Stage__c','StageName'}, new List<String>{'RecordType.Name'}));       
        if(mOppId!=null && caseToUpdate.size()>0){
            List<Opportunity> impactedOppList = updateOpsStage(caseToUpdate,mapOfOpp,caseToOppMap);
            OpportunityDataAccess.updateOpportunityList(impactedOppList, new List<String>{'Ops_Stage__c'});		        		        			           
        }
        caseValidationOnUsers(caseLst, oldRecordsMap);
    }
    public static void getOperationLineItems(List<Case> caseList, Set<Id> empIdSet){
        if(caseList != null && !caseList.isEmpty() && empIdSet != null && !empIdSet.isEmpty()){
            Map<Id,List<Operations_Target_Line_Item__c>> empIdToOpTargetLIMap = OperationTargetLIDataAccess.getOperationLineItemsByEmpId(empIdSet);
            
            if(empIdToOpTargetLIMap != null && !empIdToOpTargetLIMap.isEmpty()){
            	Date startDate, endDate, currentDate = Date.newInstance(System.Now().year(), System.Now().month(), System.Now().day());
                String originStr;
                
                for(Case caseObj : caseList){
                    
                    if(caseObj.ClosedDate != null){
                        startDate = Date.newInstance(caseObj.ClosedDate.year(), caseObj.ClosedDate.month(), caseObj.ClosedDate.day());
                        endDate = startDate;
                    }else {
                        startDate = currentDate;
                        endDate = startDate;
                    }
                    
                    if(caseObj.Origin == 'Proactive') {
                        originStr = 'Proactive';
                    }
                    else {
                        originStr = 'Reactive';
                    }
                    if(empIdToOpTargetLIMap.containsKey(caseObj.OwnerId)){
                        for(Operations_Target_Line_Item__c otli: empIdToOpTargetLIMap.get(caseObj.OwnerId)){
                            
                            if(otli.Start_Date__c <= startDate && otli.End_Date__c >= endDate && otli.Operations_Target__r.Case_Record_Type_Id__c == caseObj.RecordTypeId && otli.Operations_Target__r.Case_Origin__c == originStr){
                                caseObj.Operations_Target__c = otli.Id;
                                break;
                            }
                        }

                    }
                }
                    
            }
        }        
    }

    public static void completeMilestone(Object triggerParamObj){
    	
    	SS_TriggerCollectionParameters.CaseTriggerParams caseTriggerParam = (SS_TriggerCollectionParameters.CaseTriggerParams) triggerParamObj;
        
        if(!caseTriggerParam.originalCaseStatusClosedID.isEmpty()){
            CaseMilestoneUtils.completeMilestone(caseTriggerParam.originalCaseStatusClosedID, System.Now());
            if(!caseTriggerParam.originalCaseStatusClosedList.isEmpty()) {
                PeerReviewUtils.originalCaseStatusClosed(caseTriggerParam.originalCaseStatusClosedList);
            }
        }
        
        if(!caseTriggerParam.generateRevisionCaseID.isEmpty()){
            CaseMilestoneUtils.completeMilestone(caseTriggerParam.generateRevisionCaseID, System.Now());
                if(!caseTriggerParam.generateRevisionCaseList.isEmpty()){
                    PeerReviewUtils.generateRevisionCase(caseTriggerParam.generateRevisionCaseList);
                }
        }
        
        if(!caseTriggerParam.completeMilestoneID.isEmpty()){
            CaseMilestoneUtils.completeMilestone(caseTriggerParam.completeMilestoneID, System.Now());
        }        
    }
    
    public void addErrorToCase(Case newCase){
        //Error message on quote review case.
        if(newCase.RecordTypeId == ZS.Case_Review_Request_Record_Type_Id__c && newCase.Sub_Case_Type__c == 'Quote' 
                && (newCase.Status == 'Review Failed' || newCase.Status == 'Closed') && newCase.ParentId != null) {
            Map<String, Integer> reviewStatusCountMap = new Map<String, Integer>();
            reviewStatusCountMap = PeerReviewUtils.getQuoteReviewStatusCount(newCase.ParentId);
            if(reviewStatusCountMap.size() == 1) {
                if(newCase.Status == 'Closed' && reviewStatusCountMap.get('Pass') == null){
                    newCase.addError(ZS.QA_Error_Msg_Closed_with_Fail__c);
                }
                if(newCase.Status == 'Review Failed' && reviewStatusCountMap.get('Fail') == null){
                    newCase.addError(ZS.QA_Error_Msg_Failed_with_all_Pass__c);
                }
            }
            else {
                if(newCase.Status == 'Closed') {
                    newCase.addError(ZS.QA_Error_Msg_Closed_with_Fail__c);
                }
                if(newCase.Status == 'Review Failed' && (reviewStatusCountMap.get('null') != null || reviewStatusCountMap.get('In Review') != null)){
                    newCase.addError(ZS.QA_Error_Msg_Failed_with_In_Review__c);
                }
            }
        }
    }
    
    public void setClosedFlag(Case newCase,Case oldCase){
       
        if(ZF.Peer_Review__c && (newCase.RecordTypeId == ZS.Case_Booking_Request_Record_Type_Id__c || newCase.RecordTypeId == ZS.Case_Quote_Request_Record_Type_Id__c) 
                && newCase.Status == 'Ready' && newCase.Status != oldCase.Status && newCase.Original_Case_1P__c == null) {
            newCase.Ready_Status_Date_1P__c = System.Now();
            if(PeerReviewUtils.peerReviewPreCheck(newCase)){
                setCloseFlag = true;
            }else{
                setCloseFlag  = false;
            }
            mapOfCaseToCloseFlag.put(newCase.id,setCloseFlag);
        }
    }
    
    public static List<Opportunity> updateReviewRequestCase(List<Case> mOppToCaseList, Map<id,Opportunity> oppMap){
        map<Id, Schema.RecordTypeInfo> rt_map = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById();
        List<Opportunity> impactedOppList = new List<Opportunity>();
        for(Case mCase : mOppToCaseList){
            String recordTypeName = rt_map.get(mCase.recordTypeID).getName();
             if(recordTypeName.equalsIgnoreCase('Review Request')){
                if(mCase.status.equalsIgnoreCase('New')){
                    Opportunity opp =  oppMap.get(mCase.Opportunity__c);
                    opp.Ops_Stage__c = 'In Review';
                    impactedOppList.add(opp);
                } 
             }
        }   
        return impactedOppList;
    }
    
    public List<Opportunity> updateOpsStage(List<Case> caseList,Map<id,Opportunity> mapOfOpp,Map<Id,Id> caseToOppMap){
        set<ID> setop= new set<ID>();
        Map<Id,Opportunity> impactedOpps = new Map<Id,Opportunity>();
        map<Id, Schema.RecordTypeInfo> rt_map = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById();
        
        for(Case mCase : caseList){
            String recordTypeName = rt_map.get(mCase.recordTypeID).getName();
            if(mapOfCaseToCloseFlag != null){                
                if((mapOfCaseToCloseFlag.containsKey(mCase.id)?mapOfCaseToCloseFlag.get(mCase.id):false) && (recordTypeName.equalsIgnoreCase('Quote Request')||recordTypeName.equalsIgnoreCase('Booking Request')) 
                        && mCase.Status.equalsIgnoreCase('Ready')){
                    mCase.Status = 'Closed';
                }
            }
            if(mCase.Opportunity__c!=null && mCase.status!=null){
                Opportunity opp =  mapOfOpp.get(caseToOppMap.get(mCase.id));
                if(recordTypeName.equalsIgnoreCase('Booking Request')){
                    if(mCase.status.equalsIgnoreCase('Work In Progress')){
                        opp.Ops_Stage__c = 'In Progress';
                    }else if(mCase.status.equalsIgnoreCase('On Hold')){
                        opp.Ops_Stage__c = 'On Hold';
                    }else if(mCase.status.equalsIgnoreCase('Closed - Unsuccessfully')){
                        opp.Ops_Stage__c = 'PO Rejected';
                    }else if(mCase.status.equalsIgnoreCase('Closed')&& (mCase.Sub_Case_Type__c==null?true:!mCase.Sub_Case_Type__c.equalsIgnoreCase('Correction'))){
                        opp.Ops_Stage__c = 'PO Submitted';
                    }
                }
                if(recordTypeName.equalsIgnoreCase('Booking Request')||recordTypeName.equalsIgnoreCase('Quote Request')||
                    recordTypeName.equalsIgnoreCase('Data Update Request')){
                    if(mCase.Status.equalsIgnoreCase('New')){
                        if(String.isNotBlank(opp.Ops_Stage__c) && opp.Ops_Stage__c.equals('PO Rejected')){
                            opp.Ops_Stage__c = '';
                        }
                    }
                }
                
                if(recordTypeName.equalsIgnoreCase('Quote Request')){
                    if(mCase.status.equalsIgnoreCase('Work In Progress')
                        &&(mCase.Sub_Case_Type__c.equalsIgnoreCase('New')||mCase.Sub_Case_Type__c.equalsIgnoreCase('Revision'))){
                        opp.Ops_Stage__c = 'In Progress';
                    }else if(mCase.status.equalsIgnoreCase('On Hold')){
                        opp.Ops_Stage__c = 'On Hold';
                    }else if(mCase.status.equalsIgnoreCase('Closed - Unsuccessfully')){
                        opp.Ops_Stage__c = 'Unsuccessful';
                    }else if(mCase.status.equalsIgnoreCase('Closed')){
                        opp.Ops_Stage__c = 'Completed';
                        
                            if(opp.StageName!='Quote Completed'&&opp.StageName!='Quote Delivered'&&
                               opp.StageName!='Customer Commitment'&&opp.StageName!='PO Received'&&
                               opp.StageName!='No Service'&&opp.StageName!='House Account'&&
                               opp.StageName!='Closed Sale'&&opp.StageName!='Open-Consolidated'){
                                opp.StageName= 'Quote Completed';
                               }
                        
                    }else if(mCase.status.equalsIgnoreCase('New')){
                        if(opp.StageName!='Quote Request'&&opp.StageName!='In Review'&&
                               opp.StageName!='Customer Commitment'&&opp.StageName!='PO Received'&&
                               opp.StageName!='No Service'&&opp.StageName!='House Account'&&
                               opp.StageName!='Closed Sale' &&opp.StageName!='Open-Consolidated'&&
                               opp.StageName!='Quote Completed'&&opp.StageName!='Quote Delivered'){
                                opp.StageName= 'Quote Request';
                               }
                    }
                }
                if(recordTypeName.equalsIgnoreCase('Quote Request')||
                    recordTypeName.equalsIgnoreCase('Data Update Request')){
                    if(mCase.status.equalsIgnoreCase('New')){
                         if(String.isNotBlank(opp.Ops_Stage__c) && opp.Ops_Stage__c.equalsIgnoreCase('Unsuccessful')){
                            opp.Ops_Stage__c = '';
                        }
                    }       
                }
                if(recordTypeName.equalsIgnoreCase('Review Request')){
                    if(mCase.status.equalsIgnoreCase('New')){
                        opp.Ops_Stage__c = 'In Review';
                    }else if(mCase.status.equalsIgnoreCase('Ready')){
                        mCase.status = 'Closed';
                        opp.Ops_Stage__c = 'Completed';
                        if(mCase.parentId!=NULL){
                            setop.add(mCase.parentId);
                        }
                        if(mCase.Original_Case_1P__c!=NULL){
                            setop.add(mCase.Original_Case_1P__c);
                        }                        
                    }                    
                }                
                if(recordTypeName.equalsIgnoreCase('Quote Request')){
                    if(mCase.status.equalsIgnoreCase('New')&& (mCase.Sub_Case_Type__c!=null?mCase.Sub_Case_Type__c.equalsIgnoreCase('Correction'):false)){
                        opp.Ops_Stage__c = 'In Review';
                    }   
                }
                impactedOpps.put(opp.id,opp);                
            }
        }
        if(!setop.isEmpty() && setop.size()>0 ){
        	CSM_TriggerManager.disableAllTriggers();
            List<Case> pcase = new List<Case>();
            List<Case> casetoupdate = new List<Case>();
            pcase = CaseDataAccess.getCasesByWhereClause(setop, new List<String>{'Status'});
            for(case cs:pcase)
            {
                cs.status='Closed';
                casetoupdate.add(cs);
            }
            List<String> caseFields = new List<String> {'Status'};
            CaseDataAccess.updateCases(casetoupdate, caseFields);     
       }
        return impactedOpps.values();
    }
    
    //US1788
    public void caseValidationOnUsers(List<Case> caseLst,Map<ID, sObject> oldRecordsMap){
    	Case oldCase;
        Set<String> missingFields = new Set<String>();
        List<sObject> caseList = new List<sObject>();
        Map<Id,sObject> oldMap = new Map<Id,sObject>();
        Boolean SalesRep = PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_SalesRep);
        Boolean OperationServicesUser = PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_OperationServicesUser);
        Boolean SalesManager = PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_SalesManager);
        Boolean CanEditCases=PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_CanEditCases);
        Set<String> caseNonEditableFieldSet;
        
        if(CanEditCases) return;
        
        if(SalesRep || SalesManager){
            caseNonEditableFieldSet = new Set<String>{'AccountId', 'ContactId', 'OwnerId',Util.solnExtnNameSpace+'Opportunity__c','Status','Priority', 'Description','Subject'};
        }else{
            caseNonEditableFieldSet = new Set<String>();
        }
        PerformObjectFieldValidation performValidation = new PerformObjectFieldValidation(caseNonEditableFieldSet);
        for(Case newCase : caseLst) {
            oldCase = (case)oldRecordsMap.get(newCase.Id);
            if(SalesRep && newCase.Status!= 'Closed Automatically'){
                if(oldCase.isClosed != true){
                        caseList.add(newCase);
                }else{//Added for DE2381 and US2372
                    newCase.addError(System.Label.CANNOT_MODIFY_CASE_SALES_REP);
                }
            }   
            else if( OperationServicesUser && oldCase.isClosed == true ){
                    newCase.addError(System.Label.CANNOT_MODIFY_CASE_OPS_REP);
            }
            else if( !(newCase.Status != oldCase.Status && (newCase.Status== 'Closed Automatically'|| newCase.Status=='Escalated'))//Ignore Internal updates
                && !(newCase.OwnerId != oldCase.OwnerId && newCase.HA_NS_Approval_Status__c != oldCase.HA_NS_Approval_Status__c )//Ignore Internal updates
                && SalesManager && !CaseTriggerHandler.isInsertRequest){
                    caseList.add(newCase);
            }
        }// for case loop
        if(caseList.size()>0){
            performValidation.checkForValidUpdate(caseList, (Map<ID, Case>) oldRecordsMap);
        }
    }   
}