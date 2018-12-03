public with sharing class CSM_PlaysListController {

	public Boolean hasCSMAccess {get; private set;}
	public Boolean hasRenewAccess {get; private set;}
	public String retUrl{get;set;}
	public String helpParam {get; set;}
	public String tabCategory {get; set;} 
	public CSM_PlaysListController() 
	{
	    hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
	    hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
	    PageReference pageRefTemp = Page.CSM_PlaysList;
		pageRefTemp.getParameters().put('tabCategory', 'SuccessPlan');
        retURL = pageRefTemp.getURL();
	    helpParam = CSM_Constants.HELP_PLAYS;
	}
}