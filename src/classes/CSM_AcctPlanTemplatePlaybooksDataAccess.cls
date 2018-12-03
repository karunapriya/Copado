/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		08.05.2014
 * @description	CSM_AcctPlanTemplatePlaybooksDataAccess class used to provide template data access method
 */

public with sharing class CSM_AcctPlanTemplatePlaybooksDataAccess {
	
	/** 
	 * @description returns the playbooks for a given Success Plan Template
	 */
	public static List<CSM_Account_Plan_Playbook__c> populateAccountTemplatePlaybooks(String accountPlanTemplateId)
	{
		List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList1 = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> noAccessList1 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, fcFieldList1);
		List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_READ, fcFieldList2);
    	//If user has access to fields, query the Success Plan Phase
    	if (noAccessList1.isEmpty() && noAccessList2.isEmpty())
    	{
			if(accountPlanTemplateId != null)
			{
				accountPlanPlaybookList = [select id, 
												  CSM_isActive__c, 
												  CSM_Account_Plan_Template__c, 
												  CSM_Playbook__c,
												  CSM_Playbook__r.CSM_Display_Name__c, 
												  CSM_Playbook__r.CSM_isActive__c
											 from CSM_Account_Plan_Playbook__c 
											where CSM_Account_Plan_Template__c = :accountPlanTemplateId
											and CSM_Account_Plan__c = null limit 1000];
			}
		}
		//User does not have access to all the fields
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APP + ':'+String.valueOf(noAccessList1)};
    		String[] arguments2 = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList2)};
    		arguments.addAll(arguments2);
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
			System.Label.CSM_MSG_OBJECT_NOT_READABLE, arguments)); 
    	    
    	}
    	return accountPlanPlaybookList;
	}
	
	/** 
	 * @description return boolean stating whether the user has access to create new playbook
	 */
	public static boolean createPlaybookAvailable() {
		List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
		//Check that user has access to Success Plan playbook and insert playbook
		List<String> fcFieldList1 = new List<String>{CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> noAccessList1 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, fcFieldList1);
		List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE, CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_SHORT_DESC, 
									CSM_Constants.OBJ_PLAYBOOK_LONG_DESC /*, CSM_Constants.OBJ_PLAYBOOK_PLAY_TOTAL*/};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_INSERT, fcFieldList2);
		if (noAccessList1.isEmpty() && noAccessList2.isEmpty())
    	{
			return true;
		}
		//User does not have access to all the fields
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APP + ':'+String.valueOf(noAccessList1)};
    		String[] arguments2 = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList2)};
    		arguments.addAll(arguments2);
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
			System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE, arguments));
    	    
    	}
		return false;					
	}
	
	/** 
	 * @description returns if the playbook is editable
	 */
	public static boolean updatePlaybookAvailable() {
		
		List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
		//Check that user has access to Success Plan playbook and update playbook
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_DISPLAY_NAME, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE, CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_SHORT_DESC, 
									CSM_Constants.OBJ_PLAYBOOK_LONG_DESC /*, CSM_Constants.OBJ_PLAYBOOK_PLAY_TOTAL*/};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_UPDATE, fcFieldList);
			
		if (noAccessList.isEmpty())
    	{
			return true;
		}
		//User does not have access to all the fields
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
			System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments));
    	}	
		return false;
	}
	
	/** 
	 * @description returns if the user can add a playbook to Success Plan playbook
	 */
	public static boolean addPlaybookAvailable() {
		
		//Checks to see if the user has access to add record to 
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_INSERT, fcFieldList);
    	//If user has access to fields, query the Success Plan Phase
    	if (noAccessList.isEmpty())
    	{
			return true;
		}
		//User does not have access to all the fields
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
			System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments));	
    	}
		return false;
	}
	
	
	
	/** 
	 * @description save the list of Success Plan playbook entries
	 */
	public static boolean saveTemplatePlaybooks(List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList) 
	{
		
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,
		    CSM_Constants.DML_OPERATION_UPSERT, fcFieldList);
    	//If user has access to fields, query the Success Plan Phase
    	if (noAccessList.isEmpty())
    	{
    		upsert accountPlanPlaybookList;
    	}
    	else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments));	
    	   
    	}	
		return false;
	}
	
	
	/** 
	 * @description Returns active Success Plan playbook entries for automated playbooks that are active
	 * @return List<CSM_Account_Plan_Playbook__c>
	 */ 
	public static List<CSM_Account_Plan_Playbook__c> getNonAutomatedAccountPlanPlaybooks(List<CSM_Account_Plan__c> accountPlanList)
	{
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, fcFieldList);
		List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_READ, fcFieldList2);
		system.debug('noAccessList : ' + noAccessList + '..... ' + ' noAccessList2 : ' + noAccessList2 );
		Set<Id> accountPlanIds = new Set<Id>();
		Set<Id> accountPlanTemplateIds = new Set<Id>();
		for(CSM_Account_Plan__c aPlan : accountPlanList){
			accountPlanIds.add(aPlan.Id);
			accountPlanTemplateIds.add(aPlan.CSM_Account_Plan_Template__c);
		}
		system.debug('accountPlanIds - ' + accountPlanIds + 'accountPlanTemplateIds - ' + accountPlanTemplateIds);
		if(noAccessList.isEmpty() && noAccessList2.isEmpty())
		{
			tmpList = [select id, 
							  CSM_Playbook__c, 
							  CSM_isActive__c, 
							  CSM_Account_Plan__c,
							  CSM_Account_Plan__r.CSM_AccountId__c,
							  CSM_Account_Plan_Template__c
						 from CSM_Account_Plan_Playbook__c
						//where (CSM_Account_Plan__c IN :accountPlanIds OR CSM_Account_Plan_Template__c IN :accountPlanTemplateIds)
						where CSM_Account_Plan__c IN :accountPlanIds
						  and CSM_Playbook__r.CSM_Automated__c = false
						  and CSM_Playbook__r.CSM_isActive__c = true
						  and CSM_isActive__c = true
						  and CSM_ByPass_Criteria__c != true
						//limit 1000];
						limit 2500];
		}
		else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APP + ':'+String.valueOf(noAccessList)};
    		String[] arguments2 = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList2)};
    		arguments.addAll(arguments2);
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_READABLE, arguments));	
    	    
    	}
		return tmpList;
	}
	
	/** 
	 * @description Returns active Success Plan playbook entries for automated playbooks that are active
	 * @return List<CSM_Account_Plan_Playbook__c>
	 */ 
/*	public static List<CSM_Account_Plan_Playbook__c> getNonAutomatedAccountPlanPlaybooks(Set<Id> opportunityPlanIds)
	{
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, fcFieldList);
		List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_READ, fcFieldList2);
		system.debug('noAccessList : ' + noAccessList + '..... ' + ' noAccessList2 : ' + noAccessList2 );
		//Eswar Bala
		List<REN_Opportunity_Plan__c> lstOpportunityPlans = [Select Id, REN_Template__c From REN_Opportunity_Plan__c Where Id IN :opportunityPlanIds];
		Set<Id> accountPlanTemplateIds = new Set<Id>();
		if(lstOpportunityPlans != null)
		{
			for(REN_Opportunity_Plan__c op :lstOpportunityPlans)
			{
				if(op.REN_Template__c != null)
				{
					accountPlanTemplateIds.add(op.REN_Template__c);
				}
			}
		}
		
		if(noAccessList.isEmpty() && noAccessList2.isEmpty())
		{
			tmpList = [select id, 
							  CSM_Playbook__c, 
							  CSM_isActive__c, 
							  CSM_Account_Plan__c, 
							  CSM_Account_Plan_Template__c
						 from CSM_Account_Plan_Playbook__c
						where (REN_Oppty_Success_Plan__c IN :opportunityPlanIds OR CSM_Account_Plan_Template__c IN :accountPlanTemplateIds) 
						  and CSM_Playbook__r.CSM_Automated__c = false
						  and CSM_Playbook__r.CSM_isActive__c = true
						  and CSM_isActive__c = true
						limit 5000];
		}
		else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APP + ':'+String.valueOf(noAccessList)};
    		String[] arguments2 = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList2)};
    		arguments.addAll(arguments2);
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_READABLE, arguments));	
    	    
    	}
		return tmpList;
	}*/
	
	public static void cloneAccountPlanPlayBooks(Map<Id, Id> currentToCloneTemplateIdMap){
		List<String> appFieldList = new List<String>{CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK,
		    CSM_Constants.OBJ_APP_ACCT_PLAN, CSM_Constants.OBJ_APP_ACCT_TEMPLATE};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		    CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, appFieldList);
		
		List<String> pFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED};
		List<String> noAccessPlayList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		    CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_READ, pFieldList);
		
		List<CSM_Account_Plan_Playbook__c> clonePlaybookList = new List<CSM_Account_Plan_Playbook__c>();
		
		if (noAccessList.isEmpty() && noAccessPlayList.isEmpty())
		{
			List<CSM_Account_Plan_Playbook__c> apPlaybookList = [Select CSM_IsActive__c, CSM_Playbook__c, CSM_Account_Plan__c, 
															CSM_Account_Plan_Template__c, CSM_Playbook__r.CSM_Automated__c  
															From CSM_Account_Plan_Playbook__c 
															Where CSM_Account_Plan_Template__c IN:currentToCloneTemplateIdMap.keySet() and CSM_Account_Plan__c = null limit 1000];
			if(!apPlaybookList.isEmpty()){
	    		for(CSM_Account_Plan_Playbook__c apPlaybook : apPlaybookList){
	    			if(apPlaybook != null && !apPlaybook.CSM_Playbook__r.CSM_Automated__c){
						CSM_Account_Plan_Playbook__c clonePlaybook = apPlaybook.clone(false, true);
	    				clonePlaybook.CSM_Account_Plan_Template__c = currentToCloneTemplateIdMap.get(apPlaybook.CSM_Account_Plan_Template__c);
	    				clonePlaybookList.add(clonePlaybook);
	    			}
	    		}
	    		saveTemplatePlaybooks(clonePlaybookList);
			}
		}
		else 
		{
			String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APP + ':'+String.valueOf(noAccessList) 
				+' ' + CSM_CONSTANTS.OBJ_PLAYBOOK + ':' + String.valueof(noAccessPlayList)};
			throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_READABLE, arguments));	
		}
	}
	
	/** 
	 * @description Returns Success Plan playbook for given playbooks and acctPlanTemplate association
	 */ 
	public static List<CSM_Account_Plan_Playbook__c> getAcctPlanPlaybooksByPlaybookIdAndTemplateId(String removeAccountPlanPlaybookId)
	{
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, fcFieldList);
		List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
		List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_READ, fcFieldList2);
		
		if(noAccessList.isEmpty() && noAccessList2.isEmpty())
		{
			tmpList = [select id, 
							  CSM_Playbook__c,  
							  CSM_Account_Plan__c, 
							  CSM_Account_Plan_Template__c
						 from CSM_Account_Plan_Playbook__c
						where Id = :removeAccountPlanPlaybookId 
						limit 5000];
		}
		else 
    	{
    		String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APP + ':'+String.valueOf(noAccessList)};
    		String[] arguments2 = new String[] {CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noAccessList2)};
    		arguments.addAll(arguments2);
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_READABLE, arguments));	
    	    
    	}
		return tmpList;
	}
	
	/** 
	 * @description remove the success plan playbook associatedt o success plan template
	 */
	public static void deleteTemplatePlaybook(List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList) 
	{

	}
	
	public static boolean deleteAcctPlanTemplatePlaybook(List<CSM_Account_Plan_Playbook__c> accountPlanPlaybookList) 
	{
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,
		    CSM_Constants.DML_OPERATION_DELETE, null);
	
		delete accountPlanPlaybookList;
		return true;
    	
	}
}