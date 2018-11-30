public with sharing class REN_LogicBuilderValidationHelper {
	public String namespacePrefix; 
	
	public REN_LogicBuilderValidationHelper(){
	 	namespacePrefix = CSM_Util.getNamespace();
	}
	 
	public String buildWhereCriteriaString(List<REN_Line_Criteria__c> allCriteriaList, REN_Renew_Configuration__c renconfigObj) {
	 	return buildWhereCriteriaString(allCriteriaList, renconfigObj, false);
	}
	
	public String buildWhereCriteriaString(List<REN_Line_Criteria__c> allCriteriaList, REN_Renew_Configuration__c renconfigObj, Boolean forDisplay) {
		return buildWhereCriteriaBulkSearch(allCriteriaList, renconfigObj, forDisplay, null);
	}
	 
	public String buildWhereCriteriaBulkSearch(List<REN_Line_Criteria__c> allCriteriaList, REN_Renew_Configuration__c renconfigObj, Boolean forDisplay, Set<String> returnFirstFilterSet) {
		Map<Integer, String> lineNoToFilterMap = new Map<Integer, String>();
		Boolean isMCEnabled = CSM_Util.checkMCEnabled();
		String corpCurrency = (String)renconfigObj.get(namespacePrefix + 'RLM_Currency_Code__c');//CSM_Util.getCorpCurrency();
		String productReferenceOnOLI = '';
		String apiLabelName = namespacePrefix + 'RLM_Field_Name__c';
		String rlmValue;
		Integer iCount = 0;
		if(forDisplay){
			apiLabelName = namespacePrefix + 'RLM_Field_Display_Name__c';
		}
		for(REN_Line_Criteria__c criteria : allCriteriaList) {
			iCount++;
			String queryString = '';
			if(String.isBlank(criteria.RLM_Values__c)){
				criteria.RLM_Values__c = null;
			}
			if(criteria.RLM_Values__c != null && criteria.RLM_Field_Type__c == CSM_Constants.TYPE_MULTIPICKLIST){
				rlmValue = criteria.RLM_Values__c ;
				rlmValue = rlmValue.replace('[','');
				rlmValue = rlmValue.replace(']','');
				rlmValue = rlmValue.replace(',',';');
				criteria.RLM_Values__c  = rlmValue;
			}
			if(criteria.RLM_Object_API_Name__c == REN_Constants.OBJ_PRODUCT && String.isBlank(productReferenceOnOLI) 
						&& (renconfigObj.REN_Record_Key__c == REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT 
						|| renconfigObj.REN_Record_Key__c == REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET 
						|| renconfigObj.REN_Record_Key__c == REN_Constants.RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM)) {
				productReferenceOnOLI = REN_Constants.PRODUCT_REFERENCE_ON_OPTYLINEITEM;
			}
			
			if (criteria.RLM_Operator__c == CSM_Constants.OPERATOR_ALL) {
					queryString += ' ID != null ';
					criteria.RLM_Is_Specific_Date__c = false;
					criteria.RLM_Date_Value__c = null;
					criteria.RLM_Values__c = null;
					criteria.RLM_Date_Literal_String__c = null;
					criteria.RLM_Date_Literal_Number__c = null;
			}else if (criteria.RLM_Operator__c == CSM_Constants.OPERATOR_LIKE) {
				if(criteria.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY && isMCEnabled) {
					queryString += productReferenceOnOLI+criteria.get(apiLabelName) + 
								' ' + String.escapeSingleQuotes(criteria.RLM_Operator__c) + 
								' \'%'+ String.escapeSingleQuotes(corpCurrency) + String.escapeSingleQuotes(criteria.RLM_Values__c) + '%\'';
				} else if (criteria.RLM_Field_Type__c == CSM_Constants.TYPE_STRING || CSM_Constants.TYPE_REFERENCE.equals(criteria.RLM_Field_Type__c)){
					queryString = CSM_CriteriaService.buildLikeOperator(queryString, criteria.RLM_Values__c, productReferenceOnOLI+criteria.get(apiLabelName));
				} else{
					queryString += productReferenceOnOLI+criteria.get(apiLabelName) + 
									' ' + String.escapeSingleQuotes(criteria.RLM_Operator__c) + ' \'%' + String.escapeSingleQuotes(criteria.RLM_Values__c) + '%\'';
				}
			
			} else if (criteria.RLM_Operator__c == CSM_Constants.DOES_NOT_CONTAINS) { //handles does not contain operator
				if(criteria.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY && isMCEnabled) {
					queryString += '(NOT ' + productReferenceOnOLI+criteria.get(apiLabelName) + 
								' ' + String.escapeSingleQuotes(CSM_Constants.OPERATOR_LIKE) + 
								' \'%'+ String.escapeSingleQuotes(corpCurrency) + String.escapeSingleQuotes(criteria.RLM_Values__c) + '%\')';
				} else if (criteria.RLM_Field_Type__c == CSM_Constants.TYPE_STRING || CSM_Constants.TYPE_REFERENCE.equals(criteria.RLM_Field_Type__c)){
					queryString = CSM_CriteriaService.buildNotLikeOperator(queryString, criteria.RLM_Values__c, productReferenceOnOLI+criteria.get(apiLabelName));
				} else{
					queryString += '(NOT ' + productReferenceOnOLI+criteria.get(apiLabelName) + 
									' ' + String.escapeSingleQuotes(CSM_Constants.OPERATOR_LIKE) + ' \'%' + String.escapeSingleQuotes(criteria.RLM_Values__c) + '%\')';
				}
			}else if (criteria.RLM_Operator__c == CSM_Constants.OPERATOR_IN || criteria.RLM_Operator__c == CSM_Constants.OPERATOR_NOTIN) {  		 
			    	if (CSM_Constants.TYPE_STRING.equals(criteria.RLM_Field_Type__c) || CSM_Constants.TYPE_REFERENCE.equals(criteria.RLM_Field_Type__c) ) {
			    		if(iCount == 1 && returnFirstFilterSet != null){
			    	    	queryString += CSM_CriteriaService.buildStringInOperatorBulk(queryString, criteria.RLM_Values__c, criteria.RLM_Operator__c, productReferenceOnOLI + criteria.get(apiLabelName), returnFirstFilterSet);
			    	   		system.debug('@@@ queryString ::: '+ queryString);
			    		} else {
			    			queryString += CSM_CriteriaService.buildStringInOperator(queryString, criteria.RLM_Values__c, criteria.RLM_Operator__c, productReferenceOnOLI + criteria.get(apiLabelName));
			    		}
			    	}else{
			    		//set corpcurrency to append it before currency value in query ~~A-A~~	
			    		CSM_CriteriaService.currencyCode = String.escapeSingleQuotes(corpCurrency);
			    		queryString += CSM_CriteriaService.buildInNotInOperator(queryString,  criteria.RLM_Values__c, criteria.RLM_Operator__c, productReferenceOnOLI+criteria.get(apiLabelName), criteria.RLM_Field_Type__c); 
			    	}	
			}else if (criteria.RLM_Operator__c == CSM_Constants.OPERATOR_INCLUDES || criteria.RLM_Operator__c == CSM_Constants.OPERATOR_EXCLUDES) {
				queryString += productReferenceOnOLI+criteria.get(apiLabelName) + 
									' ' + criteria.RLM_Operator__c + '(\'' + String.escapeSingleQuotes(criteria.RLM_Values__c) + '\')';	
			} else {
				//If type is Date, read date field, convert to string for query string
				if(criteria.RLM_Field_Type__c == CSM_Constants.TYPE_DATE){ 
					queryString += CSM_CriteriaService.buildDateCriteria(queryString, criteria.RLM_Is_Specific_Date__c, criteria.RLM_Date_Value__c, criteria.RLM_Operator__c, 
					        criteria.RLM_Date_Literal_String__c, (String)criteria.get(apiLabelName), Integer.valueOf(criteria.RLM_Date_Literal_Number__c), criteria.RLM_DateTime_Value__c, criteria.RLM_Field_Type__c);
				}else if(criteria.RLM_Field_Type__c == CSM_Constants.TYPE_DATETIME){ 
					queryString += CSM_CriteriaService.buildDateCriteria(queryString, criteria.RLM_Is_Specific_Date__c, criteria.RLM_Date_Value__c, criteria.RLM_Operator__c, 
					    criteria.RLM_Date_Literal_String__c, (String)criteria.get(apiLabelName), Integer.valueOf(criteria.RLM_Date_Literal_Number__c), criteria.RLM_DateTime_Value__c, criteria.RLM_Field_Type__c);				        
				}else if (criteria.RLM_Field_Type__c == CSM_Constants.TYPE_INTEGER && criteria.RLM_Values__c != null) {//If integer place as integer
						queryString += productReferenceOnOLI+criteria.get(apiLabelName) + ' ' + criteria.RLM_Operator__c + ' ' + Integer.valueOf(criteria.RLM_Values__c);
				}else if ((criteria.RLM_Field_Type__c == CSM_Constants.TYPE_DOUBLE || criteria.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY || criteria.RLM_Field_Type__c == CSM_Constants.TYPE_PERCENT) 
							&& criteria.RLM_Values__c != null) {//If double, place as integer
					String val = (criteria.RLM_Values__c!=null?String.valueOf(Decimal.valueOf(criteria.RLM_Values__c).SetScale(2)):criteria.RLM_Values__c);
					if(criteria.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY && isMCEnabled){
						queryString += productReferenceOnOLI+criteria.get(apiLabelName) + ' ' + criteria.RLM_Operator__c + ' ' + String.escapeSingleQuotes(corpCurrency) + val;
					}else {
						queryString += productReferenceOnOLI+criteria.get(apiLabelName) + ' ' + criteria.RLM_Operator__c + ' ' + val;
					}					
				}else {//otherwise string or picklist and display as string in quotes
					if (criteria.RLM_Values__c == null) {
						if(criteria.RLM_Field_Type__c == CSM_Constants.TYPE_INTEGER ||
							criteria.RLM_Field_Type__c == CSM_Constants.TYPE_DOUBLE || 
							criteria.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY || 
							criteria.RLM_Field_Type__c == CSM_Constants.TYPE_PERCENT) {
							queryString += productReferenceOnOLI+criteria.get(apiLabelName) + ' ' + criteria.RLM_Operator__c + ' ' + criteria.RLM_Values__c;
						}else {
							queryString += productReferenceOnOLI+criteria.get(apiLabelName) + ' ' + criteria.RLM_Operator__c + ' \'\'';
						}
					}else {
						if(criteria.RLM_Field_Type__c == CSM_Constants.TYPE_CURRENCY && isMCEnabled){
							queryString += productReferenceOnOLI+criteria.get(apiLabelName) + 
											' ' + criteria.RLM_Operator__c + 
											' \'' + String.escapeSingleQuotes(corpCurrency) + String.escapeSingleQuotes(criteria.RLM_Values__c) + '\'';
						}else if(criteria.RLM_Field_Type__c == CSM_Constants.TYPE_BOOLEAN){
					    	queryString += productReferenceOnOLI+criteria.get(apiLabelName) + 
					    					' ' + criteria.RLM_Operator__c + ' ' + String.escapeSingleQuotes(criteria.RLM_Values__c);
						}else {
							//if the operator is equals and the field type is string and value contains either new line or tab or comma, then massage the value and treat the operator as IN
							if ((CSM_Constants.OPERATOR_EQUAL.equals(criteria.RLM_Operator__c) || CSM_Constants.OPERATOR_NOTEQUAL.equals(criteria.RLM_Operator__c))
							&& (CSM_Constants.TYPE_STRING.equals(criteria.RLM_Field_Type__c) || CSM_Constants.TYPE_REFERENCE.equals(criteria.RLM_Field_Type__c)
							|| CSM_Constants.TYPE_PICKLIST.equals(criteria.RLM_Field_Type__c) || CSM_Constants.TYPE_ID.equals(criteria.RLM_Field_Type__c) 
							|| CSM_Constants.TYPE_TEXTAREA.equals(criteria.RLM_Field_Type__c) ) ) {
					    		if(iCount == 1 && returnFirstFilterSet != null){
					    	    	queryString += CSM_CriteriaService.buildStringInOperatorBulk(queryString, criteria.RLM_Values__c, 
					    	    		(CSM_Constants.OPERATOR_EQUAL.equals(criteria.RLM_Operator__c) ? CSM_Constants.OPERATOR_IN : CSM_Constants.OPERATOR_NOTIN), 
					    	    		productReferenceOnOLI + criteria.get(apiLabelName), returnFirstFilterSet);
                                    //criteria.RLM_Values__c = null;
								}else{
									queryString += CSM_CriteriaService.buildStringInOperator(queryString,  
			    						criteria.RLM_Values__c,
					    	    		(CSM_Constants.OPERATOR_EQUAL.equals(criteria.RLM_Operator__c) ? CSM_Constants.OPERATOR_IN : CSM_Constants.OPERATOR_NOTIN), 
			    						productReferenceOnOLI + criteria.get(apiLabelName)
			    					);
								}
							} else {
						    	queryString += productReferenceOnOLI+criteria.get(apiLabelName) + 
						    					' ' + criteria.RLM_Operator__c + ' \'' + String.escapeSingleQuotes(criteria.RLM_Values__c) + '\'';
							}
							System.debug('queryString at the end===' + queryString);
						}
					}
				}
			}
			if (queryString !=null && namespacePrefix!=null && namespacePrefix.length()>0) {
        		queryString = queryString.replaceAll(namespacePrefix, '');
        	}
			if(!lineNoToFilterMap.containsKey(Integer.valueOf(criteria.RLM_LineNo__c))) {
				lineNoToFilterMap.put(Integer.valueOf(criteria.RLM_LineNo__c), queryString);
			}
            criteria = null;//To remove space used by 230K-DE3231
		}
		String fltrLogic = renconfigObj.RLM_Filter_Logic__c;
		String fltrLogicWithescapeQuote;
		if(fltrLogic != null){
			fltrLogicWithescapeQuote = String.escapeSingleQuotes(fltrLogic);
		}
        
		System.debug('dcrit1 - ' + lineNoToFilterMap + ' - ' + fltrLogicWithescapeQuote);
		//System.debug('getWhereClauseString(lineNoToFilterMap, fltrLogicWithescapeQuote)===' + getWhereClauseString(lineNoToFilterMap, fltrLogicWithescapeQuote));
		return getWhereClauseString(lineNoToFilterMap, fltrLogicWithescapeQuote);	
	}
	

	/* Added for US401 to process FCV and Play criteria     */
	public String buildWhereCriteriaStringCSM(List<SObject> allCriteriaList, SObject mainObj) {
		Map<Integer, String> lineNoToFilterMap = new Map<Integer, String>();
		Boolean isMCEnabled = CSM_Util.checkMCEnabled();
		String corpCurrency = (String)mainObj.get(namespacePrefix + 'RLM_Currency_Code__c');//CSM_Util.getCorpCurrency();
		String rlmValue;
		for(SObject criteria : allCriteriaList) {
			String queryString = '';
			if(criteria.get(namespacePrefix + 'RLM_Values__c') != null && criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_MULTIPICKLIST){
				rlmValue = (String)criteria.get(namespacePrefix + 'RLM_Values__c') ;
				rlmValue = rlmValue.replace('[','');
				rlmValue = rlmValue.replace(']','');
				rlmValue = rlmValue.replace(',',';');
				//rlmValue = rlmValue.replaceAll('(\\s+)','');
				criteria.put(namespacePrefix + 'RLM_Values__c',rlmValue);
			}
			if (criteria.get(namespacePrefix + 'RLM_Operator__c') == CSM_Constants.DOES_NOT_CONTAINS) { //handles does not contain operator
				if(criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_CURRENCY && isMCEnabled) {
					queryString += '(NOT ' + criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
								' ' + String.escapeSingleQuotes(CSM_Constants.OPERATOR_LIKE) + 
								' \'%'+ corpCurrency + String.escapeSingleQuotes((String)criteria.get(namespacePrefix + 'RLM_Values__c')) + '%\'';
				}
				else if (criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_STRING || CSM_Constants.TYPE_REFERENCE.equals(criteria.get(namespacePrefix + 'RLM_Field_Type__c'))){
					queryString = CSM_CriteriaService.buildNotLikeOperator(queryString, (String)criteria.get(namespacePrefix + 'RLM_Values__c'), (String)criteria.get(namespacePrefix + 'RLM_Field_Name__c'));
				}
				else{
					queryString += '(NOT ' + criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
									' ' + String.escapeSingleQuotes(CSM_Constants.OPERATOR_LIKE) + ' \'%' + String.escapeSingleQuotes((String)criteria.get('RLM_Values__c')) + '%\')';
				}
			}			
			else if (criteria.get(namespacePrefix + 'RLM_Operator__c') == CSM_Constants.OPERATOR_LIKE) {
				if(criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_CURRENCY && isMCEnabled) {
					queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
								' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + 
								' \'%'+ corpCurrency + String.escapeSingleQuotes((String)criteria.get(namespacePrefix + 'RLM_Values__c')) + '%\'';
				}
				else if (criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_STRING || CSM_Constants.TYPE_REFERENCE.equals(criteria.get(namespacePrefix + 'RLM_Field_Type__c'))){
					queryString = CSM_CriteriaService.buildLikeOperator(queryString, (String)criteria.get(namespacePrefix + 'RLM_Values__c'), (String)criteria.get(namespacePrefix + 'RLM_Field_Name__c'));
				}
				else{
					queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
									' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + ' \'%' + String.escapeSingleQuotes((String)criteria.get('RLM_Values__c')) + '%\'';
				}
			}
			else if (criteria.get(namespacePrefix + 'RLM_Operator__c') == CSM_Constants.OPERATOR_IN || criteria.get(namespacePrefix + 'RLM_Operator__c') == CSM_Constants.OPERATOR_NOTIN) {  				 
			    queryString += CSM_CriteriaService.buildInNotInOperator(queryString,  
			    								(String)criteria.get(namespacePrefix + 'RLM_Values__c'), 
			    								(String)criteria.get(namespacePrefix + 'RLM_Operator__c'), 
			    								(String)criteria.get(namespacePrefix + 'RLM_Field_Name__c'), 
			    								(String)criteria.get(namespacePrefix + 'RLM_Field_Type__c')); 
			}else if (criteria.get(namespacePrefix + 'RLM_Operator__c') == CSM_Constants.OPERATOR_INCLUDES || criteria.get(namespacePrefix + 'RLM_Operator__c') == CSM_Constants.OPERATOR_EXCLUDES) {
				queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') +' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + 
								'(\'' + String.escapeSingleQuotes((String)criteria.get(namespacePrefix + 'RLM_Values__c')) + '\')';
			}
			else {
				//If type is Date, read date field, convert to string for query string
				if(criteria.get('RLM_Field_Type__c') == CSM_Constants.TYPE_DATE)
				{
					queryString += CSM_CriteriaService.buildDateCriteria(queryString, (Boolean)criteria.get(namespacePrefix + 'RLM_Is_Specific_Date__c'), (Date)criteria.get(namespacePrefix + 'RLM_Date_Value__c'), (String)criteria.get(namespacePrefix + 'RLM_Operator__c'), 
					        (String)criteria.get(namespacePrefix + 'RLM_Date_Literal_String__c'), (String)criteria.get(namespacePrefix + 'RLM_Field_Name__c'), Integer.valueOf(criteria.get(namespacePrefix + 'RLM_Date_Literal_Number__c')), (DateTime)criteria.get(namespacePrefix + 'RLM_DateTime_Value__c'), (String)criteria.get('RLM_Field_Type__c'));	
				}
				else if(criteria.get('RLM_Field_Type__c') == CSM_Constants.TYPE_DATETIME)
				{
					queryString += CSM_CriteriaService.buildDateCriteria(queryString, (Boolean)criteria.get(namespacePrefix + 'RLM_Is_Specific_Date__c'), (Date)criteria.get(namespacePrefix + 'RLM_Date_Value__c'), (String)criteria.get(namespacePrefix + 'RLM_Operator__c'), 
					        (String)criteria.get(namespacePrefix + 'RLM_Date_Literal_String__c'), (String)criteria.get(namespacePrefix + 'RLM_Field_Name__c'), Integer.valueOf(criteria.get(namespacePrefix + 'RLM_Date_Literal_Number__c')), (DateTime)criteria.get(namespacePrefix + 'RLM_DateTime_Value__c'), (String)criteria.get('RLM_Field_Type__c'));				        
				}
				//If integer place as integer
				else if (criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_INTEGER && criteria.get(namespacePrefix + 'RLM_Values__c') != null) {
					/*if(criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_CURRENCY && isMCEnabled) {
						queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
									' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + 
									' ' + corpCurrency + Integer.valueOf(criteria.get(namespacePrefix + 'RLM_Values__c'));
					}
					else{*/
						queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
										' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + 
										' ' + Integer.valueOf(criteria.get(namespacePrefix + 'RLM_Values__c'));
					//}
				}
				//If double, place as integer
				else if ((criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_DOUBLE 
							|| criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_CURRENCY 
							|| criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_PERCENT)
							&& criteria.get(namespacePrefix + 'RLM_Values__c') != null) {
					 String val = String.valueOf(Decimal.valueOf((String)criteria.get(namespacePrefix + 'RLM_Values__c')).SetScale(2));
					 if(criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_CURRENCY && isMCEnabled){
						queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
										' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + 
										' ' + corpCurrency + val;
					}
					else {
						queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
										' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + 
										' ' + val;
					}
				}
				//otherwise string or picklist and display as string in quotes
				else {
					if (criteria.get(namespacePrefix + 'RLM_Values__c') == null) {
						if( criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_INTEGER
							|| criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_DOUBLE 
							|| criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_CURRENCY 
							|| criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_PERCENT) {
							queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') +
											' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + 
											' ' + criteria.get(namespacePrefix + 'RLM_Values__c');
						}
						else {
							queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
											' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + ' \'\'';
											//' ' + String.escapeSingleQuotes(criteria.RLM_Values__c);
						}
					}
					else {
						if(criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_CURRENCY && isMCEnabled){
							queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
											' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + 
											' \'' + corpCurrency + String.escapeSingleQuotes((String)criteria.get(namespacePrefix + 'RLM_Values__c')) + '\'';
						}
						else if(criteria.get(namespacePrefix + 'RLM_Field_Type__c') == CSM_Constants.TYPE_BOOLEAN){
					    	queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
					    					' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + ' ' + String.escapeSingleQuotes((String)criteria.get(namespacePrefix + 'RLM_Values__c'));
						}
						else if ((CSM_Constants.OPERATOR_EQUAL.equals(criteria.get(namespacePrefix + 'RLM_Operator__c')) || CSM_Constants.OPERATOR_NOTEQUAL.equals(criteria.get(namespacePrefix + 'RLM_Operator__c')))
							&& (CSM_Constants.TYPE_STRING.equals(criteria.get(namespacePrefix + 'RLM_Field_Type__c')) || CSM_Constants.TYPE_REFERENCE.equals(criteria.get(namespacePrefix + 'RLM_Field_Type__c'))
							|| CSM_Constants.TYPE_PICKLIST.equals(criteria.get(namespacePrefix + 'RLM_Field_Type__c'))
							|| CSM_Constants.TYPE_ID.equals(criteria.get(namespacePrefix + 'RLM_Field_Type__c'))) ) {
							queryString += CSM_CriteriaService.buildInNotInOperator(queryString,  
			    								(String)criteria.get(namespacePrefix + 'RLM_Values__c'), 
			    								(CSM_Constants.OPERATOR_EQUAL.equals(criteria.get(namespacePrefix + 'RLM_Operator__c')) ? CSM_Constants.OPERATOR_IN : CSM_Constants.OPERATOR_NOTIN), 
			    								(String)criteria.get(namespacePrefix + 'RLM_Field_Name__c'), 
			    								(String)criteria.get(namespacePrefix + 'RLM_Field_Type__c'));	
						}
						else {
					    	queryString += criteria.get(namespacePrefix + 'RLM_Field_Name__c') + 
					    					' ' + criteria.get(namespacePrefix + 'RLM_Operator__c') + ' \'' + String.escapeSingleQuotes((String)criteria.get(namespacePrefix + 'RLM_Values__c')) + '\'';
						}
					}
				}
			}
			if (queryString !=null && namespacePrefix!=null && namespacePrefix.length()>0) {
        		queryString = queryString.replaceAll(namespacePrefix, '');
        	}
			if(!lineNoToFilterMap.containsKey(Integer.valueOf(criteria.get(namespacePrefix + 'RLM_LineNo__c')))) {
				lineNoToFilterMap.put(Integer.valueOf(criteria.get(namespacePrefix + 'RLM_LineNo__c')), queryString);
			}
		}
		String fltrLogic = (String)mainObj.get(namespacePrefix + 'RLM_Filter_Logic__c');
		return getWhereClauseString(lineNoToFilterMap, fltrLogic);	
	}

	public Boolean validateFilterLogic(String filterLogic, List<SObject> criteriaList){
		if(String.isBlank(filterLogic)){
	 		return true;
	 	}
	 	if(criteriaList == null || criteriaList.isEmpty()){
	 		return false;
	 	}
    	String filterLogicToValidate = filterLogic.replaceAll('\\(', '').replaceAll('\\)', '');
    	list<String> splitFilterList = filterLogicToValidate.split('[a-zA-Z ][a-zA-Z ]');
    	List<String> listOfLogicNum = new List<String>();
    	
    	for(String s: splitFilterList){
    		if(!String.isEmpty(s) )
    		listOfLogicNum.add(s.trim());
    	}
    	
    	Set<String> setOfLineNum = new Set<String>();
        for (SObject lc :criteriaList){
        	Object lineNo = lc.get(namespacePrefix + 'RLM_LineNo__c');
        	String fieldName = String.valueOf(lc.get(namespacePrefix + 'RLM_Field_Name__c'));
        	if(lineNo != null && !fieldName.equalsIgnoreCase(Label.CSM_LBL_NONE)){
        		setOfLineNum.add(String.valueOF(lineNo));
        	}
        }
    	
    	Set<String> strSet  =  new Set<String>(listOfLogicNum);
    	return setOfLineNum.containsAll(strSet);    	
    }
    
	public Boolean validateOperatorsForWrapper(List<REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper> criteriaWrapperList) {
        for (REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper wrapper :criteriaWrapperList){
        	String fieldName = String.valueOf(wrapper.criteria.get(namespacePrefix + 'RLM_Field_Name__c'));
        	String operatorName = String.valueOf(wrapper.criteria.get(namespacePrefix + 'RLM_Operator__c'));
        	if (!Label.CSM_LBL_NONE.equalsIgnoreCase(fieldName) && Label.CSM_LBL_NONE.equalsIgnoreCase(operatorName)) {
        		return false;
        	}
        }
        return true;	
	}
	
	
	public Boolean validateFilterLogicForWrapper(String filterLogic, List<REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper> criteriaWrapperList){
		if(String.isBlank(filterLogic)){
	 		return true;
	 	}
	 	if(criteriaWrapperList == null || criteriaWrapperList.isEmpty()){
	 		return false;
	 	}
    	String filterLogicToValidate = filterLogic.replaceAll('\\(', '').replaceAll('\\)', '');
    	list<String> splitFilterList = filterLogicToValidate.split('[a-zA-Z ][a-zA-Z ]');
    	List<String> listOfLogicNum = new List<String>();
    	
    	for(String s: splitFilterList){
    		if(!String.isEmpty(s) )
    		listOfLogicNum.add(s.trim());
    	}
    	
    	Set<String> setOfLineNum = new Set<String>();
        for (REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper wrapper :criteriaWrapperList){
        	Object lineNo = wrapper.criteria.get(namespacePrefix + 'RLM_LineNo__c');
        	String fieldName = String.valueOf(wrapper.criteria.get(namespacePrefix + 'RLM_Field_Name__c'));
        	if(lineNo != null && !fieldName.equalsIgnoreCase(Label.CSM_LBL_NONE)){
        		setOfLineNum.add(String.valueOF(lineNo));
        	}
        }
     	system.debug('setOfLineNum:' + setOfLineNum );
    	
    	Set<String> strSet  =  new Set<String>(listOfLogicNum);
    	system.debug('strSet:' + strSet );
    	
    	return strSet.containsAll(setOfLineNum) && setOfLineNum.containsAll(strSet);
    	//return setOfLineNum.containsAll(strSet);
    }    
    
    public Boolean validateCriteria(List<SObject> criteriaList,
    									List<REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper> criteriaWrapperList,
    									Map<String, REN_LogicBuilderCmpCtrl.FieldDescribedWrapper> fieldWrapperByLogicBuilderExtName){
		boolean isValid = true;
		if (criteriaWrapperList!=null && !criteriaWrapperList.isEmpty()){
			for (REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper cw : criteriaWrapperList) {
				String operator = cw.criteria.get(namespacePrefix + 'RLM_Operator__c') == null?null:(String)cw.criteria.get(namespacePrefix + 'RLM_Operator__c');
				String fieldApiName = cw.criteria.get(namespacePrefix + 'RLM_Field_Name__c') == null?null:(String)cw.criteria.get(namespacePrefix + 'RLM_Field_Name__c');
				if(operator == null) {
	    			cw.criteria.addError(Label.CSM_MSG_OPERATOR_POPULATED);
	    			isValid = false;
	    		}
	    		REN_LogicBuilderCmpCtrl.FieldDescribedWrapper fdw = fieldWrapperByLogicBuilderExtName.get(fieldApiName);
	    		if(fdw != null){
		    		cw.criteria.put(namespacePrefix + 'RLM_Field_Type__c', fdw.dataType);
	    		}
	    		String fieldType = cw.criteria.get(namespacePrefix + 'RLM_Field_Type__c') == null?null:(String)cw.criteria.get(namespacePrefix + 'RLM_Field_Type__c');
	    		String fieldDisplayName = cw.criteria.get(namespacePrefix + 'RLM_Field_Display_Name__c') == null?null:(String)cw.criteria.get(namespacePrefix + 'RLM_Field_Display_Name__c');
	    		Boolean isSpecificDate = cw.criteria.get(namespacePrefix + 'RLM_Is_Specific_Date__c') == null?null:(Boolean)cw.criteria.get(namespacePrefix + 'RLM_Is_Specific_Date__c');
	    		Date dateValue = cw.criteria.get(namespacePrefix + 'RLM_Date_Value__c') == null?null:(Date)cw.criteria.get(namespacePrefix + 'RLM_Date_Value__c');
	    		DateTime dateTimeValue = cw.criteria.get(namespacePrefix + 'RLM_DateTime_Value__c') == null?null:(DateTime)cw.criteria.get(namespacePrefix + 'RLM_DateTime_Value__c');
	    		String fieldValue = cw.criteria.get(namespacePrefix + 'RLM_Values__c') == null?null:(String)cw.criteria.get(namespacePrefix + 'RLM_Values__c');
	    		String dateLiteral = cw.criteria.get(namespacePrefix + 'RLM_Date_Literal_String__c') == null?null:(String)cw.criteria.get(namespacePrefix + 'RLM_Date_Literal_String__c');
	    		Decimal dateLiteralNumber = cw.criteria.get(namespacePrefix + 'RLM_Date_Literal_Number__c') == null?null:(Decimal)cw.criteria.get(namespacePrefix + 'RLM_Date_Literal_Number__c');
	    		if(operator == CSM_Constants.OPERATOR_ALL)	{
	    			// Do nothing
	    		} else if(fieldType == CSM_Constants.TYPE_DATE && dateValue == null && isSpecificDate != null && isSpecificDate && operator != CSM_Constants.OPERATOR_EQUAL && operator != CSM_Constants.OPERATOR_NOTEQUAL)	{
	    			cw.criteria.addError(Label.CSM_MSG_DATE_POPULATED);
	    			isValid = false;
	    		} else if(fieldType == CSM_Constants.TYPE_DATETIME && dateTimeValue == null && isSpecificDate != null && isSpecificDate && operator != CSM_Constants.OPERATOR_EQUAL && operator != CSM_Constants.OPERATOR_NOTEQUAL){
	    			cw.criteria.addError(Label.CSM_MSG_DATE_TIME_POPULATED);
	    			isValid = false;
	    		} else if (fieldType == CSM_Constants.TYPE_DATE
	    		        && !isSpecificDate
	    		        && dateLiteral != null 
	    		        && String.isBlank(dateLiteral)) {
	    			cw.criteria.addError(Label.CSM_MSG_VALUE_POPULATED);
	    			isValid = false;
	    		} else if ((fieldType == CSM_Constants.TYPE_DATE) 
	    		        && !isSpecificDate
	    		        && dateLiteral != null 
	    		        && (dateLiteral.contains('_N_') || dateLiteral.startsWith('N_'))
	    		        && dateLiteralNumber == null) {
	    			cw.criteria.addError(Label.CSM_MSG_VALUE_POPULATED);
	    			isValid = false;
	    		} else if(fieldType != CSM_Constants.TYPE_DATE && fieldType != CSM_Constants.TYPE_DATETIME 
	    				&& String.isEmpty(fieldValue)){
	    			if(operator != null && 
	    				(operator.equals(CSM_Constants.OPERATOR_EQUAL) 
	    					|| operator.equals(CSM_Constants.OPERATOR_NOTEQUAL))) {
	    				if(fieldType != CSM_Constants.TYPE_STRING && fieldType != CSM_Constants.TYPE_PICKLIST && fieldType != CSM_Constants.TYPE_REFERENCE 
	    					&& fieldType != CSM_Constants.TYPE_INTEGER && fieldType != CSM_Constants.TYPE_DOUBLE && fieldType != CSM_Constants.TYPE_CURRENCY && fieldType != CSM_Constants.TYPE_TEXTAREA){		    					
	    					cw.criteria.addError(Label.CSM_MSG_VALUE_POPULATED + ' ' + fieldDisplayName);
	    					isValid = false;
	    				}
	    			} else {
	    				cw.criteria.addError(Label.CSM_MSG_VALUE_POPULATED + ' ' + fieldDisplayName);
	    				isValid = false;
	    			}
	    		}else if (fieldType == CSM_Constants.TYPE_MULTIPICKLIST && fieldValue == '[]'){
	    				cw.criteria.addError(Label.CSM_MSG_VALUE_POPULATED + ' ' + fieldDisplayName);
	    				isValid = false;
	    		} else if ((operator == CSM_Constants.OPERATOR_LIKE || operator == CSM_Constants.DOES_NOT_CONTAINS)
	    		      && (fieldType == CSM_Constants.TYPE_DATE
	    		      	  || fieldType == CSM_Constants.TYPE_DATETIME
	    		          || fieldType == CSM_Constants.TYPE_INTEGER
	    		          || fieldType == CSM_Constants.TYPE_DOUBLE
	    		          || fieldType == CSM_Constants.TYPE_CURRENCY
	    		          || fieldType == CSM_Constants.TYPE_PERCENT)) {
	    			cw.criteria.addError(Label.CSM_MSG_OPERATOR_WRONG_FIELDTYPE);
	    			isValid = false;
	    		} else if (operator == CSM_Constants.OPERATOR_LIKE 
	    			&& fieldValue.length() < 3) {
	    			cw.criteria.addError(Label.CSM_MSG_LIKE_REQUIRES_MIN);
	    			isValid = false;
	    		} else if ((fieldType == CSM_Constants.TYPE_DATE || fieldType == CSM_Constants.TYPE_DATETIME) 
	    		        && (operator == CSM_Constants.OPERATOR_IN
	    		            || operator == CSM_Constants.OPERATOR_NOTIN || operator == CSM_Constants.DOES_NOT_CONTAINS)){
	    		 	cw.criteria.addError(Label.CSM_MSG_OPERATOR_WRONG_FIELDTYPE);
	    			isValid = false;
	    		} else if (fieldType == CSM_Constants.TYPE_DATE) {
	    			if (isSpecificDate) {
	    				cw.criteria.put(namespacePrefix + 'RLM_Date_Literal_Number__c', null);
	    				cw.criteria.put(namespacePrefix + 'RLM_Date_Literal_String__c', null);	
	    				cw.criteria.put(namespacePrefix + 'RLM_DateTime_Value__c', null);	    				
	    			} else {
	    				cw.criteria.put(namespacePrefix + 'RLM_Date_Value__c', null);
	    				cw.criteria.put(namespacePrefix + 'RLM_DateTime_Value__c', null);
	    				if (dateLiteral != null 
	    					&& !dateLiteral.contains('_N_') 
	    					&& !dateLiteral.startsWith('N_')) {
	    					cw.criteria.put(namespacePrefix + 'RLM_Date_Literal_Number__c', null);
	    				}
	    			}
	    		}
	    		else if(fieldType == CSM_Constants.TYPE_DATETIME){
	    				if (isSpecificDate) {
	    					cw.criteria.put(namespacePrefix + 'RLM_Date_Literal_Number__c', null);
	    					cw.criteria.put(namespacePrefix + 'RLM_Date_Literal_String__c', null);
	    					cw.criteria.put(namespacePrefix + 'RLM_Date_Value__c', null);
	    				}
	    				else{
	    					cw.criteria.put(namespacePrefix + 'RLM_Date_Value__c', null);
	    					cw.criteria.put(namespacePrefix + 'RLM_DateTime_Value__c', null);
	    					if (dateLiteral != null 
	    						&& !dateLiteral.contains('_N_') 
	    						&& !dateLiteral.startsWith('N_')) {
	    						cw.criteria.put(namespacePrefix + 'RLM_Date_Literal_Number__c', null);
	    					}
	    				}
	    		}
				cw.criteria.put(namespacePrefix + 'RLM_Criteria__c', '');
				criteriaList.add(cw.criteria);
			}
		}
		system.debug('datecrit - ' + criteriaList);
		system.debug('isValid::' + isValid);
		return isValid;
	}
	
	public String getWhereClauseString(Map<Integer, String> lineNoToFilterMap, String filterLogic)	{
		String finalWhereClauseString='';
		if(String.isNotBlank(filterLogic)) {
			system.debug('\n~~~~INor - ' + filterLogic);			
			String[] splitFilterLogic = filterLogic.split('(?=\\D)|(?<=\\D)');
			for(String logicChar : splitFilterLogic) {
				if(logicChar != null){
					system.debug('\n~~~~logicChar - ' + logicChar);
					try {
						finalWhereClauseString += lineNoToFilterMap.get(Integer.valueOf(logicChar));
					}catch(system.TypeException te){
						finalWhereClauseString += String.escapeSingleQuotes(logicChar);
					}
				}
			}
			system.debug(splitFilterLogic +'\n~~~~INorquery - ' + finalWhereClauseString);			
		} else {
			system.debug('INand - ' + lineNoToFilterMap);			
			List<String> cList = lineNoToFilterMap.values();
			for(Integer i=0; i<cList.size(); i++) {
				if(i == 0)	{
					finalWhereClauseString = cList[i];
				} else {
					finalWhereClauseString += ' AND ' + cList[i];			
				}
			}				
		}
		System.debug('finalWhereClauseString - '+finalWhereClauseString);
		return finalWhereClauseString;
	}
}