public with sharing class CSM_AccountPlanPlaybookDataAccess {

	static String namespace = CSM_Util.getNameSpace();		
	public static List<CSM_Account_Plan_Playbook__c> getAutomatedAccountPlanPlaybooks(Set<String> accountIdSet, 
																				Map<Id, CSM_Play_Result__c> playResultsMap, 
																				List<CSM_Account_Plan__c> accountPlanIds){
		
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> fcPlabybookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
			
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, fcFieldList);
		List<String> noPlaybookAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_READ, fcPlabybookFieldList);

		if(noAccessList.isEmpty() && noPlaybookAccessList.isEmpty()){
			tmpList = [SELECT Id, 
							  CSM_Playbook__c, 
							  CSM_isActive__c, 
							  CSM_Account_Plan__c,
							  CSM_Account_Plan__r.CSM_AccountId__c
						FROM 
						 	CSM_Account_Plan_Playbook__c
						WHERE 
							CSM_Account_Plan__c in :accountPlanIds
						  AND CSM_Playbook__r.CSM_Automated__c = true
						  AND CSM_Playbook__r.CSM_isActive__c = true
						  AND CSM_isActive__c = true LIMIT 5000];
		}
		else{
			String[] arguments = new String[] {CSM_CONSTANTS.OBJ_APP + ':'+String.valueOf(noAccessList) + CSM_CONSTANTS.OBJ_PLAYBOOK + ':'+String.valueOf(noPlaybookAccessList)};
			List<CSM_Play_Result__c> errorPlayResult = new List<CSM_Play_Result__c>();
    		for (String pr : playResultsMap.keySet()){
				if (accountIdSet.contains(playResultsMap.get(pr).CSM_Account_Id__c)){
					playResultsMap.get(pr).CSM_Failed__c = true;
					playResultsMap.get(pr).CSM_Failed_Description__c = System.Label.CSM_MSG_OBJECT_NOT_READABLE + ' ' + arguments;
					errorPlayResult.add(playResultsMap.get(pr));
				}
    		}
    		if (errorPlayResult!=null && errorPlayResult.isEmpty()){
    			List<String> prFieldList = new List<String>{CSM_Constants.OBJ_PR_FAILED, CSM_Constants.OBJ_PR_FAILED_DESC};
    			CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PR, prFieldList, CSM_Constants.DML_OPERATION_UPDATE);
   			    update errorPlayResult;
    		}
    	}
		return tmpList;
	}
	
	public static List<CSM_Account_Plan_Playbook__c> createAccountPlanPlaybook(List<CSM_Account_Plan_Playbook__c> newAccountPlanPlaybookList)
	{
		List<String> appFieldList = new List<String>{CSM_Constants.OBJ_APP_ACCT_PLAN, 
			CSM_Constants.OBJ_APP_BYPASS_CRITERIA, CSM_Constants.OBJ_APP_SOURCE, 
			CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE};
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, appFieldList, CSM_Constants.DML_OPERATION_INSERT);
		insert newAccountPlanPlaybookList;
		return newAccountPlanPlaybookList;
	}
	
	public static List<CSM_Account_Plan_Playbook__c> createAccountPlanPlaybook(List<CSM_PlayBook__c> listOfPlaybooks, 
												Map<String, String> playbookForExternalIds, 
												Map<Id, CSM_Account_Plan__c> accountPlanMap,
												Map<Id, CSM_Account_Plan__c> apMap,
												Map<String, String> playbookExternalIds) {
		Map<String, CSM_Account_Plan_Playbook__c> appMap = new Map<String, CSM_Account_Plan_Playbook__c> (); 
		
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_PLAN};
			
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
			// Get all the Success Plan Playbooks
			for (CSM_Account_Plan_Playbook__c app : [SELECT CSM_Account_Plan__c, CSM_Playbook__c 
													FROM CSM_Account_Plan_Playbook__c 
													WHERE CSM_Playbook__c IN :listOfPlaybooks AND CSM_Account_Plan__c IN :apMap.KeySet() LIMIT 2000]) {
				appMap.put(app.CSM_Account_Plan__c +':'+app.CSM_Playbook__c, app);
			}
				
			List<CSM_Account_Plan_Playbook__c> appList = new List<CSM_Account_Plan_Playbook__c>();
	        for (String pbExtId : playbookExternalIds.KeySet()) {
				String[] acctPlayBookIds = pbExtId.split(':');
				if (acctPlayBookIds!=null && acctPlayBookIds.size()==2) {
					if (accountPlanMap !=null && accountPlanMap.containsKey(acctPlayBookIds[1]) &&
						playbookForExternalIds!=null && playbookForExternalIds.containsKey(acctPlayBookIds[0]) && 
						appMap!=null && appMap.containsKey(accountPlanMap.get(acctPlayBookIds[1]).Id+':'+playbookForExternalIds.get(acctPlayBookIds[0]))==false){
						CSM_Account_Plan_Playbook__c app = new CSM_Account_Plan_Playbook__c();
						app.CSM_Account_Plan__c = accountPlanMap.get(acctPlayBookIds[1]).Id;
						app.CSM_Source__c = CSM_Constants.STR_FROM_REVENUE_ANALYTICS;//Added for US1146
						app.CSM_Playbook__c = playbookForExternalIds.get(acctPlayBookIds[0]);
						appList.add(app);
					} 
				}
			}	
				
			if (appList!=null && !appList.isEmpty()){
				List<String> appFieldList = new List<String>{CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_PLAN,
				        CSM_Constants.OBJ_APP_SOURCE};
				CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, appFieldList, CSM_Constants.DML_OPERATION_INSERT);
				insert appList;
			}
		 return appList;
	}
	
	public static List<CSM_Account_Plan_Playbook__c> getAccountPlanPlaybooksByAccPlanId(String accountPlanId, String acctPlanTempId){
		
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> fcPlabybookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
			
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAYBOOK, fcPlabybookFieldList, CSM_Constants.DML_OPERATION_READ);
		tmpList = [SELECT Id, 
							  CSM_IsActive__c,
							  CSM_Playbook__c,
							  CSM_Playbook__r.Id,
							  CSM_Playbook__r.CSM_IsActive__c, 
							  CSM_Account_Plan__c,
							  CSM_Account_Plan_Template__c
						FROM 
						 	CSM_Account_Plan_Playbook__c
						WHERE 
							(CSM_Account_Plan__c = :accountPlanId and CSM_Account_Plan_Template__c = null)
						OR  (CSM_Account_Plan_Template__c = :acctPlanTempId and CSM_Account_Plan__c = null)
						LIMIT 2000];

		return tmpList;
	}
	public static List<CSM_Account_Plan_Playbook__c> getAccountPlanPlaybooksByPlanId(String accountPlanId){
		
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> fcPlabybookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
			
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAYBOOK, fcPlabybookFieldList, CSM_Constants.DML_OPERATION_READ);
		tmpList = [SELECT Id, 
							  CSM_IsActive__c,
							  CSM_Playbook__c,
							  CSM_Playbook__r.CSM_Display_Name__c,
							  CSM_Playbook__r.CSM_IsActive__c,
							  CSM_Playbook__r.CSM_Short_Description__c, 
							  CSM_Playbook__r.CSM_Automated__c,
							  CSM_Account_Plan__c,
							  CSM_Account_Plan_Template__c,
							  CSM_Status__c,
							  CSM_Source__c,
							  CSM_Task_Total__c,
							  CSM_Total_number_of_Plays__c,
							  CSM_Number_of_closed_Plays__c
						FROM 
						 	CSM_Account_Plan_Playbook__c
						WHERE 
						CSM_Account_Plan__c = :accountPlanId
						LIMIT 2000];

		return tmpList;
	}
	
	public static List<CSM_Account_Plan_Playbook__c> getAccountPlanPlaybooksByPlaybookId(String playbookId){
		
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> fcPlabybookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
			
		//List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, fcFieldList);
		//List<String> noPlaybookAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_READ, fcPlabybookFieldList);

		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAYBOOK, fcPlabybookFieldList, CSM_Constants.DML_OPERATION_READ);
		tmpList = [SELECT Id, 
							  CSM_Playbook__c, 
							  CSM_Account_Plan__c,
							  CSM_Account_Plan_Template__c,
							  CSM_Account_Plan__r.CSM_DisplayName__c,
							  CSM_Account_Plan_Template__r.CSM_Template_Name__c
						FROM 
						 	CSM_Account_Plan_Playbook__c
						WHERE 
							CSM_Playbook__c = :playbookId 
						LIMIT 10000];
		return tmpList;
	}
	
	/** 
	 * @description Returns Success Plan playbook for given playbooks and acctPlan association
	 */ 
	public static List<CSM_Account_Plan_Playbook__c> getAcctPlanPlaybooksByPlaybookIdAndAcctPlanId( List<string> playbookIds, String acctPlanId)
	{
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		//List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, fcFieldList);
		List<String> fcFieldList2 = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
		//List<String> noAccessList2 = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_READ, fcFieldList2);
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAYBOOK, fcFieldList2, CSM_Constants.DML_OPERATION_READ);

		tmpList = [select id, 
							  CSM_Playbook__c,  
							  CSM_Account_Plan__c, 
							  CSM_Account_Plan_Template__c
						 from CSM_Account_Plan_Playbook__c
						where CSM_Playbook__c in :playbookIds AND CSM_Account_Plan__c = :acctPlanId
						order by CSM_Playbook__c, CSM_Account_Plan__c,CSM_Account_Plan_Template__c
						limit 5000];
		return tmpList;
	}
	
	public static Database.queryLocator getQueryLocatorSPPBBatch()
	{	
		List<String> fieldList = new List<String>{CSM_Constants.OBJ_AP_ID, CSM_Constants.OBJ_APP_ACCT_PLAN,CSM_Constants.OBJ_APP_ACCT_TEMPLATE,CSM_Constants.OBJ_APP_PLAYBOOK};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_APP, fieldList, CSM_Constants.DML_OPERATION_READ);
		
		String queryStr = 'SELECT Id,' + namespace +'CSM_Account_plan__C,' + namespace +'CSM_Account_plan_template__C,'  + namespace +'CSM_PlayBook__C FROM ' + namespace + 'CSM_Account_Plan_Playbook__c where '+ namespace +'CSM_Account_plan__C = null order by ' + namespace + 'CSM_Account_plan_template__C';
 		system.debug('quueerry - ' + queryStr);
		return Database.getQueryLocator(queryStr);
	}	

	public static Integer getQueryLocatorCount(String objectName)
	{	
		List<String> fieldList = new List<String>{CSM_Constants.OBJ_AP_ID};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_APP, fieldList, CSM_Constants.DML_OPERATION_READ);
		
		String queryStr = 'select count() from ' + namespace + objectName  + ' where '+ namespace +'CSM_Account_plan__C = null';
 
		return Database.countQuery(queryStr);
	}
	
	public static List<CSM_Account_Plan_Playbook__c> getTemplateNullInPlanPlaybook()
	{	
		List<String> fieldList = new List<String>{CSM_Constants.OBJ_AP_ID, CSM_Constants.OBJ_APP_ACCT_PLAN,CSM_Constants.OBJ_APP_ACCT_TEMPLATE,CSM_Constants.OBJ_APP_PLAYBOOK};
		CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_APP, fieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<CSM_Account_Plan_Playbook__c> planPlaybookList= [SELECT Id,CSM_Account_plan__C,CSM_Account_plan_template__C,CSM_PlayBook__C FROM CSM_Account_Plan_Playbook__c where CSM_Account_plan_template__C = null];

		return planPlaybookList;
	}	
		
	
	
	public static List<CSM_Account_Plan_Playbook__c> getAcctPlanPlaybooksByTmpltIDLstWthoutAccPlan(Set<String> templateList){
		List<CSM_Account_Plan_Playbook__c> sppbLst = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		sppbLst =  [Select id,CSM_Account_Plan__c,CSM_Playbook__c,CSM_Account_Plan_Template__c from CSM_Account_Plan_Playbook__c where CSM_Account_Plan_Template__c IN :templateList and CSM_Account_Plan_Template_1__c IN :templateList LIMIT 10000]; //CSM_Account_Plan__c = null
		
		return sppbLst;
	}
	
	public static List<CSM_Account_Plan_Playbook__c> getAcctPlanPlaybooksByTmpltIDandPlBookId(List<String>templateList,List<String>plBookList,List<CSM_Account_Plan_Playbook__c> splanPbookLst){
		List<CSM_Account_Plan_Playbook__c> sppbLst = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		sppbLst =  [Select id
					from CSM_Account_Plan_Playbook__c 
					where CSM_Account_Plan_Template__c IN :templateList and CSM_Playbook__c IN: plBookList 
								and CSM_Account_Plan__c != null and Id not in: splanPbookLst Limit 10000];
		
		return sppbLst;
	}
	
	public static List<CSM_Account_Plan_Playbook__c> getAcctPlanPlaybooksByAccPlanIdwithTemp(List<String> accountPlanIdLst){
		List<CSM_Account_Plan_Playbook__c> sppbLst = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
		sppbLst =  [Select id,CSM_Account_Plan__c,CSM_Playbook__c,CSM_Account_Plan_Template__c from CSM_Account_Plan_Playbook__c where CSM_Account_Plan__c IN :accountPlanIdLst AND CSM_Account_Plan_Template__c != null LIMIT 10000];
		
		return sppbLst;
	}
	public static List<CSM_Account_Plan_Playbook__c> getAcctPlanPlaybooksByAccPlanId(List<String> accountPlanIdLst){
		List<CSM_Account_Plan_Playbook__c> sppbLst = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, 
			CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, 
			CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN,
			CSM_Constants.OBJ_APP_SOURCE};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
		sppbLst =  [Select id,CSM_Account_Plan__c,CSM_Playbook__c,CSM_Account_Plan_Template__c from CSM_Account_Plan_Playbook__c 
					where CSM_Account_Plan__c IN :accountPlanIdLst Limit 10000 ];
		
		return sppbLst;
	}
	
	public static List<CSM_Account_Plan_Playbook__c> insertAcctPlanPlaybook (List<CSM_Account_Plan_Playbook__c> acctPlanPlBookLst){
		 
		 List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN,CSM_Constants.OBJ_APP_SOURCE};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_INSERT);
		insert acctPlanPlBookLst;
		
		return acctPlanPlBookLst;
	}
	
	public static void deleteAcctPlanPlaybook (List<CSM_Account_Plan_Playbook__c> acctPlanPlBookLst){
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, null, CSM_Constants.DML_OPERATION_DELETE);
		delete acctPlanPlBookLst;
	}
	
	public static List<CSM_Account_Plan_Playbook__c> getAcctPlanPlaybookByTemplatewithAcctPlan(List<String> templateLst){
		
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		List<CSM_Account_Plan_Playbook__c> acctplanPBookLst = [Select id,CSM_Account_Plan__c,CSM_Account_Plan_Template__c 
																from CSM_Account_Plan_Playbook__c 
																where CSM_Account_Plan_Template__c IN:templateLst 
																	and CSM_Account_Plan__c != null Limit 10000];
		
		return 	acctplanPBookLst;
	}
	public static List<CSM_Account_Plan_Playbook__c> getSuccessPlanPlaybookBySPTId(Set<Id> sptId){
		
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> fcPlabybookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAYBOOK, fcPlabybookFieldList, CSM_Constants.DML_OPERATION_READ);
		tmpList = [SELECT Id, 
							  CSM_Playbook__c, 
							  CSM_Account_Plan__c,
							  CSM_Account_Plan_Template__c,
							  CSM_Account_Plan__r.CSM_DisplayName__c,
							  CSM_Account_Plan_Template__r.CSM_Template_Name__c
						FROM 
						 	CSM_Account_Plan_Playbook__c
						WHERE 
							CSM_Account_Plan_Template__c = :sptId 
						LIMIT 10000];
		return tmpList;
	}
	public static List<CSM_Account_Plan_Playbook__c> updateAccountPlanPlaybookList (List<CSM_Account_Plan_Playbook__c> acctPlanPlBookLst){
		 
		 List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ACCT_TEMPLATE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_UPDATE);
		update acctPlanPlBookLst;
		
		return acctPlanPlBookLst;
	}
	public static List<CSM_Account_Plan_Playbook__c> getAccountPlanPlaybooksByPlaybook(Set<Id> playbookIds){
		
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> fcPlabybookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
			
		//List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, fcFieldList);
		//List<String> noPlaybookAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_READ, fcPlabybookFieldList);

		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAYBOOK, fcPlabybookFieldList, CSM_Constants.DML_OPERATION_READ);
		tmpList = [SELECT Id, 
							  CSM_Playbook__c, 
							  CSM_Account_Plan__c,
							  CSM_Account_Plan_Template__c,
							  CSM_Account_Plan__r.CSM_DisplayName__c,
							  CSM_Account_Plan_Template__r.CSM_Template_Name__c
						FROM 
						 	CSM_Account_Plan_Playbook__c
						WHERE 
							CSM_Playbook__c IN :playbookIds
						LIMIT 10000];
		return tmpList;
	}
	public static List<CSM_Account_Plan_Playbook__c> getAccountPlanPlaybooksByPlaybookIds(Set<Id> playbookIds){
		
		List<CSM_Account_Plan_Playbook__c> tmpList = new List<CSM_Account_Plan_Playbook__c>();
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_APP_ID, CSM_Constants.OBJ_APP_PLAYBOOK, CSM_Constants.OBJ_APP_ISACTIVE, CSM_Constants.OBJ_APP_ACCT_PLAN};
		List<String> fcPlabybookFieldList = new List<String>{CSM_Constants.OBJ_PLAYBOOK_AUTOMATED, CSM_Constants.OBJ_PLAYBOOK_ISACTIVE};
			
		//List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_APP,CSM_Constants.DML_OPERATION_READ, fcFieldList);
		//List<String> noPlaybookAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_PLAYBOOK,CSM_Constants.DML_OPERATION_READ, fcPlabybookFieldList);

		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_APP, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		CSM_Util.checkCRUD_FLS(CSM_CONSTANTS.OBJ_PLAYBOOK, fcPlabybookFieldList, CSM_Constants.DML_OPERATION_READ);
		tmpList = [SELECT Id, 
							  CSM_Playbook__c, 
							  CSM_Account_Plan__c,
							  CSM_Account_Plan_Template__c,
							  CSM_Account_Plan__r.CSM_DisplayName__c,
							  CSM_Account_Plan_Template__r.CSM_Template_Name__c
						FROM 
						 	CSM_Account_Plan_Playbook__c
						WHERE 
							CSM_Playbook__c IN :playbookIds and CSM_Account_Plan__c != null
						LIMIT 10000];
		return tmpList;
	}
}