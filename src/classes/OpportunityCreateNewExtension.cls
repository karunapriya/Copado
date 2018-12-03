/**
 * Created Date		: Oct 27, 2016
 * Developed By		: Nkonkar, Comity Designs, Inc.
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
 * Nkonkar					User Story				Oct 27, 2016			1.1					@description
 *
 */
 
 public with sharing class OpportunityCreateNewExtension {

	private ApexPages.StandardController controller;
	public String retURL {get; set;}
	public String saveNewURL {get; set;}
	public String rType {get; set;}
	public String cancelURL {get; set;}
	public String ent {get; set;}
	public String confirmationToken {get; set;}
	public String accountID {get; set;}
	public String contactID {get; set;}
	public boolean isPermissionGranted {get; set;}
	private string accid;
	private static String nameSpace = Util.solnExtnNameSpace.removeEnd('__');
	 
	public OpportunityCreateNewExtension(ApexPages.StandardController controller) {
	
		this.controller = controller;
	
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		rType = ApexPages.currentPage().getParameters().get('RecordType');
		cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
		ent = ApexPages.currentPage().getParameters().get('ent');
		confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
		saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
	    accid = ApexPages.currentPage().getParameters().get('accid');
		isPermissionGranted = PermissionUtil.isCustomPermissionAssigned(PermissionUtil.PS_CanCreateOpportunity);
	}
	
	public PageReference redirect() {
		if(isPermissionGranted){
			
			PageReference returnURL = new PageReference('/006/e');
			returnURL.getParameters().put('retURL', retURL);
			returnURL.getParameters().put('RecordType', rType);
			returnURL.getParameters().put('cancelURL', cancelURL);
			returnURL.getParameters().put('ent', ent);
			returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
			returnURL.getParameters().put('save_new_url', saveNewURL);
			returnURL.getParameters().put('nooverride', '1');
			if(accid!=null){
				returnURL.getParameters().put('accid',accid);
			}
			returnURL.setRedirect(true);
			return returnURL;
		}
		return null;
	
	}

}