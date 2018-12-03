public with sharing class CHL_OpptyStatusLogDataAccess {
    public static List<CHL_Opportunity_Status_Log__c> opptyStatusLogList {
        get{
            if(opptyStatusLogList == null){
                opptyStatusLogList = getChannelOptyStatusLogData();
            }
            return opptyStatusLogList;
        }
    }
    /*
    	@Description : This variable will hold 	CHL_Opportunity_Status_Log__c data for guest user, created for US3395
    */
    public static List<CHL_Opportunity_Status_Log__c> opptyStatusLogListGuestUser {
        get{
            if(opptyStatusLogListGuestUser == null){
                opptyStatusLogListGuestUser = getChannelOptyStatusLogDataForGuestUser();
            }
            return opptyStatusLogListGuestUser;
        }
    }
    
    public static List<CHL_Opportunity_Status_Log__c> getChannelOptyStatusLogData() {
        List<String> ChlStatusLogFields = new List<String>{'CHL_Field_API_Names__c',
														   'CHL_Days_between_Update__c',
														   'CHL_Quote_PDF_Option__c',
														   'CHL_Days_before_Expiration__c',
														   'CHL_Available_Sales_Stages__c',
														   'CHL_Display_Pipeline_Sales_Stages__c',
														   'CHL_Show_Oppty_for_Unavailable_Stage__c',
                                                           'CHL_Enable_2_Tier_Pricing__c',
                                                           'CHL_Active_Languages__c',
                                                           'CHL_Exclude_Sales_Stages__c',
                                                           'CHL_Create_New_Quote_On_Destination_PO__c'
                                                           };
        CSM_Util.checkCRUD_FLS('CHL_Opportunity_Status_Log__c', ChlStatusLogFields, 'Read'); 
        return [SELECT Id, CHL_Field_API_Names__c,CHL_Show_Oppty_for_Unavailable_Stage__c, CHL_Days_between_Update__c,CHL_Display_Pipeline_Sales_Stages__c,CHL_Exclude_Sales_Stages__c,CHL_Quote_PDF_Option__c,CHL_Days_before_Expiration__c,CHL_Available_Sales_Stages__c, CHL_Enable_2_Tier_Pricing__c,CHL_Active_Languages__c, CHL_Create_New_Quote_On_Destination_PO__c from CHL_Opportunity_Status_Log__c limit 1];
    }
    
    public static void upsertOpportunityStatusLogList(List<CHL_Opportunity_Status_Log__c> optyStatusLogList){
        List<String> ChlStatusLogFields = new List<String>{CHL_Constants.OBJ_OPSL_FIELD_NAMES, 
                                                           CHL_Constants.OBJ_OPSL_DAYS_UPDATES,
                                                           CHL_Constants.OBJ_OPSL_QUOTE_PDF_OPTION,
                                                           CHL_Constants.OBJ_OPSL_DAYS_BEFORE_EXPIRATION,
                                                           CHL_Constants.OBJ_OPSL_AVAILABLE_SALES_STAGES,
                                                           CHL_Constants.OBJ_OPSL_IS_UNAVAILABLE_SALES_STAGE,
                                                           'CHL_Active_Languages__c',
                                                           'CHL_Exclude_Sales_Stages__c',
                                                           'CHL_Display_Pipeline_Sales_Stages__c',
                                                           'CHL_Create_New_Quote_On_Destination_PO__c'};
        CSM_Util.checkCRUD_FLS(CHL_Constants.OBJ_OP_STATUS_LOG, ChlStatusLogFields, CSM_Constants.DML_OPERATION_UPSERT); 
        upsert optyStatusLogList;
    }
    
    /*
    	@Description : This method is created for US3395, to get data for guest user. 
    				   Guest user is only concerned with Active Language field of Opportunity Status Log field. So just need to check that field for FLS CRUD.
    */
    public static List<CHL_Opportunity_Status_Log__c> getChannelOptyStatusLogDataForGuestUser() {
        List<String> ChlStatusLogFields = new List<String>{'CHL_Active_Languages__c'};
        CSM_Util.checkCRUD_FLS('CHL_Opportunity_Status_Log__c', ChlStatusLogFields, 'Read'); 
        return [SELECT Id, CHL_Active_Languages__c from CHL_Opportunity_Status_Log__c limit 1];
    }
}