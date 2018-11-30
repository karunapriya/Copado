public with sharing class CSM_PlaybooksListController {
	
	public boolean hasCSMAccess {get; private set;}
	public Boolean hasRenewAccess {get; private set;}
	public String helpParam {get; set;}
	public String tabCategory {get; set;} 
	
	public CSM_PlaybooksListController() {
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		helpParam = CSM_Constants.HELP_PLAYBOOKS;
	}

}