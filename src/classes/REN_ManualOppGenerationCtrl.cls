/**
 * Created Date		: Nov 13, 2017
 * Developed By		: Dheeraj Vashist, Comity Designs, Inc.
 *
 * Function			: @description - To access SDM & None SDM Functionality in Entitlement package.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj Vashist					User Story				Nov 13, 2017			1.1					Ent Ext Manual opp generation
 * 
 */
global with sharing class REN_ManualOppGenerationCtrl {

    global Boolean sdmFlag {get;set;}
    global String namespace{get;set;}
    global REN_ManualOppGenerationCtrl(){
        sdmFlag =false;
        namespace= '';
        SS_License__c ssLicense = SS_License__c.getOrgDefaults();
        if(ssLicense!=null){
          sdmFlag = ssLicense.Simplified_Data_Model_Is_Enabled__c;
          namespace = CSM_Util.getNamespace();
        }
         
    }
}