/* Description: Class to declared constants for Channel Partner Objects fields */

global with sharing class CHL_Constants {
    
    public static final String PERCENT = '%';
    public static final String PARTNER_USER = 'PowerPartner';
    public static final String PARTNER_LICENSE = 'Partner Community';
    public static final String PARTNER_PROFILE = 'Channel Community';
    public static final String PARTNER_COMMUNITY_LOGIN_LICENSE = 'Partner Community Login';
    public static final String SALESFORCE_LICENSE = 'Salesforce';
    
    // Segment - Google Analytics
    public static final String GA_SEGMENT_LOGIN_EVENT = 'Login';
    public static final String GA_SEGMENT_CHANGE_PWD_EVENT = 'Change Password';    
    public static final String GA_SEGMENT_FORGOT_PWD_EVENT = 'Forgot Password';
    public static final String GA_SEGMENT_FORGOT_PWD_ACTION = 'Forgot';    
    public static final String GA_SEGMENT_LOGIN_CATEGORY = 'Web';
    public static final String GA_SEGMENT_SUCCESS_LABEL = 'Success';
    public static final String GA_SEGMENT_FAILURE_LABEL = 'Failure';    
    public static final String GA_SEGMENT_CHANGE_PWD_ACTION = 'Change';
    public static final String GA_SEGMENT_CHANGE_CATEGORY = 'Password';        
    public static final String GA_SEGMENT_EMAIL_LABEL = 'Email Sent';   
    public static final String GA_SEGMENT_EVENT_ENDPOINT = 'https://api.segment.io/v1/track';     
        
    
    //Opportunity Status Log fields
    public static final String OBJ_OP_STATUS_LOG = 'CHL_Opportunity_Status_Log__c';
    public static final String OBJ_OPSL_FIELD_NAMES = 'CHL_Field_API_Names__c';
    public static final String OBJ_OPSL_DAYS_UPDATES = 'CHL_Days_between_Update__c';
    public static final String OBJ_OPSL_QUOTE_PDF_OPTION = 'CHL_Quote_PDF_Option__c';
    public static final String OBJ_OPSL_DAYS_BEFORE_EXPIRATION = 'CHL_Days_before_Expiration__c';
    public static final String OBJ_OPSL_QUOTE_PDF_OPTION_QUOTEPDF = 'Quote PDF';
    public static final String OBJ_OPSL_QUOTE_PDF_OPTION_NOTES = 'Notes & Attachment';
    public static final String OBJ_OPSL_AVAILABLE_SALES_STAGES = 'CHL_Available_Sales_Stages__c';
    public static final String OBJ_OPSL_PIPELINE_SALES_STAGES = 'CHL_Display_Pipeline_Sales_Stages__c';
   public static final String OBJ_OPSL_IS_UNAVAILABLE_SALES_STAGE = 'CHL_Show_Oppty_for_Unavailable_Stage__c';
    
    public static final String STR_SUCCESS = 'Success';
    
    public static final String STR_PIPELINE_STAGES = 'PipeLineStages';
    public static final String STR_AVLBL_STAGES = 'AvlblStages';
    public static final String STR_EXCLUDE_STAGES = 'ExcludeStages';
    
    //Partner Opportunity Fields    
    public static final String OBJ_PARTNER_OPPORTUNITY = 'CHL_Partner_Opportunity__c';
    public static final String OBJ_PO_SALES_STAGE = 'CHL_Sales_Stage__c';
    public static final String OBJ_PO_AMOUNT = 'CHL_Amount__c';
    public static final String OBJ_PO_CLOSE_DATE = 'CHL_Close_Date__c';
    public static final String OBJ_PO_PROBABILITY = 'CHL_Probability__c';
    public static final String OBJ_PO_OPPTY = 'CHL_Opportunity__c';
    public static final String OBJ_PO_LASTUPDATE = 'CHL_Last_Status_Update_Date__c';
    public static final String OBJ_PO_EXPIRATIONDATE = 'CHL_Expiration_Date__c';
    public static final String OBJ_PO_NEED_STATUS_UPDATE = 'CHL_Needs_Status_Update__c';
    public static final String FL_OPPORTUNITY = 'CHL_Opportunity__c';
    public static final String FL_ID = 'Id';
    public static final String OBJ_PO_OPPTY_ACCOUNT_NAME = 'CHL_Opportunity_Account_Name__c';
    public static final String OBJ_PO_RESELLER_REP = 'CHL_Partner_Account_1_Contact__c';
    public static final String OBJ_PO_DISTRIBUTOR_REP = 'CHL_Partner_Account_2_Contact__c';
    public static final String OBJ_PO_RESELLER_REP_NAME = 'CHL_Partner_Account_1_Contact__r';
    public static final String OBJ_PO_DISTRIBUTOR_REP_NAME = 'CHL_Partner_Account_2_Contact__r';    
    public static final String OBJ_PO_RESELLER_REP_NAME_COL = 'CHL_Partner_Account_1_Contact__r.name';
    public static final String OBJ_PO_DISTRIBUTOR_REP_NAME_COL = 'CHL_Partner_Account_2_Contact__r.name';    
    public static final String OBJ_PO_PARTNER_ACC1 = 'CHL_Partner_Account_1__c';
    public static final String OBJ_PO_PARTNER_ACC2 = 'CHL_Partner_Account_2__c';
    public static final String OBJ_PO_PARTNER_ACC1_TYPE = 'CHL_Partner_Account_1_Type__c';
    public static final String OBJ_PO_PARTNER_ACC2_TYPE = 'CHL_Partner_Account_2_Type__c';
    public static final String OBJ_PO_INCUMBENT = 'CHL_Incumbent__c';
    public static final String OBJ_PO_SYNCING = 'CHL_Syncing__c';
    public static final String OBJ_PO_CURRENCYISOCODE = 'CurrencyISOCode';
    public static final String OBJ_PO_STATUS = 'CHL_Status__c';
    public static final String OBJ_PO_NAME = 'Name';
    public static final String OBJ_PO_MO_ACCOUNT = 'CHL_Opportunity__r.AccountId';
    public static final String OBJ_RENEWS_STR = 'renewals';
    public static final String SYNCING_OPTION_FROM_MO = 'From Master Opportunity';
    public static final String SYNCING_OPTION_TO_MO = 'To Master Opportunity';
         
    //Object Name
    public static final String OBJ_PT_OPPORTUNITY = 'CHL_Partner_Opportunity__c';
    public static final String OBJ_PT_Opportunity_Share = 'CHL_Partner_Opportunity__Share';
    public static final String OBJ_OPPORTUNITYSHARE = 'OpportunityShare';
    public static final String OBJ_CONTACT = 'Contact';
    public static final String OBJ_CASE = 'Case';
    public static final String OBJ_CONTACT_STR = 'contacts';
    public static final String OBJ_OPP_DETAILS = 'details';
    public static final String OBJ_PT_RENEWAL_RELATIONSHIP = 'CHL_Partner_Renewal_Relationship__c';
    public static final String OBJ_NOTE = 'Note';
    public static final String OBJ_NOTE_BODY ='Body';
    public static final String OBJ_NOTES_STR = 'Notes';
    
    public static final String STR_USERGROUPID = 'UserorGroupId';
    public static final String STR_ROWCAUSE = 'RowCause';
    public static final String STR_SHARE_REASON = 'CHL_Manual_Share_Reason__c';
    public static final String STR_MANUAL = 'Manual';
    public static final String STR_OPPOTUNITYID = 'OpportunityId';
    public static final String STR_OPPOTUNITYACCESS = 'OpportunityAccessLevel';
    public static final String STR_PARENT = 'ParentId';
    public static final String STR_ACCESSLEVEL = 'AccessLevel'; 
    public static final String STR_EDIT = 'Edit';
    public static final string STR_PARTNER_USER_TYPE = 'PowerPartner';
    
    public static final String CUSTOM_OBJ_NAME = 'name';
    public static final String FLD_MAP_OWNERID  = 'OwnerId';
    
    //Opportunity
    public static final String OBJ_OPP_SYNCE_QUOTE_ID = 'syncedquoteid';
    public static final String OBJ_OPP_SYNCE_QUOTE_NAME = 'SyncedQuote.Name';
    
    //Quote
    public static final String OBJ_QUOTE = 'Quote';
    public static final String OBJ_QUOTE_STR = 'quotes';
    public static final String OBJ_QUOTE_EXPIRATION_DATE = 'ExpirationDate';
    public static final String OBJ_QUOTE_OPPTY_ID = 'Quote.OpportunityId';
    public static final String OBJ_QUOTE_ID = 'Quote.Id';
    public static final String OBJ_QUOTE_PDF = 'QuoteDocument';
    public static final String OBJ_QUOTE_PARTNER_OPPTY_ID = 'Quote.CHL_Partner_Opportunity__c';    
    public static final String OBJ_QUOTE_PARTNER_PRIMARY = 'CHL_Partner_Primary__c';
    public static final String OBJ_QUOTE_PDF_NAME = 'Name';
    public static final String OBJ_QUOTE_PDF_Id = 'Id';
    public static final String OBJ_QUOTE_PDF_PARTNER_PRIMARY = 'Quote.CHL_Partner_Primary__c';
    public static final String OBJ_QUOTE_QUOTENUMBER = 'QuoteNumber';
    public static final String OBJ_QUOTE_PDF_DOCUMENT = 'Document';
    public static final String OBJ_QUOTE_TOTAL = 'GrandTotal';
    public static final String OBJ_CASE_SHARE = 'CaseShare';
     
    //QuoteLineItem
    public static final String OBJ_QUOTELINEITEM = 'QuoteLineItem';
    public static final String OBJ_QUOTELI_QUOTEID = 'QuoteId';
    public static final String OBJ_QUOTELI_END_DATE = 'CHL_End_Date__c';
    public static final String OBJ_QUOTELI_START_DATE = 'CHL_Start_Date__c';
    public static final String OBJ_QUOTELI_ASSET = 'CHL_Asset__c';
    public static final String OBJ_QUOTELI_PRICEBOOKENTRYID = 'PricebookEntryId';
    public static final String OBJ_QUOTELI_QTY = 'Quantity';
    public static final String OBJ_QUOTELI_TOTPRICE = 'Subtotal';//'TotalPrice'; //
    public static final String OBJ_QUOTELI_MSRP = 'CHL_MSRP__c';
    
    //CHL_Partner_Renewal_Relationship__c
    public static final String OBJ_PARTNER_REN_REL_FLD = 'CHL_Renewal_Relationship__c';
    
    
    //Trigger 
    public static Boolean PARTNEROPPORTUNITY_BEFORE_TRIGGER = true; 
    public static Boolean PARTNEROPPORTUNITY_AFTER_TRIGGER = true; 
    public static Boolean PORTALGROUP_BEFORE_TRIGGER = true;
    public static Boolean USER_AFTER_TRIGGER = true;
    
    
    //Filter options for Opportunity Grid
    public static final String FILTER_OPTION_NONE = system.label.CSM_LBL_NONE;
    public static final String FILTER_OPTION_OPTY_QUOTES = system.label.CHL_LBL_OPEN_OPP_QUOTES;
    public static final String FILTER_OPTION_OPEN_OPPORTUNITY = system.label.CHL_LBL_OPEN_OPP;
    public static final String FILTER_OPTION_CLOSED_OPPORTUNITY = system.label.CHL_LBL_CLOSE_OPP;
    public static final String FILTER_OPTION_WON_OPPORTUNITY = system.label.CHL_LBL_WON_OPP;
    public static final String FILTER_OPTION_LOST_OPPORTUNITY = system.label.CHL_LBL_LOST_OPP;
    public static final String FILTER_OPTION_STATUS_UPDATE = system.label.CHL_LBL_NEED_STATUS_UPDATES;
    public static final String FILTER_OPTION_NEW_LAST_WEEK = system.label.CHL_LBL_NEW_LAST_WEEK;
    public static final List<String> PREDEFINED_FILTER_OPTIONS = new List<String>{FILTER_OPTION_NONE,
                                                            FILTER_OPTION_OPTY_QUOTES, 
                                                            FILTER_OPTION_OPEN_OPPORTUNITY, 
                                                            FILTER_OPTION_CLOSED_OPPORTUNITY,
                                                            FILTER_OPTION_WON_OPPORTUNITY, 
                                                            FILTER_OPTION_LOST_OPPORTUNITY, 
                                                            FILTER_OPTION_STATUS_UPDATE,FILTER_OPTION_NEW_LAST_WEEK};
    public static final List<String> RELATED_TO = new List<String> {'Opportunity','Quote','Asset','Service Contract'};                                                           
    public static final List<String> EXCLUDE_STAGES = new List<String>{'Closed Won','Closed Lost'};
    public static final String STR_OPPORTUNITIES = 'Opportunities';
    public static final String STR_SERVICE_CONTRACT = 'Service Contract';
    public static final String OBJ_SERVICE_CONTRACT = 'ServiceContract';
    public static final String OBJ_OPPORTUNITY = 'Opportunity';
     
     //Expiered Matrix
     public static final String EXP_MATRIX_COUNT = 'oppCounts';
     public static final String EXP_MATRIX_STAGE = 'stage';
     public static final String EXP_MATRIX_AMOUNT = 'sumAmount';
     
     //Data Type
     public static final String PICKLIST = 'PICKLIST';
     public static final String TYPE_CURRENCY = 'CURRENCY';
     public static final String TYPE_DATE = 'DATE';
     public static final String TYPE_PERCENT = 'PERCENT';
     public static final String TYPE_DATE_TIME = 'DateTime';
     public static final String TYPE_BOOLEAN = 'Boolean';
     public static final String TYPE_STRING = 'STRING';
 
     //Grid Data Type
     public static final String GRID_TYPE_PROBABILITY = 'PROBABILITY';
     public static final String GRID_TYPE_MULTI_CURRENCY = 'MULTI_CURRENCY';
    
     //String value
     public static final String STR_NONE = '---None---';
     public static final String STR_RELATED_TO ='Related To';
     public static final String STR_CURRENCY_CODE = 'currencyCode';
     
     //Maping  
     public static final String FLD_MAP_PARTNER_OPPT_TO_MASTER_OPPT = system.label.CHL_LBL_PARTNER_OPPTY_TO_MASTER_OPPTY;
     
     //Attachment
     public static final String OBJ_ATTACHMENT = 'Attachment';
     public static final String OBJ_ATT_LAST_MODIFIED_DATE = 'LastModifiedDate';
     public static final String OBJ_ATT_LAST_MODIFIED_BY = 'LastModifiedBy';
     public static final String OBJ_ATT_LAST_MODIFIED_BY_NAME ='LastModifiedBy.name';
     
     
     //API names for Columns in the Opportunity Grid
     public static final String GRID_COLUMN_QUOTE_PDF = 'Latest_Quote';
     public static final String GRID_COLUMN_RESELLER = 'Reseller_Rep';
     public static final String GRID_COLUMN_DISTRIBUTOR = 'Distributor_Rep';
     public static final Set<String> GRID_COLUMNS = new Set<String>{OBJ_PO_NAME,
                                                            OBJ_PO_OPPTY_ACCOUNT_NAME,
                                                            OBJ_PO_SALES_STAGE, 
                                                            OBJ_PO_PROBABILITY, 
                                                            OBJ_PO_AMOUNT,
                                                            OBJ_PO_EXPIRATIONDATE, 
                                                            OBJ_PO_CLOSE_DATE, 
                                                            OBJ_PO_PARTNER_ACC1_TYPE,
                                                            OBJ_PO_PARTNER_ACC2_TYPE,
                                                            OBJ_PO_RESELLER_REP,
                                                            OBJ_PO_DISTRIBUTOR_REP,
                                                            GRID_COLUMN_QUOTE_PDF,
                                                            OBJ_PO_NEED_STATUS_UPDATE,
                                                            OBJ_PO_STATUS,
                                                            'CHL_Partner_Account_1__c',
                                                            'CHL_Partner_Account_2__c',
                                                            'CHL_MSRP__c'
                                                        };
    
    //Pipeline Chart
    public static final String STR_OPP_UPDATED_STATUS = 'Opportunities with updated status';
    public static final String STR_OPP_NEED_STATUS_UPDATE = 'Opportunities that need a status update';
    public static final String STR_TOTAL = 'Total';
    public static final String STR_ALL = 'All';
    public static final String STR_RESELLER = 'Reseller';
    public static final String STR_DISTRIBUTOR = 'Distributor';
    public static final String STR_COUNTRY = 'Country';
    
    //For Quote Sync Email 
    public static final String QUOTES_SYNC_EMAIL_SUBJECT = system.label.CHL_LBL_QUOTE_EMAIL_SUB; 
    public static final String QUOTES_SYNC_EMAIL_TEXT1 = system.label.CHL_LBL_QUOTE_EMAIL_BODY_1;
    public static final String QUOTES_SYNC_EMAIL_TEXT2 = system.label.CHL_LBL_QUOTE_EMAIL_BODY_2;
    public static final String QUOTES_SYNC_EMAIL_FROM = 'Admin Support';
    
    //FieldSet Fields
    public static final String ACCOUNT_DETAILS_FIELDSET_NAME = 'CHL_AccountDetails_Fieldset';
    public static final String CASE_DETAILS_FIELDSET_NAME = 'CHL_CaseDetails_Fieldset';
    public static final String CONTACT_DETAILS_FIELDSET_NAME = 'CHL_ContactDetails_Fieldset';
    public static final String QUOTE_DETAILS_FIELDSET_NAME = 'CHL_QuoteDetails_Fieldset';
    public static final String QUOTE_LIST_FIELDSET_NAME = 'CHL_QuoteList_FieldSet';
    public static final String PARTNER_OPP_DETAILS_FIELDSET_NAME = 'CHL_Partner_Opportunity_Details';
    public static final String PARTNER_REN_RELATIONSHIP_FIELDSET_NAME = 'CHL_RenRelationship_Details_Fieldset';
    public static final String PARTNER_OPPORTUNITY_FROM_NAME = 'Partner_OPP';
    public static final String PARTNER_RENEWAL_RELATIONSHIP_FIELDSET_NAME = 'CHL_PartnerRenRelationship_FieldSet';
    
    //Case fields
    public static final String CASE_NUMBER = 'CaseNumber';
    public static final String CASE_ACCOUNT_NAME = 'Account.name';
    public static final String CASE_STATUS = 'Status';
    public static final String CASE_CREATED_DATE = 'CreatedDate';
    public static final String CASE_CLOSED_DATE = 'ClosedDate';
    public static final String CASE_CREATED_BY_NAME = 'CreatedBy.name';
    public static final String CASE_DESCRIPTION = 'Description';
    public static final String CASE_SUBTYPE = 'CHL_CaseSubtype__c';
    public static final String CASE_ACCOUNTID = 'AccountId';
    public static final String CASE_ACCOUNT = 'Account';
    public static final String CASE_CREATED_BY = 'CreatedBy';
    public static final String CASE_PRIORITY = 'Priority';
    public static final String CASE_SUBJECT = 'Subject';
    public static final String CASE_RELATED_TO_TXT = 'CHL_Related_To_Text__c';
    public static final String CASE_RELATED_TO = 'CHL_Related_To__c';
    public static final String STR_RENEWAL_SALES_REQUEST = 'Renewal Sales Request';
    
    //CaseComment
    public static final String OBJ_CASECOMMENT = 'CaseComment'; 
    public static final String OBJ_CASECOMM_COMMENTBODY = 'CommentBody';
    public static final String OBJ_CASECOMM_CREATED_BY_ID= 'CreatedById';
    
    
    
    //API names for Columns in the Request Grid
    public static final Set<String> GRID_CASE_COLUMNS = new Set<String>{CASE_NUMBER,
                                                                    CASE_ACCOUNTID,
                                                                    CASE_STATUS,
                                                                    CASE_CREATED_DATE,
                                                                    CASE_CLOSED_DATE,
                                                                    CASE_CREATED_BY,
                                                                    CASE_DESCRIPTION,
                                                                    CASE_SUBTYPE,
                                                                    CASE_SUBJECT,
                                                                    CASE_RELATED_TO_TXT};
                                                                    
    //API names for Columns in the Case Attachment Grid
    public static final Set<String> GRID_CASE_ATTACHMENT_COLUMNS = new Set<String>{OBJ_PO_NAME,
                                                                    OBJ_ATT_LAST_MODIFIED_DATE,
                                                                    OBJ_ATT_LAST_MODIFIED_BY,
                                                                    OBJ_CASECOMM_CREATED_BY_ID,
                                                                    CASE_CREATED_DATE};
                                                                    
    //Filter options for Request Grid    
    public static final String FILTER_OPTION_MY_OPEN_REQ_CASE = system.label.CHL_LBL_MY_OPEN_REQUESTS;
    public static final String FILTER_OPTION_CLOSE_REQ_CASE = system.label.CHL_LBL_MY_CLOSED_REQUESTS;
    public static final String FILTER_OPTION_ALL_REQUEST = system.label.CHL_LBL_ALL_REQUESTS;
    public static final List<String> PREDEFINED_FILTER_CASE_OPTIONS = new List<String>{FILTER_OPTION_MY_OPEN_REQ_CASE,
                                                            FILTER_OPTION_CLOSE_REQ_CASE,
                                                            FILTER_OPTION_ALL_REQUEST };
                                                            
    //below list will be used to check CRUD permission on Partner Opportunity Object
    public static final List<String> PARTNER_OPP_FEILD_LIST = new List<String>{OBJ_PO_SALES_STAGE, 
                                                    OBJ_PO_AMOUNT, 
                                                    OBJ_PO_CLOSE_DATE, 
                                                    OBJ_PO_PROBABILITY, 
                                                    OBJ_PO_OPPTY, 
                                                    OBJ_PO_RESELLER_REP,
                                                    OBJ_PO_DISTRIBUTOR_REP,
                                                    OBJ_PO_LASTUPDATE,
                                                    OBJ_PO_EXPIRATIONDATE,
                                                    OBJ_PO_NEED_STATUS_UPDATE,
                                                    OBJ_PO_PARTNER_ACC1_TYPE,
                                                    //OBJ_PO_PARTNER_ACC2_TYPE,
                                                    OBJ_PO_PARTNER_ACC1,
                                                    OBJ_PO_PARTNER_ACC2,
                                                    OBJ_PO_STATUS,
                                                   // OBJ_PO_SYNCING,
                                                    OBJ_PO_INCUMBENT,
                                                    'CHL_EQ__c',
                                                    'CHL_FY__c',
                                                    //'CHL_MSRP__c',
                                                    'CHL_AddsAmount__c',
                                                    'CHL_Color_Commit__c',
                                                    'CHL_First_Quote_Completed_Date__c'
                                                    };
                                                    
    //Asset & SC Fields
    public static final String OBJ_ASSET_SERIAL_NUMBER = 'SerialNumber';
    public static final String OBJ_ASSET_PRODUCT = 'Product2Id';
    public static final String OBJ_ASSET_QUANTITY = 'Quantity';
    public static final String OBJ_ASSET_PRICE = 'Price';
    public static final String OBJ_ASSET_STATUS = 'Status';
    public static final String OBJ_ASSET_START_DATE = 'REN_Start_Date__c';
    public static final String OBJ_ASSET_END_DATE = 'REN_End_Date__c';
    public static final String OBJ_ASSET_PRODUCT2 = 'Product2';
    
    //API names for Columns in the Asset Grid
    public static final Set<String> GRID_ASSET_COLUMNS = new Set<String>{CUSTOM_OBJ_NAME,
                                                                    OBJ_ASSET_SERIAL_NUMBER,
                                                                    OBJ_ASSET_PRODUCT,
                                                                    OBJ_ASSET_QUANTITY,
                                                                    OBJ_ASSET_PRICE,
                                                                    OBJ_ASSET_STATUS,
                                                                    OBJ_ASSET_START_DATE,
                                                                    OBJ_ASSET_END_DATE};
                                                                    
    //API names for Columns in the Contract Line Item Grid
    public static final Set<String> GRID_CONTRACT_LI_COLUMNS = new Set<String>{REN_Constants.OBJ_SERVICE_CONTRACT_ID,
                                                                    REN_Constants.OBJ_SC_CONTRACT_NO,
                                                                    REN_Constants.OBJ_SCLI_LINEITEMNUMBER,
                                                                    REN_Constants.OBJ_ASSET_PRODUCT2ID,
                                                                    REN_Constants.OBJ_SCLI_QUANTITY,
                                                                    REN_Constants.OBJ_SC_TOTAL_PRICE,
                                                                    REN_Constants.OBJ_SCLI_STATUS,
                                                                    REN_Constants.OBJ_SCLI_STARTDATE,
                                                                    REN_Constants.OBJ_SCLI_ENDDATE};
    //Portal Groups & Portal Group Members
    public static final String OBJ_PORTAL_GROUP = 'CHL_Portal_Group__c';
    public static final String OBJ_PORTAL_DESC = 'CHL_Description__c';
    public static final String OBJ_PORTAL_HIERAR = 'CHL_Roll_Up_Hierarchy__c';
    public static final String OBJ_PORTAL_MEM_ACCNT = 'CHL_Partner_Account__c';
    public static final String OBJ_PORTAL_MEM_MASTER = 'CHL_Portal_Group__c';
    public static final String OBJ_PORTAL_GROUP_MEM = 'CHL_Portal_Group_Member__c';
    public static final String OBJ_PORTAL_GROUP_PUB_GRP_ID = 'CHL_Public_Group__c';
    public static final String OBJ_PORTAL_MEM_USER = 'CHL_Partner_User__c';
    public static final String OBJ_PORTAL_GROUP_REL_MEM = 'CHL_Related_Group_Member__c';
    
    //Portal Reports
    public static final String PORTAL_REPORTS_USER_PREF = 'CHL_Selected_Community_Reports__c';
    public static final String OBJ_SERVICECONTRACT = system.label.CHL_SERVICE_CONTRACT;
    
    //Portal Contents
    public static final String OBJ_PORTAL_CONTENT = 'CHL_Portal_Content__c';
    
    //Sales Stage Mapping
    public static final String OBJ_SALES_STAGE_MAPPING= 'CHL_Sales_Stage_Mapping__c';
    public static final String OBJ_FLD_MO_SALES_STAGE= 'CHL_Master_Opportunity_Sales_Stage__c';
    public static final String OBJ_FLD_PO_SALES_STAGE= 'CHL_Partner_Opportunity_Sales_Stage__c';
    public static final String OBJ_FLD_PO_TYPE= 'CHL_Partner_Opportunity_Type__c';
    
    //User Object
    public static final String OBJ_USER_FLD_CURRENCY_ISO = 'DefaultCurrencyIsoCode';
    
    //US2049 -- String for Data Grid Attribute
    public static final String QUOTE_ON_PO = 'quoteOnPO';
    public static final String QUOTE_ON_PO_OBJ = 'quoteOnPOObj';
    
    //US2155 - Channel Query Builder
    public static final String TYPE_SELECT = 'SELECT';
    public static final String TYPE_NUMBER = 'NUMBER';
    public static final String TYPE_TEXT = 'TEXT';
}