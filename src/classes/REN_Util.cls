public with sharing class REN_Util{

    public static Map<String,Id> getRecordTypes(String objectApiName){
        Map<String,Id> recordTypeMap = new Map<String,Id>();
        List<Schema.RecordTypeInfo> recordTypeInfo = Schema.getGlobalDescribe().get(objectApiName).getDescribe().getRecordTypeInfos();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            if(info.getName() == 'Master'){
                continue;
            }
            recordTypeMap.put(info.getName(),info.getRecordTypeId());
        }
        return recordTypeMap;
    }
    
    public static string getStaticResourcePath(string sRname) {
    	StaticResource static_resource = [SELECT Id,name, SystemModStamp  FROM StaticResource WHERE Name =:sRname LIMIT 1];
		String resourcePath = '/resource/'
                    + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
                    + '/' 
                    + static_resource.get('Name');
    	
    	system.debug('From cntrl : '+resourcePath);
    	string baseURL = URL.getSalesforceBaseUrl().toExternalForm();
    	baseURL = baseURL.replace('my.salesforce', 'lightning.force');
    	return baseURL + resourcePath;
    }

	public static Set<String> convertCSVtoSet(String csvValue, String delimitedStr){
		Set<String> strSet = new Set<String>();
		if(String.isNotBlank(csvValue)){
			List<String> sList = csvValue.split(delimitedStr);
			for(String s:sList){
		    	strSet.add(s.trim());
		    }
		}
		return strSet;
	}

	public static Double convertCurrencyValue(Double valueToBeConverted, String currencyToBeConverted, String convertedCurrency){
    	Double convertedVal = valueToBeConverted * ((1/CSM_Util.getExchangeRateToCorpCurrency(currencyToBeConverted)) * CSM_Util.getExchangeRateToCorpCurrency(convertedCurrency));
		system.debug('coon -' + convertedVal);
		return convertedVal;
	}

	public static String getGenericErrorMessage(Exception exp, String additionalMessage){
		String errMessage = '';
		String errDetails = '';
		String currentURL = '';
		try{
			if(!String.isBlank(additionalMessage)){
				errMessage += additionalMessage;
			}
			currentURL = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + Apexpages.currentPage().getUrl();
		}catch(Exception e){}
		errMessage = errMessage.trim();

		if(exp != null && !String.isBlank(exp.getMessage())){
			errMessage = ' ' + exp.getMessage();
			if(errMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
				errMessage = errMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
			}
			errDetails = exp.getStackTraceString();
			//errMessage += '\n~~~~~~: ' + errDetails;
		}
		errMessage = String.format(System.Label.REN_GENERIC_ERROR_MESSAGE, new String[] {errMessage});       	

		System.debug(LoggingLevel.DEBUG, '\n~~~~Login User: ' + UserInfo.getUserName() + ', URL: ' + currentURL);
		System.debug(LoggingLevel.DEBUG, '\n~~~~Error: ' + errMessage + ' \n' + errDetails);
		return errMessage;
		
	}
	
	public static Set<String> getFieldNameSetFromFieldSet(List<Schema.FieldSetMember> fieldSetMemberList, Set<String> fieldNameSetCrudFlsCheck) {
		Set<String> refrenceFieldSet = new Set<String>();
		fieldNameSetCrudFlsCheck.add('Id');
		refrenceFieldSet.add('Id');
        String nameSpace = CSM_Util.getNamespace();
        boolean isNameSpace = String.isNotBlank(nameSpace);
        if(fieldSetMemberList != null){
	        for(Schema.FieldSetMember fld :fieldSetMemberList){
	            String fldStr = fld.getFieldPath();
                String fldStr1 = isNameSpace ? fldStr.removeStartIgnoreCase(nameSpace) : fldStr;
                /*
				if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fld.getFieldPath().contains('.')){
					String fName = fld.getFieldPath().removeEndIgnoreCase('Id').replace('__c', '__r') + (fld.getFieldPath().contains('REN_Contract_Line_Item__c') ? '.LineItemNumber':'.Name' );
					if(!refrenceFieldSet.contains(fName)){
						 refrenceFieldSet.add(fName);
					}
				}*/
	            system.debug('***'+fld);
	            refrenceFieldSet.add(fldStr);
	            if(!fld.getFieldPath().contains('.')){
	            	fieldNameSetCrudFlsCheck.add(fldStr1);
	            }
	        }
        }
        if(UserInfo.isMultiCurrencyOrganization()){
			refrenceFieldSet.add('CurrencyIsoCode');
			fieldNameSetCrudFlsCheck.add('CurrencyIsoCode');
		}
		for(String s:fieldNameSetCrudFlsCheck){
			if(!refrenceFieldSet.contains(nameSpace + s)){
				refrenceFieldSet.add(s);
			}
		}
		//refrenceFieldSet.addAll(fieldNameSetCrudFlsCheck);
		return refrenceFieldSet;
	}
	
	
	//public static Map<String, Opportunity> filterOpportunityAtStage(String fireOnStage, Map<String, Opportunity> oldOpptRecordsMap, Map<String, Opportunity> newOpptRecordsMap)
	public static Map<String, Opportunity> filterOpportunityAtStage(Map<String, Opportunity> oldOpptRecordsMap, Map<String, Opportunity> newOpptRecordsMap, String whereCondition)
	{
		if(String.isNotBlank(whereCondition)){
			Map<ID, Opportunity> changedStageMatchingOpptMap = new Map<ID, Opportunity>();
			for(Opportunity o :newOpptRecordsMap.values()){
				if((o.StageName != (oldOpptRecordsMap.get(o.Id)).StageName)){ //Changed and new value is the fireOnStage
					changedStageMatchingOpptMap.put(o.Id, o);
				}
			} 
			if(!changedStageMatchingOpptMap.isEmpty()){
                Set<String> knownFields=new Set<String>{'Pricebook2Id', 'Name', 'AccountId', 'Description', 'CHL_Partner_Account_1__c', 'CHL_Partner_Account_1_Contact__c', 'CHL_Partner_Account_1_Type__c', 'CHL_Partner_Account_2__c', 'CHL_Partner_Account_2_Contact__c', 'CHL_Partner_Account_2_Type__c', 'REN_Append_Renewal_Opportunity__c'};
                if (CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c')){
                    knownFields.add(CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c');
                }
                if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'RecordTypeId')){
                	knownFields.add('RecordTypeId');
                }
                List<REN_Field_Mappings__c> fieldMappings=REN_RenewReferenceData.getInstance().fieldMappingsMap.get(CSM_Constants.OBJ_OPPORTUNITY + ':' + CSM_Constants.OBJ_OPPORTUNITY);
                knownFields.addAll(getFromFldsToQuery(fieldMappings));
				List<Opportunity> filteredRecordList = (List<Opportunity>)REN_OpportunityDataAccess.getFilteredRecordsList('Opportunity',knownFields,changedStageMatchingOpptMap.keySet(), whereCondition, null, null);
				return new Map<String, Opportunity>(filteredRecordList);
			}
		}
		return new Map<String, Opportunity>();
	}

	public static Map<String, Opportunity> filterOpportunityByAcctContPresence(Map<String, Opportunity> currentFilteredOppts, Map<String, String> mapOpptId2AcctId, 
																			Map<String, String> mapOpptId2ContId)
	{
		Map<String, Opportunity> opportunitiesWithAcctsOrConts = new Map<String, Opportunity>();
		for(Opportunity o :currentFilteredOppts.values())
		{
			if(mapOpptId2AcctId.containsKey(o.Id) || mapOpptId2ContId.containsKey(o.Id))
			{
				opportunitiesWithAcctsOrConts.put(o.Id, o);
			}
		}
		return opportunitiesWithAcctsOrConts;
	}


	public static List<String> fetchAppendOpportunityIDs(Map<String, Opportunity> currentFilteredOppts)
	{
		List<String> lstOpptIDs = new List<String>();
		for(Opportunity o :currentFilteredOppts.values())
		{
			if(o.REN_Append_Renewal_Opportunity__c != null)
			{
				lstOpptIDs.add(o.REN_Append_Renewal_Opportunity__c);
			}
		}
		return lstOpptIDs;
	}
	
	public static List<String> fetchAddOnOpportunityIDs4Opportunity(Map<String, Opportunity> currentFilteredOppts){
		List<String> lstOpptIDs = new List<String>();
		for(Opportunity o :currentFilteredOppts.values())
		{
			if(o.REN_Append_Renewal_Opportunity__c != null)
			{
				lstOpptIDs.add(o.Id);
			}
		}
		return lstOpptIDs;
	}
	
	public static List<String> fetchAddOnOpportunityIDs4ServiceContract(List<Opportunity> currentFilteredOppts){
		List<String> lstOpptIDs = new List<String>();
		// VCP - ORG21 check
		Boolean hasField = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
		if(hasField)
		{
			for(Opportunity o :currentFilteredOppts)
			{
				// VCP - ORG21 check
				if(o.get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT) != null)
				{
					lstOpptIDs.add(o.Id);
				}
			}
		}
		return lstOpptIDs;
	}
	
	public static Set<String> fetchAppendServiceContractIDs(List<Opportunity> currentFilteredOppts){
		system.debug('IN fetchAppendServiceContractIDs - currentFilteredOppts : ' + currentFilteredOppts);
		Set<String> setOpptIDs = new Set<String>();
		// VCP - ORG21 check
		Boolean hasField = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
		if(hasField)
		{
			for(Opportunity o :currentFilteredOppts)
			{
				// VCP - ORG21 check
				if(o.get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT) != null)
				{
					setOpptIDs.add((Id)o.get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT));
				}
			}
		}
		return setOpptIDs;
	}
	
	public static List<Opportunity> filterOpportunityAppendServiceContracts(List<Opportunity> currentFilteredOppts){
		system.debug('IN filterOpportunityAppendServiceContracts - currentFilteredOppts : ' + currentFilteredOppts);
		List<Opportunity> appendMatchOpptLst = new List<Opportunity>();
		//Eswar Bala: Issue with Service Contract Not Generating
		// VCP - ORG21 check
		Boolean hasField = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
		system.debug('hasField: ' + hasField);
		if(hasField)
		{
			for(Opportunity o :currentFilteredOppts)
			{
				// VCP - ORG21 check
				system.debug('what is Append Service : ' + o.get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT));
				if(o.get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT) == null)
				{
					appendMatchOpptLst.add(o);
				}
			}
		}
		else
		{
			for(Opportunity o :currentFilteredOppts)
			{
				appendMatchOpptLst.add(o);
			}
		}
		return appendMatchOpptLst;
	}
	
	
	public static Map<String, Opportunity> filterOpportunityAppendOpportunities(Map<String, Opportunity> currentFilteredOppts){
		system.debug('IN filterOpportunityAppendOpportunities - currentFilteredOppts : ' + currentFilteredOppts);
		Map<String, Opportunity> appendMatchOpptMap = new Map<String, Opportunity>();
		for(Opportunity o :currentFilteredOppts.values())
		{
			system.debug('what is Append Renewal : ' + o.REN_Append_Renewal_Opportunity__c);
			if(o.REN_Append_Renewal_Opportunity__c == null)
			{
				appendMatchOpptMap.put(o.Id, o);
			}
		}
		return appendMatchOpptMap;
	}

	//fetchAppendOppt2ServContr
	public static Map<String, String> fetchAppendOppt2ServContr(List<Opportunity> lstAddOnOppts){
		Map<String, String> oppt2ServContr = new Map<String, String>();
		// VCP - ORG21 check
		Boolean hasField = CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
		if(hasField)
		{
			for(Opportunity o :lstAddOnOppts)
			{
				// VCP - ORG21 check
				oppt2ServContr.put(o.Id, (Id)o.get(CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT));
			}
		}
		return oppt2ServContr;
	}
	
	/***
    * @description: get ContractLineItem mapping.
    * @Param: newContractLineItem, opLnId, fieldTyp, oldOpptLineId2OldOpptLineMap, defaultVal, toField, fromField.
    * @Return: ContractLineItem record.
    ***/
	public static SObject getMappedLineItemBasedContractLineItem(SObject newContractLineItem, String opLnId, String fieldTyp, 
																 Map<String, OpportunityLineItem> oldOpptLineId2OldOpptLineMap, String defaultVal, String toField, 
																 String fromField)
	{
		if(defaultVal != null && defaultVal.trim() != '')
		{
			if(fieldTyp == CSM_Constants.TYPE_CURRENCY || fieldTyp == CSM_Constants.TYPE_DOUBLE)
			{
				newContractLineItem.put(toField, Double.valueOf(defaultVal));
			}
			else if(fieldTyp == CSM_Constants.TYPE_INTEGER || fieldTyp == CSM_Constants.TYPE_PERCENT)
			{
				newContractLineItem.put(toField, Integer.valueOf(defaultVal));
			}
			//else if(fieldTyp == CSM_Constants.TYPE_DATETIME)
			//{
				//newContractLineItem.put(toField, DateTime.valueOf(defaultVal + ' 00:00:00'));
			//}
			else if(fieldTyp == CSM_Constants.TYPE_DATE)
			{
				newContractLineItem.put(toField, Date.valueOf(defaultVal + ' 00:00:00'));
			}
			else if(fieldTyp == CSM_Constants.TYPE_BOOLEAN)
			{
				newContractLineItem.put(toField, Boolean.valueOf(defaultVal));
			}
			else
			{
				newContractLineItem.put(toField, defaultVal);
			}
		}
		else if(fromField != null)
		{
			newContractLineItem.put(toField, (oldOpptLineId2OldOpptLineMap.get(opLnId)).get(fromField));
		}
		return newContractLineItem;
	}
	
	public static Asset getMappedLineItemBasedAsset(Asset newAsset, String opLnId, String fieldTyp, 
													Map<String, OpportunityLineItem> oldOpptLineId2OldOpptLineMap, String defaultVal, String toField, 
													String fromField)
	{
		system.debug('IN getMappedLineItemBasedAsset');
		system.debug('newAsset : ' + newAsset);
		system.debug('opLnId : ' + opLnId);
		system.debug('fieldTyp : ' + fieldTyp);
		system.debug('defaultVal : ' + defaultVal);
		system.debug('toField : ' + toField);
		system.debug('fromField : ' + fromField);
		
		if(defaultVal != null && defaultVal.trim() != '')
		{
			if(fieldTyp == CSM_Constants.TYPE_CURRENCY || fieldTyp == CSM_Constants.TYPE_DOUBLE)
			{
				newAsset.put(toField, Double.valueOf(defaultVal));
			}
			else if(fieldTyp == CSM_Constants.TYPE_INTEGER || fieldTyp == CSM_Constants.TYPE_PERCENT)
			{
				newAsset.put(toField, Integer.valueOf(defaultVal));
			}
			//else if(fieldTyp == CSM_Constants.TYPE_DATETIME)
			//{
				//newAsset.put(toField, DateTime.valueOf(defaultVal + ' 00:00:00'));
			//}
			else if(fieldTyp == CSM_Constants.TYPE_DATE)
			{
				newAsset.put(toField, Date.valueOf(defaultVal + ' 00:00:00'));
			}
			else if(fieldTyp == CSM_Constants.TYPE_BOOLEAN)
			{
				newAsset.put(toField, Boolean.valueOf(defaultVal));
			}
			else
			{
				newAsset.put(toField, defaultVal);
			}
		}
		else if(fromField != null)
		{
			newAsset.put(toField, (oldOpptLineId2OldOpptLineMap.get(opLnId)).get(fromField));
		}
		return newAsset;
	}

	/**
	 * @Author - Tanvi 21-Feb-2015
	 * Created for SF293, SF307
	 * @description  updateRenewalRelationships - this method will re-associate the opportunity product line items to the Destination Opportunity, during Split/Merge Process. 
	 */ 	
	public static void updateRenewalRelationships(List<Opportunity> lsttarget, Map<String, String> mapOldToNewOpptyLineIds) {
		updateRenewalRelationships(lsttarget, mapOldToNewOpptyLineIds, null);
	}
	
	public static void updateRenewalRelationships(List<Opportunity> lsttarget, Map<String, String> mapOldToNewOpptyLineIds, List<REN_Renews_To__c> rrForSplit) {
		if(lsttarget != null && !lsttarget.isEmpty()){
			Opportunity renewalOppty = lsttarget[0];
			List<REN_Renews_To__c> lstRenewsTo = null;
			
			if(rrForSplit == null){//Split all RR
				//lstRenewsTo = REN_RenewRelationshipDataAccess.getRenewalRelationships(mapOldToNewOpptyLineIds);
			}else{//Split selected RR only
				lstRenewsTo = rrForSplit;
			}
			
			List<REN_Renews_To__c> lstToUpdateRenewsTo = new List<REN_Renews_To__c>();
			if(lstRenewsTo!=null && !lstRenewsTo.isEmpty()){
				for(REN_Renews_To__c rTo : lstRenewsTo ){
					//rTo.REN_Renewal_Product_Line_Id__c = mapOldToNewOpptyLineIds.get(rTo.REN_Renewal_Product_Line_Id__c); US3338 - Commented
					//rTo.REN_Original_Line_Item_ID__c = rTo.REN_Renewal_Product_Line_Id__c; US3338 - Commented	
					lstToUpdateRenewsTo.add(rTo);
					system.debug(rTo + '\n\n~~~~ rrForSplit:' + (rrForSplit == null));
					if(rTo.REN_Source_Opportunity__c == null){
						rTo.REN_Source_Opportunity__c = rTo.REN_Renews_To__c;
					}
					rTo.REN_Previous_Opportunity__c = rTo.REN_Renews_To__c;
					rTo.REN_Renews_To__c = renewalOppty.Id;
				} 
				REN_RenewRelationshipDataAccess.updateRenewalRelationship(lstToUpdateRenewsTo);
				List<Opportunity> lstOpptoUpdate = new List<Opportunity>();
				if(renewalOppty.REN_Is_CLM_Renewal__c != true)	{
					renewalOppty.REN_Is_CLM_Renewal__c = true;
					lstOpptoUpdate.add(renewalOppty);
					//update lstOpptoUpdate;
					REN_OpportunityDataAccess.updateOpportunityforRenewals(lstOpptoUpdate);
				}
				
				//update lstRenewsTo;
			}
		}
	}

	public static boolean evaluateLogicalExp(String arithmeticExpressionStr, sObject oldRecord, sObject newRecord, Map<String, REN_Line_Criteria__c> lineCriteriaMap){
		if(String.isBlank(arithmeticExpressionStr)){
			return true;
		}
		arithmeticExpressionStr = arithmeticExpressionStr.replaceAll('\\(', ' \\( ');
 		arithmeticExpressionStr = arithmeticExpressionStr.replaceAll('\\)', ' \\) ');
		
		arithmeticExpressionStr = arithmeticExpressionStr.replaceAll('  ', ' ');
		arithmeticExpressionStr = arithmeticExpressionStr.replaceAll('  ', ' ');
		arithmeticExpressionStr = arithmeticExpressionStr.replaceAll('  ', ' ');
		arithmeticExpressionStr = arithmeticExpressionStr.replaceAll('  ', ' ');
		arithmeticExpressionStr = arithmeticExpressionStr.replaceAll('  ', ' ');
		arithmeticExpressionStr = arithmeticExpressionStr.trim();
		arithmeticExpressionStr = arithmeticExpressionStr.toUpperCase();

		String[] splitFilterLogic = arithmeticExpressionStr.split(' ');
		system.debug('~~~~splitFilterLogic: ' + splitFilterLogic);
		Integer iCount = 0;
		boolean result = parse(splitFilterLogic, oldRecord, newRecord, lineCriteriaMap,iCount);
		system.debug('~~~~Final parse result:  ' + result);
		return result;
	}
	
	private static boolean evaluateLineCriteria(Object value, REN_Line_Criteria__c lineCriteria){
		boolean isCriteriaMatched = true;
		Object criteriaValue;
		String fieldType = lineCriteria.RLM_Field_Type__c;
		if (value != null && lineCriteria.RLM_Operator__c != CSM_Constants.OPERATOR_ALL) {
			if (fieldType == CSM_Constants.TYPE_CURRENCY || fieldType == CSM_Constants.TYPE_DOUBLE) {
				criteriaValue = Double.valueOf(lineCriteria.RLM_Values__c);
			} else if (fieldType == CSM_Constants.TYPE_INTEGER || fieldType == CSM_Constants.TYPE_PERCENT) {
				criteriaValue = Integer.valueOf(lineCriteria.RLM_Values__c);
			} else if (fieldType == CSM_Constants.TYPE_DATETIME) {
				criteriaValue = Date.valueOf(lineCriteria.RLM_Values__c + ' 00:00:00');
			} else if (fieldType == CSM_Constants.TYPE_DATE) {
				if((Boolean)lineCriteria.RLM_Is_Specific_Date__c){
					criteriaValue = lineCriteria.RLM_Date_Value__c;
				}else{
					//criteriaValue = System.TODAY();
				}
			} else if (fieldType == CSM_Constants.TYPE_BOOLEAN) {
				criteriaValue = Boolean.valueOf(lineCriteria.RLM_Values__c);
			} else {
				criteriaValue = lineCriteria.RLM_Values__c;
			}   
		}
		if (lineCriteria.RLM_Operator__c == CSM_Constants.OPERATOR_ALL) {
			isCriteriaMatched = true;
		}else if (criteriaValue == null || value == null) {
			if (lineCriteria.RLM_Operator__c == '='){
				isCriteriaMatched = (value == criteriaValue);
			}else if (lineCriteria.RLM_Operator__c == '!='){
				isCriteriaMatched = (value != criteriaValue);
			}else{
				isCriteriaMatched = false;
			}
		}else if (lineCriteria.RLM_Operator__c == CSM_Constants.OPERATOR_LIKE) {
			isCriteriaMatched = ((String)value).containsIgnoreCase((String)criteriaValue);
		}else if (lineCriteria.RLM_Operator__c == CSM_Constants.OPERATOR_IN || lineCriteria.RLM_Operator__c == CSM_Constants.OPERATOR_NOTIN) {  
			Set<String> inOptionSet = new Set<String>(((String)criteriaValue).split(';'));
			if (lineCriteria.RLM_Operator__c == CSM_Constants.OPERATOR_IN){
				isCriteriaMatched = inOptionSet.contains((String)value);
			}else if (lineCriteria.RLM_Operator__c == CSM_Constants.OPERATOR_NOTIN){
				isCriteriaMatched = !(inOptionSet.contains((String)value));
			}				 
		}else {
			if(lineCriteria.RLM_Operator__c == '='){
				isCriteriaMatched = (value == criteriaValue);
			}else if(lineCriteria.RLM_Operator__c == '!='){
				isCriteriaMatched = (value != criteriaValue);
			}
			if(fieldType == CSM_Constants.TYPE_INTEGER || fieldType == CSM_Constants.TYPE_PERCENT || fieldType == CSM_Constants.TYPE_CURRENCY || fieldType == CSM_Constants.TYPE_DOUBLE){
				if(lineCriteria.RLM_Operator__c == '>'){
					isCriteriaMatched = ((Decimal)value > (Decimal)criteriaValue);
				}else if(lineCriteria.RLM_Operator__c == '<'){
					isCriteriaMatched = ((Decimal)value < (Decimal)criteriaValue);
				}else if(lineCriteria.RLM_Operator__c == '>='){
					isCriteriaMatched = ((Decimal)value >= (Decimal)criteriaValue);
				}else if(lineCriteria.RLM_Operator__c == '<='){
					isCriteriaMatched = ((Decimal)value <= (Decimal)criteriaValue);
				}else{
					isCriteriaMatched = true;//Error Case
				} 
			}else if(fieldType == CSM_Constants.TYPE_DATE || fieldType == CSM_Constants.TYPE_DATETIME){
				if(lineCriteria.RLM_Operator__c == '>'){
					isCriteriaMatched = ((Date)value > (Date)criteriaValue);
				}else if(lineCriteria.RLM_Operator__c == '<'){
					isCriteriaMatched = ((Date)value < (Date)criteriaValue);
				}else if(lineCriteria.RLM_Operator__c == '>='){
					isCriteriaMatched = ((Date)value >= (Date)criteriaValue);
				}else if(lineCriteria.RLM_Operator__c == '<='){
					isCriteriaMatched = ((Date)value <= (Date)criteriaValue);
				}else{
					isCriteriaMatched = true;//Error Case
				} 
			}
		}
		return isCriteriaMatched;
	}
	
	private static boolean parse(List<String> arithmeticExpList, sObject oldRecord, sObject newRecord, Map<String, REN_Line_Criteria__c> lineCriteriaMap, Integer iterationCount){
		iterationCount = iterationCount + 1;
		List<String> arithmeticExpressionList = new List<String> (arithmeticExpList);
		Boolean returnVal;
		if(arithmeticExpressionList.size() == 1){
			if(arithmeticExpressionList[0].isNumeric()){
				REN_Line_Criteria__c criteria = lineCriteriaMap.get(arithmeticExpressionList[0]);
				returnVal = ( (oldRecord.get(criteria.RLM_Field_Name__c) != newRecord.get(criteria.RLM_Field_Name__c)) && evaluateLineCriteria(newRecord.get(criteria.RLM_Field_Name__c), criteria));
				return returnVal;
			}else{
				returnVal = arithmeticExpressionList[0] == 'true';
				return returnVal;
			}
		}
		Integer i=0;
		Integer listSize = arithmeticExpressionList.size();
		for(i=2; i<listSize; i++){
			Boolean flag = true;
			if(arithmeticExpressionList[i-2] == '(' && arithmeticExpressionList[i] == ')' ){
				//Do nothing...
			}else{
				if(arithmeticExpressionList[i-2].isNumeric() && arithmeticExpressionList[i].isNumeric() ){
					if(arithmeticExpressionList[i-1] == 'AND'){
						arithmeticExpressionList[i-1] = '' + (parse(new List<String>{arithmeticExpressionList[i-2]}, oldRecord, newRecord, lineCriteriaMap, iterationCount) && parse(new List<String>{arithmeticExpressionList[i]}, oldRecord, newRecord, lineCriteriaMap, iterationCount));
					}
					if(arithmeticExpressionList[i-1] == 'OR'){
						arithmeticExpressionList[i-1] = '' + (parse(new List<String>{arithmeticExpressionList[i-2]}, oldRecord, newRecord, lineCriteriaMap, iterationCount) || parse(new List<String>{arithmeticExpressionList[i]}, oldRecord, newRecord, lineCriteriaMap, iterationCount));
					}
				}else if((arithmeticExpressionList[i-2] == 'true' || arithmeticExpressionList[i-2]== 'false' )  && arithmeticExpressionList[i].isNumeric() ){
					if(arithmeticExpressionList[i-1] == 'AND'){
						arithmeticExpressionList[i-1] = '' + (arithmeticExpressionList[i-2] == 'true' && parse(new List<String>{arithmeticExpressionList[i]}, oldRecord, newRecord, lineCriteriaMap, iterationCount));
					}
					if(arithmeticExpressionList[i-1] == 'OR'){
						arithmeticExpressionList[i-1] = '' + (arithmeticExpressionList[i-2] == 'true' || parse(new List<String>{arithmeticExpressionList[i]}, oldRecord, newRecord, lineCriteriaMap, iterationCount));
					}
				}else if(arithmeticExpressionList[i-2].isNumeric()  && (arithmeticExpressionList[i] == 'true' || arithmeticExpressionList[i]== 'false') ){
					if(arithmeticExpressionList[i-1] == 'AND'){
						arithmeticExpressionList[i-1] = '' + (parse( new List<String>{arithmeticExpressionList[i-2]}, oldRecord, newRecord, lineCriteriaMap, iterationCount) && arithmeticExpressionList[i] == 'true');
					}
					if(arithmeticExpressionList[i-1] == 'OR'){
						arithmeticExpressionList[i-1] = '' + (parse( new List<String>{arithmeticExpressionList[i-2]}, oldRecord, newRecord, lineCriteriaMap, iterationCount) || arithmeticExpressionList[i] == 'true');
					}
				}else if((arithmeticExpressionList[i-2] == 'true' || arithmeticExpressionList[i-2]== 'false' )  && (arithmeticExpressionList[i] == 'true' || arithmeticExpressionList[i]== 'false') ){
					if(arithmeticExpressionList[i-1] == 'AND'){
						arithmeticExpressionList[i-1] = '' + (arithmeticExpressionList[i-2] == 'true' && arithmeticExpressionList[i] == 'true');
					}
					if(arithmeticExpressionList[i-1] == 'OR'){
						arithmeticExpressionList[i-1] = '' + (arithmeticExpressionList[i-2] == 'true' || arithmeticExpressionList[i] == 'true');
					}
				}else{
					flag = false;
				}
			}
			if(flag){
				arithmeticExpressionList.remove(i);
				arithmeticExpressionList.remove(i-2);
				i = 1;
				listSize = arithmeticExpressionList.size();
			}
		}
		returnVal = parse(arithmeticExpressionList, oldRecord, newRecord, lineCriteriaMap, iterationCount);
		return returnVal;
		//return false;
	}
	public static List<SelectOption> pricebookPicklist(){
		List<SelectOption> priceBookList = new List<SelectOption>();
		STring queryString ='';
		
			//queryString = 'SELECT Id, Name FROM Pricebook2 WHERE IsActive = true';
			List<SObject> pricebook = REN_PricebookDataAccess.getPriceBookDetail();//Database.query(queryString);
	        if(pricebook != null && !pricebook.isEmpty())
	        {
	        	for(SObject ct : pricebook)
	        	{
	        		priceBookList.add(new SelectOption((String)ct.get('Id'), (String)ct.get('Name')));
	        	}
	        }
		
		return priceBookList;
	}	
	public static Pricebook2 getPricebookbyID(String priceBookID){
		List<String> fcFieldList = new List<String>{'Id','Name'};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_PRICEBOOK, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		
		List<Pricebook2> pricebookLst =	[Select id,Name From Pricebook2 where id = :priceBookID LIMIT 1];
		Pricebook2 priceBook = null;
		if(pricebookLst != null && !pricebookLst.isEmpty()){
			priceBook =  pricebookLst[0];
		}
		
		return priceBook;
	}
	public static sObject copyObjectUsingAdminMapping(sObject fromObject, sObject toObject, Map<String, Schema.SobjectField> fieldDescriptionMap, List<REN_Field_Mappings__c> fieldMappingList){
		if(fromObject == null || toObject == null || fieldDescriptionMap == null || fieldMappingList == null){
			//do nothing. 
		}else{
			for(REN_Field_Mappings__c fieldMapping: fieldMappingList) {
				if(String.isBlank(String.valueOf(fieldMapping.REN_Default_Value__c))){
					toObject.put(fieldMapping.REN_To_Field_API_Name__c, fromObject.get(fieldMapping.REN_From_Field_API_Name__c));
				}else{//Set default value				
					String fieldType = String.valueOf(fieldDescriptionMap.get(fieldMapping.REN_To_Field_API_Name__c).getDescribe().getType());
		           if (fieldType == CSM_Constants.TYPE_CURRENCY || fieldType == CSM_Constants.TYPE_DOUBLE) {
		               toObject.put(fieldMapping.REN_To_Field_API_Name__c, Double.valueOf(fieldMapping.REN_Default_Value__c));
		           } else if (fieldType == CSM_Constants.TYPE_INTEGER || fieldType == CSM_Constants.TYPE_PERCENT) {
		               toObject.put(fieldMapping.REN_To_Field_API_Name__c, Integer.valueOf(fieldMapping.REN_Default_Value__c));
		           } else if (fieldType == CSM_Constants.TYPE_DATETIME || fieldType == CSM_Constants.TYPE_DATE) {
		           		try{
		           			if(String.isNotBlank(fieldMapping.REN_Default_Value__c)){
		           				toObject.put(fieldMapping.REN_To_Field_API_Name__c, Date.valueOf(fieldMapping.REN_Default_Value__c + ' 00:00:00'));
		           			}
		           		}catch(Exception e){
		           			toObject.addError(e.getMessage());
		           			System.debug(LoggingLevel.DEBUG, '\n~~~~Error: ' + e.getMessage() + ' \n' + e.getStackTraceString());
		           		}
		           } else if (fieldType == CSM_Constants.TYPE_BOOLEAN) {
		               toObject.put(fieldMapping.REN_To_Field_API_Name__c, Boolean.valueOf(fieldMapping.REN_Default_Value__c));
		           } else {
		               toObject.put(fieldMapping.REN_To_Field_API_Name__c, fieldMapping.REN_Default_Value__c);
		           }
				}
			}		
		}
		return toObject;
	}

	/*
	 * @description send mail 
	 * @Param: id of users to send mail to, email template id,ID of object which is used in template
	 */
	public static void sendEmailNotification(Set <Id> recepientUserIdSet, String subjectText, String bodyText) {
		Messaging.SingleEmailMessage emailDraft = new Messaging.SingleEmailMessage();
		emailDraft.setSubject(subjectText);
		emailDraft.setHtmlBody(bodyText);
		emailDraft.setPlainTextBody(bodyText);
		sendEmailNotification(recepientUserIdSet, emailDraft);
	}
	
	public static void sendEmailNotificationUsingTemplate(Set <Id> recepientUserIdSet, String templateID, Id dependentObjId) {
		/*
			WhatID cannot be set unless TargetObjectId is of contact Id,so we are setting random contact id as targetobject.
			Setting whatID sets the context for the email template which then can use object fields
			This emailDraft is just used for generating body for the actual email.Draft mail is not sent,so rollback is used
		*/
		Messaging.SingleEmailMessage emailDraft = new Messaging.SingleEmailMessage();
		List < contact > contactList =CSM_ContactDataAccess.getContactList();// [Select id from Contact Limit 1];
		if (contactList != null && !contactList.isEmpty() && String.isNotBlank(templateID)) {
			
			emailDraft.setTargetObjectId(contactList[0].Id);
			emailDraft.setTemplateId(templateID);
			emailDraft.setWhatId(dependentObjId);
			emailDraft.saveAsActivity = false;

			Savepoint sp = Database.setSavepoint();
			Messaging.SendEmail(New Messaging.SingleEmailMessage[] {
				emailDraft
			});
			Database.rollback(sp);
			sendEmailNotification(recepientUserIdSet, emailDraft);
		}
	}

	public static void sendEmailNotification(Set <Id> recepientUserIdSet, Messaging.SingleEmailMessage emailDraft) {
		List < Messaging.SingleEmailMessage > emailList = new List < Messaging.SingleEmailMessage > ();
		for (ID recepientId: recepientUserIdSet) {
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setTargetObjectId(recepientId);
			email.setSubject(emailDraft.getSubject());
			email.setHtmlBody(emailDraft.getHtmlBody());
			email.setPlainTextBody(emailDraft.getPlainTextBody());
			email.saveAsActivity = false;
			emailList.add(email);
		}
		Messaging.SendEmail(emailList);
	}

	public static Set <Id> getUniqueEmailRecipients(List < REN_Email_Recipient__c > emailRecepientList) {
		String userType = Schema.SObjectType.User.getKeyPrefix();
		Set < Id > userIdList = new Set < Id > ();
		Set < Id > groupIdList = new Set < Id > ();

		for (REN_Email_Recipient__c emailRecep: emailRecepientList) {
			if (emailRecep.REN_Recipient__c.startsWith(userType)) {
				userIdList.add(emailRecep.REN_Recipient__c);
			} else {
				groupIdList.add(emailRecep.REN_Recipient__c);
			}
		}

		//Currently we support only direct users within groups,so groups within groups not considered
		if (!groupIdList.isEmpty()) {
			List < GroupMember > groupMembersList = [Select Id, UserOrGroupId From GroupMember Where GroupId = : groupIdList];

			for (GroupMember groupMember: groupMembersList) {
				if (((String) groupMember.UserOrGroupId).startsWith(userType)) {
					userIdList.add(groupMember.UserOrGroupId);
				}
			}
		}
		return userIdList;
	}	
	
	public static ID getEmailTemplateId (String templateName) 	{
		ID templateID ;
		List<EmailTemplate> emailTemplateList = [Select Id, name, DeveloperName from EmailTemplate Where Name = :templateName OR DeveloperName = :templateName];
		if(!emailTemplateList.isEmpty()){
			templateID = emailTemplateList[0].Id ;
		}
		return templateID;
	}
	
	public static void setErrorInObjects (List<sObject> objList, Exception ex){
		String errorMsg = REN_Util.getGenericErrorMessage(ex, null);
		system.debug(Logginglevel.ERROR, '\n\n~~~~ Exception:' + errorMsg);
		system.debug(ex);
		
		for (Integer i = 0; i < objList.size(); i++){
			objList[i].addError(errorMsg);
		} 
	}
	
	public static Set<String> getFromFldsToQuery(List < REN_Field_Mappings__c > fieldMappingList) {
		Set<String> fldSet = new Set<String>();
		if(fieldMappingList != null && !fieldMappingList.isEmpty()){
			String nameSpace = CSM_Util.getNamespace();
			String fieldName = '';
			//Remove the namespace from the field name. As keys in the objectFieldInfoMap
	        	// contains the field name without namespace.
			for(REN_Field_Mappings__c mappedFld:fieldMappingList){
				fieldName = mappedFld.REN_From_Field_API_Name__c ;
				if(String.isNotBlank(nameSpace) && String.isNotBlank(fieldName) && fieldName.startsWith(nameSpace)){
					fieldName = fieldName.removeStart(namespace).toLowerCase();
				}
				if(String.isNotBlank(fieldName)){
					fldSet.add(fieldName);
				}
			 }
		}
		return fldSet;
	} 
	
		public static void getFromAndToFldsToQuery(List <REN_Field_Mappings__c> fieldMappingList,Set<String> frmFldSet,Set<String> toFldSet) {
		String nameSpace = CSM_Util.getNamespace();
		String frmFieldName = '';
		String toFieldName = '';
       	//Remove the namespace from the field name. As keys in the objectFieldInfoMap
       	// contains the field name without namespace.
		for(REN_Field_Mappings__c mappedFld:fieldMappingList){
			frmFieldName = mappedFld.REN_From_Field_API_Name__c ;
   			toFieldName = mappedFld.REN_To_Field_API_Name__c;
			if(String.isNotBlank(nameSpace) && String.isNotBlank(frmFieldName) && frmFieldName.startsWith(nameSpace)){
				frmFieldName = frmFieldName.removeStart(namespace);
			}
			if(String.isNotBlank(frmFieldName)){
				if(frmFldSet == null){
					frmFldSet = new Set<String>();
				}
				frmFldSet.add(frmFieldName);
			}
			if(String.isNotBlank(nameSpace) && String.isNotBlank(toFieldName) && toFieldName.startsWith(nameSpace)){
				toFieldName = toFieldName.removeStart(namespace);
			}
			if(String.isNotBlank(toFieldName)){
				if(toFldSet == null){
					toFldSet = new Set<String>();
				}
				toFldSet.add(toFieldName);
			}
		 }
		 //return fldSet;
	}
	
	public  static String constructWhereClause(String assetCriteria, String renewalRelationCriteria,String queryField){
		String soqlWhere = '';
        if(String.isBlank(assetCriteria)){
        	if(String.isBlank(renewalRelationCriteria)){
    			soqlWhere += 'Id Not IN (Select ' 
    						+ queryField 
    						+ ' From REN_Renews_To__c)';
        	}else {
        		soqlWhere += 'Id IN (Select ' 
    						+ queryField 
    						+ ' From REN_Renews_To__c  Where (' + renewalRelationCriteria + '))';
        	}
  
        }else{
        	if(String.isBlank(renewalRelationCriteria)){
    			soqlWhere += '(' + assetCriteria + ') AND Id Not IN (Select ' 
    						+ queryField 
    						+ ' From REN_Renews_To__c)';
        	}else{
        		soqlWhere += '(' + assetCriteria + ') AND Id IN (Select ' 
    						+ queryField 
    						+ ' From REN_Renews_To__c  Where (' + renewalRelationCriteria + '))';
        	}
        }
        system.debug('soqlWhere $$$$$$$ '+soqlWhere);
        return soqlWhere;
  
    }
    
    public static void resetTriggersTo(boolean isActive) {
		 
		CSM_Constants.ACCOUNT_PLAN_AFTER_TRIGGER = isActive;
		CSM_Constants.ACCOUNT_PLAN_BEFORE_TRIGGER = isActive;
		CSM_Constants.ACCOUNT_TRIGGER = isActive;
		CSM_Constants.CASE_TRIGGER = isActive;
		CSM_Constants.PLAY_CRITERIA_TRIGGER = isActive;
		CSM_Constants.PLAY_RESULT_TRIGGER = isActive;
		CSM_Constants.TASK_TRIGGER = isActive;
		REN_Constants.ASSET_TRIGGER = isActive;
		REN_Constants.CONTRACTLINEITEM_TRIGGER = isActive;
		if(isActive){
			CSM_TriggerManager.enableFirstTrigger();
		}else{
			CSM_TriggerManager.disableAllTriggers();
		}
		//TODO: Add all here
		
	}

	public static Boolean isFieldChanged(sObject oldObject, sObject newObject, Set<String> anyOneFieldChangedSet){
		Boolean isChanged = false;
		if (oldObject != null && newObject != null){
			for(String fld :anyOneFieldChangedSet){
				if(oldObject.get(fld) != newObject.get(fld)){
					isChanged = true;
					break;
				}
			}
		}else{
			isChanged = null;
		}
		return isChanged;
	}
	
	public static List<Attachment> getAllAttachments(Set<Id> setOfIds){
		List<String> fcFieldList = new List<String>{'Id','Name'};
		CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ATTACHMENT, fcFieldList, CSM_Constants.DML_OPERATION_READ);
		return [SELECT Id, ParentId, CreatedDate,Name,Body FROM Attachment WHERE ParentId IN :setOfIds ORDER BY CreatedDate DESC ];
	}
	
	public static string getDecryptedData(String encryptData){
		SS_License__c licenseInstance = SS_License__c.getOrgDefaults();
    	string keystring = licenseInstance.REN_AES_Encryption_Key__c;
		Blob key = EncodingUtil.base64Decode(keystring);
		string decryptedData = '';
		if(String.isNotblank(encryptData)) {
			encryptData = EncodingUtil.URLDECODE(encryptData , 'UTF-8');
            encryptData = encryptData.contains(' ')?encryptData.replace(' ','+'):encryptData;
	    	Blob encryptedData = EncodingUtil.base64Decode(encryptData);
	        Blob decrypted = Crypto.decryptWithManagedIV('AES256', key, encryptedData);
	        decryptedData = decrypted.toString();
		}
		return decryptedData;
	}
    
    public static string getEncryptedData(String dataToEncrypt, Blob encryptionKey){
		Blob blobDataToEncrypt = Blob.valueOf(String.valueOf(dataToEncrypt));
    	Blob encryptedData = Crypto.encryptWithManagedIV('AES256', encryptionKey, blobDataToEncrypt);
    	return EncodingUtil.base64Encode(encryptedData);
	}
	
	
	public static Set<String> parseFilterValues(String filterStr){
		System.debug(filterStr);
		filterStr = filterStr.replaceAll('"+\\s*[,\n\t]+\\s*', ']#~, ');
		filterStr = filterStr.replaceAll('\\s*[,\n\t]+\\s*"+', ', #~[');
		filterStr = filterStr.replaceAll('^\\s*"', '[');
		filterStr = filterStr.replaceAll('"\\s*$', ']');
		filterStr = filterStr.replaceAll('\'+\\s*[,\n\t]+\\s*', '}#~, ');
		filterStr = filterStr.replaceAll('\\s*[,\n\t]+\\s*\'+', ', #~{');
		filterStr = filterStr.replaceAll('^\\s*\'', '{');
		filterStr = filterStr.replaceAll('\'\\s*$', '}');
		Set<String> parsedSet = new Set<String>(filterStr.split('\\s*,*#~,*\\s*'));
		Set<String> parsedSet1 = new Set<String>();
		for(String s: parsedSet){
			if(String.isNotBlank(s)){
				if(s.startsWith('[') && s.endsWith(']')){
					parsedSet1.add(s.removeEnd(']').removeStart('['));
				}else if(s.startsWith('{') && s.endsWith('}')){
					if(s.containsAny(',')){
						parsedSet1.addAll(('\'' + s.removeEnd('}').removeStart('{') + '\'').split('\\s*,\\s*'));
					}else{
						parsedSet1.add(s.removeEnd('}').removeStart('{'));
					}
				}else if(s.startsWith('[') ){
					parsedSet1.add('"' + s.removeStart('['));
				}else if(s.endsWith(']')){
					parsedSet1.add(s.removeEnd(']') + '"');
				}else if(s.startsWith('{') ){
					parsedSet1.add('\'' + s.removeStart('{'));
				}else if(s.endsWith('}')){
					parsedSet1.add(s.removeEnd('}') + '\'');
				}else {
					parsedSet1.addAll(s.split('\\s*[,\n\r\t]+\\s*'));
				}
			}
		}
		parsedSet1.remove(null);
		parsedSet1.remove('');
		return parsedSet1;
	}
	
	/* This method is used for getting field names adding format functions for Date and currency data type and used in SOQL calues for fields. */
	public static String getSelectSOQLFieldStr(String objectName, List<Schema.FieldSetMember> fieldSetMemberList, Set<String> additionalFieldSet){
	    Set<String> fsFieldSet = new Set<String>();
        Set<String> refrenceFieldSet = new Set<String>();
        String queryString = '';
        String nameSpace = CSM_Util.getNamespace();
        SObject sObj = CSM_AccessController.newSObject(objectName);
        Map<String, Schema.SobjectField> fields = sObj.getSObjectType().getDescribe().fields.getMap();
        for(Schema.FieldSetMember fld :fieldSetMemberList){
            String fldStr = fld.getFieldPath();
            if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fld.getFieldPath().contains('.')){
                String fName = null;
                DescribeFieldResult dfr = fields.get(fldStr).getDescribe();
                    List<Schema.SObjectType> oTypeList = dfr.getReferenceTo();
                    if(!oTypeList.isEmpty()){
                        String refObjName = oTypeList[0].getDescribe().getName();
                        if(CSM_AccessController.hasField(refObjName, 'Name')){
                            fName = dfr.getRelationshipName() + '.Name';
                        }
                    }
                if(String.isNotBlank(fName) && !refrenceFieldSet.contains(fName)){
                    queryString += ', ' + fName; 
                     refrenceFieldSet.add(fName);
                }
            }
            if(!refrenceFieldSet.contains(fld.getFieldPath()) && fld.getType().equals(Schema.DisplayType.PICKLIST)){
            	queryString += ', toLabel(' + fld.getFieldPath() + ')';
            	refrenceFieldSet.add(fldStr);
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
                    queryString += ','+ s;  
                }
            }
        }
        List<String> fsFieldList = new List<String>(fsFieldSet);
        CSM_Util.checkCRUD_FLS(objectName , fsFieldList, CSM_Constants.DML_OPERATION_READ);
        
        return queryString.removeStart(','); 
	}
	

	public static Set<String> processValuesWithDoubleQuotes(String filterValue) {
		Set<String> processStringSet = new Set<String>();
		Set<String> finalStringSet = new Set<String>();
		filterValue = filterValue.trim();
		List<String> filterValueList = filterValue.split('"');
		for(String value : filterValueList){
			if(value.countMatches(',') != 1){
		        List<String> lst2 = new List<String>();
		        if(value.startsWith(',') || value.endsWith(',')) {
                    lst2 = value.split(',');
                } else {
                    lst2.add(value);
                }
		        for(String value2 : lst2){
		        	value2 = value2.trim();
		            processStringSet.add(value2);
		        }
		    } else {
		    	value= value.trim();
		    	processStringSet.add(value);
		    }
		}
		
		for(string value : processStringSet){
		    value= value.trim();
		    if(string.isNotBlank(value) && value != ','){
		        system.debug('==>'+value);
		        if(value.contains('\'')) {
                    value = value.replaceAll('\'','\'\'');
                }
                system.debug('value==>'+value);
		        finalStringSet.add(value);
		    }
		    
		}	
		return finalStringSet;
	}
	
	//This method is to update records of any object: sObject
    public static List<sObject> updateSObjectRecords(List<sObject> updateList, List<String> fieldList, String objectAPIName){
        List<String> noAccessFieldList = CSM_AccessController.getInstance()
                                            .returnNoPermissionFieldsNameList(objectAPIName, 
                                            CSM_Constants.DML_OPERATION_UPDATE, fieldList);
        
        if (noAccessFieldList.isEmpty())
        {
            update updateList;
        }
        else
        {
             String[] arguments = new String[] {objectAPIName + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_UPDATEABLE, arguments));
        }
        return updateList; 
    }
    public static List<sObject> insertSObjectRecords(List<sObject> insertList, List<String> fieldList, String objectAPIName){
        List<String> noAccessFieldList = CSM_AccessController.getInstance()
                                            .returnNoPermissionFieldsNameList(objectAPIName, 
                                            CSM_Constants.DML_OPERATION_INSERT, fieldList);
        if (noAccessFieldList.isEmpty())
        {
            insert insertList;
        }
        else
        {
             String[] arguments = new String[] {objectAPIName + ':'+String.valueOf(noAccessFieldList)};
             throw new CSM_AccessController.AccessControlDmlException( String.format(
             System.Label.CSM_MSG_OBJECT_NOT_READABLE, arguments));
        }
        return insertList;  
    }
    
    public static List<QueueSObject> getQueuesObject(List<String> fieldList, List<String> additionalFields){
        CSM_Util.checkCRUD_FLS('QueueSObject', fieldList, CSM_Constants.DML_OPERATION_READ);
        if(additionalFields != null){
        	fieldList.addAll(additionalFields);
        }
        String soqlStr = String.join(fieldList, ',');
        soqlStr = 'SELECT ' + soqlStr + ' from QueueSObject where QueueId != null'; 
        return Database.query(soqlStr);
    }
    
    public static List<sObject> getEntitlementListByAccount(Set<String> accountSet) 
    {
    	CSM_Util.checkCRUD_FLS('Entitlement', new List<String> {'AccountId'}, CSM_Constants.DML_OPERATION_READ);
	    return Database.query('SELECT Id, AccountId FROM Entitlement WHERE AccountId IN :accountSet LIMIT 9999');
    }
    
    public static String jsonStrParser(List<String> jsonStrList, String predicate){
        if(jsonStrList != null && !jsonStrList.isEmpty() && String.isNotBlank(jsonStrList[0])){
            JSONParser parser = JSON.createParser(jsonStrList[0]);
        	while (parser.nextToken() != null) {
                if(parser.getText() == predicate){
                    parser.nextToken();
                    return parser.getText();
                }
            }    
        }
        return null;
    }
    /* public static List<ProcessInstanceStep> getProcessInstanceSteps(Set<Id> quoteIdSet){
    	CSM_Util.checkCRUD_FLS('ProcessInstanceStep', new List<String> {'Comments'}, CSM_Constants.DML_OPERATION_READ);
    	return [SELECT Id,Comments FROM ProcessInstanceStep where ProcessInstanceId IN(Select Id from ProcessInstance where TargetObjectId IN:quoteIdSet) order by CreatedDate DESC limit 1];	
    }*/    
    public static Set<Id> queryTeamMembers(List<String> fieldList, String ObjApiName, String whereField){
        Set<Id> recIdSet = new Set<Id>();
        CSM_Util.checkCRUD_FLS(ObjApiName, fieldList, CSM_Constants.DML_OPERATION_READ);
        String soqlStr = 'Select ' + String.join(fieldList, ',') + ' from ' + ObjApiName + ' where ' + whereField + ' = \'' + UserInfo.getUserId() + '\' Limit 10000';
        List<sObject> teamMemberList = Database.query(soqlStr);
        
        if(teamMemberList != null && !teamMemberList.isEmpty()){
            for(sObject obj : teamMemberList){
                recIdSet.add((Id)obj.get(fieldList[0]));
            }
        }        
        return recIdSet;
    }
    public static List<String> getDateByLiteral(List<String> dateLiteralList, Integer dateLiteralNumber){
        List<string> dateValList= new List<string>();
        if(dateLiteralList[0] == 'TODAY'){
            dateValList.add(String.valueOf(Datetime.now()));  
        }else if(dateLiteralList[0] == 'YESTERDAY'){
            dateValList.add(String.valueOf(Datetime.now()-1));    
        }else if(dateLiteralList[0] == 'TOMORROW'){
            dateValList.add(String.valueOf(Datetime.now()+1));    
        }else if(dateLiteralList[0] == 'N_DAYS_AGO'){
            dateValList.add(String.valueOf(Datetime.now().addDays(-dateLiteralNumber)));    
        }else if(dateLiteralList[0] == 'LAST_90_DAYS'){
            dateValList.add(String.valueOf(Datetime.now().addDays(-90)));    
            dateValList.add(String.valueOf(Datetime.now()));
        }else if(dateLiteralList[0] == 'NEXT_90_DAYS'){
            dateValList.add(String.valueOf(Datetime.now().addDays(1)));
            dateValList.add(String.valueOf(Datetime.now().addDays(90)));    
        }else if(dateLiteralList[0] == 'LAST_N_DAYS'){
            dateValList.add(String.valueOf(Datetime.now().addDays(-dateLiteralNumber)));    
            dateValList.add(String.valueOf(Datetime.now()));
        }else if(dateLiteralList[0] == 'NEXT_N_DAYS'){
            dateValList.add(String.valueOf(Datetime.now().addDays(1)));
            dateValList.add(String.valueOf(Datetime.now().addDays(dateLiteralNumber)));    
        }else if(dateLiteralList[0] == 'LAST_FISCAL_QUARTER' || dateLiteralList[0] == 'THIS_FISCAL_QUARTER' || dateLiteralList[0] == 'NEXT_FISCAL_QUARTER'
            || dateLiteralList[0] == 'LAST_N_FISCAL_QUARTERS' || dateLiteralList[0] == 'NEXT_N_FISCAL_QUARTERS' || dateLiteralList[0] == 'N_FISCAL_QUARTERS_AGO'){
            List<Period>  periodList = getFiscalPeriod(dateLiteralList, new List<String>{'Quarter'},dateLiteralNumber); 
            if(!periodList.isEmpty()){
            	dateValList.add(String.valueOf(periodList[0].get('startDate')));
                dateValList.add(String.valueOf(periodList[dateLiteralNumber == null ||  dateLiteralList[0] == 'N_FISCAL_QUARTERS_AGO' ? 0 :dateLiteralNumber-1].get('endDate')));
            }
     	}else if(dateLiteralList[0] == 'LAST_FISCAL_YEAR' || dateLiteralList[0] == 'THIS_FISCAL_YEAR' || dateLiteralList[0] == 'NEXT_FISCAL_YEAR'
            || dateLiteralList[0] == 'LAST_N_FISCAL_YEARS' || dateLiteralList[0] == 'NEXT_N_FISCAL_YEARS' || dateLiteralList[0] == 'N_FISCAL_YEARS_AGO'){
            List<Period>  periodList = getFiscalPeriod(dateLiteralList, new List<String>{'Year'},dateLiteralNumber);
            if(!periodList.isEmpty()){
            	dateValList.add(String.valueOf(periodList[0].get('startDate')));
                dateValList.add(String.valueOf(periodList[dateLiteralNumber == null || dateLiteralList[0] == 'N_FISCAL_YEARS_AGO' ? 0 :dateLiteralNumber-1].get('endDate')));             
            }
       	}else{
        	dateValList = calculatekDates(dateLiteralList[0], dateLiteralNumber);
        } 
        return dateValList;
    }
    private static List<String> calculatekDates(String dateLiteral, Integer dateLiteralNumber){
        Integer num;
        Date startDate;
        Date endDate;
        Time timegmt = Time.newInstance(0, 0, 0, 0);
        List<String> dateValList = new List<String>();
        if(dateLiteral == 'NEXT_WEEK' || dateLiteral == 'NEXT_N_WEEKS' || dateLiteral == 'NEXT_MONTH' || dateLiteral == 'NEXT_N_MONTHS' 
        	|| dateLiteral == 'NEXT_YEAR' || dateLiteral == 'NEXT_N_YEARS' || dateLiteral == 'NEXT_Quarter' || dateLiteral == 'NEXT_N_QUARTERS'){
            num = 1;
        }else if(dateLiteral == 'LAST_WEEK' || dateLiteral == 'LAST_MONTH' || dateLiteral == 'LAST_YEAR' || dateLiteral == 'LAST_QUARTER'){
            num = -1;
        }else if(dateLiteral == 'THIS_WEEK' || dateLiteral == 'THIS_MONTH' || dateLiteral == 'THIS_YEAR' || dateLiteral == 'THIS_QUARTER'){
            num = 0;
        }else if(dateLiteral == 'LAST_N_WEEKS' || dateLiteral == 'N_WEEKS_AGO' || dateLiteral == 'LAST_N_MONTHS' || dateLiteral == 'N_MONTHS_AGO'
        	|| dateLiteral == 'LAST_N_YEARS' || dateLiteral == 'N_YEARS_AGO' || dateLiteral == 'LAST_N_QUARTERS' || dateLiteral == 'N_QUARTERS_AGO'){
            num = -dateLiteralNumber;
        }
        if(dateLiteral.contains('WEEK')){
        	 Date currentDate = Date.today();
            Date weekDate = currentDate.addDays(7 * num);
            startDate = weekDate.toStartOfWeek();
            if(dateLiteral == 'NEXT_WEEK' || dateLiteral == 'LAST_WEEK' || dateLiteral == 'THIS_WEEK' || dateLiteral == 'N_WEEKS_AGO'){
                endDate = startDate.addDays(6);
            }else if(dateLiteral == 'LAST_N_WEEKS' || dateLiteral == 'NEXT_N_WEEKS'){
                endDate = startDate.addDays((7 * dateLiteralNumber) - 1);
            }    
        }else if(dateLiteral.contains('MONTH')){
            Integer numberOfDays;
        	startDate = System.date.today().toStartOfMonth().addMonths(num); 
            if(dateLiteral == 'NEXT_MONTH' || dateLiteral == 'LAST_MONTH' || dateLiteral == 'THIS_MONTH' || dateLiteral == 'N_MONTHS_AGO'){
                numberOfDays = Date.daysInMonth(startDate.year(), startDate.month());
                endDate = startDate.addDays(numberOfDays-1);
            }else if(dateLiteral == 'LAST_N_MONTHS' || dateLiteral == 'NEXT_N_MONTHS'){
				endDate = startDate.addMonths(dateLiteralNumber).addDays(-1);                
            }
        }else if(dateLiteral.contains('YEAR')){
            Integer numberOfDays;
        	startDate =  date.newinstance(System.date.today().year(), 1, 1).addYears(num);
            if(dateLiteral == 'NEXT_YEAR' || dateLiteral == 'LAST_YEAR' || dateLiteral == 'THIS_YEAR' || dateLiteral == 'N_YEARS_AGO'){
                endDate = startDate.addMonths(12).addDays(-1);
            }else if(dateLiteral == 'LAST_N_YEARS' || dateLiteral == 'NEXT_N_YEARS'){
            	endDate = startDate.addMonths((12 * dateLiteralNumber)).addDays(-1);                
            }           
        }else if(dateLiteral.contains('QUARTER')){
            if(System.date.today().month() == 1 || System.date.today().month() == 2 || System.date.today().month() == 3){
             	startDate = date.newinstance(System.date.today().year(), 1, 1).addMonths(num*3);
            }else if(System.date.today().month() == 4 || System.date.today().month() == 5 || System.date.today().month() == 6){
             	startDate = date.newinstance(System.date.today().year(), 4, 1).addMonths(num*3);
            }else if(System.date.today().month() == 7 || System.date.today().month() == 8 || System.date.today().month() == 9){
             	startDate = date.newinstance(System.date.today().year(), 7, 1).addMonths(num*3);
            }else if(System.date.today().month() == 10 || System.date.today().month() == 11 || System.date.today().month() == 12){
             	startDate = date.newinstance(System.date.today().year(), 10, 1).addMonths(num*3);
            }
            if(dateLiteral == 'NEXT_QUARTER' || dateLiteral == 'LAST_QUARTER' || dateLiteral == 'THIS_QUARTER' || dateLiteral == 'N_QUARTERS_AGO'){
                endDate = 	startDate.addMonths(3).addDays(-1);
            }else if(dateLiteral == 'LAST_N_QUARTERS' || dateLiteral == 'NEXT_N_QUARTERS'){
            	endDate = startDate.addMonths(3 * dateLiteralNumber).addDays(-1);   
            }
        }      
        dateValList.add(String.valueOf(Datetime.newInstance(startDate,timegmt)));
        dateValList.add(String.valueOf(Datetime.newInstance(endDate,timegmt)));
        return dateValList;
    }
    public static List<sObject> getFiscalPeriod(List<String> dateLiteralList, List<String> typeList, Integer dateLiteralNumber){
        string periodQry = '';
        if(dateLiteralNumber != null){
            periodQry = 'select Id, startDate,endDate from Period where startDate = '+dateLiteralList[0]+':'+dateLiteralNumber+' AND Type=\''+typeList[0]+'\'';                
        }else{
            periodQry = 'select Id, startDate,endDate from Period where startDate = '+dateLiteralList[0]+' AND Type=\''+typeList[0]+'\'';    
        }
        return Database.query(periodQry); 
    }
    
	public static String getObjectApiName(String objApiName, String fullFieldApiNameWithRef) {
    	if(fullFieldApiNameWithRef.contains('.')){    		
	    	String leftOfFirstDot = fullFieldApiNameWithRef.substringBefore('.');
	    	String rightOfFirstDot = fullFieldApiNameWithRef.substringAfter('.');
            system.debug('@@@ objApiName' + objApiName);
	        system.debug('@@@ fullFieldApiNameWithRef' + fullFieldApiNameWithRef);
	        system.debug('@@@ leftOfFirstDot' + leftOfFirstDot);
	        system.debug('@@@ rightOfFirstDot' + rightOfFirstDot);
	        
			Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get(objApiName).getDescribe();
			Schema.DescribeFieldResult fieldDesc;
			String refObjApiName = '';
			
 			if(leftOfFirstDot.endsWithIgnoreCase('__r')){
	        	fieldDesc = objDesc.fields.getMap().get(leftOfFirstDot.replace('__r','__c')).getDescribe();
	        }else{
	        	fieldDesc = objDesc.fields.getMap().get(leftOfFirstDot + 'Id').getDescribe();
			}
        	List<Schema.SObjectType> reference = fieldDesc.getReferenceTo();
        	objApiName = reference[0].getDescribe().getName();
	    	if(rightOfFirstDot.contains('.')){
	    		objApiName = getObjectApiName(objApiName, rightOfFirstDot);
	    	}
    	}
		return objApiName;
	}
    
}