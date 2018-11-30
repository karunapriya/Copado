/**
 * Created Date		: May 24, 2018
 * Developed By		: Smita, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: smitah@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Smita					US3344				May 24, 2018			1.1					@description
 *
 */
global with sharing class REN_QuoteImportLandingController {

	public Boolean isSimplifiedEnabled {get; set;}
	private Opportunity currentOpportunity;
	public Boolean isClosedOpp{get;set;}
	public Boolean isClosedCase{get;set;}
	public Boolean isAssignedToQueue{get;set;}
	public Boolean isTemplatePresent{get;set;}
	public transient string strValueofdocumentBody {get;set;}
	public String urlPrefix{get;set;}
	String OppId;
	String caseId;
	public REN_QuoteImportLandingController(){
		this.isSimplifiedEnabled = SS_Constants.isSimplifiedDataModelEnabled;
        isClosedOpp=false;
        isClosedCase =false;
        isAssignedToQueue = false;
        isTemplatePresent = true;
        if((UserInfo.getUserType()).equalsIgnoreCase('PowerPartner')){
        	urlPrefix = site.getPathPrefix().remove('/')+'/';
        }else{
            urlPrefix = '';
        }
        List<Document> docList = CHL_DocumentDataAccess.getQuoteTemplate();
        if(docList!=null && !docList.isEmpty()){
        	strValueofdocumentBody = docList[0].body.toString();
        }else{
        	isTemplatePresent = false;
        }      
		OppId = ApexPages.currentPage().getParameters().get('oppId');
		caseId = ApexPages.currentPage().getParameters().get('caseId');		
		if(OppId != null){
			List<Opportunity> opptyList = REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<String>{oppId});
        	if(opptyList != null && !opptyList.isEmpty()){
            	this.currentOpportunity = opptyList[0];
        	}
		}
		if(caseId != null){
			List<Case> caseList =CSM_CaseDataAccess.getCasesById(new Set<Id>{caseId});	
			if(caseList != null && !caseList.isEmpty()){
				if(caseList[0].IsClosed){
					isClosedCase = true;
				}
				else if(caseList[0].Owner.Type != 'User'){
					isAssignedToQueue = true;
				}				
			}
		}
		 SS_Validations__c fetchValidationSettings = SS_Validations__c.getInstance();
		      
		if (!this.isSimplifiedEnabled){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.label.REN_MSG_SDM_OFF_QUOTE_IMPORT)); 
            return;         
        }
       	else if((REN_Util.convertCSVtoSet(fetchValidationSettings.REN_No_Split_allowed_for_Opp_Stage__c, ',').contains((this.currentOpportunity).StageName))){
        	isClosedOpp = true;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.label.REN_MSG_OPP_STAGE_BLOCK_TO_QUOTE_IMPORT)); 
            return;  
        }
        else if(isClosedCase){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.label.REN_MSG_CASE_CLOSED_QUOTE_IMPORT)); 
            return;  
        }
        else if(isAssignedToQueue){

        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_CAN_NOT_IMPORT_QUOTES)); 
            return;  
        }
        else if(!isTemplatePresent){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.label.REN_LBL_TEMPLATE_REQUIRED)); 
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