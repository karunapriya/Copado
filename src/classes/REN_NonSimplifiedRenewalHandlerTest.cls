@isTest
private class REN_NonSimplifiedRenewalHandlerTest {
	static testMethod void setUpTestData(){
		List <Account> accountList = CSM_TestDataUtility.createAccount(1);
		system.assert(accountList != null);
		system.assert(!accountList.isEmpty());
		
		List <Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(1, accountList[0].id);
		opportunityList[0].stageName = 'Closed Won';
		opportunityList[0].REN_Is_CLM_Renewal__c=false;
		update opportunityList;
		
		system.assert(opportunityList != null);
		system.assert(!opportunityList.isEmpty());
        
        List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
        renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
        upsert renewConfigurationList;
        system.assert(renewConfigurationList!=null);
        
        Map<String, REN_Renew_Configuration__c> renewConfigurationMap = new Map<String, REN_Renew_Configuration__c>();
		if(renewConfigurationList != null){
			for(REN_Renew_Configuration__c rConfig: renewConfigurationList){
				renewConfigurationMap.put(rConfig.REN_Record_Key__c, rConfig);
			}
		}
				
        REN_Renew_Configuration__c configAsset = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_ASSET);
        REN_Renew_Configuration__c configSC = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT);
        REN_Renew_Configuration__c configOpp = renewConfigurationMap.get(REN_Constants.RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY);
        
		List<REN_Line_Criteria__c> lineCriteriaList = new List<REN_Line_Criteria__c>();
		lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 1, RLM_Field_Type__c = CSM_Constants.TYPE_PICKLIST, RLM_Field_Name__c = 'StageName', RLM_Operator__c = '=', RLM_Values__c = 'Closed Won', RLM_Object_API_Name__c = 'Asset', REN_Renew_Configuration__c = configAsset.Id));
		lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 1, RLM_Field_Type__c = CSM_Constants.TYPE_PICKLIST, RLM_Field_Name__c = 'StageName', RLM_Operator__c = '=', RLM_Values__c = 'Closed Won', REN_Renew_Configuration__c = configSC.Id));
        lineCriteriaList.add(new REN_Line_Criteria__c(RLM_LineNo__c = 1, RLM_Field_Type__c = CSM_Constants.TYPE_PICKLIST, RLM_Field_Name__c = 'StageName', RLM_Operator__c = '=', RLM_Values__c = 'Closed Won', RLM_Object_API_Name__c = 'Opportunity',REN_Renew_Configuration__c = configOpp.Id));
        insert lineCriteriaList;
        system.assert(lineCriteriaList != null);        
         
        REN_Field_Mappings__c fmStage = getFieldMappingRec('PICKLIST', 'StageName', '', 'Opportunity', 'Opportunity', true, 'Closed Won');
        
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
                
        //Asset
        REN_Field_Mappings__c fmCompPrd = getFieldMappingRec('BOOLEAN', 'IsCompetitorProduct', '', 'Asset', 'OpportunityLineItem', true, 'false');      
        REN_Field_Mappings__c fmNameAsset = getFieldMappingRec('STRING', 'Name', 'Name', 'Asset', 'OpportunityLineItem', true, '');        
        REN_Field_Mappings__c fmQuantityAsset = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'Asset', 'OpportunityLineItem', true, '');        
        REN_Field_Mappings__c fmDescAsset = getFieldMappingRec('TEXTAREA', 'Description', 'Description', 'Asset', 'OpportunityLineItem', true, '');
        
        //Service Contracts
        REN_Field_Mappings__c fmNameSC  = getFieldMappingRec('STRING', 'Name', 'Name', 'ServiceContract', 'Opportunity', true, '');        
        REN_Field_Mappings__c fmOwnerSC = getFieldMappingRec('REFERENCE', 'OwnerId', 'OwnerId', 'ServiceContract', 'Opportunity', true, '');        
        REN_Field_Mappings__c fmUnitPriceSC = getFieldMappingRec('DOUBLE', 'UnitPrice', 'UnitPrice', 'ContractLineItem', 'OpportunityLineItem', true, '');        
        REN_Field_Mappings__c fmQtySC = getFieldMappingRec('DOUBLE', 'Quantity', 'Quantity', 'ContractLineItem', 'OpportunityLineItem', true, '');        
        
        //Renewabale Line Item
        REN_Field_Mappings__c fmQtyRLI = getFieldMappingRec('DOUBLE', 'REN_Quantity__c', 'Quantity',REN_Constants.OBJ_REN_RENEWS_TO, REN_Constants.OBJ_OPPTY_LINE_ITEM, false, '');        
        
        List<REN_Field_Mappings__c> fMappingList = new List<REN_Field_Mappings__c>();
        fMappingList.add(fmStage);
        fMappingList.add(fmOwner);
        fMappingList.add(fmName);
        fMappingList.add(fmPrivate);
        fMappingList.add(fmProb);
        fMappingList.add(fmCloseDt);       
        fMappingList.add(fmQuantityOpLn);
        fMappingList.add(fmServDtOpLn);       
        fMappingList.add(fmCompPrd);
        fMappingList.add(fmNameAsset);
        fMappingList.add(fmQuantityAsset);
        fMappingList.add(fmDescAsset);       
        fMappingList.add(fmNameSC);
        fMappingList.add(fmOwnerSC);
        fMappingList.add(fmQtyRLI);
        fMappingList.add(fmQtySC);      
        insert fMappingList;
		
		String standardPriceBookId = Test.getStandardPricebookId();
		
		Product2 p2 = new Product2(Name = 'Test Product', isActive = true,ProductCode ='IN7080');
		insert p2;
		system.assert(p2.Id != null);
		
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = p2.Id, UnitPrice = 99, isActive = true);
		insert pbe;
		system.assert(pbe.Id != null);
		
		List <OpportunityLineItem> opliList = new List <OpportunityLineItem> ();
		OpportunityLineItem oli = new OpportunityLineItem();
		oli.UnitPrice = 50000;
		oli.ServiceDate = System.today();
		oli.Description = 'Desc 1';
		oli.Quantity = 1;
		oli.PricebookEntryId = pbe.Id;
		oli.OpportunityId = opportunityList[0].Id;
		opliList.add(oli);
		insert opliList;
        system.assert(opliList!=null);
        
		Test.startTest();
			REN_Value_Mapping__c newValuMapp = new REN_Value_Mapping__c();
			newValuMapp.REN_Record_Key__c = REN_Constants.REN_RLI_DATE_MAP;
			newValuMapp.REN_Value__c = 'REN_Start_Date__c';
			newValuMapp.Name = 'Test';
			insert newValuMapp;
			CSM_TriggerManager.disableAllTriggers();
        	REN_NonSimplifiedRenewalHandler.renewOpportunity(opportunityList);  
        Test.stopTest();      
	}
	static REN_Field_Mappings__c getFieldMappingRec(String dataType, String toName, String fromName, String toObject, String fromObject, 
                                                    Boolean isRequired, String defaultValue){
        REN_Field_Mappings__c fm = new REN_Field_Mappings__c();
        fm.REN_Field_Data_Type__c = dataType;
        fm.REN_To_Field_API_Name__c = toName;
        fm.REN_From_Field_API_Name__c = fromName;
        fm.REN_To_Object_API_Name__c = toObject;
        fm.REN_From_Object_Api_Name__c = fromObject;
        fm.REN_Is_Required__c = isRequired;
        fm.REN_Default_Value__c = defaultValue;
        return fm;
    }
    
}