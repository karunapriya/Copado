public with sharing class REN_ServiceContractsController {

	public Boolean hasRenewAccess {get; private set;}
	public Boolean hasServiceContractAccess {get; private set;}
	public String retUrl{get;set;}
	public String helpParam {get; set;}
	public String tabCategory {get; set;} 
	public REN_ServiceContractsController() 
	{
		hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled; 
		hasServiceContractAccess = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT);
		PageReference pageRefTemp = Page.ren_servicecontracts;
		retURL = pageRefTemp.getURL();
		helpParam = CSM_Constants.HELP_PLAYS;
	}
}