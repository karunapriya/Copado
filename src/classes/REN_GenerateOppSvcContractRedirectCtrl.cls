/**
 * Created Date		: Nov 22, 2016
 * Developed By		: abirjepatil, Comity Designs, Inc.
 *
 * Function			: This controller helps redirection to the required page, when the 'Generate Opportunity' javascript
                      button is modified to redirect to a VF Page.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * abirjepatil					US1779				Nov 22, 2016			1.1					@description
 *
*/
public with sharing class REN_GenerateOppSvcContractRedirectCtrl {

    public String scId;
    private ApexPages.StandardController standardController;
    //private Boolean sdmFlag;

    public REN_GenerateOppSvcContractRedirectCtrl(ApexPages.StandardController stdController)
    {
    	/*sdmFlag =false;
        SS_License__c ssLicense = SS_License__c.getOrgDefaults();
        if(ssLicense!=null){
        	sdmFlag = ssLicense.Simplified_Data_Model_Is_Enabled__c;
        }*/
        this.standardController = stdController;
        scId = ApexPages.currentPage().getParameters().get('Id');        
    }

   public PageReference returnPage()
   {
   		PageReference pageRef = Page.REN_CreateRenewOpptyFromServiceContract;
		pageRef.getParameters().put('contractId', scId);
   		return pageRef;
   }

}