public with sharing class CSM_BatchPlanTemplateAssignController {
	public String helpParam{get;set;}
	public String selectedRowId{get;set;}	
	public REN_Batch_Activity__c renBatch{get;set;}	
	public CSM_Account_Plan_Template__c acctPlanTemp{get;set;}	
	public CSM_Batch_Success_Plan_Default__c planDefault {get; set;}
	public String editPlanDefaultRecordId{get;set;}
	public String editFilterRecordId{get;set;}	
	public String selectedPlanDefaultId {get; set;}
	public CSM_DataGridAttribute objectFilterGridAttribute {get; set;}
	public CSM_DataGridAttribute planDefaultAttribute {get; set;}	
		
	public CSM_BatchPlanTemplateAssignController(){
		renBatch = new REN_Batch_Activity__c();
		planDefault = new CSM_Batch_Success_Plan_Default__c();
		selectedPlanDefaultId = ApexPages.currentPage().getParameters().get('pid');
		selectedRowId = ApexPages.currentPage().getParameters().get('fid');
		populateGridAttributes();		
	}
	
	private void populateGridAttributes()
	{
		 objectFilterGridAttribute = new CSM_DataGridAttribute();
		 objectFilterGridAttribute.tableName= CSM_Constants.GRID_ATTR_OBJ_FILTER_TBL;
		 objectFilterGridAttribute.objectType=CSM_Constants.GRID_ATTR_OBJ_FILTER_OBJ_TYPE;
		 objectFilterGridAttribute.viewName=CSM_Constants.CSM_PTA;
		 objectFilterGridAttribute.gridSize=5;
		 objectFilterGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_FILTER_TOOLBAR;
		 objectFilterGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
		 objectFilterGridAttribute.stateSave=CSM_Constants.GRID_ATTR_TRUE;
		 objectFilterGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_FALSE;
		 objectFilterGridAttribute.showExport=CSM_Constants.GRID_ATTR_FALSE;
		 objectFilterGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_FALSE;
		
		 CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
         gridInputParams.selectedTaskFilter = selectedRowId;
         gridInputParams.taskOrViewId = '';
 		 objectFilterGridAttribute.params =JSON.serialize(gridInputParams);
		 
	     planDefaultAttribute = new CSM_DataGridAttribute();
	     planDefaultAttribute.tableName=CSM_Constants.GRID_ATTR_PLAN_DEFAULT_TBL;
	     planDefaultAttribute.objectType= CSM_Constants.GRID_ATTR_PLAN_DEFAULT_OBJ_TYPE;
	     planDefaultAttribute.viewName=CSM_Constants.GRID_ATTR_PLAN_DEFAULT_VIEW;
	     planDefaultAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_GROUP_TOOLBAR;
	     planDefaultAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE; 
	     planDefaultAttribute.stateSave=CSM_Constants.GRID_ATTR_TRUE;
	     planDefaultAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_FALSE;
	     planDefaultAttribute.showExport=CSM_Constants.GRID_ATTR_FALSE;
	     planDefaultAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE;
	     
	     gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();
 	     gridInputParams.taskOrViewId = '';
         gridInputParams.selectedTaskFilter = selectedPlanDefaultId;
 		 planDefaultAttribute.params =JSON.serialize(gridInputParams);
	}
	
	public void savePlanBatch(){
	
	}

	public pageReference populateUser(){
		acctPlanTemp = CSM_AccountPlanTemplateDataAccess.populateAccountPlanTemplateInformation(renBatch.REN_Plan_Template_Id__c);
		//renBatch.REN_Plan_Template_Name__c = acctPlanTemp.CSM_Template_Name__c;
		renBatch.REN_Plan_Template_Id__c = acctPlanTemp.Id;	
		
		return null;
	}

	public PageReference cancel(){
        PageReference pageRef = Page.csm_batchsuccessplanactivity;
        pageRef.getParameters().put('tabCategory', 'Admin');
        pageRef.setRedirect(true);
        return pageRef;

    } 

	
	public PageReference createNewObjectFilterRecord(){
		PageReference pageRef = Page.CSM_SourceRecordPTAFilter;
		String rUrl = pageRef.getUrl();
				
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
    	populateUrlParameters(pageRef);

    	return PageRef;		
	}

	public PageReference editObjectFilterRecord(){
		PageReference pageRef = Page.CSM_SourceRecordPTAFilter;
		String rUrl = pageRef.getUrl();
				
		pageRef.getParameters().put(CSM_Constants.ID_PARAM,editFilterRecordId);
    	populateUrlParameters(pageRef);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
    	pageRef.getParameters().put(CSM_Constants.SAVE_URL,rUrl);

    	return PageRef;		
	
	}

	public PageReference editPlanDefaultRecord()
    {
    	PageReference pageRef = Page.CSM_BatchSuccessPlanDefault;
    	pageRef.getParameters().put('id',editPlanDefaultRecordId);
    	populateUrlParameters(pageRef);
		return pageRef;
    }  
    public PageReference createPlanDefaultRecord()
    {
    	PageReference pageRef = Page.CSM_BatchSuccessPlanDefault;
    	populateUrlParameters(pageRef);
		return pageRef;
    }

    public PageReference populateUrlParameters(PageReference pageRef)
    {
    	pageRef.getParameters().put('tabCategory', 'SuccessPlan');
		pageRef.getParameters().put('pid',selectedPlanDefaultId);
		pageRef.getParameters().put('fid',selectedRowId);
		
		pageRef.setRedirect(true);						
		return pageRef;
    }

}