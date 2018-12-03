public with sharing class CSM_SourceRecordPTAFilterController extends REN_BaseMainController{
	public REN_Renew_Configuration__c renewObj{get;set;}
	public Map<String, REN_LogicBuilderInputWrapper> logicBuilderWapperMap{get;set;}
	private String fId , pId;
	
	public CSM_SourceRecordPTAFilterController(){
		String configId = ApexPages.currentPage().getParameters().get('Id');
		fId = ApexPages.currentPage().getParameters().get('fid');
		pId = ApexPages.currentPage().getParameters().get('pid');
		if(configId != null){
			this.renewObj = REN_RenewConfigurationDataAccess.getRenewConfigByIdy(configId);
		}else{
			this.renewObj=new REN_Renew_Configuration__c(REN_Plan_Object_Name__c = CSM_Constants.OBJ_TYPE_ACCOUNT);			
			renewObj.REN_Configuration_Type__c = 'CSM_PTA';
			renewObj.REN_Is_Active__c = true;
		}
		this.logicBuilderWapperMap = new Map<String, REN_LogicBuilderInputWrapper>();
		this.logicBuilderWapperMap.put(CSM_Constants.OBJ_TYPE_ACCOUNT, new REN_LogicBuilderInputWrapper(this.renewObj, REN_Constants.OBJ_LC, CSM_Constants.OBJ_TYPE_ACCOUNT, CSM_Constants.OBJ_TYPE_ACCOUNT, true, this, '', 'refreshLB1', 'onChangeDate1', false, ''));
		this.logicBuilderWapperMap.put(CSM_Constants.OBJ_CONTRACT, new REN_LogicBuilderInputWrapper(this.renewObj, REN_Constants.OBJ_LC, CSM_Constants.OBJ_CONTRACT, CSM_Constants.OBJ_CONTRACT, true, this, '', 'refreshLB1', 'onChangeDate1', false, ''));
		this.logicBuilderWapperMap.put(CSM_Constants.OBJ_TYPE_OPPORTUNITY, new REN_LogicBuilderInputWrapper(this.renewObj, REN_Constants.OBJ_LC, CSM_Constants.OBJ_TYPE_OPPORTUNITY, CSM_Constants.OBJ_TYPE_OPPORTUNITY, true, this, '', 'refreshLB1', 'onChangeDate1', false, 'AccountId'));
	}
	
    
	public PageReference save(){
		String errMsg;
		try {
			String viewName = renewObj.REN_View_Name__c;
			if(String.isBlank(viewName)){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(Label.CSM_ERR_EMPTY_FIELD, new String[]{'View Name'})));
				return null;
			}
			REN_LogicBuilderCmpCtrl selectedCtrl = (REN_LogicBuilderCmpCtrl)getBaseChildControllerMap().get(renewObj.REN_Plan_Object_Name__c + '_' + renewObj.REN_Plan_Object_Name__c);
			Boolean emptyCriteria = true;
			//to check if there is any added criteria, if nothing is added do not call the save method. This is only for assets, all criterias cannot be empty
			for(REN_LogicBuilderCmpCtrl.REN_LineCriteriaWrapper criObj: selectedCtrl.criteriaWrapperList){
				system.debug(criObj);
				if((String)criObj.criteria.get('RLM_Field_Name__c')!='--None--'){
					emptyCriteria = false;
					break;
				}
			}
			if(emptyCriteria && !Test.isRunningTest()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_NO_CRITERIA_ERR_MSG_FC));
				return null;
			}
			renewObj.REN_Record_Key__c = 'CSM_PTA: ' + renewObj.REN_View_Name__c;
			selectedCtrl.logicBuilderInput.isSearch = false;
			selectedCtrl.performSave();
			fId = renewObj.id;
			if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){ 
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, String.format(Label.REN_MSG_RENEWAL_CONFIG_SAVED, new String[]{renewObj.REN_Plan_Object_Name__c + ' Record Filter'})));
			}
		}catch(Exception ex){
			errMsg = ex.getMessage();
			system.debug(renewObj + '\n\n'+ ex);
			system.debug(ex.getStackTraceString());
			if(errMsg != null &&  errMsg.contains('DUPLICATE_VALUE')){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, String.format(System.Label.DUPLICATE_FILTER_NAME, new String[] {renewObj.REN_View_Name__c})));
			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,  REN_Util.getGenericErrorMessage(ex, null)));
			}
		}
		if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){
			return cancel();
		}
		return null;
					
	}
	
	public PageReference cancel(){
		PageReference pageRef = Page.csm_batchplantemplateassignment;
		pageRef.getParameters().put('tabCategory','SuccessPlan');
		pageRef.getParameters().put('id',renewObj.id);
		pageRef.getParameters().put('fid',fId);
		pageRef.getParameters().put('pid',pId);
		pageRef.setRedirect(true);
		return pageRef;
	}

	
	public PageReference objectTypeChanged(){
		REN_LogicBuilderCmpCtrl selectedCtrl = (REN_LogicBuilderCmpCtrl)getBaseChildControllerMap().get(renewObj.REN_Plan_Object_Name__c + '_' + renewObj.REN_Plan_Object_Name__c);
		if(selectedCtrl != null &&selectedCtrl.criteriaWrapperList != null){
	            selectedCtrl.criteriaWrapperList.clear();
	            selectedCtrl.populateDefaultCriteria();
        }
		return null;
	}


}