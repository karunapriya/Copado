public with sharing class CSM_PlaybookPlaysListCompCtrl {
	
	private List<CSM_PlaybookPlay__c> playbookPlayList;
	public Boolean performAddVal {get; set;}
	public String playId {get; set;}
	//public String playbookPlayId {get; set;}
	
	public CSM_PlaybookPlaysListCompCtrl()
	{
		
	}
	
	public String playbookId
	{
		get; 
		set {
			if(value != null)
			{
				playbookId = value;
				system.debug('PLAYBOOK ID:::' + playbookId);
			}
		}
	}
	
	public Boolean automatedPlaybook
	{
		get; 
		set {
			if(value != null)
			{
				automatedPlaybook = value;
			}
		}
	}
	
	public List<CSM_PlaybookPlay__c> getPlaybookPlayList() {
		this.populatePlays();
		return playbookPlayList;
	}
	
	private void populatePlays() {
		playbookPlayList = new List<CSM_PlaybookPlay__c>();
		try
		{
			playbookPlayList = CSM_PlaybookPlayDataAccess.populatePlaybookPlayInformation(playbookId);
			
			for (CSM_PlaybookPlay__c pr : playbookPlayList) {
				system.debug('playbookPlayList@@@'+ pr);
			}

		}
		catch (Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	}

    public PageReference removePlayFromPlaybook() {
    	Boolean removePlay = CSM_PlaybookPlayDataAccess.removePlayFromPlaybook(playbookId, playId);
    	if (removePlay){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_PLAY_REMOVED_FROM_PLAYBOOK));
    	} else {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_CANNOT_REMOVE_PLAY_FROM_PLAYBOOK));
    	}
    	return null;
    	
    }
    
    public PageReference createPlay() {
    	PageReference returnUrl = Page.CSM_PlaybookManagement;
    	returnUrl.getParameters().put(CSM_Constants.ID_PARAM, playbookId);
    	//String rUrl = '/apex/CSM_PlaybookManagement?id=' + playbookId;
    	String rUrl = EncodingUtil.urlEncode(returnUrl.getUrl(), CSM_Constants.UTF_8);
    	PageReference pageRef = Page.CSM_PlayManagement;
    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM, playbookId);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
    	pageRef.setRedirect(true);
    	return PageRef;
    	
    }
    
    public PageReference addPlay() {
    	PageReference returnUrl = Page.CSM_PlaybookManagement;
    	returnUrl.getParameters().put(CSM_Constants.ID_PARAM, playbookId);
    	//String rUrl = '/apex/CSM_PlaybookManagement?id=' + playbookId;
    	String rUrl = EncodingUtil.urlEncode(returnUrl.getUrl(), CSM_Constants.UTF_8);

    	//String rUrl = '/apex/CSM_PlaybookManagement?id=' + playbookId;
    	//rUrl = EncodingUtil.urlEncode(rUrl, CSM_Constants.UTF_8);
    	PageReference pageRef = Page.CSM_AddPlay;
    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM, playbookId);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
    	pageRef.setRedirect(true);
    	return PageRef;
    	
    }
    
    public PageReference editPlay() {
    	PageReference returnUrl = Page.CSM_PlaybookManagement;
    	returnUrl.getParameters().put(CSM_Constants.ID_PARAM, playbookId);
    	//String rUrl = '/apex/CSM_PlaybookManagement?id=' + playbookId;
    	String rUrl = EncodingUtil.urlEncode(returnUrl.getUrl(), CSM_Constants.UTF_8);
    	
    	//String rUrl = '/apex/CSM_PlaybookManagement?id=' + playbookId;
    	//rUrl = EncodingUtil.urlEncode(rUrl, CSM_Constants.UTF_8);
    	PageReference pageRef = Page.CSM_PlayManagement;
    	pageRef.getParameters().put(CSM_Constants.ID_PARAM,playid);
    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM, playbookId);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
    	pageRef.setRedirect(true);
    	return PageRef;
    }
    /*
	public PageReference activatePlaybookPlay() {
    	try {
	    	if(!String.isEmpty(playbookPlayId))
	    	{
	    		boolean isSuccessful = CSM_PlaybookPlayDataAccess.activateDeactivatePlays(new List<String>{playbookPlayId}, true);
	    		playbookPlayId = '';	
	    	}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
    	return null;
    	
    }
    
    public PageReference deactivatePlaybookPlay() {
    	try {
	    	if(!String.isEmpty(playbookPlayId))
	    	{
	    		boolean isSuccessful = CSM_PlaybookPlayDataAccess.activateDeactivatePlays(new List<String>{playbookPlayId}, false);
	    		playbookPlayId = '';	
	    	}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
    	return null;
    }
    */
}