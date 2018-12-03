public with sharing class REN_BatchOppGenerationController extends REN_BaseMainController {
	public String helpParam {get;set;}
	public Id deletableRecordId{get;set;}
	public String selectedRowId {get; set;}
	public String selectedGroupRowId {get; set;}
	//public String selPriceBook{get; set;}
	public REN_Batch_Activity__c batchActivity {get; set;}
	public List<SelectOption> options {get; set;}
	public String selectedValue{get;set;}
	public List<SelectOption> priceBookList{get;set;}
	public List<REN_Email_Recipient__c> emailRecipient {get; private set;}
	public Id userId = UserInfo.getUserId();
	public List<User> addRecipient{get; set;}
	public List<String> emailRep {get; set;}
	public List<SObject> selectedRecipients{get;set;}
	public List<User> populateEmailRecip{get; set;}
	public Boolean recordDeleted = false;
	public String editSourceRecordId{get;set;}
	public String editGroupRecordId{get;set;}
	public String cloneSourceRecordId{get;set;}
	public String cloneGroupRecordId{get;set;}
	public List<SelectOption> dateFieldSelectOption{get;set;}
	public CSM_DataGridAttribute filterGridAttribute{get;set;}
	public CSM_DataGridAttribute groupGridAttribute{get;set;}
	
	public REN_BaseMainController thisController{
		get{
			return this;
		}
			set;}
	//public Date onDate { get; set; }
	//public Time onTime { get; set; }
	//public Boolean runButton{get;set;}
	//public Boolean scheduleButton{get;set;}
	//public DateTime genNow;
	private String batchId;
	//public Boolean flag = true;
	
	public REN_BatchOppGenerationController() 
	{        
        helpParam = Label.REN_LBL_SERVICE_CONTRACTS;
        batchActivity = new REN_Batch_Activity__c();
        emailRecipient = new List<REN_Email_Recipient__c>();
        batchActivity.REN_Last_Modified_By__c = userId;
        batchActivity.REN_Last_Modified_On__c = DateTime.now();
        batchActivity.REN_Email_Notification__c = true;
        batchId = ApexPages.currentPage().getParameters().get('id');
        selectedRowId = ApexPages.currentPage().getParameters().get('sid');
        selectedGroupRowId = ApexPages.currentPage().getParameters().get('gid');
        //addRecipient = new List<User>();
        addRecipient = REN_EmailRecipientDataAccess.getAllUsersForSelection();
        emailRep = new List<String>();
        emailRep.add('Id');
        emailRep.add('Name');
        emailRep.add('Email');
        selectedRecipients = new List<SObject>();
        if(batchId != null)
        {
        	populateInfo();
        }
        else
        {
        	batchActivity.REN_Created_By__c = userId;
        	batchActivity.REN_Created_On__c = DateTime.now();
        	populateEmailRecip = REN_EmailRecipientDataAccess.getUser(userId);
        	batchActivity.REN_Object__c = REN_Constants.TRACK_USING_ASSET;
        	selectedValue = 'Generate now';
        }
        options = new List<SelectOption>();
        options.add(new SelectOption('Generate now','Generate now'));
        options.add(new SelectOption('Generate on','Generate on')); 
        priceBookList = REN_Util.pricebookPicklist();
        
        
        List<Schema.SObjectField> sObjectFieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(REN_Constants.OBJ_ASSET);
        //dateFieldSelectOption = CSM_AccessController.getInstance().getFieldsByType(sObjectFieldList, CSM_Constants.TYPE_DATE);
        dateFieldSelectOption = CSM_AccessController.getInstance().getFieldsByType(sObjectFieldList, CSM_Constants.TYPE_DATE);
        //SS_SelectOptionSorter.doSort(dateFieldSelectOption, SS_SelectOptionSorter.FieldToSort.Label);
        CSM_Util.sortSelectOptionByLabel(dateFieldSelectOption);
        setGridAttributes();
    }
    
    private void setGridAttributes()
    {
        filterGridAttribute = new CSM_DataGridAttribute();
        filterGridAttribute.tableName = CSM_Constants.GRID_ATTR_FILTER_WIDGET;
    	filterGridAttribute.objectType =CSM_Constants.GRID_ATTR_BATCH_OPP_GEN_OBJ_TYPE;
    	filterGridAttribute.viewName =CSM_Constants.GRID_ATTR_FILTER;
    	filterGridAttribute.gridSize=5;
    	filterGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_FILTER_TOOLBAR;
    	filterGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
    	filterGridAttribute.stateSave=CSM_Constants.GRID_ATTR_TRUE;
    	filterGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_FALSE;
    	filterGridAttribute.showExport=CSM_Constants.GRID_ATTR_FALSE;
    	filterGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_FALSE;
    	
    	CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
     	gridInputParams.taskOrViewId = '';
     	gridInputParams.selectedTaskFilter = selectedRowId;
     	filterGridAttribute.params = JSON.serialize(gridInputParams);
    	
	    groupGridAttribute = new CSM_DataGridAttribute();
	    groupGridAttribute.tableName = CSM_Constants.GRID_ATTR_GROUP_WIDGET;
	    groupGridAttribute.objectType = CSM_Constants.GRID_ATTR_BATCH_OPP_GEN_OBJ_TYPE;
        groupGridAttribute.viewName=CSM_Constants.GRID_ATTR_GROUPING;
        groupGridAttribute.gridSize=5;
        groupGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_GROUP_TOOLBAR;
        groupGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
        groupGridAttribute.stateSave=CSM_Constants.GRID_ATTR_TRUE;
        groupGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_FALSE;
        groupGridAttribute.showExport=CSM_Constants.GRID_ATTR_FALSE;
        groupGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_FALSE;
        
        gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
     	gridInputParams.taskOrViewId = '';
     	gridInputParams.selectedTaskFilter = selectedGroupRowId;
     	groupGridAttribute.params = JSON.serialize(gridInputParams);
        
    }
    
    public PageReference createFilterRecord()
    {
    	PageReference pageRef = Page.REN_SourceRecordFilter;
    	pageRef.getParameters().put('sid',selectedRowId);
    	pageRef.getParameters().put('gid',selectedGroupRowId);
		pageRef.setRedirect(true);
		return pageRef;
    }
    public PageReference createGroupRecord()
    {
    	PageReference pageRef = Page.REN_GroupingLogic;
    	pageRef.getParameters().put('sid',selectedRowId);
    	pageRef.getParameters().put('gid',selectedGroupRowId);
		pageRef.setRedirect(true);
		return pageRef;
    }  
    
    public PageReference editSourceRecord()
    {
    	PageReference pageRef = Page.REN_SourceRecordFilter;
    	pageRef.getParameters().put('id',editSourceRecordId);
    	pageRef.getParameters().put('sid',selectedRowId);
    	pageRef.getParameters().put('gid',selectedGroupRowId);
		pageRef.setRedirect(true);
		return pageRef;
    }  
    
    public PageReference editGroupRecord()
    {
    	PageReference pageRef = Page.REN_GroupingLogic;
    	pageRef.getParameters().put('id',editGroupRecordId);
    	pageRef.getParameters().put('sid',selectedRowId);
    	pageRef.getParameters().put('gid',selectedGroupRowId);
		pageRef.setRedirect(true);
		return pageRef;
    }  
    
    public PageReference deleteSelectedRecord()
    {
    	try{
	    	if(deletableRecordId != null){
	    		REN_Renew_Configuration__c renConfigTypeObj = REN_RenewConfigurationDataAccess.getRenewConfigByIdy(deletableRecordId);
	    		REN_Renew_Configuration__c rrObj = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(renConfigTypeObj.REN_Record_Key__c+'_πRR');
	    		List<REN_Renew_Configuration__c> configList = new List<REN_Renew_Configuration__c>();
	    		configList.add(renConfigTypeObj);
	    		if(rrObj != null){
	    			configList.add(rrObj);
	    		}
	    		REN_RenewConfigurationDataAccess.deleteRenewConfig(configList);
	    		PageReference pageRef = Page.ren_batchoppgeneration;
	    		if(renConfigTypeObj.get(CSM_Util.getNamespace()+REN_Constants.OBJ_RC_CONFIGURATION_TYPE) == 'Grouping' && deletableRecordId == selectedGroupRowId){
			    	pageRef.getParameters().put('sid',selectedRowId);
	    		}else if(renConfigTypeObj.get(CSM_Util.getNamespace()+REN_Constants.OBJ_RC_CONFIGURATION_TYPE) == 'Grouping'){
	    			pageRef.getParameters().put('sid',selectedRowId);
	    			pageRef.getParameters().put('gid',selectedGroupRowId);
	    		}
	    		
	    		if(renConfigTypeObj.get(CSM_Util.getNamespace()+REN_Constants.OBJ_RC_CONFIGURATION_TYPE) == 'Filter' && deletableRecordId == selectedRowId){
			    	pageRef.getParameters().put('gid',selectedGroupRowId);
	    		}else if(renConfigTypeObj.get(CSM_Util.getNamespace()+REN_Constants.OBJ_RC_CONFIGURATION_TYPE) == 'Filter'){
	    			pageRef.getParameters().put('sid',selectedRowId);
	    			pageRef.getParameters().put('gid',selectedGroupRowId);
	    		}
	    		pageRef.getParameters().put('tabCategory', 'Renewal');
	    		pageRef.setRedirect(true);
				return pageRef;
	    		selectedRowId = '-';
	    		selectedGroupRowId='-';
	    	}
    	}catch(DMLException ex){
    		String msg = ex.getMessage();
    		if(msg != null && msg.contains('it is associated with')){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.ERR_MESG_BATCH_OPP_GEN));
    		}else{
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(ex, null)));
    		}
    	}catch(Exception ex){
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(ex, null)));
    	}
    	
    	return null;
    }
    
    private List<REN_Line_Criteria__c> cloneAndCreateCriteria(String origId, String clonedId, String objName)
    {
    	List<REN_Line_Criteria__c> criteriaList = REN_LineCriteriaDataAccess.getLineCriteriaListByConfig(origId,objName);
	    List<REN_Line_Criteria__c> clonedCriteriaList = new List<REN_Line_Criteria__c>();
	            
	    for (REN_Line_Criteria__c lineCriteria: criteriaList)
	    {
	        REN_Line_Criteria__c clonedLineCriteria = lineCriteria.clone(false, true, false, false);
	        clonedLineCriteria.REN_Renew_Configuration__c = clonedId;
	        clonedCriteriaList.add(clonedLineCriteria);	
	    }
	    
	    return clonedCriteriaList;
	}
    
    public PageReference cloneSourceRecord()
    {
    	REN_Renew_Configuration__c cloneSourceObj = null;
    	try
    	{
	    	//create and upsert the REN_Renew_Configuration__c object
	    	REN_Renew_Configuration__c origSourceObj = REN_RenewConfigurationDataAccess.getRenewConfigByIdy(cloneSourceRecordId);
	    	cloneSourceObj = origSourceObj.clone(false, true, false, false);
	    	cloneSourceObj.REN_Record_Key__c = System.label.CSM_ClONE_ACC_PLAN_TEMPLATE_PREFIX + ' ' + cloneSourceObj.REN_Record_Key__c;
	    	cloneSourceObj.REN_View_Name__c = System.label.CSM_ClONE_ACC_PLAN_TEMPLATE_PREFIX + ' ' + cloneSourceObj.REN_View_Name__c;
	    	
	    	List<REN_Renew_Configuration__c> renewConfigList = new List<REN_Renew_Configuration__c>();
	    	renewConfigList.add(cloneSourceObj);
	    	
	    	REN_Renew_Configuration__c origRenewObj = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(origSourceObj.REN_Record_Key__c+'_πRR');
	    	if(origRenewObj != null){
				cloneSourceObj = origRenewObj.clone(false, true, false, false);
	    		cloneSourceObj.REN_Record_Key__c = System.label.CSM_ClONE_ACC_PLAN_TEMPLATE_PREFIX + ' ' + cloneSourceObj.REN_Record_Key__c;
	    		cloneSourceObj.REN_View_Name__c = System.label.CSM_ClONE_ACC_PLAN_TEMPLATE_PREFIX + ' ' + cloneSourceObj.REN_View_Name__c;
	    		renewConfigList.add(cloneSourceObj);
	    	}
	    	List<REN_Renew_Configuration__c> savedList = REN_RenewConfigurationDataAccess.saveRenewConfiguration(renewConfigList);
	   		List<REN_Line_Criteria__c> clonedCritList = new List<REN_Line_Criteria__c>();
	   
	    	//create and upsert the REN_Line_Criteria__c objects
	    	if (!savedList.isEmpty())
	    	{	//Not using for loop to avoid dml in a loop	
	    		clonedCritList.addAll(cloneAndCreateCriteria(origSourceObj.id, savedList[0].Id,REN_Constants.OBJ_ASSET));
	    		if(savedList.size()>=2){
	    			clonedCritList.addAll(cloneAndCreateCriteria(origRenewObj.id, savedList[1].Id,REN_Constants.OBJ_REN_RENEWS_TO));
	    		}
	    		if (!clonedCritList.isEmpty()){
	    			REN_LineCriteriaDataAccess.upsertLineCriterias(clonedCritList);
	    		}
	    	    PageReference pageRef = Page.ren_batchoppgeneration;
				pageRef.getParameters().put('tabCategory', 'Renewal');
				pageRef.setRedirect(true);
				return pageRef;
	    	}
    	}
    	catch(Exception ex)
    	{
    		String errMsg = ex.getMessage();    	
    		if(errMsg != null &&  errMsg.contains('DUPLICATE_VALUE')){
    		    String message = String.format(System.Label.DUPLICATE_FILTER_NAME, new String[] {cloneSourceObj.REN_View_Name__c});
    		    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, message));
    		}
    		else
    		{
   			    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(ex, null)));
    		}
    	}
    	
    	return null;
    }  
    
    public PageReference cloneGroupRecord()
    {
    	REN_Renew_Configuration__c cloneSourceObj = null;
    	try
    	{
	    	//create and upsert the REN_Renew_Configuration__c object
	    	REN_Renew_Configuration__c origSourceObj = REN_RenewConfigurationDataAccess.getRenewConfigByIdy(cloneGroupRecordId);
	    	cloneSourceObj = origSourceObj.clone(false, true, false, false);
	    	
	    	cloneSourceObj.REN_Record_Key__c = System.label.CSM_ClONE_ACC_PLAN_TEMPLATE_PREFIX + ' ' + cloneSourceObj.REN_Record_Key__c;
	    	String viewName = System.label.CSM_ClONE_ACC_PLAN_TEMPLATE_PREFIX + ' ' + cloneSourceObj.REN_View_Name__c;
	    	if (viewName.length() > 70)
	    	{
	    		viewName = viewName.substring(0,69);
	    	}
	    	cloneSourceObj.REN_View_Name__c = viewName;
	    	
	    	List<REN_Renew_Configuration__c> renewConfigList = new List<REN_Renew_Configuration__c>();
	    	renewConfigList.add(cloneSourceObj);
	    	List<REN_Renew_Configuration__c> savedList = REN_RenewConfigurationDataAccess.saveRenewConfiguration(renewConfigList);
	   		List<REN_Line_Criteria__c> clonedCritList = new List<REN_Line_Criteria__c>();
	    	//create and upsert the REN_Line_Criteria__c objects
	    	if (!savedList.isEmpty())
	    	{		
	    		clonedCritList.addAll(cloneAndCreateCriteria(cloneGroupRecordId, savedList[0].Id,REN_Constants.OBJ_ASSET));
	    		if (!clonedCritList.isEmpty()){
	    	    	REN_LineCriteriaDataAccess.upsertLineCriterias(clonedCritList);
	    		}        
	    	    PageReference pageRef = Page.ren_batchoppgeneration;
				pageRef.getParameters().put('tabCategory', 'Renewal');
				pageRef.setRedirect(true);
				return pageRef;
	    	}
    	
    	}
    	catch(Exception ex)
    	{
    		String errMsg = ex.getMessage();    	
    		if(errMsg != null &&  errMsg.contains('DUPLICATE_VALUE')){
    		    String message = String.format(System.Label.DUPLICATE_FILTER_NAME, new String[] {cloneSourceObj.REN_View_Name__c});
    		    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, message));
    		}
    		else
    		{
   			    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(ex, null)));
    		}
    	}
    	
    	return null;
    }  
    
    
    private void populateInfo()
    {
    	try
    	{
	    	batchActivity = REN_BatchActivityDataAccess.getBatchAct(batchId);
	    	DateTime tempVar = batchActivity.REN_Job_Start_Date__c;
	    	selectedRowId = batchActivity.REN_Source_Record_Filter__c;
	    	selectedGroupRowId = batchActivity.REN_Grouping__c;
	    	system.debug('selectedRowId----'+selectedRowId);
	    	system.debug('selectedGroupRowId----'+selectedGroupRowId);
	    	String strBatchId = String.valueOf(batchActivity.id);
	    	populateEmailRecip = new List<User>();
	    	populateEmailRecip = REN_EmailRecipientDataAccess.getUsers(strBatchId);	   
	    	selectedValue = 'Generate on'; 	
    	}
    	catch(exception e)
    	{    		
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(e, e.getMessage())));
    	}
    }
    /*public PageReference runButtonDisable()
    {
    	scheduleButton = false;
    	runButton = true;
    	if(genNow != null)
    	{
    		genNow = null;
    	}
    	return null;
    }
    public PageReference scheduleButtonDisable()
    {
    	scheduleButton = true;
    	runButton = false;
    	genNow = DateTime.now();
    	return null;
    }*/
    public PageReference saveBatchOpp(){
    	
    	REN_Batch_Activity__c saveRec = new REN_Batch_Activity__c();
    	Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
    	//string noofRecords = REN_BatchOppGenDetailsCompCntrl.getRecordsReturned();
    	string criteria;
    	try
    	{
	    	saveRec.REN_Grouping__c = ApexPages.currentPage().getParameters().get('uniqueCBoxGrouping');
	    	saveRec.REN_Source_Record_Filter__c = ApexPages.currentPage().getParameters().get('uniqueCBoxFilter');
	    	if(String.isNotBlank(selectedRowId) && selectedRowId != '-'){
	    		saveRec.REN_Source_Record_Filter__c = selectedRowId;
	    	}
	    	if(String.isNotBlank(selectedGroupRowId) && selectedGroupRowId != '-'){
	    		saveRec.REN_Grouping__c = selectedGroupRowId;
	    	}
	    	
	    	saveRec.REN_Email_Notification__c = batchActivity.REN_Email_Notification__c;
	    	saveRec.REN_Pricebook__c = batchActivity.REN_Pricebook__c;
	    	saveRec.REN_Last_Modified_By__c = userId;
	    	saveRec.REN_Last_Modified_On__c = DateTime.now();
	    	saveRec.REN_Created_By__c =  batchActivity.REN_Created_By__c;
	    	saveRec.REN_Created_On__c =  batchActivity.REN_Created_On__c;
	    	saveRec.REN_Closed_Date_Depends_On__c =  batchActivity.REN_Closed_Date_Depends_On__c;
	    	saveRec.REN_Closed_Date_Options__c =  batchActivity.REN_Closed_Date_Options__c;
	    	if(UserInfo.isMultiCurrencyOrganization()){
	    		REN_Renew_Configuration__c renConfig = REN_RenewConfigurationDataAccess.getRenewConfigByIdy(saveRec.REN_Source_Record_Filter__c);
	    		if(renConfig != null){
	    			saveRec.put('CurrencyIsoCode', renConfig.RLM_Currency_Code__c);
	    		} 
	    	}

	    	REN_Renew_Configuration__c renConfigObj;
	    	if(saveRec.REN_Source_Record_Filter__c != null) {
	    		renConfigObj = REN_RenewConfigurationDataAccess.getRenewConfigByIdy(saveRec.REN_Source_Record_Filter__c);
	    	}
	    	if(renConfigObj != null && renConfigObj.REN_Filter_Criteria__c == null){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_NO_CRITERIA_ERR_MSG_FC));
			}
	    	if(renConfigObj != null && renConfigObj.REN_Filter_Criteria__c != null){
				//criteria = ' where ' + renConfigObj.REN_Filter_Criteria__c;
				String renewalCrit ='';
				String renewRecKey = renConfigObj.REN_Record_Key__c+'_πRR';
				REN_Renew_Configuration__c renewalRenewObj = REN_RenewConfigurationDataAccess.getRenewConfigByRecordKey(renewRecKey);
				if(renewalRenewObj != null){
					renewalCrit = renewalRenewObj.REN_Filter_Criteria__c;
				}
				criteria = ' where '+REN_Util.constructWhereClause(renConfigObj.REN_Filter_Criteria__c,renewalCrit,'REN_Asset__c'); 
				if(REN_AssetDataAccess.getAssetsCounts(criteria, 1) < 1){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_MSG_ALRT_ASSET_COUNT_VARY));
				}
			}
	    	if(batchActivity.id != null)
	    	{
	    		saveRec.id = batchActivity.id;
	    	}
	    	if(selectedValue.contains('now')){
    			saveRec.REN_Job_Start_Date__c = DateTime.now();
    		}else{
    			saveRec.REN_Job_Start_Date__c = batchActivity.REN_Job_Start_Date__c;
    		}
	    	
	    	List<REN_Email_Recipient__c> saveEmailRecipRec = new List<REN_Email_Recipient__c>();
				for(REN_BaseChildController baseChildController : baseChildControllerMap.values())
				{
					if(baseChildController instanceof REN_MultiSelectPickListCompCtrl)
					{
						((REN_MultiSelectPickListCompCtrl)baseChildController).retrieveSelectedRecipients();
						selectedRecipients = ((REN_MultiSelectPickListCompCtrl)baseChildController).finalRecipients;
								
					}
				}
				
	    	if(String.isBlank(saveRec.REN_Source_Record_Filter__c)){
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_MSG_ERR_SRCREC_FLTR));
	    	}
	    	if(String.isBlank(saveRec.REN_Grouping__c)){
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_MSG_ERR_GRP_LOGIC));
	    	}
	    	if(String.isBlank(saveRec.REN_Pricebook__c)){
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_MSG_ERR_PRICEBOOK));
	    	}
	    	if(String.isBlank(saveRec.REN_Closed_Date_Depends_On__c) || String.isBlank(saveRec.REN_Closed_Date_Options__c)){
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, String.format(System.Label.REN_LBL_FIELD_IS_REQUIRED, new String[] {System.Label.REN_CLOSE_DATE_DEFINITION})));
	    	}
	    	if(saveRec.REN_Job_Start_Date__c == null){
		    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_MSG_ERR_DATE_TIME));
	    	}
	    	if(saveRec.REN_Job_Start_Date__c != null && saveRec.REN_Job_Start_Date__c < DateTime.now() && !selectedValue.contains('now')){
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.REN_MSG_ERR_DATE));
	    	}
	    	if(selectedRecipients == null || selectedRecipients.isEmpty() && batchActivity.REN_Email_Notification__c == true)
	    	{
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.REN_LBL_EMAIL_SEL_VAL));
	    	}
	    	if(!ApexPages.hasMessages()){
	    		REN_Batch_Activity__c batchActivity = null;
	    		
	    		if(saveRec.id != null){
	    			batchActivity = REN_BatchActivityDataAccess.getBatchAct(saveRec.id);
	    			if(batchActivity.REN_Status__c != 'Scheduled'){
	    				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.REN_LBL_BATCH_STARTED));
	    				return null;
	    			}
	    		}
				saveRec = REN_BatchActivityDataAccess.saveBatchAct(saveRec);
				
				
				if(batchId != null)
				{
					recordDeleted = REN_EmailRecipientDataAccess.deleteEmailRecip(populateEmailRecip, batchId);
				}
				for(SObject emailRepRec : selectedRecipients)
				{
						REN_Email_Recipient__c tempVar = new REN_Email_Recipient__c();
						tempVar.put('REN_User__c', emailRepRec.id);
						tempVar.put('REN_Recipient__c', tempVar.REN_User__c);
						tempVar.put('REN_Batch__c', saveRec.id);
						saveEmailRecipRec.add(tempVar);
				}
				emailRecipient = REN_EmailRecipientDataAccess.saveEmailRecip(saveEmailRecipRec);
				//Scheduled Batch here
				if(batchActivity != null && batchActivity.REN_Job_Start_Date__c != saveRec.REN_Job_Start_Date__c && String.isNotBlank(batchActivity.REN_Scheduler_ID__c)){
					//Remove scheduler
					try{
						System.abortJob(batchActivity.REN_Scheduler_ID__c); //abort the job
					}catch(Exception e){
						system.debug('## \n\n~~~~ ERROR: '+ e.getMessage());
					}
				}
				if(batchActivity == null || batchActivity.REN_Job_Start_Date__c != saveRec.REN_Job_Start_Date__c){
					batchActivity = REN_BatchActivityDataAccess.getBatchAct(saveRec.id);
					List<REN_Batch_Activity__c> batchActivityList = new List<REN_Batch_Activity__c>();
					batchActivityList.add(batchActivity);
					scheduledBatchJob(batchActivityList);
				}
	    	}
	    	
    	}
    	catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(e, e.getMessage())));
	   	}
	    if(ApexPages.hasMessages()){
	   		return null;
	   	}else{
		   	return cancel();
	   	}   	

    }  
    public void scheduledBatchJob(List<REN_Batch_Activity__c> saveRecList){
    	List<REN_Batch_Activity__c> batchList = new List<REN_Batch_Activity__c>();
    	for (REN_Batch_Activity__c saveRec : saveRecList) {
	    	String strDateTime = (saveRec.REN_Job_Start_Date__c.addMinutes(1)).format(REN_Constants.DB_DATETIME_FORMAT_BATCH);
			String jobID = system.schedule(String.format(Label.REN_BATCH_OPP_SCHEDULAR_NAME, new String[]{saveRec.REN_Batch_Number__c, saveRec.name}), strDateTime, new REN_BatchOppGenScheduledDispatcher());	
			saveRec.REN_Scheduler_ID__c = jobID;
			if(saveRec.REN_Job_Start_Date__c <= System.now().addMinutes(1)){
				saveRec.REN_Status__c = 'Processing';
			}
			batchList.add(saveRec);
			System.debug(strDateTime + '\n~~~~ScheduledId: ' + jobID);
    	}
		REN_BatchActivityDataAccess.saveBatchAct(batchList);
		
    }
    
    public PageReference cancel()
    {
    	PageReference pageRef = Page.REN_BatchOppGenActivity;
		pageRef.getParameters().put('tabCategory', 'Renewal');
		pageRef.setRedirect(true);
    	return pageRef;
    }
    
    
    public List<SelectOption> getDateFormulaOptions(){
    	List<selectOption> options = new List<selectOption>();
        Map<String, SobjectField> fieldMap = REN_Batch_Activity__c.getSObjectType().getDescribe().fields.getMap();
        //US2419 - Added namespace 
		List<Schema.PicklistEntry> pick_list_values = fieldMap.get(CSM_Util.getNamespace()+'REN_Closed_Date_Options__c').getDescribe().getPickListValues();
 		for (Schema.PicklistEntry a : pick_list_values) {
			options.add(new selectOption(a.getLabel(), a.getValue()));
      	}
      	return options;
    }
}