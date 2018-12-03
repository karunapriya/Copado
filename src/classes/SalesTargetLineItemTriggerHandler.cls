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
 * Comity Designs, Inc. 2016 - All Rights Reserved.
 */

public with sharing class SalesTargetLineItemTriggerHandler extends TriggerManager.TriggerHandler {
	public override void onBeforeInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap){
		SalesTargetLineItemTriggerHelper.setFieldsOnBeforeInsert((List<Sales_Target_Line_Item__c>)newRecords);
    }
}