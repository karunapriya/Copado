public with sharing class REN_BatchTaskGenSummaryController {
	public REN_Batch_Activity__c batchActivityObj {get; set;}
	public REN_batchActivityWrapper batchActivityObjWrap {get; set;}
	private String batchId;
	public String batchActId{get; set;}
	public CSM_DataGridAttribute batchTaskGenSummGridAttribute{get;set;}
	public String gridTitle {get; set;}
	private string typeVal;
	private String segmentType;
	
    public REN_BatchTaskGenSummaryController() {
		batchId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
		batchActivityObj = REN_BatchActivityDataAccess.getBatchActSObject(batchId);
		batchActivityObjWrap = REN_BatchActivityHelper.getBatchActivityWrapperById(batchActivityObj);
		String nameSpace = CSM_Util.getNamespace();
		batchActId = String.valueOf(batchActivityObj.get('id'));
		batchActId = batchActId.substring(0,15);
		
		typeVal = ApexPages.currentPage().getParameters().get('type');
		segmentType = (String) batchActivityObj.getSObject('REN_Segment__r').get('REN_Type__c');
		
		setGridAttributes();
		
		if(typeVal.equalsIgnoreCase('success')) {
			gridTitle = Label.LBL_GENERATED_TASKS;
		} else if(typeVal.equalsIgnoreCase('failed')) {
			gridTitle = Label.LBL_FAILURE_RECORDS;
		}
	}
	
	private void setGridAttributes() {
		batchTaskGenSummGridAttribute = new CSM_DataGridAttribute();
		batchTaskGenSummGridAttribute.tableName = 'BatchTaskGenSummary';
		batchTaskGenSummGridAttribute.objectType  = 'BatchTaskGenSummary';
				
		if(typeVal.equalsIgnoreCase('success')) {
	    	batchTaskGenSummGridAttribute.viewName = 'BatchTaskGenSummary_Success';
		} else if(typeVal.equalsIgnoreCase('failed')) {
			batchTaskGenSummGridAttribute.viewName = 'BatchTaskGenSummary_Failed';
		}
		
	    batchTaskGenSummGridAttribute.gridToolBarId = '';
	    batchTaskGenSummGridAttribute.hasSearch = 'true';
	    batchTaskGenSummGridAttribute.stateSave = 'true';
	    batchTaskGenSummGridAttribute.hasShowColumns = 'true';
	    batchTaskGenSummGridAttribute.showExport ='true';
	    batchTaskGenSummGridAttribute.showGlobalSelect = 'true';
	    
	    CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
     	gridInputParams.taskOrViewId = batchActId;
     	gridInputParams.selectedFilterClause = segmentType;
     	batchTaskGenSummGridAttribute.params = JSON.serialize(gridInputParams);
     	
	    Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
 	    batchTaskGenSummGridAttribute.userDateFormat = localeMap.get(userInfo.getLocale());
    }
    
	public PageReference returnPage() {    
        PageReference pageRef = Page.REN_TaskGenerationActivity;
		pageRef.getParameters().put('tabCategory', 'Playmaker');
		pageRef.setRedirect(true);
    	return pageRef;
    }
	public PageReference goToSegmentPage() {    
        PageReference pageRef = Page.REN_SegmentAdditionalDetails;
		pageRef.getParameters().put('parentId', (String)batchActivityObj.get('REN_Segment__c'));
		pageRef.getParameters().put('tabCategory', 'Playmaker');
		pageRef.setRedirect(true);
    	return pageRef;
    }
}