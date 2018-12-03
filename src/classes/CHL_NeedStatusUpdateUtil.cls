public with sharing class CHL_NeedStatusUpdateUtil {

    public static void updateStatusFlag(Map<Id, SObject> newRecordsMap, Map<Id, SObject> oldRecordsMap) {
        List<CHL_Opportunity_Status_Log__c> channelOpptyStatusLogList =  CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
        Set<String> availableStages = CHL_Util.getAvailableSalesStage(); 
 		Boolean hasCommunityAccess = (SS_LicenseCheck.getInstance().isChannelEnabled && SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ChannelCommunity)); 
 				
        string monitorFieldValues = '';
        boolean isUnavailableStage;
        if(channelOpptyStatusLogList != null && !channelOpptyStatusLogList.isEmpty())   {
            monitorFieldValues = channelOpptyStatusLogList[0].CHL_Field_API_Names__c; 
            isUnavailableStage = channelOpptyStatusLogList[0].CHL_Show_Oppty_for_Unavailable_Stage__c;
        }           
        
        Set<String> monitorFieldSet = new Set<String>();
        if(monitorFieldValues<>'' && !string.isblank(monitorFieldValues) && monitorFieldValues !=null) {
          monitorFieldSet.addAll(monitorFieldValues.split(';'));   
        }
        system.debug('monitorFieldSet : '+monitorFieldSet);
        
        Map<String, CHL_Partner_Opportunity__c> mapAllPartnerOpportunityNew = new Map<String, CHL_Partner_Opportunity__c>(); 
        Map<String, CHL_Partner_Opportunity__c> mapAllPartnerOpportunityOld = new Map<String, CHL_Partner_Opportunity__c>();
        
        if(oldRecordsMap != null && !oldRecordsMap.isEmpty())
        {
            for(Id i :oldRecordsMap.keySet())
            {
                mapAllPartnerOpportunityOld.put(String.valueOf(i), (CHL_Partner_Opportunity__c)(oldRecordsMap.get(i)));
            }
        }
        if(newRecordsMap != null && !newRecordsMap.isEmpty())
        {
            for(Id i :newRecordsMap.keySet())
            {
                mapAllPartnerOpportunityNew.put(String.valueOf(i), (CHL_Partner_Opportunity__c)(newRecordsMap.get(i)));
            }
        }
        
        List<CHL_Partner_Opportunity__c> lstOldNNew = new List<CHL_Partner_Opportunity__c>();
        for(CHL_Partner_Opportunity__c newRP :mapAllPartnerOpportunityNew.values())
        {
            lstOldNNew.clear();
            lstOldNNew.add(newRP);
            lstOldNNew.add(mapAllPartnerOpportunityOld.get(newRP.Id));
            if(hasChanged(lstOldNNew, monitorFieldSet)){
                system.debug('@@CHANGED STATUS ');
                newRP.CHL_Last_Status_Update_Date__c = Date.valueof(system.now());
                newRP.CHL_Needs_Status_Update__c = false;
            }
            if(isUnavailableStage == true && hasCommunityAccess == true && hasUnavailableStage(lstOldNNew,availableStages)) {
            	newRP.CHL_Sales_Stage__c.addError(Label.CHL_ERR_UNAVAILABLE_STAGE_UPDATE);
            }
        }           
    }
    public static Boolean hasChanged(List<sObject> lstOldNNew, set<String> allMonitoredFldsSet)
    {
        sObject newRR = lstOldNNew[0];
        sObject oldRR = lstOldNNew[1];
        Boolean isChanged = false;
         
        for(String fld :allMonitoredFldsSet)
        {    
            if(oldRR.get(fld) != newRR.get(fld))
            {
                isChanged = true;
                break;
            }
        }
        return isChanged;
    }
    
    public static Boolean hasUnavailableStage(List<sObject> lstOldNNew, set<String> avlblStages) {
    	sObject oldRR = lstOldNNew[1];
    	String previousSalesStage = (string)oldRR.get(CSM_Util.getNamespace()+'CHL_Sales_Stage__c');
    	system.debug('@@Stages: '+previousSalesStage);
    	if(avlblStages.contains(previousSalesStage)) { //previousSalesStage != currentSalesStage && 
    		return false;
    	} else {
    		return true;
    	}
    }
}