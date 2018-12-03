/**
    * @author    	Eswar Bala (eswar@comitydesigns.com)   
    * @date         May 18, 2016
    * @description  TriggerManager - Generic Manager to dispatch trigger execution flow
*/
global with sharing class Constants {
    //FLS check constants 
    public static final String DML_OPERATION_UPSERT = 'Upsert';
    public static final String DML_OPERATION_INSERT = 'Insert'; 
    public static final String DML_OPERATION_UPDATE = 'Update';
    public static final String DML_OPERATION_DELETE = 'Delete';
    public static final String DML_OPERATION_READ = 'Read';
    
    //Data Type
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
    
    //Trigger
    public static Boolean CASE_BEFORE_INSERT_TRIGGER = true;
    public static Boolean CASE_BEFORE_UPDATE_TRIGGER = true;

    public static Boolean CASE_AFTER_UPDATE_TRIGGER = true; 
    
	public static Boolean PEER_REVIEW_BEFORE_UPDATE_TRIGGER = true; 

    public static Boolean PROACTIVE_RULE_LINE_ITEM_BEFORE_UPDATE_TRIGGER = true; 
    public static Boolean PROACTIVE_RULE_LINE_ITEM_AFTER_UPDATE_TRIGGER = true; 

    public static Boolean PROACTIVE_RULE_BEFORE_UPDATE_TRIGGER = true; 
    public static Boolean PROACTIVE_RULE_AFTER_UPDATE_TRIGGER = true; 

    public static Boolean USER_AFTER_UPDATE_TRIGGER = true; 

    public static final String TYPE_LOOKUP = 'LOOKUP';
    public static final String OBJ_SC_TOTAL_PRICE = 'TotalPrice';
    
    public static final String CRM_USER = 'CRM User';
   
    public static final String PROACTIVE =  'Proactive';
    
    public static final String STAGE_NoService = 'No Service';
    public static final String STAGE_HouseAccount = 'House Account';
    public static final String STAGE_ClosedSale = 'Closed Sale';
    
    
    public static final String CONTRACT_ID = 'contractid';
	public static final String CURRENCY_ISO_CD = 'CurrencyIsoCode';
	public static final String INVALID_OBJECT_NAME = 'Invalid Object Name';
    
    //Object Name
    public static final String OBJ_CASE = 'Case';
    public static final String OBJ_CONTACT = 'Contact';
 	public static final String OBJ_QUOTE = 'Quote';
    public static final String OBJ_QUOTE_LI = 'QuoteLineItem';
	public static final String OBJ_OPERATIONS_TARGET = 'Operations_Target__c';
 	public static final String OBJ_PROACTIVE_CASE_SETUP = 'Proactive_Case_Setup__c';
 	public static final String OBJ_PROACTIVE_RULE_LI = 'Proactive_Rule_Line_Item__c';
 	public static final String OBJ_PROACTIVE_RULE = 'Proactive_Rule__c';
 	public static final String OBJ_OPERATIONS_TARGET_LI = 'Operations_Target_Line_Item__c';
    public static final String OBJ_SALES_TARGET = 'Sales_Target__c';
    public static final String OBJ_SALES_TARGET_LI = 'Sales_Target_Line_Item__c';
    public static final String OBJ_PERIOD = 'Period__c';
    
    //Quote's Fields
    public static final String QUOTE_REVIEW_STATUS = 'Review_Status__c';
    public static final String QUOTE_EARLIEST_START_DT = 'CLM_Earliest_Start_Date__c';
    public static final String QUOTE_LATEST_END_DT = 'CLM_Latest_End_Date__c';
    public static final String QUOTE_TYPE_YEAR = 'Quote_Type_Year__c';
    public static final String QUOTE_ERROR_CATEGORY = 'Error_Category__c';
    public static final String QUOTE_CASE = 'Case__c';
    public static final String QUOTE_LOCAL_CURR_CODE = 'Local_Currency_Code__c';
    public static final String QUOTE_OPPORTUNITY_ID = 'OpportunityId';
    public static final String QUOTE_LOCAL_CURR_AMT = 'Local_Currency_Amount__c';
    
    //QLI's Fields
    public static final String QLI_UNIT_PRICE = 'UnitPrice';
    public static final String QLI_QUOTE_ID ='QuoteId';
    public static final String QLI_QUANTITY ='Quantity';
    
    //Case's Fields
    public static final String CASE_CONTACT =  'ContactId';
    public static final String CASE_ORIGIN =  'Origin';
    
    //Sales_Target's Fields
    public static final String ST_CRITERIA_CHECKER = 'Criteria_Checker__c';
    public static final String ST_EMPLOYEE = 'Employee__c';
    
    //Sales_Target_LI's Fields
    public static final String ST_START_DATE = 'Start_Date__c';
    public static final String ST_END_DATE = 'End_Date__c';
    public static final String ST_TARGET = 'Target__c';
    
    //Period's Fields
    public static final String PERIOD_START_DATE = 'Period_Start_Date__c'; 
    public static final String PERIOD_END_DATE = 'Period_End_Date__c';
	public static final String REN_RLI_DATE_MAP = 'REN_RLI_DATE_MAP';   
	
	public static final String REN_VALUE = 'REN_Value__c';
	public static final String REN_OBJ_VALUE_MAPPING = 'REN_Value_Mapping__c';
	public static final String REN_OBJ_RLI = 'REN_Renews_To__c';
	
	public static final String OBJ_RC_RECORD_KEY = 'REN_Record_Key__c';
	public static final String OBJ_DLRS_LOOKUP_ROLLUP_SUMMARY = 'dlrs__LookupRollupSummary__c';
	
	
    
    
}