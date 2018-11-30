/**
 * @author    	 Chandra Prakash (Chandra@comitydesigns.com)    
 * @date         03/05/2015
 * @description  REN_ContractLineItemTriggerHandler trigger handler for REN_ContractLineItemTrigger
 */
public with sharing class REN_ContractLineItemTriggerHandler extends CSM_TriggerManager.TriggerHandler{
	
	public override void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap)
	{
 		try
 		{
			//IF Renew license exists for user, proceed with the call 
			Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
			
					
			//US193: Insert Opportunities Line items when Service Contract's line items get Changed
			//DE235 - Remove the User Story US209
			if(hasRenewAccess && CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT))
			{
				REN_ContractLineItemRenewalLogicHandler.handleContractLineItemCreation(newRecords, newRecordsMap);
			}
 		}
 		catch(exception ex){
 			REN_Util.setErrorInObjects (newRecords, ex);
	 	}
 	}

	public override void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap){
 		try{
		 	//IF Renew license exists for user, proceed with the call 
	        Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
			if(hasRenewAccess && CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
		 		//US193: Update Opportunities Line items when Service Contract's line items get Changed
		 		REN_ContractLineItemRenewalLogicHandler.handleContractLineItemUpdate(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
		 		REN_ContractLineItemRenewalLogicHandler.rollupContractLine(oldRecordsMap, newRecordsMap);
		 	}
 		}catch(exception ex){
 			REN_Util.setErrorInObjects (newRecords, ex);
	 	}
 	}

	
	public override void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {
 		system.debug(Logginglevel.ERROR, '\n\n~~~~ onBeforeDelete:' + oldRecordsMap);
 		try{
		 	//IF Renew license exists for user, proceed with the call 
	        Boolean hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
		 		
			if(hasRenewAccess && CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
		 		//US193: Update Opportunities Line items when Service Contract's line items get Changed
		 		REN_ContractLineItemRenewalLogicHandler.handleContractLineItemDeletion(oldRecords, oldRecordsMap);
		 	}
 		}catch(exception ex){
 			REN_Util.setErrorInObjects (oldRecords, ex);
	 	}
 	}
 	
}