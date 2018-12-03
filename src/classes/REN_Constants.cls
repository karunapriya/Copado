global with sharing class REN_Constants {
	
	//Common fields
	public static final String FLD_ID = 'Id';
	public static final String REN_CURRENCY_ISO_CODE = 'CurrencyIsoCode';
	public static final String FLD_NAME = 'Name';
	public static final String FLD_ISDELETED = 'IsDeleted';
	public static final Integer DEFAULT_CRITERIA_COUNT = 3;
	public static final String RECORD_TYPE_ID = 'RecordTypeId';
	public static final String IS_WON = 'isWon';
	public static final String IS_ACTIVE = 'isActive';
	
	
	//Trigger
	public static Boolean OPPORTUNITYLINEITEM_TRIGGER = true;
	global static Boolean CONTRACTLINEITEM_TRIGGER = true;
	public static Boolean ASSET_TRIGGER = true;
    public static Boolean ASSET_TRIGGER_BEFORE_UPDATE = true;
	//public static Boolean RENEWALRELATIONSHIP_BEFORE_TRIGGER = true; 
	public static Boolean RENEWALRELATIONSHIP_AFTER_TRIGGER = true; 
	public static Boolean SERVICE_CONTRACT_BEFORE_TRIGGER = true;	
	public static Boolean ATTACHMENT_TRIGGER = true;	
	//Opportunity Plan field list.
    public static final String OBJ_OP = 'REN_Opportunity_Plan__c';
    public static final String OBJ_OP_ID = 'Id';
    public static final String OBJ_OP_CURRENT_QUARTER = 'REN_Current_Quarter__c';
    public static final String OBJ_OP_DISPLAYNAME = 'REN_DisplayName__c';
    public static final String OBJ_OP_ISACTIVE = 'REN_IsActive__c';
    public static final String OBJ_OP_OPPORTUNITY_OWNER = 'REN_Opportunity_Owner__c';
    public static final String OBJ_OP_OPPORTUNITY_OWNER_ID = 'REN_Opportunity_Owner_Id__c';
    public static final String OBJ_OP_QUARTER_START_DATE = 'REN_Quarter_Start_Date__c';
    public static final String OBJ_OP_RELATED_OPPORTUNITY = 'REN_Related_Opportunity__c';
    public static final String OBJ_OP_OPPORTUNITY = 'REN_Opportunity__c';
    public static final String OBJ_OP_RENEWAL_AM = 'REN_Renewal_AM__c';
    public static final String OBJ_OP_RENEWAL_REP = 'REN_Renewal_Rep__c';
    public static final String OBJ_OP_SALES_OPS_AM = 'REN_Sales_Ops_AM__c';
    public static final String OBJ_OP_SALES_OPS_REP = 'REN_Sales_Ops_Rep__c';
    public static final String OBJ_OP_TEMPLATE = 'REN_Template__c';
    public static final String OBJ_T_REN_OPPORTUNITY = 'REN_Opportunity__c'; 
    public static final String OBJ_T_REN_OPPORTUNITY_SERVICE_CONTRACT = 'REN_Opportunity_Service_Contract__c';
    public static final String OBJ_OP_CAMPAIGNID = 'CampaignId';
    
    // Opportunity plan task assignTo picklist values.
    public static final String ASSIGN_OPPORTUNITY_OWNER = 'Opportunity Owner';
    public static final String ASSIGN_RENEWAL_SALES_REP = 'Renewal/Sales Rep';
    public static final String ASSIGN_RENEWAL_SALES_AM = 'Renewal/Sales AM';
    public static final String ASSIGN_SALES_OPS_AM = 'Sales Ops AM';
    public static final String ASSIGN_SALES_OPS_REP = 'Sales Ops Rep';
    
    // Success Plan Template Module Type values
    public static final String MODULE_TYPE_CSM = 'CSM';
    public static final String MODULE_TYPE_RENEW_DIRECT = 'Renew Direct';
    
    public static final String DB_DATE_FORMAT = 'yyyy-MM-dd';
    public static final String DB_DATETIME_FORMAT = 'yyyy-MM-dd hh:mm:ss';//'yyyy-MM-dd\'T\'hh:mm:ss\'Z\'';
    
    //Renew Configuration Constant
    public static final String OBJ_RC_OPPORTUNITY_TYPE = 'Type';
    public static final String OBJ_RC_OPPORTUNITY_STAGE = 'StageName';
    public static final String OBJ_VALUE_OPERATOR = 'operator';
    public static final String VAL_CRITERIA = 'criteria';

    public static final String BATCH_ACTIVITY_TYPE_SEGMENT_TASK = 'Generate Task for Segment Members';
    public static final String PRIMARY_CONTACT = 'Primary Contact from Contact Role';
    
    // Opportunity Custom Fields
    public static final String OBJ_OPP_FY = 'REN_FY__c';
    public static final String OBJ_OPP_EQ = 'REN_EQ__c';
    public static final String OBJ_OPP_STAGE = 'StageName';
    public static final String OBJ_OPP_CONSOLIDATED = 'REN_Is_Consolidated__c';
    //public static final String OBJ_OPP_CONSOLIDATED_TO = 'REN_Consolidated_To__c';
    //public static final String OBJ_OPP_SPLIT_FROM = 'REN_Split_From__c';
    public static final String OBJ_OPP_APPEND_OPPTY = 'REN_Append_Renewal_Opportunity__c';
    public static final String OBJ_OPP_APPEND_SERV_CONTRACT = 'REN_Append_Service_Contract__c';
    public static final String OBJ_OPP_ISCLM_RENEWAL = 'REN_Is_CLM_Renewal__c';
    public static final String OBJ_OPP_NOTIFY_OPPT_OWNER = 'REN_Notify_Opportunity_Owner__c';
    public static final String OBJ_OPP_FORECAST_CATEGORY = 'ForecastCategoryName';
    public static final String OBJ_OPP_CLM_RENEWAL = 'REN_Is_CLM_Renewal__c';
    public static final String OBJ_OPP_APPEND_RENEWAL_OPPTY = 'REN_Append_Renewal_Opportunity__c';
    public static final String OBJ_OPP_EARLIEST_EXPIRATION_DATE = 'REN_Earliest_Expiration_Date__c';
    public static final String OBJ_OPP_RENEWAL_TARGET = 'REN_Renewal_Target__c';
    public static final String OBJ_OPP_RENEWAL_TARGET_LOST = 'REN_Renewal_Target_Lost__c';
    public static final String OBJ_OPP_RENEWAL_TARGET_RESOLVED = 'REN_Renewal_Target_Resolved__c';
    public static final String OBJ_OPP_RENEWAL_TARGET_WON = 'REN_Renewal_Target_Won__c';
    public static final String OBJ_OPP_PRICEBOOK_ID = 'Pricebook2Id';
    public static final String OBJ_OPP_APPEND_SC = 'REN_Append_Service_Contract__c';
    public static final String OBJ_OPP_APPEND_SC_Pricebook2Id = 'REN_Append_Service_Contract__r.Pricebook2Id';    
    public static final String OBJ_OPP_APPEND_SC_CURRENCY = 'REN_Append_Service_Contract__r.CurrencyIsoCode';    
    public static final String OBJ_OPP_APPEND_OPP_Pricebook2Id = 'REN_Append_Renewal_Opportunity__r.Pricebook2Id';    
    public static final String OBJ_OPP_APPEND_OPP_CURRENCY = 'REN_Append_Renewal_Opportunity__r.CurrencyIsoCode';
    public static final String OBJ_OPP_FORECAST_CATEGORY_2 = 'ForecastCategory'; 
    public static final String OBJ_OPP_EARLIEST_EXISTING_END_DATE = 'REN_Earliest_Existing_End_Date__c';
    public static final String OBJ_OPP_CONVERSION_DELTA = 'REN_Conversion_Delta_Amount__c';
    public static final String OBJ_OPP_ADDS_AMOUNT = 'REN_AddsAmount__c';
    public static final String OBJ_OPP_LOSS_RATE = 'REN_Loss_Rate__c';
    public static final String OBJ_OPP_EXPIRATION_QUARTER_YEAR = 'REN_Expiration_Quarter_Year__c';
	public static final String OBJ_OPP_NEW_CLOSE_DATE = 'CSM_CloseDate__c';
	
	//Opportunity Standard fields
    public static final String OBJ_OPP_AMOUNT = 'Amount';
    public static final String OBJ_OPP_CLOSE_DATE = 'CloseDate';
    public static final String OBJ_OPP_CREATED_DATE = 'createdDate';    
    public static final String OBJ_OPP_PROBABILITY = 'Probability';
    public static final String OBJ_OPP_ACCOUNT = 'AccountId';
    public static final String OBJ_OPP_OWNER_ID = 'OwnerId';
    
    //Opportunity Stage
    public static final String OBJ_OPPSTAGE_PROB = 'DefaultProbability';
    public static final String OBJ_OPPSTAGE_MASTERLABEL = 'MasterLabel';
    public static final String OBJ_OPPSTAGE = 'OpportunityStage';
    public static final String OBJ_OPPSTAGE_NOT_CONTACTED = 'Not Contacted';
    
    public static final String OBJ_PRICEBOOK = 'Pricebook2';  
    // ServiceContract fields
    public static final String OBJ_SERVICECONTRACT = 'ServiceContract';    
    public static final String OBJ_SC_NAME = 'Name';
    public static final String OBJ_SC_OWNER_ID = 'OwnerId';
    public static final String OBJ_SC_PRICEBOOK2_ID = 'Pricebook2Id';
    public static final String OBJ_SC_ACCOUNT = 'AccountId';
    public static final String OBJ_SC_BILL_ADDR = 'BillingAddress';
    public static final String OBJ_SC_CONTACT = 'ContactId';
    public static final String OBJ_SC_CONTRACT_NO = 'ContractNumber';
    public static final String OBJ_SC_DESC = 'Description';
    public static final String OBJ_SC_DISC = 'Discount';
    public static final String OBJ_SC_END_DATE = 'EndDate';
    public static final String OBJ_SC_SHIP_ADDR = 'ShippingAddress';
    public static final String OBJ_SC_SHIP_HANDLING = 'ShippingHandling';
    public static final String OBJ_SC_SPECIAL_TERMS = 'SpecialTerms';
    public static final String OBJ_SC_START_DATE = 'StartDate';
    public static final String OBJ_SC_STATUS = 'Status';
    public static final String OBJ_SC_SUBTOTAL = 'Subtotal';
    public static final String OBJ_SC_TAX = 'Tax';
    public static final String OBJ_SC_TERM = 'Term';
    public static final String OBJ_SC_TOTAL_PRICE = 'TotalPrice';
    public static final String OBJ_SC_REN_OPPTID = 'REN_Renewal_Opportunity__c';
    public static final String OBJ_SC_SRC_OPPTID = 'REN_Opportunity__c';
    public static final String OBJ_SC_IS_CONSOLIDATED = 'REN_Is_Consolidated__c';
    public static final String OBJ_SC_IS_CONSOLIDATED_TO = 'REN_Consolidated_To__c';    
	public static final String OBJ_SC_IDS = 'serviceContractIds';
	public static final String OBJ_SC_RELATION = 'REN_Service_Contract__r';
    
    //OpportunityContactRole field
    public static final String OBJ_OPPCONROLE_OPPTY = 'OpportunityId';
    public static final String OBJ_OPPCONROLE_CONTACT = 'contactid';
    
    //Renew Config fields
    public static final String OBJ_RC = 'REN_Renew_Configuration__c';
    public static final String OBJ_RC_IS_ACTIVE = 'REN_Is_Active__c';
    public static final String OBJ_RC_RECORD_KEY = 'REN_Record_Key__c';
    public static final String OBJ_RC_UPDATED_ON = 'REN_Update_On__c';
    public static final String OBJ_RC_FILTER_LOGIC = 'RLM_Filter_Logic__c';
    public static final String OBJ_RC_FILTER_CRITERIA = 'REN_Filter_Criteria__c';
    public static final String OBJ_RC_VIEW_NAME = 'REN_View_Name__c';
    public static final String OBJ_RC_DESCRIPTION = 'REN_Description__c';
    public static final String OBJ_RC_CONFIGURATION_TYPE = 'REN_Configuration_Type__c';
    public static final String OBJ_RC_CTYPE_GROUPING = 'Grouping';
    public static final String OBJ_RC_CURRENCYCODE = 'RLM_Currency_Code__c';
    public static final String OBJ_RC_CTYPE_RENEW_OP = 'Renew Opportunity';
    public static final String OBJ_RC_CTYPE_CSM_PLAN = 'CSM_PTA';    
    
  	//US451
    public static final String RC_TT_OPPORTUNITY_TO_RENEW_OPPORTUNITY  =  'Opportunity_To_Renew_Opportunity';
    public static final String RC_TT_OPPORTUNITY_PRODUCT_TO_RENEW_OPPORTUNITY_PRODUCT  =  'Opportunity_Product_To_Renew_Opportunity_Product';
    public static final String RC_TT_ASSET_TO_RENEW_OPPORTUNITY_PRODUCT  =  'Asset_To_Renew_Opportunity_Product';
    public static final String RC_TT_CONTRACT_LINE_ITEM_TO_RENEW_OPPORTUNITY_PRODUCT  =  'Contract_Line_Item_To_Renew_Opportunity_Product';
    public static final String RC_TT_OPPORTUNITY_TO_ASSET  =  'Opportunity_To_Asset';
    public static final String RC_TT_OPPORTUNITY_PRODUCT_TO_ASSET  =  'Opportunity_Product_To_Asset';
    public static final String RC_TT_OPPORTUNITY_TO_SERVICE_CONTRACT  =  'Opportunity_To_Service_Contract';
    public static final String RC_TT_OPPORTUNITY_PRODUCT_TO_CONTRACT_LINE_ITEM  =  'Opportunity_Product_To_Contract_Line_Item';
    
    public static final string PRODUCT_REFERENCE_ON_OPTYLINEITEM = 'PricebookEntry.Product2.';
 
    public static final String RC_TRIGGER_TYPE_SERVICE_CONTRACT = 'Service Contract';
    public static final String RC_TRIGGER_TYPE_OPPORTUNITY = 'Opportunity';
    public static final String RC_TRIGGER_TYPE_ASSET = 'Asset';
    
    //Field Mappings fields
    public static final String OBJ_FM = 'REN_Field_Mappings__c';
    public static final String OBJ_FM_RENEW_CONFIG = 'REN_Renew_Configuration__c';
    public static final String OBJ_FM_DEFAULT_VALUE = 'REN_Default_Value__c';
    public static final String OBJ_FM_FIELD_DATA_TYPE = 'REN_Field_Data_Type__c';
    public static final String OBJ_FM_FROM_FIELD_API_NAME = 'REN_From_Field_API_Name__c';
    public static final String OBJ_FM_FROM_OBJECT_API_NAME = 'REN_From_Object_Api_Name__c';
    public static final String OBJ_FM_IS_REQUIRED = 'REN_Is_Required__c';
    public static final String OBJ_FM_TO_FIELD_API_NAME = 'REN_To_Field_API_Name__c';
    public static final String OBJ_FM_TO_OBJECT_API_NAME = 'REN_To_Object_API_Name__c';
    public static final String OBJ_FM_NAME = 'Name';
    //Line Criteria fields
    public static final String OBJ_LC = 'REN_Line_Criteria__c';
    public static final String OBJ_LC_RENEW_CONFIG = 'REN_Renew_Configuration__c';
    public static final String OBJ_LC_CRITERIA = 'RLM_Criteria__c';
    public static final String OBJ_LC_FIELD_VALUE = 'RLM_Values__c';
    public static final String OBJ_LC_OBJ_API_NAME = 'RLM_Object_API_Name__c';
    public static final String OBJ_LC_OBJ_FIELD_API_NAME = 'RLM_Field_Name__c';
    public static final String OBJ_LC_OPERATOR = 'RLM_Operator__c';
    public static final String OBJ_LC_DATETIME = 'RLM_DateTime_Value__c';
     
    //Related List Object Fields
    public static final String OBJ_RL = 'REN_Related_List__c';
    public static final String OBJ_RL_RENEW_CONFIG = 'REN_Renew_Configuration__c';
    public static final String OBJ_RL_OBJ_API_NAME = 'REN_Object_API_Name__c';
    public static final String OBJ_RL_RELATED_LIST_TYPE = 'REN_Related_List_Type__c';

    public static final String TRACK_USING_SERVICE_CONTRACT = 'Service Contracts';
    public static final String TRACK_USING_ASSET = 'Asset';
    public static final String PUSH_TYPE_NET_NEW = 'Push only net new';
    public static final String PUSH_TYPE_ALL = 'Push all';
    public static final String PUSH_TYPE_NONE = 'None';
    
    //Objects
    public static final String OBJ_SEGMEMBER= 'REN_Segment_Member__c';
    public static final String OBJ_OPPORTUNITYCONTACTROLE = 'OpportunityContactRole';
    public static final String OBJ_OPPORTUNITY = 'Opportunity';
	public static final String OBJ_OPPTY_LINE_ITEM = 'OpportunityLineItem';    
	public static final String OBJ_SERVICE_CONTRACT = 'ServiceContract';
    public static final String OBJ_ASSET = 'Asset';
    public static final String OBJ_PRODUCT = 'Product2';
    public static final String OBJ_CONTRACT_LINE_ITEM = 'ContractLineItem';
    public static final String OBJ_PricebookEntry = 'PricebookEntry';
    public static final String OBJ_RENEW_LINE_ITEM = 'REN_Renews_To__c';
    
    // OpportunityLineItem 
   
    public static final String OBJ_OLI_UNITPRICE = 'UnitPrice';
    public static final String OBJ_OLI_SORTORDER = 'SortOrder';
    public static final String OBJ_OLI_SERVICEDATA = 'ServiceDate';
    public static final String OBJ_OLI_QUANTITY = 'Quantity';
    public static final String OBJ_OLI_PRODUCTCODE = 'ProductCode';
    public static final String OBJ_OLI_SOURCE_OPLI_ID = 'REN_Source_Opportunity_Line_Item_Id__c';
    public static final String OBJ_OLI_OPPORTUNITY_ID = 'OpportunityId';
    public static final String OBJ_OLI_TOTAL_PRICE =  'TotalPrice';
    public static final String OBJ_OLI_PREV_OPP = 'REN_Previous_Opportunity__c';
    //public static final String OBJ_OLI_ORIG_LI_ID =  'REN_Original_Line_Item_ID__c';
    public static final String OBJ_OLI_SOURCE_OPP =  'Ren_Source_Opportunity__c';

    // OpportunityProduct 
    

    // ContractLineItem 
  
    public static final String OBJ_SCLI_UNITPRICE = 'UnitPrice';
    public static final String OBJ_SCLI_SERVICECONTRACTID = 'ServiceContractId';
    public static final String OBJ_SCLI_STATUS = 'Status';
    public static final String OBJ_SCLI_QUANTITY = 'Quantity';
    public static final String OBJ_SCLI_STARTDATE = 'StartDate';
    public static final String OBJ_SCLI_PRICEBOOKENTRYID = 'PricebookEntryId';    
    public static final String OBJ_SCLI_LISTPRICE = 'ListPrice';
    public static final String OBJ_SCLI_LINEITEMNUMBER = 'LineItemNumber';
    public static final String OBJ_SCLI_ENDDATE = 'EndDate';    
    public static final String OBJ_SCLI_DISCOUNT = 'Discount';    
    public static final String OBJ_SCLI_DESCRIPTION = 'Description';    
    public static final String OBJ_SCLI_ASSETID = 'AssetId';    
    public static final String OBJ_SCLI_OPLI_ID = 'REN_Oppty_Line_Item_id__c';
    public static final String OBJ_SCLI_SERIALNUMBER = 'SerialNumber';
    
    //Asset
   
    public static final String OBJ_ASSET_OPPORTUNITY = 'REN_Opportunity__c';
    public static final String OBJ_ASSET_OPPORTUNITY_LINE_ITEM_ID = 'REN_Oppty_Line_Item_Id__c';
    public static final String OBJ_ASSET_PRODUCT2ID = 'Product2Id';
    public static final String OBJ_ASSET_PRICE = 'Price';
    public static final String OBJ_PERIOD = 'Period';
    public static final String OBJ_PARTNER = 'Partner';
	public static final String OBJ_FLD_START_DATE = 'REN_Start_Date__c';
	public static final String OBJ_FLD_END_DATE = 'REN_End_Date__c';

	public static final String OBJ_EXT_FIELD_SERVICE_CONTRACT = 'REN_Service_Contract__c';    
	public static final String CUSTOMER_TYPE1 = 'Type1';
	public static final String CUSTOMER_TYPE2 = 'Type2';
	public static final String CUSTOMER_TYPE3 = 'Type3';
	
	//Opportunity and Line Fields
	public static final String OBJ_OPP_FLD_IS_CLM_RENEWAL = 'REN_Is_CLM_Renewal__c';
	public static final String OBJ_OPPLN_FLD_CVD_ASSET = 'REN_Covered_Asset__c';
	public static final String OBJ_OPPLN_FLD_CVD_PRD = 'REN_Covered_Product__c';
	public static final String OBJ_SERVICE_CONTRACT_ID = 'ServiceContractId'; 
	public static final String OBJ_OPPLN_START_DATE = 'REN_Start_Date__c';
	public static final String OBJ_OPPLN_END_DATE = 'REN_End_Date__c';
	
	
	//Renewal Relationship
	public static final String OBJ_REN_RENEWS_TO = 'REN_Renews_To__c';
	public static final String OBJ_REN_RENEWS_TO_ASSET = 'REN_Asset__c';
	public static final String OBJ_REN_RENEWS_TO_RENEWS_TO = 'REN_Renews_To__c';
	//public static final String OBJ_REN_RENEWS_TO_RENEWS_TO_PRODUCT_ID = 'REN_Renewal_Product_Line_Id__c';
	public static final String OBJ_REN_RENEWS_TO_CONTRACT_LINE_ITEM = 'REN_Contract_Line_Item__c';
	public static final String OBJ_REN_RENEWS_TO_START_DATE = 'REN_Start_Date__c';
	public static final String OBJ_REN_RENEWS_TO_END_DATE = 'REN_End_Date__c';
	public static final String OBJ_REN_RENEWS_TO_PREVIOUS_PRICE = 'REN_Previous_Price__c';
	public static final String OBJ_REN_RENEWS_TO_QUANTITY = 'REN_Quantity__c';
	public static final String OBJ_REN_RENEWS_TO_PRODUCT = 'REN_Product__c';
	public static final String OBJ_REN_RENEWS_TO_STATUS = 'REN_Renewal_Status__c';
	public static final String OBJ_REN_RENEWS_TO_TARGET = 'REN_Renewal_Target__c';
	//public static final String OBJ_REN_RENEWS_TO_ORIG_LINE_ITEM = 'REN_Original_Line_Item_ID__c';
	public static final String OBJ_RS_CONFIGURATION = 'REN_RS_Config__c';
	
	public static final String FLD_VAL_UPDATE_ON_ASSET_EX = 'Asset - Existing';
	public static final String FLD_VAL_UPDATE_ON_CONTRACT_LINES_EXISTING = 'Contract Lines - Existing';
	public static final String FLD_VAL_UPDATE_ON_CONTRACT_LINES_NEW = 'Contract Lines - New';
	
	public static final String OBJ_LC_IS_SPECIFIC_DATE = 'RLM_Is_Specific_Date__c';
    public static final String OBJ_LC_DATE_LITERAL_NUMBER = 'RLM_Date_Literal_Number__c';
    public static final String OBJ_LC_DATE_LITERAL_STRING = 'RLM_Date_Literal_String__c';
    public static final String OBJ_LC_DATE_STRING = 'RLM_Date_String__c';
    public static final String OBJ_LC_DISPLAY_NAME = 'RLM_Field_Display_Name__c';
	public static final String OBJ_LC_DATE = 'RLM_Date_Value__c';
	public static final String OBJ_LC_TYPE = 'RLM_Field_Type__c';
    
    
	public static final String FLD_MAP_OPPT_TO_RENEWAL_OPPT = system.label.REN_LBL_OPPTY_TO_REN_OPPTY;
	public static final String FLD_MAP_ASSET_TO_OPPT = system.label.REN_LBL_ASSET_TO_OPLI;
	public static final String FLD_MAP_OPPT_TO_SERVICE_CONTRACTS = system.label.REN_LBL_OPPTY_TO_SC;
	public static final String FLD_MAP_OPPT_LINE_TO_ASSET = system.label.REN_LBL_OPLI_TO_ASSET;
	public static final String FLD_MAP_SERVICE_CONTRACT_TO_OPPORTUNITY = system.label.REN_LBL_SC_TO_OPPTY;
	public static final String FLD_MAP_OPPT_LINE_TO_RR = system.label.REN_LBL_OPLI_TO_RR;
	//public static Boolean RENEWALRELATIONSHIP_BEFORE_TRIGGER = true; 
	//public static Boolean RENEWALRELATIONSHIP_AFTER_TRIGGER = true; 
	
	public static final String WHITESPACE = ' '; //The intent here is to indicate wherever this is used, the use is intentional.
	
	public static final String STR_CONSOLIDATE = 'Consolidate';
	public static final String STR_SPLIT = 'Split';
	public static final String STR_SEARCH_AND_MOVE = 'Search and Move';
	
	
	 /*@Created By: PES
     @Created On: 18th May 2015
     @description : Below nine constants are used in REN_WaterfallReportController
     
     */
     
    public static final String RENEWAL_TARGET_TOTAL_AVAILABLE = 'Renewal Target - Total Available';
    public static final String RENEWAL_TARGET_UNRESOLVED = 'Renewal Target - Unresolved';
    public static final String RENEWAL_TARGET_RESOLVED = 'Renewal Target - Resolved';
    public static final String RENEWAL_TARGET_LOST = 'Renewal Target - Total Lost';
    public static final String RENEWAL_TARGET_WON = 'Renewal Target - Total Won';
    public static final String CONVERSION_DELTA = 'Conversion Delta';
    public static final String PIPELINE_ADDS_WON = 'Pipeline Adds - Total Won';
    public static final String PIPELINE_WON = 'Pipeline - Total Won';
    public static final String REPORTNAME = 'Renewals_System_Reports';  
   
    
    
    public static final String AVAILABLE_OPPORTUNITY = 'Available'+'<br/>'+'Opportunity';
    public static final String UNRESOLVED_OPPORTUNITY = 'Unresolved'+'<br/>'+'Opportunity';
    public static final String RESOLVED_OPPORTUNITY = 'Resolved'+'<br/>'+'Opportunity';
    public static final String LOST_OPPORTUNITY = 'Lost'+'<br/>'+'Opportunity';
    public static final String WON_OPPORTUNITY = 'Won'+'<br/>'+'Opportunity';
    public static final String CONVERSION_OPPORTUNITY = 'Conversion'+'<br/>'+'Opportunity';
    public static final String ADDED_OPPORTUNITY = 'Added'+'<br/>'+'Opportunity';
    public static final String TOTAL_OPPORTUNITY = 'Total'+'<br/>'+'Won';
    
    
    public static final String HCHRT_LITERAL_ISINTERMEDIATESUM = 'isIntermediateSum';
    public static final String HCHRT_LITERAL_ISSUM = 'isSum';
    
    //  US466 - Added folder Renewals_Insights_Reports. 
    public static final String REN_INSIGHTS_FOLDER = 'Renewals_Insights_Reports'; 
    
  	//Reports and Folder
    public static final String OBJ_REPORT = 'Report';
    public static final String OBJ_FOLDER = 'Folder';
    public static final String OBJ_FOLDER_FLD_DEVELOPER_NAME = 'DeveloperName';
    
    public static final String OBJ_BATCH_ACT = 'REN_Batch_Activity__c';
	public static final String EMAIL_NOTIFI = 'REN_Email_Notification__c';
	public static final String REN_PB = 'REN_Pricebook__c';
	public static final String REN_RECIP = 'REN_Recipient__c';
	public static final String OBJ_EMAIL_RECIP = 'REN_Email_Recipient__c';
	public static final String REN_GROUPING = 'REN_Grouping__c';
	public static final String REN_GROUPING_FILTER = 'REN_Grouping_Filter__c';
	public static final String REN_JOB_ID = 'REN_Job_ID__c';
	public static final String REN_SRC_REC_FLTR = 'REN_Source_Record_Filter__c';
	public static final String REN_JOB_STRT_DT = 'REN_Job_Start_Date__c';
	public static final String REN_BAT_NUM = 'REN_Batch_Number__c';
	public static final String REN_EMAIL_RECIP = 'REN_Recipient__c';
	public static final String REN_USER = 'REN_User__c';
	public static final String REN_STATUS = 'REN_Status__c';
	public static final String DB_DATETIME_FORMAT_BATCH = 'ss mm HH dd MM ? yyyy';
	public static final String REN_JOB_COMPLT_DT = 'REN_Job_Completion_Date__c';
	public static final String REN_FAILURE_ASSETS = 'REN_Failure_Assets__c';
	public static final String REN_SCHEDULER_ID = 'REN_Scheduler_ID__c';
	public static final String REN_LAST_MOD_DT = 'REN_Last_Modified_By__c';
	public static final String REN_GEN_RECS = 'REN_Generated_Records__c';
	public static final String REN_RELATION_FILTER_NAME = 'REN_Source_Record_Filter__r.REN_View_Name__c';
	public static final String REN_RELATION_GROUPING_NAME = 'REN_Grouping__r.REN_View_Name__c';
	public static final String REN_CREATEDBY = 'REN_Created_By__c';
	public static final String REN_CREATEDON = 'REN_Created_On__c';
	public static final String REN_LAST_MOD_ON = 'REN_Last_Modified_On__c';
	public static final String REN_LAST_MOD_NAME = 'REN_Last_Modified_By__r.name';
	public static final String REN_CREATEDBY_STD = 'CreatedById';
	public static final String REN_CREATEDON_STD = 'CreatedDate';
	public static final String REN_CREATEDBY_NAME = 'CreatedBy.name';
    public static final String REN_PLAN_TEMPLATE_ASSIGNMENT_NAME = 'REN_Plan_Template_Name__c';    
    public static final String REN_RC_PLAN_TEMPLATE_ID = 'REN_Plan_Template_Id__c';    
	public static final String REN_BATCH_TYPE = 'REN_Batch_Type__c';
	public static final String REN_CLOSED_DATE_OPTIONS = 'REN_Closed_Date_Options__c';
	public static final String REN_CLOSED_DATE_DEPENDS_ON = 'REN_Closed_Date_Depends_On__c'; 
	
	public static final String OBJ_BATCH_FAIL = 'REN_Batch_Opportunity_Failure__c';
	public static final String REN_ASSET = 'REN_Asset__c';
	public static final String REN_MSG = 'REN_Failure_Message__c';
	public static final String REN_BATCH_ACTVTY = 'REN_Batch_Activity__c';
	public static final String REN_OPP_AMOUNT_TOTL = 'REN_Total_Amount__c';
	public static final String REN_CREATEDBY_NAME_CUST = 'REN_Created_By__r.name';
	public static final String REN_OBJ_TYPE = 'REN_Object__c';
	public static final String REN_RELATION_FILTER_DESC = 'REN_Source_Record_Filter__r.REN_Description__c';
	public static final String REN_RELATION_GROUPING_DESC = 'REN_Grouping__r.REN_Description__c';
	public static final String REN_ACCOUNT_NAME = 'Account.Name';
	public static final String REN_RENEWABLE_PROD = 'REN_Renewable_Products__c';
	public static final String REN_FILT_CRITERIA = 'REN_Filter_Criteria__c';
	public static final String REN_GROUP_CRITERIA = 'REN_Grouping_Criteria__c';
	public static final String REN_ACCOUNT_ID = 'Account.Id';
	public static final String REN_FAIL_ASSET = 'REN_Failure_Assets__c';
	public static final String REN_ASSET_NAME = 'REN_Asset__r.name';
	public static final String REN_RECORD_NAME = 'REN_Record_Name__c';
	public static final String REN_RECORDID = 'REN_Record_Id__c';
	
	public static final String  STATUS_PROCESSING = 'Processing';
	public static final String  STATUS_FAILED = 'Failed';
	public static final String  STATUS_COMPLETED = 'Completed';
	public static final String  STATUS_PARTIAL_SUCCESS = 'Partial Success';
	public static final String  STATUS_INPROGRESS = 'InProgress';
	
	
	public static final String EARLIEST_DATE = 'Earliest Date';
	public static final String LATEST_DATE = 'Latest Date';
	public static final String COMMON_DATE = 'Most Common Date';
	public static final String VALUABLE_DATE = 'Most Valuable Date';
	
	public static final String RENEW_REL_FILTER = 'Renewal Relationship Filter';
	public static final String FILTER = 'Filter';
	
	//Value Mapping
	public static final String REN_VALUE = 'REN_Value__c';
	public static final String REN_OBJ_VALUE_MAPPING = 'REN_Value_Mapping__c';
	public static final String REN_RR_STATUS_MAP = 'REN_RR_STATUS_MAP';
	public static final String REN_RLI_DATE_MAP = 'REN_RLI_DATE_MAP';
	
	
	//Values for Source object - Reason field - Field API Name:Reason__c
	public static final String REN_REASON_ADDON = 'Add On';
	public static final String REN_REASON_MERGE = 'Merge';
	public static final String REN_REASON_AUTO_REN = 'Auto Renewal';
	public static final String REN_REASON_MAN_REN = 'Manual Renewal';
	public static final String REN_REASON_SPLIT = 'Split';
	public static final String REN_REASON_CONSOLIDATED = 'Consolidation';
	
	//Static Record Limit Variables
	public static String REC_LIMIT_BATCH_OPP_GENRATION_GRID ='Batch Opp Genration Grid';
	public static String REC_LIMIT_AUTOMATED_GENRATION_LOG_GRID ='Automated Generation Log Grid';
	public static String RENEWAL_LINE_ITEM_DATE = 'Renewal Line Item Date Field';
	
	//Segment object
    public static final String OBJ_SEGMENT = 'REN_Segment__c';			
	public static final String OBJ_SE_NAME = 'Name';
	public static final String OBJ_SE_NUMBER_OF_SEGMENT_MEMBERS = 'REN_Number_of_Segment_Members__c';
	public static final String OBJ_SE_DESCRIPTION = 'REN_Description__c';
	public static final String OBJ_SE_TYPE = 'REN_Type__c';
	public static final String OBJ_SE_VALUE = 'REN_Value__c';
	public static final String OBJ_SE_CREATED_BY_NAME = 'CreatedBy.Name';
	public static final String OBJ_SE_CREATED_DATE = 'CreatedDate';
	public static final String OBJ_SE_LAST_MODIFIED_BY_NAME = 'LastModifiedBy.Name';
	public static final String OBJ_SE_LAST_MODIFIED_DATE = 'LastModifiedDate';
	public static final String OBJ_SE_TYPE_ABRLM = 'ABRLM'; //Picklist values REN_Segment__c.REN_Type__c
	public static final String OBJ_SE_TYPE_LOW_TOUCH = 'Low Touch'; //Picklist values REN_Segment__c.REN_Type__c
	public static final String OBJ_SE_LAST_FILTER = 'REN_Last_Filter__c';
	public static final String OBJ_SE_QR_CREATED = 'REN_QuoteRequest_Created__c';
	public static final String OBJ_SE_QR_SUBMITTED = 'REN_QuoteRequest_Submitted__c';		
	
	//Segment member object
	public static final String OBJ_SEGMENT_MEMBER = 'REN_Segment_Member__c';
	public static final String OBJ_SM_NAME = 'Name';
	public static final String OBJ_SM_ASSET = 'REN_Asset__c';
	public static final String OBJ_SM_OPPORTUNITY = 'REN_Opportunity__c';
	public static final String OBJ_SM_SEGMENT = 'REN_Segment__c';
	public static final String OBJ_SM_SEGMENT_PRIMARY_CONTACT = 'REN_Segment_Primary_Contact__c';
	
	//Account, Opportunity, RLI and Asset
	public static final String OBJ_AORA = 'AORA';
	public static final String OBJ_DSFS_DOCUSIGN_STATUS = 'dsfs__DocuSign_Status__c';
	public static final String DML_OPERATION_UPDATE = 'Update';
	public static final String OBJ_CASE_DESC = 'Description';
	public static final String OBJ_CASE_OPP = 'Opportunity__c';
	public static final String OBJ_CASE_REC_TYPE = 'RecordTypeId';
	public static final String OBJ_CASE_SUB_CASE_TYPE = 'Sub_Case_Type__c';
	public static final String OBJ_CASE_STATUS = 'Status';
	public static final String OBJ_CASE_CONTRACT_AMOUNT = 'Contract_Amount__c';
	public static final String OBJ_CASE_CONTACT_ID = 'ContactId';
	public static final String OBJ_CASE_SUBJECT = 'Subject';
	public static final String OBJ_ATTACHMENT = 'Attachment';
	public static final String OBJ_CASE_RECORD_TYPE = 'Record Type';
	
	public static Boolean IS_AUTO_REBUILD = true;
}