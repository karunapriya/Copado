public with sharing class CSM_SuccessPlanHelpCtrl {
	public String urlString {get; set;}
	private CSM_HelpLinks__c helpLinkSettings;
	public CSM_SuccessPlanHelpCtrl()
	{
		 
		helpLinkSettings = CSM_AdminDataAccess.getCSMHelpLinksInstance(); 
		urlString = '';
		if(helpLinkSettings != null)
		{
			urlString = helpLinkSettings.CSM_Base_Url__c;
			urlString += helpLinkSettings.CSM_Success_Plan_Home__c;
			
		} 
	}
}