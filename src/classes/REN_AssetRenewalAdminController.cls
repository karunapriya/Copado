public with sharing class REN_AssetRenewalAdminController {

	public Boolean hasRenewAccess {get; private set;}
	public String retUrl{get;set;}
	public String helpParam {get; set;}
	public String tabCategory {get; set;} 
	
	public REN_AssetRenewalAdminController() 
	{
        hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
        PageReference pageRef = Page.REN_AssetRenewalAdmin;
        retURL = pageRef.getURL();
        //retURL = '/apex/ren_assetRenewalAdmin';
	    helpParam = CSM_Constants.HELP_PLAYS;
	}
}