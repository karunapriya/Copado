/**
 * Created Date		: Jan 9, 2017
 * Developed By		: prashant, Comity Designs, Inc.
 *
 * Function			: @description - Class have helper method which triggered by while updating docusign status object field .
 * Support Email 	:  prashant@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * prashant					US1961				Jan 9, 2017			1.1					@description
 * Tanvi										July 18, 2017							Fixed the Production issue and remove unnecessary code
 * 
 */
public with sharing class REN_DocuSignStatusTriggerHelper {

     
    
     /**
	 * @description :This method needs to update opportunity and create case ,And used it for docusign trigger.
     * @param paramName :Docusign status objectList and map.
     * @return return list of opportunity.
     */
	// MARK: Your method goes here
	public static List<opportunity> updateOpportunityAndCreateCase(Map<ID, sObject> newRecordsMap, Map<ID, sObject> oldRecordsMap){
		//TS:Below code is commented now, as it is handle from REN_LowTouchOpportunities for all Buy Now Flows.
		/*String PO_RECEIVED ='PO Received';
        String COMMIT_LEVEL_YELLOW = 'Yellow';
		List<String> oppIdLst = new List<String>();
		sObject oldStatusObj;		
		String seEamespace = CSM_Util.nameSpacePrefixSolnExtn;
		for(sObject obj : newRecordsMap.values()){
			if(oldRecordsMap !=null) {
				oldStatusObj = oldRecordsMap.get(obj.Id);
			}
			String oldStatus = oldStatusObj != null ? (String)oldStatusObj.get('dsfs__Envelope_Status__c'):'';
			String newStatus = (String)obj.get('dsfs__Envelope_Status__c');
			if(oldStatus != newStatus && oldStatus != 'Completed' && newStatus == 'Completed'){
				oppIdLst.add((String)obj.get('dsfs__Opportunity__c'));
			}
		}
		if(oppIdLst != null){
			List<Opportunity> oppList= REN_OpportunityDataAccess.getOpportunityDetailByIdWithSyncQuote(oppIdLst);
			Savepoint sp = Database.setSavepoint();
			try {
				for(Opportunity oppObj: oppList){
					oppObj.put('StageName', PO_RECEIVED);
	          	  	oppObj.REN_Notify_Opportunity_Owner__c  = true;
	          	  	oppObj.REN_LT_Renewal_Details__c = system.Label.REN_SIGN_VIA_DOCUSIGN;          	  	
			  	  	OpportunityStage oppStage = REN_OpportunityDataAccess.getProbabilityValueByStage(PO_RECEIVED);
			  	  	oppObj.Probability = oppStage.DefaultProbability;
					if(CSM_AccessController.hasField('Opportunity', seEamespace+'Commit_Level__c')) {
						oppObj.put(seEamespace+'Commit_Level__c', COMMIT_LEVEL_YELLOW);
					}
		       		
				}
				REN_OpportunityDataAccess.updateOpportunityforRenewals(oppList);
				CSM_CaseDataAccess.createBookingRequest(oppList[0].id);
				return oppList;
			}
			catch(exception ex) {
				Database.rollback(sp);
				REN_LowTouchUtil.updateErrorLog(System.label.REN_LBL_DOCUSIGN, ex.getMessage() , oppList[0].id);
				return null;
			}
		}*/
		return null;
	}
}