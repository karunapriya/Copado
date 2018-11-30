public with sharing class CSM_HelpExtension {
	
	//public String param {get; set;}
	public String urlString {get; set;}
	public CSM_HelpLinks__c HelpLinkSettings {get; set;}  
	private String path; 
	
	public CSM_HelpExtension()  
	{
		//param = ApexPages.currentPage().getParameters().get('param');
		helpLinkSettings = CSM_HelpLinks__c.getOrgDefaults(); 
		urlString = '';
		if(helpLinkSettings != null)
		{
			urlString = helpLinkSettings.CSM_Base_Url__c;
		}
		//http://csm.helpdocsonline.com/success-plans-tab
	
	}
	 
	public void buildUrl() {
		
			if(param.toUpperCase() == CSM_Constants.HELP_OVERVIEW.toUpperCase()) 
			{
				urlString += helpLinkSettings.CSM_Overview__c;
				//path = helpLinkSettings.CSM_Overview__c;
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
			//urlString += path; 
		//}
	}
	
	public String param {
		get {
			return param;
		}
		set {
				if(String.isEmpty(param) && value != null)// && path == null)
				{
					param = value;
					buildUrl();
					system.debug('param set $$ ' + value);
				}
		}
	}
	
	
	
	
}