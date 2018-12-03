/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         07/28/2016
 * @description  Proactive Data Access class
 */
public with sharing class ProactiveDataAccess
{
	/**
    * @description : This method returns a list of proactive case setup records for the given set of rules
    * @param a set of proactive rule ids
    * @return a list of proactive case setup records
    */
	public static List<Proactive_Case_Setup__c> getProactiveCaseSetupByRule(Set<String> proactiveRuleIds)	
	{
	    List<String> proCaseSetupFieldList = new List<String>{Util.solnExtnNameSpace +'Delete_Action__c', Util.solnExtnNameSpace +'Field__c',Util.solnExtnNameSpace +'Value__c',Util.solnExtnNameSpace +'Proactive_Rule__c'};
	    Util.checkCRUD_FLS('Proactive_Case_Setup__c', proCaseSetupFieldList, Constants.DML_OPERATION_READ);
	    
	    return[SELECT Id, 
                      Name, 
                      Delete_Action__c, 
                      Field__c, 
                      Value__c 
                 FROM Proactive_Case_Setup__c 
                WHERE Proactive_Rule__c = :proactiveRuleIds
                ORDER BY Name, CreatedDate ASC];
	}
	
	
	/**
    * @description : This method returns a list of proactive line items for the given set of rules
    * @param a set of proactive rule ids
    * @return a list of proactive rule line items
    */
	public static List<Proactive_Rule_Line_Item__c> getProactiveLineItemsByRule(Set<Id> proactiveRuleIds)	
	{	
	    List<String> proRuleLIFieldList = new List<String>{Util.solnExtnNameSpace +'Output__c',Util.solnExtnNameSpace +'Delete_Action__c', Util.solnExtnNameSpace +'Field__c', Util.solnExtnNameSpace +'Value__c',Util.solnExtnNameSpace +'Type__c',Util.solnExtnNameSpace +'Operator__c',Util.solnExtnNameSpace +'Proactive_Rule__c'};
	    Util.checkCRUD_FLS('Proactive_Rule_Line_Item__c', proRuleLIFieldList, Constants.DML_OPERATION_READ);
	    
	    return [SELECT Id, 
                       Name, 
                       Output__c,
                       Delete_Action__c, 
			           Field__c, 
			           Type__c, 
			           Operator__c, 
			           Value__c,
			           Proactive_Rule__c  
                  FROM Proactive_Rule_Line_Item__c 
                 WHERE Proactive_Rule__c = :proactiveRuleIds  
                 ORDER BY Name, CreatedDate ASC];
	}
	

	/**
    * @description : This method returns a list of proactive rules for the given ids
    * @param a set of ids
    * @return a list of proactive rules
    */
	public static List<Proactive_Rule__c> getProactiveRuleById(Set<String> proactiveRuleIds)	
	{
		 List<String> proRuleFieldList = new List<String>{Util.solnExtnNameSpace +'Filter_Logic__c',Util.solnExtnNameSpace +'Order_By__c', Util.solnExtnNameSpace +'Order_Type__c', Util.solnExtnNameSpace +'Limit__c', Util.solnExtnNameSpace +'Output__c' };
	     Util.checkCRUD_FLS('Proactive_Rule__c', proRuleFieldList, Constants.DML_OPERATION_READ);
		 
		 return [SELECT Id, 
                        Name, 
                        Filter_Logic__c, 
                        Order_By__c, 
                        Order_Type__c, 
                        Limit__c, 
                        Output__c 
                   FROM Proactive_Rule__c  
                  WHERE Id  IN :proactiveRuleIds];
	    
	}
	
	/**
    * @description : This method updates proactive rules
    * @param a list of proactive rules
    */
	public static void updateProactiveRules(List<Proactive_Rule__c> updatedProactiveRules, List<String> proactiveRuleFieldList)
	{
		Util.checkCRUD_FLS('Proactive_Rule__c', proactiveRuleFieldList, Constants.DML_OPERATION_UPDATE);
		update updatedProactiveRules;
	}	
	
	/**
    * @description : This method inserts proactive line items 
    * @param a list of proactive line items to delete
    * @param a list of proactive fields
    */
	public static void insertProactiveItems(List<Proactive_Rule_Line_Item__c> insertProactiveItems, List<String> proactiveItemFieldList)
	{
		Util.checkCRUD_FLS('Proactive_Rule_Line_Item__c', proactiveItemFieldList, Constants.DML_OPERATION_INSERT);
		insert insertProactiveItems;
	}
	
	/**
    * @description : This method update proactive line items 
    * @param a list of proactive line items to update
    * @param a list of proactive fields
    */
	public static void updateProactiveItems(List<Proactive_Rule_Line_Item__c> updateProactiveItems, List<String> proactiveItemFieldList)
	{
		Util.checkCRUD_FLS('Proactive_Rule_Line_Item__c', proactiveItemFieldList, Constants.DML_OPERATION_UPDATE);
		update updateProactiveItems;
	}
	
	/**
    * @description : This method deletes proactive line items 
    * @param a list of proactive line items to delete
    */
	public static void deleteProactiveItems(List<Proactive_Rule_Line_Item__c> deleteProactiveItems)
	{
		Util.checkCRUD_FLS('Proactive_Rule_Line_Item__c', null, Constants.DML_OPERATION_DELETE);
		delete deleteProactiveItems;
	}
	
	/**
    * @description : This method inserts proactive cases 
    * @param a list of proactive line items to delete
    * @param a list of proactive fields
    */
	public static void insertProactiveCase(List<Proactive_Case_Setup__c> insertProactiveCases, List<String> proactiveCaseFieldList)
	{
		Util.checkCRUD_FLS('Proactive_Case_Setup__c', proactiveCaseFieldList, Constants.DML_OPERATION_INSERT);
		insert insertProactiveCases;
	}
	
	/**
    * @description : This method updates proactive cases
    * @param a list of proactive cases to update
    * @param a list of proactive case fields
    */
	public static void updateProactiveCase(List<Proactive_Case_Setup__c> updateProactiveCases, List<String> proactiveCaseFieldList)
	{
		Util.checkCRUD_FLS('Proactive_Case_Setup__c', proactiveCaseFieldList, Constants.DML_OPERATION_UPDATE);
		update updateProactiveCases;
	}
	
	/**
    * @description : This method deletes proactive cases 
    * @param a list of proactive cases to delete
    */
	public static void deleteProactiveCase(List<Proactive_Case_Setup__c> deleteProactiveCases)
	{
		Util.checkCRUD_FLS('Proactive_Case_Setup__c', null, Constants.DML_OPERATION_DELETE);
		delete deleteProactiveCases;
	}
}