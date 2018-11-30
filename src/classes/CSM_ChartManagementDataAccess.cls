public with sharing class CSM_ChartManagementDataAccess {
	
	
	public static List<CSM_Chart_Management__c> getCharts(String chartId) 
	{
		
		List<CSM_Chart_Management__c> tempChartList = new List<CSM_Chart_Management__c>();
		List<String> chartManagementFieldList = new List<String>{CSM_Constants.OBJ_CHART_MGMT_COLOR_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_ADMIN_LIST_DISPLAY, 
			CSM_Constants.OBJ_CHART_MGMT_COLOR_1_VALUE,CSM_Constants.OBJ_CHART_MGMT_COLOR_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_COLOR_2_VALUE, 
			CSM_Constants.OBJ_CHART_MGMT_COLOR_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_COLOR_3_VALUE,CSM_Constants.OBJ_CHART_MGMT_COLOR_RANGE, 
			CSM_Constants.OBJ_CHART_MGMT_COLOR_SORT_RANGE, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_COLOR_FIELDS, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_COLOR_RANGE,
    		CSM_Constants.OBJ_CHART_MGMT_DISPLAY_RANGE, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_1_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_2_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_2_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_3_VALUE, CSM_Constants.OBJ_CHART_MGMT_MODULE_TYPE, CSM_Constants.OBJ_CHART_MGMT_OBJECT_LABEL, 
    		CSM_Constants.OBJ_CHART_MGMT_OBJECT_NAME, CSM_Constants.OBJ_CHART_MGMT_OBJECT_TYPE, CSM_Constants.OBJ_CHART_MGMT_RANGE_1_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_1_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_2_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_2_TO_VALUE,  CSM_Constants.OBJ_CHART_MGMT_RANGE_3_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_3_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_4_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_4_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_4_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_5_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_5_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_5_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_6_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_6_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_6_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_DISPLAY,
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_2_DISPLAY, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_DISPLAY, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_DISPLAY,
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_4_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_TYPE, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_VALUE,
    		CSM_Constants.OBJ_CHART_MGMT_SOQL_QUERY, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_NAME};
    		 
    		List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_CHART_MGMT, 
                CSM_Constants.DML_OPERATION_READ, chartManagementFieldList);
                
        if(noAccessFieldList.isEmpty()) 
        {
        	tempChartList = [select CSM_Color_1_Label__c, CSM_Color_1_Value__c, CSM_Color_2_Label__c, CSM_Admin_List_Display__c,
        					CSM_Color_2_Value__c, CSM_Color_3_Label__c, CSM_Color_3_Value__c, CSM_Color_Range__c, CSM_Color_Sort_Range__c, 
        					CSM_Display_Color_Fields__c, CSM_Display_Color_Range__c, CSM_Display_Range__c, CSM_Field_1_Label__c, 
    						CSM_Field_1_Type__c, CSM_Field_1_Value__c, CSM_Field_2_Label__c, CSM_Field_2_Type__c, CSM_Field_2_Value__c,
    						CSM_Field_2_Display__c, CSM_Field_1_Display__c, CSM_Field_3_Display__c,
    						CSM_Field_3_Label__c, CSM_Field_3_Type__c, CSM_Field_3_Value__c, CSM_Module_Type__c, CSM_Object_Label__c, 
    						CSM_Object_Name__c, CSM_Object_Type__c, CSM_Range_1_From_Value__c, CSM_Range_1_Label__c, CSM_Range_1_To_Value__c, 
    						CSM_Range_2_From_Value__c, CSM_Range_2_Label__c, CSM_Range_2_To_Value__c, CSM_Range_3_From_Value__c, 
    						CSM_Range_3_Label__c, CSM_Range_3_To_Value__c, CSM_Range_4_From_Value__c, CSM_Range_4_Label__c, CSM_Range_4_To_Value__c, 
    						CSM_Range_5_From_Value__c, CSM_Range_5_Label__c, CSM_Range_5_To_Value__c, CSM_Range_6_From_Value__c, 
    						CSM_Range_6_Label__c, CSM_Range_6_To_Value__c, CSM_Soql_Query__c, id, Name, CSM_Display_Name__c, 
    						CSM_Field_4_Display__c, CSM_Field_4_Label__c, CSM_Field_4_Value__c, CSM_Field_4_Type__c
    						From CSM_Chart_Management__c 
    						where id = :chartId
    						limit 1]; 
		}
        else
       	{
        	String[] arguments = new String[] {CSM_Constants.OBJ_CHART_MGMT + ':'+String.valueOf(noAccessFieldList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return tempChartList;
        
   
	}
	
	public static List<CSM_Chart_Management__c> getCharts()
	{
		
		List<CSM_Chart_Management__c> tempChartList = new List<CSM_Chart_Management__c>();
		List<String> chartManagementFieldList = new List<String>{CSM_Constants.OBJ_CHART_MGMT_COLOR_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_ADMIN_LIST_DISPLAY,
			CSM_Constants.OBJ_CHART_MGMT_COLOR_1_VALUE,CSM_Constants.OBJ_CHART_MGMT_COLOR_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_COLOR_2_VALUE, 
			CSM_Constants.OBJ_CHART_MGMT_COLOR_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_COLOR_3_VALUE,CSM_Constants.OBJ_CHART_MGMT_COLOR_RANGE, 
			CSM_Constants.OBJ_CHART_MGMT_COLOR_SORT_RANGE, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_COLOR_FIELDS, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_COLOR_RANGE,
    		CSM_Constants.OBJ_CHART_MGMT_DISPLAY_RANGE, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_1_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_2_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_2_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_3_VALUE, CSM_Constants.OBJ_CHART_MGMT_MODULE_TYPE, CSM_Constants.OBJ_CHART_MGMT_OBJECT_LABEL, 
    		CSM_Constants.OBJ_CHART_MGMT_OBJECT_NAME, CSM_Constants.OBJ_CHART_MGMT_OBJECT_TYPE, CSM_Constants.OBJ_CHART_MGMT_RANGE_1_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_1_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_2_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_2_TO_VALUE,  CSM_Constants.OBJ_CHART_MGMT_RANGE_3_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_3_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_4_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_4_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_4_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_5_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_5_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_5_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_6_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_6_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_6_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_DISPLAY,
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_2_DISPLAY, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_DISPLAY, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_DISPLAY,
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_4_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_TYPE, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_VALUE,
    		CSM_Constants.OBJ_CHART_MGMT_SOQL_QUERY, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_NAME};
    		
    		List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_CHART_MGMT, 
                CSM_Constants.DML_OPERATION_READ, chartManagementFieldList);
                
        if(noAccessFieldList.isEmpty())
        {
        	tempChartList = [select CSM_Color_1_Label__c, CSM_Color_1_Value__c, CSM_Color_2_Label__c, CSM_Admin_List_Display__c,
        					CSM_Color_2_Value__c, CSM_Color_3_Label__c, CSM_Color_3_Value__c, CSM_Color_Range__c, CSM_Color_Sort_Range__c, 
        					CSM_Display_Color_Fields__c, CSM_Display_Color_Range__c, CSM_Display_Range__c, CSM_Field_1_Label__c, 
    						CSM_Field_1_Type__c, CSM_Field_1_Value__c, CSM_Field_2_Label__c, CSM_Field_2_Type__c, CSM_Field_2_Value__c,
    						CSM_Field_2_Display__c, CSM_Field_1_Display__c, CSM_Field_3_Display__c,
    						CSM_Field_3_Label__c, CSM_Field_3_Type__c, CSM_Field_3_Value__c, CSM_Module_Type__c, CSM_Object_Label__c, 
    						CSM_Object_Name__c, CSM_Object_Type__c, CSM_Range_1_From_Value__c, CSM_Range_1_Label__c, CSM_Range_1_To_Value__c, 
    						CSM_Range_2_From_Value__c, CSM_Range_2_Label__c, CSM_Range_2_To_Value__c, CSM_Range_3_From_Value__c, 
    						CSM_Range_3_Label__c, CSM_Range_3_To_Value__c, CSM_Range_4_From_Value__c, CSM_Range_4_Label__c, CSM_Range_4_To_Value__c, 
    						CSM_Range_5_From_Value__c, CSM_Range_5_Label__c, CSM_Range_5_To_Value__c, CSM_Range_6_From_Value__c, 
    						CSM_Range_6_Label__c, CSM_Range_6_To_Value__c, CSM_Soql_Query__c, id, Name, CSM_Display_Name__c, 
    						CSM_Field_4_Display__c, CSM_Field_4_Label__c, CSM_Field_4_Value__c, CSM_Field_4_Type__c
    						From CSM_Chart_Management__c 
    						limit 500]; 
		}
        else
       	{
        	String[] arguments = new String[] {CSM_Constants.OBJ_CHART_MGMT + ':'+String.valueOf(noAccessFieldList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return tempChartList;
        
   
	}
	
	public static List<CSM_Chart_Management__c> getCharts(boolean adminDisplayable)
	{
		
		List<CSM_Chart_Management__c> tempChartList = new List<CSM_Chart_Management__c>();
		List<String> chartManagementFieldList = new List<String>{CSM_Constants.OBJ_CHART_MGMT_COLOR_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_ADMIN_LIST_DISPLAY,
			CSM_Constants.OBJ_CHART_MGMT_COLOR_1_VALUE,CSM_Constants.OBJ_CHART_MGMT_COLOR_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_COLOR_2_VALUE, 
			CSM_Constants.OBJ_CHART_MGMT_COLOR_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_COLOR_3_VALUE,CSM_Constants.OBJ_CHART_MGMT_COLOR_RANGE, 
			CSM_Constants.OBJ_CHART_MGMT_COLOR_SORT_RANGE, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_COLOR_FIELDS, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_COLOR_RANGE,
    		CSM_Constants.OBJ_CHART_MGMT_DISPLAY_RANGE, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_1_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_2_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_2_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_3_VALUE, CSM_Constants.OBJ_CHART_MGMT_MODULE_TYPE, CSM_Constants.OBJ_CHART_MGMT_OBJECT_LABEL, 
    		CSM_Constants.OBJ_CHART_MGMT_OBJECT_NAME, CSM_Constants.OBJ_CHART_MGMT_OBJECT_TYPE, CSM_Constants.OBJ_CHART_MGMT_RANGE_1_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_1_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_2_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_2_TO_VALUE,  CSM_Constants.OBJ_CHART_MGMT_RANGE_3_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_3_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_4_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_4_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_4_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_5_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_5_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_5_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_6_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_6_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_6_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_DISPLAY,
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_2_DISPLAY, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_DISPLAY, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_DISPLAY,
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_4_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_TYPE, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_VALUE,
    		CSM_Constants.OBJ_CHART_MGMT_SOQL_QUERY, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_NAME};
    		
    		List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_CHART_MGMT, 
                CSM_Constants.DML_OPERATION_READ, chartManagementFieldList);
                
        if(noAccessFieldList.isEmpty())
        {
        	tempChartList = [select CSM_Color_1_Label__c, CSM_Color_1_Value__c, CSM_Color_2_Label__c, CSM_Admin_List_Display__c,
        					CSM_Color_2_Value__c, CSM_Color_3_Label__c, CSM_Color_3_Value__c, CSM_Color_Range__c, CSM_Color_Sort_Range__c, 
        					CSM_Display_Color_Fields__c, CSM_Display_Color_Range__c, CSM_Display_Range__c, CSM_Field_1_Label__c, 
    						CSM_Field_1_Type__c, CSM_Field_1_Value__c, CSM_Field_2_Label__c, CSM_Field_2_Type__c, CSM_Field_2_Value__c,
    						CSM_Field_2_Display__c, CSM_Field_1_Display__c, CSM_Field_3_Display__c,
    						CSM_Field_3_Label__c, CSM_Field_3_Type__c, CSM_Field_3_Value__c, CSM_Module_Type__c, CSM_Object_Label__c, 
    						CSM_Object_Name__c, CSM_Object_Type__c, CSM_Range_1_From_Value__c, CSM_Range_1_Label__c, CSM_Range_1_To_Value__c, 
    						CSM_Range_2_From_Value__c, CSM_Range_2_Label__c, CSM_Range_2_To_Value__c, CSM_Range_3_From_Value__c, 
    						CSM_Range_3_Label__c, CSM_Range_3_To_Value__c, CSM_Range_4_From_Value__c, CSM_Range_4_Label__c, CSM_Range_4_To_Value__c, 
    						CSM_Range_5_From_Value__c, CSM_Range_5_Label__c, CSM_Range_5_To_Value__c, CSM_Range_6_From_Value__c, 
    						CSM_Range_6_Label__c, CSM_Range_6_To_Value__c, CSM_Soql_Query__c, id, Name, CSM_Display_Name__c, 
    						CSM_Field_4_Display__c, CSM_Field_4_Label__c, CSM_Field_4_Value__c, CSM_Field_4_Type__c
    						From CSM_Chart_Management__c 
    						where CSM_Admin_List_Display__c = :adminDisplayable
    						limit 500]; 
		}
        else
       	{
        	String[] arguments = new String[] {CSM_Constants.OBJ_CHART_MGMT + ':'+String.valueOf(noAccessFieldList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
        }	
        return tempChartList;
        
   
	}
	
	public static boolean saveCharts(List<CSM_Chart_Management__c> chartList)
	{
		
		boolean isSuccess = true;
		List<String> chartManagementFieldList = new List<String>{CSM_Constants.OBJ_CHART_MGMT_COLOR_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_ADMIN_LIST_DISPLAY,
			CSM_Constants.OBJ_CHART_MGMT_COLOR_1_VALUE,CSM_Constants.OBJ_CHART_MGMT_COLOR_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_COLOR_2_VALUE, 
			CSM_Constants.OBJ_CHART_MGMT_COLOR_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_COLOR_3_VALUE,CSM_Constants.OBJ_CHART_MGMT_COLOR_RANGE, 
			CSM_Constants.OBJ_CHART_MGMT_COLOR_SORT_RANGE, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_COLOR_FIELDS, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_COLOR_RANGE,
    		CSM_Constants.OBJ_CHART_MGMT_DISPLAY_RANGE, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_1_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_2_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_2_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_TYPE, 
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_3_VALUE, CSM_Constants.OBJ_CHART_MGMT_MODULE_TYPE, CSM_Constants.OBJ_CHART_MGMT_OBJECT_LABEL, 
    		CSM_Constants.OBJ_CHART_MGMT_OBJECT_NAME, CSM_Constants.OBJ_CHART_MGMT_OBJECT_TYPE, CSM_Constants.OBJ_CHART_MGMT_RANGE_1_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_1_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_1_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_2_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_2_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_2_TO_VALUE,  CSM_Constants.OBJ_CHART_MGMT_RANGE_3_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_3_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_3_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_4_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_4_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_4_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_5_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_5_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_5_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_RANGE_6_FROM_VALUE, 
    		CSM_Constants.OBJ_CHART_MGMT_RANGE_6_LABEL, CSM_Constants.OBJ_CHART_MGMT_RANGE_6_TO_VALUE, CSM_Constants.OBJ_CHART_MGMT_FIELD_1_DISPLAY,
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_2_DISPLAY, CSM_Constants.OBJ_CHART_MGMT_FIELD_3_DISPLAY, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_DISPLAY,
    		CSM_Constants.OBJ_CHART_MGMT_FIELD_4_LABEL, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_TYPE, CSM_Constants.OBJ_CHART_MGMT_FIELD_4_VALUE,
    		CSM_Constants.OBJ_CHART_MGMT_SOQL_QUERY, CSM_Constants.OBJ_CHART_MGMT_DISPLAY_NAME};
    		
    		List<String> noAccessFieldList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_CHART_MGMT, 
                CSM_Constants.DML_OPERATION_UPSERT, chartManagementFieldList);
                
        if(noAccessFieldList.isEmpty())
        {
        	for(CSM_Chart_Management__c c : chartList)
        	{
        		String queryString = 'select id ';
        		if(c.CSM_Field_1_Display__c)
        		{
        			queryString += ' , ' + c.CSM_Field_1_Value__c;
        		}
        		if(c.CSM_Field_2_Display__c)
        		{
        			queryString += ' , ' + c.CSM_Field_2_Value__c;
        		}
        		if(c.CSM_Field_3_Display__c)
        		{
        			queryString += ' , ' + c.CSM_Field_3_Value__c;
        		}
        		queryString += ' ' + c.CSM_Object_Name__c;
        		c.CSM_SOQL_Query__c = queryString;
        	}
        	upsert chartList;
		}
        else
       	{
       		isSuccess = false;
        	String[] arguments = new String[] {CSM_Constants.OBJ_CHART_MGMT + ':'+String.valueOf(noAccessFieldList)};
    		throw new CSM_AccessController.AccessControlDmlException( String.format(
    		System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments));
        }	
        return isSuccess;
        
   
	}
    

}