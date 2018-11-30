@isTest
private class REN_RenewalRelationshipRollup_Test
{
    static User createUser(String profileName)
    {
    	//Id profileId
		Profile renewProfile = [Select Name, Id From Profile where Name = :profileName limit 1]; 
		User renewUsr =  CSM_TestDataUtility.CreateUser(renewProfile.Id);
		insert renewUsr;
		system.assert(renewUsr.Id != null);
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
		
		REN_Related_List__c rl = new REN_Related_List__c(Name=REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Competitors');
		insert rl;

		REN_Field_Mappings__c fmStage = getFieldMappingRec('Opportunity → Renewal Opportunity', 'PICKLIST', 'StageName', '', 'Opportunity', 'Opportunity', true, 'Qualification');
		
		//CloseDate
		REN_Field_Mappings__c fmCloseDt = getFieldMappingRec('Opportunity → Renewal Opportunity', 'DATE', 'CloseDate', 'CloseDate', 'Opportunity', 'Opportunity', true, '');
		
		//OwnerId
		REN_Field_Mappings__c fmOwner = getFieldMappingRec('Opportunity → Renewal Opportunity', 'REFERENCE', 'OwnerId', 'OwnerId', 'Opportunity', 'Opportunity', true, '');
		
		//Name
		REN_Field_Mappings__c fmName = getFieldMappingRec('Opportunity → Renewal Opportunity', 'STRING', 'Name', 'Name', 'Opportunity', 'Opportunity', true, '');
		
		//IsPrivate
		REN_Field_Mappings__c fmPrivate = getFieldMappingRec('Opportunity → Renewal Opportunity', 'BOOLEAN', 'IsPrivate', 'IsPrivate', 'Opportunity', 'Opportunity', true, '');
		
		//Probability
		REN_Field_Mappings__c fmProb = getFieldMappingRec('Opportunity → Renewal Opportunity', 'PERCENT', 'Probability', '', 'Opportunity', 'Opportunity', true, '15');
		
		//Oppt Line Item
		REN_Field_Mappings__c fmQuantityOpLn = getFieldMappingRec('Opportunity → Renewal Opportunity', 'DOUBLE', 'Quantity', 'Quantity', 'OpportunityLineItem', 'OpportunityLineItem', true, '');
		
		REN_Field_Mappings__c fmServDtOpLn = getFieldMappingRec('Opportunity → Renewal Opportunity', 'DATE', 'ServiceDate', '', 'OpportunityLineItem', 'OpportunityLineItem', true, '2019-09-17');
		
		REN_Related_List__c rlAsset = new REN_Related_List__c(Name=REN_Constants.OBJ_RL, REN_Related_List_Type__c = 'Competitors');
		insert rlAsset;

		REN_Field_Mappings__c fmCompPrd = getFieldMappingRec('Opportunity Line Item → Asset', 'BOOLEAN', 'IsCompetitorProduct', '', 'Asset', 'OpportunityLineItem', true, 'false');
		
		REN_Field_Mappings__c fmNameAsset = getFieldMappingRec('Opportunity Line Item → Asset', 'STRING', 'Name', 'Name', 'Asset', 'OpportunityLineItem', true, '');
		
		REN_Field_Mappings__c fmQuantityAsset = getFieldMappingRec('Opportunity Line Item → Asset', 'DOUBLE', 'Quantity', 'Quantity', 'Asset', 'OpportunityLineItem', true, '');
		
		REN_Field_Mappings__c fmDescAsset = getFieldMappingRec('Opportunity Line Item → Asset', 'TEXTAREA', 'Description', 'Description', 'Asset', 'OpportunityLineItem', true, '');
		
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
		
		insert fMappingList;
		
		Product2 prod1 = new Product2(Name = 'Test Product 1', IsActive = true);
		insert prod1;
		
		Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod1.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 standardPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert standardPB;
		
		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPB.Id, UnitPrice = 1.0, IsActive = true, Product2Id = prod1.Id);
		insert price1;
		
		Account a = new Account(Name = 'RENEW DIRECT Test Account A');
		insert a; 
		
		List<Opportunity> testOppList = new List<Opportunity>();
		for(Integer i = 0; i < 10; i++)
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
	
	static REN_Field_Mappings__c getFieldMappingRec(string mappingName, String dataType, String toName, String fromName, String toObject, String fromObject, 
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
		fm.Name = mappingName;
		return fm;
	}
	

    static testMethod void testRenewRelationshipUpdates()
    {
    	//User adminUsr = createUser('System Administrator');
    	//list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
		//lstPSAssignments = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :renewUsrId];
		//PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'Renew'];
		//lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUsr.id, PermissionSetId = ps.Id));
		//insert lstPSAssignments;
    	Test.startTest(); 
        //System.runAs(adminUsr){
        	List<Opportunity> lstOppt = setupAdminNOppt(false);
	        for(Opportunity currentOpportunity : lstOppt)
	        {
	        	currentOpportunity.StageName = 'Closed Won';
				currentOpportunity.REN_Is_CLM_Renewal__c = false;
	        }
	        CSM_Constants.OPPORTUNITY_TRIGGER = true;
	        
        	update lstOppt;
        	List<Asset> lstAssets = [Select Id, Name From Asset where createdById = :UserInfo.getUserId() limit 10];
        	Integer i = 0;
        	for(Asset a :lstAssets)
        	{
        		a.Name = a.Name + i++;
        		a.Quantity = i + 1;
        	}
        	//REN_Constants.RENEWALRELATIONSHIP_BEFORE_TRIGGER = true;
        	//REN_Constants.RENEWALRELATIONSHIP_AFTER_TRIGGER = true;
        	update lstAssets;
        	
        	system.assert(lstOppt.size() > 0);
        //}
        Test.stopTest();
        
    }
    
    static testmethod void resetRliFields(){
        Account account = CHL_TestUtility.partnerAccount();
        insert account;
        List<Opportunity> oppList = CHL_TestUtility.createOpportunity(1, account.Id);
        insert oppList;
        List<Product2> productList = CHL_TestUtility.createProducts(1);
        insert productList;
        List<REN_Renews_To__c> rliList = CHL_TestUtility.createRenewableLineItems(1, oppList[0].Id, productList[0].Id);
        insert rliList;
        
        List<REN_Renews_To__c> rliList2 = new List<REN_Renews_To__c>();
        rliList2.addAll(rliList.deepClone(true));
        
        rliList2[0].REN_Quantity__c = 10;
        
        Map<ID, sObject> oldRecordsMap = new Map<ID, sObject>((List<SObject>)rliList);
        Map<ID, sObject> newRecordsMap = new Map<ID, sObject>((List<SObject>)rliList2);
        
        REN_RenewalRelationshipRollupHandler.resetFields(oldRecordsMap, newRecordsMap, 'REN_Quantity__c');
        
        rliList2[0].REN_Renewal_Target_Multiplier__c = 1;
        
        REN_RenewalRelationshipRollupHandler.resetFields(oldRecordsMap, newRecordsMap, 'REN_Quantity__c');
        System.assertEquals(rliList2[0].REN_Renewal_Target_Multiplier__c, 1);
    }
}