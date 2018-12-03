/**
 * Created Date     : March 05, 2018
 * Developed By     : Nidhi, Comity Designs, Inc.
 *
 * Function         : This class is act as a wrapper class for opportunity trigger parameters. Added as part of US2947.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Nidhi                 US2947             March 05, 2018            1.1                 @description
 *
 */
 
public with sharing class REN_OpportunityTriggerParams {
	
	//public List<Opportunity> oppListToUpdateSalesTarget;
	//public Map<Id, Opportunity> oldRecMapToUpdateSalesTarget;
	//public Set<Id> accountIdSet;
	//public Set<Id> syncedQuoteIdSet;
	public Set<Id> filteredIdSet;
	public Set<Id> idSet;
	public Map<Id, Opportunity> filteredOpportunityMap;
	public List<CHL_Partner_Opportunity__c> partnerOptyList;
	public List<Opportunity> filteredOpportunityList;
	public Map<Id, Opportunity> newRecordsMap;
	public Map<Id, Opportunity> oldRecordsMap;
}