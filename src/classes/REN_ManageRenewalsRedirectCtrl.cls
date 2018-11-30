/**
 * Created Date		: Nov 17, 2016
 * Developed By		: abirjepatil, Comity Designs, Inc.
 *
 * Function			: This controller helps redirection to the required page, when the 'Manage Renewals' javascript
                      button is modified to redirect to a VF Page.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * abirjepatil					US1761				Nov 17, 2016			1.1					@description
 *
*/
public with sharing class REN_ManageRenewalsRedirectCtrl {

    public String opptyId;
    private ApexPages.StandardSetController standardController;

    public REN_ManageRenewalsRedirectCtrl(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        opptyId = ApexPages.currentPage().getParameters().get('Id');        
    }

   public PageReference returnPage()
   {
        PageReference pageRef = Page.REN_RenewalRelationshipBulkEdit;
		pageRef.getParameters().put('OpptId', opptyId);        

	    return pageRef;
   }
}