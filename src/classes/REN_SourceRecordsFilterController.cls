public with sharing class REN_SourceRecordsFilterController extends REN_BaseMainController{

	public String criteria {get; set;}
	public String helpParam {get; set;}
    public String selCurrency {get; set;}	
	public List<REN_LogicBuilderInputWrapper> lbInputWrapperList{get;set;}
	public REN_Renew_Configuration__c renconfigobj{get;set;}
	public String configId{get;set;}
	private Boolean criteriaFlag;
	public String sourceSelectedRowId{get;set;}
	public String groupSelectedRowId{get;set;}
	public String batchId{get;set;}
	public String genCount{get;set;}
	public Boolean errValidationMsg{get;set;}
	private REN_Renew_Configuration__c renewalRenewObj;
	private REN_LogicBuilderInputWrapper assetLogicBuilderInputWrapper;
	public CSM_DataGridAttribute assetGridAttribute{get; set;}

	public REN_SourceRecordsFilterController()
	{
		super();
		errValidationMsg = true;
		criteriaFlag = false;
		criteria='';
		helpParam = CSM_Constants.HELP_DATA_GENERATION;
		configId = ApexPages.currentPage().getParameters().get('Id');
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
			renewalRenewObj = new REN_Renew_Configuration__c();
			this.lbInputWrapperList = new List<REN_LogicBuilderInputWrapper>();
			
			assetLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(renconfigobj,REN_Constants.OBJ_LC, REN_Constants.OBJ_ASSET, 'recordKeyName', false, this, ''
										, 'refreshLB1', 'onChangeDate1',true,'AccountId,Product2Id');
        	this.lbInputWrapperList.add(assetLogicBuilderInputWrapper);
        	REN_LogicBuilderInputWrapper rrLogicBuilderInputWrapper =new REN_LogicBuilderInputWrapper(renewalRenewObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_REN_RENEWS_TO, 
                                            'SourceFilterByRenewTo', false, this, '','refreshLB2', 'onChangeDate2', false, '');
			this.lbInputWrapperList.add(rrLogicBuilderInputWrapper);		
			
			rrLogicBuilderInputWrapper.isCurrencyOptionDisabled = true;
			assetLogicBuilderInputWrapper.dependentLogicBuilder = rrLogicBuilderInputWrapper;
		}
		setGridAttributes();
	}

    private void setGridAttributes()
    {
    	assetGridAttribute = new CSM_DataGridAttribute();        
        assetGridAttribute.tableName = Schema.SObjectType.Asset.label;
    	assetGridAttribute.objectType =Schema.SObjectType.Asset.label;
    	assetGridAttribute.viewName =CSM_Constants.GRID_ATTR_ASSET_VIEW;
    	assetGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
    	assetGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
    	assetGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
    	assetGridAttribute.gridToolBarId='grid-toolbar';
    	assetGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
    	
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
     	gridInputParams.selectedFilterClause = criteria;
 	    gridInputParams.gridCurrency = selCurrency;     	
     	assetGridAttribute.params = JSON.serialize(gridInputParams);
    }
    
	public PageReference createRenewConfig()
	{
			renconfigobj.REN_Record_Key__c = renconfigobj.REN_View_Name__c + '_' + REN_Constants.FILTER;
			renconfigobj.REN_Configuration_Type__c = REN_Constants.FILTER;
			renconfigobj.REN_Is_Active__c = true;
			
			renewalRenewObj.REN_Record_Key__c = renconfigobj.REN_View_Name__c + '_' + REN_Constants.FILTER+'_πRR';
			renewalRenewObj.REN_View_Name__c = renconfigobj.REN_View_Name__c +'_πRR';
			renewalRenewObj.REN_Configuration_Type__c = REN_Constants.RENEW_REL_FILTER;
			renewalRenewObj.REN_Is_Active__c = true;
			return null;
	}

	public void retrieveRenewConfig(string configId)
	{
		this.renconfigobj=REN_RenewConfigurationDataAccess.getRenewConfigByIdy(configId);
		this.renewalRenewObj = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(renconfigobj.REN_Record_Key__c+'_πRR');
		renewalRenewObj = (renewalRenewObj == null )? new REN_Renew_Configuration__c() : renewalRenewObj;
		this.lbInputWrapperList = new List<REN_LogicBuilderInputWrapper>();
		
		assetLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(renconfigobj,REN_Constants.OBJ_LC, 'Asset', 'recordKeyName', false, this, ''
										, 'refreshLB1', 'onChangeDate1',true,'AccountId,Product2Id');
        this.lbInputWrapperList.add(assetLogicBuilderInputWrapper);
        
        REN_LogicBuilderInputWrapper rrLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(renewalRenewObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_REN_RENEWS_TO, 
                                            'SourceFilterByRenewTo', false, this, '', 'refreshLB2', 'onChangeDate2', false, '');
		this.lbInputWrapperList.add(rrLogicBuilderInputWrapper);										
		rrLogicBuilderInputWrapper.isCurrencyOptionDisabled = true;
		assetLogicBuilderInputWrapper.dependentLogicBuilder = rrLogicBuilderInputWrapper;
	}

	public PageReference saveDataGeneration(){
		String errMsg;
		try {
			createRenewConfig();
			String viewName = renconfigobj.REN_View_Name__c;
			if(String.isBlank(viewName)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_VIEW_NAME_CAN_NOT_EMPTY));
				return null;
			}
			findForCriteria(true);
			if(criteriaFlag)
			{
				criteriaFlag=false;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_NO_CRITERIA_ERR_MSG_FC));
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
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CHL_GENERAL_ERROR + ex.getMessage() ));
			}
		}
		PageReference pageRef = Page.ren_batchoppgeneration;
		if(configId!=null){
			pageRef.getParameters().put('sid',configId);
		}
		else{
			pageRef.getParameters().put('sid',renconfigobj.id);
		}
		pageRef.getParameters().put('gid',groupSelectedRowId);
		pageRef.getParameters().put('tabCategory', 'Renewal');
		pageRef.setRedirect(true);
		if(errMsg != null &&  errMsg.contains('DUPLICATE_VALUE')){
			return null;
		}
		if(!ApexPages.hasMessages(ApexPages.Severity.ERROR))
		{
			return pageRef;
		}
		else
		{
			return null;
		}
	}

	public PageReference cancel(){
		PageReference pageRef= Page.ren_batchoppgeneration;
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

	public PageReference findFor()
	{
		try
		{
			findForCriteria(false); 
 		    REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance('recordKeyName_' + REN_Constants.OBJ_ASSET);       	
		    this.selCurrency = selectedCtrl.corpCurr;
			setGridAttributes();		      

			if(!ApexPages.hasMessages())
			{
				errValidationMsg = true;
				criteria = ' Where '+REN_Util.constructWhereClause(this.renconfigobj.REN_Filter_Criteria__c,this.renewalRenewObj.REN_Filter_Criteria__c,'REN_Asset__c');
				system.debug('criteria:::'+criteria);
				
			}
			else
			{
				criteria = 'error';
			}
			
		}
		catch(Exception ex)
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input - '+ex.getMessage());
			ApexPages.addMessage(myMsg);
			errValidationMsg = false;
		}
		return null;
	}
	
	private void findForCriteria(Boolean isSave)
    {	
    	criteriaFlag = performFind('recordKeyName_' + REN_Constants.OBJ_ASSET,isSave);
    	performFind('SourceFilterByRenewTo_' + REN_Constants.OBJ_REN_RENEWS_TO,isSave);
    }
	
	private Boolean performFind(String logicBulderInst,Boolean isSave){
		REN_LogicBuilderCmpCtrl selectedCtrl=new REN_LogicBuilderCmpCtrl();
		selectedCtrl = this.findLogicBuilderInstance(logicBulderInst);
		selectedCtrl.logicBuilderInput.isSearch=!isSave;
		Boolean emptyCriteria = false;
		//to check if there is any added criteria, if nothing is added do not call the save method.
		//This is only for assets, all criterias cannot be empty
		if(logicBulderInst.equalsIgnoreCase('recordKeyName_' + REN_Constants.OBJ_ASSET)){
			emptyCriteria = true;
			for(REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper criObj: selectedCtrl.criteriaWrapperList){
				if((String)criObj.criteria.get('RLM_Field_Name__c')!='--None--'){
					emptyCriteria = false;
					break;
				}
			}
		}
		if( isSave && emptyCriteria == false){
			selectedCtrl.performFind();
		}else if(isSave == false ){
			selectedCtrl.performFind();
		}
		return emptyCriteria;
	}
	
	private REN_LogicBuilderCmpCtrl findLogicBuilderInstance(String uniqueLogicBuilderInstance){
		Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
		return (REN_LogicBuilderCmpCtrl)baseChildControllerMap.get(uniqueLogicBuilderInstance);
	}
}