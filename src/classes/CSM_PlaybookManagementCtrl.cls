public with sharing class CSM_PlaybookManagementCtrl {
	
	public boolean hasCSMAccess {get; private set;}
	public boolean hasRenewAccess {get; private set;}
	public String helpParam {get; set;}
	public String sectionHeader {get; set;}
	public boolean isEdit {get; set;}
	public String playbookEditId {get; set;}
	public String returnURL {get; private set;}
	private String playbookId;
	public String tabCategory {get; set;} 
	
	public CSM_Playbook__c playbook {get; set;}
	public CSM_PlaybookManagementCtrl() 
	{
		isEdit = false;
		helpParam = CSM_Constants.HELP_CREATE_EDIT_PLAYBOOKS_PLAYS;
		playbookId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
		//if (playbookId!=null){
			// Get current page url through page reference 
		//	PageReference pageRefTemp = Page.CSM_PlaybookManagement;
	
			// Set up  current page reference with parameters
		//	returnURL = pageRefTemp.getURL() + CSM_Constants.ID_VAL + playbookId;
		//}else{
			String retURL = ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL);
			if (retURL != null){
				returnURL = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL),CSM_Constants.UTF_8);
			}
		//}
		// Check CSM Access
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		populatePlaybook();
	}
	
	private void populatePlaybook() {
		playbook = new CSM_Playbook__c();
		try
		{
			if(!String.isEmpty(playbookId))
			{
				playbook = CSM_PlaybooksDataAccess.populatePlaybooksInformation(playbookId);
				if(playbook != null)
				{
					sectionHeader =  Label.CSM_LBL_PLAYBOOK_EDIT;
					isEdit = true;
				}
				else
				{
					sectionHeader = Label.CSM_LBL_PLAYBOOK_CREATE;
				}
			}
			else
			{
				sectionHeader = Label.CSM_LBL_PLAYBOOK_CREATE;
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			
		}
		
	}
	
	
	public PageReference playbookCreate() {
		try {
			List<CSM_Playbook__c> saveList = CSM_PlaybooksDataAccess.savePlaybook(new List<CSM_Playbook__c>{playbook});
			if(!SaveList.isEmpty())
			{
				playbook = saveList[0];
				PageReference pageRef = Page.CSM_PlaybookManagement;
				pageRef.getParameters().put(CSM_Constants.ID_PARAM,playbook.id);
				pageRef.setRedirect(true);
				return pageRef;	
			}
			
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			
		}
		return null;
	}
	
	public PageReference playbookSave() {
		try {
			List<CSM_Playbook__c> saveList = CSM_PlaybooksDataAccess.savePlaybook(new List<CSM_Playbook__c>{playbook});
			{
				playbook = saveList[0];
			}
			//Save phase changes 
			if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
			{
				
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_PLAYBOOK_SAVE));
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
			playbookSave();
			if(!ApexPages.HasMessages(APexPages.SEVERITY.ERROR))
			{
				PageReference pageRef = Page.CSM_PlaybookManagement;
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
	
	public PageReference playbookCancel() {
		try { 
			PageReference pageRef = Page.CSM_PlaybooksList;
			pageRef.getParameters().put('tabCategory','SuccessPlan');
			
			if(returnURL != null)
			{
				pageRef = new PageReference(returnURL);
			}
			//system.debug('returnurl - ' + returnURL);
			//PageREference pageRef = Page.csm_playbookslist;//new PageReference(returnURL);
			pageRef.setRedirect(true);
			return pageRef;
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getmessage()));
			return null;
		}
	}
	
	public CSM_PlaybookManagementCtrl getThis(){
		return this;
	}
	
	
		

}