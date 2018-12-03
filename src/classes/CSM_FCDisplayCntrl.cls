/**
 * Created Date		: Feb 20, 2017
 * Developed By		: Nidhi, Comity Designs, Inc.
 *
 * Function			: This class act as controller for displaying FC as Cards and Tiles.
 * Support Email 	: Nidhi@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nidhi					US2118				Feb 20, 2017		1.1					@description
 * 
 */

public with sharing class CSM_FCDisplayCntrl {
	
    public String scoutUrl {get; set;}
 	public String helpParam {get; set;}
	public Boolean hasCSMAccess {get; private set;}
	public Boolean hasRenewAccess {get; private set;}
	public List<SelectOption> riskReasonList {get; private set;} 
 	public List<SelectOption> riskReasonDismissList {get; private set;}
	public List<SelectOption> newTaskRiskReasonList {get; private set;} 	
	//public transient Boolean hasTaskFCV {get; set;}	
	public List<CSM_FocusCategoryColumnWrapper> tilesOrderedList {get; private set;}
	public String nameSpace {get;set;}
   
	public CSM_FCDisplayCntrl() {
		try{
			nameSpace = CSM_Util.getNamespace();
			scoutUrl = '';
			//hasTaskFCV = checkForTaskFC();
	        hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
            hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
			helpParam = CSM_Constants.HELP_OVERVIEW;
			CSM_Admin__c adminSetting = CSM_Admin__c.getOrgDefaults();
			if(adminSetting != null)
			{
				scoutUrl = adminSetting.CSM_ScoutCollector__c;
			}
            //schemaMap = Schema.getGlobalDescribe();
            riskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON);
		    riskReasonDismissList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS);
		    newTaskRiskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_COMBINED);	
			
		}catch (Exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));	 
        } 
	}
}