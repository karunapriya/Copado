public with sharing class REN_GroupingLogicController extends REN_BaseMainController{
public String configurationType{get;set;}
	public String criteria {get; set;}
	public String helpParam {get; set;}
	public REN_LogicBuilderInputWrapper logicBuilderObj{get;set;}
	public REN_Renew_Configuration__c renconfigobj{get;set;}
	public String configId {get;set;}
	private Boolean errFlag{get;set;}
	public String sourceSelectedRowId{get;set;}
	public String groupSelectedRowId{get;set;}
	public String batchId{get;set;}
	public String genCount{get;set;}
	public CSM_DataGridAttribute groupingLogicGridAttribute{get; set;}

	public REN_GroupingLogicController()
	{
		super();
		errFlag=false;
		criteria='';
		configurationType='Grouping';
		helpParam = CSM_Constants.HELP_DATA_GENERATION;
		configId = ApexPages.currentPage().getParameters().get('Id');//'a0Wj0000002SpfJ';
		sourceSelectedRowId=ApexPages.currentPage().getParameters().get('sId');
		groupSelectedRowId=ApexPages.currentPage().getParameters().get('gId');
		batchId = ApexPages.currentPage().getParameters().get('bid');
		genCount = ApexPages.currentPage().getParameters().get('cnt');
		if(configId != null){
			retrieveRenewConfig(configId);
		}
		else
		{
			this.renconfigobj=new REN_Renew_Configuration__c();
			logicBuilderObj=new REN_LogicBuilderInputWrapper(renconfigobj, 
				REN_Constants.OBJ_LC, 'Asset', 'recordKeyName', false, this, ''
				, 'refreshLB1', 'onChangeDate1',true,'AccountId,Product2Id');
				
		}
		setGridAttributes();
	}

    private void setGridAttributes()
    {								 
    	groupingLogicGridAttribute = new CSM_DataGridAttribute();     
        groupingLogicGridAttribute.tableName = Schema.SObjectType.Asset.label;
    	groupingLogicGridAttribute.objectType =Schema.SObjectType.Asset.label;
    	groupingLogicGridAttribute.viewName =CSM_Constants.GRID_ATTR_ASSET_VIEW;
    	groupingLogicGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
    	groupingLogicGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
    	groupingLogicGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_FALSE;
    	groupingLogicGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
    	groupingLogicGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE;  
    	
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
     	gridInputParams.selectedFilterClause = criteria;
     	groupingLogicGridAttribute.params = JSON.serialize(gridInputParams);
    }

	public PageReference createRenewConfig()
	{
		renconfigobj.REN_Record_Key__c = renconfigobj.REN_View_Name__c + '_' + configurationType;
		renconfigobj.REN_Configuration_Type__c = configurationType;
		renconfigobj.REN_Is_Active__c = true;
		return null;
	}

	public void retrieveRenewConfig(string configId)
	{
		this.renconfigobj=REN_RenewConfigurationDataAccess.getRenewConfigByIdy(configId);
		logicBuilderObj=new REN_LogicBuilderInputWrapper(renconfigobj, 
				REN_Constants.OBJ_LC, 'Asset', 'recordKeyName', false, this, ''
				, 'refreshLB1', 'onChangeDate1',true,'AccountId,Product2Id');
	}

	public PageReference saveDataGeneration(){
		String errMsg ;
		try {
			createRenewConfig();
			String viewName = renconfigobj.REN_View_Name__c;
			if(String.isBlank(viewName)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_VIEW_NAME_CAN_NOT_EMPTY));
				return null;
			}
			saveFilterCriteria();
			if(errFlag){
				errFlag=false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_NO_CRITERIA_ERR_MSG_GL));
				return null;
			}
			if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){ 
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 
						String.format(Label.REN_MSG_RENEWAL_CONFIG_SAVED, new String[]{'Source Record Filter'})));
			}    		
		}catch(Exception ex){
			errMsg = ex.getMessage();
			if(errMsg != null &&  errMsg.contains('DUPLICATE_VALUE')){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_FILTER_NAME_ALREADY_PRESENT));
			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(ex, ex.getMessage())));
			}
		}
		PageReference pageRef = Page.ren_batchoppgeneration;
		if(configId!=null){
			pageRef.getParameters().put('gid',configId);
		}
		else{
			pageRef.getParameters().put('gid',renconfigobj.id);
		}
		pageRef.getParameters().put('sid',sourceSelectedRowId);
		pageRef.getParameters().put('tabCategory', 'Renewal');
		pageRef.setRedirect(true);
		if(errMsg != null &&  errMsg.contains('DUPLICATE_VALUE')){
			return null;
		}
		return pageRef;
	
	}

	public PageReference cancel(){
		PageReference pageRef = Page.ren_batchoppgeneration;
		if(batchId != null)
		{
			if(genCount == 'Success')
			{
				pageRef = Page.REN_BatchOppGenSummary;
				pageRef.getParameters().put('id',batchId);
				pageRef.setRedirect(true);
			}
			else
			{
				pageRef = Page.REN_BatchOppGenFailedSummary;
				pageRef.getParameters().put('id',batchId);
				pageRef.setRedirect(true);
			}
		}
		else
		{
			pageRef = Page.ren_batchoppgeneration;
			pageRef.getParameters().put('sid',sourceSelectedRowId);
			pageRef.getParameters().put('gid',groupSelectedRowId);
			pageRef.getParameters().put('tabCategory', 'Renewal');
			pageRef.setRedirect(true);
		}
		return pageRef;
	}

	private void saveFilterCriteria(){
		Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
		for(REN_BaseChildController baseChildController : baseChildControllerMap.values()){
			if(baseChildController instanceof REN_GroupingLogicBuilder){
				if(((REN_GroupingLogicBuilder)baseChildController).criteriaWrapperList.isEmpty()){
					errFlag=true;
				}else{
					((REN_GroupingLogicBuilder)baseChildController).performSave();
				}
			}
		}
	}
}