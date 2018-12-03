public with sharing class REN_BatchOppGenSummaryController {
	public SObject batchActivityObj {get; set;}
	public REN_batchActivityWrapper batchActivityObjWrap {get; set;}
	private String batchId;
	public String batchActId{get; set;}
	public String closeDateFldLabel{get;set;}
	public String genCount='Success';
	public CSM_DataGridAttribute batchOppGenSummGridAttribute{get;set;}
	
	public REN_BatchOppGenSummaryController()
	{
		batchId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
		//batchActivityObj = new REN_Batch_Activity__c();
		batchActivityObj = REN_BatchActivityDataAccess.getBatchActSObject(batchId);
		batchActivityObjWrap = REN_BatchActivityHelper.getBatchActivityWrapperById(batchActivityObj);
		String nameSpace = CSM_Util.getNamespace();
		Map<String, Schema.SObjectField> ObjFldMap = Schema.SObjectType.Asset.fields.getMap();
		//Remove the namespace from the field name. As keys in the ObjFldMap contains the field name without namespace.
        String fldName = (String)batchActivityObj.get('REN_Closed_Date_Depends_On__c');
        //US2419 -- Commented code
        /*if(String.isNotBlank(nameSpace) && String.isNotBlank(fldName) && fldName.startsWith(nameSpace)){
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
    	batchOppGenSummGridAttribute = new CSM_DataGridAttribute();        
        batchOppGenSummGridAttribute.tableName = CSM_Constants.GRID_ATTR_BATCH_OPP_GEN_SUMM_TBL;
    	batchOppGenSummGridAttribute.objectType = CSM_Constants.GRID_ATTR_BATCH_OPP_GEN_SUMM_OBJ_TYPE;
    	batchOppGenSummGridAttribute.viewName = CSM_Constants.GRID_ATTR_BATCH_OPP_GEN_SUMM_VIEW_NAME;
    	batchOppGenSummGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_FILTER_TOOLBAR;
    	batchOppGenSummGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
    	batchOppGenSummGridAttribute.stateSave=CSM_Constants.GRID_ATTR_TRUE;
    	batchOppGenSummGridAttribute.hasShowColumns= CSM_Constants.GRID_ATTR_TRUE;
    	batchOppGenSummGridAttribute.showExport=CSM_Constants.GRID_ATTR_TRUE;
    	batchOppGenSummGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE;  
    	
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
     	gridInputParams.taskOrViewId = batchActId;
     	batchOppGenSummGridAttribute.params = JSON.serialize(gridInputParams);
     	Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		batchOppGenSummGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
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
    	sObject sObj = batchActivityObj.getSObject('REN_Source_Record_Filter__r');
    	if(sObj != null){
    		pageRef.getParameters().put('id',(Id)sObj.get('id'));
    	}
    	pageRef.getParameters().put('bid',batchActId);
    	pageRef.getParameters().put('cnt',genCount);
		pageRef.setRedirect(true);
		return pageRef;
    } 
    public PageReference editGroupRecord()
    {
    	PageReference pageRef = Page.ren_groupinglogic;
    	sObject sObj = batchActivityObj.getSObject('REN_Grouping__r');
    	if(sObj != null){
    		pageRef.getParameters().put('id',(Id)sObj.get('id'));
    	}
    	
    	pageRef.getParameters().put('bid',batchActId);
    	pageRef.getParameters().put('cnt',genCount);
		pageRef.setRedirect(true);
		return pageRef;
    }  
}