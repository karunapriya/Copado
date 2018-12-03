/**
 * Created Date		: Jan 19, 2018
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
 * Chandra					User Story				Jan 19, 2018			1.1					@description
 * 
 */
 @isTest
public with sharing class OpportunityCreateNewExtensionTest {
	@isTest
    static void testOpportunityCreateNewExtension(){
    	OpportunityCreateNewExtension ctrl = new OpportunityCreateNewExtension(null);
    	ctrl.redirect();
    	SS_TriggerCollectionParameters.OpportunityTriggerParams paramObj = new SS_TriggerCollectionParameters.OpportunityTriggerParams();
        OpportunityUtils.updateCaseClosedAutomatically(paramObj);
        System.assertEquals(true, ctrl != null);
    }
}