/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.21.2014
* @description    SS_Constants class encapsulates all the Service Source constants  
*/
public with sharing class SS_Constants {
    //License Type
    public static final String SS_LICENSE_TYPE_CSM = 'CSM';
    public static final String SS_NO_LICENSE_MSG = 'User does not have access to Admin features!!!';
    public static final String SS_LICENSE_TYPE_RENEW = 'Renew';
    public static final String SS_LICENSE_TYPE_CHANNEL = 'Channel';

   /*public static final String USER_TYPE_CSM = 'CSM';
    public static final String USER_TYPE_CSM_NETOPS = 'CSM_NetOps';
    public static final String USER_TYPE_RENEW = 'Renew';
    public static final String USER_TYPE_RENEW_NETOPS = 'Renew_NetOps';
    public static final String USER_TYPE_CHANNEL = 'Channel';
    public static final String USER_TYPE_CHANNEL_NETOPS = 'Channel_NetOps';
    public static final String USER_TYPE_CHANNEL_COMMUNITY = 'Channel_Community';
    public static final String USER_TYPE_SOLEXT_SYSTEM_ADMIN_USER = 'SystemAdminUser';
    public static final String USER_TYPE_SOLEXT_INTEGRATION_USER = 'IntegrationUser';
    public static final String USER_TYPE_SOLEXT_DATASERVICE_USER= 'DataServicesUser';
    public static final String USER_TYPE_PLAYMAKER = 'REN_Playmaker';
    public static final String USER_TYPE_SOLEXT_SALES_MANAGER =  'SalesManager';
    public static final String USER_TYPE_SOLEXT_OPS_MANAGER =  'OperationServicesEditUser';
    public static final String USER_TYPE_SOLEXT_LT_INTEGRATOR='LT_Self_Serve_Integrator';
    
     
    public static Boolean isCSMUser = false;
    public static Boolean isCSMNetOpsUser = false;
    public static Boolean isRenewUser = false;
    public static Boolean isRenewNetOpsUser = false;
    public static Boolean isChannelUser = false;
    public static Boolean isChannelNetOpsUser = false;
    public static Boolean isChannelCommunityUser = false;
    public static Boolean isSolExtSystemAdminUser = false;
    public static Boolean isSolExtIntegrationUser = false;
    public static Boolean isSolExtDataServicesUser = false;
    public static Boolean isPlaymakerUser = false;
    public static Boolean isSolExtSalesManager = false;
    public static Boolean isSolExtOpsManager = false;
    public static Boolean isSolExtLTIntegrator=false;*/
    
    public static final String PS_CanCreateOpportunity = 'CanCreateOpportunity';
	public static final String PS_CanEditDelOpptLineItem = 'CanEditDelOpptLineItem';
	public static final String PS_DataServicesUser = 'DataServicesUser';
	//public static final String PS_EnableSolExtnFeature = 'EnableSolExtnFeature';
	public static final String PS_IntegrationUser = 'IntegrationUser';
	public static final String PS_OperationServicesEditUser = 'OperationServicesEditUser';
	public static final String PS_OperationServicesUser = 'OperationServicesUser';
	//public static final String PS_ReadOnlyUser = 'ReadOnlyUser';
	public static final String PS_SalesManager = 'SalesManager';
	public static final String PS_SalesRep = 'SalesRep';
	//public static final String PS_SalesUser = 'SalesUser';
	//public static final String PS_SolExtChannelUser = 'SolExtChannelUser';
	public static final String PS_SystemAdminUser = 'SystemAdminUser';
	public static final String PS_CanEditCases='CanEditCases';
	public static final String PS_REN_Playmaker = 'REN_Playmaker';
	public static final String PS_LT_Self_Serve_Integrator = 'LT_Self_Serve_Integrator';
	public static final String PS_ChannelCommunity='Channel_Community';
	public static final String PS_ManageFocusCategory='PRISM_Manage_Focus_Categories';
	public static final String PS_IBExportUser = 'PRISM_IB_Export';
	public static final String PS_Mass_Transfer_Opportunities = 'PRISM_Mass_Transfer_Opportunities';
	public static final String PS_Edit_Closed_Sale_Opportunities = 'Prism_Edit_Closed_Sale_Opportunities';
    //Sol Ext permission sets
    public static final String PS_Business_Analyst = 'PRISM_Business_Analyst';
    
    public static Boolean isSimplifiedDataModelEnabled=SS_License__c.getOrgDefaults().Simplified_Data_Model_Is_Enabled__c; //TODO: Need to change logic. Set Custom setting field here.

}