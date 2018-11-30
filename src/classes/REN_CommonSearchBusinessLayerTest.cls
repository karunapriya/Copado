@isTest
public with sharing class REN_CommonSearchBusinessLayerTest {
	@testSetup 
	static void setup() { 
		List<Account> accountList = CSM_TestDataUtility.createAccount(1);
		List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(3, accountList[0].id);
		system.assert(accountList != null);
    }
    
	static testMethod void cSearchBusinessLayerTestWithFieldSet() {
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
    	qp.fieldSetName =  CSM_Util.getNamespace()+'REN_Opportunity_Split';
    	CSM_CustomGridInputWrapper gridObj = new CSM_CustomGridInputWrapper();
		gridObj.params =  qp;
		REN_CommonSearchBusinessLayer commonSearchLayerObj = new REN_CommonSearchBusinessLayer(gridObj);
		CSM_GridResponseWrapper resObj = commonSearchLayerObj.retrieveSObjectWrapperList();
    	system.assert(commonSearchLayerObj != null);
    }
    
    static testMethod void cSearchBusinessLayerTestWithoutFieldSet() {
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
    	qp.fieldSetName = '';
    	CSM_CustomGridInputWrapper gridObj = new CSM_CustomGridInputWrapper();
		gridObj.params =  qp;
		REN_CommonSearchBusinessLayer commonSearchLayerObj = new REN_CommonSearchBusinessLayer(gridObj);
		CSM_GridResponseWrapper resObj = commonSearchLayerObj.retrieveSObjectWrapperList();
		system.assert(commonSearchLayerObj != null);
    	
    }
}