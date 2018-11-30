/**
 * Created Date		: Nov 21, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Controller for Opportunity line items selection in Opportunity split wizard 
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1760					Nov 21, 2016	 1.1				Initial development
 *
 */
public with sharing class REN_OpptSplitWizardOLIController {
   /* This controller class is Deprecated under US3293
      If you need this controller class code, take latest from previous version
   
    public String productIds {get; set;}
    public String helpParam {get;set;}
    
    public CSM_DataGridAttribute opptSplitOLIGridAttribute
    {
    	set;
    	
    	get
    	{
    		helpParam = '';
    		
    		opptSplitOLIGridAttribute = new CSM_DataGridAttribute();
    		opptSplitOLIGridAttribute.tableName = 'opptSplitOLI';
    		opptSplitOLIGridAttribute.objectType  = 'OpptSplitOLI';
    	    opptSplitOLIGridAttribute.viewName = 'OpptSplitOLI';
    	    opptSplitOLIGridAttribute.gridToolBarId = 'grid-toolbar';
    	    opptSplitOLIGridAttribute.hasSearch = 'true';
    	    opptSplitOLIGridAttribute.stateSave = 'true';
    	    opptSplitOLIGridAttribute.hasShowColumns = 'true';
    	    opptSplitOLIGridAttribute.showExport ='true';
    	    opptSplitOLIGridAttribute.showGlobalSelect = 'true';
    	    opptSplitOLIGridAttribute.params = '{"opptyId":"' + ApexPages.currentPage().getParameters().get('opptId') + '"}';
    	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
     	    opptSplitOLIGridAttribute.userDateFormat = localeMap.get(userInfo.getLocale());
     	    return opptSplitOLIGridAttribute;
    	}
    }
    
    public REN_OpptSplitWizardOLIController(ApexPages.StandardController stdController){
    }
    
    
    public PageReference redirectToOpptSplitWizard() {
		PageReference pageRef = Page.REN_OpptSplitWizard;
		pageRef.getParameters().put('opptId', ApexPages.currentPage().getParameters().get('opptId'));
		pageRef.getParameters().put('opptLns', productIds);
		pageRef.setRedirect(true);
		return pageRef;
	} */
}