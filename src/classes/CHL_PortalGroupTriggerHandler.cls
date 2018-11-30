public with sharing class CHL_PortalGroupTriggerHandler extends CSM_TriggerManager.TriggerHandler {
    public override void onBeforeUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap)	{
 		try	{
	 		Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;	
	 		if(hasChannelAccess == true) {
	 			Set<String> portalGrpNames = new Set<String>();
		 		for(sObject newObj : newRecords) {
			    	if(newObj.get('Name') != oldRecordsMap.get(newObj.id).get('Name')) {
				      	/*Boolean uniqueName = CHL_PortalGroupDataAccess.findPoralGroupByName(String.valueOf(newObj.get('Name')));
			 			if(uniqueName) {
			 				newObj.addError(System.label.PORTAL_GROUP_DUPLI_NAME_MSG);
			 			}*/
			 			portalGrpNames.add(String.valueOf(newObj.get('Name')));
			      	}
			    }	
			    Set<String> portalGrps = CHL_PortalGroupDataAccess.getPortalGroupName(portalGrpNames);
	 			for(sObject newPGObj : newRecords) {
 					if(newPGObj.get('Name') != oldRecordsMap.get(newPGObj.id).get('Name') && isUnique(newPGObj,portalGrps)) {
 						newPGObj.addError(System.label.PORTAL_GROUP_DUPLI_NAME_MSG);
 					}
 				}
			}
 		} catch(exception ex){
	 		REN_Util.setErrorInObjects (newRecords, ex); 
	 	}
 	}
 	
 	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {
 		try {
	 	    Boolean hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;	
	 		Set<String> portalGrpNames = new Set<String>();
	 		if(hasChannelAccess == true) {
	 			for(sObject newObj : newRecords) {
	 				portalGrpNames.add(String.valueOf(newObj.get('Name')));
	 				/*Boolean uniqueName = CHL_PortalGroupDataAccess.findPoralGroupByName(String.valueOf(newObj.get('Name')));
		 			if(uniqueName) {
		 				newObj.addError(System.label.PORTAL_GROUP_DUPLI_NAME_MSG);
		 			}*/
	 			}
	 			Set<String> portalGrps = CHL_PortalGroupDataAccess.getPortalGroupName(portalGrpNames);
	 			for(sObject newPGObj : newRecords) {
 					if(isUnique(newPGObj,portalGrps)) {
 						newPGObj.addError(System.label.PORTAL_GROUP_DUPLI_NAME_MSG);
 					}
 				}
	 		}
 			
 		} catch(exception ex) {
 			REN_Util.setErrorInObjects (newRecords, ex); 
 		}
 	}
 	
 	private static Boolean isUnique(sObject newPGRecord, set<String> portalGrpNames)
    {
    	Boolean isNameUnique = false;         
        for(String fldName :portalGrpNames)
        {    
            if(String.valueOf(newPGRecord.get('Name')) == fldName)
            {
                isNameUnique = true;
                break;
            }
        }
        return isNameUnique;
    }
}