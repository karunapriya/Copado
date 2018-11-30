/**
 * Created Date		: Apr 18, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - used as a landing page for Bulk import
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					US3249				Apr 18, 2018			1.1					@description
 *
 */
global with sharing class REN_BulkImportLandingController {

	public Boolean isSimplifiedEnabled {get; set;}
	private Opportunity currentOpportunity;
	public Boolean isClosedOpp{get;set;}
	public Boolean isClosedCase{get;set;}
	public String docurl{get;set;}
	String OppId;
	String caseId;
	public REN_BulkImportLandingController(){
		this.isSimplifiedEnabled = SS_Constants.isSimplifiedDataModelEnabled;
		OppId = ApexPages.currentPage().getParameters().get('oppId');
		caseId = ApexPages.currentPage().getParameters().get('caseId');		
		if(OppId != null){
			List<Opportunity> opptyList = REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<String>{oppId});
        	if(opptyList != null && !opptyList.isEmpty()){
            	this.currentOpportunity = opptyList[0];
        	}
		}
		if(caseId != null){
			List<Case> caseList =CSM_CaseDataAccess.getClosedCases(new Set<Id>{caseId});	
			if(caseList != null && !caseList.isEmpty()){
				isClosedCase = true;
			}
		}
		 SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();
		      
		if (!this.isSimplifiedEnabled){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.label.REN_MSG_SDM_OFF_BULK_IMPORT)); 
            return;         
        }
       	else if((REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',').contains((this.currentOpportunity).StageName))){
        	isClosedOpp = true;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.label.REN_MSG_OPP_STAGE_BLOCK_TO_BULK_IMPORT)); 
            return;  
        }
        else if(isClosedCase == true){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.label.REN_MSG_CASE_CLOSED_BULK_IMPORT)); 
            return;  
        }
	}
	public pageReference cancelImport(){
		PageReference pr;
		if(caseId != null){
			pr = new PageReference('/'+caseId);	
		}else{
			pr = new PageReference('/'+OppId);
		} 
		return pr;  	
    }
    
    @RemoteAction
    global static String gateway(String inputValue){
        String data = '';
        REN_JSONAPIRouter ltRouter = new REN_JSONAPIRouter();
        data = ltRouter.getPostRequest(inputValue);
        system.debug('data :: '+data);
        return data;
    }	
}