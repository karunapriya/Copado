/**
 * Created Date		: Aug 28, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
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
 * Dilip					User Story				Aug 28, 2018			1.1					@description
 *
 */
@isTest
public with sharing class REN_BulkUpdateCtrlTest {
	@testSetup 
    static void setup() {
    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(3, accountList[0].id);
        String solExtNameSpace = CSM_Util.nameSpacePrefixSolnExtn;
        insert new REN_Custom_Search_Config__c(REN_Mass_Update_FieldSet_Name__c = solExtNameSpace + 'REN_Opportunity_Mass_Update', REN_RS_Request_Limit_Threshold__c = 1000, Name = 'Opportunity', REN_Parent_Object__c = 'Opportunity');
    
    	REN_RS_Config__c rsConfig = new REN_RS_Config__c(REN_Flow_Name__c = 'Mass Update', REN_Invoking_Object__c = 'Opportunity', REN_RS_Request_Timeout_Limit__c = 3000, REN_Named_Credential__c = 'Test', REN_Named_Credential_URL_Extension__c = 'Test');
        insert rsConfig;
    }
    
    public static testmethod void updateOppty(){
        ApexPages.currentPage().getParameters().put('objectName', 'Opportunity');
        ApexPages.currentPage().getParameters().put('updateAllRecords', 'true');
        REN_BulkUpdateCtrl bulkUpdateObj = new REN_BulkUpdateCtrl();
        system.assert(bulkUpdateObj != null);
        bulkUpdateObj.selectedObject = Schema.getGlobalDescribe().get('opportunity').newSObject();
        bulkUpdateObj.selectedObject.put('OwnerId', UserInfo.getUserId());
        bulkUpdateObj.selectedRecords = '';
        for(Opportunity opp : [select id from opportunity]){
            bulkUpdateObj.selectedRecords = bulkUpdateObj.selectedRecords + opp.Id + '-';
        }
        system.assert(bulkUpdateObj.selectedRecords != null);
        bulkUpdateObj.setRecords();
        bulkUpdateObj.updateRecords();
    }
}