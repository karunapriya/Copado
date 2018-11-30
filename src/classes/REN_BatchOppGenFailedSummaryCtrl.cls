public with sharing class REN_BatchOppGenFailedSummaryCtrl {
	public SObject batchActivityObj {get; set;}
	public REN_batchActivityWrapper batchActivityObjWrap {get; set;}
	private String batchId;
	public String batchActId{get; set;}
	public String genCount='Fail';
	public String closeDateFldLabel{get;set;}
	public CSM_DataGridAttribute batchFailedGridAttribute{get;set;}
	public String batchTotal{get; set;}
	public REN_BatchOppGenFailedSummaryCtrl()
	{	
		batchId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
		batchActivityObj = REN_BatchActivityDataAccess.getBatchActSObject(batchId);
		batchActivityObjWrap = REN_BatchActivityHelper.getBatchActivityWrapperById(batchActivityObj);
		
		String nameSpace = CSM_Util.getNamespace();
		Map<String, Schema.SObjectField> ObjFldMap = Schema.SObjectType.Asset.fields.getMap();
		//Remove the namespace from the field name. As keys in the ObjFldMap
        	// contains the field name without namespace.
        String fldName = (String)batchActivityObj.get('REN_Closed_Date_Depends_On__c');
        //US2419 -- Commented code
        /*  if(String.isNotBlank(nameSpace) && String.isNotBlank(fldName) && fldName.startsWith(nameSpace)){
			fldName = fldName.removeStart(namespace).toLowerCase();
		} */
        if(ObjFldMap != null && ObjFldMap.containsKey(fldName)){
        	closeDateFldLabel =	ObjFldMap.get(fldName).getdescribe().getLabel();
		}
		batchActId = String.valueOf(batchActivityObj.get('id'));
		batchActId = batchActId.substring(0,15);
		setGridAttributes();
	}
	
	private void setGridAttributes()
    {
    	batchFailedGridAttribute = new CSM_DataGridAttribute();        
        batchFailedGridAttribute.tableName = CSM_Constants.GRID_ATTR_BATCH_FAILED_TBL;
    	batchFailedGridAttribute.objectType = CSM_Constants.GRID_ATTR_BATCH_FAILED_OBJ_TYPE;
    	batchFailedGridAttribute.viewName = CSM_Constants.GRID_ATTR_BATCH_FAILED_VIEW;
    	batchFailedGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_FILTER_TOOLBAR;
    	batchFailedGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
    	batchFailedGridAttribute.stateSave=CSM_Constants.GRID_ATTR_TRUE;
    	batchFailedGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
    	batchFailedGridAttribute.showExport=CSM_Constants.GRID_ATTR_TRUE;
    	batchFailedGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE;  
    	
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
     	gridInputParams.taskOrViewId = batchActId;
     	batchFailedGridAttribute.params = JSON.serialize(gridInputParams);
     	Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		batchFailedGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    }
	
	public PageReference deleteBatchFailures()
	{
		List<REN_Batch_Opportunity_Failure__c> lstFails = REN_BatchOppFailureDataAccess.getFailedAssetsRecords(batchActId);
		PageReference retPage = Page.ren_batchoppgenfailedsummary;
		retPage.getParameters().put('id', batchActId);
		
		retPage.setRedirect(true);
		if(lstFails != null && !lstFails.isEmpty())
		{
			if(lstFails.size() < 10000)
			{
				CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_BATCH_FAIL, null, CSM_Constants.DML_OPERATION_DELETE);
				delete lstFails;
			}
			else
			{
				Database.executeBatch(new REN_BatchOppFailureDataCleanupBatch(new Set<String>{batchActId}, true, -90), 200);
			}
		}
		return retPage;
	}
	
	public PageReference returnPage() 
	{    
        PageReference pageRef = Page.REN_BatchOppGenActivity;
		pageRef.getParameters().put('tabCategory', 'Renewal');
		pageRef.setRedirect(true);
    	return pageRef;
    }
    public PageReference editSourceRecord()
    {
    	PageReference pageRef = Page.REN_SourceRecordFilter;
    	pageRef.getParameters().put('id',(Id)batchActivityObj.getSObject('REN_Source_Record_Filter__r').get('id'));
    	pageRef.getParameters().put('bid',batchActId);
    	pageRef.getParameters().put('cnt',genCount);
		pageRef.setRedirect(true);
		return pageRef;
    } 
    public PageReference editGroupRecord()
    {
    	PageReference pageRef = Page.ren_groupinglogic;
    	pageRef.getParameters().put('id',(Id)batchActivityObj.getSObject('REN_Grouping__r').get('id'));
    	pageRef.getParameters().put('bid',batchActId);
    	pageRef.getParameters().put('cnt',genCount);
		pageRef.setRedirect(true);
		return pageRef;
    }  
}