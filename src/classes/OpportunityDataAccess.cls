/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         05/20/2016
 * @description  Opportunity Data Access class
 */
public with sharing class OpportunityDataAccess
{
    public static Map<Id, Opportunity> getOpportunityMapById(Set<Id> opportunityIdSet) {
      Util.checkCRUD_FLS('Opportunity', new List<String>{'CloseDate', 'Name', 'isWon', 'StageName', 'CloseDate', 'CurrencyIsoCode'}, Constants.DML_OPERATION_READ);
      return new Map<Id, Opportunity>([SELECT Id, Name, isWon, StageName, CloseDate, CurrencyIsoCode FROM Opportunity WHERE Id IN :opportunityIdSet]);
    }
    
    public static List<Opportunity> getOpportunityListById(Set<String> opportunityIdSet) {
       Util.checkCRUD_FLS('Opportunity', new List<String>{'AccountId','Name'}, Constants.DML_OPERATION_READ);
       return [SELECT Id, AccountId ,Name FROM Opportunity WHERE Id IN :opportunityIdSet];
    }
  
    public static List<AggregateResult> getCountWithBusinessByFilterConditionsByExpDate(String aditionalFilterConditions, Set<String> diaCompliantStages,
        String expDate)
    {
    	String namespace = Util.solnExtnNameSpace;
    	List<String> oppFields = new List<String> {namespace + 'Business_Line__c','Id', 
    	    namespace + 'Target_DIA__c', namespace + 'Quote_Completed_DIA__c',
    	    namespace +  'Quote_Delivered_DIA__c', 
    	    'REN_Earliest_Expiration_Date__c', 'StageName'};
        Util.checkCRUD_FLS('Opportunity', oppFields, Constants.DML_OPERATION_READ);
        String oppQuery = 'SELECT Business_Line__c businessLine, COUNT(Id) recordCount, SUM(Target_DIA__c) sumTargetDIA, '
                        + ' SUM(Quote_Completed_DIA__c) sumQuoteCompletedDIA, '
                        + ' SUM(Quote_Delivered_DIA__c) sumQuoteDeliveredDIA FROM Opportunity ';
        String conditions = ' WHERE REN_Earliest_Expiration_Date__c = ' + expDate + ' AND StageName IN :diaCompliantStages ';
        String groupByCondition = ' Group By Business_Line__c ';
        
        return Database.query(oppQuery + conditions + aditionalFilterConditions + groupByCondition);
    }
    
    
    public static List<AggregateResult> getCountByFilterConditionsByExpDate(String aditionalFilterConditions, Set<String> diaCompliantStages,
        String expDate)
    {
        String namespace = Util.solnExtnNameSpace;
        List<String> oppFields = new List<String> {'Id', namespace + 'Target_DIA__c', 
        	namespace + 'Quote_Completed_DIA__c', namespace + 'Quote_Delivered_DIA__c', 
        	namespace + 'Lead_Time__c', 
        	namespace + 'DIA_Compliance__c','REN_Earliest_Expiration_Date__c', 'StageName'};
      Util.checkCRUD_FLS('Opportunity', oppFields, Constants.DML_OPERATION_READ);
      String oppQuery = 'SELECT COUNT(Id) recordCount, SUM(Target_DIA__c) sumTargetDIA, '
          + ' SUM(Quote_Completed_DIA__c) sumQuoteCompletedDIA, '
          + ' SUM(Quote_Delivered_DIA__c) sumQuoteDeliveredDIA, SUM(Lead_Time__c) sumLeadTime, ' 
          + 'SUM(DIA_Compliance__c) sumDIACompliance FROM Opportunity ';
        String conditions = ' WHERE REN_Earliest_Expiration_Date__c = ' +expDate +  ' AND StageName IN :diaCompliantStages ';
     return Database.query(oppQuery + conditions + aditionalFilterConditions);
    }
    
    public static List<AggregateResult> getCountByDateAndStage(String aditionalFilterConditions, String expDate1, String expDate2, Set<String> diaStageNames)
    {
    	 List<String> oppFields = new List<String> {'Id', Util.solnExtnNameSpace + 'Quote_Completed_DIA__c', 
    	 	'REN_Earliest_Expiration_Date__c', 'StageName'};
         Util.checkCRUD_FLS('Opportunity', oppFields, Constants.DML_OPERATION_READ);
    	
    	String oppQuery = 'SELECT COUNT(Id) recordCount, SUM(Quote_Completed_DIA__c) sumQuoteCompletedDIA FROM Opportunity ';
        String conditions = ' WHERE (REN_Earliest_Expiration_Date__c = ' + expDate1
         + ' OR REN_Earliest_Expiration_Date__c = ' + expDate2+') AND StageName IN :diaStageNames ';
    	return Database.query(oppQuery + conditions + aditionalFilterConditions );
    }
     
        
    
    public static List<AggregateResult> getCountWithExpDateAndStage(String aditionalFilterConditions, 
        String expDate1, String expDate2, Set<String> diaStageNames, String soqlLimit)
    {
         List<String> oppFields = new List<String> {'REN_Earliest_Expiration_Date__c', 'StageName', 
    	 	'Id', 'REN_Days_Until_Expiration__c'};
         Util.checkCRUD_FLS('Opportunity', oppFields, Constants.DML_OPERATION_READ);
    
        String oppQuery = 'SELECT REN_Earliest_Expiration_Date__c endDate, StageName stage, COUNT(Id) recordCount, AVG(REN_Days_Until_Expiration__c) avgRollingDIA FROM Opportunity ';
        String conditions = ' WHERE (REN_Earliest_Expiration_Date__c = ' + expDate1 + ' OR REN_Earliest_Expiration_Date__c = '+ expDate2+ ') AND StageName IN :diaStageNames ';
        String groupByCondition = ' Group By REN_Earliest_Expiration_Date__c, StageName Order By REN_Earliest_Expiration_Date__c ASC ';
        String queryLimit = ' LIMIT ' + soqlLimit;    
        return Database.query(oppQuery + conditions + aditionalFilterConditions + groupByCondition+ queryLimit);
     
    }
     
    
    public static List<AggregateResult> getCountWithStageByDate(String expDate, String aditionalFilterConditions)
    {
    	 List<String> oppFields = new List<String> {'StageName', 'Id', 'REN_Renewal_Target__c',
    	 	'REN_Earliest_Expiration_Date__c'};
         Util.checkCRUD_FLS('Opportunity', oppFields, Constants.DML_OPERATION_READ);
    	
    	String oppQuery = 'SELECT StageName stage, COUNT(Id) recordCount, SUM(REN_Renewal_Target__c) sumRenewalAmount FROM Opportunity ';
        String conditions = ' WHERE REN_Earliest_Expiration_Date__c = ' + expDate + ' ';
        String groupByCondition = ' Group By StageName ';
        return Database.query(oppQuery + conditions + aditionalFilterConditions + groupByCondition);
    }
    public static List<Opportunity> getOpportunityDetailsById(Set<Id> opportunityIdSet, List<String> fldsToQuery, List<String> additionlFields){
		Util.checkCRUD_FLS('Opportunity', fldsToQuery, Constants.DML_OPERATION_READ);
		String soqlString;
		if(additionlFields != null){
			fldsToQuery.addAll(additionlFields);
		}
   		soqlString = 'SELECT ' + String.join(fldsToQuery, ',') + ' FROM Opportunity WHERE Id IN:opportunityIdSet limit 1000'; 
        return Database.query(soqlString);
		
	}
	public static void updateOpportunityList(List<Opportunity> opportunityList, List<String> fieldListForCrudFls){        
        Util.checkCRUD_FLS('Opportunity', fieldListForCrudFls, Constants.DML_OPERATION_UPDATE);
        update opportunityList;         
        
    }
}