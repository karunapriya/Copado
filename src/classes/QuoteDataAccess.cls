/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         05/20/2016
 * @description  Quote Data Access class
 */
public with sharing class QuoteDataAccess{
  

  public static List<Quote> getQuoteListByCaseAndStatus(Set<String> caseSet, String reviewStatus) { 
      String namespace = Util.solnExtnNameSpace;
       List<String> quoteFields = new List<String>{Constants.OBJ_SC_TOTAL_PRICE, 
       	                                           namespace+Constants.QUOTE_EARLIEST_START_DT, 
	                 							   namespace+Constants.QUOTE_LATEST_END_DT, 
	                 							   namespace+Constants.QUOTE_TYPE_YEAR, 
	       										   namespace+Constants.QUOTE_REVIEW_STATUS, 
	       										   namespace+Constants.QUOTE_ERROR_CATEGORY,
	                 							   namespace+Constants.QUOTE_CASE };
      Util.checkCRUD_FLS(Constants.OBJ_QUOTE, quoteFields, Constants.DML_OPERATION_READ);
      return [SELECT Id, 
	                 Name, 
	                 TotalPrice, 
	                 CLM_Earliest_Start_Date__c, 
	                 CLM_Latest_End_Date__c, 
	                 Quote_Type_Year__c, 
	                 Review_Status__c, 
	                 Error_Category__c 
	            FROM Quote
	           WHERE Review_Status__c = :reviewStatus
	             AND Case__c = :caseSet 
	             ORDER BY Name ASC LIMIT 9999];
  }
  
  public static List<Quote> getQuoteListByCase(Set<String> caseSet) { 
      String namespace = Util.solnExtnNameSpace;
      List<String> quoteFields = new List<String>{Constants.OBJ_SC_TOTAL_PRICE,
      	                                          namespace+Constants.QUOTE_EARLIEST_START_DT, 
	                 							  namespace+Constants.QUOTE_LATEST_END_DT, 
	                 							  namespace+Constants.QUOTE_TYPE_YEAR, 
	                 							  namespace+Constants.QUOTE_REVIEW_STATUS, 
	                 							  namespace+Constants.QUOTE_ERROR_CATEGORY,
	                 							  namespace+Constants.QUOTE_CASE };
      Util.checkCRUD_FLS(Constants.OBJ_QUOTE, quoteFields, Constants.DML_OPERATION_READ);
      return [SELECT Id, 
                     Name, 
                     TotalPrice, 
                     CLM_Earliest_Start_Date__c, 
                     CLM_Latest_End_Date__c, 
                     Quote_Type_Year__c, 
                     Review_Status__c, 
                     Error_Category__c 
                FROM Quote 
            WHERE Case__c = :caseSet 
            AND Case__c != null 
            ORDER BY Name ASC LIMIT 9999];    
  }
  
  public static Map<Id, Quote> getQuoteMapByCase(Set<String> caseSet) { 
      String namespace = Util.solnExtnNameSpace;
      List<String> quoteFields = new List<String>{Constants.OBJ_SC_TOTAL_PRICE, 
      	                                         namespace+Constants.QUOTE_EARLIEST_START_DT, 
	                  							 namespace+Constants.QUOTE_LATEST_END_DT, 
	                  							 namespace+Constants.QUOTE_TYPE_YEAR, 
	                 							 namespace+Constants.QUOTE_REVIEW_STATUS, 
	                 							 namespace+Constants.QUOTE_ERROR_CATEGORY,
	                 							 namespace+Constants.QUOTE_CASE };
	  Util.checkCRUD_FLS(Constants.OBJ_QUOTE, quoteFields, Constants.DML_OPERATION_READ);   
      return new Map<Id, Quote>([SELECT Id, 
            Name, 
            TotalPrice, 
            CLM_Earliest_Start_Date__c, 
            CLM_Latest_End_Date__c, 
            Quote_Type_Year__c, 
            Review_Status__c, 
            Error_Category__c 
            FROM Quote 
            WHERE Case__c = :caseSet 
            AND Case__c != null LIMIT 9999]);    
  }
  
  public static void updateQuoteList(List<Quote> quoteList) { 
  	  String namespace = Util.solnExtnNameSpace;
      List<String> quoteFields = new List<String>{//Constants.OBJ_SC_TOTAL_PRICE, 
      	                                         //namespace+Constants.QUOTE_EARLIEST_START_DT, 
	                  							 //namespace+Constants.QUOTE_LATEST_END_DT, 
	                  							 namespace+Constants.QUOTE_TYPE_YEAR, 
	                 							 namespace+Constants.QUOTE_REVIEW_STATUS, 
	                 							 namespace+Constants.QUOTE_ERROR_CATEGORY,
	                 							 namespace+Constants.QUOTE_CASE };
	  Util.checkCRUD_FLS(Constants.OBJ_QUOTE, quoteFields, Constants.DML_OPERATION_UPDATE);   
      update quoteList;    
  }
  
  public static List<AggregateResult> getCountByConditions(String aditionalFilterConditions){
  	  List<String> quoteFields = new List<String> {Util.solnExtnNameSpace+Constants.QUOTE_REVIEW_STATUS};
      Util.checkCRUD_FLS(Constants.OBJ_QUOTE, quoteFields, Constants.DML_OPERATION_READ);
      
      List<String> caseFields = new List<String> {Constants.CASE_ORIGIN};
      Util.checkCRUD_FLS(Constants.OBJ_CASE, caseFields, Constants.DML_OPERATION_READ);
      
      String quoteQuery = ' SELECT Case__r.Origin origin, Review_Status__c reviewStatus, count(Id) recordCount FROM Quote ';
      String conditions = ' WHERE Case__c != null AND Review_Status__c != null ';
      String queryLimit = ' LIMIT 999999 ';   // Limit upto 1 million rows
      String groupByConditionUserLevel = ' Group By Case__r.Origin, Review_Status__c ';
        
      return Database.query(quoteQuery + conditions + aditionalFilterConditions + groupByConditionUserLevel + queryLimit);
  } 
  
  public static List<Quote> getQuoteByCase(Set<String> caseIds){
      List<String> quoteFields = new List<String> {	Constants.CURRENCY_ISO_CD, Constants.OBJ_SC_TOTAL_PRICE, Util.solnExtnNameSpace+Constants.QUOTE_REVIEW_STATUS };
      Util.checkCRUD_FLS(Constants.OBJ_QUOTE, quoteFields, Constants.DML_OPERATION_READ);
      return [SELECT Id, Name, CurrencyIsoCode, TotalPrice,
      		CLM_Earliest_Start_Date__c, 
            CLM_Latest_End_Date__c, 
            Quote_Type_Year__c, 
            Review_Status__c,
            OpportunityId, 
            IsSyncing, 
            Error_Category__c, Case__c  FROM Quote WHERE Case__c = :caseIds ORDER BY Name ASC LIMIT 9999];
            
  }
  
  /************** START -- Functions for QuoteLineItem ***********/
  
  public static Map<Id, QuoteLineItem> getQuoteLineMapByQuote(Set<Id> quoteIdSet) {  
  	  String namespace = Util.solnExtnNameSpace;   
      List<String> quoteLiFields = new List<String> {namespace+ Constants.QUOTE_LOCAL_CURR_AMT,
          namespace+Constants.QUOTE_LOCAL_CURR_CODE, Constants.QLI_QUOTE_ID, Constants.QLI_QUANTITY};
      Util.checkCRUD_FLS(Constants.OBJ_QUOTE_LI, quoteLiFields, Constants.DML_OPERATION_READ);
      
      return new Map<Id, QuoteLineItem>([SELECT Id,Local_Currency_Amount__c, Local_Currency__c, QuoteId,Quantity FROM QuoteLineItem WHERE QuoteId IN :quoteIdSet AND Local_Currency__c != NULL LIMIT 9999]);
  }
}