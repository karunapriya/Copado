/**
 * Created Date		: Sep 13, 2016
 * Developed By		: Chandra, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Chandra					User Story				Sep 13, 2016			1.1					@description
 *
 *
 * Comity Designs, Inc. 2016 - All Rights Reserved.
 */
@isTest
private class RenewableLineItemHandlerHelperTest {
	public static String prefixName = '';
	public static List<Product2> product2List;
	public static List<PricebookEntry> pricebookEntryList;
	
	public static Map<String, REN_Renew_Configuration__c> renewConfigurationMap;
	
	public static List<Account> accountList;
	public static List<Opportunity> opportunityList;
	public static List<OpportunityLineItem> opportunityLineItemList;
	public static List<REN_Renews_To__c> renewalLineItemList;
	/**
	 * Method to create test records once and use for all the methods in this test class
	 */ 
    
    public static List<Opportunity> testDataSetup(Integer totalAccounts, Integer noOfOpportunityInEachAccount, Integer noOfOpportunityLineItemInEachOppty) {
    	checkAssertForVariables();
    	createProduct(noOfOpportunityLineItemInEachOppty);
		createPricebookEntry(product2List, null);
		createAccount(totalAccounts);
		createOpportunity(noOfOpportunityInEachAccount, accountList);
		createRenewalLineItem(opportunityList);
		
		System.debug(LoggingLevel.WARN,'\n\n~@~ Created Data: ' 
		  + '\n product2List: ' + product2List.size() + ':- ' + product2List
		  + '\n accountList: ' + accountList.size() + ':- ' + accountList
		  + '\n opportunityList: ' + opportunityList.size() + ':- ' + opportunityList
		  +' ---- RLI ---'+renewalLineItemList
		);        
		system.assert(opportunityList[0].id != null);
		return opportunityList;
    }
	
	public static List<Product2> createProduct(Integer recordCount){
    	product2List = new List<Product2>();
		for (integer i=1; i<=recordCount; i++){
			Product2 prod = new Product2();
			prod.Name = prefixName + 'Test Product_' + i;
			prod.IsActive = true;
			prod.ProductCode = 'TP' + i;
			product2List.add(prod);
		}
    	insert product2List;
    	system.assert(product2List[0].id != null);
    	return product2List;
	}
	
	public static List<PricebookEntry> createPricebookEntry(List<Product2> product2ListParam, Id pricebook2Id){
		
		if(pricebook2Id == null){
			List<Pricebook2> pbList = [select id, name, isActive from Pricebook2 where IsStandard = true ];
			if(pbList != null && !pbList.isEmpty()){
				pricebook2Id = pbList[0].id;
			}
		}
		pricebookEntryList = new List<PricebookEntry>();
		Integer i = 1;
    	for(Product2 a: product2ListParam){
			PricebookEntry pbe = new PricebookEntry();
			pbe.Product2Id = a.id;
			pbe.Pricebook2Id = Test.getStandardPricebookId();
			pbe.UnitPrice = i++ * 100 + 1;
			pbe.IsActive = true;
			pricebookEntryList.add(pbe);
    	}
    	
    	insert pricebookEntryList;
    	System.assert(pricebookEntryList != null);
		return pricebookEntryList;
	}
	
	public static List<Account> createAccount(Integer recordCount) {
    	accountList = new List<Account>();
    	for (integer i=1; i<=recordCount; i++){
    		Account newAccount = new Account();
    		newAccount.Name = prefixName + 'Test-Account ' + i;
    		accountList.add(newAccount);
    	}
    	insert accountList;
    	system.assert(accountList[0].id != null);
    	return accountList;    
    }  
	
	public static List<Opportunity> createOpportunity(Integer recordCountForEachAccount, List<Account> accountListParam){
    	opportunityList = new List<Opportunity>();
    	if(accountListParam == null){
    		accountListParam = new List<Account>();
    	}
    	if(accountListParam.isEmpty()){
    		accountListParam.add(new Account());
    	}
    	for(Account a: accountListParam){
	    	for(integer i=1; i<=recordCountForEachAccount; i++){
	    		Opportunity newOpportunity = new Opportunity();
	    		newOpportunity.accountId = a.id;
	    		newOpportunity.Name = prefixName + 'Original Opp ' + i;
	    		newOpportunity.CloseDate = System.Today();
	    		newOpportunity.StageName = 'Qualification';
	    		newOpportunity.Type = 'New Customer';
	    		opportunityList.add(newOpportunity);
	    	}
    	}
    	insert opportunityList;
    	system.assert(opportunityList[0].id != null);
    	return opportunityList;
    }    
	
    public static List<REN_Renews_To__c> createRenewalLineItem(List<Opportunity> opportunityListParam){
    		 renewalLineItemList = new List<REN_Renews_To__c>();
    		renewalLineItemList.add(new REN_Renews_To__c(REN_Renews_To__c = opportunityListParam[0].Id,REN_Product__c = product2List[0].id, OwnerID = Userinfo.getUserId(),REN_Start_Date__c = System.today(), REN_End_Date__c = System.today()+1, 
    		REN_New_End_Date__c = System.today()+1,REN_Quantity__c = 1,REN_New_Start_Date__c = System.today(),
    		Previous_Local_Currency_Code__c = 'USD',Previous_Local_Currency_Amount__c = 1000, Batch_Type__c = 'Expired'
	    ));
	    insert renewalLineItemList;
	    system.assert(renewalLineItemList[0].id != null);
	    renewalLineItemList[0].Previous_Local_Currency_Code__c = 'EUR';
	    update renewalLineItemList;
	    system.assert(renewalLineItemList[0].id != null);
	    return renewalLineItemList;
    }
    
    
    public static void checkAssertForVariables(){
   		system.assert(product2List==null);
   		system.assert(pricebookEntryList==null);
   		system.assert(renewConfigurationMap==null);
   		system.assert(opportunityList==null);
   		system.assert(renewalLineItemList==null);
   }
   
    
}