public with sharing class CHL_RenPartnerDataSyncCtrl extends REN_BaseMainController {

	public Boolean hasChannelAccess{get;set;}
	public REN_FieldMappingInputWrapper mappingInputWrapper{get;set;}
	list<CHL_Opportunity_Status_Log__c> oppLogList {get;set;}
	
	public String quoteSelectedOption {get;set;}
	public String parentIdsToRefresh {get;set;}
	public String helpParam {
        get;
        set;
    }
    
	public void setQuoteSelectedOption(String quoteSelectedOption){
  		this.quoteSelectedOption = quoteSelectedOption;
	} 
	
	public CHL_RenPartnerDataSyncCtrl() {
		helpParam = CSM_Constants.HELP_RENEWAL_PARTNER_DATA_SYNC;
		parentIdsToRefresh='warnMessage, fieldToSync, mappingsParentPanel';
		this.hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;	
		this.mappingInputWrapper = new REN_FieldMappingInputWrapper(REN_Constants.OBJ_OPPORTUNITY, CSM_Util.getNamespace()+CHL_Constants.OBJ_PARTNER_OPPORTUNITY, CHL_Constants.FLD_MAP_PARTNER_OPPT_TO_MASTER_OPPT, this, system.label.CHL_LBL_PARTNER_OPP_FIELDS, system.label.REN_LBL_MAPPING_SECTION_HEADER, 'Partner_Opportunity Field', 'Opportunity Field', system.label.CHL_LBL_PARTNER_OPP_FIELDS, parentIdsToRefresh);
		mappingInputWrapper.isDefaultShow = false;
		if(getOppQuote() != 'false'){
		  quoteSelectedOption = getOppQuote();
		}
	}

	public PageReference save() {
		Savepoint sp;
		try {
			sp = Database.setSavepoint();
			Map < String, Set < REN_BaseChildController >> mappingToControllerMap = this.getMappingToControllerMap();
			Set < REN_BaseChildController > controllerList = mappingToControllerMap.get(CHL_Constants.FLD_MAP_PARTNER_OPPT_TO_MASTER_OPPT);
			if (controllerList != null && !controllerList.isEmpty()) {
				for (REN_BaseChildController baseChildController: controllerList) {
					if (baseChildController instanceof REN_FieldMappingComponentController) {
						((REN_FieldMappingComponentController) baseChildController).save();
					}
				}
			}
			saveOppQuote();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CHL_LBL_PARTNER_SAVED_MSG));
		} catch (Exception ex) {
			Database.rollback(sp);
			ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage());
			ApexPages.addMessage(msg);
			return null;
		}
		return null;
	}
	
	
	public List < SelectOption > getQuoteOptions() {
		List < SelectOption > options = new List < SelectOption > ();
		options.add(new SelectOption(CHL_Constants.OBJ_OPSL_QUOTE_PDF_OPTION_QUOTEPDF, Label.CHL_LBL_SALESFORCE_QUOTE));
		options.add(new SelectOption(CHL_Constants.OBJ_OPSL_QUOTE_PDF_OPTION_NOTES, Label.CHL_LBL_ATTACHMENT_QUOTE));
		return options;
	}
	
	public void saveOppQuote() {
		List<CHL_Opportunity_Status_Log__c> oppStatusLogList = new List<CHL_Opportunity_Status_Log__c>();
		if (oppLogList.isEmpty()) {
			CHL_Opportunity_Status_Log__c oppStatusLog = new CHL_Opportunity_Status_Log__c();
			oppStatusLog.CHL_Quote_PDF_Option__c = quoteSelectedOption;
			oppStatusLogList.add(oppStatusLog);
		} else {
			oppLogList[0].CHL_Quote_PDF_Option__c = quoteSelectedOption;
			oppStatusLogList.add(oppLogList[0]);
		}
		
		CHL_OpptyStatusLogDataAccess.upsertOpportunityStatusLogList(oppStatusLogList);
	}
	
	public string getOppQuote() {
		oppLogList = new list <CHL_Opportunity_Status_Log__c> ();
		oppLogList = CHL_OpptyStatusLogDataAccess.getChannelOptyStatusLogData();
		if (!oppLogList.isEmpty()) {
			return (oppLogList[0].CHL_Quote_PDF_Option__c);
		} else {
			return 'false';
		}
	}

	public PageReference cancel() {
		PageReference pageRef = Page.chl_renpartnerdatasync;
        pageRef.getParameters().put('tabCategory', 'Channel');
        pageRef.setRedirect(true);
        return pageRef;

	}
	
	
	
}