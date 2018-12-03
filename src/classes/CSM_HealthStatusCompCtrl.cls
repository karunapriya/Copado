/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		09.12.2014
 * @description	CSM_HealthStatusCompCtrl class used for the account health status chart
 */
	
public with sharing class CSM_HealthStatusCompCtrl {
	
	
	public String healthStatusType {get; set;}
	private Map<String,Integer> pieChartMap;
	private List<String> healthColors;
	private List<String> healthOptionList;
	public Integer totalRecordCount {get; set;} 
	public CSM_UserPreferencesFilterWrapper userWrapper {get; set;}
	
	/** 
 	 * @description	constructor
 	 */
	public CSM_HealthStatusCompCtrl() {
	
	}
	
	private void initValues() {
		pieChartMap = new Map<String,Integer>();
		healthColors = new List<String>();
		healthStatusType = '';
		totalRecordCount = 0;
		//Get the colors from the custom setting
		healthColors = CSM_AdminDataAccess.getAdminList(CSM_Constants.OBJ_LIST_HEALTH_COLORS);
	}
	
	private void populateHealthOptionList()
	{
		if (healthOptionList == null)
		{
			List<String> optionsList = new List<String>();
			
			Set<String> statusNotInCustomSetting = new Set<String>();
			
			List<String> csHealthOptions = CSM_AdminDataAccess.getAdminList(CSM_Constants.OBJ_LIST_HEALTH_OPTIONS);
			
			Schema.DescribeFieldResult fieldResult = Account.CSM_Health_Status__c.getDescribe();
            List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : pleList)
		    {
	    	    statusNotInCustomSetting.add(f.getLabel());
			}
			statusNotInCustomSetting.add(Label.CSM_LBL_UNDETERMINED);	
			
			boolean foundVal = false;
	        for (String healthO: csHealthOptions)
			{     
	            foundVal = false;
	            for(String f : statusNotInCustomSetting)
			    {
		    		if (f == healthO)
					{
						foundVal = true;
						statusNotInCustomSetting.remove(f);
						optionsList.add(f);
					}
					
					
				}
		        if (!foundVal)
		        {
		        	optionsList.add(healthO);
		        }
		    }   
			healthOptionList = new List<String>();
			healthOptionList.addAll(optionsList);
			healthOptionList.addAll(statusNotInCustomSetting);
			System.debug('donut health option list'+healthOptionList);
		}
	}
	
	/** 
 	 * @description	gets the account information, builds the chart data and returns the json
 	 * @return String
 	 */
	public String pieData {
		get {
			try {				
				//MF Get account info - Remove accountlist declaration from public variable
				initValues();		
				List<Account> accountList = new List<Account>();
				System.debug('VVV - userWrapper - '+userWrapper);
				accountList = CSM_AccountDataAccess.getHealthInformationForSpecificAccounts(userWrapper);
				System.debug('ZZZ accountList - '+accountList);
				if(!accountList.isEmpty())
				{
					totalRecordCount = accountList.size();
				}
				for (Account a : accountList)
				{
					//Loop through list and build map
					if (String.isBlank(a.CSM_Health_Status__c))
					{
						if(!pieChartMap.containsKey(Label.CSM_LBL_UNDETERMINED))
						{
							pieChartMap.put(Label.CSM_LBL_UNDETERMINED,1);
						}
						else
						{
							pieChartMap.put(Label.CSM_LBL_UNDETERMINED,  pieChartMap.get(Label.CSM_LBL_UNDETERMINED)+1 );
						}
					}
					else
					{
						if(!pieChartMap.containsKey(a.CSM_Health_Status__c))
						{
							pieChartMap.put(a.CSM_Health_Status__c,1);
						}
						else
						{
							pieChartMap.put(a.CSM_Health_Status__c,  pieChartMap.get(a.CSM_Health_Status__c)+1 );
						}
					}
					
				}
				system.debug('pieChartMap $$ ' + pieChartMap);
				//Generate json from the map data
				JSONGenerator generator = JSON.createGenerator(true);
				generator.writeStartObject();
		        generator.writeFieldName('data');
		        generator.writeStartArray();
		        populateHealthOptionList();
		       
		        if (healthOptionList != null)
		        {
			        for (String healthOption: healthOptionList)
			        {		        	
			        	if (pieChartMap.containsKey(healthOption))
			        	{
			        		//Double percentageCalculated = 0.0;
			        		//percentageCalculated = ((double)pieChartMap.get(healthOption) / (double)totalRecordCount) * 100;
			        		//percentageCalculated = Math.round(percentageCalculated, 2);
			        		Decimal percentageCalculated = 0.0;
			        		percentageCalculated = ((decimal)pieChartMap.get(healthOption) / (decimal)totalRecordCount) * 100;
			        		percentageCalculated = percentageCalculated.setScale(1,RoundingMode.HALF_UP);
			        		system.debug('percentage $$ ' + pieChartMap.get(healthOption)  + ' ' + totalRecordCount + ' ' + percentageCalculated);
			        		generator.writeStartObject();
			        		generator.writeStringField('name',healthOption);
			        		generator.writeNumberfield('y',pieChartMap.get(healthOption));
			        		generator.writeNumberfield('percent',percentageCalculated);
			        		generator.writeEndObject();
			        		pieChartMap.remove(healthOption);
			        	}		        	
			        }
		        }
		        if (pieChartMap != null)
		        {
					for (String s : pieChartMap.keySet())
			        {
			        	generator.writeStartObject();
			        	if(String.isBlank(s))
			        	{
			        		generator.writeStringField('name',Label.CSM_LBL_UNDETERMINED);	
			        	}
			        	else
			        	{
			        		generator.writeStringField('name',s);
			        	}
			        	generator.writeNumberfield('y',pieChartMap.get(s));
			        	Decimal percentageCalculated = 0.0;
			        		percentageCalculated = ((decimal)pieChartMap.get(s) / (decimal)totalRecordCount) * 100;
			        		percentageCalculated = percentageCalculated.setScale(1,RoundingMode.HALF_UP);
			        		system.debug('percentage $$ ' + pieChartMap.get(s)  + ' ' + totalRecordCount + ' ' + percentageCalculated);
			        	generator.writeNumberfield('percent',percentageCalculated);
	        			generator.writeEndObject();
			        }
		        }
    			generator.writeEndArray();//end of records array
			    generator.writeEndObject();
			    return generator.getAsString();
			        
        	
			}
			catch (exception ex)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));	
			}
			return null;
		}
	}
	
	/** 
 	 * @description	returns the json string of the health colors
 	 * @return string
 	 */
	public String colorData {
		get {
			JSONGenerator generator = JSON.createGenerator(true);
		    generator.writeStartArray();
			for (String s : healthColors)
	        {
	        	generator.writeString(s);
	        }	
	        generator.writeEndArray();//end of records array
		    return generator.getAsString();
		}
	}
	
	/** 
 	 * @description	redirects the page to the account health status page
 	 * @return pageReference
 	 */
	public PageReference displayDetails() {
		if(!String.isBlank(healthStatusType))
		{
			String fieldValue;
			if(userWrapper.attrFieldUserId != null){
				fieldValue = userWrapper.attrFieldUserId;
			}
			else{
				if(userWrapper.attrFieldType == CSM_Constants.TYPE_DATE){
					 fieldValue = String.valueOf(userWrapper.attrFieldDateValue);
				}
				else{
					fieldValue = userWrapper.attrFieldValue;
				}
			}
			
			if(fieldValue == null){
				fieldValue = CSM_Constants.NULL_PARAM;
			}
			else if(fieldValue == ''){
				fieldValue = CSM_Constants.NULL_PARAM;
			}
			PageReference pageRef = Page.CSM_AccountHealthStatus;
			pageRef.getParameters().put(CSM_Constants.STATUS_PARAM, healthStatusType);
			pageRef.getParameters().put(CSM_Constants.RANGE_DATE_PARAM, null);
			if (userWrapper.attObjectType != null) {
				pageRef.getParameters().put(CSM_Constants.USER_PREF_OBJECT_TYPE, userWrapper.attObjectType);
				pageRef.getParameters().put(CSM_Constants.USER_PREF_FIELD_NAME, userWrapper.attrFieldName);
				pageRef.getParameters().put(CSM_Constants.USER_PREF_FIELD_TYPE, userWrapper.attrFieldType);
				pageRef.getParameters().put(CSM_Constants.USER_PREF_FIELD_VALUE, fieldValue);
			}
			/* if (userWrapper.attObjectType != null && userWrapper.attObjectType.equalsIgnoreCase('Success Plan')) {
				system.debug('Success Plan Object');
				pageRef.getParameters().put(CSM_Constants.USER_PREF_OBJECT_TYPE, userWrapper.attObjectType);
				//cannot pass set, need to pass string, and then convert to set in heatmap controller before passing it to the grid
				
				pageRef.getParameters().put(CSM_Constants.USER_SP_ACCT_ARRAY, CSM_Util.setToString(userWrapper.attrSPAccountIdsList));
			}*/

			pageRef.setRedirect(true);
			return pageRef;
		}
		return null;
	}


}