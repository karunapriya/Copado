/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.21.2014
* @description    SS_LicenseCheck class checks if the user has license for appropriate feature  
*/
public with sharing class SS_LicenseCheckComponentController {

	public Boolean hasCSMAccess {get; private set;}
	public String CSMNoAccessMsg {get; private set;}
	public Boolean hasRenewAccess {get; private set;}
	public Boolean hasChannelAccess {get; private set;}
	
	/**
	* @description Constructor
	*
	* @return null 
	*/
	public SS_LicenseCheckComponentController() {
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
		hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		hasChannelAccess =SS_LicenseCheck.getInstance().isChannelEnabled;
		CSMNoAccessMsg = SS_Constants.SS_NO_LICENSE_MSG; 
	}

}