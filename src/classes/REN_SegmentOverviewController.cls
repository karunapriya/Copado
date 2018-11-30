/**
 * Created Date		: Nov 30, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Controller for segment overview page
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1861					Nov 30, 2016	1.0					Initial Development
 *
 */
public with sharing class REN_SegmentOverviewController {
    public String helpParam {get;set;}
	public String id {get;set;}
	public String deleteIds {get;set;}
	public String segmentIds {get;set;}	
	public Boolean isPlaymakerUser {get; private set;}
    public CSM_DataGridAttribute segmentOverviewGridAttribute{get; set;}
    public Boolean displayQuoteRequestMsg {get; private set;}
    public String quoteRequestUrl{get; private set;}
    public String tempVariable{get;set;}
    public List<SelectOption> getTaskOwnerOptions{get;set;}

	public REN_SegmentOverviewController() {
		this.isPlaymakerUser = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_REN_Playmaker);
		helpParam = CSM_Constants.HELP_SEGMENT_DETAIL;
		
		segmentOverviewGridAttribute = new CSM_DataGridAttribute();
		segmentOverviewGridAttribute.tableName = 'segmentOverview';
		segmentOverviewGridAttribute.objectType  = 'SegmentOverview';
	    segmentOverviewGridAttribute.viewName = 'SegmentOverview';
	    segmentOverviewGridAttribute.gridToolBarId = 'grid-toolbar';
	    segmentOverviewGridAttribute.hasSearch = 'true';
	    segmentOverviewGridAttribute.stateSave = 'true';
	    segmentOverviewGridAttribute.hasShowColumns = 'true';
	    segmentOverviewGridAttribute.showExport ='true';
	    segmentOverviewGridAttribute.showGlobalSelect = 'true';
	    segmentOverviewGridAttribute.params = '{}';
	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
 	    segmentOverviewGridAttribute.userDateFormat = localeMap.get(userInfo.getLocale());
 	    displayQuoteRequestMsg = false;
 	    quoteRequestUrl = Page.REN_QuoteRequestBatchResult.getUrl();
	}

	/*
	** @Description: Navigates to Segment detail page
	** @returns: Page reference to Segment detail page 
	*/
	public PageReference editClick() {
		try {			
			return getSegmentDetailPageReference(id);
		} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		
		return null;
	}
 
 	/*
	** @Description: Navigates to Segment detail page
	** @returns: Page reference to Segment detail page
	*/
	public PageReference redirectToSegmentDetail() {
		try {
			return getSegmentDetailPageReference(null);
		} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		
		return null;
	}
	
	/*
	** @Description: Navigate to Segment detail helper method
	** @returns: Page reference to Segment detail page
	*/
	private PageReference getSegmentDetailPageReference(String recordId) {
		PageReference pageRef = Page.REN_SegmentDetail; 
		
		if(String.isNotEmpty(recordId)) {
			pageRef.getParameters().put('id', recordId);
		}
		
		pageRef.getParameters().put('tabCategory', 'Playmaker');
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	/*
	** @Description: Deletes the Segment record
	*/
    public void deleteClick() {
    	try {
    		displayQuoteRequestMsg = false;
	        if(!String.isBlank(deleteIds)){
	        	List<String> deleteList = deleteIds.split('-');
	        	Set<String> deleteSet = new Set<String>();
	        	deleteSet.addAll(deleteList);
			    REN_SegmentDataAccess.deleteSegments(deleteSet);
	        }
    	} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
    }
    
	/*
	** @Description: Runs Quote Request creation batch
	*/
    public void createQuoteRequest() {
    	String namespace = CSM_Util.getNameSpace();
		PageReference pageRef = Page.REN_QuoteRequestBatchResult;    	
    	try {
	        if(!String.isBlank(segmentIds)){
	        	List<String> segmentList = segmentIds.split(',');
	        	Set<String> segmentSet = new Set<String>();
	        	segmentSet.addAll(segmentList);
	        	List<REN_Segment__c> segmentListToUpdate = REN_SegmentDataAccess.getSegmentsById(segmentSet);
	        	
	        	for(REN_Segment__c segment: segmentListToUpdate){
	        		segment.REN_QuoteRequest_Submitted__c = true;
	        	}
	        	
	        	update segmentListToUpdate;
	        	Integer batchSize = CSM_Util.getCustomListSetting('REN_QuoteRequestCreationBatch');
	        	batchSize = (batchSize == null || batchSize == 0) ? 1 : batchSize;
	        	Database.executeBatch(new REN_QuoteRequestCreationBatch(),batchSize);
                displayQuoteRequestMsg = true;			        	
	        }
    	} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
    }
    
    public PageReference saveSegmentBatch(){
    	return null;
    }
    
    public PageReference cancel()
    {
    	PageReference pageRef = Page.REN_SegmentOverview;
		pageRef.getParameters().put('tabCategory', 'Playmaker');
		pageRef.setRedirect(true);
    	return pageRef;
    }
    
    public List<SelectOption> getTaskOwnerOptions(){
    	List<selectOption> options = new List<selectOption>();
		options.add(new SelectOption('Designated Owner','Designated Owner'));
        options.add(new SelectOption('Record Owner','Record Owner')); 
      	return options;
    }
    
    public PageReference generateTasks() {
    	String namespace = CSM_Util.getNameSpace();
		PageReference pageRef = Page.REN_SegmentTaskGeneration;    	
    	try {
	        if(!String.isBlank(segmentIds)){
	        	List<String> segmentList = segmentIds.split(',');
	        	if(segmentList.size() == 1) {
	        		pageRef.getParameters().put('tabCategory', 'Playmaker');
	        		pageRef.getParameters().put('seid', segmentList[0]);
					pageRef.setRedirect(true);
			    	return pageRef;
	        	}
	        				        	
	        }
    	} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			return null;
		}
		return null;
    }
}