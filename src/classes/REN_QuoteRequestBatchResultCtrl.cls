/**
 * Created Date		: Feb 7, 2017
 * Developed By		: abirjepatil, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * abirjepatil					User Story				Feb 7, 2017			1.1					@description
 * 
 */
public with sharing class REN_QuoteRequestBatchResultCtrl {

    public String helpParam {get;set;}
	public Boolean isPlaymakerUser {get; private set;}
    public CSM_DataGridAttribute quoteRequestResultGridAttribute{get; set;}

	public REN_QuoteRequestBatchResultCtrl() {
		String namespace = CSM_Util.getNamespace();
		this.isPlaymakerUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_REN_Playmaker);
		
		helpParam = CSM_Constants.HELP_QUOTE_REQUEST_LOG;
		
		quoteRequestResultGridAttribute = new CSM_DataGridAttribute();
		quoteRequestResultGridAttribute.tableName = 'quoteRequestResult';
		quoteRequestResultGridAttribute.objectType  = 'QuoteRequestResult';
	    quoteRequestResultGridAttribute.viewName = 'quoteRequestResult';
	    quoteRequestResultGridAttribute.gridToolBarId = 'grid-toolbar';
	    quoteRequestResultGridAttribute.hasSearch = 'true';
	    quoteRequestResultGridAttribute.stateSave = 'true';
	    quoteRequestResultGridAttribute.hasShowColumns = 'true';
	    quoteRequestResultGridAttribute.showExport ='true';
	    quoteRequestResultGridAttribute.showGlobalSelect = 'true';
	    quoteRequestResultGridAttribute.params = '{}';
	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
 	    quoteRequestResultGridAttribute.userDateFormat = localeMap.get(userInfo.getLocale());
	}
    
}