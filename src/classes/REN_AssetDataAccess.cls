public with sharing class REN_AssetDataAccess {
	
	public static List<Asset> getAssetDetailsById(List<String> assetIds, Set<String> fieldSet){
        List<Asset> tmplist = new List<Asset>();
        fieldSet.add('REN_Covered_Asset__c');
        Schema.SObjectType objectAsset = new Asset().getSobjectType();
		//Map<String, Schema.SobjectField> assetAllFieldNames = CSM_AccessController.fetchAllFieldNames(objectAsset);
		//String nameSpace = CSM_Util.getNamespace();
		List<String> assetFieldList = new List<String>();
		if(fieldSet == null || fieldSet.isEmpty()){
			assetFieldList = new List<String>{'id'};
		}else{
			assetFieldList = new List<String>(fieldSet);
		}
		
		/*
		for(Schema.SobjectField F :assetAllFieldNames.values())
		{
			String fldStr = F.getDescribe().getName();
	        if(nameSpace != null && nameSpace.length() > 0)
	        {
	        	fldStr = fldStr.replace(nameSpace, '');
	        }
	        assetFieldList.add(fldStr);
	        if(queryString.trim() != 'SELECT Product2.Name,')
	        {
	        	queryString += ', ';
	        }
	        queryString += fldStr;
		}
*/
		String queryString = 'SELECT Product2.Name, ' + (String.join(assetFieldList, ', ')) + ' FROM ' + REN_Constants.OBJ_ASSET + ' WHERE Id IN :assetIds'; 
		system.debug('queryString : ' + queryString);
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, assetFieldList, CSM_Constants.DML_OPERATION_READ);    
       	return Database.query(queryString); 
    }
    
	public static List<Asset> getAssetsByAccount(String accountId, String sortExpression, String sortDirection, String selectedCurr)
	{
     	List<String> fieldList = new List<String>{
										     		REN_Constants.OBJ_ASSET_OPPORTUNITY, 
										     		REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID
												 };
     	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, fieldList, CSM_Constants.DML_OPERATION_READ);
     	Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_ASSETS);
		String soql = 'Select Id, Name, SerialNumber, Product2Id, Product2.Name, Format(Quantity), Status, AccountId, Account.Name,' +
			   			' Format(REN_End_Date__c), Format(REN_Start_Date__c), ' + (UserInfo.isMultiCurrencyOrganization()?'convertCurrency(Price),':'format(Price),') + 
			   			' (Select Id, REN_Renews_To__c, REN_Renews_To__r.Name, REN_Renews_To__r.StageName, Format(REN_Renews_To__r.CloseDate) From Renew_To__r Limit 1) ';
		if(UserInfo.isMultiCurrencyOrganization())
		{
			soql += ', CurrencyIsoCode';
		}
		soql += ' From Asset Where AccountId = :accountId LIMIT ' + limitVal;
		system.debug('soql : ' + soql);

		List<Asset> assetList = Database.query(soql);		
        /*if(UserInfo.isMultiCurrencyOrganization())
        {
	        if(assetList != null)
	        {
	            for(SObject assetItem: assetList){
	            	String strValue = String.ValueOf(assetItem.get('Price'));
	            	Double convertedVal = REN_Util.convertCurrencyValue(Double.ValueOf(strValue),UserInfo.getDefaultCurrency(),selectedCurr);

					assetItem.put('Price',convertedVal);		            
	            }
	        }
        }*/

		return assetList;
		
    }
    
    public static List<Asset> getAssetsForClause(String whereClause)
	{
		return null;
	}
	
	public static List<Asset> getAssetsForClause(String whereClause, Boolean forDisplay, String selectedCurr){
		List<String> fieldList = new List<String>{
										     		REN_Constants.OBJ_ASSET_OPPORTUNITY, 
										     		REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID
												 };
     	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, fieldList, CSM_Constants.DML_OPERATION_READ);
     	Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_ASSETS);
		String soql = 'Select Id, Name, SerialNumber, Product2Id, Product2.Name, Format(Quantity), Status, AccountId, Account.Name,' +
			   			' Format(REN_End_Date__c), Format(REN_Start_Date__c), ' + (UserInfo.isMultiCurrencyOrganization()?'convertCurrency(Price),':'format(Price),') + 
			   			'(Select Id, REN_Renews_To__c, REN_Renews_To__r.Name, REN_Renews_To__r.StageName, Format(REN_Renews_To__r.CloseDate) From Renew_To__r Limit 1) ';
		if(UserInfo.isMultiCurrencyOrganization())
		{
			soql += ', CurrencyIsoCode';
		}
		if(forDisplay){
			limitVal = 20000;
		}
		soql += ' From Asset ' + whereClause  + ' LIMIT ' + limitVal;
		system.debug('soql : ' + soql);
		List<Asset> assetList = Database.query(soql);		
        /*if(UserInfo.isMultiCurrencyOrganization())
        {
	        if(assetList != null)
	        {
	            for(SObject assetItem: assetList){
	            	String strValue = String.ValueOf(assetItem.get('Price'));
	            	Double convertedVal = REN_Util.convertCurrencyValue(Double.ValueOf(strValue),UserInfo.getDefaultCurrency(),selectedCurr);
					assetItem.put('Price',convertedVal);		            
	            }
	        }
        }*/

		return assetList;

	}
	public static Integer getAssetsCounts(String whereClause, Integer recLimits){
		List<String> fieldList = new List<String>{};
     	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, fieldList, CSM_Constants.DML_OPERATION_READ);
     	Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_ASSETS);
		String soql = 'Select id From Asset ' + whereClause + (recLimits > 0 ? ' LIMIT ' + recLimits : '');
		List<Asset> aList = Database.query(soql);
		if(aList == null || aList.isEmpty()){
			return 0;
		}
		return aList.size();
	}
	public static List<Asset> getAllAssetFromOppts(Set<String> optyIdSet){
		List<String> fieldList = new List<String>{
										     		REN_Constants.OBJ_ASSET_OPPORTUNITY, 
										     		REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID,
										     		REN_Constants.OBJ_OPP_ACCOUNT,
										     		REN_Constants.FLD_ID,
										     		REN_Constants.FLD_NAME,
										     		REN_Constants.OBJ_ASSET_PRODUCT2ID
												 };
     	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, fieldList, CSM_Constants.DML_OPERATION_READ);
		return [Select Id, AccountId, Name, Product2Id, REN_Opportunity__c, REN_Oppty_Line_Item_Id__c From Asset 
                                            Where REN_Opportunity__c IN : optyIdSet limit 10000];
        
	}
	
	//Below Method is used in community to Show Assets related to selected Account
	public static List<Asset> getAssetsByAccountId(String accountId)
	{
     	List<String> fieldList = new List<String>{
										     		REN_Constants.OBJ_ASSET_PRICE, 
										     		REN_Constants.OBJ_FLD_START_DATE,
										     		REN_Constants.OBJ_FLD_END_DATE
												 };
     	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, fieldList, CSM_Constants.DML_OPERATION_READ);
     	//Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_ASSETS);
     	String namespace = CSM_Util.getNamespace();
     	Set<String> fieldsToAddInQuerySet = new Set<String>{'Id', 'Name', 'SerialNumber', 'Product2Id', 'Product2.Name', 'Quantity', 'Status', 
     													  'AccountId', 'Account.Name', namespace + 'REN_End_Date__c', namespace + 'REN_Start_Date__c', 'Price', namespace + 'CHL_Partner_Account_1__c', 
     													  namespace + 'CHL_Partner_Account_2__c', namespace + 'CHL_Partner_Account_1_Contact__c', namespace + 'CHL_Partner_Account_2_Contact__c',
     													  namespace + 'CHL_Partner_Account_1_Type__c', namespace + 'CHL_Partner_Account_2_Type__c'};

		
		if(UserInfo.isMultiCurrencyOrganization())
		{
			//soql += ', CurrencyIsoCode';
			fieldsToAddInQuerySet.add('CurrencyIsoCode');
		}
		Set<String> fieldsFromFieldSet = CHL_Util.getFieldsFromFieldSet(CSM_Util.getNamespace()+'CHL_Asset_Account_Details_Community', 'Asset');
		if (fieldsFromFieldSet != null && !fieldsFromFieldSet.isEmpty()) {
			for (String fld : fieldsFromFieldSet) {
				if (!fieldsToAddInQuerySet.contains(fld)) {
					fieldsToAddInQuerySet.add(fld);
				}
			}
		}

		String columnString = '';
		for (String queryFld : fieldsToAddInQuerySet) {
			columnString += queryFld+',';
		}
		columnString = columnString.removeEnd(',');
		String soql = '';
		soql = 'SELECT ' + columnString;
		soql += ' From Asset Where AccountId = :accountId LIMIT 10000' ;
		system.debug('soql : ' + soql);
		return Database.query(soql);
    }
    
    public static List<Asset> getAccountByAsset(Set<String> assetIdSet)
	{
     	List<String> fieldList = new List<String>{
										     		REN_Constants.OBJ_ASSET_PRICE, 
										     		REN_Constants.OBJ_FLD_START_DATE,
										     		REN_Constants.OBJ_FLD_END_DATE
												 };
     	CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, fieldList, CSM_Constants.DML_OPERATION_READ);
     	Integer limitVal = CSM_AdminDataAccess.getRecLimit(CSM_Constants.REC_LIMIT_ASSETS);
		String soql = 'Select AccountId ';
			   			
		if(UserInfo.isMultiCurrencyOrganization())
		{
			soql += ', CurrencyIsoCode';
		}
		soql += ' From Asset Where Id in :assetIdSet LIMIT ' + limitVal;
		system.debug('soql : ' + soql);
		return Database.query(soql);
    }
    public static List<Database.SaveResult> insertAssets(List<Asset> assetList){
    	List<Database.SaveResult> queryResultList = null;
		if(!assetList.isEmpty()){
			List<String> assetFieldList = new List<String>{REN_Constants.OBJ_ASSET_OPPORTUNITY, 
										     		REN_Constants.OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID,
										     		REN_Constants.OBJ_OPP_ACCOUNT,
										     		REN_Constants.FLD_ID,
										     		REN_Constants.FLD_NAME,
										     		REN_Constants.OBJ_ASSET_PRODUCT2ID};	 
			CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, assetFieldList, CSM_Constants.DML_OPERATION_INSERT);												
			queryResultList = Database.insert(assetList , false);
		}
		return queryResultList;
    }
    public static void createAssets(List<Asset> assetsToInsert, List<String> assetFields)
	{
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, assetFields, CSM_Constants.DML_OPERATION_INSERT);										
	    insert assetsToInsert;
	}
	
	public static void updateAssets(List<Asset> assetsToUpdate, List<String> assetFields)
	{
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ASSET, assetFields, CSM_Constants.DML_OPERATION_UPDATE);										
	    update assetsToUpdate;
	}
	
	public static List<SObject> getAssetsBySOSL(CHL_GridInputWrapper inputWrapper)
	{
		//String fieldList = '';
    	//for(String str:CHL_CONSTANTS.GRID_ASSET_COLUMNS) {
    		//fieldList += str+',';
	    //}
	    //fieldList = fieldList.removeEnd(',');
	    String namespace = CSM_Util.getNamespace(); 
	    Set<String> fieldsToAddInQuerySet = new Set<String>{'Product2.Name', 'Account.Name', namespace + 'CHL_Partner_Account_1__c', namespace + 'CHL_Partner_Account_2__c',
	    													namespace + 'CHL_Partner_Account_1_Contact__c',namespace + 'CHL_Partner_Account_2_Contact__c', 
	    													namespace + 'CHL_Partner_Account_1_Type__c', namespace + 'CHL_Partner_Account_2_Type__c'};
	    Set<String> fieldsFromFieldSet = CHL_Util.getFieldsFromFieldSet(CSM_Util.getNamespace()+'CHL_Asset_Account_Details_Community', 'Asset');

		if (fieldsFromFieldSet != null && !fieldsFromFieldSet.isEmpty()) {
			for (String fld : fieldsFromFieldSet) {
				if (!fieldsToAddInQuerySet.contains(fld)) {
					fieldsToAddInQuerySet.add(fld);
				}
			}
		}
		String columnString = '';
		for (String queryFld : fieldsToAddInQuerySet) {
			columnString += queryFld+',';
		}
		columnString = columnString.removeEnd(',');
		//fieldList = fieldList+columnString;
		//System.debug('fieldList===' + fieldList); 
	    //fieldList = fieldList+'Product2.Name,Account.Name,CHL_Partner_Account_1__c, CHL_Partner_Account_2__c,CHL_Partner_Account_1_Contact__c,CHL_Partner_Account_2_Contact__c, CHL_Partner_Account_1_Type__c, CHL_Partner_Account_2_Type__c';  		
   		Integer queryLimit = inputWrapper.lm == 5 ? 5 : 2000;
   		String queryString = 'FIND\''+ inputWrapper.q +'*\' IN All Fields Returning Asset ('+columnString+' ORDER BY Name Asc) Limit '+queryLimit;
   		system.debug('queryString : '+queryString);
		List<List<SObject>>searchList = search.query(queryString);
		system.debug('searchList::'+searchList);
		List<sObject> assetList = new List<sObject>();
		if(searchList != null && searchList.size()>0){
			assetList.addAll(searchList[0]);
		}
		return assetList;
	}
	
    public static List<Asset> getAssetsByIds(List<Schema.FieldSetMember> fieldSetMemberList,Set<String> segmentIds,String filter,Integer recordLimit,string selectedObjectTemp){
        Set<String> fsFieldSet = new Set<String>();
        Set<String> refrenceFieldSet = new Set<String>();
        String queryString = '';
        String nameSpace = CSM_Util.getNamespace();
        
        for(Schema.FieldSetMember fld :fieldSetMemberList){
        	String fldStr = fld.getFieldPath();
            if (nameSpace!=null && nameSpace.length()>0){
                fldStr = fldStr.replace(nameSpace, '');
            }
            if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fld.getFieldPath().contains('.')){
                String fName = fld.getFieldPath().removeEndIgnoreCase('Id').replace('__c', '__r') + (fld.getFieldPath().contains('REN_Contract_Line_Item__c') ? '.LineItemNumber':'.Name' ); //****
                if(!refrenceFieldSet.contains(fName)){
                    queryString += ', ' + fName; 
                     refrenceFieldSet.add(fName);
                }
            }
            if(!refrenceFieldSet.contains(fld.getFieldPath())){                  
				if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DOUBLE) ||
					fld.getType().equals(Schema.DisplayType.CURRENCY) || fld.getType().equals(Schema.DisplayType.DATETIME)){
					if (UserInfo.isMultiCurrencyOrganization() && fld.getType().equals(Schema.DisplayType.CURRENCY)){
						queryString += ', format(convertCurrency(' + fld.getFieldPath() + '))';
					} else {
						queryString += ', format(' + fld.getFieldPath() + ')';
					}
				}
				else {   
					queryString += ', ' + fld.getFieldPath();
				}
			} 
			system.debug('***'+fld);
			if(!fld.getFieldPath().contains('.')){
			    fsFieldSet.add(fldStr);
			}
			refrenceFieldSet.add(fldStr);
        }
		if(UserInfo.isMultiCurrencyOrganization() && !queryString.contains('CurrencyIsoCode')){
		    queryString += ', CurrencyIsoCode';
		    fsFieldSet.add('CurrencyIsoCode'); 
		}
        List<String> fsFieldList = new List<String>(fsFieldSet);
        CSM_Util.checkCRUD_FLS('Asset', fsFieldList, CSM_Constants.DML_OPERATION_READ);
		
        if(String.isNotEmpty(filter)) {
            if(selectedObjectTemp == REN_Constants.OBJ_ASSET){
            	queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM Asset ' + filter +  ' AND ' + ' ID NOT IN (SELECT REN_Asset__c FROM REN_Segment_Member__c WHERE REN_Segment__c IN :segmentIds)';
            }else{
            	queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM Asset WHERE ' + ' ID IN' + '('+ 'SELECT REN_Asset__c FROM REN_Renews_To__c' + filter + ' ) ' + ' AND ' + ' ID NOT IN (SELECT REN_Asset__c FROM REN_Segment_Member__c WHERE REN_Segment__c IN :segmentIds)';
            }
        }else{
        	queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM Asset WHERE ' + ' ID IN (SELECT REN_Asset__c FROM REN_Renews_To__c) ' + ' AND ' + ' ID NOT IN (SELECT REN_Asset__c FROM REN_Segment_Member__c WHERE REN_Segment__c IN :segmentIds)';
    	}
        if(recordLimit == null) {
         	recordLimit = 1000;
        }
        queryString += ' LIMIT ' + recordLimit;
		system.debug(fieldSetMemberList + '\n\n queryString in getDataUsingFieldSet --- : ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        return sObjectList;
    }
  
	public static List<SObject> getDataUsingFieldSet(List<Schema.FieldSetMember> fieldSetMemberList, Set<String> additionalFieldSet, String filterStr, Integer recordLimit) {   
        Set<String> fsFieldSet = new Set<String>();
        Set<String> refrenceFieldSet = new Set<String>();
        String queryString = '';
        String nameSpace = CSM_Util.getNamespace();
        
        for(Schema.FieldSetMember fld :fieldSetMemberList){
            String fldStr = fld.getFieldPath();
            if (nameSpace!=null && nameSpace.length()>0){
                fldStr = fldStr.replace(nameSpace, '');
            }
            if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fld.getFieldPath().contains('.')){
                String fName = fld.getFieldPath().removeEndIgnoreCase('Id').replace('__c', '__r') + (fld.getFieldPath().contains('REN_Contract_Line_Item__c') ? '.LineItemNumber':'.Name' ); //****
                if(!refrenceFieldSet.contains(fName)){
                    queryString += ', ' + fName; 
                     refrenceFieldSet.add(fName);
                }
            }
            
			if(!refrenceFieldSet.contains(fld.getFieldPath())){                  
				if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DOUBLE) ||
					fld.getType().equals(Schema.DisplayType.CURRENCY) || fld.getType().equals(Schema.DisplayType.DATETIME)){
					if (UserInfo.isMultiCurrencyOrganization() && fld.getType().equals(Schema.DisplayType.CURRENCY)){
						queryString += ', format(convertCurrency(' + fld.getFieldPath() + '))';
					} else {
						queryString += ', format(' + fld.getFieldPath() + ')';
					}
				}
				else {   
					queryString += ', ' + fld.getFieldPath();
				}
			} 
			system.debug('***'+fld);
			if(!fld.getFieldPath().contains('.')){
			    fsFieldSet.add(fldStr);
			}
			refrenceFieldSet.add(fldStr);
        }
		if(UserInfo.isMultiCurrencyOrganization() && !queryString.contains('CurrencyIsoCode')){
		    queryString += ', CurrencyIsoCode';
		    fsFieldSet.add('CurrencyIsoCode'); 
		}
		if(additionalFieldSet != null){
		    for(String s : additionalFieldSet){
		        if(!refrenceFieldSet.contains(s)){
		            fsFieldSet.add(s);
		            queryString += ','+ s;  
		        }
		    }
		}
        List<String> fsFieldList = new List<String>(fsFieldSet);
        
        CSM_Util.checkCRUD_FLS('Asset', fsFieldList, CSM_Constants.DML_OPERATION_READ);
        //system.debug('filterStr-------'+filterStr);
        
        if(String.isNotBlank(filterStr)) {
        	queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM Asset WHERE id != null ' + (String.isBlank(filterStr) ? ' ' : (' AND (' + filterStr + ' ) '));
        } else {
        	queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM Asset WHERE id != null ' + (String.isBlank(filterStr) ? ' ' : (' (' + filterStr + ' ) '));
        }
        
        if(recordLimit == null) {
         	recordLimit = 1000;
        }
        
        queryString += ' LIMIT ' + recordLimit;
        
        system.debug(fieldSetMemberList + '\n\n queryString in getDataUsingFieldSet --- : ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        return sObjectList;
    }
    
}