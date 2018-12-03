@isTest(SeeAllData = false) 
private class REN_CreateOptyFromContractControllerTest {
	static REN_CreateOptyFromServiceContractCtrl controller;
	static User createUser(String profileName)
	{
		//Id profileId
		Profile renewProfile = [Select Name, Id From Profile where Name = :profileName limit 1]; 
		User renewUsr =  CSM_TestDataUtility.CreateUser(renewProfile.Id);
		insert renewUsr;
		system.assert(renewUsr != null);
		return renewUsr;
	}
	static List < Opportunity > setup(){		
		List<REN_Renew_Configuration__c> renewConfigurationList = new List<REN_Renew_Configuration__c>();
        renewConfigurationList = REN_TestDataUtility.createRenewConfigurationDatalist();
        upsert renewConfigurationList;
		system.assert(renewConfigurationList != null);
		//Name
		REN_Field_Mappings__c fm1 = new REN_Field_Mappings__c();
		fm1.REN_Field_Data_Type__c = 'STRING';
		fm1.REN_To_Field_API_Name__c = 'Name';
		fm1.REN_From_Field_API_Name__c = 'Name';
		fm1.REN_To_Object_API_Name__c = 'Opportunity';
		fm1.REN_From_Object_Api_Name__c = 'ServiceContract';
		fm1.REN_Is_Required__c = true;
		//OwnerId
		REN_Field_Mappings__c fm2 = new REN_Field_Mappings__c();
		fm2.REN_Field_Data_Type__c = 'REFERENCE';
		fm2.REN_To_Field_API_Name__c = 'OwnerId';
		fm2.REN_From_Field_API_Name__c = 'OwnerId';
		fm2.REN_To_Object_API_Name__c = 'Opportunity';
		fm2.REN_From_Object_Api_Name__c = 'ServiceContract';
		fm2.REN_Is_Required__c = true;


		REN_Field_Mappings__c fm5 = new REN_Field_Mappings__c();
		fm5.REN_Field_Data_Type__c = 'DATE';
		fm5.REN_To_Field_API_Name__c = 'CloseDate';
		fm5.REN_From_Field_API_Name__c = 'StartDate';
		fm5.REN_To_Object_API_Name__c = 'Opportunity';
		fm5.REN_From_Object_Api_Name__c = 'ServiceContract';
		fm5.REN_Is_Required__c = true;


		REN_Field_Mappings__c fm7 = new REN_Field_Mappings__c();
		fm7.REN_Field_Data_Type__c = '';
		fm7.REN_To_Field_API_Name__c = 'IsPrivate';
		fm7.REN_To_Object_API_Name__c = 'Opportunity';
		fm7.REN_From_Object_Api_Name__c = 'ServiceContract';
		fm7.REN_Is_Required__c = true;
		fm7.REN_Default_Value__c = 'false';
		
		REN_Field_Mappings__c fm6 = new REN_Field_Mappings__c();
		fm6.REN_Field_Data_Type__c = '';
		fm6.REN_To_Field_API_Name__c = 'StageName';
		fm6.REN_From_Field_API_Name__c = 'Status';
		fm6.REN_To_Object_API_Name__c = 'Opportunity';
		fm6.REN_From_Object_Api_Name__c = 'ServiceContract';
		fm6.REN_Is_Required__c = true;



		//UnitPrice
		REN_Field_Mappings__c fm3 = new REN_Field_Mappings__c();
		fm3.REN_Field_Data_Type__c = 'CURRENCY';
		fm3.REN_To_Field_API_Name__c = 'UnitPrice';
		fm3.REN_From_Field_API_Name__c = 'UnitPrice';
		fm3.REN_To_Object_API_Name__c = 'OpportunityLineItem';
		fm3.REN_From_Object_Api_Name__c = 'ContractLineItem';
		fm3.REN_Is_Required__c = true;
		//Quantity
		REN_Field_Mappings__c fm4 = new REN_Field_Mappings__c();
		fm4.REN_Field_Data_Type__c = 'DOUBLE';
		fm4.REN_To_Field_API_Name__c = 'Quantity';
		fm4.REN_From_Field_API_Name__c = 'Quantity';
		fm4.REN_To_Object_API_Name__c = 'OpportunityLineItem';
		fm4.REN_From_Object_Api_Name__c = 'ContractLineItem';
		fm4.REN_Is_Required__c = true;
		
		REN_Field_Mappings__c fm11 = new REN_Field_Mappings__c();
		fm11.REN_Field_Data_Type__c = 'Number';
		fm11.REN_To_Field_API_Name__c = 'REN_Quantity__c';
		fm11.REN_From_Field_API_Name__c = 'Quantity';
		fm11.REN_To_Object_API_Name__c = 'REN_Renews_To__c';
		fm11.REN_From_Object_Api_Name__c = 'OpportunityLineItem';
		fm11.REN_Is_Required__c = true;
		
		List <REN_Field_Mappings__c> fMappingList = new List <REN_Field_Mappings__c> ();
		fMappingList.add(fm1);
		fMappingList.add(fm2);
		fMappingList.add(fm3);
		fMappingList.add(fm5);		
		fMappingList.add(fm6);		
		fMappingList.add(fm7);
		fMappingList.add(fm4);
		fMappingList.add(fm11);
		
		
		insert fMappingList;
      
		Product2 prod1 = new Product2(Name = 'Test Product 1', IsActive = true);
		insert prod1;
		system.assert(prod1.Id != null);
		String standardPriceBookId = Test.getStandardPricebookId();
		PricebookEntry price1 = new PricebookEntry(UseStandardPrice = false, Pricebook2Id = standardPriceBookId, UnitPrice = 1.0, IsActive = true, Product2Id = prod1.Id);
		insert price1;
		system.assert(price1.Id != null);

		Account a = new Account(Name = 'RENEW DIRECT Test Account A');
		insert a;
		system.assert(a.Id != null);
		List < Opportunity > testOppList = new List < Opportunity > ();
		for (Integer i = 0; i < 10; i++) {
			testOppList.add(new Opportunity(Name='MyTestoff'+i, StageName = 'Prospecting',
			CloseDate = System.Today(), AccountId = a.Id, Type = 'New Customer'));
		}
		insert testOppList;
		system.assert(testOppList != null);
		Boolean hasServiceContract = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT);

		if (hasServiceContract){
			List <OpportunityLineItem > testOppLineItemsList = new List < OpportunityLineItem > ();
			List <SObject> testServiceContractList = new List <SObject> ();
			Integer count = 0;
			for (Opportunity currentOpportunity: testOppList) {
				SObject serviceContract = CSM_AccessController.newSObject(REN_Constants.OBJ_SERVICE_CONTRACT);
				serviceContract.put('Name', 'test ServiceContract'+count);
				// VCP - ORG21 check
				if (CSM_AccessController.hasField(REN_Constants.OBJ_T_REN_OPPORTUNITY_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 +REN_Constants.OBJ_EXT_FIELD_SERVICE_CONTRACT)){
            		// VCP - ORG21 check
            		serviceContract.put(CSM_Util.nameSpacePrefix21 +'REN_Opportunity__c', currentOpportunity.Id);
				}
				serviceContract.put('Pricebook2Id', standardPriceBookId);
				testServiceContractList.add(serviceContract);
				count = count + 1;

				for (Integer i = 0; i < 2; i++) {
					testOppLineItemsList.add(new OpportunityLineItem(OpportunityId = currentOpportunity.Id, Quantity = 1.0, TotalPrice = 1.0, PricebookEntryId = price1.Id));
				}
			}
			insert testOppLineItemsList;
			system.assert(testOppLineItemsList != null);
			try {
				insert testServiceContractList;
			} catch (exception ex){
				system.debug('error message::'+ex.getMessage());
			}
			List<SObject> ContractLineItemList = new List<SObject>();
			for (SObject sc: testServiceContractList) {
				SObject cli = CSM_AccessController.newSObject('ContractLineItem');
				cli.put('ServiceContractId', sc.get(REN_Constants.OBJ_OP_ID));
				cli.put('UnitPrice', 100.00);
				cli.put('Discount', 1);
				cli.put('Quantity', 1.0);
				cli.put('PricebookEntryId', price1.Id);
				ContractLineItemList.add(cli);
			}
			try {
				insert ContractLineItemList;

			} catch (exception ex){
				system.debug('error message::'+ex.getMessage());
			}
			system.assert(ContractLineItemList != null);

		}
		return testOppList;
	} 
	
	static testMethod void testServiceContractCreation() {
		Test.startTest();
		User renewUsr = createUser('System Administrator');
		CSM_Constants.OPPORTUNITY_TRIGGER = true;
		CSM_TestUtility.addLicense();
		CSM_TestUtility.addRenewLicense();
		CSM_TestUtility.addCSMAdmin();
		List<Opportunity> lstOppt= setup();
		Set<Id> optyIds = new Set<Id>();
		for(Opportunity currentOpportunity : lstOppt)
		{
			currentOpportunity.StageName = 'Qualification';
			optyIds.add(currentOpportunity.Id);
		}
		CSM_Constants.OPPORTUNITY_TRIGGER = true;
		System.runAs(renewUsr)
		{
			try {
				update lstOppt;
			} catch (Exception ex){
				
			}
		}
		
		Boolean hasServiceContract = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT);
		if (hasServiceContract && optyIds !=null && !optyIds.isEmpty()) {
			String soql = 'SELECT Id';
			 
			// VCP - ORG21 check
			if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICE_CONTRACT, CSM_Util.nameSpacePrefix21 +REN_Constants.OBJ_OP_OPPORTUNITY)){
				// VCP - ORG21 check
				soql += ', ' + CSM_Util.nameSpacePrefix21 +'REN_Opportunity__c';
			}
			soql += ' FROM ServiceContract order by createdDate desc';
			List<SObject> scList = database.query(soql);
			system.assert(scList != null);
			if (!scList.isEmpty()) {
		    	ApexPages.StandardController sc = new ApexPages.StandardController(scList[0]);
				PageReference pageRef = Page.REN_CreateRenewOpptyFromServiceContract;
				pageRef.getParameters().put('contractId', String.valueOf(scList[0].Id));
		        Test.setCurrentPage(pageRef);
				String soqlContractLineItem = 'SELECT PricebookEntryId,Status,TotalPrice,ServiceContractId,ListPrice,CreatedDate,Subtotal,LineItemNumber,CreatedById,LastViewedDate,Discount,LastModifiedDate,Id,UnitPrice,StartDate,LastReferencedDate,Description,IsDeleted,Quantity,EndDate,SystemModstamp,LastModifiedById,AssetId FROM ContractLineItem WHERE ServiceContractId=\''+String.valueOf(scList[0].Id)+'\'';                
				List<SObject> contractLineItemList = database.query(soqlContractLineItem); 
				REN_CreateOptyFromServiceContractCtrl testCreateOptyFromServiceContract = new REN_CreateOptyFromServiceContractCtrl();
				//MF Mike Set
				List<String> oIds =  new List<String>();
				For (Id i : optyIds)
				{
					oIds.add(i);
				}
				
				Map<Id, String> pbEntryIdToProdNameMap =  testCreateOptyFromServiceContract.getPbEntryIdToProdName(oIds);
				Map<Id, OpportunityLineItem> cliToOliMap = new Map<Id, OpportunityLineItem>();
				String currencyCode = '';
				if(CSM_AccessController.hasField('opportunity',  'CurrencyIsoCode')) {
					currencyCode = ',CurrencyIsoCode';
				}
				String queryString= 'select id, opportunityId, Quantity'+ currencyCode +',CreatedById , PricebookEntryId, Discount, Product2Id from OpportunityLineItem where OpportunityId in :optyIds limit 100';
				List<sObject> opptyLineList = Database.query(queryString);
				for(sObject opsLineObj:opptyLineList) {
					cliToOliMap.put(contractLineItemList[0].Id,(OpportunityLineItem)opsLineObj);
				}
				testCreateOptyFromServiceContract.populateOpliWrapperList(opptyLineList, pbEntryIdToProdNameMap);
				testCreateOptyFromServiceContract.save();
				REN_Value_Mapping__c newValuMapp = new REN_Value_Mapping__c();
				newValuMapp.REN_Record_Key__c = REN_Constants.REN_RLI_DATE_MAP;
				newValuMapp.REN_Value__c = 'REN_Start_Date__c';
				newValuMapp.Name = 'Test';
				insert newValuMapp;
				testCreateOptyFromServiceContract.saveRrFromContractLineItem(cliToOliMap);
		        system.assert(scList!= null);
		        
		        PageReference pr = testCreateOptyFromServiceContract.cancel();
		        system.assert(pr != null);
		       // getMappedContractLineBasedOli
			}
		}
		Test.stopTest();
	}
	static testMethod void testServiceContractCreationNegative() {
		Test.startTest();
		REN_CreateOptyFromServiceContractCtrl testCreateOptyFromServiceContract = new REN_CreateOptyFromServiceContractCtrl();
		testCreateOptyFromServiceContract.save();
		List<Opportunity> opList = setup();
		List<OpportunityLineItem> oliList = [select Id from OpportunityLineItem limit 2];
		REN_CreateOptyFromServiceContractCtrl.getMappedContractLineBasedOli(oliList[0], 'test', 'DOUBLE', null,'2.0', 'Quantity', 'Quantity');
		REN_CreateOptyFromServiceContractCtrl.getMappedContractLineBasedOli(oliList[0], 'test', 'PERCENT', null,'20', 'Discount', 'Discount');
		Test.stopTest();
	}
    
}