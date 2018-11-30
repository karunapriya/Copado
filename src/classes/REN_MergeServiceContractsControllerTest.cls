@isTest(SeeAllData = true)
private class REN_MergeServiceContractsControllerTest {
	static testMethod void Test_validateConsolidatedServiceContracts() {
		system.assert(true);
	}
    /* This test class is deprecated under US3293
    
    static testMethod void Test_validateConsolidatedServiceContracts() {
        CSM_Constants.ACCOUNT_TRIGGER = false;
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<SObject> serviceContractList = CSM_TestDataUtility.createServiceContract(2, accountList[0].id);
        //serviceContractList[0].REN_Is_Consolidated__c = true;
        if (!serviceContractList.isEmpty()){
        	// VCP - ORG21 check
            if (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED)){
                serviceContractList[0].put(CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_IS_CONSOLIDATED, true);
                update serviceContractList[0];
            }
        }
        String scIdParam = '';
        for(SObject sc : serviceContractList){
            if(String.isBlank(scIdParam)){
                scIdParam = scIdParam + sc.get('Id');
            }else{
                scIdParam = scIdParam + '-' + sc.get('Id');
            }
        }
        Test.startTest();
        PageReference pageRefVF = Page.REN_MergeServiceContracts;
        Test.setCurrentPageReference(pageRefVF);
        System.currentPageReference().getParameters().put('serviceContractIds', scIdParam);
        REN_MergeServiceContractsController controller = new REN_MergeServiceContractsController();
        Test.stopTest();
        system.assert(System.currentPageReference().getParameters().get('serviceContractIds') == scIdParam);

    }
    
    static testMethod void Test_MergeServiceContracts_Positive() {
        CSM_Constants.ACCOUNT_TRIGGER = false;
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        system.assert(accountList != null);
        List<SObject> serviceContractList = CSM_TestDataUtility.createServiceContract(2, accountList[0].id);
        String standardPriceBookId = Test.getStandardPricebookId();
        Product2 p2 = new Product2(Name='Test Product',isActive=true);
        insert p2;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=p2.Id, UnitPrice=99, isActive=true);
        insert pbe;
        if (!serviceContractList.isEmpty()){
            serviceContractList[0].put(REN_Constants.OBJ_SC_PRICEBOOK2_ID,standardPriceBookId);
            serviceContractList[1].put(REN_Constants.OBJ_SC_PRICEBOOK2_ID,standardPriceBookId);
            
            update serviceContractList;
        }                
        List<SObject> scliList = new List<SObject>();
        for(Integer i=0; i<5; i++){
            if (CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT)){
                SObject newscl = CSM_AccessController.newSObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
                newscl.put(REN_Constants.OBJ_SCLI_UNITPRICE,50000);
                newscl.put(REN_Constants.OBJ_SCLI_DESCRIPTION, 'Desc 1');
                newscl.put(REN_Constants.OBJ_SCLI_QUANTITY, 1);
                newscl.put(REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID, pbe.Id);
                if(i < 2){
                    newscl.put(REN_Constants.OBJ_SCLI_SERVICECONTRACTID,serviceContractList[0].get('Id'));
                }else{
                    newscl.put(REN_Constants.OBJ_SCLI_SERVICECONTRACTID, serviceContractList[1].get('Id'));
                }
                scliList.add(newscl);
            }
        }
        if (!scliList.isEmpty()){
            insert scliList;
        }
        String scIdParam = '';
        for(SObject sc : serviceContractList){
            if(String.isBlank(scIdParam)){
                scIdParam = scIdParam + sc.get('Id');
            }else{
                scIdParam = scIdParam + '-' + sc.get('Id');
            }
        }
        Test.startTest();
        PageReference pageRefVF = Page.REN_MergeServiceContracts;
        Test.setCurrentPageReference(pageRefVF);
        System.currentPageReference().getParameters().put('serviceContractIds', scIdParam);
        REN_MergeServiceContractsController controller = new REN_MergeServiceContractsController();
        
        controller.selectedValuesJson = '{"Name":"New SContract 1","AccountId":"' +accountList[0].id +'"}';//'","StartDate":"' + controller.serviceContractList[0].get('StartDate')+ //'","EndDate":"' +(System.Today() + 2) + '"}';//JSON.serialize(controller.serviceContractList[0]);
        if (controller.serviceContractList!=null){
            controller.selectedMasterId = controller.serviceContractList[0].Id;
        }
        controller.mergeServiceContracts();
        Test.stopTest();

    }
    
     static testMethod void Test_Cancel() {
        CSM_Constants.ACCOUNT_TRIGGER = false;
        List<Account> accountList = CSM_TestDataUtility.createAccount(1);
        List<SObject> serviceContractList = CSM_TestDataUtility.createServiceContract(2, accountList[0].id);
        String scIdParam = '';
        for(SObject sc : ServiceContractList){
            if(String.isBlank(scIdParam)){
                scIdParam = scIdParam + sc.get('Id');
            }else{
                scIdParam = scIdParam + '-' + sc.get('Id');
            }
        }
        Test.startTest();
        PageReference pageRefVF = Page.REN_MergeServiceContracts;
        Test.setCurrentPageReference(pageRefVF);
        System.currentPageReference().getParameters().put('serviceContractIds', scIdParam);
        REN_MergeServiceContractsController controller = new REN_MergeServiceContractsController();
        PageReference cancelRef = controller.cancel();
        system.assert(cancelRef != null);
        Test.stopTest();

    }   
    static testMethod void Test_serviceContractDataMethods()	{
    	CSM_Constants.ACCOUNT_TRIGGER = false;
    	 system.assert(true);
    	if (CSM_AccessController.hasObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM)){
	    	List<Account> accountList = CSM_TestDataUtility.createAccount(1);
	        List<SObject> serviceContractList = CSM_TestDataUtility.createServiceContract(2, accountList[0].id);
	        List<SObject> serviceContractDataList = REN_ServiceContractsDataAccess.getContractLineItemList(new List<String>{accountList[0].id}, 'ServiceContract.Name', CSM_Constants.SORT_DIRECTION_DESCENDING,null);
	    	system.assert(serviceContractDataList != null);
	    	List<Product2> productList = new List<Product2>();
	    	if (serviceContractList != null && !serviceContractList.isEmpty()){
	            system.assert(accountList.get(0).Id != null);
	            for(Integer i=0; i < 5; i++){
	                productList.add(REN_TestDataUtility.createProduct(i));
	            }
	            insert productList;
	            List<PricebookEntry> pbEntryList = new List<PricebookEntry>();
	            for(Product2 prod : productList){
	                pbEntryList.add(REN_TestDataUtility.createPBEntry(prod.Id));
	            }
	            insert pbEntryList;
	                SObject contractLineItem;
	                List<SObject> contractLineItemList = new List<SObject>();
	                for(PricebookEntry pbr : pbEntryList){
	                    contractLineItem = CSM_AccessController.newSObject(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
	                    contractLineItem.put(REN_Constants.OBJ_SCLI_PRICEBOOKENTRYID,pbr.Id);
	                    contractLineItem.put(REN_Constants.OBJ_SCLI_QUANTITY,1);
	                    contractLineItem.put(REN_Constants.OBJ_OLI_UNITPRICE,pbr.UnitPrice);
	                    contractLineItem.put(REN_Constants.OBJ_SCLI_STARTDATE,Date.Today());
	                    contractLineItem.put(REN_Constants.OBJ_SCLI_ENDDATE,Date.Today().addYears(1));
	                    contractLineItem.put(REN_Constants.OBJ_SCLI_SERVICECONTRACTID, serviceContractList[0].Id);
	                    contractLineItemList.add(contractLineItem); 
	                }
	                insert contractLineItemList;
	                List<String> contractLineItemIdlist = new List<String>();
	                if(contractLineItemList != null && !contractLineItemList.isEmpty())	{
	                	contractLineItemIdlist.add(contractLineItemList[0].Id);
	                	//contractLineItemIdlist.add();
	                }
	                List<SObject> contractLineItemDataList  = REN_ServiceContractsDataAccess.getContractLineItemListById(contractLineItemIdlist, new Set<String>());
	                system.assert(contractLineItemDataList != null);
	            
	            Map<String,string> ServiceContractOptyMap = REN_ServiceContractsDataAccess.getServiceContractOpportunityMap(serviceContractList);
	            system.assert(ServiceContractOptyMap != null);
	            Map<String,string> OpptyServiceContractMap = REN_ServiceContractsDataAccess.getOpportunityServiceContractMap(serviceContractList);
	            system.assert(OpptyServiceContractMap != null);
	            List<Opportunity> opportunityList = CSM_TestDataUtility.createOpportunity(1, accountList[0].id);
	            List<Opportunity> filterOpptylist = REN_ServiceContractsDataAccess.filterOpptyListWithoutAccount(opportunityList);
	            system.assert(filterOpptylist != null);
	            
	    	}
    	}
    } */
}