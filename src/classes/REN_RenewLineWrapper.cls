/**
 * Created Date		: Jul 21, 2017
 * Developed By		: Dheeraj, Comity Designs, Inc.
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
 * Dheeraj					US2551				Jul 21, 2017			1.1					@description
 * 
 */
public with sharing class REN_RenewLineWrapper {
	public REN_Renews_To__c renewLine {get; set;}
	public Integer customId {get;set;}
	public Boolean isSelected {get; set;} 
	public String sourceOpptId {get; set;}
	public String sourceOpptLnId {get; set;}
	public String renewProduct {get; set;}
	public String product2Id{get;set;}
    public String typeOfRli{get;set;}
}