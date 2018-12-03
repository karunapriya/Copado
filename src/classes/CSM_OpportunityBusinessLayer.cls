public with sharing class CSM_OpportunityBusinessLayer extends CSM_BusinessLayer {
	private static Boolean displayEditOpp;
	private static Boolean displayDeleteOpp;
	public CSM_OpportunityBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
		super(inputWrapper);
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
		return getOpportunityWrapperList();
	}
	
	private CSM_GridResponseWrapper getOpportunityWrapperList() {
		CSM_GridResponseWrapper opportunityResponseWrapper = new CSM_GridResponseWrapper();
		if (this.inputWrapper.viewName == CSM_Constants.GRID_ATTR_CONSOLIDATE)
		{
			displayEditOpp = false;
	   	    displayDeleteOpp = false;
	   	    opportunityResponseWrapper.hasCheckbox = true;
		}
		else 
		{
			displayEditOpp = CSM_AccessController.getInstance().objectCrudCheck(CSM_Constants.OBJ_OPPORTUNITY, CSM_Constants.DML_OPERATION_UPDATE);
	   	    displayDeleteOpp = CSM_AccessController.getInstance().objectCrudCheck(CSM_Constants.OBJ_OPPORTUNITY, CSM_Constants.DML_OPERATION_DELETE);
		    opportunityResponseWrapper.hasCheckbox = false;
		    opportunityResponseWrapper.hasAction = true;
		    opportunityResponseWrapper.hasDetail = false;
		}	
		
		opportunityResponseWrapper.header = setOpportunityHeader();
		
		opportunityResponseWrapper.row = setOpportunityRows(getOpportunityList(), opportunityResponseWrapper.header);
		
        return opportunityResponseWrapper;
	}
	
	private List<Opportunity> getOpportunityList(){
		List<Opportunity> opportunityList = new List<Opportunity>();
		String filterId = inputWrapper.params.selectedFilterClause;
		if (this.inputWrapper.viewName == CSM_Constants.GRID_ATTR_CONSOLIDATE)
		{
			
			Set<Id> accountIdSet = new Set<Id>();
			if (this.inputWrapper.params.accountId != null)
			{
				accountIdSet.add(this.inputWrapper.params.accountId);
			}
			
			Boolean allowSyncedQuote = true;
			SS_Validations__c ssValidationsGlobal = SS_Validations__c.getOrgDefaults();
			/*
			if (CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY, 'SyncedQuoteId'))
			{			
				allowSyncedQuote = !ssValidationsGlobal.REN_Disable_Consolidate_Synced_Quote__c;
			}
			*/
			Set<String> allowedStages = new Set<String>();
			if (String.isNotBlank(ssValidationsGlobal.REN_No_Split_allowed_for_Opp_Stage__c))
			{
				allowedStages = REN_Util.convertCSVtoSet(ssValidationsGlobal.REN_No_Split_allowed_for_Opp_Stage__c, ',');
			}
			
			opportunityList = REN_OpportunityDataAccess.getConsolidateFieldSetByAccount(accountIdSet, 
			    false, allowSyncedQuote, allowedStages, false,filterId);
		}
		else
		{
			if (String.isNotBlank(this.inputWrapper.params.accountId)){
				List<CSM_Account_Plan__c> accountPlan = CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(null, this.inputWrapper.params.accountId);
				if(accountPlan != null && !accountPlan.isEmpty()){
		        	opportunityList = CSM_OpportunityDataAccess.getDetailFieldSetByAccount(this.inputWrapper.params.accountId, 
		        																			accountPlan[0].CSM_Phase_Start_Date__c);
				}
			} else {
				opportunityList = new List<Opportunity>();
			}
		}
		return opportunityList;
	}
	
	private List<CSM_GridRowWrapper> setOpportunityRows(List<sObject> opportunityList, List<CSM_GridColumnWrapper> colList) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
        
		for(sObject sObj : opportunityList) {
			CSM_GridRowWrapper row = new CSM_GridRowWrapper();
			row.id = (String)sObj.get('Id');
			setRowAction(row, sObj);
			row.sObj = sObj;
			row.isMC = CSM_Util.checkMCEnabled();
			row.namespace = CSM_Util.getNamespace();
			row.columns = new List<CSM_GridColumnWrapper>();
			if (colList!=null){
				row.columns = colList;
				gridRowWrapper.add(row);
			}
		}
		
		return gridRowWrapper;
	}
	
	private void setRowAction(CSM_GridRowWrapper row, sObject sObj){
		if (this.inputWrapper.viewName != CSM_Constants.GRID_ATTR_CONSOLIDATE)
			{
			row.actions = new List<CSM_GridActionWrapper>();
			if(displayEditOpp){
				CSM_GridActionWrapper editWrap = new CSM_GridActionWrapper('Edit');
				editWrap.hrefAction = '/' + row.id + '/e?retURL=' 
									+ Page.CSM_AccountSuccessPlan.getUrl()+'?id=' + this.inputWrapper.params.accountPlanId;
	            editWrap.titleAction = Label.CSM_LBL_EDIT;
      			editWrap.classAction = 'actionLink';
			    row.actions.add(editWrap);
			}
			if(displayDeleteOpp){
			
				CSM_GridActionWrapper deleteWrap = new CSM_GridActionWrapper('Del');
				deleteWrap.hrefAction = 'javascript:void(0);';
				deleteWrap.onclickAction = 'confirmDeleteOpp(\''+row.id+'\')';
				deleteWrap.titleAction = Label.REN_Delete;
      			row.actions.add(deleteWrap);
			}
		}
	}
	
	private List<CSM_GridColumnWrapper> setOpportunityHeader() {
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		//Completion Date
		CSM_GridColumnWrapper opportunityColumn = new CSM_GridColumnWrapper();
		
		//Name
		opportunityColumn = new CSM_GridColumnWrapper();
		opportunityColumn.apiName = 'Name';
		opportunityColumn.label = 'Name';
		opportunityColumn.valueCol = 'Name';
		opportunityColumn.isSortable = true;
		opportunityColumn.customColumnSorter = 'customColumnSorter';	
		opportunityColumn.lookUpIdCol = 'Id';
		opportunityColumn.isDateCol = false;
		gridClmWrapper.add(opportunityColumn);
		
		List<Schema.FieldSetMember> fieldSetMembers = null;
        if (this.inputWrapper.viewName == CSM_Constants.GRID_ATTR_CONSOLIDATE)
		{
			fieldSetMembers = SObjectType.Opportunity.FieldSets.REN_Consolidate_ListView_Fieldset.getFields();
		}
        else
        {
        	fieldSetMembers = SObjectType.Opportunity.FieldSets.CSM_Details_Fieldset.getFields();
        }
        
		for(Schema.FieldSetMember fld :fieldSetMembers) 
        {
            opportunityColumn = new CSM_GridColumnWrapper();
			opportunityColumn.apiName = fld.getFieldPath();
			opportunityColumn.customColumnSorter = 'customColumnSorter';
	
			if(fld.getFieldPath().contains('AccountId')) {
				opportunityColumn.valueCol = fld.getFieldPath().replaceAll('AccountId', 'Account.Name');
				opportunityColumn.label = Label.CHL_Account;
			} else if(fld.getFieldPath().contains('Pricebook2Id')) {
				opportunityColumn.valueCol = fld.getFieldPath().replaceAll('Pricebook2Id', 'Pricebook2.Name');
				opportunityColumn.label = Label.LBL_PRICEBOOK;
			} else {
				opportunityColumn.valueCol = fld.getFieldPath();
				opportunityColumn.label = fld.getLabel();
			}
	
			if(opportunityColumn.valueCol == 'Amount')
			{
				opportunityColumn.dataAlign = 'right';
				opportunityColumn.label = opportunityColumn.label + ' ('+UserInfo.getDefaultCurrency() +')';
				opportunityColumn.isCurrencyCol = true;		
			}
			
			opportunityColumn.isSortable = true;
			
			opportunityColumn.isDateCol = fld.getType().equals(Schema.DisplayType.DATE)?true:false;
			gridClmWrapper.add(opportunityColumn);           
        }
        if (this.inputWrapper.viewName == CSM_Constants.GRID_ATTR_CONSOLIDATE)
		{
			opportunityColumn = new CSM_GridColumnWrapper();
			opportunityColumn.apiName = 'Ownerid';
			opportunityColumn.label = 'Owner';
			opportunityColumn.valueCol = 'Owner.Name';
			opportunityColumn.isSortable = true;
			opportunityColumn.customColumnSorter = 'customColumnSorter';
			opportunityColumn.lookUpIdCol = 'OwnerId';
			//colAssignedTo.filterControl = 'select'; 
			
			opportunityColumn.isVisible = true;
			gridClmWrapper.add(opportunityColumn);
		}
       
		return gridClmWrapper;
	}
}