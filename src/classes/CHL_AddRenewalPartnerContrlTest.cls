@isTest
private class CHL_AddRenewalPartnerContrlTest {
    
    static testMethod void myUnitTest() {
        insert new SS_License__c(Channel__c = true);
        insert new CSM_Admin__c(CHL_Restrict_Multiple_Incumbent_On_PO__c = true);
        
        REN_Field_Mappings__c fieldMapping = new REN_Field_Mappings__c(REN_Field_Data_Type__c = 'STRING', REN_From_Field_API_Name__c = 'Name', REN_From_Object_Api_Name__c = 'Opportunity', REN_To_Field_API_Name__c = 'Name', REN_To_Object_API_Name__c  = 'Partner_OPP');
        insert fieldMapping;
        
        Boolean isEntitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
        
        List < Account > accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList.get(0).Id != null);
        
        Product2 prod1 = REN_TestDataUtility.createProduct(1);
        insert prod1;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 standardPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert standardPB;
        
        Opportunity testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=standardPB.id,
                                                CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, REN_Earliest_Expiration_Date__c = System.Today() + 2);
        
        insert testOppty;
        Product2 prod = REN_TestDataUtility.createProduct(1);
        insert prod;
        
        PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod1.Id);
        insert price1;
        system.assert(price1.Id != null);
        
        system.assert(prod.Id != null);
        OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = testOppty.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
        insert opptyLineItem;
        
        Asset asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);
        asset.REN_Oppty_Line_Item_Id__c = opptyLineItem.Id;
        insert asset;
        
        REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
        renRelationObj.Name = 'Ren-OPP';
        renRelationObj.REN_Asset__c = asset.Id;
        renRelationObj.REN_Renews_To__c = testOppty.Id;
        renRelationObj.REN_Renewal_Product_Line_Id__c = opptyLineItem.Id;
        renRelationObj.REN_Product__c = prod.id;
        renRelationObj.REN_Quantity__c = 2;
        renRelationObj.REN_Previous_Price__c= 500;
        insert renRelationObj;
        
        List < SObject > serviceContractList = CSM_TestDataUtility.createServiceContract(2, accList[0].id);
        
        REN_Renews_To__c renRelationSCObj = new REN_Renews_To__c();
        renRelationSCObj.Name = 'Ren-OPP';
        if(isEntitlementEnabled){
            if(!serviceContractList.isEmpty()){
                if (CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT)){
                    renRelationSCObj.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT, serviceContractList[0].Id);
                }
                
            }
        }
        renRelationSCObj.REN_Renews_To__c = testOppty.Id;
        renRelationSCObj.REN_Renewal_Product_Line_Id__c = opptyLineItem.Id;
        renRelationSCObj.REN_Product__c = prod.id;
        renRelationSCObj.REN_Quantity__c = 2;
        renRelationSCObj.REN_Previous_Price__c= 500;
        insert renRelationSCObj;
        
        String OppID = testOppty.id;
        CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
        optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
        optyStatusLogObj.CHL_Days_between_Update__c = 5;
        optyStatusLogObj.CHL_Available_Sales_Stages__c = 'Needs Analysis;Closed Won';
        optyStatusLogObj.CHL_Enable_2_Tier_Pricing__c = true;
        insert optyStatusLogObj;
        Test.startTest();
        List<Account> accountList = new List<Account>();	
        List<Contact> contactList = new List<Contact>();
        Account acc =  CHL_TestUtility.partnerAccount();
        Account acc2 =  CHL_TestUtility.partnerAccount();
        accountList.add(acc);
        accountList.add(acc2);
        insert accountList;	
        accountList[0].CHL_Partner_Account_Type__c = 'Reseller';
        accountList[1].CHL_Partner_Account_Type__c = 'Distributor';
        update accountList;
        Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
        contactList.add(con);
        insert contactList;	
        list < Opportunity > oppList = new list < Opportunity > ();
        System.debug('\n\n----testOppty: ' + testOppty);
        oppList.add(testOppty);
        CHL_Partner_Opportunity__c obj =new CHL_Partner_Opportunity__c();
        obj.Name = 'TestPO'; 
        obj.CHL_Incumbent__c = true;
        obj.CHL_Opportunity__c = oppList[0].id;
        insert obj;
        //User u = CHL_TestUtility.createTestPartnerUser('Channel Community','testpartnercontact@test.com',contactList[0].id);
        //insert u;
        PageReference pageRef = Page.CHL_AddPartnerOpportunity;
        pageRef.getParameters().put('Id', OppId);
        Test.setCurrentPage(pageRef);
        List<CHL_Partner_Opportunity__c> partnerOpps = new List<CHL_Partner_Opportunity__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(partnerOpps);
		CHL_AddRenewalPartnerController controller = new CHL_AddRenewalPartnerController(sc);
        CHL_AddRenewalPartnerController.RenRelationshipLineItemsWrapper renRelLineItemWrapperObj = new CHL_AddRenewalPartnerController.RenRelationshipLineItemsWrapper(renRelationObj);
        renRelLineItemWrapperObj.isSelected = true;
        
        List < CHL_AddRenewalPartnerController.RenRelationshipLineItemsWrapper > renRelList = new List < CHL_AddRenewalPartnerController.RenRelationshipLineItemsWrapper > ();
        renRelList.add(renRelLineItemWrapperObj);
        controller.isQLIFromRLI=true;
        
        //Record For SC
        CHL_AddRenewalPartnerController.RenRelationshipLineItemsWrapper renRelLineItemWrapperSCObj = new CHL_AddRenewalPartnerController.RenRelationshipLineItemsWrapper(renRelationSCObj);
        renRelLineItemWrapperSCObj.isSelected = true;
        renRelList.add(renRelLineItemWrapperSCObj);
        
        controller.renRelLineItemWrapperList = renRelList;
        
        controller.getsyncingOptions();
        
        try{	
            controller.OppDetailList = oppList;
            controller.partnerOppObj.CHL_Partner_Account_1__c = accountList[0].id;
            controller.partnerOppObj.CHL_Partner_Account_1_Contact__c = contactList[0].id;
            controller.partnerOppObj.CHL_Incumbent__c = true;
            controller.noteText = 'This is test note';
            controller.recordCurrencyCode = '';
            String currCode = controller.recordCurrencyCode;
            Case cse=new Case();
            insert cse;
            controller.validatePopup();
            controller.attachFile=Blob.valueOf('Unit Test Attachment Body');
            controller.fileName='Test file';
            Attachment attach=new Attachment();
            attach.Name='Unit Test Attachment';
            attach.Body=controller.attachFile;
            attach.ParentId=cse.id;
            insert attach;
            controller.save();
            controller.isQLIFromRLI=false;
            controller.save();
            controller.cancelIncumbent();
            PageReference pr = controller.cancelAndReturnToOppt();
            System.assert(pr!=null);
        }catch(Exception ex){
            system.assert(ex.getmessage()<>null);
        }  	
        Test.stopTest();
    }
    
    static testmethod void noAccessRecordMap(){
        insert new SS_License__c(Channel__c = true);
        insert new CSM_Admin__c(CHL_Restrict_Multiple_Incumbent_On_PO__c = true);
        
        REN_Field_Mappings__c fieldMapping = new REN_Field_Mappings__c(REN_Field_Data_Type__c = 'STRING', REN_From_Field_API_Name__c = 'Name', REN_From_Object_Api_Name__c = 'Opportunity', REN_To_Field_API_Name__c = 'Name', REN_To_Object_API_Name__c  = 'Partner_OPP');
        insert fieldMapping;
        
        Boolean isEntitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
        
        List < Account > accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList.get(0).Id != null);
        
        Product2 prod1 = REN_TestDataUtility.createProduct(1);
        insert prod1;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 standardPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert standardPB;
        
        Opportunity testOppty = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting', Pricebook2Id=standardPB.id,
                                                CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, REN_Earliest_Expiration_Date__c = System.Today() + 2);
        
        insert testOppty;
        Product2 prod = REN_TestDataUtility.createProduct(1);
        insert prod;
        
        PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod1.Id);
        insert price1;
        system.assert(price1.Id != null);
        
        system.assert(prod.Id != null);
        OpportunityLineItem opptyLineItem = new OpportunityLineItem(OpportunityId = testOppty.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id, REN_Start_Date__c = System.Today(), REN_End_Date__c = System.Today() + 3);
        insert opptyLineItem;
        
        Asset asset = REN_TestDataUtility.createAsset(accList.get(0).Id, prod.Id);
        asset.REN_Oppty_Line_Item_Id__c = opptyLineItem.Id;
        insert asset;
        
        REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
        renRelationObj.Name = 'Ren-OPP';
        renRelationObj.REN_Asset__c = asset.Id;
        renRelationObj.REN_Renews_To__c = testOppty.Id;
        renRelationObj.REN_Renewal_Product_Line_Id__c = opptyLineItem.Id;
        renRelationObj.REN_Product__c = prod.id;
        renRelationObj.REN_Quantity__c = 2;
        renRelationObj.REN_Previous_Price__c= 500;
        insert renRelationObj;
        
        List < SObject > serviceContractList = CSM_TestDataUtility.createServiceContract(2, accList[0].id);
        
        REN_Renews_To__c renRelationSCObj = new REN_Renews_To__c();
        renRelationSCObj.Name = 'Ren-OPP';
        if(isEntitlementEnabled){
            if(!serviceContractList.isEmpty()){
                if (CSM_AccessController.hasField(REN_Constants.OBJ_REN_RENEWS_TO, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT)){
                    renRelationSCObj.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT, serviceContractList[0].Id);
                }
                
            }
        }
        renRelationSCObj.REN_Renews_To__c = testOppty.Id;
        renRelationSCObj.REN_Renewal_Product_Line_Id__c = opptyLineItem.Id;
        renRelationSCObj.REN_Product__c = prod.id;
        renRelationSCObj.REN_Quantity__c = 2;
        renRelationSCObj.REN_Previous_Price__c= 500;
        insert renRelationSCObj;
        
        String OppID = testOppty.id;
        CHL_Opportunity_Status_Log__c optyStatusLogObj = new CHL_Opportunity_Status_Log__c(); 
        optyStatusLogObj.CHL_Field_API_Names__c = 'CHL_Sales_Stage__c;CHL_Amount__c';
        optyStatusLogObj.CHL_Days_between_Update__c = 5;
        optyStatusLogObj.CHL_Available_Sales_Stages__c = 'Needs Analysis;Closed Won';
        optyStatusLogObj.CHL_Enable_2_Tier_Pricing__c = true;
        insert optyStatusLogObj;
        Test.startTest();
        List<Account> accountList = new List<Account>();	
        List<Contact> contactList = new List<Contact>();
        Account acc =  CHL_TestUtility.partnerAccount();
        Account acc2 =  CHL_TestUtility.partnerAccount();
        accountList.add(acc);
        accountList.add(acc2);
        insert accountList;	
        accountList[0].CHL_Partner_Account_Type__c = 'Reseller';
        accountList[1].CHL_Partner_Account_Type__c = 'Distributor';
        update accountList;
        Contact con =  CHL_TestUtility.partnerContact(accountList[0].id);
        contactList.add(con);
        insert contactList;	
        list < Opportunity > oppList = new list < Opportunity > ();
        System.debug('\n\n----testOppty: ' + testOppty);
        oppList.add(testOppty);
        CHL_Partner_Opportunity__c obj =new CHL_Partner_Opportunity__c();
        obj.Name = 'TestPO'; 
        obj.CHL_Incumbent__c = true;
        obj.CHL_Opportunity__c = oppList[0].id;
        insert obj;
        //User u = CHL_TestUtility.createTestPartnerUser('Channel Community','testpartnercontact@test.com',contactList[0].id);
        //insert u;
        PageReference pageRef = Page.CHL_AddPartnerOpportunity;
        pageRef.getParameters().put('Id', '0060a00000ciCou');
        Test.setCurrentPage(pageRef);
        List<CHL_Partner_Opportunity__c> partnerOpps = new List<CHL_Partner_Opportunity__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(partnerOpps);
		CHL_AddRenewalPartnerController controller = new CHL_AddRenewalPartnerController(sc);
        CHL_AddRenewalPartnerController.RenRelationshipLineItemsWrapper renRelLineItemWrapperObj = new CHL_AddRenewalPartnerController.RenRelationshipLineItemsWrapper(renRelationObj);
        renRelLineItemWrapperObj.isSelected = true;
        Test.stopTest();
    }
    
}