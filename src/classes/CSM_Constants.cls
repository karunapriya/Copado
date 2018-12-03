public with sharing class CSM_Constants {

	public static final String TASK_SOQL;	
	static {
		if(CSM_Util.getRecordTypeExists(new Task())){
			TASK_SOQL = 'SELECT Id, CSM_Risk_Reason__c, Description, WhoId, CSM_Account__c, format(ActivityDate), Subject, WhatId, What.Name, CSM_Play__c, format(CSM_Completed_Date__c), CSM_Account_Plan__r.CSM_AccountId__r.Name, CSM_Account_Plan__c, OwnerId, Owner.Name, Status, CSM_Task_State__c, CSM_Play_Task__c, CSM_Play__r.CSM_Display_Name__c,recordtype.name, IsClosed FROM Task ';
		}
		else{			
			TASK_SOQL = 'SELECT Id, CSM_Risk_Reason__c, Description, WhoId, CSM_Account__c, format(ActivityDate), Subject, WhatId, What.Name, CSM_Play__c, format(CSM_Completed_Date__c), CSM_Account_Plan__r.CSM_AccountId__r.Name, CSM_Account_Plan__c, OwnerId, Owner.Name, Status, CSM_Task_State__c, CSM_Play_Task__c, CSM_Play__r.CSM_Display_Name__c, IsClosed FROM Task ';	
		}
	}
	
	//Static Record Limit Variables
	public static String REC_LIMIT_ASSETS = 'Assets';
	public static String REC_LIMIT_SERVICE_CONTRACT = 'ServiceContract';
	public static String REC_LIMIT_FOCUS_CATEGORIES = 'FocusCategories';
	public static String REC_LIMIT_HEALTH_CHARTS = 'HealthCharts';
	public static String REC_LIMIT_SUCCESS_TASKS = 'SuccessTasks';
	public static String REC_LIMIT_ACTIONS = 'Action';
	public static String REC_LIMIT_ACTIVITY_HISTORY = 'ActivityHistory';
	public static String REC_LIMIT_OPPORTUNITIES = 'Opportunities';
	public static String REC_LIMIT_PLAYBOOK = 'Playbook';
	
	// Static final variables
	
	public static Boolean PLAY_RESULT_TRIGGER = true;
	public static Boolean CASE_TRIGGER = true;
	public static Boolean ACCOUNT_PLAN_BEFORE_TRIGGER = true;
	public static Boolean ACCOUNT_PLAN_AFTER_TRIGGER = true;
	public static Boolean ACCOUNT_PLAN_PLAYBOOK_TRIGGER = true;
	public static Boolean ACCOUNT_TRIGGER = true;
	public static Boolean OPPORTUNITY_TRIGGER =  true;
	public static Boolean OPPORTUNITY_TRIGGER_BEFORE =  true;
	public static Boolean PLAY_CRITERIA_TRIGGER =  true;
	public static Boolean TASK_TRIGGER =  true;
	public static Boolean SCOUT_CUSTOMER_TRIGGER =  true;
	public static Boolean PLAYBOOK_PLAY_TRIGGER = true;	
	public static Boolean PLAYBOOK_TRIGGER = true;
	public static Boolean SPPL_TRIGGER = true;	
	public static Boolean BatchFilter_TRIGGER = true;	
	public static Boolean LEAD_TRIGGER = true;
 
	public static final String IS_HIGH_PRIORITY = 'ishighpriority';
	public static final String CONTRACT_ID = 'contractid';
	public static final String CURRENCY_ISO_CD = 'CurrencyIsoCode';	

	// Object Prefix
	public static final String OBJ_TYPE = 'objType';
	public static final String RET_URL = 'retUrl';
	public static final String RET_TO_URL = 'retURL';
	public static final String SAVE_URL = 'saveURL';
	public static final String CANCEL_URL = 'cancelURL';
	public static final String ACCOUNT_PREFIX = '001';
	public static final String OPPTY_PREFIX = '006';
	public static final String CASE_PREFIX = '500';
	
	public static final String ACCOUNT_ID_PARAM = 'accid';
	public static final String ID_PARAM = 'id';
	public static final String ACCT_TEMPLATE_PARAM = 'acctTemplate';
	public static final String STATUS_PARAM = 'status';
	public static final String RANGE_DATE_PARAM = 'rangeDate';
	public static final String UTF_8 = 'UTF-8';
	public static final String ACCT_PLAN_TEMPLATE = 'aptId';
	public static final String TITLE_PARAM = 'title';
	public static final String ADD_PARAM = 'add';
	public static final String PLAYBOOK_ID_PARAM = 'pbId';
	public static final String ACCT_PLAN_ID = 'apId';
	public static final String NAME = 'Name';
	public static final String CASE_NUMBER = 'CaseNumber';
	public static final String USER_PREF_OBJECT_TYPE = 'attrObjectType';
	public static final String USER_SP_ACCT_LIST = 'attrSPAccountIdsList';
	public static final String USER_SP_ACCT_ARRAY = 'attrSPAccountIdsArray';
	
	
	public static final String USER_PREF_FIELD_NAME = 'attrFieldName';
	public static final String USER_PREF_FIELD_TYPE = 'attrFieldType';
	public static final String USER_PREF_FIELD_VALUE = 'attrFieldValue';
	
	public static final String SELECTED_TAB = 'selectedTab';	
	public static final String SELECTED_TAB_PLAYS = '0';
	
	public static final String INT_RESOLUTION_STATUS_UNRECOGNIZED = 'Unrecognized Resolution Status';
	public static final String INT_RESOLUTION_STATUS_MISSING = 'Missing Resolution Status';
	public static final String INT_PLAYBOOK_MISSING = 'Missing playbook';
	public static final String INT_PLAYBOOK_NAME_MISSING = 'Missing playbook name';
	public static final String INT_PLAYBOOK_DESC_MISSING = 'Missing playbook desc';
	public static final String INT_PLAY_MISSING = 'Missing play';
	public static final String INT_PLAY_NAME_MISSING = 'Missing play name';
	public static final String INT_PLAY_DESC_MISSING = 'Missing play desc';
	public static final String INT_PLAY_OBJECT_MISSING = 'Missing play object';
	public static final String INT_PLAY_ACTIVATE_DATE_FORMAT = 'Incorrect Date Format';
	public static final String INT_ACCOUNT_ID_INCORRECT = 'Incorrect Account Id';
	
	public static final String INT_PLAYRESULT_MISSING = 'Missing playresult';
	public static final String INT_ACCOUNTID_MISSING = 'Missing accountId';
	public static final String INT_PLAYRESULT_ATTAINED = 'Attained';
	public static final String INT_PLAYRESULT_HALTED = 'Halted';
	public static final String INT_PLAYRESULT_PENDING = 'Pending';
	
	// Dynamic Task soql operators
	public static final String ACCT_PLAN_PREFIX = CSM_Account_Plan__c.sObjectType.getDescribe().getKeyPrefix();
    public static final String EMAIL_URL = '/_ui/core/email/author/EmailAuthor?p3_lkid=';
	public static final String EMAIL_CONTACT_PARAM = '&p2_lkid=';
	public static final String TASK_COMPLETED = 'completed';
	public static final String TASK_PROCESSING_COMPLETE = 'complete';
	public static final String TASK_CREATE_URL = '/00T/e?retURL=';
	public static final String TASK_EXISTING_URL = '/e?retURL=';
	public static final String TASK_WHAT_ID = '&what_id=';
	public static final String TASK_SUBJECT = '&tsk5=';
	public static final String TASK_WHERE = 'where'; 
	public static final String TASK_FOLLOWUP_SUBJECT = 'Follow up to '; 
	
	public static final String TASK_STATE_SYSTEM_COMPLETION = 'System Completion';
	public static final String TASK_STATE_SYSTEM_DISMISSAL = 'System Dismissal';
	public static final String TASK_STATE_MANUAL_COMPLETION = 'Manual Completion';
	public static final String TASK_STATE_MANUAL_DISMISSAL = 'Manual Dismissal';
	public static final String EQUALS = 'equals';
	public static final String NOT_EQUALS = 'notEqualTo';
	public static final String LESS_THAN = 'lessThan';
	public static final String GREATER_THAN = 'greaterThan';
	public static final String LESS_OR_EQUAL = 'lessOrEqual';
	public static final String GREATER_OR_EQUAL = 'greaterOrEqual';
	public static final String STARTS_WITH = 'Starts With';
	public static final String CONTAINS = 'contains';
	public static final String DOES_NOT_CONTAINS = 'doesNotContain';
    public static final String EXISTS = 'EXISTS';
    public static final String NOT_EXISTS = 'NOT EXISTS';
	//FLS check constants 
    public static final String DML_OPERATION_UPSERT = 'Upsert';
    public static final String DML_OPERATION_INSERT = 'Insert'; 
    public static final String DML_OPERATION_UPDATE = 'Update';
    public static final String DML_OPERATION_DELETE = 'Delete';
    public static final String DML_OPERATION_READ = 'Read';

    public static final String CSM_FOCUS_CATEGORIES_TYPE_MAIN = 'Main';
    public static final String CSM_FOCUS_CATEGORIES_TYPE_TILES = 'Tiles';
    
    //CSM Admin Custom Setting
    public static final String CSM_ADMIN = 'CSM Admin';
    public static final String SYSTEM_ADMIN_NAME = 'System Administrator';
    
    //CSM Field Types
    public static final String TYPE_STRING = 'STRING';
    public static final String TYPE_DATE = 'DATE';
    public static final String TYPE_INTEGER = 'INTEGER';
    public static final String TYPE_PICKLIST = 'PICKLIST';
	public static final String TYPE_MULTIPICKLIST = 'MULTIPICKLIST';    
    public static final String TYPE_DOUBLE = 'DOUBLE';
    public static final String TYPE_CURRENCY = 'CURRENCY';
    public static final String TYPE_PERCENT = 'PERCENT';
    public static final String TYPE_DATETIME = 'DATETIME';
    public static final String TYPE_BOOLEAN = 'BOOLEAN';
    public static final String TYPE_REFERENCE = 'REFERENCE';
    public static final String TYPE_LOOKUP = 'LOOKUP';
    public static final String TYPE_TEXTAREA = 'TEXTAREA';
    public static final String TYPE_LONGTEXTAREA = 'LONGTEXTAREA';
    public static final String TYPE_ID = 'ID'; 

	//CSM OPerator Types
	public static final String OPERATOR_ALL = 'ALL';
	public static final String OPERATOR_LIKE = 'LIKE';
	public static final String OPERATOR_IN = 'IN';
	public static final String OPERATOR_NOTIN = 'NOT IN';
	public static final String OPERATOR_EQUAL = '=';
	public static final String OPERATOR_NOTEQUAL = '!=';
	public static final String OPERATOR_INCLUDES = 'INCLUDES';
	public static final String OPERATOR_EXCLUDES = 'EXCLUDES';
	public static final String OPERATOR_GREATERTHAN = '>';
	public static final String OPERATOR_GREATERTHANEQUALTO = '>=';
	public static final String OPERATOR_LESSERTHAN = '<';
	public static final String OPERATOR_LESSERTHANEQUALTO = '<=';
	
    public static final String OBJ_FCG_GROUPID = 'fcGroupId';
    public static final String OBJ_FCG_EDITFC = 'editFC';
    
    //Focus Category Group Object and Field List
    public static final String OBJ_FCG = 'CSM_Focus_Category_Group__c';
    public static final String OBJ_FCG_ISACTIVE = 'CSM_IsActive__c';
    public static final String OBJ_FCG_DISPLAY_NAME = 'CSM_Display_Name__c';
    public static final String OBJ_FCG_GROUP_TYPE = 'CSM_Group_Type__c';
    public static final String OBJ_FCG_ORDER = 'CSM_Order__c';
    public static final String OBJ_FCG_ORDER_AUTO_ID = 'CSM_Order_Auto_Id__c';
    public static final String OBJ_FCG_CATEGORY_GROUP = 'CSM_Focus_Category_Group__c';
    public static final String OBJ_FCG_CATEGORY_COLUMN_COUNT = 'CSM_Category_Column_Count__c';
    public static final String OBJ_FCG_CATEGORIES_COUNT = 'CSM_Categories_Count__c';
    public static final String OBJ_FCG_OWNERID = 'OwnerId';
    public static final String OBJ_FCG_NAME = 'Name';
    
    //Focus Category Object and Field List 
    public static final String OBJ_FC = 'CSM_Focus_Category__c';
    public static final String OBJ_FC_DISPLAY_NAME = 'CSM_Focus_Category_View__r.CSM_Display_Name__c';
    public static final String OBJ_FC_OBJECT_NAME = 'CSM_Focus_Category_View__r.CSM_Object_Name__c';
    public static final String OBJ_FC_SOQL = 'CSM_Focus_Category_View__r.CSM_SOQL__c';
    public static final String OBJ_FC_COLUMNS = 'CSM_Focus_Category_View__r.CSM_Columns__c';
    public static final String OBJ_FC_CRITERIA = 'CSM_Focus_Category_View__r.CSM_Criteria__c';
    public static final String OBJ_FC_VIEW_ORDER = 'CSM_View_Order__c';
    public static final String OBJ_FC_CATEGORY_COLUMN = 'CSM_Focus_Category_Column__c';
    public static final String OBJ_FC_FOCUS_CATEGORY_VIEW ='CSM_Focus_Category_View__c';
    public static final String OBJ_FC_ISACTIVE ='CSM_IsActive__c';
    public static final String OBJ_FC_NAME = 'Name';
    public static final String OBJ_FCV_FILTER_BY_OWNER= 'CSM_Filter_By_Owner_Value__c';
    public static final String OBJ_FCV_IS_SAVED_SEARCH = 'RLM_Is_Saved_Search__c';
    
    // Focus Category View Criteria
    public static final String OBJ_FCVC_IS_SPECIFIC_DATE = 'RLM_Is_Specific_Date__c';
    public static final String OBJ_FCVC_DATE_LITERAL_NUMBER = 'RLM_Date_Literal_Number__c';
    public static final String OBJ_FCVC_DATE_LITERAL_STRING = 'RLM_Date_Literal_String__c';
    
    //Criteria Constants
    public static final String C_YESTERDAY = 'YESTERDAY';
    public static final String C_TODAY = 'TODAY';
    public static final String C_TOMORROW = 'TOMORROW';
    
    public static final String C_LAST_WEEK = 'LAST_WEEK';
    public static final String C_THIS_WEEK = 'THIS_WEEK';
    public static final String C_NEXT_WEEK = 'NEXT_WEEK';
    public static final String C_LAST_N_WEEKS = 'LAST_N_WEEKS';
    public static final String C_NEXT_N_WEEKS = 'NEXT_N_WEEKS';
    public static final String C_N_WEEKS_AGO = 'N_WEEKS_AGO';
    
    public static final String C_LAST_MONTH = 'LAST_MONTH';
    public static final String C_THIS_MONTH = 'THIS_MONTH';
    public static final String C_NEXT_MONTH = 'NEXT_MONTH';
    public static final String C_LAST_N_MONTHS = 'LAST_N_MONTHS';
    public static final String C_NEXT_N_MONTHS = 'NEXT_N_MONTHS';
    public static final String C_N_MONTHS_AGO = 'N_MONTHS_AGO';
    
    public static final String C_LAST_90_DAYS = 'LAST_90_DAYS';
    public static final String C_NEXT_90_DAYS = 'NEXT_90_DAYS';
    
    public static final String C_LAST_N_DAYS = 'LAST_N_DAYS';
    public static final String C_NEXT_N_DAYS = 'NEXT_N_DAYS';
    public static final String C_N_DAYS_AGO = 'N_DAYS_AGO';
    
    public static final String C_LAST_QUARTER = 'LAST_QUARTER';
    public static final String C_THIS_QUARTER = 'THIS_QUARTER';
    public static final String C_NEXT_QUARTER = 'NEXT_QUARTER';
    public static final String C_LAST_N_QUARTERS = 'LAST_N_QUARTERS';
    public static final String C_NEXT_N_QUARTERS = 'NEXT_N_QUARTERS';
    public static final String C_N_QUARTERS_AGO = 'N_QUARTERS_AGO';
    
    public static final String C_LAST_YEAR = 'LAST_YEAR';
    public static final String C_THIS_YEAR = 'THIS_YEAR';
    public static final String C_NEXT_YEAR = 'NEXT_YEAR';
    public static final String C_LAST_N_YEARS = 'LAST_N_YEARS';
    public static final String C_NEXT_N_YEARS = 'NEXT_N_YEARS';
    public static final String C_N_YEARS_AGO = 'N_YEARS_AGO';
    
    public static final String C_LAST_FISCAL_QUARTER = 'LAST_FISCAL_QUARTER';
    public static final String C_THIS_FISCAL_QUARTER = 'THIS_FISCAL_QUARTER';
    public static final String C_NEXT_FISCAL_QUARTER = 'NEXT_FISCAL_QUARTER';
    public static final String C_LAST_N_FISCAL_QUARTERS = 'LAST_N_FISCAL_QUARTERS';
    public static final String C_NEXT_N_FISCAL_QUARTERS = 'NEXT_N_FISCAL_QUARTERS';
    public static final String C_N_FISCAL_QUARTERS_AGO = 'N_FISCAL_QUARTERS_AGO';
    
    public static final String C_LAST_FISCAL_YEAR = 'LAST_FISCAL_YEAR';
    public static final String C_THIS_FISCAL_YEAR = 'THIS_FISCAL_YEAR';
    public static final String C_NEXT_FISCAL_YEAR = 'NEXT_FISCAL_YEAR';
    public static final String C_LAST_N_FISCAL_YEARS = 'LAST_N_FISCAL_YEARS';
    public static final String C_NEXT_N_FISCAL_YEARS = 'NEXT_N_FISCAL_YEARS';
    public static final String C_N_FISCAL_YEARS_AGO = 'N_FISCAL_YEARS_AGO'; 
    
    //Focus Category Column Object and Field List
    public static final String OBJ_FCC = 'CSM_Focus_Category_Column__c';
    public static final String OBJ_FCC_COLUMN_ORDER = 'CSM_Column_Order__c';
    public static final String OBJ_FCC_CATEGORY_GROUP = 'CSM_Focus_Category_Group__c';
    public static final String OBJ_FCC_CATEGORIES_COUNT = 'CSM_Categories_Count__c';
    public static final String OBJ_FCC_DISPLAY_NAME = 'CSM_Display_Name__c';
    public static final String OBJ_FCC_ISACTIVE = 'CSM_IsActive__c';
    public static final String OBJ_FCC_NAME = 'Name';
    public static final String OBJ_FCC_ID = 'Id';

    //Success Plan fields
    public static final String OBJ_AP = 'CSM_Account_Plan__c';
    public static final String OBJ_AP_ID = 'Id';
    public static final String OBJ_AP_NAME = 'Name';
    public static final String OBJ_AP_ACCOUNT = 'CSM_AccountId__c';
    public static final String OBJ_AP_ACCOUNT_MANAGER = 'CSM_Account_Manager__c';
    public static final String OBJ_AP_ACCOUNT_PLAN_TEMPLATE = 'CSM_Account_Plan_Template__c';
    public static final String OBJ_AP_CUSTOMER_SUCCESS_MGR = 'CSM_Customer_Success_Manager__c';
    public static final String OBJ_AP_END_DATE = 'CSM_End_Date__c';
    public static final String OBJ_AP_PHASE_START_DATE = 'CSM_Phase_Start_Date__c';
    public static final String OBJ_AP_START_DATE ='CSM_Start_Date__c';
    public static final String OBJ_AP_ACCOUNT_OWNER = 'CSM_Account_Owner__c';
    public static final String OBJ_AP_ACCOUNT_OWNER_ID = 'CSM_Account_Owner_Id__c';
    public static final String OBJ_AP_CSM_CONTACT = 'CSM_Contact__c';
    public static final String OBJ_AP_CSM_MANAGER = 'CSM_Manager__c';
    public static final String OBJ_AP_EXEC_SPONSOR = 'CSM_Exec_Sponsor__c';
    public static final String OBJ_AP_RENEWAL_CONTACT = 'CSM_Renewal_Contact__c';
    public static final String OBJ_AP_RENEWAL_MANAGER = 'CSM_Renewal_Manager__c';
    public static final String OBJ_AP_SUPPORT_CONTACT = 'CSM_Support_Contact__c';
    public static final String OBJ_AP_ACV_AMOUNT = 'CSM_ACV_Amount__c';
    public static final String OBJ_AP_ACTIVE = 'CSM_isActive__c';
    public static final String OBJ_AP_DISPLAY_NAME = 'CSM_DisplayName__c';
    public static final String OBJ_AP_RENEWAL_DATE = 'CSM_Renewal_Date__c';
    public static final String OBJ_AP_CURRENT_PHASE = 'CSM_CurrentPhase__c';
    //public static final String OBJ_AP_PLAN_PHASE = 'CSM_Plan_Phase__c';
    
    //Success Plan template fields
    public static final String OBJ_APT = 'CSM_Account_Plan_Template__c';
    public static final String OBJ_APT_ID = 'Id';
    public static final String OBJ_APT_NAME = 'Name';
    public static final String OBJ_APT_ISACTIVE = 'CSM_isActive__c';
    public static final String OBJ_APT_DISPLAY_NAME = 'CSM_Template_Name__c';
    public static final String OBJ_APT_OPP_DATES_TIMELINES = 'CSM_Opp_Dates_TimeLines__c';
    public static final String OBJ_APT_OPP_DATE = 'CSM_Opp_Date__c';
    public static final String OBJ_APT_CURRENCY_CODE = 'CSM_Currency_Code__c';
    public static final String OBJ_APT_PHASE_COUNT = 'CSM_Phase_Count__c';
    public static final String OBJ_APT_ACT_IND_CNT = 'CSM_Active_Indicators_Count__c';
    
    //Success Plan Template Fields
    public static final String OBJ_APPH = 'CSM_Account_Plan_Phase__c';
    public static final String OBJ_APPH_ID = 'Id';
    public static final String OBJ_APPH_NAME = 'Name';
    public static final String OBJ_APPH_PHASE_NAME = 'CSM_Phase_Name__c';
    public static final String OBJ_APPH_LENGTH = 'CSM_Length__c';
    public static final String OBJ_APPH_TEMPLATE = 'CSM_Account_Plan_Template__c';
    public static final String OBJ_APPH_ORDER = 'CSM_Order__c';  

    public static final String OBJ_LIST_INDICATORS = 'Indicators';    
    public static final String OBJ_LIST_FOCUS_CATEGORIES = 'Focus Categories';
    public static final String OBJ_LIST_HEALTH_COLORS = 'CSM_Health_Status_Colors__c';
    public static final String OBJ_LIST_PHASE_COLORS = 'CSM_Phase_Colors__c';
    public static final String OBJ_LIST_PLAYS = 'Plays';
    public static final String OBJ_LIST_RISK_REASON = 'RiskReason';
    public static final String OBJ_LIST_RISK_REASON_DISMISS = 'RiskReasonDismiss';
    public static final String OBJ_LIST_HEALTH_OPTIONS = 'CSM_Health_Status_Options__c';
    public static final String OBJ_LIST_OPPTY_RELATED_LIST = 'REN_Opportunity_Related_List__c';
    public static final String OBJ_LIST_FILTER_ATTRIBUTES = 'FilterAttributes';
    public static final String OBJ_LIST_SP_FILTER_ATTRIBUTES = 'SuccessPlanFilterAttributes';    
    public static final String OBJ_LIST_TASK_FILTER_ATTRIBUTES = 'TaskFilterAttributes';    
    public static final String OBJ_LIST_RISK_REASON_COMBINED = 'RiskReasonCombined';
    
    
    //public static final String VIEW_PAGE = '/ui/list/FilterEditPage';       
    public static final String FTYPE_VAL = '?ftype='; 
    public static final String ID_VAL = '?id=';
    public static final String OBJ_TYPE_ACCOUNT = 'Account';
    public static final String OBJ_TYPE_OPPORTUNITY = 'Opportunity';
    public static final String OBJ_TYPE_ACCOUNT_PLAN = 'CSM_Account_Plan__c'; 
    public static final String OBJ_TYPE_TASK = 'Task';
    public static final String OBJ_TYPE_ACTIVITY = 'Activity';
    public static final String PARAM_VIEWID = 'viewID';
    public static final String PARAM_VIEWID_URL = '?viewID=';
    public static final String PARAM_GROUPID = '?fcGroupId=';
    public static final String PARAM_RETURN_URL = '&retURL=';
    public static final String PARAM_CANCEL_URL = '&cancelURL=';
    public static final String PARAM_GSL_URL = 'gsl'; //Grid State Load
    public static final String SELECT_STATEMENT = 'select id from '; 
    
    // playbook play
    public static final String OBJ_PLAYBOOKPLAY_PLAYBOOK = 'CSM_Playbook__c';
    public static final String OBJ_PLAYBOOKPLAY_PLAY = 'CSM_Play__c';
    
    //Indicator and Indicator Group constants
    public static final String OBJ_I_ID = 'Id';
    public static final String OBJ_I_NAME = 'Name';
    public static final String OBJ_I_DISPLAY_NAME = 'CSM_Indicator_Display_Name__c';
    public static final String OBJ_I_INDICATOR_GROUP = 'CSM_Indicator_Group__c';
    public static final String OBJ_I_FIELD_NAME = 'CSM_Object_Field_Name__c';
    public static final String OBJ_I_OBJECT_NAME = 'CSM_Object_Name__c';
    public static final String OBJ_I_IS_ACTIVE = 'CSM_isActive__c';
    public static final String OBJ_I = 'CSM_Indicator__c';
    public static final String OBJ_I_FIELD_TYPE = 'CSM_Object_Field_Type__c';
    public static final String OBJ_IG_DISPLAY_NAME = 'CSM_Display_Name__c';
    public static final String OBJ_IG = 'CSM_Indicator_Group__c';
    public static final String OBJ_IG_ID = 'Id';
    public static final String OBJ_IG_NAME = 'Name';
    public static final String OBJ_I_FIELD_LABEL = 'CSM_Object_Field_Label__c';
    public static final String OBJ_I_CURRENCY_CODE = 'RLM_Currency_Code__c';    
    
     //Indicator and Indicator Group constants
    public static final String OBJ_FCV_DISPLAY_NAME = 'CSM_Display_Name__c';
    public static final String OBJ_FCV_COLUMN = 'CSM_Focus_Category_View_Column__c';
    public static final String OBJ_FCV = 'CSM_Focus_Category_View__c';
    public static final String OBJ_FCV_COLUMNS = 'CSM_Columns__c';
    public static final String OBJ_FCV_CRIT = 'CSM_Criteria__c';
    public static final String OBJ_FCV_SOQL = 'CSM_SOQL__c';
    public static final String OBJ_FCV_CRITERIA = 'CSM_Focus_Category_View_Criteria__c';
    public static final String OBJ_FCV_OBJECT_NAME = 'CSM_Object_Name__c';
    public static final String OBJ_FCV_CURRENCY_HEADER = 'CSM_Currency_Header__c';
    public static final String OBJ_FCV_FILTER_LOGIC = 'RLM_Filter_Logic__c';    
    public static final String OBJ_FCV_IS_TILE = 'CSM_IsTile__c';
    public static final String OBJ_FCV_IS_ACTIVE = 'CSM_Is_Active__c';  
    public static final String OBJ_FCV_Queue = 'CSM_Case_Queue__c';
    public static final String OBJ_FCV_Sort_By='CSM_Sort_By__c';
	public static final String OBJ_FCV_Sort_Order='CSM_Sort_Order__c';      
    
    public static final String OBJ_APP = 'CSM_Account_Plan_Playbook__c';
    public static final String OBJ_APP_ID = 'Id';
    public static final String OBJ_APP_ISACTIVE = 'CSM_isActive__c';
    public static final String OBJ_APP_PLAYBOOK = 'CSM_Playbook__c';
    public static final String OBJ_APP_ACCT_TEMPLATE = 'CSM_Account_Plan_Template__c';
    public static final String OBJ_APP_ACCT_PLAN = 'CSM_Account_Plan__c';
    public static final String OBJ_APP_BYPASS_CRITERIA = 'CSM_ByPass_Criteria__c';
    public static final String OBJ_APP_SOURCE = 'CSM_Source__c';
    
    public static final String OBJ_PLAYBOOK = 'CSM_Playbook__c';
    public static final String OBJ_PLAYBOOK_DISPLAY_NAME = 'CSM_Display_Name__c';
    public static final String OBJ_PLAYBOOK_ISACTIVE = 'CSM_IsActive__c';
    public static final String OBJ_PLAYBOOK_AUTOMATED = 'CSM_Automated__c';
    public static final String OBJ_PLAYBOOK_SHORT_DESC = 'CSM_Short_Description__c';
    public static final String OBJ_PLAYBOOK_LONG_DESC = 'CSM_Long_Description__c';
    public static final String OBJ_PLAYBOOK_PLAY_TOTAL = 'CSM_Play_Total__c';
    public static final String OBJ_PLAYBOOK_EXTERNAL_ID = 'CSM_External_Id__c';
    public static final String OBJ_PLAYBOOK_ID = 'Id';
    public static final String OBJ_PLAYBOOK_NAME = 'Name';
    public static final String OBJ_PLAYBOOK_TYPE = 'CSM_Playbook_Type__c';
    
    //Timeline Colors
    public static final String TIMELINE_WHITE = '#FFFFFF';
    public static final String TIMELINE_GRAY = '#404040';
    
    //Success Plan template Indicators
    public static final String OBJ_APT_IND = 'CSM_Account_Plan_Template_Indicator__c';
    public static final String OBJ_APT_IND_ID = 'Id';
    public static final String OBJ_APT_IND_NAME = 'Name';
    public static final String OBJ_APT_IND_ACCTPLANTEPMPLATE = 'CSM_Account_Plan_Template__c';
    public static final String OBJ_APT_IND_ISACTIVE = 'CSM_IsACtive__c';
    public static final String OBJ_APT_IND_CRIT_1_FROM = 'CSM_Criteria_1_From_Value__c';
    public static final String OBJ_APT_IND_CRIT_1_TO = 'CSM_Criteria_1_To_Value__c';
    public static final String OBJ_APT_IND_CRIT_1_TYPE = 'CSM_Criteria_1_Type__c';
    public static final String OBJ_APT_IND_CRIT_2_FROM = 'CSM_Criteria_2_From_Value__c';
    public static final String OBJ_APT_IND_CRIT_2_TO = 'CSM_Criteria_2_To_Value__c';
    public static final String OBJ_APT_IND_CRIT_2_TYPE = 'CSM_Criteria_2_Type__c';
    public static final String OBJ_APT_IND_CRIT_3_FROM = 'CSM_Criteria_3_From_Value__c';
    public static final String OBJ_APT_IND_CRIT_3_TO = 'CSM_Criteria_3_To_Value__c';
    public static final String OBJ_APT_IND_CRIT_3_TYPE = 'CSM_Criteria_3_Type__c';
    public static final String OBJ_APT_IND_CRIT_1_FROM_DATE = 'CSM_Criteria_1_From_Date__c';
    public static final String OBJ_APT_IND_CRIT_1_TO_DATE = 'CSM_Criteria_1_To_Date__c';
    public static final String OBJ_APT_IND_CRIT_2_FROM_DATE = 'CSM_Criteria_2_From_Date__c';
    public static final String OBJ_APT_IND_CRIT_2_TO_DATE = 'CSM_Criteria_2_To_Date__c';
    public static final String OBJ_APT_IND_CRIT_3_FROM_DATE = 'CSM_Criteria_3_From_Date__c';
    public static final String OBJ_APT_IND_CRIT_3_TO_DATE = 'CSM_Criteria_3_To_Date__c'; 
	public static final String OBJ_APT_IND_INDICATOR = 'CSM_Indicator__c';
	public static final String OBJ_APT_IND_ORDER = 'CSM_Order__c';
	public static final String FAIL = 'Fail';
	public static final String SUCCESS = 'Success';
	public static final String MEET = 'Meet';
	public static final String CSS_PASS = 'pass';
	public static final String CSS_FAIL = 'fail';
	
	//Task constants
	public static final String OBJ_TASK = 'Task';
	public static final String OBJ_EVENT = 'Event';
	public static final String OBJ_T_ID = 'Id';
	public static final String OBJ_T_SUBJECT = 'Subject';
	public static final String OBJ_T_TYPE = 'Type';
	public static final String OBJ_T_STATUS = 'Status';
	public static final String OBJ_T_ACTIVITYDATE = 'ActivityDate';
	public static final String OBJ_T_WHATID = 'WhatId';
	public static final String OBJ_T_TASK_STATE = 'CSM_Task_State__c';
	public static final String OBJ_T_PLAY = 'CSM_Play__c';
	public static final String OBJ_T_PLAYBOOK = 'CSM_Playbook__c';
	public static final String OBJ_T_WHOID = 'WhoId';
	public static final String OBJ_T_ACCOUNTID = 'AccountId';
	public static final String OBJ_T_RISK_REASON = 'CSM_Risk_Reason__c';
	public static final String OBJ_T_ACCOUNT = 'CSM_Account__c';
	public static final String OBJ_T_PLAY_TASK = 'CSM_Play_Task__c';
	public static final String OBJ_T_DESCRIPTION = 'Description';
	public static final String OBJ_T_OWNERID = 'OwnerId';
	public static final String OBJ_T_COMPLETED_DATE = 'CSM_Completed_Date__c';
	public static final String OBJ_T_ACCTPLAN = 'CSM_Account_Plan__c';
	public static final String OBJ_E_SUBJECT = 'Subject';
	public static final String OBJ_E_ACTIVITYDATE = 'ActivityDate';
	public static final String OBJ_E_ACCT_PLAN = 'CSM_Account_Plan__c';
	public static final String OBJ_T_PLAY_STATUS = 'CSM_Play_Status__c';
	public static final String OBJ_T_ACCTNAME = 'Account.Name';
	public static final String OBJ_T_REN_OPP = 'REN_Opportunity__c';
	public static final String OBJ_T_IS_CLOSED = 'IsClosed';
	public static final String OBJ_T_SUCCESS_PLAN_PLAY = 'CSM_SuccessPlan_Play__c';
	
	public static final String OBJ_SUCCESS_PLAN_PLAY = 'CSM_SuccessPlan_Play__c';
	public static final String OBJ_SPP_PLAYBOOK = 'CSM_SuccessPlan_Playbook__c';
	
	public static final String OBJ_SUCCESS_PLAN_PLAYBOOK = 'CSM_Account_Plan_Playbook__c';
	public static final String OBJ_SPPB_PLAYBOOK = 'CSM_Playbook__c';
	
		
	public static final String OBJ_PLAYBOOKPLAY = 'CSM_PlaybookPlay__c';
	public static final String OBJ_PBP_PLAY = 'CSM_Play__c';
	public static final String OBJ_PBP_PLAYBOOK = 'CSM_Playbook__c';
	public static final String OBJ_PBP_ID = 'Id';
	
	public static final String OBJ_PLAY = 'CSM_Play__c';
	public static final String OBJ_PLAY_ISACTIVE = 'CSM_IsActive__c';
	public static final String OBJ_PLAY_SHORTDESCRIPTION = 'CSM_Short_Description__c';
	public static final String OBJ_PLAY_AUTOMATED = 'CSM_Automated__c';
	public static final String OBJ_PLAY_AUTO_COMPLETED_AUTOMATED_TASK = 'CSM_Auto_Complete_Automated_Tasks__c';
	public static final String OBJ_PLAY_AUTO_DISMISS_AUTOMATED_TASK = 'CSM_Auto_Dismiss_Automated_Tasks__c';
	public static final String OBJ_PLAY_DISPLAY_NAME = 'CSM_Display_Name__c';
	public static final String OBJ_PLAY_DESCRIPTION = 'CSM_Play_Description__c';
	public static final String OBJ_PLAY_OBJECT_NAME = 'CSM_Object_Name__c';
	public static final String OBJ_PLAY_TASK_TOTAL = 'CSM_Task_Total__c';
	public static final String OBJ_PLAY_TOTAL_CLOSED = 'CSM_Number_of_closed_Plays__c';
	public static final String OBJ_PLAY_QUERY_CRIT = 'CSM_Query_Criteria__c';
	public static final String OBJ_PLAY_EXTERNAL_ID = 'CSM_External_Id__c';
	public static final String OBJ_PLAY_NAME = 'Name';
	public static final String OBJ_PLAY_ID = 'Id';
    public static final String OBJ_PLAY_FILTER_LOGIC = 'RLM_Filter_Logic__c';	
    public static final String OBJ_PLAY_ACTIVE_TASK_TOTAL = 'CSM_Active_Play_Task_Total__c';
    public static final String OBJ_PLAY_REENtry = 'CSM_Play_ReEntry__c';    
	
	public static final String OBJ_PLAY_CRIT = 'CSM_Play_Criteria__c';
	public static final String OBJ_PLAY_CRIT_DATE = 'RLM_Date_Value__c';
	public static final String OBJ_PLAY_CRIT_DATETIME = 'RLM_DateTime_Value__c';
	public static final String OBJ_PLAY_CRIT_NAME = 'RLM_Field_Name__c';
	public static final String OBJ_PLAY_CRIT_TYPE = 'RLM_Field_Type__c';
	public static final String OBJ_PLAY_CRIT_OPERATOR = 'RLM_Operator__c';
	public static final String OBJ_PLAY_CRIT_VALUE = 'RLM_Values__c';
	public static final String OBJ_PLAY_CRIT_PLAY = 'CSM_Play__c';
	public static final String OBJ_PLAY_CRIT_DISPLAY_NAME = 'RLM_Field_Display_Name__c';
	public static final String OBJ_PLAY_CRIT_IS_SPECIFIC_DATE = 'RLM_Is_Specific_Date__c';
	public static final String OBJ_PLAY_CRIT_DATE_LITERAL_NUMBER = 'RLM_Date_Literal_Number__c';
    public static final String OBJ_PLAY_CRIT_DATE_LITERAL_STRING = 'RLM_Date_Literal_String__c';
	
	
	public static final String OBJ_PLAY_TASK = 'CSM_Play_Task__c';
	public static final String OBJ_PLAY_TASK_ASSIGN = 'CSM_Assign_To__c';
	public static final String OBJ_PLAY_TASK_DAYS_DUE = 'CSM_Days_Until_Due__c';
	public static final String OBJ_PLAY_TASK_DESCRIPTION = 'CSM_Description__c';
	public static final String OBJ_PLAY_TASK_PLAY = 'CSM_Play__c';
	public static final String OBJ_PLAY_TASK_ACTIVE = 'CSM_IsActive__c';
	public static final String OBJ_PLAY_TASK_AUTOCOMPLETE = 'CSM_Auto_Complete_Automated_Tasks__c';
	public static final String OBJ_PLAY_TASK_AUTODISMISS = 'CSM_Auto_Dismiss_Automated_Tasks__c';
	public static final String OBJ_PLAY_TASK_TYPE = 'CSM_Type__c';
	
	public static final String ASSIGN_ACCOUNT_MANAGER = 'Account Manager';
	public static final String ASSIGN_ACCOUNT_OWNER = 'Account Owner';
	public static final String ASSIGN_SUPPORT_CONTACT = 'Support Contact';
	public static final String ASSIGN_RENEWAL_MANAGER = 'Renewal Manager';
	public static final String ASSIGN_RENEWAL_CONTACT = 'Renewal Contact';
	public static final String ASSIGN_CSM_MANAGER = 'CSM Manager';
	public static final String ASSIGN_CSM_CONTACT = 'CSM Contact';
	public static final String ASSIGN_CUSTOMER_SUCCESS_MANAGER = 'Customer Success Manager';
	public static final String ASSIGN_EXEC_SPONSOR = 'Exec Sponsor';
	
	//Opportunity Constants
	public static final String OBJ_OPPORTUNITY = 'Opportunity';
	public static final String OBJ_O_NAME = 'Name';
	public static final String OBJ_O_ID = 'Id';
	public static final String OBJ_O_CLOSE_DATE = 'CloseDate';
	public static final String OBJ_O_IS_CLOSED = 'IsClosed';
	public static final String OBJ_O_ACCOUNT_ID = 'AccountId';
	public static final String OBJ_O_IS_CLM_RENEWAL = 'REN_Is_CLM_Renewal__c';
	
	public static final String OBJ_TASK_PROCESSING = 'CSM_Task_Processing__c';
	public static final String OBJ_TASK_PROCESSING_TASK = 'CSM_Task_Id__c';
	//public static final String OBJ_TASK_PROCESSING_ACCOUNT_PLAN = 'CSM_Account_Plan__c';
	public static final String OBJ_TASK_PROCESSING_SUCCESS_PLAN = 'CSM_Success_Plan__c';
	public static final String OBJ_TASK_PROCESSING_PLAY = 'CSM_Play__c';
	public static final String OBJ_TASK_PROCESSING_PLAY_TASK = 'CSM_PlayTask__c';
	public static final String OBJ_TASK_PROCESSING_STATUS = 'CSM_Status__c';
	public static final String OBJ_TASK_PROCESSING_ID = 'Id';
	public static final String OBJ_TASK_PROCESSING_SUCCESS_PLAN_PLAY = 'CSM_Successplan_Play__c';
	

	//Activity History
	public static final String OBJ_ACTIVITY_HISTORY = 'ActivityHistory';
	public static final String OBJ_AH_IS_TASK = 'IsTask';
	public static final String OBJ_AH_END_DATE_TIME ='EndDateTime';
	public static final String OBJ_AH_OWNER_ID = 'OwnerId';	
	public static final String OBJ_AH_SUBJECT = 'Subject';
	public static final String OBJ_AH_TASK_STATE = 'CSM_Task_State__c';
	public static final String OBJ_AH_PLAY = 'CSM_Play__c';
	public static final String OBJ_AH_ACTIVITYDATE = 'ActivityDate';	
	public static final String OBJ_AH_COMPLETED_DATE = 'CSM_Completed_Date__c';
	public static final String OBJ_AH_PLAY_EXIT_DATE = 'CSM_Play_Exit_Date__c';
	
	
	public static final String OBJ_CONTACT = 'Contact';
	public static final String OBJ_CONTACT_FIRSTNAME = 'FirstName';
	public static final String OBJ_CONTACT_LASTNAME = 'LastName';
	public static final String OBJ_CONTACT_TITLE = 'Title';
	public static final String OBJ_CONTACT_PHONE = 'Phone';
	public static final String OBJ_CONTACT_CSM_RELATED = 'CSM_Related__c';
	public static final String OBJ_GROUPMEMBER = 'GroupMember';
	public static final String OBJ_EMAILTEMPLATE = 'EmailTemplate';
	
	//Account Constants
	public static final String OBJ_ACCOUNT = 'Account';
	public static final String OBJ_A_HEALTH_STATUS = 'CSM_Health_Status__c';
	public static final String OBJ_A_LAST_HEALTH_STATUS = 'CSM_Last_Health_Status__c';
	public static final String OBJ_A_ID = 'Id';
	public static final String OBJ_A_NAME = 'Name';
	public static final String OBJ_A_HEALTHY = 'Healthy';
	public static final String OBJ_A_LOW_ADOPTION = 'Low Adoption';
	public static final String OBJ_A_PENDING_CHURN = 'Pending Churn';
	public static final String OBJ_A_UNDETERMINED = 'Undetermined';
	public static final String OBJ_A_BILLINGCITY = 'BillingCity';
	public static final String OBJ_A_SA_CUST = 'ScoutAnalytics__CustomerInstanceCode__c';
	public static final String OBJ_A_SA_BUSINESS =  'ScoutAnalytics__Businessunit_did__c';
	public static final String OBJ_A_ANNUAL_REVENUE =  'AnnualRevenue';
	public static final String OBJ_A_OVERDUE_TASKS_COUNT =  'CSM_Overdue_Tasks_Count__c';	
	public static final String OBJ_A_HAS_ACCOUNT_PLAN =  'CSM_Account_Has_Success_Plan__c';	
	public static final String OBJ_A_PARENTID =  'ParentId';
	
	//Health Check Constants
	public static final String NO_HEALTH_CHECK = 'No Health Check';
	public static final String MORE_THAN_121 = 'More Than 121';
	public static final String BETWEEN_91_120 = 'Between 91 and 120';
	public static final String BETWEEN_61_90 = 'Between 61 and 90';
	public static final String BETWEEN_31_60 = 'Between 31 and 60';
	public static final String BETWEEN_0_30 = 'Between 0 and 30';
	public static final Integer INT_UNDETERMINED = 0;
	public static final Integer INT_CHURN_RISK = 1;
	public static final Integer INT_LOW_ADOPTION = 2;
	public static final Integer INT_HEALTHY = 3;
	public static final Integer INT_NO_HEALTH_CHECK = 0;
	public static final Integer INT_GREATER_121 = 1;
	public static final Integer INT_BETWEEN_91_120 = 2;
	public static final Integer INT_BETWEEN_61_90 = 3;
	public static final Integer INT_BETWEEN_31_60 = 4;
	public static final Integer INT_BETWEEN_0_30 = 5;
	
	public static final Integer PLAY_DESC_DISPLAY_COUNT = 300;
	
	//PlayResult constants
	public static final String NAME_AUTOMATED_TEMPLATE = 'AutomatedPlayDefault';
	public static final String OBJ_PR = 'CSM_Play_Result__c';
	public static final String OBJ_PR_ID = 'Id';
    public static final String OBJ_PR_ACCOUNT_ID = 'CSM_Account_Id__c';
    public static final String OBJ_PR_ASSIGNEE = 'CSM_Assignee__c';
    public static final String OBJ_PR_ENTER_DATE = 'CSM_Enter_Date__c';
    public static final String OBJ_PR_EXIT_DATE = 'CSM_Exit_Date__c';
    public static final String OBJ_PR_FAILED = 'CSM_Failed__c';
    public static final String OBJ_PR_FAILED_DESC = 'CSM_Failed_Description__c';
    public static final String OBJ_PR_PLAYBOOK_DESC = 'CSM_Playbook_Description__c';
    public static final String OBJ_PR_PLAYBOOK_EXT_ID = 'CSM_Playbook_External_Id__c';
    public static final String OBJ_PR_PLAYBOOK_NAME = 'CSM_Playbook_Name__c';
    public static final String OBJ_PR_PLAY_DESC = 'CSM_Play_Description__c';
    public static final String OBJ_PR_PLAY_EXT_ID = 'CSM_Play_External_Id__c';
    public static final String OBJ_PR_PLAY_NAME = 'CSM_Play_Name__c';
    public static final String OBJ_PR_PLAY_OBJECT = 'CSM_Play_Object__c';
    public static final String OBJ_PR_PLAYRESULT_ID = 'CSM_Play_Result_Id__c';
    public static final String OBJ_PR_PROCESSED = 'CSM_Processed__c';
    public static final String OBJ_PR_RES_STATUS = 'CSM_Resolution_Status__c';
    public static final String OBJ_PR_SUBSCRIPTION = 'CSM_Subscription_Id__c';
    public static final String OBJ_PR_STATUS_NUMBER =  'CSM_Status_Number__c';

    //ScoutAnalytics__Scout_Account_Custom_Fields__c constants
    public static final String OBJ_SA_SACF = 'ScoutAnalytics__Scout_Account_Custom_Fields__c';
    public static final String OBJ_SA_SREV_CUSTOMER = 'ScoutForSREV__Scout_Customer__c';
    public static final String OBJ_SA_SACF_ACCOUNT = 'ScoutAnalytics__Account__c';
    public static final String OBJ_APT_USEAS_SCOUT_DEF = 'CSM_UseasScout_Default_Template__c';
    public static final String OBJ_SA_SREV_CUSTOMER_REF_ID = 'ScoutForSREV__Customer_Reference_Id__c';
    
    //Added for US667 - Play trigger handler for Scout Customer object
    public static final String OBJ_SCOUT_SREV_CUSTOMER = 'Scout_Customer__c';
    public static final String OBJ_SCOUT_SREV_CUSTOMER_REF_ID = 'Customer_Reference_Id__c';
    
    //Survey Response object
    public static final String OBJ_RESPONSE = 'CSM_Survey_Response__c';
    public static final String OBJ_RESPONSE_OBJECT_ID = 'CSM_Object_Id__c';    
    public static final String OBJ_RID = 'Id';    

    //Account plan template clone constants
    public static final Integer ACCOUNT_PLAN_TEMPLATE_NAME_SIZE = 40;
    
    // flags constants
    public static final String ADMIN_HYPERLINK_FLAG = 'hlinks';
    
    //Help constants
    public static final String HELP_OVERVIEW = 'Overview';
    public static final String HELP_SUCCESS_PLAN_HOME = 'SuccessPlanHome';
    public static final String HELP_SUCCESS_PLAN_DETAILS = 'SuccessPlanDetails';
    public static final String HELP_FOCUS_CATEGORY_GROUPS = 'FocusCategoryGroups';
    public static final String HELP_FOCUS_CATEGORY_GROUPS_CREATE_EDIT = 'FocusCategoryGroups';
    public static final String HELP_FOCUS_CATEGORY_VIEWS = 'FocusCategoryViews';
    public static final String HELP_FOCUS_CATEGORIES = 'FocusCategories';
    public static final String HELP_ORGANIZE_FOCUS_CATEGORIES = 'organize-focus-categories';
    public static final String HELP_INDICATOR_GROUPS = 'IndicatorGroups';
    public static final String HELP_SUCCESS_PLAN_TEMPLATES = 'SuccessPlanTemplates';
    public static final String HELP_SUCCESS_PLAN_TEMPLATES_EDIT = 'SuccessPlanTemplatesEdit';
    public static final String HELP_PLAYBOOKS = 'Playbooks';
    public static final String HELP_CREATE_EDIT_PLAYBOOKS_PLAYS = 'PlaybooksPlay';
    public static final String HELP_PLAYS = 'Plays';
    public static final String HELP_DATA_GENERATION = 'DataGeneration';
    public static final String HELP_SUCCESS_TASKS = 'SuccessTasks';
    public static final String HELP_PLAY_CRITERIA = 'PlayCriteria';
    public static final String HELP_PLAY_TASK = 'PlayTask';
    public static final String HELP_TASK_COMPLETE = 'TaskComplete';
    public static final String HELP_TASK_DISMISS = 'TaskDismiss';
    public static final String HELP_HEALTH_DONUT = 'HealthDonut';
    public static final String HELP_HEALTH_MAP = 'HealthMap';
    public static final String HELP_PLAN_DETAILS_SUBTAB = 'PlanDetails';
    public static final String HELP_SUCCESS_PLAN_TEMPLATE_PHASES = 'SuccessPlanTemplatePhases';
    public static final String HELP_SUCCESS_PLAN_TEMPLATE_PLAYBOOKS = 'SuccessPlanTemplatePlaybooks';
    public static final String HELP_SUCCESS_PLAN_TEMPLATE_INDICATORS = 'SuccessPlanTemplateIndicators';
    public static final String HELP_ADMIN_TAB = 'AdminTab';
    public static final String HELP_SEGMENT_DETAIL = 'segmentation';
    public static final String HELP_SEARCH_AND_MOVE_DETAIL = 'searchandmove';
    public static final String HELP_BATCH_FILTER_ACTIVITY = 'batchfilteractivity';
    public static final String HELP_MULTI_SELECT_REPORTING = 'multiselectreporting';
    public static final String HELP_CONSOLIDATION_REQUEST_LOGS = 'consolidationrequestlogs';
    public static final String HELP_OPPORTUNITY_GENERATION = 'opportunitygeneration';
    public static final String HELP_OPPORTUNITY_UPDATES = 'opportunityupdates';
    public static final String HELP_MAPPINGS = 'mappings';
    public static final String HELP_MAPPINGS_ADD_FIELD = 'mappingsaddfield';
    public static final String HELP_CHANNEL_PORTAL_CONFIGURATION = 'channelportalconfiguration';
    public static final String HELP_RENEWAL_PARTNER_DATA_SYNC = 'renewalpartnerdatasync ';
    public static final String HELP_CONSOLIDATE_OPPORTUNITY = 'consolidateopportunity ';
    public static final String HELP_AUTOMATED_GENERATION_LOG = 'automatedgenerationlog ';
    public static final String HELP_BATCH_GENERATION_ACTIVITY = 'batchgenerationactivity ';
    public static final String HELP_TASK_GENERATION_ACTIVITY = 'taskgenerationactivity ';
    public static final String HELP_INSTALL_BASE_DATA_RULE = 'installbasedatarules ';
    public static final String HELP_LOW_TOUCH = 'lowtouch ';
    public static final String HELP_QUOTE_REQUEST_LOG = 'quoterequestlog ';
    
    // OpportunityLineItem
    public static final String OBJ_OPPORTUNITY_LINE_ITEM = 'OpportunityLineItem';
    // REN Related List
    public static final String OBJ_REN_RELATED_LIST = 'REN_Related_List__c';
    // product2 
    public static final String OBJ_PRODUCT2 ='Product2';
    //Line Criteria
    public static final String OBJ_LINE_CRITERIA ='REN_Line_Criteria__c';
    
    
    public static final String OBJ_CHART_MGMT = 'CSM_Chart_Management__c';
    public static final String OBJ_CHART_MGMT_COLOR_1_LABEL = 'CSM_Color_1_Label__c';
    public static final String OBJ_CHART_MGMT_COLOR_1_VALUE = 'CSM_Color_1_Value__c';
    public static final String OBJ_CHART_MGMT_COLOR_2_LABEL = 'CSM_Color_2_Label__c';
    public static final String OBJ_CHART_MGMT_COLOR_2_VALUE = 'CSM_Color_2_Value__c';
    public static final String OBJ_CHART_MGMT_COLOR_3_LABEL = 'CSM_Color_3_Label__c';
    public static final String OBJ_CHART_MGMT_COLOR_3_VALUE = 'CSM_Color_3_Value__c';
    public static final String OBJ_CHART_MGMT_COLOR_RANGE = 'CSM_Color_Range__c';
    public static final String OBJ_CHART_MGMT_COLOR_SORT_RANGE = 'CSM_Color_Sort_Range__c';
    public static final String OBJ_CHART_MGMT_DISPLAY_COLOR_FIELDS = 'CSM_Display_Color_Fields__c';
    public static final String OBJ_CHART_MGMT_DISPLAY_COLOR_RANGE = 'CSM_Display_Color_Range__c';
    public static final String OBJ_CHART_MGMT_DISPLAY_RANGE = 'CSM_Display_Range__c';
    public static final String OBJ_CHART_MGMT_FIELD_1_LABEL = 'CSM_Field_1_Label__c';
    public static final String OBJ_CHART_MGMT_FIELD_1_TYPE = 'CSM_Field_1_Type__c';
    public static final String OBJ_CHART_MGMT_FIELD_1_VALUE = 'CSM_Field_1_Value__c';
    public static final String OBJ_CHART_MGMT_FIELD_1_DISPLAY = 'CSM_Field_1_Display__c';
    public static final String OBJ_CHART_MGMT_FIELD_2_LABEL = 'CSM_Field_2_Label__c';
    public static final String OBJ_CHART_MGMT_FIELD_2_TYPE = 'CSM_Field_2_Type__c';
    public static final String OBJ_CHART_MGMT_FIELD_2_VALUE = 'CSM_Field_2_Value__c';
    public static final String OBJ_CHART_MGMT_FIELD_2_DISPLAY = 'CSM_Field_2_Display__c';
    public static final String OBJ_CHART_MGMT_FIELD_3_LABEL = 'CSM_Field_3_Label__c';
    public static final String OBJ_CHART_MGMT_FIELD_3_TYPE = 'CSM_Field_3_Type__c';
    public static final String OBJ_CHART_MGMT_FIELD_3_VALUE = 'CSM_Field_3_Value__c';
    public static final String OBJ_CHART_MGMT_FIELD_3_DISPLAY = 'CSM_Field_3_Display__c';
    public static final String OBJ_CHART_MGMT_FIELD_4_LABEL = 'CSM_Field_4_Label__c';
    public static final String OBJ_CHART_MGMT_FIELD_4_TYPE = 'CSM_Field_4_Type__c';
    public static final String OBJ_CHART_MGMT_FIELD_4_VALUE = 'CSM_Field_4_Value__c';
    public static final String OBJ_CHART_MGMT_FIELD_4_DISPLAY = 'CSM_Field_4_Display__c';
    public static final String OBJ_CHART_MGMT_MODULE_TYPE = 'CSM_Module_Type__c';
    public static final String OBJ_CHART_MGMT_OBJECT_LABEL = 'CSM_Object_Label__c';
    public static final String OBJ_CHART_MGMT_OBJECT_NAME = 'CSM_Object_Name__c';
    public static final String OBJ_CHART_MGMT_OBJECT_TYPE = 'CSM_Object_Type__c';
    public static final String OBJ_CHART_MGMT_RANGE_1_FROM_VALUE = 'CSM_Range_1_From_Value__c';
    public static final String OBJ_CHART_MGMT_RANGE_1_LABEL = 'CSM_Range_1_Label__c';
    public static final String OBJ_CHART_MGMT_RANGE_1_TO_VALUE = 'CSM_Range_1_To_Value__c'; 
    public static final String OBJ_CHART_MGMT_RANGE_2_FROM_VALUE = 'CSM_Range_2_From_Value__c';
    public static final String OBJ_CHART_MGMT_RANGE_2_LABEL = 'CSM_Range_2_Label__c';
    public static final String OBJ_CHART_MGMT_RANGE_2_TO_VALUE = 'CSM_Range_2_To_Value__c';
    public static final String OBJ_CHART_MGMT_RANGE_3_FROM_VALUE = 'CSM_Range_3_From_Value__c';
    public static final String OBJ_CHART_MGMT_RANGE_3_LABEL = 'CSM_Range_3_Label__c';
    public static final String OBJ_CHART_MGMT_RANGE_3_TO_VALUE = 'CSM_Range_3_To_Value__c';
    public static final String OBJ_CHART_MGMT_RANGE_4_FROM_VALUE = 'CSM_Range_4_From_Value__c';
    public static final String OBJ_CHART_MGMT_RANGE_4_LABEL = 'CSM_Range_4_Label__c';
    public static final String OBJ_CHART_MGMT_RANGE_4_TO_VALUE = 'CSM_Range_4_To_Value__c';
    public static final String OBJ_CHART_MGMT_RANGE_5_FROM_VALUE = 'CSM_Range_5_From_Value__c';
    public static final String OBJ_CHART_MGMT_RANGE_5_LABEL = 'CSM_Range_5_Label__c';
    public static final String OBJ_CHART_MGMT_RANGE_5_TO_VALUE = 'CSM_Range_5_To_Value__c';
    public static final String OBJ_CHART_MGMT_RANGE_6_FROM_VALUE = 'CSM_Range_6_From_Value__c';
    public static final String OBJ_CHART_MGMT_RANGE_6_LABEL = 'CSM_Range_6_Label__c';
    public static final String OBJ_CHART_MGMT_RANGE_6_TO_VALUE = 'CSM_Range_6_To_Value__c';
    public static final String OBJ_CHART_MGMT_SOQL_QUERY = 'CSM_Soql_Query__c';
    public static final String OBJ_CHART_MGMT_DISPLAY_NAME = 'CSM_Display_Name__c';
    public static final String OBJ_CHART_MGMT_ADMIN_LIST_DISPLAY = 'CSM_Admin_List_Display__c'; 
    
    public static final String FIELD1 = 'Field1';
    public static final String FIELD2 = 'Field2'; 
    public static final String FIELD3 = 'Field3';
    public static final String TASK_FILTER_OPTION_ALL = 'All';
	public static final String TASK_FILTER_OPTION_CONT_TASKS = 'Meeting Tasks';
	public static final String TASK_FILTER_OPTION_OTHER_TASKS = 'Other Tasks';
	public static final String TASK_FILTER_OPTION_EMAIL_TASKS = 'Email Tasks';
	public static final String TASK_FILTER_OPTION_PC_TASKS = 'Phone Call Tasks';
	public static final String TASK_FILTER_OPTION_RT_ACCOUNT = 'Related To Account';
	public static final String TASK_FILTER_OPTION_RT_OPPORTUNITY = 'Related To Opportunity';
	public static final String TASK_FILTER_OPTION_HASPLAY = 'Has Play';
	public static final String TASK_FILTER_OPTION_UNDETERMINEDPLAY = 'Undetermined Play';
	public static final String TASK_FILTER_OPTION_ASSIGNED_TO = 'Assigned To';
	public static final String TASK_FILTER_OPTION_PLAY = 'Play';
	public static final String TASK_FILTER_OPTION_PLAYBOOK = 'Playbook';
	public static final String TASK_FILTER_OPTION_TASK_TYPE = 'Task Type';
	public static final String TASK_FILTER_OPTION_RELATED_TO = 'Related To';
	public static final String TASK_FILTER_OPTION_RECORD_TYPE = 'Record Type';
    														
    public static final String SORT_DIRECTION_ASCENDING = 'ASC';
    public static final String SORT_DIRECTION_DESCENDING = 'DESC';
    
    public static final String OBJ_CASE = 'Case';
    public static final String OBJ_CASE_CASENUMBER = 'CaseNumber';
    public static final String OBJ_CONTRACT = 'Contract';
    public static final String CONTRACT_NUMBER = 'ContractNumber';
    
    //User Preferences fields
    public static final String OBJ_UP = 'CSM_User_Preferences__c'; 
    public static final String OBJ_UP_USER = 'CSM_User__c';
    public static final String OBJ_UP_HIDE_OVERVIEW_CHARTS = 'CSM_Hide_Overview_Charts__c';
    public static final String OBJ_UP_HIDE_INACTIVE_CATEGORIES = 'CSM_Hide_Inactive_Categories__c';
    
    public static final String OBJ_UP_FIELD_FILTER = 'CSM_Object_Field_Filter__c';
    public static final String OBJ_UP_FIELD_FILTER_USER = 'CSM_Object_Field_Filter_User__c';
    public static final String OBJ_UP_FIELD_FILTER_VALUE = 'CSM_Object_Field_Filter_Value__c';
    public static final String OBJ_UP_FIELD_FILTER_DATE_VALUE = 'CSM_Object_Field_Date_Value__c';
    public static final String OBJ_UP_FILTER = 'CSM_Object_Filter__c'; 
    public static final String OBJ_UP_FIELD_LOOKUP_USER = 'UserLookupField';
    public static final String OBJ_UP_FIELD_DATE = 'UserDateField';
    public static final String OBJ_UP_FILTER_DISPLAY_NAME = 'CSM_Filter_Display_Name__c';  
    public static final String NULL_PARAM = 'null'; 
    
    public static final String OBJ_UP_OVERVIEW_CAROUSEL_CHART = 'CSM_Overview_Carousel_Chart__c';            
    public static final String OBJ_UP_OVERVIEW_FCGROUP_FILTER = 'CSM_Overview_FC_Group_Filter__c';
    public static final String OBJ_UP_SP_ACTION_FILTER = 'CSM_Success_Plan_Actions_Filter__c';        
    public static final String OBJ_UP_SP_ACTION_GRID_COLUMNS = 'CSM_Success_Plan_Actions_Grid_Columns__c';    
    public static final String OBJ_UP_SP_ACTIVITY_GRID_COLUMNS = 'CSM_Success_Plan_Activity_Grid_Columns__c';
    public static final String OBJ_UP_ST_ACTION_FILTER = 'CSM_Success_Task_Filter__c';        
    public static final String OBJ_UP_ST_ACTION_GRID_COLUMNS = 'CSM_Success_Task_Grid_Columns__c';    
        
    
    //Case Status fields - for SF285 & 295
    public static final string OBJ_CASE_STATUS_CLOSED = 'Closed';
    public static final string OBJ_CASE_STATUS_NEW = 'New';
    public static final string OBJ_CASE_STATUS_WORKING = 'Working';
    public static final string OBJ_CASE_PRIORITY_HIGH = 'High';
    public static final string OBJ_A_NUMBER_OF_CASES = 'CSM_Number_of_Cases__c';
    public static final string OBJ_A_WORKING_CASES = 'CSM_Number_of_Working_Cases__c';
    public static final string OBJ_A_NEW_CASES = 'CSM_Number_of_New_Cases__c';
    public static final string OBJ_A_HIGH_CASES = 'CSM_Number_of_Open_High_Priority_Cases__c';
    public static final string OBJ_A_CLOSED_CASES = 'CSM_Number_of_Closed_Cases__c';
    public static final string OBJ_A_AVERAGE_SLA_CASES = 'CSM_Average_SLA_Response_Time__c';
    public static final string OBJ_A_OLDEST_CASES = 'CSM_Oldest_Open_Case__c';
    public static final string OBJ_CASE_ID = 'Id';
    public static final string OBJ_CASE_ACC_ID = 'AccountId';
    public static final string OBJ_CASE_DiffOf_Creation_Closed_Date = 'CSM_DiffOf_Creation_Closed_Dates__c';
    public static final string OBJ_CASE_PRIORITY = 'Priority';
    public static final string OBJ_CASE_STATUS = 'Status';
    
    public static final String OBJ_PRODUCT = 'Product2';
    public static final String OBJ_PRODUCT_PF = 'Family';
    public static final String OBJ_PRODUCT_PD = 'Description';
    public static final String OBJ_PRODUCT_PC = 'ProductCode';
    public static final String OBJ_PRODUCT_ISACTIVE = 'IsActive';
    
    public static final String CSM_EMAIL = 'Email';
    public static final String OBJ_USER = 'User';
    
    //OpportunityContactRole
    public static final String OBJ_OCR = 'OpportunityContactRole';
    public static final String OBJ_OCR_ID = 'Id';
    public static final String OBJ_OCR_ROLE = 'Role';
    public static final String OBJ_OCR_OPP_ID = 'OpportunityId';
    public static final String OBJ_OCR_IS_PRIMARY = 'IsPrimary';
    public static final String OBJ_OCR_CONTACT_ID =  'ContactId';
    
    //OpportunityCompetitor
    public static final String OBJ_OC = 'OpportunityCompetitor';
    public static final String OBJ_OC_WEAKNESSES = 'Weaknesses';
    public static final String OBJ_OC_STRENGTHS = 'Strengths';
    public static final String OBJ_OC_OPP_ID = 'OpportunityId';
    public static final String OBJ_OC_COMP_NAME = 'CompetitorName';
    
    //OpportunityPartner
    public static final String OBJ_OP = 'OpportunityPartner';
    public static final String OBJ_OP_ROLE = 'Role';
    public static final String OBJ_OP_REV_PART_ID = 'ReversePartnerId';
    public static final String OBJ_OP_OPP_ID = 'OpportunityId';
    public static final String OBJ_OP_IS_PRIMARY = 'IsPrimary';
    public static final String OBJ_OP_ID = 'Id';
    public static final String OBJ_OP_ACCOUNT_TO_ID = 'AccountToId';
    
    //Partner
    public static final String OBJ_PARTNER = 'Partner';
    public static final String OBJ_P_ACCOUNT_TO_ID = 'AccountToId';
    public static final String OBJ_P_ACCOUNT_FROM_ID = 'AccountFromId';
    public static final String OBJ_P_IS_PRIMARY = 'IsPrimary';
    public static final String OBJ_P_OPP_ID = 'OpportunityId';
    public static final String OBJ_P_ROLE = 'Role';
    
    //CSM_Play_Result_History__c
    public static final String OBJ_PRH = 'CSM_Play_Result_History__c';
    public static final String OBJ_PRH_ACCOUNT_ID = 'CSM_Account_Id__c';
    public static final String OBJ_PRH_ASSIGNEE = 'CSM_Assignee__c';
    public static final String OBJ_PRH_ENTER_DATE = 'CSM_Enter_Date__c';
    public static final String OBJ_PRH_EXIT_DATE = 'CSM_Exit_Date__c';
    public static final String OBJ_PRH_FAILED = 'CSM_Failed__c';
    public static final String OBJ_PRH_FAILED_DESC = 'CSM_Failed_Description__c';            
    public static final String OBJ_PRH_PLAYBOOK_DESC = 'CSM_Playbook_Description__c';
    public static final String OBJ_PRH_PLAYBOOK_EXT_ID = 'CSM_Playbook_External_Id__c';
    public static final String OBJ_PRH_PLAYBOOK_NAME = 'CSM_Playbook_Name__c';
    public static final String OBJ_PRH_PLAY_DESC = 'CSM_Play_Description__c';
    public static final String OBJ_PRH_PLAY_EXT_ID = 'CSM_Play_External_Id__c';          
    public static final String OBJ_PRH_PLAY_NAME = 'CSM_Play_Name__c';
    public static final String OBJ_PRH_PLAY_OBJECT = 'CSM_Play_Object__c';
    public static final String OBJ_PRH_PLAY_RESULT = 'CSM_Play_Result_Id__c';
    public static final String OBJ_PRH_PROCESSED = 'CSM_Processed__c';
    public static final String OBJ_PRH_RES_STATUS = 'CSM_Resolution_Status__c';
    public static final String OBJ_PRH_SUBSCRIPTION = 'CSM_Subscription_Id__c';
         
    //CSM_Batch_Result__c
    public static final String OBJ_BR = 'CSM_Batch_Result__c';
    public static final String OBJ_BR_STATUS = 'CSM_Status__c';
    public static final String OBJ_BR_COMPLETION_TIME = 'CSM_Batch_Completion_Time__c';
    public static final String OBJ_BR_START_TIME = 'CSM_Batch_Start_Time__c';
    public static final String OBJ_BR_MODULE =  'CSM_Module__c';
    public static final String OBJ_BR_OBJECTS_PROCESSED = 'CSM_Objects_Processed__c';
    public static final String OBJ_BR_ID = 'CSM_BatchId__c';
    public static final String OBJ_BR_ERROR_DESC = 'CSM_Error_Description__c';
    public static final String OBJ_BR_ERROR = 'CSM_Errors__c';
    public static final String OBJ_BR_RECORDS = 'CSM_Records_Processed__c';
	public static final String OBJ_BR_SEGMENTS = 'REN_Segment_Names__c';
    
    //User Record Access
    public static final String OBJ_URA_READ = 'UserRecordAccess.HasReadAccess';
    public static final String OBJ_URA_EDIT = 'UserRecordAccess.HasEditAccess';
    
    //Page Name
    public static final String CSM_PLAYLIST_PG = 'csm_playslist';
    
    //Batch Success Plan Defaults
    public static final String CSM_BPD_PLANDEFAULTNAME = 'CSM_Plan_Default_Name__c';
    public static final String OBJ_BAT_PLAN_DEFAULT = 'CSM_Batch_Success_Plan_Default__c';
    
    public static final String CSM_PTA = 'CSM_PTA';
    
    //Grid Attribute Constants
    public static final String GRID_ATTR_TASK_GRID = 'taskGrid';
    public static final String GRID_ATTR_TOOLBAR = 'grid-toolbar';
    public static final String GRID_ATTR_TRUE = 'true';
    public static final String GRID_ATTR_FALSE = 'false';
    public static final String GRID_ATTR_ACCT_ACTIVITY = 'accountActivity';
    public static final String GRID_ATTR_ACT_HISTORY = 'activityhistory';
    public static final String GRID_ATTR_ACT_TAB = 'actionTab';
    public static final String GRID_ATTR_ACT_SP_GRID = 'actionSpGrid';
    public static final String GRID_ATTR_SERV_CONTRACTS = 'serviceContracts';
    public static final String GRID_ATTR_SERVICE_CONTRACTS = 'ServiceContracts';
    public static final String GRID_ATTR_PLAYBOOK_TOOLBAR = 'playbook-grid-toolbar';
    public static final String GRID_ATTR_PLAYBOOK_SP = 'playbookSPGrid';
    public static final String GRID_ATTR_SUCCESS_PLAN_DETAIL = 'SuccessPlanDetail';
    public static final String GRID_ATTR_OPP_SP = 'opportunitySPGrid';
    public static final String GRID_ATTR_OPP_TOOLBAR = 'opportunity-grid-toolbar';
    public static final String GRID_ATTR_CONT_LINE_ITEM = 'ContractLineItem';
    
    public static final String GRID_ATTR_HEALTH_STATUS_TOOLBAR = 'healthStatus-toolbar';
    public static final String GRID_ATTR_HEALTH_STATUS_VIEW = 'HealthStatus';
    public static final String GRID_ATTR_HEALTH_STATUS_TBL = 'healthStatus';
    
    public static final String GRID_ATTR_FC_FULL_LIST_VIEW = 'FCFullList';
    public static final String GRID_ATTR_FC_FULL_LIST_TBL = 'fcFullList';
    
    public static final String GRID_ATTR_OBJ_FILTER_TBL = 'CSMObjectfilterWidget';
    public static final String GRID_ATTR_OBJ_FILTER_OBJ_TYPE = 'BatchPTAWidget';
    public static final String GRID_ATTR_FILTER_TOOLBAR = 'filter-grid-toolbar';
    public static final String GRID_ATTR_PLAN_DEFAULT_TBL =  'planDefault';
    public static final String GRID_ATTR_PLAN_DEFAULT_OBJ_TYPE = 'planDefaultObj';
    public static final String GRID_ATTR_PLAN_DEFAULT_VIEW = 'SuccessPlanDefault';
    public static final String GRID_ATTR_GROUP_TOOLBAR = 'group-grid-toolbar';
    
    public static final String GRID_ATTR_BATCH_HISTORY = 'batchHistory';
    public static final String GRID_ATTR_BATCH_SP_HISTORY = 'BatchSuccessPlanHistory';
    
    public static final String GRID_ATTR_FILTER_WIDGET = 'filterWidget';
    public static final String GRID_ATTR_BATCH_OPP_GEN_OBJ_TYPE = 'BatchOppGenWidget';
    public static final String GRID_ATTR_FILTER = 'Filter';
    public static final String GRID_ATTR_GROUP_WIDGET = 'groupWidget';
    public static final String GRID_ATTR_GROUPING = 'Grouping';
    
    public static final String GRID_ATTR_BATCH_FAILED_TBL = 'batchJobFailedSummary';
    public static final String GRID_ATTR_BATCH_FAILED_VIEW = 'BatchJobFailedSummary';
    public static final String GRID_ATTR_BATCH_FAILED_OBJ_TYPE ='BatchOppGenFailedSummary';
    
    public static final String GRID_ATTR_BATCH_OPP_GEN_SUMM_TBL = 'batchJobSummary';
    public static final String GRID_ATTR_BATCH_OPP_GEN_SUMM_OBJ_TYPE = 'BatchOppGenSummary';
    public static final String GRID_ATTR_BATCH_OPP_GEN_SUMM_VIEW_NAME = 'BatchJobSummary';
    
    public static final String GRID_ATTR_ASSET_VIEW = 'AssetView';
    public static final String GRID_ATTR_RENEWAL_RELATIONSHIP_OBJ_TYPE = 'RenewalRelationship';
    public static final String GRID_ATTR_RENEWAL_RELATIONSHIP_TABLE_NAME = 'renewalRelationshipGrid';
    
    public static final String GRID_ATTR_SEARCH_ADD = 'searchAndAdd';
    public static final String CSM_FLD_REC_TYPE = 'CSM_Record_Type__c';
    public static final String OBJ_RECORD_TYPE = 'RecordTypeId';
    public static final String GRID_ATTR_CONSOLIDATE = 'consolidate';
    
    public static final String STR_FROM_REVENUE_ANALYTICS = 'From Revenue Analytics';
    public static final String STR_FROM_TEMPLATE = 'From Template';
    public static final String STR_MANUAL_ADD = 'Manual Add';
    
    public static final String GRID_ATTR_SUCC_PLAN_PLAY = 'successPlanPlayGrid';
	public static final String GRID_ATTR_TYPE_SUCC_PLAN_PLAY = 'SuccessPlanPlay';
	public static final String OBJ_PLAY_REL_DISPLAY_NAME = 'CSM_Play__r.CSM_Display_Name__c';
    public static final String OBJ_PLAYBOOK_PLAY = 'CSM_Playbook_Play__c';
    public static final String OBJ_REL_PLAYBOOK_DISP_NAME = 'CSM_Playbook_Play__r.CSM_Playbook__r.CSM_Display_Name__c';
    public static final String OBJ_FLD_PLAY_OUTCOME = 'CSM_Play_Outcome__c';
    public static final String OBJ_FLD_SRC = 'CSM_Source__c';
    public static final String OBJ_FLD_REL_PLAY_DESC = 'CSM_Play__r.CSM_Short_Description__c';
    public static final String OBJ_FLD_TOTL_TASKS = 'CSM_Total_number_of_Tasks__c';
    public static final String OBJ_FLD_TOTL_CLOSED_TASKS = 'CSM_Number_of_Closed_Tasks__c';
    public static final String OBJ_FLD_REL_PLAY_ISACTIVE = 'CSM_Play__r.CSM_IsActive__c';
    public static final String OBJ_SUCC_PLAN_PLAY = 'CSM_SuccessPlan_Play__c';
    public static final String PBJ_FLD_PLAYBOOK_REL_NAME = 'CSM_Playbook__r.CSM_Display_Name__c';
    public static final String OBJ_FLD_PLAYBOOK_REL_SHRTDESC = 'CSM_Playbook__r.CSM_Short_Description__c';
    public static final String OBJ_FLD_TOTL_NO_PLAYS = 'CSM_Total_number_of_Plays__c';
    public static final String OBJ_FLD_PLAYBOOK_REL_AUTO = 'CSM_Playbook__r.CSM_Automated__c';
    public static final String OBJ_FLD_PLAYBOOK_REL_ACTIVE = 'CSM_Playbook__r.CSM_IsActive__c';
    public static final String OBJ_FLD_EVALUATION_DATE = 'CSM_Evaluation_Date__c';
    
    public static final String OBJ_UP_ATTRIB = 'CSM_User_Preference_Attribute__c';
    
    //Batch Filter object
    public static final String OBJ_BF = 'CSM_Batch_Filter__c';			
	public static final String OBJ_BF_NAME = 'Name';
	public static final String OBJ_BF_IS_ACTIVE = 'CSM_IsActive__c';
	public static final String OBJ_BF_BATCH_JOB_NAME = 'CSM_Batch_Job_Name__c';
	public static final String OBJ_BF_CURRENCY_CODE = 'RLM_Currency_Code__c';
	public static final String OBJ_BF_DESCRIPTION = 'CSM_Description__c';
	public static final String OBJ_BF_DISPLAY_NAME = 'CSM_Display_Name__c';
	public static final String OBJ_BF_END_BOUNDARY_CRITERIA = 'CSM_End_Boundary_Criteria__c';
	public static final String OBJ_BF_FILTER_LOGIC = 'RLM_Filter_Logic__c';
	public static final String OBJ_BF_OBJECT_NAME = 'CSM_Object_Name__c';
	public static final String OBJ_BF_QUERY_CRITERIA = 'CSM_Query_Criteria__c';
	public static final String OBJ_BF_CREATED_BY_NAME = 'CreatedBy.Name';
	public static final String OBJ_BF_CREATED_DATE = 'CreatedDate';
	public static final String OBJ_BF_LAST_MODIFIED_BY_NAME = 'LastModifiedBy.Name';
	public static final String OBJ_BF_LAST_MODIFIED_DATE = 'LastModifiedDate';
	
	//Batch Filter Criteria object
	public static final String OBJ_BATCH_FILTER_CRITERIA = 'CSM_Batch_Filter_Criteria__c';	
	//testing
	
	//Added constants for Restrict visibility section to Focus category setup functionality
	public static final String STR_ALL_PRTR_USERS = 'AllPartnerUsers';
	public static final String STR_ALL_INTERNAL_USERS = 'AllInternalUsers';
	public static final String STR_ALL_CUST_PORT_USERS = 'AllCustomerPortalUsers';
	public static final String STR_VISI_ONLY_ME = 'Visible To Me';
	public static final String STR_VISI_ALL_USERS = 'Visible To All';
	public static final String STR_VISI_CERTAIN_GRP_USERS = 'Visible To Specific Persons';
	public static final String STR_PUBLIC_GROUP = 'Public Groups';
	public static final String STR_ROLES = 'Roles';
	public static final String STR_USERS = 'Users';	
	public static final String STR_ROLES_WITH_SUBORD = 'Roles & Internal Subordinates';
	public static final String STR_PRM_ORG = 'PRMOrganization';
	public static final String STR_ORG = 'Organization';
	public static final String STR_REGULAR = 'Regular';
	public static final String STR_ALL_CUST_PORTAL = 'AllCustomerPortal';
	
	public static final String STR_PARTNER_SYNCING = 'Partner Syncing';
	public static final String STR_NONE = 'None';
	
	//Dummy products added for Simplified Data Model
    public static final String STR_RENEWAL_AMOUNT_PRODUCT = 'Renewal Amount';
    public static final String STR_ADDS_AMOUNT_PRODUCT = 'Adds Amount';
}