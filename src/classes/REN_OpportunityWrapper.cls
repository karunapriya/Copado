/**
 * Created Date		: Feb 1, 2017
 * Developed By		: Dheeraj, Comity Designs, Inc.
 *
 * Function			: @description - wrapper for Lightning component LT
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj					US2031				Feb 1, 2017			1.1					wrapper for Lightning component LT
 *
 */
public with sharing class REN_OpportunityWrapper {
    
   @AuraEnabled
   public String FieldName;
   @AuraEnabled
   public String FieldValue;
   @AuraEnabled
   public String FieldLabel;
   @AuraEnabled
   public String SSNameSpace;
   @AuraEnabled
   public String BaseURL;
   @AuraEnabled
   public String QuotePDF;
   @AuraEnabled
   public String type=null; 
}