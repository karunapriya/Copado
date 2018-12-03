/**
 * Created Date		: Oct 20, 2016
 * Developed By		: Sheetal, Comity Designs, Inc.
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
 * admin					User Story				Oct 20, 2016			1.1					@description
 *
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Comity Designs, Inc. 2016 - All Rights Reserved.
 */
@isTest
private class REN_AsyncOppResolutionRRBatchTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */  
	static testMethod void myUnitTest() {
        Test.startTest();
	        REN_TestDataSetup batchData=new REN_TestDataSetup();
	        batchData.renewBatchData();
	        
	        REN_Renewal_Processing_Status__c R=[select id from REN_Renewal_Processing_Status__c limit 1];
        	system.assert(R!=null);
        	
        	Product2 p=[select id from Product2 limit 1]; 
        	
			Opportunity oppty = [select id from opportunity limit 1];
			List<OpportunityLineItem> oli = [select id from OpportunityLineItem where OpportunityId = :oppty.id];
			
			oli[0].REN_Source_Opportunity_Line_Item_Id__c = oli[1].id;
			update oli;
			
			Asset assetRecord = [select id from asset limit 1];
			system.assert(assetRecord != null);
			
			List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
			fMappingList.add(REN_TestDataUtility.createFieldMapping('Renewal Relationship → Opportunity Line Item', 'DOUBLE', 'Quantity', 'REN_Quantity__c', 'OpportunityLineItem', 'REN_Renews_To__c', false, ''));
	        //fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'UnitPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
	        fMappingList.add(REN_TestDataUtility.createFieldMapping('Renewal Relationship → Opportunity Line Item', 'DOUBLE', 'TotalPrice', 'REN_Total_Price__c', 'OpportunityLineItem', 'REN_Renews_To__c', false, ''));
	        REN_FieldMappingsDataAccess.upsertFieldMappings(fMappingList);
			system.assert(fMappingList!=null);
			
			List<REN_Line_Processing_Status__c> lineProcessingStatus = new List<REN_Line_Processing_Status__c>();
			REN_Line_Processing_Status__c lobj=new REN_Line_Processing_Status__c();
			lobj.REN_Failure_Msg__c='testing';
	        lobj.REN_Asset_RLI_Qualified__c=true;
	        lobj.REN_Renewal_Asset_RLI_Id__c=null;
	        lobj.REN_OLI_Qualified__c=false;
	        lobj.REN_Failure__c=false;
	        lobj.REN_Product__c=p.id;
        	lobj.REN_Renewal_OLI_Id__c=oli[0].id;
			lobj.REN_Renewal_Processing_Status__c=R.id;
            lobj.REN_Renewal_Asset_Id__c=assetRecord.id;
            lobj.REN_Source_OLI_Id__c=oli[1].id;	
			lineProcessingStatus.add(lobj);
			insert lineProcessingStatus;
        	system.assert(lineProcessingStatus!=null);
						    
	        Database.executeBatch(new REN_AsyncOppResolutionRRBatch(),2);
        Test.stopTest();
	}
	
	static testMethod void myUnitTest1() {
        Test.startTest();
	        REN_TestDataSetup batchData=new REN_TestDataSetup();
	        batchData.renewBatchData();
	        
	        Product2 p=[select id from Product2 limit 1]; 
	        SS_Constants.isSimplifiedDataModelEnabled = true;
	        
	        REN_Renewal_Processing_Status__c R=[select id from REN_Renewal_Processing_Status__c limit 1];
        	system.assert(R!=null);
        	
			Opportunity oppty = [select id from opportunity limit 1];
			List<OpportunityLineItem> oli = [select id from OpportunityLineItem where OpportunityId = :oppty.id];
			List<REN_Line_Processing_Status__c> lineProcessingStatus = new List<REN_Line_Processing_Status__c>();
			
			Asset assetRecord = [select id from asset limit 1];
			system.assert(assetRecord != null);
			
			List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
			fMappingList.add(REN_TestDataUtility.createFieldMapping('Opportunity Line Item → Renewal Relationship', 'DOUBLE', 'REN_Quantity__c','Quantity', 'REN_Renews_To__c', 'OpportunityLineItem', false, ''));
	        //fMappingList.add(REN_TestDataUtility.createFieldMapping(REN_Constants.FLD_MAP_ASSET_TO_OPPT, 'DOUBLE', 'UnitPrice', 'Price', 'OpportunityLineItem', 'Asset', true, ''));
	        fMappingList.add(REN_TestDataUtility.createFieldMapping('Opportunity Line Item → Renewal Relationship', 'DOUBLE', 'REN_Total_Price__c' ,'TotalPrice', 'REN_Renews_To__c', 'OpportunityLineItem', false, ''));
	        REN_FieldMappingsDataAccess.upsertFieldMappings(fMappingList);
	        system.assert(fMappingList != null);
			
			REN_Line_Processing_Status__c lobj=new REN_Line_Processing_Status__c();
			lobj.REN_Failure_Msg__c='testing';
	        lobj.REN_Asset_RLI_Qualified__c=true;
	        lobj.REN_Renewal_Asset_RLI_Id__c=null;
	        lobj.REN_OLI_Qualified__c=true;
	        lobj.REN_Failure__c=false;
	        lobj.REN_Product__c=p.id;
        	lobj.REN_Renewal_OLI_Id__c=oli[0].id;
			lobj.REN_Renewal_Processing_Status__c=R.id;
            lobj.REN_Renewal_Asset_Id__c=assetRecord.id;
            lobj.REN_Source_OLI_Id__c=oli[0].id;	
            lobj.REN_Renewal_Contract_Line_Item_Id__c = p.id;
			lineProcessingStatus.add(lobj);
			insert lineProcessingStatus;
        	system.assert(lineProcessingStatus!=null);
						    
	        Database.executeBatch(new REN_AsyncOppResolutionRRBatch(),2);
        Test.stopTest();
	}
}