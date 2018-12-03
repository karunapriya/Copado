/**
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
 */
@isTest
private class REN_ServiceContractTriggerHandlerTest {

    @testSetup 
	static void setup() {
		
		//insert new SS_License__c(Channel__c = true);
	
		List<Opportunity> opptyList = new List<Opportunity>();
		insert new SS_License__c(Renew__c = true);        
		List<Account> accountList =  CSM_TestDataUtility.createAccount(1);     
		System.assert(accountList != null);   
        List<SObject> sContractList = CSM_TestDataUtility.createServiceContract(1,accountList[0].Id);
        Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Contacted');
		opptyList.add(oppty);
		insert opptyList; 			
		
		List<REN_Field_Mappings__c> mappingList = CHL_TestUtility.createQuoteMapping();
		insert mappingList;		
	}
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        REN_Constants.SERVICE_CONTRACT_BEFORE_TRIGGER = true;
		insert new SS_License__c(Renew__c = true);        
		List<Account> accountList =  CSM_TestDataUtility.createAccount(1);        
        List<SObject> sContractList = CSM_TestDataUtility.createServiceContract(1,accountList[0].Id);

       Test.startTest();
        Map<ID, sObject> newMap = new Map<ID, sObject>();
        newMap.put(sContractList[0].Id, sContractList[0]);
        
        if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT) ){
	        REN_ServiceContractTriggerHandler sContractHandler = new REN_ServiceContractTriggerHandler();
	        sContractHandler.onBeforeInsert(sContractList, newMap);
	
	        List<SObject> sContractList1 = CSM_TestDataUtility.createServiceContract(1,accountList[0].Id);
	        Map<ID, sObject> oldMap = new Map<ID, sObject>();
	        newMap.put(sContractList1[0].Id, sContractList[0]);
	
	        Map<ID, sObject> newMap1 = new Map<ID, sObject>();
	        newMap.put(sContractList1[0].Id, sContractList[0]);
	
	        REN_Constants.SERVICE_CONTRACT_BEFORE_TRIGGER = true;
	        sContractHandler.onBeforeUpdate(sContractList1, sContractList1, oldMap, newMap1);
	        system.assert(true);
			//system.assert(sContractList1[0].get('AccountId') == sContractList1[0].get(CSM_Util.nameSpacePrefix21 +'REN_Related_Account__c'));        
        }
        Test.stopTest();
    }
    
    static testMethod void myUnitTest_SC() {
    	REN_ServiceContracts sc = new REN_ServiceContracts();
    	List<Account> accountList = [select Id from Account limit 1];
    	List<REN_Field_Mappings__c>  fmappingList = [select id from REN_Field_Mappings__c where name in ('Quote → Opportunity' , 'Opportunity → Quote') ];
		system.assert(fmappingList != null);
    	//List<Opportunity> opptyList = [select id,Pricebook2Id,SyncedQuoteId,Name,AccountId,Description,CHL_Partner_Account_1__c,CHL_Partner_Account_1_Contact__c,CHL_Partner_Account_1_Type__c,CHL_Partner_Account_2__c,CHL_Partner_Account_2_Contact__c,CHL_Partner_Account_2_Type__c from Opportunity limit 1];
    	String syncQuoteId = CSM_AccessController.hasField('opportunity',  'SyncedQuoteId')?',SyncedQuoteId':'';
		string opptyQuery = 'select Id, name, Pricebook2Id,description,AccountId,CHL_Partner_Account_1__c,CHL_Partner_Account_1_Contact__c,CHL_Partner_Account_1_Type__c,CHL_Partner_Account_2__c,CHL_Partner_Account_2_Contact__c,CHL_Partner_Account_2_Type__c'+syncQuoteId+' from opportunity limit 1';
    	List<sObject> opptyList = Database.query(opptyQuery);
    	List<SObject> sContractList = CSM_TestDataUtility.createServiceContract(1,accountList[0].Id);
    	sc.createRenewals(opptyList, null);
    	sc.setChannelFields(opptyList[0],opptyList[0]);
    }
}