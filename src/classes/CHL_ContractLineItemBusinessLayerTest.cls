@isTest
public with sharing class CHL_ContractLineItemBusinessLayerTest {
	
	@testSetup static void setup() {
		insert new SS_License__c(Channel__c = true);
	
		List<Account> accountList = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		List<Opportunity> opptyList = new List<Opportunity>();
		List<CHL_Partner_Opportunity__c> chlpartnerList = new List<CHL_Partner_Opportunity__c>();
	
		Account acc =  CHL_TestUtility.partnerAccount();
		accountList.add(acc);
		insert accountList;
		System.assert(accountList != null);
	
		Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
		contactList.add(con);
		insert contactList;
	
		Opportunity oppty =  CHL_TestUtility.partnerOpportunity(accountList[0].id,'Needs Analysis');
		opptyList.add(oppty);
		insert opptyList; 			
		
		List<Product2> productList = CHL_TestUtility.createProducts(2);
		insert productList;
		
		List<PricebookEntry> pbeList = CHL_TestUtility.createPricebookEntry(productList,Test.getStandardPricebookId());
		insert pbeList;
		
		List <OpportunityLineItem> opliList = CHL_TestUtility.createOplis(opptyList,pbeList);
		insert opliList;
		
		List<REN_Field_Mappings__c> mappingList = CHL_TestUtility.createQuoteMapping();
		insert mappingList;
		
		CHL_TestUtility.WrapperPartnerOpportunity partOppty = new CHL_TestUtility.WrapperPartnerOpportunity();
		partOppty.partnerAcc1Id = accountList[0].id;
		partOppty.partnerAcc1Type = 'Reseller';
		partOppty.contact1Id = contactList[0].Id;
		partOppty.expirationDate = system.today().addDays(-10);
		partOppty.Stage = 'Qualification';
		partOppty.partnerAcc2Id = accountList[0].id;
		partOppty.partnerAcc2Type = 'Distributor';
		partOppty.contact2Id = contactList[0].Id;
		
		List < CHL_Partner_Opportunity__c > chlpartnerList1 = CHL_TestUtility.channelPartnerOpportunityList(1, partOppty);
		insert chlpartnerList1;
	}
	
	
    static testMethod void myUnitTest() {
    	List<CHL_Partner_Opportunity__c> poList = [select Id, name, CHL_Partner_Account_1__c, CHL_Partner_Account_1_Contact__c, CHL_Partner_Account_1_Type__c, CHL_Incumbent__c,CHL_Partner_Account_2__c, CHL_Partner_Account_2_Contact__c,CHL_Partner_Account_2_Type__c from CHL_Partner_Opportunity__c limit 1];
		System.assert(poList !=null);
    	if (CSM_AccessController.hasObject(CHL_Constants.OBJ_SERVICE_CONTRACT))
        	{
                //To create SC Obj.
           		Sobject sCObj = Schema.getGlobalDescribe().get(CHL_Constants.OBJ_SERVICE_CONTRACT).newSObject() ; 
            	sCObj.put('Name', 'SC Test') ; 
            	sCObj.put('AccountId', poList[0].CHL_Partner_Account_1__c) ; 
            	if(CSM_AccessController.hasField(CHL_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1__c')) {
                	sCObj.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1__c', poList[0].CHL_Partner_Account_1__c) ;
           		}
           		if(CSM_AccessController.hasField(CHL_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1_Contact__c')) {
                	sCObj.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1_Contact__c', poList[0].CHL_Partner_Account_1_Contact__c) ;
           		}
           		if(CSM_AccessController.hasField(CHL_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1_Type__c')) {
                	sCObj.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_1_Type__c', poList[0].CHL_Partner_Account_1_Type__c) ;
           		}           		
           		if(CSM_AccessController.hasField(CHL_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2__c')) {
                	sCObj.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2__c', poList[0].CHL_Partner_Account_2__c) ;
           		}
           		if(CSM_AccessController.hasField(CHL_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2_Contact__c')) {
                	sCObj.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2_Contact__c', poList[0].CHL_Partner_Account_2_Contact__c) ;
           		}
           		if(CSM_AccessController.hasField(CHL_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2_Type__c')) {
                	sCObj.put(CSM_Util.nameSpacePrefix21 + 'CHL_Partner_Account_2_Type__c', poList[0].CHL_Partner_Account_2_Type__c) ;
           		}
            	
            	insert sCObj;
         	}
    	CHL_ContractLineItemBusinessLayer abLayer = new CHL_ContractLineItemBusinessLayer(new CHL_GridInputWrapper());
    	CHL_GridInputWrapper.CHL_CustomGridParams qp = new CHL_GridInputWrapper.CHL_CustomGridParams();
    	qp.accountID = poList[0].CHL_Partner_Account_1__c;
    	abLayer.inputWrapper.queryParams = qp;    	
    	CHL_AngularResponeWrapper wrapper = abLayer.constructGridWrapper();
		system.assert(wrapper<>null);
    }

}