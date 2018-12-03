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
public class CHL_CrossSell_UpsellRedirectCtrl {
     public String quoteId;
     
    public CHL_CrossSell_UpsellRedirectCtrl(ApexPages.StandardSetController standardController)
    {
        quoteId = ApexPages.currentPage().getParameters().get('Id');        
    }

   public PageReference returnPage()
   {
        PageReference pageRef = Page.CrossSell_Upsell;
		pageRef.getParameters().put('id', quoteId);        

	    return pageRef;
   }

}