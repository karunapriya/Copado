public with sharing class CSM_CriteriaService {
	//Variable defect DE2689 for appending currencyCode to currency value in query
	public static String currencyCode = '';
	public static String buildInNotInOperator(String queryString, String valueWithCommas, String operator, String fieldName, String fieldType)
	{
		//List<String> valueList = valueWithCommas.split(','); 
		Set<String> valueSet = REN_Util.parseFilterValues(valueWithCommas); 
	    queryString += fieldName + ' ' + operator + ' (';
	    
	    boolean firstValue = true;
	    for (String value: valueSet)
	    {
	    	if (firstValue)
			{
				firstValue = false;
			}
			else
			{
				queryString += ',';
			}
	    	//If type is Date, read date field, convert to string for query string
			if (fieldType == CSM_Constants.TYPE_INTEGER)
			{
				queryString += Integer.valueOf(value);
			}
			//If double, place as integer
			else if (fieldType == CSM_Constants.TYPE_DOUBLE || fieldType == CSM_Constants.TYPE_CURRENCY || fieldType == CSM_Constants.TYPE_PERCENT)
			{
				if(fieldType == CSM_Constants.TYPE_CURRENCY)
				{
					queryString += currencyCode + Double.valueOf(value);
				}
				else
				{
					queryString += Double.valueOf(value);
				}
			}
			else if (fieldType == CSM_Constants.TYPE_BOOLEAN)
			{
				queryString += value;
			}
			
			//otherwise string or picklist and display as string in quotes
			else
			{
				if (value.contains('\\\'')) {
					queryString += '\'' + value + '\'';	
				} else {
					queryString += '\'' + String.escapeSingleQuotes(value) + '\'';	
				}								
			}
			
	    }
	    
	    queryString += ')'; 
	    return queryString;
	}

	public static String buildStringInOperator(String queryString, String valueWithCommas, String operator, String fieldName){
		Set<String> valueSet = REN_Util.parseFilterValues(valueWithCommas);
	    String filterStr = '';
	    for (String value: valueSet){
			filterStr +=  '\'' + String.escapeSingleQuotes(value) + '\',' ;
			//queryString += '\'' + String.escapeSingleQuotes(value) + '\'';
	    }
	    filterStr = filterStr.removeEnd(',');
	    System.debug('filterStr ==='+ filterStr);
	    return String.isBlank(filterStr) ?  queryString : queryString + ' ' + (fieldName + ' ' + operator + ' (' + filterStr + ')' );
	}
	public static String buildLikeOperator(String queryString, String valueWithCommas, String fieldName) {
		Set<String> valueSet = REN_Util.parseFilterValues(valueWithCommas);
	    String filterStr = '';
	    for (String value: valueSet){
			filterStr +=  fieldName + ' LIKE \'%' + String.escapeSingleQuotes(value) + '%\' OR ';
			//queryString += '\'' + String.escapeSingleQuotes(value) + '\'';
	    }
	    filterStr = filterStr.removeEnd(' OR ');
	    System.debug('filterStr ==='+ filterStr);
	    return String.isBlank(filterStr) ?  queryString : (queryString + ' ' + ' (' + filterStr + ')' );

	}
	
	public static String buildStringInOperatorBulk(String queryString, String valueWithCommas, String operator, String fieldName, Set<String> returnFirstFilterSet){
		returnFirstFilterSet.addAll(REN_Util.parseFilterValues(valueWithCommas));
	    return returnFirstFilterSet.isEmpty() ?  queryString : queryString + ' ' + (fieldName + ' ' + operator + ' :firstFilterSet ' );
	}

	public static String buildNotLikeOperator(String queryString, String valueWithCommas, String fieldName) {
		List<String> valueList = valueWithCommas.split(',');  
	    queryString += ' ( NOT ' + buildLikeOperator('', valueWithCommas, fieldName) + ' ) ';
	    return queryString;
	}

/*	
	public static String buildInNotForStringInOperator(String queryString, String valueWithCommas, String operator, String fieldName, String fieldType)
	{
		List<String> valueList = new List<String> ();
	   
	    queryString += fieldName + ' ' + operator + ' (';
	    Set<String> trimmedCommaSplitList=REN_Util.setOfFormattedInputForLogicBuilder(valueWithCommas).KeySet();
		System.debug('trimmedCommaSplitList===' + trimmedCommaSplitList);
		for (String trimStr : trimmedCommaSplitList) {
				string temp='';
    			if(trimStr.contains(',') || trimStr.contains('"')){   				
    				temp= '\'' + trimStr + '\'';
    				valueList.add(temp);
    			}else if (trimStr.contains('\'')){
    				String inputr;
    				if (trimStr.contains('\\\'')) {
    					inputr = trimStr;
    				} else {
    					inputr = String.escapeSingleQuotes(trimStr);
    				}					
					temp += '\''+ inputr +'\'';
					valueList.add(temp);
    			}else{
    				if(string.isEmpty(temp)){
    					temp= '\'' + trimStr + '\'';
						valueList.add(temp);
    				}
    			}
		}
		
	    System.debug('valueList===' + valueList);
	    boolean firstValue = true;
	    for (String value: valueList)
	    {
	    	if (firstValue)
			{
				firstValue = false;
			}
			else
			{
				queryString += ',';
			}
	    	//If type is Date, read date field, convert to string for query string
			if (fieldType == CSM_Constants.TYPE_INTEGER)
			{
				queryString += Integer.valueOf(value);
			}
			//If double, place as integer
			else if (fieldType == CSM_Constants.TYPE_DOUBLE || fieldType == CSM_Constants.TYPE_CURRENCY || fieldType == CSM_Constants.TYPE_PERCENT)
			{
				queryString += Double.valueOf(value);
			}
			else if (fieldType == CSM_Constants.TYPE_BOOLEAN)
			{
				queryString += value;
			}
			
			//otherwise string or picklist and display as string in quotes
			else
			{
				queryString += value;
				//queryString += '\'' + String.escapeSingleQuotes(value) + '\'';
			}
			
	    }
	    queryString = queryString.removeEnd(',');
	    queryString += ')'; 
	    system.debug('queryString==='+queryString);
	    return queryString;
	}



	public static String buildLikeOperator(String queryString, String valueWithCommas, String operator, String fieldName, String fieldType) {
		List<String> valueList = valueWithCommas.split(',');  
	    //queryString += fieldName + ' ' + operator + ' (';
	    queryString += ' (';
	    
	    boolean firstValue = true;
	    for (String value: valueList) {
	    	if (firstValue) {
				firstValue = false;
			}
			else {
				queryString += ' OR ';
			}
			queryString = queryString + fieldName + ' LIKE \'%' + value + '%\'';			
	    }
	    
	    queryString += ')'; 
	    System.debug('queryString===' + queryString);
	    return queryString;
	}
	
	public static String buildNotLikeOperator(String queryString, String valueWithCommas, String operator, String fieldName, String fieldType) {
		List<String> valueList = valueWithCommas.split(',');  
	    queryString += ' (NOT (';
	    
	    boolean firstValue = true;
	    for (String value: valueList) {
	    	if (firstValue) {
				firstValue = false;
			}
			else {
				queryString += ' OR ';
			}
			queryString = queryString + '('+ fieldName + ' LIKE \'%' + value + '%\')';			
	    }
	    
	    queryString += '))'; 
	    System.debug('queryString in buildNotLikeOperator===' + queryString);
	    return queryString;
	}
	*/
	public static String buildDateCriteria(String queryString, boolean specificDate, Date dateValue, String operator, String dateLiteralString, String fieldName, Integer dateLiteralNumber, DateTime dateTimeValue, String fieldType)
	{
		if(fieldType == CSM_Constants.TYPE_DATE)
		{
			if (specificDate)
			{
				String dateString = null;
				if(dateValue != null)
				{
				dateString = String.valueOf(dateValue);
				List<String> splitString = dateString.split(' ',2);
				if(splitString != null && !splitString.isEmpty())
				{
					dateString = splitString[0];
				}
				}
				queryString += fieldName  + ' ' + operator + ' ' + dateString;		
			}	
			else if(dateLiteralString != null)
			{
				queryString += fieldName + ' ' + operator + ' ' + dateLiteralString;
				if(dateLiteralString != null){
					if (dateLiteralString.contains('_N_') || dateLiteralString.startsWith('N_'))
					{
						queryString += ':' + dateLiteralNumber;
					}
				}
			}
		}
		else if(fieldType == CSM_Constants.TYPE_DATETIME)
		{
			if(specificDate){
				if(dateTimeValue != null)
				{
				String dateTimeString1 = dateTimeValue.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
				dateTimeValue = dateTimeValue.addMinutes(1);
				String dateTimeString2 = dateTimeValue.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
				
				if(operator == CSM_Constants.OPERATOR_EQUAL)
				{
					queryString += '(' + fieldName  + ' ' + CSM_Constants.OPERATOR_GREATERTHANEQUALTO + ' ' + dateTimeString1 + ' AND ' + fieldName  + ' ' + CSM_Constants.OPERATOR_LESSERTHANEQUALTO + ' ' + dateTimeString2 + ')';
				}
				else if(operator == CSM_Constants.OPERATOR_GREATERTHANEQUALTO)
				{
					queryString += fieldName  + ' ' + operator + ' ' + dateTimeString1;
				}
				else if(operator == CSM_Constants.OPERATOR_LESSERTHANEQUALTO)
				{
					queryString += fieldName  + ' ' + CSM_Constants.OPERATOR_LESSERTHAN + ' ' + dateTimeString2;
				}
				else if(operator == CSM_Constants.OPERATOR_GREATERTHAN)
				{
					queryString += fieldName  + ' ' + CSM_Constants.OPERATOR_GREATERTHANEQUALTO + ' ' + dateTimeString2;
				}
				else if(operator == CSM_Constants.OPERATOR_LESSERTHAN)
				{
					queryString += fieldName  + ' ' + operator + ' ' + dateTimeString1;
				}
				else
				{
					queryString += '(' + fieldName  + ' ' + CSM_Constants.OPERATOR_LESSERTHAN + ' ' + dateTimeString1 + ' OR '
									   + fieldName  + ' ' + CSM_Constants.OPERATOR_GREATERTHAN + ' ' + dateTimeString2 + ')';
				}
				}
				else
				{
					if(operator == CSM_Constants.OPERATOR_EQUAL || operator == CSM_Constants.OPERATOR_NOTEQUAL)
					{
						queryString += fieldName  + ' ' + operator + ' ' + null;
					}
				}
			}
			else if(dateLiteralString != null)
			{
				queryString += fieldName + ' ' + operator + ' ' + dateLiteralString;
				if(dateLiteralString != null){
					if (dateLiteralString.contains('_N_') || dateLiteralString.startsWith('N_'))
					{
						queryString += ':' + dateLiteralNumber;
					}
				}
			}
		}
		return queryString;
	}
	
	public static List<SelectOption> getDateStringList()
	{
	    List<SelectOption> dateStringList = new List<SelectOption>();
	    dateStringList.add(new SelectOption(CSM_Constants.C_YESTERDAY, Label.CSM_LBL_YESTERDAY));
	    dateStringList.add(new SelectOption(CSM_Constants.C_TODAY, Label.CSM_LBL_TODAY));
	    dateStringList.add(new SelectOption(CSM_Constants.C_TOMORROW, Label.CSM_LBL_TOMORROW));
	    
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_WEEK, Label.CSM_LBL_LAST_WEEK));
	    dateStringList.add(new SelectOption(CSM_Constants.C_THIS_WEEK, Label.CSM_LBL_THIS_WEEK));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_WEEK, Label.CSM_LBL_NEXT_WEEK));
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_N_WEEKS, Label.CSM_LBL_LAST_N_WEEKS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_N_WEEKS, Label.CSM_LBL_NEXT_N_WEEKS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_N_WEEKS_AGO, Label.CSM_LBL_N_WEEKS_AGO));
	    
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_MONTH, Label.CSM_LBL_LAST_MONTH));
	    dateStringList.add(new SelectOption(CSM_Constants.C_THIS_MONTH, Label.CSM_LBL_THIS_MONTH));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_MONTH, Label.CSM_LBL_NEXT_MONTH));
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_N_MONTHS, Label.CSM_LBL_LAST_N_MONTHS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_N_MONTHS, Label.CSM_LBL_NEXT_N_MONTHS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_N_MONTHS_AGO, Label.CSM_LBL_N_MONTHS_AGO));
	    
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_90_DAYS, Label.CSM_LBL_LAST_90_DAYS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_90_DAYS, Label.CSM_LBL_NEXT_90_DAYS));
	    
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_N_DAYS, Label.CSM_LBL_LAST_N_DAYS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_N_DAYS, Label.CSM_LBL_NEXT_N_DAYS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_N_DAYS_AGO, Label.CSM_LBL_N_DAYS_AGO));
	    
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_QUARTER, Label.CSM_LBL_LAST_QUARTER));
	    dateStringList.add(new SelectOption(CSM_Constants.C_THIS_QUARTER, Label.CSM_LBL_THIS_QUARTER));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_QUARTER, Label.CSM_LBL_NEXT_QUARTER));
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_N_QUARTERS, Label.CSM_LBL_LAST_N_QUARTERS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_N_QUARTERS, Label.CSM_LBL_NEXT_N_QUARTERS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_N_QUARTERS_AGO, Label.CSM_LBL_N_QUARTERS_AGO));
	    
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_YEAR, Label.CSM_LBL_LAST_YEAR));
	    dateStringList.add(new SelectOption(CSM_Constants.C_THIS_YEAR, Label.CSM_LBL_THIS_YEAR));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_YEAR, Label.CSM_LBL_NEXT_YEAR));
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_N_YEARS, Label.CSM_LBL_LAST_N_YEARS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_N_YEARS, Label.CSM_LBL_NEXT_N_YEARS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_N_YEARS_AGO, Label.CSM_LBL_N_YEARS_AGO));
	    
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_FISCAL_QUARTER, Label.CSM_LBL_LAST_FISCAL_QUARTER));
	    dateStringList.add(new SelectOption(CSM_Constants.C_THIS_FISCAL_QUARTER, Label.CSM_LBL_THIS_FISCAL_QUARTER));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_FISCAL_QUARTER, Label.CSM_LBL_NEXT_FISCAL_QUARTER));
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_N_FISCAL_QUARTERS, Label.CSM_LBL_LAST_N_FISCAL_QUARTERS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_N_FISCAL_QUARTERS, Label.CSM_LBL_NEXT_N_FISCAL_QUARTERS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_N_FISCAL_QUARTERS_AGO, Label.CSM_LBL_N_FISCAL_QUARTERS_AGO));
	    
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_FISCAL_YEAR, Label.CSM_LBL_LAST_FISCAL_YEAR));
	    dateStringList.add(new SelectOption(CSM_Constants.C_THIS_FISCAL_YEAR, Label.CSM_LBL_THIS_FISCAL_YEAR));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_FISCAL_YEAR, Label.CSM_LBL_NEXT_FISCAL_YEAR));
	    dateStringList.add(new SelectOption(CSM_Constants.C_LAST_N_FISCAL_YEARS, Label.CSM_LBL_LAST_N_FISCAL_YEARS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_NEXT_N_FISCAL_YEARS, Label.CSM_LBL_NEXT_N_FISCAL_YEARS));
	    dateStringList.add(new SelectOption(CSM_Constants.C_N_FISCAL_YEARS_AGO, Label.CSM_LBL_N_FISCAL_YEARS_AGO));
	    return dateStringList;	    
	}
    
    public static List<SelectOption> getRecordTypeFromObject(String objectName){ 
     
        List<SelectOption> recordTypeStringList = new List<SelectOption>();
        String soql = 'SELECT Id,Name,SobjectType FROM RecordType';
        List<RecordType> recordTyprList =  Database.query(soql);
        if(!recordTyprList.isEmpty()){
            for( RecordType rtObj : recordTyprList){
                if(rtObj.SobjectType == objectName)
                	recordTypeStringList.add(new SelectOption(rtObj.Id,rtObj.Name));
            }
        }
        system.debug('1----recordTypeStringList--'+recordTypeStringList);
       
        return recordTypeStringList;
	}
}