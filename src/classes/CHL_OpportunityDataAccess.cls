public with sharing class CHL_OpportunityDataAccess {
	
	public static List<Opportunity> getOpportunityDetailById(List<String> opptIds)	{
		List<String> allAccessibleFieldsList = REN_OpportunityDataAccess.getAccessibleFields();
		Set<String> accessibleFieldsSet =  new Set<String>();
		accessibleFieldsSet.addAll(allAccessibleFieldsList);		  	
		accessibleFieldsSet.remove(CHL_Constants.OBJ_OPP_SYNCE_QUOTE_ID); // To remove syncedquoteid and SyncedQuote.Name field from opp accessible field List
		accessibleFieldsSet.remove(CHL_Constants.OBJ_OPP_SYNCE_QUOTE_NAME);	  	
		allAccessibleFieldsList.clear();
		allAccessibleFieldsList.addAll(accessibleFieldsSet);
		CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_OPPORTUNITY, new List<String>{'Name'}, CSM_Constants.DML_OPERATION_READ); 
		String soqlStr = REN_OpportunityDataAccess.joinList(allAccessibleFieldsList, ', ',CSM_Util.getNamespace());	  		    
   		String queryString =  'SELECT ' + soqlStr + 
                                ' FROM Opportunity' + 
                                ' WHERE Id IN:opptIds Order By Name';
		return Database.query(queryString);
	}
	
	public static void updateOpportunityList(List<Opportunity> opportunityList){        
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_OPPORTUNITY, new List<String>{'Name'}, CSM_Constants.DML_OPERATION_UPDATE);                        
        update opportunityList;                 
    }

}