public with sharing class CSM_BusinessLayerFactory {

	private static final String TYPE_TASK = 'TASK';
	private static final String TYPE_ACCOUNT = 'ACCOUNT';
	private static final String TYPE_OPPORTUNITY = 'OPPORTUNITY';
	private static final String TYPE_ASSET = 'ASSET';
	private static final String TYPE_SERVICECONTRACT = 'SERVICECONTRACT';
	private static final String TYPE_CONTRACTLINEITEM = 'CONTRACTLINEITEM';
	private static final String TYPE_RENEWALRELATIONSHIP = 'RENEWALRELATIONSHIP';
	private static final String TYPE_CONSOLIDATE_OPPORTUNITY_LOG = 'ConsolidateOpportunityLog';	
	private static final String VIEW_NAME_FCFULLLIST = 'FCFullList';
	private static final String VIEW_NAME_FCViewList = 'FocusCategoryViewList';
	private static final String VIEW_NAME_ACTIONTAB = 'actionTab';
	private static final String TYPE_PLAYBOOK = 'PLAYBOOK';
	private static final String BATCH_OPP_GEN_WIDGET = 'BatchOppGenWidget';
	private static final String BATCH_PTA_WIDGET = 'BatchPTAWidget';
	private static final String BATCH_OPP_GEN_BATCH_HISTORY = 'BatchOppGenBatchHistory';
	private static final String TYPE_PARTNER_OPPORTUNITY = 'PARTNER_OPPORTUNITY'; //this is for Channel Partner
	private static final String BATCH_OPP_GEN_SUMMARY = 'BatchOppGenSummary';
	private static final String BATCH_OPP_GEN_FAILED_SUMMARY = 'BatchOppGenFailedSummary';
	private static final String BATCH_SUCC_PLAN_DEFAULT = 'planDefaultObj';
	private static final String BATCH_SUCC_PLAN_ACTIVITY = 'BatchSuccessPlanHistory';
	private static final String CHL_PORTAL_GROUP_MEM_VIEW = 'portalGroupMembersView';
	private static final String TYPE_SUCCPLANPLAYBOOK = 'SuccessPlanPlay';
	private static final String TYPE_AUTOMATED_GENERATION_LOG = 'AutomatedGenerationLog';
	private static final String TYPE_BATCH_FILTER_ACTIVITY = 'BatchFilterActivity';
	private static final String TYPE_OPPORTUNITY_SPLIT_OLI = 'OpptSplitOLI';
	private static final String TYPE_SEGMENT_OVERVIEW = 'SegmentOverview';
	private static final String TYPE_SEGMENT_DETAIL = 'SegmentDetail';
    private static final String TYPE_SEGMENT_MEMBER = 'SegmentMember';
	private static final String TYPE_OAUTH_SETUP = 'oAuthSetupPage';
	private static final String TYPE_PO_QUOTES = 'quoteOnPOObj';
	private static final String TYPE_QUOTEREQUEST_RESULT = 'QuoteRequestResult';	
	private static final String TYPE_TASK_GENERATION_ACTIVITY = 'TaskGenerationActivity';
	private static final String TYPE_BATCH_TASK_GEN_SUMMARY = 'BatchTaskGenSummary';
	private static final String TYPE_SEGMENT_TEMPLATE = 'objSegmentTaskTemplate';
	private static final string Type_FC='FocusCategoryList';
	private static final String TYPE_SEARCH_AND_MOVE = 'searchAndMove';
	private static final String TYPE_COMMON_SEARCH = 'commonSearch';
	private static final String TYPE_IB_REPORT_SEARCH = 'IBExportSearch';
	private static final String TYPE_MASS_UPDATE = 'massUpdate';
    private static final String TYPE_SEARCH_AND_ADD = 'searchAndAdd';
	
	
	private CSM_CustomGridInputWrapper inputWrapper;
	
	public CSM_BusinessLayerFactory(CSM_CustomGridInputWrapper inputWrapper){
		this.inputWrapper = inputWrapper;
		system.debug('\n\n 111 $$ inputWrapper :: '+ inputWrapper);
	}
	
	public CSM_GridResponseWrapper retrieveSObjectWrapperList(){
		system.debug('in retrieveSObjectWrapperList $$ ');
		CSM_GridResponseWrapper sObjList = new CSM_GridResponseWrapper();
		if(String.isNotBlank(this.inputWrapper.objType)){
			CSM_BusinessLayer businessLayer;
			
			if (TYPE_TASK.equalsIgnoreCase(this.inputWrapper.objType)) {
				if (VIEW_NAME_ACTIONTAB.equalsIgnoreCase(this.inputWrapper.viewName)) {
					businessLayer = new CSM_SPActionTabBusinessLayer(this.inputWrapper);						
				}
				else {
					businessLayer = new CSM_TaskBusinessLayer(this.inputWrapper);
				}
			} 
			else if (VIEW_NAME_FCFULLLIST.equalsIgnoreCase(this.inputWrapper.viewName)){
				businessLayer = new CSM_FCFullListBusinessLayer(this.inputWrapper);
			}
			else if (VIEW_NAME_FCViewList.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new CSM_FocusCategoryViewListBusinessLayer(this.inputWrapper);
			}
			else if(TYPE_ACCOUNT.equalsIgnoreCase(this.inputWrapper.objType)) {
				businessLayer = new CSM_AccountBusinessLayer(this.inputWrapper);
			}
			else if(TYPE_ASSET.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_AssetBusinessLayer(this.inputWrapper);
			}
			else if(TYPE_RENEWALRELATIONSHIP.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_RenewRelationshipBusinessLayer(this.inputWrapper);
			}			
			else if(TYPE_CONSOLIDATE_OPPORTUNITY_LOG.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_ConsolidateOpportunityBusinessLayer(this.inputWrapper);
			}			
			else if(CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICE_CONTRACT) && TYPE_CONTRACTLINEITEM.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_ServiceContractBusinessLayer(this.inputWrapper);
			}
			else if(TYPE_OPPORTUNITY.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new CSM_OpportunityBusinessLayer(this.inputWrapper);
			}
			else if(TYPE_PLAYBOOK.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new CSM_PlaybookBusinessLayer(this.inputWrapper);
			}else if(BATCH_OPP_GEN_WIDGET.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_BatchOppGenBusinessLayer(this.inputWrapper);
			}else if(BATCH_PTA_WIDGET.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new CSM_BatchPTABusinessLayer(this.inputWrapper);
			}else if((BATCH_OPP_GEN_BATCH_HISTORY.equalsIgnoreCase(this.inputWrapper.objType))
						|| (BATCH_SUCC_PLAN_ACTIVITY.equalsIgnoreCase(this.inputWrapper.objType))){
				businessLayer = new REN_BatchOppGenActivityLayer(this.inputWrapper);
			}else if(BATCH_OPP_GEN_SUMMARY.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_BatchOppGenSummBusinessLayer(this.inputWrapper);
			}else if(BATCH_OPP_GEN_FAILED_SUMMARY.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_BatchOppGenFailedSummBusinessLayer(this.inputWrapper);
			} else if(BATCH_SUCC_PLAN_DEFAULT.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new CSM_BatchPlanDefaultBusinessLayer(this.inputWrapper);
			} else if(CHL_PORTAL_GROUP_MEM_VIEW.equalsIgnoreCase(this.inputWrapper.objType)) {
				businessLayer = new CHL_PortalGroupMembersViewBusinessLayer(this.inputWrapper);
			} else if(TYPE_SUCCPLANPLAYBOOK.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new CSM_SuccessPlanPlayBusinessLayer(this.inputWrapper);
			}else if(TYPE_AUTOMATED_GENERATION_LOG.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_AutomatedGenLogBusinessLayer(this.inputWrapper);
			} else if(TYPE_BATCH_FILTER_ACTIVITY.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new CSM_BatchFilterActivityBusinessLayer(this.inputWrapper);
			} else if(TYPE_OPPORTUNITY_SPLIT_OLI.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_OpptSplitWizardOLIBusinessLayer(this.inputWrapper);
			} else if(TYPE_SEGMENT_OVERVIEW.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_SegmentOverviewBusinessLayer(this.inputWrapper);
			} else if(TYPE_QUOTEREQUEST_RESULT.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_QuoteRequestResultBusinessLayer(this.inputWrapper);				
			} else if(TYPE_SEGMENT_DETAIL.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_SegmentDetailBusinessLayer(this.inputWrapper);
			} else if(TYPE_SEGMENT_MEMBER.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_SegmentMemberBusinessLayer(this.inputWrapper);
			} else if(TYPE_OAUTH_SETUP.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new REN_OAuthSetupBusinessLayer(this.inputWrapper);
			} else if(TYPE_PO_QUOTES.equalsIgnoreCase(this.inputWrapper.objType)){
				businessLayer = new CHL_QuoteOnPOBusinessLayer(this.inputWrapper);
			} else if(TYPE_PARTNER_OPPORTUNITY.equalsIgnoreCase(this.inputWrapper.objType)){ 
                businessLayer=new CHL_PartnerOpportunitySyncBusinessLayer(this.inputWrapper);               
            } else if(TYPE_TASK_GENERATION_ACTIVITY.equalsIgnoreCase(this.inputWrapper.objType)){ 
                businessLayer=new REN_TaskGenerationActivityBusinessLayer(this.inputWrapper);               
            } else if(TYPE_BATCH_TASK_GEN_SUMMARY.equalsIgnoreCase(this.inputWrapper.objType)){ 
                businessLayer=new REN_BatchTaskGenSummaryBusinessLayer(this.inputWrapper);               
            } else if(TYPE_SEGMENT_TEMPLATE.equalsIgnoreCase(this.inputWrapper.objType)){ 
                businessLayer=new REN_TaskTemplateBusinessLayer(this.inputWrapper);               
            } else if(TYPE_SEARCH_AND_MOVE.equalsIgnoreCase(this.inputWrapper.objType)){ 
                businessLayer=new REN_SearchAndMoveRliBusinessLayer(this.inputWrapper);
			} else if(TYPE_COMMON_SEARCH.equalsIgnoreCase(this.inputWrapper.objType)){ 
                businessLayer=new REN_CommonSearchBusinessLayer(this.inputWrapper);
			} else if(TYPE_IB_REPORT_SEARCH.equalsIgnoreCase(this.inputWrapper.objType)){
                businessLayer = new REN_IBExportBusinessLayer(this.inputWrapper);
            } else if(TYPE_MASS_UPDATE.equalsIgnoreCase(this.inputWrapper.objType)){ 
                businessLayer=new REN_CommonSearchBusinessLayer(this.inputWrapper);
			} else if(TYPE_SEARCH_AND_ADD.equalsIgnoreCase(this.inputWrapper.objType)){ 
                businessLayer=new REN_IBExportBusinessLayer(this.inputWrapper);
			}
			sObjList = businessLayer.retrieveSObjectWrapperList();
		}
		return sObjList;
	}	
}