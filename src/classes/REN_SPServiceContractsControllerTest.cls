@isTest(SeeAllData=true)
private class REN_SPServiceContractsControllerTest {
      public static Boolean hasRenewAccess;
      public static Boolean isEntitlementEnabled;
      public static List<SObject> serviceContractObjList;
      private static Id testAccountId;
      private static  Id opportunityId;
   
    static testMethod void myUnitTest() {
        
        isEntitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
        
        if(isEntitlementEnabled != null && isEntitlementEnabled){
            DataSetup();
            REN_SPServiceContractsController controller = new REN_SPServiceContractsController();
            controller.acctId = testAccountId;
            system.debug('\n\n $$$ acctId :' +controller.acctId);
            controller.sortExpression = 'Name';
            controller.sortDirection =  'ASC';
            controller.retrieveSCForAccount();
            controller.getThis();
        }
        
    }
    
    static void DataSetup() {
            
            List<Account> accList = CSM_TestDataUtility.createAccount(1);
            system.assert(accList.get(0).Id != null);
       
            Product2 prod = REN_TestDataUtility.createProduct(1);
            insert prod;
            system.assert(prod.Id != null);
            
            String accId = string.valueof(accList[0].Id);
            testAccountId = accId;
            
            serviceContractObjList = CSM_TestDataUtility.createServiceContract(2,accId);
            
            Opportunity opport = new Opportunity();
            opport.AccountId = testAccountId;
            opport.StageName = 'Prospecting';
            opport.CloseDate = System.today();
            opport.Name = 'Opportunity Test';
            insert opport;
            
            Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
            PricebookEntry pbe =  new PricebookEntry(Pricebook2Id = standardPB.Id, product2id = prod.id, unitprice=1.0, isActive=true);
            insert pbe; 
            
            OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = opport.id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = pbe.Id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
		    insert opptyLineItem;
            
            SObject contractLineItemObj = CSM_AccessController.newSObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
            contractLineItemObj.put('Quantity', 1);
            contractLineItemObj.put('ServiceContractId', serviceContractObjList[0].id);
            contractLineItemObj.put('PricebookEntryId',pbe.id);
            contractLineItemObj.put('UnitPrice',10);
            insert contractLineItemObj;
            
            SObject renRelationObj = new REN_Renews_To__c();
            renRelationObj.put('Name', 'Ren-OPP');
            if(CSM_AccessController.hasField('REN_Renews_To__c', CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c'))
            {
                renRelationObj.put(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c', serviceContractObjList[0].id);
            }
            renRelationObj.put('REN_Renews_To__c', opport.id);
            //renRelationObj.put('REN_Renewal_Product_Line_Id__c', opptyLineItem.Id);
            renRelationObj.put('REN_Product__c', prod.id);
            
            insert renRelationObj;
            system.assert(renRelationObj != null);
      
    }
}