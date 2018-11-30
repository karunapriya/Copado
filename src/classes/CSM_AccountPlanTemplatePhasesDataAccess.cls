/**
* @author         Mike Faust (mike@comitydesigns.com)
* @date           07.31.2014
* @description    CSM_AccountPlanTemplatePhasesDataAccess class performs Data Access for  Acount Plan Phase object
*/

public with sharing class CSM_AccountPlanTemplatePhasesDataAccess {


	/**
	 *@description returns a list of Success Plan phases related to the Success Plan template 
     */
	public static List<CSM_Account_Plan_Phase__c> populateAccountTemplatePhases(String accountPlanTemplateId)
	{
		List<CSM_Account_Plan_Phase__c> accountPlanPhaseList = new List<CSM_Account_Plan_Phase__c>();
		List<String> fcFieldList = new List<String>{CSM_CONSTANTS.OBJ_APPH_ID, CSM_CONSTANTS.OBJ_APPH_NAME, CSM_Constants.OBJ_APPH_PHASE_NAME,
			CSM_Constants.OBJ_APPH_LENGTH, CSM_Constants.OBJ_APPH_TEMPLATE, CSM_Constants.OBJ_APPH_ORDER };
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APPH,
																										CSM_Constants.DML_OPERATION_READ, fcFieldList);
    	//If user has access to fields, query the Success Plan Phase
    	if (noAccessList.isEmpty())
    	{
			if(accountPlanTemplateId != null)
			{
				accountPlanPhaseList = [select id, 
											   Name, 
											   CSM_Phase_Name__c, 
											   CSM_Length__c, 
											   CSM_Account_Plan_Template__c, 
											   CSM_Order__c
						 				  from CSM_Account_Plan_Phase__c 
						 				 where CSM_Account_Plan_Template__c = :accountPlanTemplateId
						 			  order by CSM_Order__c limit 100];
			}
		}
		//User does not have access to all the fields
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APPH + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException(String.format(
    		 		System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
    	    
    	}
    	return accountPlanPhaseList;
	}
	
		
	/**
	 *@description updates a list of Success Plan phases 
     */
	public static boolean updatePhases(List<CSM_Account_Plan_Phase__c> accountPlanPhasesList) 
	{
		boolean isValid = true;
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APPH_PHASE_NAME,CSM_Constants.OBJ_APPH_LENGTH, CSM_Constants.OBJ_APPH_ORDER };
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APPH,
																										CSM_Constants.DML_OPERATION_UPSERT, fcFieldList);
    	//If user has access to fields, update the Success Plan Phases
    	if (noAccessList.isEmpty())
    	{
				if(!accountPlanPhasesList.isEmpty())
    			{
    				for (CSM_Account_Plan_Phase__c pp : accountPlanPhasesList)
					{
						if(pp.CSM_Length__c == null || pp.CSM_Length__c <=0)
						{
							pp.CSM_Length__c.addError(Label.CSM_MSG_PHASE_LENGTH_GREATER_ZERO);
							isValid = false;
						}
						if(pp.CSM_Order__c == null || pp.CSM_Order__c <=0)
						{
							pp.CSM_Order__c.addError(Label.CSM_MSG_PHASE_ORDER_GREATER_ZERO);
							isValid = false;
						}
						if(pp.CSM_Phase_Name__c == null)
						{
							pp.CSM_Phase_Name__c.addError(Label.CSM_MSG_PHASE_NAME_POPULATED);
							isValid = false;
						}
					}
					if(isValid)
					{
						upsert accountPlanPhasesList;
						//Insert was successful, return true
						return true;
					}
    			}
		}
		//User does not have access to all the fields
		else {
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APPH + ':'+String.valueOf(noAccessList)};
			throw new CSM_AccessController.AccessControlDmlException( String.format(
		        System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments)); 
			    	    
    	}
    	//Insert was unsuccessful, return false
    	return false;
    	
	}
	/**
	 *@description deletes a list of Success Plan phases 
     */
	public static boolean deletePhases(List<String> phaseList) 
	{
		
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APPH,CSM_Constants.DML_OPERATION_DELETE, null);
    	//If user cannot delete an exception will be thrown.  No need to check if noAccessList is empty.
    	
		if(!phaseList.isEmpty())
		{
			List<CSM_Account_Plan_Phase__c> accountPlanPhasesToDelete = [select id from CSM_Account_Plan_Phase__c where id in :phaseList limit 50];
			delete accountPlanPhasesToDelete;	
			//Delete was successful, return true
			return true;
		}			
		
    	//Delete was unsuccessful, return false
    	return false;
	}
	
	public static void cloneAccountPlanTemplatePhase(Map<Id, Id> currentToCloneTemplateIdMap){
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APPH_LENGTH,
			  CSM_Constants.OBJ_APPH_ORDER, CSM_Constants.OBJ_APPH_PHASE_NAME,CSM_Constants.OBJ_APPH_TEMPLATE};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APPH,
		    CSM_Constants.DML_OPERATION_READ, fcFieldList);
    	//If user has access to fields, update the Success Plan Phases
    	if (noAccessList.isEmpty())
    	{
    		List<CSM_Account_Plan_Phase__c> clonePhaseList = new List<CSM_Account_Plan_Phase__c>();
		    List<CSM_Account_Plan_Phase__c> apPhaseList = [Select CSM_Length__c, CSM_Order__c, CSM_Phase_Name__c,
		                                                      CSM_Account_Plan_Template__c
															From CSM_Account_Plan_Phase__c 
															Where CSM_Account_Plan_Template__c IN:currentToCloneTemplateIdMap.keySet() LIMIT 1000];
			if(!apPhaseList.isEmpty()){
				for(CSM_Account_Plan_Phase__c apPhase : apPhaseList){
					CSM_Account_Plan_Phase__c clonePhase = apPhase.clone(false, true);
					clonePhase.CSM_Account_Plan_Template__c = currentToCloneTemplateIdMap.get(apPhase.CSM_Account_Plan_Template__c);
					clonePhaseList.add(clonePhase);
				}
				updatePhases(clonePhaseList);
			}
    	}
		else
		{
			String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APPH + ':'+String.valueOf(noAccessList)};
			throw new CSM_AccessController.AccessControlDmlException( String.format(
		        System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments)); 
			    	    
		}
	}
	
}