/**
* @author         Mike Faust (mike@comitydesigns.com)
* @date           08.22.2014
* @description    CSM_PlayManagementCtrl controller class of CSM_PlayManagement Page
*/

public with sharing class CSM_PlayManagementCtrl extends REN_BaseMainController{
	
	public boolean hasCSMAccess {get; private set;}
	public boolean hasRenewAccess {get; private set;}
	public String helpParam {get; set;}
	public boolean isEdit {get; set;}
	public String sectionHeader {get; set;}
	public CSM_Play__c play {get; set;}
	public String playId {get; set;}
	public String playbookId {get; set;}
	public String retUrl {get; private set;}
	public String returnURL {get; private set;}
	public REN_LogicBuilderInputWrapper lbInputWrapper {get; set;}	
	public Boolean isValidCriteria {get; set;}	
	public String strCriteria {get; set;}
	private String nameSpacePrefixScout {get; set;}
	
	//private CSM_PlayCriteriaCompCtrl playCriteriaComponentController;
	private CSM_PlayTaskCompCtrl playTaskComponentController;
	public CSM_PlayManagementCtrl ctrl {get; private set;}	
		
	/**
	 * @description controller
	 */
	public CSM_PlayManagementCtrl() {
		ctrl = this;
		isEdit = false;
		helpParam = CSM_Constants.HELP_PLAYS;
		playId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
		playbookId = ApexPages.currentPage().getParameters().get(CSM_Constants.PLAYBOOK_ID_PARAM);
		if (playbookId!=null){
			// Get current page url through page reference 
			PageReference pageRefTemp = Page.CSM_PlaybookManagement;
	
			// Set up  current page reference with parameters
			returnURL = pageRefTemp.getURL() + CSM_Constants.ID_VAL + playbookId;
		}
		if(ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL) != null)
		{
			retUrl = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL),CSM_Constants.UTF_8);
		}
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		populatePlay();
	}


	/**
	 * @description builds the play object. If param is null, creates new, otherwise edit existing
	 */
	private void populatePlay() {
		play = new CSM_Play__c();
		String objName;
		try
		{
			if(!String.isEmpty(playId))
			{
				play = CSM_PlaysDataAccess.populatePlayInformation(playId);
				if(play != null)
				{
					sectionHeader =  Label.CSM_LBL_PLAY_EDIT;
					isEdit = true;
					if(play.CSM_Object_Name__c.ToLowerCase().contains(CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER.ToLowerCase())){
						nameSpacePrefixScout = play.CSM_Object_Name__c.length() != CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER.length()? play.CSM_Object_Name__c.substringBefore('__') + '__':'';
					}else{
						nameSpacePrefixScout = '';
					}
				
					lbInputWrapper = new REN_LogicBuilderInputWrapper(play,CSM_Constants.OBJ_PLAY_CRIT,play.CSM_Object_Name__c,'pl1',false,this,'', 'refreshLB1', 'onChangeDate1',true,'');					
				}
				else
				{
					sectionHeader = Label.CSM_LBL_PLAY_CREATE;
				}
			}
			else
			{
				play.CSM_IsActive__c = true;
				sectionHeader = Label.CSM_LBL_PLAY_CREATE;
			}
		}
		catch (Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		
	}
	
	/**
	 * @description gets the List of available objects for the criteria 
	 * @return List<SelectOpion>
	 */
	public List<SelectOption> getObjectList()
    {
        try
        {   
            List<SelectOption> objectList = new List<SelectOption>();           
            objectList.addAll(CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_PLAYS));
     
            return objectList;
        }
        catch (Exception ex)
        {            
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
             return null;
        }
    }
    
    /**
	 * @description Create new play method.
	 * @return PageReference
	 */
    public PageReference playCreate() {
		try {
			if (play.CSM_Object_Name__c == null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_LBL_OBJECT_TYPE_MISSING));
				return null;
			}
			List<CSM_Play__c> saveList = CSM_PlaysDataAccess.savePlays(new List<CSM_Play__c>{play});
			if(!SaveList.isEmpty())
			{
				if(!String.isEmpty(PlaybookId))
				{
					CSM_PlaybookPlayDataAccess.addPlayToPlaybook(playbookId, saveList[0].id);
					
				}
				if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
				{
					play = saveList[0];
					PageReference pageRef = Page.CSM_PlayManagement;
					pageRef.getParameters().put(CSM_Constants.RET_TO_URL, retURL);
					pageRef.getParameters().put(CSM_Constants.ID_PARAM,play.id);
					pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM, playbookId);
					pageRef.setRedirect(true);
					return pageRef;	
				}
			}
			
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			
		}
		return null;
	}
	
	/**
	 * @description saves the play, criteria and tasks
	 * @return PageReference
	 */
	public PageReference playSave() {
		try {
			//play.RLM_Currency_Code__c = playCriteriaComponentController.corpCurr;
			//saveClicked = true;	
		
			/*if(!saveList.isEmpty())
			{
				play = saveList[0];
			}
			if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_PLAY_SAVE));
			}*/
			//playCriteriaComponentController.saveCriteria();
			validateCriteriaQueryAndSave();
			if(isValidCriteria){
				List<CSM_Play__c> playList = updatePlaysWithCrtieria();
				CSM_PlaysDataAccess.savePlays(playList);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_PLAY_SAVE));							
				playTaskComponentController.saveTasks();
				PageReference pageRef; 
				if(!String.isEmpty(retUrl) && !retUrl.contains(CSM_Constants.CSM_PLAYLIST_PG))
				{
					PageRef = new PageReference(retUrl);
					pageRef.setRedirect(true);
				}
				return pageRef;
			}
		
		}
		catch (Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
	
	public PageReference saveAndNew()
	{
		try {
			validateCriteriaQueryAndSave();
			if(isValidCriteria){
				List<CSM_Play__c> playList = updatePlaysWithCrtieria();
				CSM_PlaysDataAccess.savePlays(playList);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_PLAY_SAVE));							
				playTaskComponentController.saveTasks();
			}
			//playSave();
			if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
			{
				PageReference pageRef = Page.CSM_PlayManagement;
				pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM,playbookId);
				pageRef.getParameters().put(CSM_Constants.RET_TO_URL, retURL);
				pageRef.setRedirect(true);
				return pageRef;
			}
		}
		catch (Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
	
	/**
	 * @description saves the play and redirects to create a new page
	 * @return PageReference
	
	/**
	 * @description Cancel play changes, return to previous url if provided, otherwise back to play list page
	 * @return PageReference
	 */
	public pageReference playCancel() {
		PageReference pageRef; 
		system.debug('retUrl $$$$$$$ '+retUrl);
		if(!String.isEmpty(retUrl))
		{
			PageRef = new PageReference(retUrl);
			pageRef.getParameters().put('tabCategory','SuccessPlan');
		}
		else
		{
			pageRef = Page.CSM_PlaybooksList;
			pageRef.getParameters().put('tabCategory','SuccessPlan');
			
		}
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	
	/** 
	 * @description set the value of the play Criteria component controller reference 
	 */
	/*public void setPlayCriteriaComponentController(CSM_PlayCriteriaCompCtrl appController)
	{
		playCriteriaComponentController = appController;
	}*/
	
	/** 
	 * @description return the reference of the current controller
	 * @return CSM_PlayManagementCtrl
	 */
	 /*public CSM_PlayManagementCtrl getThis()
	 {
    	return this;
     }*/
	/** 
	 * @description set the value of the play task component controller reference 
	 */
	public void setPlayTaskComponentController(CSM_PlayTaskCompCtrl apiController)
	{
		playTaskComponentController = apiController;
	}
	
	private void validateCriteriaQueryAndSave(){
		Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
		if (baseChildControllerMap.values() != null) {
			for(REN_BaseChildController baseChildController : baseChildControllerMap.values()){
				if(baseChildController instanceof REN_LogicBuilderCmpCtrl){
					((REN_LogicBuilderCmpCtrl)baseChildController).performSave();
					isValidCriteria = ((REN_LogicBuilderCmpCtrl)baseChildController).isValidCSMCriteria;
					strCriteria = ((REN_LogicBuilderCmpCtrl)baseChildController).strCriteria;				
				}
			}
		}
	}
	
	private List<CSM_Play__c> updatePlaysWithCrtieria()
	{
		//Go through map and build total string 
		CSM_Play__c playToUpdate = CSM_PlaysDataAccess.populatePlayInformation(playId);		
		List<CSM_Play__c> tmpPlayList = new List<CSM_Play__c>();
		String finalQueryString;
		string nameSpace = CSM_UTIL.getNamespace();
		if(playToUpdate.CSM_Object_Name__c == 'Account')
		{
		 finalQueryString = 'select id from ' + playToUpdate.CSM_Object_Name__c;
		}
		else if (playToUpdate.CSM_Object_Name__c == 'Opportunity')
		{
			finalQueryString = 'select id, accountId from ' + playToUpdate.CSM_Object_Name__c;
		} 
		else if (playToUpdate.CSM_Object_Name__c == 'CSM_Account_Plan__c')
		{
			finalQueryString = 'select id, CSM_AccountId__c from ' + playToUpdate.CSM_Object_Name__c;
		}
		else if (playToUpdate.CSM_Object_Name__c == 'Case')
		{
			finalQueryString = 'select id, AccountId from ' + playToUpdate.CSM_Object_Name__c;
		}
		else if (playToUpdate.CSM_Object_Name__c == 'CSM_Survey_Response__c')
		{
			finalQueryString = 'select id, ' + nameSpace +'CSM_Account__c from ' +  nameSpace +playToUpdate.CSM_Object_Name__c;
		}
		else if (playToUpdate.CSM_Object_Name__c.toUpperCase() == (nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER).toUpperCase())
		{
			finalQueryString = 'select id, ' + nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER_REF_ID + ' from ' + nameSpacePrefixScout + CSM_Constants.OBJ_SCOUT_SREV_CUSTOMER;
		}
		else 
		{
			String acctFieldName;
	        Map<String,DescribeFieldResult> fldMap = CSM_AccessController.getTypeFromFieldnameObjectname(playToUpdate.CSM_Object_Name__c.toUpperCase(), CSM_Constants.OBJ_TYPE_ACCOUNT, CSM_Constants.TYPE_REFERENCE);
			if (fldMap!=null && !fldMap.isEmpty()){
				for (String acctField : fldMap.keySet()){
					acctFieldName = acctField;
					break;
				}
			}
			if (acctFieldName!=null){
				finalQueryString = 'select id, ' + acctFieldName + ' from ' + playToUpdate.CSM_Object_Name__c;	
			} else {
				playToUpdate.CSM_Object_Name__c.addError('Object Name is not populated');
			}
			
		}
		
		
		if(!String.isEmpty(strCriteria) && strCriteria != null){
			playToUpdate.CSM_Query_Criteria__c = finalQueryString + ' where ' + '(' + strCriteria + ')';		
		}else{
			playToUpdate.CSM_Query_Criteria__c = '';		
		}
		
		
		tmpPlayList.add(playToUpdate);

		return tmpPlayList;
	}
	
	
}