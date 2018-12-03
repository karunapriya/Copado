public with sharing class CSM_HealthStatusHeatmapComponentCntrl
{
	public String heatmapData;
	
	private Map<String,Map<Integer,Integer>> heatChartMap;
	private Date todayDate = System.Today();
	private List<String> healthOptionList;
	public Integer xPoint {get; set;}
	public String yPoint {get; set;}
	public CSM_UserPreferencesFilterWrapper userWrapper {get; set;}
		
	public CSM_HealthStatusHeatmapComponentCntrl()
	{
		heatChartMap = new Map<String,Map<Integer,Integer>>();
	}
		
	private Integer getDaysCategory(Account healthAcc)
	{
		if (healthAcc.CSM_Last_Health_Status__c == null)
		{
			return CSM_Constants.INT_NO_HEALTH_CHECK;
		}
		else if (Math.abs(todayDate.daysBetween(healthAcc.CSM_Last_Health_Status__c)) > 120)
		{
			return CSM_Constants.INT_GREATER_121;
		}
		else if (Math.abs(todayDate.daysBetween(healthAcc.CSM_Last_Health_Status__c)) > 90
		        && Math.abs(todayDate.daysBetween(healthAcc.CSM_Last_Health_Status__c)) < 121)
		{
			return CSM_Constants.INT_BETWEEN_91_120;
		}
		else if (Math.abs(todayDate.daysBetween(healthAcc.CSM_Last_Health_Status__c)) > 60
		        && Math.abs(todayDate.daysBetween(healthAcc.CSM_Last_Health_Status__c)) < 91)
		{
			return CSM_Constants.INT_BETWEEN_61_90;
		}
		else if (Math.abs(todayDate.daysBetween(healthAcc.CSM_Last_Health_Status__c)) > 30
		        && Math.abs(todayDate.daysBetween(healthAcc.CSM_Last_Health_Status__c)) < 61)
		{
			return CSM_Constants.INT_BETWEEN_31_60;
		}
		else if (Math.abs(todayDate.daysBetween(healthAcc.CSM_Last_Health_Status__c)) >= 0
		        && Math.abs(todayDate.daysBetween(healthAcc.CSM_Last_Health_Status__c)) < 31)
		{
			return CSM_Constants.INT_BETWEEN_0_30;
		}
		return CSM_Constants.INT_NO_HEALTH_CHECK;
	}
	
	public String getHeatmapData()
	{
		heatmapData = '';
		heatChartMap = new Map<String,Map<Integer,Integer>>();
		
		try
		{
			List<Account> healthInfoAccounts = CSM_AccountDataAccess.getHealthInformationForSpecificAccounts(userWrapper);
			for (Account healthAcc: healthInfoAccounts)
			{
				String healthStatus = healthAcc.CSM_Health_Status__c;
				if (healthStatus == null)
				{
					healthStatus = Label.CSM_LBL_UNDETERMINED;
				}
				Map<Integer,Integer> healthDaysMap = null;
				Integer daysCategory = getDaysCategory(healthAcc);
				if (heatChartMap.containsKey(healthStatus))
				{
					healthDaysMap = heatChartMap.get(healthStatus);
					if (healthDaysMap.containsKey(daysCategory))
					{
						healthDaysMap.put(daysCategory,healthDaysMap.get(daysCategory) + 1);
					}
					else
					{
						healthDaysMap.put(daysCategory,1);
					}
					heatChartMap.put(healthStatus, healthDaysMap);
				}
				else 
				{
					healthDaysMap = new Map<Integer, Integer>();
					healthDaysMap.put(daysCategory,1);
					heatChartMap.put(healthStatus, healthDaysMap);
				}
				
				
			}
			heatmapData = generateJson();
		}
		catch (Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));	
		}
		return heatmapData;
	}
	private void populateHealthOptionList()
	{
		if (healthOptionList == null)
		{
			List<String> optionsList = new List<String>();
			
			Set<String> statusNotInCustomSetting = new Set<String>();
			
			List<String> wrongOrder = CSM_AdminDataAccess.getAdminList(CSM_Constants.OBJ_LIST_HEALTH_OPTIONS);
			
			Schema.DescribeFieldResult fieldResult = Account.CSM_Health_Status__c.getDescribe();
            List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : pleList)
		    {
	    	    statusNotInCustomSetting.add(f.getLabel());
			}
			statusNotInCustomSetting.add(Label.CSM_LBL_UNDETERMINED);	
			
			boolean foundVal = false;
	        for (Integer i = wrongOrder.size() - 1; i >= 0; i--)
			{     
	            foundVal = false;
	            for(String f : statusNotInCustomSetting)
			    {
		    		if (f == wrongOrder.get(i))
					{
						foundVal = true;
						statusNotInCustomSetting.remove(f);
						optionsList.add(f);
					}
					
					
				}
		        if (!foundVal)
		        {
		        	optionsList.add(wrongOrder.get(i));
		        }
		    }   
			healthOptionList = new List<String>();
			healthOptionList.addAll(statusNotInCustomSetting);
			healthOptionList.addAll(optionsList);
		}
	}
	public String healthCategories;
	public String getHealthCategories()
	{
		JSONGenerator generator = JSON.createGenerator(true);
		populateHealthOptionList();
	    generator.writeStartObject();
	    generator.writeFieldName('healthCats');
	    generator.writeStartArray();
	    for (String healthOption: healthOptionList)
	    {
	    	generator.writeString(healthOption);
	    }
	    generator.writeEndArray();
	    generator.writeEndObject();
	    return generator.getAsString();
	}
	
	
	private String generateJson()
	{
	    JSONGenerator generator = JSON.createGenerator(true);
	    populateHealthOptionList();
	   
	    
	    generator.writeStartObject();
	    generator.writeFieldName('dataForHeatmap');
	    generator.writeStartArray();
	    
        if (healthOptionList != null)
        {
	        Integer healthStatusTypeInt = 0;
	        for (String healthOption: healthOptionList)
	        {	
	        	for (Integer i = 0; i < 6; i++)
        		{
	        		generator.writeStartArray();
	        		generator.writeNumber(i);	    
				    generator.writeNumber(healthStatusTypeInt);
				    
				    if (heatChartMap.containsKey(healthOption))
	        	    {
				    	Map<Integer,Integer> healthDaysMap = heatChartMap.get(healthOption);
				    	if (healthDaysMap.containsKey(i))
				    	{
				    		generator.writeNumber(healthDaysMap.get(i));
				    	}
				    	else
				    	{
				    		generator.writeNumber(0);
				    	}
				    }
				    else
				    {
				    	generator.writeNumber(0);
				    }
				    	    
				    generator.writeEndArray();
        		}
	        	healthStatusTypeInt++;
	        }
        }
        generator.writeEndArray();
	    generator.writeEndObject();
	        
	    return generator.getAsString();
	}
	
	
	public PageReference displayAccountHealthStatus() {		
		String dateRangeString = CSM_Constants.NO_HEALTH_CHECK;
		
		if (xPoint == CSM_Constants.INT_GREATER_121)
		{
			dateRangeString =   CSM_Constants.MORE_THAN_121;
		}
		else if (xPoint == CSM_Constants.INT_BETWEEN_91_120)
		{
			 dateRangeString = CSM_Constants.BETWEEN_91_120;
		}
		else if (xPoint == CSM_Constants.INT_BETWEEN_61_90)
		{
			 dateRangeString = CSM_Constants.BETWEEN_61_90;
		}
		else if (xPoint == CSM_Constants.INT_BETWEEN_31_60)
		{
			 dateRangeString = CSM_Constants.BETWEEN_31_60;
		}
		
		else if (xPoint == CSM_Constants.INT_BETWEEN_0_30)
		{
			 dateRangeString = CSM_Constants.BETWEEN_0_30;
		}
		
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
		pageRef.getParameters().put(CSM_Constants.STATUS_PARAM, yPoint);
		pageRef.getParameters().put(CSM_Constants.RANGE_DATE_PARAM, dateRangeString);
		pageRef.getParameters().put(CSM_Constants.USER_PREF_FIELD_VALUE, fieldValue);			
				
		
		if (userWrapper.attObjectType != null) {
			pageRef.getParameters().put(CSM_Constants.USER_PREF_OBJECT_TYPE, userWrapper.attObjectType);
			pageRef.getParameters().put(CSM_Constants.USER_PREF_FIELD_NAME, userWrapper.attrFieldName);
			pageRef.getParameters().put(CSM_Constants.USER_PREF_FIELD_TYPE, userWrapper.attrFieldType);
		}
		/*else if (userWrapper.attObjectType != null && userWrapper.attObjectType.equalsIgnoreCase('Success Plan')) {
			pageRef.getParameters().put(CSM_Constants.STATUS_PARAM, yPoint);
			
			system.debug('Success Plan Object');
			pageRef.getParameters().put(CSM_Constants.USER_PREF_OBJECT_TYPE, userWrapper.attObjectType);
			
			pageRef.getParameters().put(CSM_Constants.USER_SP_ACCT_ARRAY, CSM_Util.setToString(userWrapper.attrSPAccountIdsList));
		}*/		

		pageRef.setRedirect(true);
		return pageRef;
	}
}