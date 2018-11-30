/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.25.2014
* @description    CSM_TaskListController class contains methods for supporting the UI  
*/
public with sharing class CSM_TaskListController {
	public boolean hasCSMAccess {get; private set;}
	public boolean hasRenewAccess {get; private set;}
	
	public CSM_TaskListController() {
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
	}
}