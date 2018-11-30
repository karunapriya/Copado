/**
 * Created Date		: May 10, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Bhagyashri					User Story				May 10, 2018			1.1					@description
 *
 */
@isTest
private class REN_IBExportODataControllerTest {

    private static REN_QueryBuilderWrapper.ColumnFilter getFilter(String filterValue, String fieldDataType, String operator){
    	REN_QueryBuilderWrapper.ColumnFilter filter = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
    	filter.fieldApiName = 'CloseDate';
        filter.filterValue = filterValue;
        filter.fieldDataType = fieldDataType;
        filter.operator = operator;
        return filter;	
    }
    static testMethod void IBExportODatactrlTest() {
        String logicString = '';
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'IB Export');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filter = getFilter('"Test","Test1"','String','=');
        inputWrapper.columnFilterList.add(filter);
        REN_QueryBuilderWrapper.ColumnFilter filter1 = getFilter('"Test","Test1"','String','!=');
        inputWrapper.columnFilterList.add(filter1);
        REN_QueryBuilderWrapper.ColumnFilter filter2 = getFilter('"Test","Test1"','REFERENCE','=');
        inputWrapper.columnFilterList.add(filter2);
        REN_QueryBuilderWrapper.ColumnFilter filter3 = getFilter('"Test","Test1"','REFERENCE','!=');
        inputWrapper.columnFilterList.add(filter3);
        REN_QueryBuilderWrapper.ColumnFilter filter4 = getFilter('"Test","Test1"','String','Starts With');
        inputWrapper.columnFilterList.add(filter4);
        REN_QueryBuilderWrapper.ColumnFilter filter5 = getFilter(null,'String','Not In');
        inputWrapper.columnFilterList.add(filter5);
        REN_QueryBuilderWrapper.ColumnFilter filter6 = getFilter(null,'String','Exists');
        inputWrapper.columnFilterList.add(filter6);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList, logicString, false, '');
        Map<Integer, String> lineFilterMap = new Map<Integer, String>();
        lineFilterMap.put(1,'Test');
        REN_IBExportODataController.getWhereClauseString(lineFilterMap, inputWrapper.filterLogic);
        System.assertEquals(lineFilterMap.size(),1);
    }
    static testMethod void IBExportODatactrlNegTest() {
        String logicString = '';
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'IB Export');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filter = getFilter('"','String',null);
        inputWrapper.columnFilterList.add(filter);
        REN_QueryBuilderWrapper.ColumnFilter filter1 = getFilter(',','String',null);
        inputWrapper.columnFilterList.add(filter1);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList, logicString, false, '');
        Map<Integer, String> lineFilterMap = new Map<Integer, String>();
        lineFilterMap.put(1,'Test');
        REN_IBExportODataController.getWhereClauseString(lineFilterMap, inputWrapper.filterLogic);
        System.assertEquals(lineFilterMap.size(),1);
    }
    static testMethod void SpecificDateTest() {
        String logicString = '';
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'Custom Search');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();        
        REN_QueryBuilderWrapper.ColumnFilter filter = getFilter(String.valueOf(DateTime.now()),'DATE',null);
        inputWrapper.columnFilterList.add(filter);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter.relatedObject = new REN_Line_Criteria__c();
        system.assert(inputWrapper.columnFilterList != null);     
        REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList, logicString, false, '');
    }
    static testMethod void LiteralTest() {
        String logicString = '';
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'Custom Search');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();        
        REN_QueryBuilderWrapper.ColumnFilter filter = getFilter(null,'DATE',null);
        filter.fieldApiName = 'CloseDate';
        filter.filterValue =null;
        filter.fieldDataType = 'DATE';
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter.relatedObject = new REN_Line_Criteria__c();
        filter.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filter.relatedObject.put('RLM_Date_Literal_String__c','TODAY');
        inputWrapper.columnFilterList.add(filter);        
        REN_QueryBuilderWrapper.ColumnFilter filterYesterday = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filterYesterday.relatedObject = new REN_Line_Criteria__c();
        filterYesterday.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filterYesterday.relatedObject.put('RLM_Date_Literal_String__c','YESTERDAY');
        inputWrapper.columnFilterList.add(filterYesterday);       
         REN_QueryBuilderWrapper.ColumnFilter filterTomorrow = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filterTomorrow.relatedObject = new REN_Line_Criteria__c();
        filterTomorrow.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filterTomorrow.relatedObject.put('RLM_Date_Literal_String__c','TOMORROW');
        inputWrapper.columnFilterList.add(filterTomorrow);  
        system.assert(inputWrapper.columnFilterList != null);     
        REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList, logicString, true, '');
    }
    
    static testMethod void LiteralTest1() {
        String logicString = '';
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'Custom Search');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();       
        REN_QueryBuilderWrapper.ColumnFilter filter = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter.relatedObject = new REN_Line_Criteria__c();
        filter.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filter.relatedObject.put('RLM_Date_Literal_Number__c',2);
        filter.relatedObject.put('RLM_Date_Literal_String__c','N_DAYS_AGO');
        inputWrapper.columnFilterList.add(filter);       
        REN_QueryBuilderWrapper.ColumnFilter filter1 = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter1.relatedObject = new REN_Line_Criteria__c();
        filter1.relatedObject.put('RLM_Date_Literal_String__c','LAST_90_DAYS');
        inputWrapper.columnFilterList.add(filter1);        
         REN_QueryBuilderWrapper.ColumnFilter filter2 = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter2.relatedObject = new REN_Line_Criteria__c();
        filter2.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filter2.relatedObject.put('RLM_Date_Literal_String__c','NEXT_90_DAYS');
        inputWrapper.columnFilterList.add(filter2); 
        system.assert(inputWrapper.columnFilterList != null);            
        REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList, logicString, true, '');
    }
    static testMethod void LiteralTest2() {
        String logicString = '';
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'Custom Search');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();        
        REN_QueryBuilderWrapper.ColumnFilter filter = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter.relatedObject = new REN_Line_Criteria__c();
        filter.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filter.relatedObject.put('RLM_Date_Literal_Number__c',2);
        filter.relatedObject.put('RLM_Date_Literal_String__c','LAST_N_DAYS');
        inputWrapper.columnFilterList.add(filter);        
        REN_QueryBuilderWrapper.ColumnFilter filter1 = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter1.relatedObject = new REN_Line_Criteria__c();
        filter1.relatedObject.put('RLM_Date_Literal_Number__c',2);
        filter1.relatedObject.put('RLM_Date_Literal_String__c','NEXT_N_DAYS');
        inputWrapper.columnFilterList.add(filter1);        
         REN_QueryBuilderWrapper.ColumnFilter filter2 = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter2.relatedObject = new REN_Line_Criteria__c();
        filter2.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filter2.relatedObject.put('RLM_Date_Literal_Number__c',2);
        filter2.relatedObject.put('RLM_Date_Literal_String__c','N_YEARS_AGO');
        inputWrapper.columnFilterList.add(filter2);
        system.assert(inputWrapper.columnFilterList != null);       
        REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList, logicString, true, '');
    }
    static testmethod void testLiteral3(){
        String logicString = '';
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'Custom Search');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filterQuarter = getFilter(null,'DATE','<');
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filterQuarter.relatedObject = new REN_Line_Criteria__c();
        filterQuarter.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filterQuarter.relatedObject.put('RLM_Date_Literal_String__c','LAST_QUARTER');
        filterQuarter.relatedObject.put('RLM_Date_Literal_Number__c',2);
        inputWrapper.columnFilterList.add(filterQuarter);
        REN_QueryBuilderWrapper.ColumnFilter filterFiscalYear = getFilter(null,'DATE','>');
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filterFiscalYear.relatedObject = new REN_Line_Criteria__c();
        filterFiscalYear.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filterFiscalYear.relatedObject.put('RLM_Date_Literal_String__c','LAST_FISCAL_YEAR');
        inputWrapper.columnFilterList.add(filterFiscalYear);
        REN_QueryBuilderWrapper.ColumnFilter filterFiscalQuarter = getFilter(null,'DATE','>');
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filterFiscalQuarter.relatedObject = new REN_Line_Criteria__c();
        filterFiscalQuarter.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filterFiscalQuarter.relatedObject.put('RLM_Date_Literal_String__c','LAST_N_FISCAL_QUARTERS');
        filterQuarter.relatedObject.put('RLM_Date_Literal_Number__c',2);
        inputWrapper.columnFilterList.add(filterFiscalQuarter);
        system.assert(inputWrapper.columnFilterList != null);
        REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList, logicString, true, '');
    }
    static testmethod void testLiteral4(){
        String logicString = '';
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'Custom Search');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filterMonth = getFilter(null,'DATE','=');
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filterMonth.relatedObject = new REN_Line_Criteria__c();
        filterMonth.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filterMonth.relatedObject.put('RLM_Date_Literal_String__c','THIS_MONTH');
        inputWrapper.columnFilterList.add(filterMonth);
        REN_QueryBuilderWrapper.ColumnFilter filterYear = getFilter(null,'DATE','!=');
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filterYear.relatedObject = new REN_Line_Criteria__c();
        filterYear.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filterYear.relatedObject.put('RLM_Date_Literal_String__c','NEXT_YEAR');
        inputWrapper.columnFilterList.add(filterYear);
        system.assert(inputWrapper.columnFilterList != null);
        REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList, logicString, true, '');
    }
    static testMethod void LiteralWeekTest() {
        String logicString = '';
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'Custom Search');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();       
        REN_QueryBuilderWrapper.ColumnFilter filter = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter.relatedObject = new REN_Line_Criteria__c();
        filter.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filter.relatedObject.put('RLM_Date_Literal_String__c','THIS_WEEK');
        inputWrapper.columnFilterList.add(filter);        
        REN_QueryBuilderWrapper.ColumnFilter filter1 = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter1.relatedObject = new REN_Line_Criteria__c();
        filter1.relatedObject.put('RLM_Date_Literal_Number__c',2);
        filter1.relatedObject.put('RLM_Date_Literal_String__c','NEXT_N_WEEKS');
        inputWrapper.columnFilterList.add(filter1);        
         REN_QueryBuilderWrapper.ColumnFilter filter2 = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter2.relatedObject = new REN_Line_Criteria__c();
        filter2.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filter2.relatedObject.put('RLM_Date_Literal_Number__c',2);
        filter2.relatedObject.put('RLM_Date_Literal_String__c','LAST_N_MONTHS');
        inputWrapper.columnFilterList.add(filter2);  
        system.assert(inputWrapper.columnFilterList != null);      
        REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList, logicString, true, '');
    }
    static testMethod void LiteralYearQuarterTest() {
        String logicString = '';
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'Custom Search');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();        
        REN_QueryBuilderWrapper.ColumnFilter filter = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter.relatedObject = new REN_Line_Criteria__c();
        filter.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filter.relatedObject.put('RLM_Date_Literal_String__c','THIS_WEEK');
        inputWrapper.columnFilterList.add(filter);       
        REN_QueryBuilderWrapper.ColumnFilter filter1 = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter1.relatedObject = new REN_Line_Criteria__c();
        filter1.relatedObject.put('RLM_Date_Literal_Number__c',2);
        filter1.relatedObject.put('RLM_Date_Literal_String__c','NEXT_N_YEARS');
        inputWrapper.columnFilterList.add(filter1);       
         REN_QueryBuilderWrapper.ColumnFilter filter2 = getFilter(null,'DATE',null);
        inputWrapper.filterLogic = '1';
        logicString = inputWrapper.filterLogic;
        filter2.relatedObject = new REN_Line_Criteria__c();
        filter2.relatedObject.put('RLM_Is_Specific_Date__c',false);
        filter2.relatedObject.put('RLM_Date_Literal_Number__c',2);
        filter2.relatedObject.put('RLM_Date_Literal_String__c','LAST_N_QUARTERS');
        inputWrapper.columnFilterList.add(filter2);  
        system.assert(inputWrapper.columnFilterList != null);     
        REN_IBExportODataController.formODataQueryInJson(inputWrapper.columnFilterList, logicString, true, '');
    }
}