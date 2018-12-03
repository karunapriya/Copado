/**
 * Created Date		: Sep 20, 2016
 * Developed By		: Chandra, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Chandra					User Story				Sep 20, 2016			1.1					@description
 * 
 */
public with sharing class SalesTargetLineItemTriggerHelper {

   public static void setFieldsOnBeforeInsert(List<Sales_Target_Line_Item__c> newRecords){
   		Set<ID> parentIdSet = new Set<ID>();
   		for(Sales_Target_Line_Item__c tli: newRecords){
   			parentIdSet.add(tli.Sales_Target__c);
   		}
   		Map<Id, Sales_Target__c> salesTargetsMap = SalesTargetDataAccess.getSalesTargetsByID(parentIdSet);
   		for(Sales_Target_Line_Item__c tli: newRecords){
   			tli.CurrencyIsoCode = (String)salesTargetsMap.get(tli.Sales_Target__c).CurrencyIsoCode;
   		}
   }
    
}