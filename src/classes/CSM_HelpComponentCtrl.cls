/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		11.24.2014
 * @description	CSM_HelpExtension  
 */
 
public with sharing class CSM_HelpComponentCtrl {
	

	public String urlString {get; set;}
	public String communityUrlString {get; set;}
	public CSM_HelpLinks__c HelpLinkSettings {get; set;}  
	private String path; 
	
	public CSM_HelpComponentCtrl()  
	{
		helpLinkSettings = CSM_AdminDataAccess.getCSMHelpLinksInstance(); 
		urlString = '';
		communityUrlString = '';
		if(helpLinkSettings != null)
		{
			urlString = helpLinkSettings.CSM_Base_Url__c;
			communityUrlString = helpLinkSettings.CSM_Community_URL__c;
			
		}
	}
	/* Method: buildURL 
	 * Description: gets the specific page parameter for the url
	 */
	public void buildUrl() {
		
			if(param.toUpperCase() == CSM_Constants.HELP_OVERVIEW.toUpperCase()) 
			{
				urlString += helpLinkSettings.CSM_Overview__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_SEGMENT_DETAIL.toUpperCase())
			{
				urlString += helpLinkSettings.segment_overview__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_CREATE_EDIT_PLAYBOOKS_PLAYS.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Playbooks_and_Play__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_FOCUS_CATEGORY_GROUPS_CREATE_EDIT.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Focus_Category_Groups_Create_Edit__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATES_EDIT.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Success_Plan_Templates_Edit__c	;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_BATCH_FILTER_ACTIVITY.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Batch_Filter_Activity__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_MULTI_SELECT_REPORTING.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Multi_Select_Reporting__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_CONSOLIDATION_REQUEST_LOGS.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Consolidation_Request_Logs__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_AUTOMATED_GENERATION_LOG.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Automated_Generation_Log__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_BATCH_GENERATION_ACTIVITY.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Batch_Generation_Activity__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_INSTALL_BASE_DATA_RULE.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Install_Base_Data_Rules__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_OPPORTUNITY_GENERATION.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Opportunity_Generation__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_OPPORTUNITY_UPDATES.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Opportunity_Updates__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_MAPPINGS.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Mappings__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_MAPPINGS_ADD_FIELD.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Mappings_Add_Field__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_CHANNEL_PORTAL_CONFIGURATION.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Channel_Portal_Configuration__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_RENEWAL_PARTNER_DATA_SYNC.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Renewals_Partner_Data_Syncing__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_CONSOLIDATE_OPPORTUNITY.toUpperCase())
			{
				urlString += helpLinkSettings.Consolidate_Opportunity__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_QUOTE_REQUEST_LOG.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Quote_Request_Log__c;
			}else if (param.toUpperCase() == CSM_Constants.HELP_LOW_TOUCH.toUpperCase())
			{
				urlString += helpLinkSettings.Admin_Low_Touch__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_SUCCESS_PLAN_HOME.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Success_Plan_Home__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_SUCCESS_PLAN_DETAILS.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Success_Plan_Details__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_FOCUS_CATEGORY_GROUPS.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Focus_Category_Groups__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_FOCUS_CATEGORY_VIEWS.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Focus_Category_Views__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_FOCUS_CATEGORIES.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Focus_Category_Views__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_INDICATOR_GROUPS.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Indicator_Groups__c;	
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATES.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Success_Plan_Templates__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_PLAYBOOKS.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Playbooks__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_PLAYS.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Plays__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_SUCCESS_TASKS)
			{
				urlString += helpLinkSettings.CSM_Success_Tasks__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_PLAY_CRITERIA.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Play_Criteria__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_PLAY_TASK.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Play_Tasks__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_TASK_COMPLETE.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Task_Complete__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_TASK_DISMISS.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Task_Dismiss__c;
			}
			else if (param.toUpperCase() == CSM_CONSTANTS.HELP_HEALTH_DONUT.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Health_Donut_Chart__c;
			}
			else if (param.toUpperCase() == CSM_CONSTANTS.HELP_HEALTH_MAP.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Health_Heatmap_Chart__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_PLAN_DETAILS_SUBTAB.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Success_Plan_Details_Subtab__c;
			}
			else if(param.toUpperCase() == CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATE_PHASES.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Plan_Phases__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATE_PLAYBOOKS.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Plan_Playbooks__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATE_INDICATORS.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Plan_Indicators__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_ADMIN_TAB.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Tab__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_TASK_GENERATION_ACTIVITY.toUpperCase())
			{
				urlString += helpLinkSettings.CSM_Admin_Task_Generation_Activity__c;
			}
			else if (param.toUpperCase() == CSM_Constants.HELP_SEARCH_AND_MOVE_DETAIL.toUpperCase())
			{
				//urlString += helpLinkSettings.REN_Search_and_Move_RR__c;
				if ('search-and-move'.equalsIgnoreCase(helpLinkSettings.REN_Search_and_Move_RR__c)) {
					urlString = 'https://prism.helpdocsonline.com/search-move';
				} else {
					urlString = helpLinkSettings.REN_Search_and_Move_RR__c;
				}
			} 
			else if (param.toUpperCase() == CSM_Constants.HELP_ORGANIZE_FOCUS_CATEGORIES.toUpperCase()) 
			{
				urlString += helpLinkSettings.CSM_Organize_Focus_Category_Views__c;
			}		
	}	
	public String param {
		get {
			return param;
		}
		set {
				if(String.isEmpty(param) && value != null)
				{
					param = value;
					buildUrl();
				}
		}
	}
	public String textParam {
		get {
			return textParam;
		}
		set {
			if(String.isEmpty(textParam) && value != null)
			{
				textParam = value;
			}
			else if(String.isEmpty(textParam) && value == null)
			{
				textParam = Label.CSM_LBL_HELP_LINK;
			}
		}
	}
	
	
}