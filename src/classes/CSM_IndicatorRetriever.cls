public with sharing class CSM_IndicatorRetriever {
	
	
	private List<CSM_Account_Plan_Template_Indicator__c> aptIndicators;
	private Map<Id, CSM_Account_Plan_Template_Indicator__c> aptIndicatorMap;
	public List<CSM_IndicatiorThumbnailWrapper> indicatorWrapperList;
	private Map<String, Set<String>> objectFieldMap;
	private Map<String, Set<String>> objectFieldToIndMap;
	private Map<Id, CSM_IndicatiorThumbnailWrapper> thumbnailMap;
	private Map<String, Id> objectFieldIndMap;
	private CSM_Admin__c adminCustomSetting;
	private Map<String, String> criteriaTypeColorMap;
	private Map<String, String> criteriaIconColorMap;
	private Map<Decimal, Id> orderIdMap;
	private Map<Decimal, Decimal> nextIntegerMap;
	private Map<String, String> criteriaStyleMap;
	private String accountPlanTemplateId;	
	private Map<String,String> locale_map;
	private String user_locale;
	/** 
	 * @description constructor
	 */
	public CSM_IndicatorRetriever()
	{
		objectFieldMap = new Map<String, Set<String>>();
		thumbnailMap = new Map<Id, CSM_IndicatiorThumbnailWrapper>();
		objectFieldIndMap = new Map<String, Id>();
		adminCustomSetting = CSM_AdminDataAccess.getCSMAdminInstance();
		aptIndicatorMap = new Map<Id, CSM_Account_Plan_Template_Indicator__c>();
		locale_map = new Map<String,String>();
		locale_map = CSM_Util.getLocaleDateMap();
		user_locale = UserInfo.getLocale();
		//Map<String, String> locale_map = CSM_Util.getLocaleDateMap();
		//String user_locale = UserInfo.getLocale();
		criteriaTypeColorMap = new Map<String, String>();
		criteriaTypeColorMap.put(CSM_Constants.FAIL, adminCustomSetting.CSM_FailCriteriaColor__c);
		criteriaTypeColorMap.put(CSM_Constants.MEET, adminCustomSetting.CSM_MeetCriteriaColor__c);
		criteriaTypeColorMap.put(CSM_Constants.SUCCESS, adminCustomSetting.CSM_SuccessCriteriaColor__c);
		
		criteriaIconColorMap = new Map<String, String>();
		criteriaIconColorMap.put(CSM_Constants.FAIL, 'iconIndicator-arrows-remove');
		criteriaIconColorMap.put(CSM_Constants.MEET, 'iconIndicator-arrows-check');
		criteriaIconColorMap.put(CSM_Constants.SUCCESS, 'iconIndicator-arrows-check');
		
		criteriaStyleMap = new Map<String, String>();
		criteriaStyleMap.put(CSM_Constants.FAIL, CSM_Constants.CSS_FAIL);
		criteriaStyleMap.put(CSM_Constants.MEET, CSM_Constants.CSS_PASS);
		criteriaStyleMap.put(CSM_Constants.SUCCESS, CSM_Constants.CSS_PASS);
	}
	
	/** 
	 * @param account template id
	 * @param account id
	 * @returnlist of Indicator Thumbnail Wrapper objects
	 */
	public List<CSM_IndicatiorThumbnailWrapper> getIndicatorWrapperList(String acctPlanTemplateId, String accountId)
	{
		accountPlanTemplateId = acctPlanTemplateId;
		orderIdMap = new Map<Decimal, Id>();
		nextIntegerMap = new Map<Decimal, Decimal>();
		indicatorWrapperList = new List<CSM_IndicatiorThumbnailWrapper>();
		try
		{
			aptIndicators = CSM_AcctPlanTemplateIndicatorDataAccess.accountPlanTemplateIndicators(acctPlanTemplateId);
			
			if (aptIndicators != null && !aptIndicators.isEmpty())
			{
				objectFieldToIndMap = new Map<String, Set<String>>();
				for (CSM_Account_Plan_Template_Indicator__c ind: aptIndicators)	
				{
					if (ind.CSM_IsActive__c)
					{					
						updateMaps(ind);
					}
				}	
				updateWhenMapsComplete(accountId);
				
			}	
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return indicatorWrapperList;
	}
	
	/** 
	 * @param accounot plan template indicator object
	 */
	private void updateMaps(CSM_Account_Plan_Template_Indicator__c ind)
    {   
    	
	    //update object Map
	    Set<String> fieldsForQuery = new Set<String>();
		if (objectFieldMap.containsKey(ind.CSM_Indicator__r.CSM_Object_Name__c))
		{
			fieldsForQuery = objectFieldMap.get(ind.CSM_Indicator__r.CSM_Object_Name__c);
		}
		
		fieldsForQuery.add(ind.CSM_Indicator__r.CSM_Object_Field_Name__c);
		objectFieldMap.put(ind.CSM_Indicator__r.CSM_Object_Name__c, fieldsForQuery);
		
		//update wrapper Map
		CSM_IndicatiorThumbnailWrapper wrapper = new CSM_IndicatiorThumbnailWrapper(ind.CSM_Indicator__r.CSM_Indicator_Display_Name__c);
	    thumbnailMap.put(ind.Id, wrapper);
	    
	    //update Object Field Indicator Map
	    objectFieldIndMap.put((ind.CSM_Indicator__r.CSM_Object_Name__c + ind.CSM_Indicator__r.CSM_Object_Field_Name__c+ind.CSM_Order__c), ind.Id);
	    Set<String> indIds = new Set<String>();
	    if (objectFieldToIndMap.containsKey(ind.CSM_Indicator__r.CSM_Object_Name__c + ind.CSM_Indicator__r.CSM_Object_Field_Name__c)) {
	    	indIds = objectFieldToIndMap.get(ind.CSM_Indicator__r.CSM_Object_Name__c + ind.CSM_Indicator__r.CSM_Object_Field_Name__c);
	    } 
	    indIds.add(ind.Id);
		objectFieldToIndMap.put(ind.CSM_Indicator__r.CSM_Object_Name__c + ind.CSM_Indicator__r.CSM_Object_Field_Name__c, indIds);
	    
		aptIndicatorMap.put(ind.Id, ind);
	    if (orderIdMap.containsKey(ind.CSM_Order__c))
	    {
	    	Decimal valueToUse = 0.1;
	    	if (nextIntegerMap.containsKey(ind.CSM_Order__c))
	    	{
	    		valueToUse = nextIntegerMap.get(ind.CSM_Order__c);	    		
	    	}
	    	nextIntegerMap.put(ind.CSM_Order__c, valueToUse + 0.1);
	    	orderIdMap.put(ind.CSM_Order__c + valueToUse, ind.Id);
	    }
	    else 
	    {	
	        orderIdMap.put(ind.CSM_Order__c, ind.Id);
	    }    
    }
    
    /** 
	 * @param account id
	 */
    private void updateWhenMapsComplete(String accountId) 
    {
    	String recordCurrencyCode = '';
    	try
    	{
    		for (String obj : objectFieldMap.keySet()){
	    		if (objectFieldMap.containsKey(obj)) {
					String acctFieldName;
					System.debug('obj - '+obj);
					System.debug('CSM_Constants.OBJ_SA_SACF - '+CSM_Constants.OBJ_SA_SACF);
    				System.debug('CSM_Constants.OBJ_SA_SREV_CUSTOMER - '+CSM_Constants.OBJ_SA_SREV_CUSTOMER);
    				if (obj != CSM_Constants.OBJ_TYPE_ACCOUNT && obj != CSM_Constants.OBJ_TYPE_OPPORTUNITY && obj != CSM_Constants.OBJ_SA_SACF  
    					&& obj != CSM_Constants.OBJ_SA_SREV_CUSTOMER){
	    				Map<String,DescribeFieldResult> fldMap = CSM_AccessController.getTypeFromFieldnameObjectname(obj, CSM_Constants.OBJ_TYPE_ACCOUNT, CSM_Constants.TYPE_REFERENCE);
	    				if (fldMap!=null && !fldMap.isEmpty()){
	    					for (String acctField : fldMap.keySet()){
	    						acctFieldName = acctField;
	    						break;
	    					}
	    				}
	    			} else {
	    				acctFieldName = (obj == CSM_Constants.OBJ_TYPE_ACCOUNT?CSM_Constants.ID_PARAM:obj == CSM_Constants.OBJ_TYPE_OPPORTUNITY?CSM_Constants.OBJ_T_ACCOUNTID:obj == CSM_Constants.OBJ_SA_SACF?CSM_Constants.OBJ_SA_SACF_ACCOUNT:obj == CSM_Constants.OBJ_SA_SREV_CUSTOMER?CSM_Constants.OBJ_SA_SREV_CUSTOMER_REF_ID:null);
	    			}
	    			if (acctFieldName!=null){
	    				System.debug('acctFieldName - '+acctFieldName);
		    			List<SObject> objList = CSM_IndicatorDataAccess.dynamicQueryForCustomObject(accountId, acctFieldName, obj, objectFieldMap.get(obj));
						if (objList != null && !objList.isEmpty())
						{
							SObject thisObj = objList[0];
						    if(UserInfo.isMultiCurrencyOrganization() && CSM_Util.returnIfCurrencyISOCodeExists(obj))	{
								recordCurrencyCode = (String)thisObj.get(CSM_Constants.CURRENCY_ISO_CD);
						    }
							
							for (String fieldName: objectFieldMap.get(obj))
							{
								Object o = thisObj.get(fieldName);
								if (objectFieldToIndMap.containsKey(obj+fieldName)){
									Set<String> indicatorPlanIds = objectFieldToIndMap.get(obj+fieldName);
									for (String indicatorPlanId : indicatorPlanIds){
										CSM_IndicatiorThumbnailWrapper wrapper = thumbnailMap.get(indicatorPlanId);
								
										setWrapperInfo(indicatorPlanId, o, wrapper,recordCurrencyCode);
									
										thumbnailMap.put(indicatorPlanId, wrapper);	
									}
								}
								
							}
						} 
	    			}
    			}
	        }
	    		
			List<Decimal> sortedList = new List<Decimal>();
			sortedList.addAll(orderIdMap.keySet());
			sortedList.sort();
			
			for (Decimal sortNumber : sortedList)
			{
				Id indId = orderIdMap.get(sortNumber);
				CSM_IndicatiorThumbnailWrapper wrapper = thumbnailMap.get(indId);					
				indicatorWrapperList.add(wrapper);
			}
			if(indicatorWrapperList.size() >0){
				CSM_IndicatiorThumbnailWrapper lastWrapper = indicatorWrapperList.remove(indicatorWrapperList.size() - 1);			
				lastWrapper.borderStyle = '';
				indicatorWrapperList.add(lastWrapper);	
			}
    	}
    	catch(Exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
    	}	
    } 

     /** Added multi-currency related code - 6th May 2015
	 * @param indicator plan id
	 * @param field data
	 * @param thumbnail wrapper
	 */
    private void setWrapperInfo(Id indicatorPlanId, Object fieldData, CSM_IndicatiorThumbnailWrapper wrapper, String recordCurrencyCode) 
    {
    	wrapper.indicatorData = fieldData;
    	if (wrapper.indicatorData != null)
    	{ 	
    		System.debug('indicatorPlanId - '+indicatorPlanId);
	    	CSM_Account_Plan_Template_Indicator__c aptInd = aptIndicatorMap.get(indicatorPlanId);
			String fieldType = aptInd.CSM_Indicator__r.CSM_Object_Field_Type__c;
			wrapper.dataType = fieldType;
			if (fieldType == CSM_Constants.TYPE_STRING 
			        || fieldType == CSM_Constants.TYPE_PICKLIST)
			{
				if (aptInd.CSM_Criteria_1_From_Value__c == fieldData)
				{
					wrapper.indicatorBackgroundColor =  criteriaTypeColorMap.get(aptInd.CSM_Criteria_1_Type__c);
					wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_1_Type__c);
					wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_1_Type__c);
				}
				else if (aptInd.CSM_Criteria_2_From_Value__c == fieldData)
				{
					wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_2_Type__c);
					wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_2_Type__c);
					wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_2_Type__c);
				}
				else if (aptInd.CSM_Criteria_3_From_Value__c == fieldData)
				{
					wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_3_Type__c);
					wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_3_Type__c);
					wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_3_Type__c);
				}
			}
			else if (fieldType == CSM_Constants.TYPE_INTEGER)
			{
				Integer integerData = Integer.valueOf(fieldData);
				wrapper.indicatorInteger = integerData;
				
				if (aptInd.CSM_Criteria_1_From_Value__c != null)
				{
					
					Integer integer1From = Integer.valueOf(aptInd.CSM_Criteria_1_From_Value__c);
					if (aptInd.CSM_Criteria_1_To_Value__c == null)
					{
						if (integerData == integer1From)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_1_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_1_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_1_Type__c);
							
						}
					}
					else
					{
						Integer integer1To = Integer.valueOf(aptInd.CSM_Criteria_1_To_Value__c);
						if (integerData >= integer1From && integerData <= integer1To)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_1_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_1_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_1_Type__c);
						}
					}
				}
				if (aptInd.CSM_Criteria_2_From_Value__c != null)
				{
					Integer integer2From = Integer.valueOf(aptInd.CSM_Criteria_2_From_Value__c);
					if (aptInd.CSM_Criteria_2_To_Value__c == null)
					{
						if (integerData == integer2From)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_2_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_2_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_2_Type__c);
						}
					}
					else
					{
						Integer integer2To = Integer.valueOf(aptInd.CSM_Criteria_2_To_Value__c);
						if (integerData >= integer2From && integerData <= integer2To)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_2_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_2_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_2_Type__c);
						}
					}
				}
				if (aptInd.CSM_Criteria_3_From_Value__c != null)
				{
					Integer integer3From = Integer.valueOf(aptInd.CSM_Criteria_3_From_Value__c);
					if (aptInd.CSM_Criteria_3_To_Value__c == null)
					{
						if (integerData == integer3From)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_3_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_3_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_3_Type__c);
						}
					}
					else
					{
						Integer integer3To = Integer.valueOf(aptInd.CSM_Criteria_3_To_Value__c);
						if (integerData >= integer3From && integerData <= integer3To)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_3_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_3_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_3_Type__c);
						}
					}
				}
			}
			else if (fieldType == CSM_Constants.TYPE_DOUBLE 
			        || fieldType == CSM_Constants.TYPE_PERCENT
			        || fieldType == CSM_Constants.TYPE_CURRENCY)
			{
				
			    String indicatorCurrency;
			    Double DoubleData;
			    Double indicatorData = Double.valueOf(fieldData);
			    if(fieldType == CSM_Constants.TYPE_CURRENCY && UserInfo.isMultiCurrencyOrganization())	{
			    	indicatorCurrency = CSM_AccountPlanTemplateDataAccess.getIndicatorCurrencyCode(accountPlanTemplateId);
					DoubleData = Double.valueOf(fieldData) * (1/CSM_Util.getExchangeRateToCorpCurrency(recordCurrencyCode)) * CSM_Util.getExchangeRateToCorpCurrency(indicatorCurrency);		
			    }else{
			    
					DoubleData = Double.valueOf(fieldData);			    
			    }
				wrapper.indicatorDouble = indicatorData;
				
								
				if (aptInd.CSM_Criteria_1_From_Value__c != null)
				{
					Double Double1From = Double.valueOf(aptInd.CSM_Criteria_1_From_Value__c);

					if (aptInd.CSM_Criteria_1_To_Value__c == null)
					{
						if (DoubleData == Double1From)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_1_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_1_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_1_Type__c);
						}
					}
					else
					{
						Double Double1To = Double.valueOf(aptInd.CSM_Criteria_1_To_Value__c);
						if (DoubleData >= Double1From && DoubleData <= Double1To)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_1_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_1_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_1_Type__c);
						}
					}
				}
				if (aptInd.CSM_Criteria_2_From_Value__c != null)
				{
					Double Double2From = Double.valueOf(aptInd.CSM_Criteria_2_From_Value__c);

					if (aptInd.CSM_Criteria_2_To_Value__c == null)
					{
						if (DoubleData == Double2From)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_2_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_2_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_2_Type__c);
						}
					}
					else
					{
						Double Double2To = Double.valueOf(aptInd.CSM_Criteria_2_To_Value__c);
						
						if (DoubleData >= Double2From && DoubleData <= Double2To)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_2_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_2_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_2_Type__c);
						}
					}
				}
				if (aptInd.CSM_Criteria_3_From_Value__c != null)
				{
					Double Double3From = Double.valueOf(aptInd.CSM_Criteria_3_From_Value__c);
					
					if (aptInd.CSM_Criteria_3_To_Value__c == null)
					{
						if (DoubleData == Double3From)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_3_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_3_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_3_Type__c);
						}
					}
					else
					{
						Double Double3To = Double.valueOf(aptInd.CSM_Criteria_3_To_Value__c);

						if (DoubleData >= Double3From && DoubleData <= Double3To)
						{
							wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_3_Type__c);
							wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_3_Type__c);
							wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_3_Type__c);
						}
					}
				}
			}
			else if (fieldType == CSM_Constants.TYPE_DATE)
			{
		        Date dateData = Date.valueOf(fieldData);
				//Datetime currentDateVal = Datetime.valueOf(fieldData);
				//wrapper.indicatorData = CSM_Util.getLocaleFormattedDateValue(user_locale,datedata , locale_map);
			      wrapper.indicatorData = dateData.format();
			
				if (dateData >= aptInd.CSM_Criteria_1_From_Date__c && dateData <= aptInd.CSM_Criteria_1_To_Date__c)
				{
					wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_1_Type__c);
					wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_1_Type__c);
					wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_1_Type__c);
				}
				else if (dateData >= aptInd.CSM_Criteria_2_From_Date__c && dateData <= aptInd.CSM_Criteria_2_To_Date__c)
				{
					wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_2_Type__c);
					wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_2_Type__c);
					wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_2_Type__c);
				}
				else if (dateData >= aptInd.CSM_Criteria_3_From_Date__c && dateData <= aptInd.CSM_Criteria_3_To_Date__c)
				{
					wrapper.indicatorBackgroundColor = criteriaTypeColorMap.get(aptInd.CSM_Criteria_3_Type__c);
					wrapper.indicatorImg = criteriaIconColorMap.get(aptInd.CSM_Criteria_3_Type__c);
					wrapper.styleClassInd = criteriaStyleMap.get(aptInd.CSM_Criteria_3_Type__c);
				}
				
			}
			if (fieldType == CSM_Constants.TYPE_CURRENCY)
			{			
				if(recordCurrencyCode == ''){
					wrapper.currencyCode = UserInfo.getDefaultCurrency();
					wrapper.currencyCodeSymbol = CSM_Util.convertCurrencyNameToSymbol(wrapper.currencyCode);
				}else{
					wrapper.currencyCode = recordCurrencyCode;
					wrapper.currencyCodeSymbol = recordCurrencyCode;
				}
	
			}
    	} 
    } 
}