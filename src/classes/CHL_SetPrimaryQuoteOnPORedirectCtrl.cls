/**
 * Created Date		: Jul 18, 2018
 * Developed By		: Smita, Comity Designs, Inc.
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
 * Smita					User Story				Jul 18, 2018			1.1					@description
 *
 */
public with sharing class CHL_SetPrimaryQuoteOnPORedirectCtrl {
	public String poId;

    public CHL_SetPrimaryQuoteOnPORedirectCtrl(ApexPages.StandardSetController standardController)
    {
        poId = ApexPages.currentPage().getParameters().get('Id');        
    }

   public PageReference returnPage()
   {
        PageReference pageRef = Page.CHL_SetPrimaryQuoteOnPO;
		pageRef.getParameters().put('Id', poId);        

	    return pageRef;
   }
}