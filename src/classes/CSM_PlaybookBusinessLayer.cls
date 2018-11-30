public with sharing class CSM_PlaybookBusinessLayer extends CSM_BusinessLayer {
	//private Map<String,String> sppbToPlaybook = new Map<String,String>();
	public CSM_PlaybookBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
		super(inputWrapper);
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
		return getPlaybookWrapperList();
	}
	
	private CSM_GridResponseWrapper getPlaybookWrapperList() {
		CSM_GridResponseWrapper pbResponseWrapper = new CSM_GridResponseWrapper();
		pbResponseWrapper.header = setOpportunityHeader();
		pbResponseWrapper.hasCheckbox = false;
		pbResponseWrapper.hasAction = true;
		pbResponseWrapper.hasDetail = false;
		Map<Id, CSM_Account_Plan_Playbook__c> mapAcctPlanPlaybook = new Map<Id, CSM_Account_Plan_Playbook__c>();
		Map<Id, Boolean> displayDeleteLink = new Map<Id, Boolean>();
		List<CSM_Account_Plan_Playbook__c> playbookList = getPlaybookList();
		//retrieveReEntrantPlaybooks(playbookList);
        pbResponseWrapper.row = setPlaybookRows(playbookList, pbResponseWrapper.header, displayDeleteLink);
        return pbResponseWrapper;
	}
	
	private List<CSM_Account_Plan_Playbook__c> getPlaybookList() {
		List<CSM_Account_Plan_Playbook__c> AccountPlanPlaybookList = new List<CSM_Account_Plan_Playbook__c>();
		AccountPlanPlaybookList = CSM_AccountPlanPlaybookDataAccess.getAccountPlanPlaybooksByPlanId(this.inputWrapper.params.accountPlanId);
		return AccountPlanPlaybookList;
	}
	
	private List<CSM_GridRowWrapper> setPlaybookRows(List<CSM_Account_Plan_Playbook__c> successPlanPlaybookList, 
													List<CSM_GridColumnWrapper> colList,
													Map<Id, Boolean> displayDeleteLink) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		Map<String,String> sppbToPlaybook = retrieveReEntrantPlaybooks(successPlanPlaybookList);
		Set<String> playbookIds = new Set<String>();
		
		if(sppbToPlaybook != null && !sppbToPlaybook.isEmpty()){
			playbookIds.addAll(sppbToPlaybook.values());		
		}

		for(CSM_Account_Plan_Playbook__c succPlanPlaybook : successPlanPlaybookList) {
			CSM_GridRowWrapper row = new CSM_GridRowWrapper();
			row.id = (String)succPlanPlaybook.get('CSM_Playbook__c');
			row.columns = new List<CSM_GridColumnWrapper>();
			row.actions = new List<CSM_GridActionWrapper>();
			row.sObj = succPlanPlaybook;
			row.isMC = CSM_Util.checkMCEnabled();
			row.namespace = CSM_Util.getNamespace();
            row.columns = new List<CSM_GridColumnWrapper>();
            if (colList!=null){
                row.columns = colList;
	            row.actionValue = '';
	            if(succPlanPlaybook.get('CSM_Account_Plan_Template__c')==null){
					CSM_GridActionWrapper actionWrap = new CSM_GridActionWrapper('Del');
					actionWrap.hrefAction = 'javascript:void(0);';
					actionWrap.titleAction = Label.REN_Delete;
					actionWrap.onclickAction = 'removePlaybookAssociation(\''+row.id+'\')';
					row.actions.add(actionWrap);
				}
	            if(playbookIds != null && !playbookIds.isEmpty()){
	            	if(playbookIds.contains((String)succPlanPlaybook.get('CSM_Playbook__c'))){ //sppbToPlaybook.get((String)succPlanPlaybook.get('Id')) != null
						CSM_GridActionWrapper actionWrap = new CSM_GridActionWrapper('Generate');
						actionWrap.hrefAction = 'javascript:void(0);';
						actionWrap.onclickAction = 'validateRefresh(\''+row.id+'\')';
						row.actions.add(actionWrap);
	            	}
				}
				
				row.hasGridImage = true;
				gridRowWrapper.add(row);
            }
		}
		
		return gridRowWrapper;
	}
	/*private void setCheckboxImageForBoolean(CSM_GridColumnWrapper col, Boolean boolVal){
		col.gridImage = new CSM_GridImageWrapper();
		col.gridImage.imgWidth = '21';
		col.gridImage.imgheight = '16';
		col.gridImage.imgClass = 'checkImg';
		if(boolVal){
			col.gridImage.imgSource = '/img/checkbox_checked.gif';
			col.gridImage.altImg = 'Checked';
			col.gridImage.imgTitle = 'Checked';
		}else{
			col.gridImage.imgSource = '/img/checkbox_unchecked.gif';
			col.gridImage.altImg = 'Not Checked';
			col.gridImage.imgTitle = 'Not Checked';
		}
	}*/
	private List<CSM_GridColumnWrapper> setOpportunityHeader() {
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

		//CAUTION: The order has te be maintained for the headers to be set and the response columns
		
		CSM_GridColumnWrapper playbookColumn = new CSM_GridColumnWrapper();
		
		//PlayBook Name
		playbookColumn = new CSM_GridColumnWrapper();
		playbookColumn.apiName = CSM_Constants.OBJ_PBP_PLAYBOOK;
		playbookColumn.label = Schema.SobjectType.CSM_Playbook__c.fields.CSM_Display_Name__c.label;
		playbookColumn.valueCol = CSM_Constants.PBJ_FLD_PLAYBOOK_REL_NAME;
		playbookColumn.isSortable = true;
		playbookColumn.lookUpIdCol = CSM_Constants.OBJ_APP_ID;
		playbookColumn.isLinkCol = true;
		gridClmWrapper.add(playbookColumn);
		
		//Status
		playbookColumn = new CSM_GridColumnWrapper();
		playbookColumn.apiName = CSM_Constants.OBJ_BR_STATUS;
		playbookColumn.label = CSM_Constants.OBJ_T_STATUS;
		playbookColumn.valueCol = CSM_Constants.OBJ_BR_STATUS;
		playbookColumn.isSortable = true;
		playbookColumn.isLinkCol = false;
		gridClmWrapper.add(playbookColumn);
		
		//Source
		playbookColumn = new CSM_GridColumnWrapper();
		playbookColumn.apiName = CSM_Constants.OBJ_FLD_SRC;
		playbookColumn.label = Schema.SobjectType.CSM_Account_Plan_Playbook__c.fields.CSM_Source__c.label;
		playbookColumn.valueCol = CSM_Constants.OBJ_FLD_SRC;
		playbookColumn.isSortable = true;
		playbookColumn.isLinkCol = false;
		gridClmWrapper.add(playbookColumn);
		
		//Short Description
		playbookColumn = new CSM_GridColumnWrapper();
		playbookColumn.apiName = CSM_Constants.OBJ_FLD_PLAYBOOK_REL_SHRTDESC;
		playbookColumn.label = Schema.SobjectType.CSM_Playbook__c.fields.CSM_Short_Description__c.label;
		playbookColumn.valueCol = CSM_Constants.OBJ_FLD_PLAYBOOK_REL_SHRTDESC;
		playbookColumn.isSortable = true;
		playbookColumn.isLinkCol = false;
		gridClmWrapper.add(playbookColumn);
		
		//Total No. of Plays
		playbookColumn = new CSM_GridColumnWrapper();
		playbookColumn.apiName = CSM_Constants.OBJ_FLD_TOTL_NO_PLAYS;
		playbookColumn.label = Schema.SobjectType.CSM_Account_Plan_Playbook__c.fields.CSM_Total_number_of_Plays__c.label;
		playbookColumn.valueCol = CSM_Constants.OBJ_FLD_TOTL_NO_PLAYS;
		playbookColumn.isSortable = true;
		playbookColumn.isLinkCol = false;
		gridClmWrapper.add(playbookColumn);
		
		//Number of Tasks
		playbookColumn = new CSM_GridColumnWrapper();
		playbookColumn.apiName = CSM_Constants.OBJ_PLAY_TOTAL_CLOSED;
		playbookColumn.label = Schema.SobjectType.CSM_Account_Plan_Playbook__c.fields.CSM_Number_of_Closed_Plays__c.label;
		playbookColumn.valueCol = CSM_Constants.OBJ_PLAY_TOTAL_CLOSED;
		playbookColumn.isSortable = true;
		playbookColumn.isLinkCol = false;
		gridClmWrapper.add(playbookColumn);
		
		//Automated
		playbookColumn = new CSM_GridColumnWrapper();
		playbookColumn.apiName = CSM_Constants.OBJ_FLD_PLAYBOOK_REL_AUTO;
		playbookColumn.label = Schema.SobjectType.CSM_Playbook__c.fields.CSM_Automated__c.label;
		playbookColumn.valueCol = CSM_Constants.OBJ_FLD_PLAYBOOK_REL_AUTO;
		playbookColumn.isSortable = true;
		playbookColumn.isLinkCol = false;
		gridClmWrapper.add(playbookColumn);
		
		//Active
		playbookColumn = new CSM_GridColumnWrapper();
		playbookColumn.apiName = CSM_Constants.OBJ_PLAYBOOK_ISACTIVE;
		playbookColumn.label = Schema.SobjectType.CSM_Account_Plan_Playbook__c.fields.CSM_IsActive__c.label;
		playbookColumn.valueCol = CSM_Constants.OBJ_PLAYBOOK_ISACTIVE;
		playbookColumn.isSortable = true;
		playbookColumn.isLinkCol = false;
		gridClmWrapper.add(playbookColumn);
		
		return gridClmWrapper;
	}
	
	public Map<String,String> retrieveReEntrantPlaybooks(List<CSM_Account_Plan_Playbook__c> spPlaybookList) {
		List<String> spplIds = new List<String>(); 
		List<csm_successplan_play__c> spplList;
		List<csm_successplan_play__c> openSpplList;	
				
		Map<String,String> sppbToPlaybook = new Map<String,String>();
					
		if(spPlaybookList != null && !spPlaybookList.isEmpty()){
			spplList = CSM_SuccessPlanPlayDataAccess.getSuccessPlanPlayForRefresh(spPlaybookList);//[select Id, CSM_SuccessPlan_Playbook__c, CSM_Playbook_Play__r.csm_playbook__c from csm_successplan_play__c where CSM_Playbook_Play__r.csm_playbook__r.csm_automated__c = false 
														//and CSM_SuccessPlan_Playbook__c in : spPlaybookList and CSM_Status__c = 'Completed' and CSM_Playbook_Play__r.csm_play__r.CSM_Play_ReEntry__c = true
															//and CSM_SuccessPlan_Playbook__r.CSM_Account_Plan_Template__c = null];
		}
		
		if(spplList != null && !spplList.isEmpty()){
			for(csm_successplan_play__c sppl: spplList){
				sppbToPlaybook.put(sppl.Id + ':' + sppl.CSM_SuccessPlan_Playbook__c, sppl.CSM_Playbook_Play__r.csm_playbook__c);
				spplIds.add(sppl.Id);
			}
		}

		/*if(spplIds != null && !spplIds.isEmpty()){
			openSpplList = CSM_SuccessPlanPlayDataAccess.getOpenSuccessPlanPlayForRefresh(spplIds);//[select Id, CSM_SuccessPlan_Playbook__c from csm_successplan_play__c where CSM_Previous_SPPL__c in : spplIds and CSM_Status__c != 'Completed'];
		}

		if(openSpplList != null && !openSpplList.isEmpty()){
			for(csm_successplan_play__c openSppl: openSpplList){
				sppbToPlaybook.remove(openSppl.CSM_Previous_SPPL__c + ':' + openSppl.CSM_SuccessPlan_Playbook__c);
			}
		}*/
		return sppbToPlaybook;
	}
}