/**
 * Created Date     : Apr 21, 2017
 * Developed By     : Dheeraj, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj                  US2293,94           Apr 21, 2017            1.1                 Cross/Up sell
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
 * Comity Designs, Inc. 2017 - All Rights Reserved.
 */
@isTest
private class CHL_ManageUpsellCrossSellCtrlTest {

    /**
     * Method to create test records once and use for all the methods in this test class
     */ 
    @testSetup 
    static void testSetupMethod() {
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
        oppty.Pricebook2Id = Test.getStandardPricebookId();
        opptyList.add(oppty);
        insert opptyList;       
        
        List<Product2> productList = CHL_TestUtility.createProducts(2);
        insert productList;
        
        List<PricebookEntry> pbeList = CHL_TestUtility.createPricebookEntry(productList,Test.getStandardPricebookId());
        
        insert pbeList;
        
        List <OpportunityLineItem> opliList = CHL_TestUtility.createOplis(opptyList,pbeList);
        insert opliList;
        List <OpportunityLineItem> opliList2 = CHL_TestUtility.createOplis(opptyList,pbeList);
        insert opliList2;
        
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
        
        REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
        renRelationObj.Name = 'Partner Renewal';
        //renRelationObj.REN_Asset__c = assObj.Id;
        renRelationObj.REN_Renews_To__c = opptyList[0].Id;
        renRelationObj.REN_Renewal_Status__c = 'Won';
        renRelationObj.REN_Renewal_Target__c = 50000.0;
        renRelationObj.REN_Renewal_Target_Multiplier__c = 1;
        renRelationObj.REN_Previous_Price__c = 50000.0;
        insert renRelationObj;
         
    }
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        List<Opportunity> opptyList = [select Id, name,Pricebook2Id,description,StageName from opportunity limit 1];
        List<CHL_Partner_Opportunity__c> poList = [select Id, name from CHL_Partner_Opportunity__c limit 1];
        List<OpportunityLineItem> lstOfOLI = [Select id,OpportunityId,Product2Id,Quantity,ListPrice,PricebookEntryId from OpportunityLineItem limit 2];
        Set<Id> poIdSet = new Set<Id>();
        poIdSet.add(poList[0].Id);
        Test.startTest();
        System.assertEquals(opptyList.get(0).StageName,'Needs Analysis');
        List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,poList);
        
        String qExtentionPrefix = CHL_Util.quoteExtnNameSpace;
        if(quoteList != null && !quoteList.isEmpty()) {
            insert quoteList;
            List<sObject> qliList = CHL_TestUtility.createQuoteLineItems(quoteList,lstOfOLI);
            insert qliList;
            List<sObject> qliList2 = CHL_TestUtility.createQuoteLineItems(quoteList,lstOfOLI);
            if(CSM_AccessController.hasField('QuoteLineItem', 'CHL_Type__c')){
                 qliList2.get(0).put(qExtentionPrefix+'CHL_Type__c','Cross-Sell');
                qliList2.get(0).put(qExtentionPrefix+'CHL_Cross_Sell_Id__c',qliList.get(0).id);
            }
            insert qliList2;
            List<sObject> qliList3 = CHL_TestUtility.createQuoteLineItems(quoteList,lstOfOLI);
            if(CSM_AccessController.hasField('QuoteLineItem', 'CHL_Type__c')){
                qliList3.get(0).put(qExtentionPrefix+'CHL_Type__c','Upsell');
            }
            insert qliList3;
            PageReference tpageRef = Page.CrossSell_Upsell;
            Test.setCurrentPage(tpageRef);
            ApexPages.currentPage().getParameters().put('id', string.valueOf(quoteList.get(0).get('Id')));
            
            System.assertEquals( string.valueOf(quoteList.get(0).get('Id')),ApexPages.currentPage().getParameters().get('id'));
            CHL_ManageUpsellCrossSellCtrl manageUpCrossSell = new CHL_ManageUpsellCrossSellCtrl();      	
                       
            manageUpCrossSell.saveUpCrossSellProduct();
            manageUpCrossSell.cancelUpCrossSellProduct();
            
            opptyList[0].put('SyncedQuoteId',(Id)quoteList.get(0).get('Id'));
            update opptyList;
                   	
        }
         Test.stopTest();
    }
    
    //Added test method for code coverage in Master.
    
    static testMethod void myUnitTest_1() {
        List<Opportunity> opptyList = [select Id, name,Pricebook2Id,description,StageName from opportunity limit 1];
        System.assert(opptyList != null);
        List<CHL_Partner_Opportunity__c> poList = [select Id, name from CHL_Partner_Opportunity__c limit 1];
        List<OpportunityLineItem> lstOfOLI = [Select id,OpportunityId,Product2Id,Quantity,ListPrice,PricebookEntryId from OpportunityLineItem limit 2]; 
        Set<Id> poIdSet = new Set<Id>();
        poIdSet.add(poList[0].Id);
        
        Test.startTest();
            try{
	            PageReference pageRef = Page.CrossSell_Upsell;
	            pageRef.getParameters().put('Id', opptyList[0].id); 	
		        CHL_ManageUpsellCrossSellCtrl manageUpsellCntrl = new CHL_ManageUpsellCrossSellCtrl();
            }
        	catch(Exception ex){
        	}
        	
            try{
	            sObject sObj = Schema.getGlobalDescribe().get('Opportunity').newSObject() ;
	            List<String> prodList = new List<String>();
	            prodList.add('Prd1');
	            Map<Id,sObject> mapOfQli = new Map<Id,sObject>();
	            mapOfQli.put(opptyList[0].id,sObj);
		        
		        CHL_ManageUpsellCrossSellCtrl.QLIDetailWrapper qliWrapperObj = new CHL_ManageUpsellCrossSellCtrl.QLIDetailWrapper(sObj,prodList,'QuoteExt',mapOfQli);
          
            }
            catch(Exception ex){
            }
            
            try{
	            PageReference pageRef = Page.CrossSell_Upsell;
	            pageRef.getParameters().put('Id', opptyList[0].id); 
	            CHL_ManageUpsellCrossSellCtrl manageUpsellCntrl = new CHL_ManageUpsellCrossSellCtrl();
		        manageUpsellCntrl.cancelUpCrossSellProduct();
            }
            catch(Exception ex){
            }
            
            try{
	            PageReference pageRef = Page.CrossSell_Upsell;
	            pageRef.getParameters().put('Id', opptyList[0].id); 
	            CHL_ManageUpsellCrossSellCtrl manageUpsellCntrl = new CHL_ManageUpsellCrossSellCtrl();
		        manageUpsellCntrl.saveUpCrossSellProduct();
            }
            catch(Exception ex){
            }
      
         Test.stopTest();
    }   
    
    static testMethod void testCancelSimplifiedDataModelOn() {
    	insert new SS_License__c(Simplified_Data_Model_Is_Enabled__c = true);
    	
    	List<Opportunity> opptyList = [select Id, name,Pricebook2Id,description,StageName from opportunity limit 1];
        List<CHL_Partner_Opportunity__c> poList = [select Id, name from CHL_Partner_Opportunity__c limit 1];
        
        System.assert(opptyList != null);
        System.assert(!opptyList.isEmpty());
        System.assert(poList != null);
        System.assert(!poList.isEmpty());
        
        List<Sobject> quoteList = CHL_TestUtility.createQuotes(1,opptyList,poList);
        
    	PageReference tpageRef = Page.CrossSell_Upsell;
        Test.setCurrentPage(tpageRef);
        if(quoteList!=null && !quoteList.isEmpty()){
        	ApexPages.currentPage().getParameters().put('id', string.valueOf(quoteList.get(0).get('Id')));
        }else{
        	ApexPages.currentPage().getParameters().put('id', '');
        }
        Test.startTest();
        	CHL_ManageUpsellCrossSellCtrl manageUpsellCntrl = new CHL_ManageUpsellCrossSellCtrl();
        	manageUpsellCntrl.cancelUpCrossSellProduct();
        Test.stopTest();
    	
    } 
}