public with sharing class REN_ContractLineItemDataAccess {
	
	public static List<sObject> getContractLineItemsWithoutRenewalItems(Set<ID> contractLineItemIdSet){
    	String columnString = CSM_Util.getColumns(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
    	if(contractLineItemIdSet == null || contractLineItemIdSet.isEmpty() || String.isBlank(columnString)){
    		return null;
    	} 
    	// VCP - ORG21 check
    	List<String> fieldList = new List<String>{'pricebookentryid', 'status', 'totalprice', 'servicecontractid', 'listprice', CSM_Util.nameSpacePrefix21 + 'ren_oppty_line_item_id__c', 'createddate', 'subtotal', 'lineitemnumber', 'createdbyid', 'lastvieweddate', 'discount', 'lastmodifieddate', 'id', 'unitprice', 'startdate', 'lastreferenceddate', 'description', 'isdeleted', 'quantity', 'enddate', 'systemmodstamp', 'lastmodifiedbyid', 'assetid'};
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_CONTRACT_LINE_ITEM, fieldList, CSM_Constants.DML_OPERATION_READ);
    	// VCP - ORG21 check
    	String queryString = 'Select ' + columnString + (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID)?', ServiceContract.' + CSM_Util.nameSpacePrefix21 + 'REN_Renewal_Opportunity__c':'') + ' from ' + REN_Constants.OBJ_CONTRACT_LINE_ITEM + ' where ID in :contractLineItemIdSet ' + (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID)?'AND ServiceContract.' + CSM_Util.nameSpacePrefix21 + 'REN_Renewal_Opportunity__c != null':''); 
    	system.debug('\n\n~~~~ queryString:' + queryString);
    	List<sObject> contractLineItemList = Database.query(queryString);
    	return contractLineItemList;
	}
	
	public static List<sObject> getContractLineItemsDetails(Set<ID> contractLineItemIdSet){
    	String columnString = CSM_Util.getColumns(REN_Constants.OBJ_CONTRACT_LINE_ITEM);
    	if(contractLineItemIdSet == null || contractLineItemIdSet.isEmpty() || String.isBlank(columnString)){
    		return null;
    	} 
    	// VCP - ORG21 check
    	List<String> fieldList = new List<String>{'pricebookentryid', 'status', 'totalprice', 'servicecontractid', 'listprice', CSM_Util.nameSpacePrefix21 + 'ren_oppty_line_item_id__c', 'createddate', 'subtotal', 'lineitemnumber', 'createdbyid', 'lastvieweddate', 'discount', 'lastmodifieddate', 'id', 'unitprice', 'startdate', 'lastreferenceddate', 'description', 'isdeleted', 'quantity', 'enddate', 'systemmodstamp', 'lastmodifiedbyid', 'assetid'};
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_CONTRACT_LINE_ITEM, fieldList, CSM_Constants.DML_OPERATION_READ);
    	// VCP - ORG21 check
    	String queryString = 'Select ' + columnString +', pricebookentry.product2Id'+ (CSM_AccessController.hasField(REN_Constants.OBJ_SERVICECONTRACT, CSM_Util.nameSpacePrefix21 + REN_Constants.OBJ_SC_REN_OPPTID)?', ServiceContract.' + CSM_Util.nameSpacePrefix21 + 'REN_Renewal_Opportunity__c':'') + ' from ' + REN_Constants.OBJ_CONTRACT_LINE_ITEM + ' where ID in :contractLineItemIdSet '; 
    	system.debug('\n\n~~~~ queryString:' + queryString);
    	List<sObject> contractLineItemList = Database.query(queryString);
    	return contractLineItemList;
	}
	
	public static List<sObject> getContractLineItemsByAccount(String accountId){
    	//system.debug('columnString B4: '+columnString);
    	String columnString = getColumnStringForCLI();
    	//String queryString = 'Select ServiceContract.name, ServiceContract.ContractNumber, ServiceContract.accountID, PricebookEntry.Name, ' + columnString + customField + ' from ' + REN_Constants.OBJ_CONTRACT_LINE_ITEM + ' where ServiceContract.accountID = :accountId ';
    	String queryString = 'Select ' + columnString + ' from ' + REN_Constants.OBJ_CONTRACT_LINE_ITEM + ' where ServiceContract.accountID = :accountId limit 10000'; 
    	system.debug('\n\n~~~~ queryString:' + queryString);
    	List<sObject> contractLineItemList = Database.query(queryString);
    	return contractLineItemList;
	}
	public static List<Database.SaveResult> insertContractLineItem(List<SObject> contractLineItemList){
    	List<Database.SaveResult> queryResultList = null;
		if(!contractLineItemList.isEmpty()){
			List<String> cliFieldList = new List<String>{'id', 'unitprice', 'startdate', 'quantity', 'enddate'};	 
			CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_CONTRACT_LINE_ITEM, cliFieldList, CSM_Constants.DML_OPERATION_INSERT);												
			queryResultList = Database.insert(contractLineItemList , false);
		}
		return queryResultList;
    }
    public static List<SObject> getCLIBySOSL(CHL_GridInputWrapper inputWrapper)
	{
		String columnString = getColumnStringForCLI();
		Integer queryLimit = inputWrapper.lm == 5 ? 5 : 2000;
		//String queryString = 'FIND\''+ inputWrapper.q +'*\' IN All Fields Returning '+REN_Constants.OBJ_CONTRACT_LINE_ITEM+' ('+fieldList+' ORDER BY ServiceContract.ContractNumber Desc) Limit '+queryLimit;
		String queryString = 'FIND\''+ inputWrapper.q +'*\' IN All Fields Returning '+REN_Constants.OBJ_CONTRACT_LINE_ITEM+' ('+columnString+' ORDER BY ServiceContract.ContractNumber Desc) Limit '+queryLimit;
   		system.debug('queryString : '+queryString);
		List<List<SObject>>searchList = search.query(queryString);
		system.debug('searchList::'+searchList);
		List<sObject> cliList = new List<sObject>();
		if(searchList != null && searchList.size()>0){
			cliList.addAll(searchList[0]);
		}
		return cliList;
	}
	
	public static String getColumnStringForCLI() {
		List<String> fieldList = new List<String>{'status', 'totalprice', 'servicecontractid', 'listprice', 'subtotal', 'lineitemnumber', 'id', 'unitprice', 'startdate', 'quantity', 'enddate'};
    	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_CONTRACT_LINE_ITEM, fieldList, CSM_Constants.DML_OPERATION_READ);
    	
    	//get fields from the field set
    	Set<String> fieldsFromFieldSet;
    	if(Test.isRunningTest()) {        	
        	fieldsFromFieldSet = new Set<String>{'status','totalprice','servicecontractid', 'listprice', 'subtotal', 'lineitemnumber', 'id', 'unitprice', 'startdate', 'quantity', 'enddate'};//CHL_Util.getFieldsFromFieldSet(CSM_Util.getNamespace()+'CHL_Asset_Account_Details_Community', 'Asset');  	    	
        } else {
        	fieldsFromFieldSet = CHL_Util.getFieldsFromFieldSet(CSM_Util.nameSpacePrefix21+'CHL_CLI_Account_Details_Community', 'ContractLineItem');
    	}
    	System.debug('fieldsFromFieldSet===' + fieldsFromFieldSet);
    	String columnString = '';
		if (!fieldsFromFieldSet.contains('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_1__c') && CSM_AccessController.hasField('ServiceContract', CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_1__c')) {
			fieldsFromFieldSet.add('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_1__c');
		}
		if (!fieldsFromFieldSet.contains('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_2__c') && CSM_AccessController.hasField('ServiceContract', CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_2__c')) {
			fieldsFromFieldSet.add('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_2__c');
		}
		if (!fieldsFromFieldSet.contains('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_1_Contact__c') && CSM_AccessController.hasField('ServiceContract', CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_1_Contact__c')) {
			fieldsFromFieldSet.add('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_1_Contact__c');
		}
		if (!fieldsFromFieldSet.contains('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_2_Contact__c') && CSM_AccessController.hasField('ServiceContract', CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_2_Contact__c')) {
			fieldsFromFieldSet.add('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_2_Contact__c');
		}
		if (!fieldsFromFieldSet.contains('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_1_Type__c') && CSM_AccessController.hasField('ServiceContract', CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_1_Type__c')) {
			fieldsFromFieldSet.add('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_1_Type__c');
		}
		if (!fieldsFromFieldSet.contains('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_2_Type__c') && CSM_AccessController.hasField('ServiceContract', CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_2_Type__c')) {
			fieldsFromFieldSet.add('ServiceContract.'+CSM_Util.nameSpacePrefix21+'CHL_Partner_Account_2_Type__c');
		}
		if (!fieldsFromFieldSet.contains('ServiceContract.name')) {
			fieldsFromFieldSet.add('ServiceContract.name');
		}
		if (!fieldsFromFieldSet.contains('PricebookEntry.Name')) {
			fieldsFromFieldSet.add('PricebookEntry.Name');
		}
		if (!fieldsFromFieldSet.contains('ServiceContract.AccountId')) {
			fieldsFromFieldSet.add('ServiceContract.AccountId');
		}
		for (String queryFld : fieldsFromFieldSet) {
			columnString += queryFld+',';
		} 
    	columnString = columnString.removeEnd(',');
    	return columnString;
	}
	
	public static List<sObject> getCLIfromSCId(Set<Id> scId, Set<String> cliFieldSet){
		List<String> contractlIneItemFieldList = new List<String>();
		Set<Id> setContractLineIds = new Set<Id>();
        
        contractlIneItemFieldList.addAll(cliFieldSet);
		
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_CONTRACT_LINE_ITEM, contractlIneItemFieldList, CSM_Constants.DML_OPERATION_READ);
			
		String soql = 'Select ServiceContract.Name, ServiceContract.ContractNumber, ServiceContract.TotalPrice,PricebookEntry.Product2.Id, PricebookEntry.Product2.Name, PricebookEntry.Product2Id ' 
        + (contractlIneItemFieldList.isEmpty() ? '' : ', ' + (String.join(contractlIneItemFieldList, ', '))) + ' From ContractLineItem Where ServiceContractId IN :scId';
		return Database.query(soql);
	}
	
}