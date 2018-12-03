public with sharing class CSM_CustomerSuccessAdminController
{
	public boolean hasCSMAccess {get; private set;}
	public boolean hasRenewAccess {get; private set;}
	public Boolean theLinksAreVisible {get; private set;}
	public String helpParam {get; set;}
	
	public CSM_CustomerSuccessAdminController() 
	{
	    hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		helpParam = CSM_Constants.HELP_INDICATOR_GROUPS;
	    //if (CSM_Util.isUserAnSystemAdmin() != false) {
	    	this.theLinksAreVisible = true;
	    //} 
	}
}