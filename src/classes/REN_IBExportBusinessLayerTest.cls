/**
 * Created Date		: May 10, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
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
 * Bhagyashri					User Story				May 10, 2018			1.1					@description
 *
 */
 
@isTest
public with sharing class REN_IBExportBusinessLayerTest {

	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
	@testSetup 
	static void setup() {
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(3, accountList[0].id);
		system.assert(accountList != null);
	}
	
    static testMethod void IBExportBusinessLayerTestWithFieldSet() {
       setup();
       List<Opportunity> OppList = [Select id from Opportunity];
	   List<String> oppSet = new List<String>();
	   String oppId;
	   for(Opportunity opp : OppList){
	   		oppSet.add((String)opp.id);
	   }
	   CSM_CustomGridInputWrapper.CSM_CustomGridParams qp = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
       qp.IdSet = oppSet;
       qp.objectName = 'Opportunity';
       qp.responseStr = '{"@odata.context":"http://sqa.dev.ssi-cloud.com/odata/frb1/dell_report/$metadata#app_coveredassets(Data_Prot_End_Fiscal_Quarter,Advisory_Sku,Id)","value":[{"Id":"54d1c0f9e4b0ff5e2a14c428","Data_Prot_End_Fiscal_Quarter":"Test1","Advisory_Sku":"Test1"},{"Id":"54d1c0aee4b09726c27445c4","Data_Prot_End_Fiscal_Quarter":"Test2","Advisory_Sku":"Test2"},{"Id":"54d1c0aee4b09726c27445cc","Data_Prot_End_Fiscal_Quarter":"FY16Q2","Advisory_Sku":"Test3"},{"Id":"54d1c0aee4b09726c27445d1","Data_Prot_End_Fiscal_Quarter":"Test4","Advisory_Sku":"Test4"},{"Id":"54d1c0aee4b09726c27445d8","Data_Prot_End_Fiscal_Quarter":"Test5","Advisory_Sku":"Test5"},{"Id":"54d1c0aee4b09726c27445e6","Data_Prot_End_Fiscal_Quarter":"Test6","Advisory_Sku":"Test6"},{"Id":"54d1c0aee4b09726c27445f9","Data_Prot_End_Fiscal_Quarter":"Test7","Advisory_Sku":"Test7"},{"Id":"54d1c0aee4b0ff5e2a14a3a9","Data_Prot_End_Fiscal_Quarter":"Test8","Advisory_Sku":"Test8"},{"Id":"54d1c0aee4b0ff5e2a14a3b5","Data_Prot_End_Fiscal_Quarter":"Test9","Advisory_Sku":"Test9"},{"Id":"54d1c0aee4b0ff5e2a14a3c1","Data_Prot_End_Fiscal_Quarter":"Test10","Advisory_Sku":"Test10"}]}';
       qp.fieldSetName =  CSM_Util.getNamespace()+'REN_Opportunity_Split';
       CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
	   inputWrapper.params =  qp;
       REN_IBExportBusinessLayer IBExportLayer =  new REN_IBExportBusinessLayer(inputWrapper);
       CSM_GridResponseWrapper resObj = IBExportLayer.retrieveSObjectWrapperList();
       system.assert(IBExportLayer != null);
        
        
    }
    
    
    static testMethod void IBExportBusinessLayerTestWithoutFieldSet() {
		List<Opportunity> OppList = [Select id from Opportunity];
		List<String> oppSet = new List<String>();
		String oppId;
		system.debug('@@ OppList :: ' + OppList);
		for(Opportunity opp : OppList){
			oppSet.add((String)opp.id);
		}
		
		CSM_CustomGridInputWrapper.CSM_CustomGridParams qp = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
    	qp.IdSet = oppSet;
    	qp.objectName = 'Opportunity';
        qp.responseStr = '{"@odata.context":"http://sqa.dev.ssi-cloud.com/odata/frb1/dell_report/$metadata#app_coveredassets(Data_Prot_End_Fiscal_Quarter,Advisory_Sku,Id)","value":[{"Id":"54d1c0f9e4b0ff5e2a14c428","Data_Prot_End_Fiscal_Quarter":"Test1","Advisory_Sku":"Test1"},{"Id":"54d1c0aee4b09726c27445c4","Data_Prot_End_Fiscal_Quarter":"Test2","Advisory_Sku":"Test2"},{"Id":"54d1c0aee4b09726c27445cc","Data_Prot_End_Fiscal_Quarter":"FY16Q2","Advisory_Sku":"Test3"},{"Id":"54d1c0aee4b09726c27445d1","Data_Prot_End_Fiscal_Quarter":"Test4","Advisory_Sku":"Test4"},{"Id":"54d1c0aee4b09726c27445d8","Data_Prot_End_Fiscal_Quarter":"Test5","Advisory_Sku":"Test5"},{"Id":"54d1c0aee4b09726c27445e6","Data_Prot_End_Fiscal_Quarter":"Test6","Advisory_Sku":"Test6"},{"Id":"54d1c0aee4b09726c27445f9","Data_Prot_End_Fiscal_Quarter":"Test7","Advisory_Sku":"Test7"},{"Id":"54d1c0aee4b0ff5e2a14a3a9","Data_Prot_End_Fiscal_Quarter":"Test8","Advisory_Sku":"Test8"},{"Id":"54d1c0aee4b0ff5e2a14a3b5","Data_Prot_End_Fiscal_Quarter":"Test9","Advisory_Sku":"Test9"},{"Id":"54d1c0aee4b0ff5e2a14a3c1","Data_Prot_End_Fiscal_Quarter":"Test10","Advisory_Sku":"Test10"}]}';
		qp.fieldSetName = '';
    	CSM_CustomGridInputWrapper inputWrapper = new CSM_CustomGridInputWrapper();
		inputWrapper.params =  qp;
		REN_IBExportBusinessLayer IBExportLayer = new REN_IBExportBusinessLayer(inputWrapper);
		CSM_GridResponseWrapper resObj = IBExportLayer.retrieveSObjectWrapperList();
		system.assert(IBExportLayer != null);
    	
    }
}