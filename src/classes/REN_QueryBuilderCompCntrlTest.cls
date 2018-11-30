/**
 * Created Date		: May 08, 2018
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: Test Coverage for REN_QueryBuilderCompController and other classes
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					US3340		May 08, 2018	1.1			 		Added in sprint 757
**/
 
@isTest
private class REN_QueryBuilderCompCntrlTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'Test');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filter = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        filter.fieldApiName = 'Name';
        inputWrapper.columnFilterList.add(filter);
        REN_QueryBuilderCompController queryBuilderCmp = new REN_QueryBuilderCompController();
        queryBuilderCmp.inputWrapper = inputWrapper;
        queryBuilderCmp.addNewFilter();
        System.assertEquals(2, inputWrapper.columnFilterList.size());
        queryBuilderCmp.queryBuilder();
        queryBuilderCmp.deleteFilter();
        queryBuilderCmp.onDateOptionClick();
        
        inputWrapper.isIbExport = false;
        queryBuilderCmp.queryBuilder(inputWrapper);
        
        
        queryBuilderCmp.lineIndex = 0;
        queryBuilderCmp.deleteFilter();
        
        queryBuilderCmp.lineNumber = 0;
        
        queryBuilderCmp.configSettings = new REN_ConfigSettings();
        queryBuilderCmp.configSettings.initializeConfigSettings('Opportunity', 'Opportunity', 'Test', false, 'Mass Update');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        filter = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        filter.fieldApiName = 'Name';
        queryBuilderCmp.findFor(10000, 'Opportunity', 'My', '', inputWrapper.columnFilterList);
        queryBuilderCmp.doSearch();
        queryBuilderCmp.onFieldChange();
    }
    
    static testMethod void querybuilderHelperRef(){
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test',true,'Test');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filter = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        filter.fieldApiName = 'Name';
        filter.operator = '=';
        filter.filterValue = 'Test';
        filter.fieldDataType = 'REFERENCE';
        inputWrapper.columnFilterList.add(filter);
        REN_QueryBuilderCompController queryBuilderCmp = new REN_QueryBuilderCompController();
        inputWrapper.isIbExport = false;
        queryBuilderCmp.inputWrapper = inputWrapper;
        
        queryBuilderCmp.queryBuilder();
        
        //Boolean
        filter.fieldDataType = CSM_Constants.TYPE_BOOLEAN;
        queryBuilderCmp.queryBuilder();
        
        filter.fieldDataType = 'STRING';
        queryBuilderCmp.queryBuilder();
        
        filter.fieldDataType = 'INTEGER';
        filter.operator = CSM_Constants.OPERATOR_EQUAL;
        queryBuilderCmp.queryBuilder();
        
        filter.fieldDataType = 'DATE';
        string stringDate = '2018' + '-' + '5'
            + '-' + '11' + ' ' + '12' + ':' + 
            '20' + ':' + '20';
        filter.filterValue = stringDate;
        queryBuilderCmp.queryBuilder();
        
        
        filter.fieldDataType = 'DATETIME';
        filter.filterValue = stringDate;
        queryBuilderCmp.queryBuilder();
        
        filter.fieldDataType = 'ADDRESS';
        queryBuilderCmp.queryBuilder();
        
        filter.fieldDataType = 'UNHANDLED';
        queryBuilderCmp.queryBuilder();
        
        filter.fieldDataType = 'STRING';
        inputWrapper.filterLogic = '1';
        queryBuilderCmp.queryBuilder();
        
        System.assert(inputWrapper.columnFilterList != Null);
    }
    
    static testMethod void Test_validateCriteria(){
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test', true, 'Test');
        //inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filter = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        filter.fieldApiName = 'Name';
        //inputWrapper.columnFilterList.add(filter);
        REN_QueryBuilderCompController queryBuilderCmp = new REN_QueryBuilderCompController();
        queryBuilderCmp.inputWrapper = inputWrapper;
        queryBuilderCmp.addNewFilter();
        System.assert(inputWrapper.columnFilterList != Null);
        inputWrapper.filterLogic = '1';
        queryBuilderCmp.queryBuilder();
        queryBuilderCmp.queryBuilder(inputWrapper);
    }
    
    static testMethod void querybuilderHelperOperatorError(){
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test', true, 'Test');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filter = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        filter.fieldApiName = 'Name';
        //filter.operator = 'eq';
        filter.filterValue = 'Test';
        filter.fieldDataType = 'REFERENCE';
        inputWrapper.columnFilterList.add(filter);
        REN_QueryBuilderCompController queryBuilderCmp = new REN_QueryBuilderCompController();
        inputWrapper.isIbExport = false;
        queryBuilderCmp.inputWrapper = inputWrapper;
        
        queryBuilderCmp.queryBuilder();
        System.assert(inputWrapper.columnFilterList != Null);
    }
    static testMethod void querybuilderHelperValueError(){
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test', true, 'Test');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filter = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        filter.fieldApiName = 'Name';
        filter.operator = 'eq';
        filter.filterValue = '';
        //filter.fieldDataType = 'REFERENCE';
        inputWrapper.columnFilterList.add(filter);
        REN_QueryBuilderCompController queryBuilderCmp = new REN_QueryBuilderCompController();
        inputWrapper.isIbExport = false;
        queryBuilderCmp.inputWrapper = inputWrapper;
        
        queryBuilderCmp.queryBuilder();
        System.assert(inputWrapper.columnFilterList != Null);
    }
    
    static testMethod void querybuilderHelperParseCSV(){
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test', true,'Test');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filter = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        filter.fieldApiName = 'Name';
        filter.operator = 'eq';
        String test = '';
        for(Integer i=0;i<7001;i++){
            test+='Test,test,test,test,';
        }
        filter.filterValue = test;
        filter.fieldDataType = 'REFERENCE';
        inputWrapper.columnFilterList.add(filter);
        REN_QueryBuilderCompController queryBuilderCmp = new REN_QueryBuilderCompController();
        inputWrapper.isIbExport = false;
        queryBuilderCmp.inputWrapper = inputWrapper;
        
        filter.fieldDataType = 'INTEGER';
        queryBuilderCmp.queryBuilder();
        System.assert(inputWrapper.columnFilterList != Null);
    }
    
    static testMethod void querybuilderHelperWithLogicfilter(){
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test', true,'Test');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filter = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        filter.fieldApiName = 'Name';
        filter.operator = 'eq';
        filter.filterValue = 'Test';
        filter.fieldDataType = 'REFERENCE';
        inputWrapper.columnFilterList.add(filter);
        REN_QueryBuilderCompController queryBuilderCmp = new REN_QueryBuilderCompController();
        inputWrapper.isIbExport = false;
        queryBuilderCmp.inputWrapper = inputWrapper;

        filter.fieldDataType = 'STRING';
        inputWrapper.filterLogic = '1';
        queryBuilderCmp.queryBuilder();
        System.assert(inputWrapper.columnFilterList != Null);
    }
    
    static testMethod void QueryBuilderCtrlFieldChange() {
        // TO DO: implement unit test
        REN_QueryBuilderWrapper inputWrapper = new REN_QueryBuilderWrapper('Opportunity','Test', true,'Test');
        inputWrapper.columnFilterList = new List<REN_QueryBuilderWrapper.ColumnFilter>();
        REN_QueryBuilderWrapper.ColumnFilter filter = new REN_QueryBuilderWrapper.ColumnFilter('Opportunity');
        filter.fieldApiName = 'AccountId';
        filter.operator = '=';
        filter.filterValue = 'Test';
        filter.fieldDataType = 'REFERENCE';
        inputWrapper.columnFilterList.add(filter);
        REN_QueryBuilderCompController queryBuilderCmp = new REN_QueryBuilderCompController();
        queryBuilderCmp.inputWrapper = inputWrapper;
        queryBuilderCmp.addNewFilter();
        System.assertEquals(2, inputWrapper.columnFilterList.size());
        queryBuilderCmp.queryBuilder();
        
        queryBuilderCmp.lineNumber = 0;
        
        queryBuilderCmp.configSettings = new REN_ConfigSettings();
        queryBuilderCmp.configSettings.initializeConfigSettings('Opportunity', 'Opportunity', 'Test', false, 'Mass Update');
        queryBuilderCmp.onFieldChange();
        
        filter.fieldApiName = 'CloseDate';
        queryBuilderCmp.lineNumber = 0;
        queryBuilderCmp.onFieldChange();
        
        inputWrapper.isFilterLogic = true;
        
        boolean isMaxCriteriaReached = queryBuilderCmp.isMaxCriteriaReached;
        String fieldAPIName = queryBuilderCmp.fieldAPIName;
    }
}