public with sharing class OpportunityUtils{
     
    public static void updateCaseClosedAutomatically(Object triggerParamObj){
     	Zenith_Features__c ZF = Zenith_Features__c.getOrgDefaults();
    	//ToDo: Add  below as its base package class
    	SS_TriggerCollectionParameters.OpportunityTriggerParams opptyTriggerParam = (SS_TriggerCollectionParameters.OpportunityTriggerParams) triggerParamObj;
    	List<BusinessHours> businessHoursList = BusinessHoursDataAccess.getBusinessHoursListByDefault(true);
        BusinessHours bh = businessHoursList != null && !businessHoursList.isEmpty() ? businessHoursList[0] : null;
    	if(ZF.Auto_Close_Case__c && opptyTriggerParam.qualifiedIdSet != null && !opptyTriggerParam.qualifiedIdSet.isEmpty()) {
 	    	set<boolean> setFlag = new set<boolean>();
 	    	setFlag.add(false);
	        List<Case> caseListNotClosed = CaseDataAccess.getCasesByOpportintyAndClosed(opptyTriggerParam.qualifiedIdSet, setFlag);
	        //List<Case> caseListNotClosed = CaseDataAccess.getCasesByOpportintyAndClosed(new Set<String>(oppList), setFlag);
 	        List<String> caseFieldList = new List<String>{'Status','Origin',Util.solnExtnNameSpace+'Total_Resolved_Business_Hour_min__c'};
 	        if (!caseListNotClosed.isEmpty())
 	        {
 		        for(Case caseObj : caseListNotClosed){
 		        	if(caseObj.Status != 'Closed Automatically') {
 		            	caseObj.Status = 'Closed Automatically';
 		            	if(ZF.Populate_Total_Resolved_Business_Hour__c && bh != null) {
 		            		caseObj.Total_Resolved_Business_Hour_min__c = Util.defaultDifferentInMin(bh.Id, caseObj.CreatedDate, System.Now()); 
 		            	}
 		            	if(caseObj.Operations_Target__c == null) {
 		            		relateOpTargetLItoCase(new List<Case>{caseObj});
 		            	}
 		        	}
 		        }
 		        CaseDataAccess.updateCases(caseListNotClosed,caseFieldList);
 	        }
     	}
     }
     
     private static void relateOpTargetLItoCase(List<case> newCase){
        Date cDate;
        String cOrigin;
        if(newCase[0].ClosedDate != null){
            cDate = Date.newInstance(newCase[0].ClosedDate.year(), newCase[0].ClosedDate.month(), newCase[0].ClosedDate.day());
        }
        else {
            cDate = Date.newInstance(System.Now().year(), System.Now().month(), System.Now().day());
        }
        
        if(newCase[0].Origin == 'Proactive') {
            cOrigin = 'Proactive';
        }
        else {
            cOrigin = 'Reactive';
        }
        
        List<Operations_Target_Line_Item__c> ot = OperationsTargetDataAccess.getOperationLineItems(cDate, cDate, 
            newCase[0].RecordTypeId, cOrigin, newCase[0].OwnerId);
        newCase[0].Operations_Target__c = (ot.size() != 0) ? ot[0].Id : null;
    } 
 }