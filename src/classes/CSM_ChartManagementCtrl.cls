public with sharing class CSM_ChartManagementCtrl {
	
	public String chartId {get; set;} 
	public String subtitleHeader {get; set;}
	public Boolean hasCSMAccess {get; private set;}
    public Boolean hasRenewAccess {get; private set;}
    public String helpParam {get; set;}
    public String tabCategory {get; set;} 
	public CSM_Chart_Management__c chartManagement {get; set;}
	
	public String selectedObject {get; set;}
	public String selectedField {get; set;}
	
	//private Map<String, Schema.SObjectField> objectFieldMap;
    private Map<String, Set<SelectOption>> objectSelectOptionMap;
    private Set<String> existingFieldSet;
    
    private Map<String,String> field1TypeMap;
    private Map<String,String> field2TypeMap;
    private Map<String,String> field3TypeMap;
    
    private List<SelectOption> field1Values;
    private List<SelectOption> field2Values;
    private List<SelectOption> field3Values;
    private String originalObject;
    
	public CSM_ChartManagementCtrl() {
		subtitleHeader = '';
		//objectFieldMap = new Map<String, Schema.SObjectField>();
		//existingFieldSet = new Set<String>();
    	objectSelectOptionMap = new Map<String, Set<SelectOption>>();
    	
    	field1TypeMap = new Map<String,String>();
    	field2TypeMap = new Map<String,String>();
    	field3TypeMap = new Map<String,String>();
    	field1Values = new List<SelectOption>();
    	field2Values = new List<SelectOption>();
    	field3Values = new List<SelectOption>();
    	
		chartId = ApexPages.currentPage().getParameters().get('id'); 
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		getChart();
	}
	
	public void getChart() {
		chartManagement = new CSM_Chart_Management__c(); 
		
		if(chartId != null)
		{
			List<CSM_Chart_Management__c> chartList = CSM_ChartManagementDataAccess.getCharts(chartId);
			if(!chartList.isEmpty())
			{
				chartManagement = chartList[0];
				subTitleHeader = chartManagement.Name;
				originalObject = chartManagement.CSM_Object_Name__c;
				if(!String.isBlank(chartManagement.CSM_Field_1_Type__c))
				{
					List<String> tmpList1 = chartManagement.CSM_Field_1_Type__c.split(';');
					for (String s : tmpList1)
					{
						field1TypeMap.put(s,s);
					}	
				}
				if(!String.isBlank(chartManagement.CSM_Field_2_Type__c))
				{
					List<String> tmpList2 = chartManagement.CSM_Field_2_Type__c.split(';');
					for (String s : tmpList2)
					{
						field2TypeMap.put(s,s);
					}	
				}
				if(!String.isBlank(chartManagement.CSM_Field_3_Type__c))
				{
					List<String> tmpList3 = chartManagement.CSM_Field_3_Type__c.split(';');
					for (String s : tmpList3)
					{
						field3TypeMap.put(s,s);
					}	
				}
				
				
				
				
			} 	
		}
	}
	
	
	/**
	* @description used to populate Object select list
	* @return list of objects from the custom setting 
	*/
    public List<SelectOption> getObjectList()
    {
        try
        {   
            List<SelectOption> objectList = new List<SelectOption>();           
            objectList.addAll(buildObjectList(ChartManagement.CSM_Object_Type__c));
            buildObjectFieldList();
            return objectList;
        }
        catch (Exception ex)
        {            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
             return null;
        }
    }
    
     /**
	* @description used to populate Field select list
	*/
    public void buildObjectFieldList()
    {
        try
        {   field1Values = new List<SelectOption>();
    		field2Values = new List<SelectOption>();
    		field3Values = new List<SelectOption>();
        	String key1 = chartManagement.CSM_Object_Name__c +  CSM_Constants.FIELD1;
        	String key2 = chartManagement.CSM_Object_Name__c +  CSM_Constants.FIELD2; 
        	String key3 = chartManagement.CSM_Object_Name__c +  CSM_Constants.FIELD3; 
            if (!String.isBlank(chartManagement.CSM_Object_Name__c))
            {   
            	//Resets the values
            	boolean resetValues = false;
            	if(ChartManagement.CSM_Object_Name__c != originalObject)
            	{
            		resetValues = true;
            		originalObject = ChartManagement.CSM_Object_Name__c;
            	}
                if(ChartManagement.CSM_Field_1_Display__c)
                {
                	system.debug('key1 $$ ' + key1);
	                if (objectSelectOptionMap.containsKey(key1))
	                {
	                	field1Values = new List<SelectOption>(objectSelectOptionMap.get(key1));                	                 
	                }
	                else 
	                {   
	                	field1Values = buildFieldList(ChartManagement.CSM_Object_Name__c,  CSM_Constants.FIELD1, key1);     
	                }
	                CSM_Util.sortSelectOptionByLabel(field1Values);
	                if(resetvalues)
	                {
	                	if(!field1Values.isEmpty())
	                		ChartManagement.CSM_Field_1_Value__c = field1Values[0].getValue();
	                }
                }
                if(ChartManagement.CSM_Field_2_Display__c)
                {
	                if (objectSelectOptionMap.containsKey(key2))
	                {
	                	field2Values = new List<SelectOption>(objectSelectOptionMap.get(key2));                	                 
	                }
	                else 
	                {   
	                	field2Values = buildFieldList(ChartManagement.CSM_Object_Name__c,  CSM_Constants.FIELD2, key2);     
	                }
	                CSM_Util.sortSelectOptionByLabel(field2Values);
	                if(resetvalues)
	                {
	                	if(!field2Values.isEmpty())
	                		ChartManagement.CSM_Field_2_Value__c = field2Values[0].getValue();
	                }
                }
                if(ChartManagement.CSM_Field_3_Display__c)
                {
	                if (objectSelectOptionMap.containsKey(key3))
	                {
	                	field3Values = new List<SelectOption>(objectSelectOptionMap.get(key3));                	                 
	                }
	                else 
	                {   
	                	field3Values = buildFieldList(ChartManagement.CSM_Object_Name__c,  CSM_Constants.FIELD3, key3);     
	                }
	                CSM_Util.sortSelectOptionByLabel(field3Values);
	                if(resetvalues)
	                {
	                	if(!field3Values.isEmpty())
	                		ChartManagement.CSM_Field_3_Value__c = field3Values[0].getValue();
	                }
	                
                }
                
            } 
        }
        catch (Exception ex)
        {            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }
    }
    
    private List<SelectOption> buildFieldList(String objectName, String fieldName, String keyString)
    {
    	system.debug('build field list $$ ' + fieldName + ' ' + objectName);
    	List<SelectOption> soFieldList = new List<SelectOption>();
    	Set<SelectOption> selectOptionSet = new Set<SelectOption>();
        List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(objectName);
        for( Schema.SObjectField tmpfield :fieldList)
        {   
        	if (!String.valueOf(tmpField).toLowerCase().contains(CSM_Constants.IS_HIGH_PRIORITY) && 
							!String.valueOf(tmpField).toLowerCase().contains(CSM_Constants.CONTRACT_ID))
			{
	        	DisplayType fieldDisplayType =  tmpfield.getDescribe().getType();
	        	if(fieldName == CSM_Constants.FIELD1)
	        	{
	        		system.debug('in field 1 $$ ' + String.valueOf(fieldDisplayType)  + ' ' + tmpField);
		            if (field1TypeMap.containsKey(String.valueOf(fieldDisplayType)))
		            {        
		            	system.debug('met criteria $$ ');
		                selectOptionSet.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
		            }
	        	}
	        	else if (fieldName ==  CSM_Constants.FIELD2)
	        	{
	        		if (field2TypeMap.containsKey(String.valueOf(fieldDisplayType)))
		            {        
		                selectOptionSet.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
		            }
	        	}
	        	else if (fieldName ==  CSM_Constants.FIELD3)
	        	{
	        		if (field3TypeMap.containsKey(String.valueOf(fieldDisplayType)))
		            {        
		                selectOptionSet.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
		            }
	        	}
			}  
        }
        objectSelectOptionMap.put(keyString, selectOptionSet);
        soFieldList.addAll(selectOptionSet);
        return soFieldList;    
    }
    
    public List<SelectOption> getField1Values() {
    	return field1Values;
    }
    public List<SelectOption> getField2Values() {
    	return field2Values;
    }
    public List<SelectOption> getField3Values() {
    	return field3Values;
    }
    
   
    
    public List<SelectOption> buildObjectList(String objString)
    {
    	List<SelectOption> objectList = new List<SelectOption>();
    	List<String> values = new List<String>();
    	values = objString.split(';');
		//objectList.add(new SelectOption('', Label.CSM_LBL_PLEASESELECT));
        if (values!=null && !values.isEmpty()){
			for (String objectName: values) {
				
					if (objectName.indexOf('=')>-1){
						String[] nameValuePair = objectName.split('=');
						if(Type.forName(nameValuePair[0]) != null) {
							if (nameValuePair.size()>1){
								objectList.add(new SelectOption(nameValuePair[0], nameValuePair[1]));
							} else {
								objectList.add(new SelectOption(nameValuePair[0], nameValuePair[0]));
							}
						}
						
					} else {
						if(Type.forName(objectName) != null) {
	            			objectList.add(new SelectOption(objectName, objectName));
						}
					}
				
	        }           
        }
    	return objectList;
    }  
    
    public PageReference cancelButton() {
    	PageReference pageRef = Page.CSM_ChartManagementList;
    	pageRef.setRedirect(true);
    	return pageRef;
    } 
    
    public PageReference saveButton() {
    	try {
    		boolean isSave = false;
    		List<CSM_Chart_Management__c> cMgmt = new List<CSM_Chart_Management__c>();
    		cMgmt.add(ChartManagement);
    		isSave = CSM_ChartManagementDataAccess.saveCharts(cMgmt);
    		if(isSave)
    		{
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,Label.CSM_MSG_CHART_SAVE));
    		}
    		
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,ex.getMessage()));
    	}
    	
    	return null;
    }
    

}