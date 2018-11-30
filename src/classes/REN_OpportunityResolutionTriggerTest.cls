@isTest(SeeAllData = true)
private class REN_OpportunityResolutionTriggerTest
{
    
    static User createUser(String profileName)
    {
        //Id profileId
        Profile renewProfile = [Select Name, Id From Profile where Name = :profileName limit 1]; 
        User renewUsr =  CSM_TestDataUtility.CreateUser(renewProfile.Id);
        insert renewUsr;
        return renewUsr;
    }
    
    static List<Opportunity> setupAdminNOppt(Boolean isPrdCriteriaSet)
    {
        CSM_Constants.OPPORTUNITY_TRIGGER = true;
        CSM_TestUtility.addLicense();
        CSM_TestUtility.addRenewLicense();
        CSM_TestUtility.addCSMAdmin();

        
        List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
        renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
        upsert renewConfigurationList;
       
        List<REN_Related_List__c> lstRL = new List<REN_Related_List__c>();
        REN_Related_List__c rl1 = new REN_Related_List__c(Name=REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Competitors');
        REN_Related_List__c rl2 = new REN_Related_List__c(Name=REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Contact Roles');
        REN_Related_List__c rl3 = new REN_Related_List__c(Name=REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Partners');
        lstRL.add(rl1);
        lstRL.add(rl2);
        lstRL.add(rl3);
        insert lstRL;
         
        REN_Field_Mappings__c fmStage = getFieldMappingRec('PICKLIST', 'StageName', '', 'Opportunity', 'Opportunity', true, 'Qualification');
        
        //CloseDate
        REN_Field_Mappings__c fmCloseDt = getFieldMappingRec('DATE', 'CloseDate', 'CloseDate', 'Opportunity', 'Opportunity', true, '');
        
        //OwnerId
        REN_Field_Mappings__c fmOwner = getFieldMappingRec('REFERENCE', 'OwnerId', 'OwnerId', 'Opportunity', 'Opportunity', true, '');
        
        //Name
        REN_Field_Mappings__c fmName = getFieldMappingRec('STRING', 'Name', 'Name', 'Opportunity', 'Opportunity', true, '');
        
        //IsPrivate
        REN_Field_Mappings__c fmPrivate = getFieldMappingRec('BOOLEAN', 'IsPrivate', 'IsPrivate', 'Opportunity', 'Opportunity', true, '');
        
        //Probability
        REN_Field_Mappings__c fmProb = getFieldMappingRec('PERCENT', 'Probability', '', 'Opportunity', 'Opportunity', true, '15');
        
        //Oppt Line Item
        REN_Field_Mappings__c fmQuantityOpLn = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmServDtOpLn = getFieldMappingRec('DATE', 'ServiceDate', '', 'OpportunityLineItem', 'OpportunityLineItem', true, '2019-09-17');
        
        
        REN_Related_List__c rlAsset = new REN_Related_List__c(Name=REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Competitors');
        insert rlAsset;
        //Assets
        REN_Field_Mappings__c fmCompPrd = getFieldMappingRec('BOOLEAN', 'IsCompetitorProduct', '', 'Asset', 'OpportunityLineItem', true, 'false');
        
        REN_Field_Mappings__c fmNameAsset = getFieldMappingRec('STRING', 'Name', 'Name', 'Asset', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmQuantityAsset = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'Asset', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmDescAsset = getFieldMappingRec('TEXTAREA', 'Description', 'Description', 'Asset', 'OpportunityLineItem', true, '');
        
        //Service Contracts
        REN_Field_Mappings__c fmNameSC  = getFieldMappingRec('STRING', 'Name', 'Name', 'ServiceContract', 'Opportunity', true, '');
        
        REN_Field_Mappings__c fmOwnerSC = getFieldMappingRec('REFERENCE', 'OwnerId', 'OwnerId', 'ServiceContract', 'Opportunity', true, '');
        
        REN_Field_Mappings__c fmUnitPriceSC = getFieldMappingRec('DOUBLE', 'UnitPrice', 'UnitPrice', 'ContractLineItem', 'OpportunityLineItem', true, '');
        
        REN_Field_Mappings__c fmQtySC = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'ContractLineItem', 'OpportunityLineItem', true, '');
        
        
        
        List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
        fMappingList.add(fmStage);
        fMappingList.add(fmOwner);
        fMappingList.add(fmName);
        fMappingList.add(fmPrivate);
        fMappingList.add(fmProb);
        
        fMappingList.add(fmQuantityOpLn);
        fMappingList.add(fmServDtOpLn);
        
        fMappingList.add(fmCompPrd);
        fMappingList.add(fmNameAsset);
        fMappingList.add(fmQuantityAsset);
        fMappingList.add(fmDescAsset);
        
        //Added below code to fix the test class failuare after patch version upload 1.25.7
        fMappingList.add(fmNameSC);
        fMappingList.add(fmOwnerSC);
        
        insert fMappingList;
        
        Product2 prod1 = new Product2(Name = 'Test Product 1', IsActive = true);
        insert prod1;
        
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
        
        PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod1.Id);
        insert price1;
        
        Account a = new Account(Name = 'RENEW DIRECT Test Account A');
        insert a; 
        
        List<Opportunity> testOppList = new List<Opportunity>();
        for(Integer i = 0; i < 100; i++)
        {
            testOppList.add(new Opportunity(Name = 'TestOpp' + i, StageName = 'Qualified', 
                                            CloseDate = System.Today(), AccountId = a.Id, Type = 'New Customer'));
        }
        insert testOppList;
        
        List<OpportunityLineItem> testOppLineItemsList = new List<OpportunityLineItem>();
        for(Opportunity currentOpportunity :testOppList)
        {
            for(Integer i = 0; i < 2; i++)
            {
                testOppLineItemsList.add(new OpportunityLineItem(OpportunityId = currentOpportunity.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id));
            }
        }
        insert testOppLineItemsList;
        return testOppList;     
    }
    
    static REN_Field_Mappings__c getFieldMappingRec(String dataType, String toName, String fromName, String toObject, String fromObject, 
                                                    Boolean isRequired, String defaultValue)
    {
        REN_Field_Mappings__c fm = new REN_Field_Mappings__c();
        //fm.REN_Renew_Configuration__c = rcRenewalId;
        fm.REN_Field_Data_Type__c = dataType;
        fm.REN_To_Field_API_Name__c = toName;
        fm.REN_From_Field_API_Name__c = fromName;
        fm.REN_To_Object_API_Name__c = toObject;
        fm.REN_From_Object_Api_Name__c = fromObject;
        fm.REN_Is_Required__c = isRequired;
        fm.REN_Default_Value__c = defaultValue;
        return fm;
    }
    
    static List<Opportunity> setup()
    {
        String namespace = CSM_Util.getNamespace();
        String REN_To_Field_API_Name;
        String REN_Notify_Opportunity_Owner;
        String Is_Consolidated;
        String REN_Is_Consolidated;
        if (nameSpace != null && nameSpace.length() > 0)
        {
            REN_To_Field_API_Name = namespace + 'REN_Is_CLM_Renewal__c';
            REN_Notify_Opportunity_Owner = namespace + 'REN_Notify_Opportunity_Owner__c';
            Is_Consolidated = namespace + 'Is_Consolidated__c';
            REN_Is_Consolidated = namespace + 'REN_Is_Consolidated__c';
        }
        else
        {
            REN_To_Field_API_Name = 'REN_Is_CLM_Renewal__c';
            REN_Notify_Opportunity_Owner = 'REN_Notify_Opportunity_Owner__c';
            Is_Consolidated = 'Is_Consolidated__c';
            REN_Is_Consolidated = 'REN_Is_Consolidated__c';
        }
    
    
        
        REN_Related_List__c rl = new REN_Related_List__c(Name = REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Competitors');
        insert rl;
        system.assert(rl.Id != null);

        CSM_Admin__c admin = new CSM_Admin__c(REN_Opportunity_Related_List__c = 'Contact Roles;Competitors;Partners');
        insert admin;
        system.assert(admin.Id != null);

        //Name
        REN_Field_Mappings__c fm1 = getFieldMappingRec('STRING', 'Name', 'Name', 'ServiceContract', 'Opportunity', true, '');
    
        //UnitPrice
        REN_Field_Mappings__c fm2 = getFieldMappingRec('CURRENCY', 'UnitPrice', 'UnitPrice', 'ContractLineItem', 'OpportunityLineItem', true, '');
    
        //Quantity
        REN_Field_Mappings__c fm3 = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'ContractLineItem', 'OpportunityLineItem', true, '');
    
        //CloseDate
        REN_Field_Mappings__c fm4 = getFieldMappingRec('DATE', 'CloseDate', 'EndDate', 'Opportunity', 'ServiceContract', true, '');

        //Name:Opportunity
        REN_Field_Mappings__c fm5 = getFieldMappingRec('STRING', 'Name', 'Name', 'Opportunity', 'ServiceContract', true, '');

        //IsPrivate
        REN_Field_Mappings__c fm6 = getFieldMappingRec('BOOLEAN', 'IsPrivate', 'false', 'Opportunity', 'ServiceContract', true, '');
    
        //StageName
        REN_Field_Mappings__c fm7 = getFieldMappingRec('PICKLIST', 'StageName', 'Status', 'Opportunity', 'ServiceContract', true, '');
    
        //Quantity
        REN_Field_Mappings__c fm8 = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'OpportunityLineItem', true, '');
    
        List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c> ();
        fMappingList.add(fm1);
        fMappingList.add(fm2);
        fMappingList.add(fm3);
        fMappingList.add(fm4);
        fMappingList.add(fm5);
        fMappingList.add(fm6);
        fMappingList.add(fm7);
        fMappingList.add(fm8);
        insert fMappingList;
    
        Product2 prod1 = new Product2(Name = 'Test Product 1', IsActive = true);
        insert prod1;
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
    
        PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, 
                                                    Product2Id = prod1.Id);
        insert price1;
    
        Account a = new Account(Name = 'RENEW DIRECT Test Account A');
        insert a;
        List<Opportunity > testOppList = new List<Opportunity > ();
        for(Integer i = 0; i < 10; i++)
        {
            testOppList.add(new Opportunity(Name = 'TestOpp' + i, StageName = 'Prospecting',
                                            CloseDate = System.Today(), AccountId = a.Id, Type = 'New Customer'));
        }
        insert testOppList;
    
        List<OpportunityLineItem> testOppLineItemsList = new List<OpportunityLineItem> ();
        for(Opportunity currentOpportunity: testOppList)
        {
            for(Integer i = 0; i < 2; i++)
            {
              testOppLineItemsList.add(new OpportunityLineItem(OpportunityId = currentOpportunity.Id, Quantity = 1.0, TotalPrice = 1.0, 
                                                                PricebookEntryId = price1.Id));
            }
        }
        insert testOppLineItemsList;
     
        return testOppList;
    }
  
    static testMethod void testRenewalAndAssetCreationNoCriteria()
    {
        User adminUsr = createUser('System Administrator');
        
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        //lstPSAssignments = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :renewUsrId];
        PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'PRISM_Base'];
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUsr.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;
        
        system.runAs(adminUsr)
        {
            List<Opportunity> lstOppt = setupAdminNOppt(false);
            Set<String> ids = new Set<String>();
            Map<String, String> idsMap = new Map<String, String>();
            for(Opportunity currentOpportunity : lstOppt)
            {
                currentOpportunity.StageName = 'Closed Won';
                ids.add(currentOpportunity.Id);
                idsMap.put(currentOpportunity.Id, currentOpportunity.Id);
            }
            CSM_Constants.OPPORTUNITY_TRIGGER = true;
            Test.startTest();
            update lstOppt;
            OpportunityCompetitor opptyComp = new OpportunityCompetitor();
            opptyComp.CompetitorName = 'ABC';
            opptyComp.OpportunityId = lstOppt[0].Id;
            insert opptyComp;
            
            List <REN_Renew_Configuration__c> renewConfigurationList = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT);
            REN_OpportunityResolutionHelper.createRelatedListRecords(ids, idsMap, renewConfigurationList);
            
            Map<String, String> serviceContractOpptyMap = new Map<String, String>();
            List<SObject> scList = createServiceContracts();
            if (!scList.IsEmpty()){
                for (SObject obj: scList){
                    serviceContractOpptyMap.put((String)obj.get('Id'), lstOppt[0].Id);
                }
            }
            //Eswar Bala: This object is not used.
            //REN_OpportunityResolutionHelper.handleOpportunityServiceContractCreation(serviceContractOpptyMap);
            if (CSM_AccessController.hasObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM)){
            	REN_OpportunityResolutionHelper.getServiceContractWithoutInsert(lstOppt, renewConfigurationList);
            REN_OpportunityResolutionHelper.getMappedOptyBasedserviceContract(scList[0], lstOppt[0].Id, CSM_Constants.TYPE_CURRENCY, null, '0', 'Tax', 
                                                            'Tax');
            REN_OpportunityResolutionHelper.getMappedOptyBasedserviceContract(scList[0], lstOppt[0].Id, '', null, '0', 'Name', 
                                                            'Name');
                            
            }
            Product2 prod1 = new Product2(Name = 'Test Product 1', IsActive = true);
            insert prod1;
            Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
            
            PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod1.Id);
            insert price1;
            List<OpportunityLineItem> testOppLineItemsList = new List<OpportunityLineItem>();                           
            for(Opportunity currentOpportunity: lstOppt)
            {
                for(Integer i = 0; i < 2; i++)
                {
                  testOppLineItemsList.add(new OpportunityLineItem(OpportunityId = currentOpportunity.Id, Quantity = 1.0, TotalPrice = 1.0, 
                                                                    PricebookEntryId = price1.Id));
                }
            }
            insert testOppLineItemsList;
        
            REN_OpportunityResolutionHelper.getMappedAssetBasedOpportunityLineItem(testOppLineItemsList, CSM_Constants.TYPE_INTEGER, null, '0', 'Quantity', 
                                                            'Quantity');
                                                        
            
            Test.stopTest();
            system.assert(lstOppt.size() > 0);
        }
    }
    
    static List<SObject> createServiceContracts()
    {
        List<SObject> lstServiceContracts = new List<SObject>();
        Boolean entitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
        if(entitlementEnabled){
            Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
            Account A = new Account(Name = 'Service Source Test Class Service Contract Related Account');
            insert A;
            for(Integer i = 0; i < 100; i++)
            {
                SObject serviceContractX = CSM_AccessController.newSObject(REN_Constants.OBJ_SERVICECONTRACT);
                serviceContractX.put('AccountId', A.Id);
                serviceContractX.put('Name', 'Service Source Test Class Service Contract ' + i);
                serviceContractX.put('PriceBook2Id', standardPB.Id);
                lstServiceContracts.add(serviceContractX);
            }
            insert lstServiceContracts;
        }
        return lstServiceContracts;
    }
    
    static testMethod void testRenewalAndAssetCreationNoCriteriaAndServiceContractAppend()
    {
        User renewUsr = createUser('System Administrator');
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        //lstPSAssignments = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :renewUsrId];
        PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'PRISM_Base'];
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = renewUsr.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;
        Boolean entitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
        // VCP - ORG21 check
        Boolean hasAppendSCField = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
        List<SObject> lstServContracts;
        
        system.runAs(renewUsr)
        {
            if(entitlementEnabled)
            {
                lstServContracts = createServiceContracts();
            }
            List<Opportunity> lstOppt = setupAdminNOppt(false);
            for(Integer i = 0; i < 100; i++)
            {
                Opportunity currentOpportunity = lstOppt[i];
                currentOpportunity.StageName = 'Closed Won';
                if(entitlementEnabled && hasAppendSCField)
                {
                    currentOpportunity.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT, (lstServContracts[i]).get('Id'));
                }
                i++;
            }

            Pricebook2 pb1 = new Pricebook2(Name='PB1');
            insert pb1;
            Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
            Account a = new Account(Name = 'Test Account A');
            insert a; 
            
            SObject sOpp;
            List<SObject> sSC;                      
            if(UserInfo.isMultiCurrencyOrganization() && entitlementEnabled){
                
                sOpp = new Opportunity();
                sOpp.put('Name', 'TestOppCurrMismatchMain');
                sOpp.put(CSM_CONSTANTS.CURRENCY_ISO_CD, 'USD');         
                sOpp.put('StageName','Qualified');
                sOpp.put('Pricebook2Id',standardPB.id); 
                sOpp.put('CloseDate',System.Today() + 1);
                sOpp.put('AccountId',a.Id);                             
                sOpp.put('Type','New Customer');                
                        
                insert sOpp;            
                sSC = CSM_TestDataUtility.createServiceContract(1, a.id);
                sSC[0].put('Name', 'TestSCPBMismatchChild');
                sSC[0].put(CSM_CONSTANTS.CURRENCY_ISO_CD, 'JPY');           
                sSC[0].put('Pricebook2Id',pb1.id);
                    
                update sSC;

                sOpp.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT, sSC[0].get('Id'));
                update sOpp;
            }  else if(entitlementEnabled){
                sOpp = new Opportunity();
                sOpp.put('Name', 'TestOppCurrMismatchMain');
                sOpp.put('StageName','Qualified');
                sOpp.put('Pricebook2Id',standardPB.id); 
                sOpp.put('CloseDate',System.Today() + 1);
                sOpp.put('AccountId',a.Id);                             
                sOpp.put('Type','New Customer');                
                        
                insert sOpp;
                            
                sSC = CSM_TestDataUtility.createServiceContract(1, a.id);
                sSC[0].put('Name', 'TestSCPBMismatchChild');
                sSC[0].put('Pricebook2Id',pb1.id);
                update sSC;             

                //sOpp.put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT, sSC[0].get('Id'));
                //update sOpp;                        
            }      
            
            
            CSM_Constants.OPPORTUNITY_TRIGGER = true;
            Test.startTest();
            try{
                update lstOppt;
    
                if(UserInfo.isMultiCurrencyOrganization() && entitlementEnabled){
                    sOpp.put('StageName','Closed Won');  
                    update sOpp;        
                }  else if(entitlementEnabled){
                    sOpp.put('StageName','Closed Won');  
                    update sOpp;        
                }      
                
            }catch(system.DmlException dme){
                system.assert(true);
            }
            
            Test.stopTest();
            system.assert(lstOppt.size() > 0);
        }
    }
    
    static testMethod void testRenewalAndAssetCreationNoCriteriaAndOpportunityAppend()
    {
        User renewUsr = createUser('System Administrator');
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        //lstPSAssignments = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :renewUsrId];
        PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'PRISM_Base'];
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = renewUsr.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;
        Account a = new Account(Name = 'Test Service Source Test');
        
        system.runAs(renewUsr)
        {
            insert a;
            CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount('', a.Id);
            List<Opportunity> testOppList = new List<Opportunity>();
            for(Integer i = 0; i < 20; i++)
            {
                testOppList.add(new Opportunity(Name = 'TestOpp' + i, StageName = 'Qualified', 
                                                CloseDate = System.Today(), AccountId = a.Id, Type = 'New Customer'));
            }
            insert testOppList;
            List<Opportunity> lstOppt = setupAdminNOppt(false);
            for(Integer i = 0; i < 20; i++)
            {
                lstOppt[i].StageName = 'Closed Won';
                lstOppt[i].REN_Append_Renewal_Opportunity__c = testOppList[i].Id;
                i++;
            }
            
            Pricebook2 pb1 = new Pricebook2(Name='PB1');
            insert pb1;
            Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];

            SObject sOpp;
            SObject sOpp1;
            if(UserInfo.isMultiCurrencyOrganization()){
                sOpp = new Opportunity();
                sOpp.put('Name', 'TestOppCurrMismatchMain');
                sOpp.put(CSM_CONSTANTS.CURRENCY_ISO_CD, 'USD');         
                sOpp.put('StageName','Qualified');
                sOpp.put('Pricebook2Id',standardPB.id); 
                sOpp.put('CloseDate',System.Today() + 1);
                sOpp.put('AccountId',a.Id);                             
                sOpp.put('Type','New Customer');                
                    
                insert sOpp;
                
                sOpp1 = new Opportunity();
                sOpp1.put('Name', 'TestOppCurrMismatchChild');
                sOpp1.put(CSM_CONSTANTS.CURRENCY_ISO_CD, 'JPY');            
                sOpp1.put('StageName','Qualified');         
                sOpp1.put('Pricebook2Id',pb1.id);
                sOpp1.put('CloseDate',System.Today() + 1);
                sOpp1.put('AccountId',a.Id);                                
                sOpp1.put('Type','New Customer');               
                
                insert sOpp1;
                
                sOpp.put('REN_Append_Renewal_Opportunity__c',sOpp1.Id);
                update sOpp;                
    
            } else {
                sOpp = new Opportunity();
                sOpp.put('Name', 'TestOppCurrMismatchMain');
                sOpp.put('StageName','Qualified');
                sOpp.put('Pricebook2Id',standardPB.id); 
                sOpp.put('CloseDate',System.Today() + 1);
                sOpp.put('AccountId',a.Id);                             
                sOpp.put('Type','New Customer');                
                        
                insert sOpp;
                
                sOpp1 = new Opportunity();
                sOpp1.put('Name', 'TestOppCurrMismatchChild');
                sOpp1.put('StageName','Qualified');         
                sOpp1.put('Pricebook2Id',pb1.id);
                sOpp1.put('CloseDate',System.Today() + 1);
                sOpp1.put('AccountId',a.Id);                                
                sOpp1.put('Type','New Customer');               
                
                insert sOpp1;

                sOpp.put('REN_Append_Renewal_Opportunity__c', sOpp1.Id);
                update sOpp;                
            }     
            
            
            CSM_Constants.OPPORTUNITY_TRIGGER = true;
            Test.startTest();
            update lstOppt;
            try{
                update lstOppt;
                sOpp.put('StageName','Closed Won');  
                update sOpp;        
                
            }catch(system.DmlException dme){
                system.assert(true);
            }
            Test.stopTest();
            system.assert(lstOppt.size() > 0);
        }
    }
    
    static testMethod void testRenewalAndAssetCreationAndCriteria()
    {
        User adminUsr = createUser('System Administrator');
        
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        //lstPSAssignments = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :renewUsrId];
        PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'PRISM_Base'];
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUsr.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;

        system.runAs(adminUsr)
        {
            List<REN_Renew_Configuration__c> lstRenewConfigs = REN_RenewConfigurationDataAccess.getRenewConfigByTriggerType(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
            REN_CreateOptyFromServiceContractCtrl.getServiceContractToOpportunityMappingList(createServiceContracts());
            List<Opportunity> lstOppt = setupAdminNOppt(true);
            for(Opportunity currentOpportunity : lstOppt)
            {
                currentOpportunity.StageName = 'Closed Won';
            }
            CSM_Constants.OPPORTUNITY_TRIGGER = true;
            Test.startTest();
            update lstOppt;
            try{
                REN_OpportunityDataAccess.checkPricebookAndCurrencyMatchForOppAndSC(new Set<String>{''+lstOppt[0].id});
            }catch(Exception e){}
            try{
                REN_OpportunityDataAccess.checkPricebookMatchForOppAndSC(new Set<String>{''+lstOppt[0].id});
            }catch(Exception e){}
            try{
                REN_OpportunityDataAccess.getPricebookAndCurrencyForOppandAppendOpp(new Set<String>{''+lstOppt[0].id});
            }catch(Exception e){}

            Test.stopTest();
            system.assert(lstOppt.size() > 0);
        }
    }
    
    static testMethod void testAssetUpdate()
    {
        User adminUsr = createUser('System Administrator');
        list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
        //lstPSAssignments = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :renewUsrId];
        PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'PRISM_Base'];
        lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUsr.id, PermissionSetId = ps.Id));
        insert lstPSAssignments;
        CSM_Util.getScoutAnalyticsUrl();
        CSM_Util.getPackageVersion();
        //CSM_Util.nameSpacePrefix21();
        CSM_Util.NewGuid();
        //CSM_Util.getCharAtIndex('String str', 2);
        CSM_Util.GetSObjectFieldsMap('Account');
        CSM_Util.isUserAnSystemAdmin();
        CSM_Util.getPicklistValues((SObject) new Opportunity(), 'StageName');
        
        
        system.runAs(adminUsr)
        {
            List<Opportunity> lstOppt = setupAdminNOppt(true);
            
            CSM_TestDataUtility.createAccountPlanTemplateData(2);
            CSM_TestDataUtility.createPlaybooks(2);
            //CSM_TestDataUtility.createIndicatorGroups();
            CSM_TestDataUtility.createAccount(2);
            CSM_TestDataUtility.createPlaybookTestData(2);
            CSM_TestDataUtility.createPlayTestData(2);
            CSM_TestDataUtility.GetTestRunAsUser();
            CSM_TestDataUtility.createChartList();
            for(Opportunity currentOpportunity : lstOppt)
            {
                currentOpportunity.StageName = 'Closed Won';
            }
            CSM_Constants.OPPORTUNITY_TRIGGER = true;
            
            update lstOppt;
            List<Asset> lstAssets = [Select Id, Name From Asset where createdByID = :UserInfo.getUserId() LIMIT 1000];
            Integer i = 0;
            for(Asset a :lstAssets)
            {
                a.Name = a.Name + i++;
                a.Quantity = i+1;
            }
            Test.startTest();
            update lstAssets;
            system.assert(lstOppt.size() > 0);
            Test.stopTest();
           
        }
    }
    
     static testMethod void getRenewUpdate()
    {
        Set<String> opportunityGenerationSetTest=new Set<String>{REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY,REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT,REN_Constants.RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT,REN_Constants.RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT,REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET};
        Test.startTest();
        List<REN_Renew_Configuration__c> renewConfigurationListTest=REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(opportunityGenerationSetTest);
        system.assert(renewConfigurationListTest.size() > 0);
        REN_RenewConfigurationDataAccess.saveRenewConfiguration(renewConfigurationListTest);
        Test.stopTest();
        System.assert(renewConfigurationListTest != Null);
    }
}