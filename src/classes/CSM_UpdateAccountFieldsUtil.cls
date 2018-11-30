/**
 * @author      Tanvi Sarolkar (tanvi@comitydesigns.com)    
 * @date         02/06/2015
 * @description  CSM_UpdateAccountFieldsUtil - trigger Utility class for updating account fields whenever Case is updated/created/deleted. 
                 This class is created as part of SF295
 */

public with sharing class CSM_UpdateAccountFieldsUtil { 
       
	public static void UpdateAccFieldsForCases(Set<Id> accIds)	{
		
		Map<String, List<Case>> numberOfCasesMap = new Map<String, List<Case>>(); //to Store Number of Cases (Open Cases) for Account
		
		Map<String, List<Case>> numberOfHighPriorityCaseMap = new Map<String, List<Case>>(); //to get High Priority Cases for Account
		
		Map<String, List<Case>> NumberOfClosedCaseMap = new Map<String, List<Case>>(); //to get Number of Closed Cases for Account
		
		Map<String, List<Case>> NumberOfNewCaseMap = new Map<String, List<Case>>(); //to get Number of New Cases for Account
		
		Map<String, List<Case>> NumberOfWorkingCaseMap = new Map<String, List<Case>>(); //to get Number of Working Cases for Account
		
		List<Account> accLst = CSM_AccountDataAccess.getAccountInformationforCases(accIds);		
		
		List<Case> caseForAccountsLst = CSM_CaseDataAccess.getCasesByAccount(accIds);
		
		if(caseForAccountsLst != null && !caseForAccountsLst.isEmpty())	{
			List<Case> numberOfCaseList = new List<Case>();
			List<Case> numberOfHighPriorityCaseList = new List<Case>();
			List<Case> numberOfClosedCaseList = new List<Case>();
			List<Case> numberOfNewCaseList = new List<Case>();
			List<Case> numberOfWorkingCaseList = new List<Case>();
			List<Case> AvgResponsetimeforCaseList = new List<Case>();
			for(Case cs: caseForAccountsLst)	{
				
				if(cs.status != CSM_Constants.OBJ_CASE_STATUS_CLOSED)	{
					if(numberOfCasesMap.containsKey(cs.AccountId))	{
						numberOfCaseList = numberOfCasesMap.get(cs.AccountId);
					}
					else {
						numberOfCaseList = new List<Case>();
					}
					numberOfCaseList.add(cs);
					numberOfCasesMap.put(cs.AccountId, numberOfCaseList);
				}
				if(cs.status != CSM_Constants.OBJ_CASE_STATUS_CLOSED && cs.priority == CSM_Constants.OBJ_CASE_PRIORITY_HIGH)	{
					if(numberOfHighPriorityCaseMap.containsKey(cs.AccountId))	{
						numberOfHighPriorityCaseList  = numberOfHighPriorityCaseMap.get(cs.AccountId);
					}
					else {
						numberOfHighPriorityCaseList  = new List<Case>();
					}
					numberOfHighPriorityCaseList.add(cs);
					numberOfHighPriorityCaseMap.put(cs.AccountId, numberOfHighPriorityCaseList);
				}
				if(cs.status == CSM_Constants.OBJ_CASE_STATUS_CLOSED)	{
					if(NumberOfClosedCaseMap.containsKey(cs.AccountId))	{
						numberOfClosedCaseList  = NumberOfClosedCaseMap.get(cs.AccountId);
					}
					else {
						numberOfClosedCaseList  = new List<Case>();
					}
					numberOfClosedCaseList.add(cs);
					NumberOfClosedCaseMap.put(cs.AccountId, numberOfClosedCaseList);
				}
				if(cs.status == CSM_Constants.OBJ_CASE_STATUS_NEW)	{
					if(NumberOfNewCaseMap.containsKey(cs.AccountId))	{
						numberOfNewCaseList  = NumberOfNewCaseMap.get(cs.AccountId);
					}
					else {
						numberOfNewCaseList  = new List<Case>();
					}
					numberOfNewCaseList.add(cs);
					NumberOfNewCaseMap.put(cs.AccountId, numberOfNewCaseList);
				}
				if(cs.status == CSM_Constants.OBJ_CASE_STATUS_WORKING)	{
					if(NumberOfWorkingCaseMap.containsKey(cs.AccountId))	{
						numberOfWorkingCaseList  = NumberOfWorkingCaseMap.get(cs.AccountId);
					}
					else {
						numberOfWorkingCaseList  = new List<Case>();
					}
					numberOfWorkingCaseList.add(cs);
					NumberOfWorkingCaseMap.put(cs.AccountId, numberOfWorkingCaseList);
				}				
			}
			
		}
		if(accLst != null && !accLst.isEmpty())	{
			//system.debug('##CASES :  '+caseForAccountsLst);
			List<Case> OldestcaseForAccountsLst = CSM_CaseDataAccess.getOldestCaseforAccount(accIds);
			Integer totDiff_hrs = 0;        
			Integer AvgHrs = 0;
			List<Account> lstToUpdateAccount = new List<Account>();
			System.debug('accLst - '+accLst);
			for(Account acct: accLst)	{
				//find Number of New Cases associated to account
				if(numberOfCasesMap.containsKey(acct.Id)){
					acct.CSM_Number_of_Cases__c = numberOfCasesMap.get(acct.Id).size();
					system.debug('CSM_Number_of_Cases__c = '+acct.CSM_Number_of_Cases__c);
				}
				else
					acct.CSM_Number_of_Cases__c = 0;
				
				//find Number of Open High Priority Cases associated to account
				if(numberOfHighPriorityCaseMap.containsKey(acct.Id))	{
					acct.CSM_Number_of_Open_High_Priority_Cases__c = numberOfHighPriorityCaseMap.get(acct.Id).size();
					system.debug('CSM_Number_of_Open_High_Priority_Cases__c = '+acct.CSM_Number_of_Open_High_Priority_Cases__c);
				}
				else
					acct.CSM_Number_of_Open_High_Priority_Cases__c = 0;
				
				//find Number of Closed Cases associated to account
				if(NumberOfClosedCaseMap.containsKey(acct.Id))	{
					acct.CSM_Number_of_Closed_Cases__c = NumberOfClosedCaseMap.get(acct.Id).size();
					//To find Average SLA Response time of all the closed cases associated to the account. 
                	//It will used formula field which is created on Case, to calculate difference between Case Open & Case Closed Date.
					for(Case csRec : NumberOfClosedCaseMap.get(acct.Id))	{
						totDiff_hrs = totDiff_hrs + integer.valueof(csRec.CSM_DiffOf_Creation_Closed_Dates__c);
					}
					if(totDiff_hrs > 0)
						AvgHrs = totDiff_hrs/(NumberOfClosedCaseMap.get(acct.Id).size());
					else
						AvgHrs = 0;
					acct.CSM_Average_SLA_Response_Time__c = string.valueof(AvgHrs);
				}
				else	{
					acct.CSM_Number_of_Closed_Cases__c = 0;
					acct.CSM_Average_SLA_Response_Time__c = '0';
				}	
				//find Number of New Cases associated to account
				if(NumberOfNewCaseMap.containsKey(acct.Id))	{
					acct.CSM_Number_of_New_Cases__c = NumberOfNewCaseMap.get(acct.Id).size();
				}
				else
					acct.CSM_Number_of_New_Cases__c = 0;
					
				//find Number of Working Cases associated to account	
				if(NumberOfWorkingCaseMap.containsKey(acct.Id))	{
					acct.CSM_Number_of_Working_Cases__c = NumberOfWorkingCaseMap.get(acct.Id).size();
				}
				else
					acct.CSM_Number_of_Working_Cases__c = 0;
				
				
				//this  will find oldest open case associated to particular account.	
				if(OldestcaseForAccountsLst != null && !OldestcaseForAccountsLst.isEmpty())	{
					for(Case cs: OldestcaseForAccountsLst)  {
	                    if(acct.Id == cs.AccountId)  {
	                        acct.CSM_Oldest_Open_Case__c = cs.Id;
	                        break;
	                    }
	                }
				}
				else
				{
					acct.CSM_Oldest_Open_Case__c = null;
				}
					
				lstToUpdateAccount.add(acct);
			}
			System.debug('ZZZ - lstToUpdateAccount - '+lstToUpdateAccount);
			//update lstToUpdateAccount; 	
			CSM_AccountDataAccess.updateAccountsforCase(lstToUpdateAccount);			
		}
	 }    
        
}