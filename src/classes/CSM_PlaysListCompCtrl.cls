public with sharing class CSM_PlaysListCompCtrl {
	
	private List<CSM_Play__c> playList;
	public String playId {get; set;}
	public Integer PlayBookCount {get; set;}
	public String PlayBookDisplayName {get; set;}
	public String removePlayId {get; set;}
	public Boolean playAdded {get; set;}	
	
	public String retURL {get; 
		set{
			if(value != null)
			{
				retURL = EncodingUtil.urlDecode(value,CSM_Constants.UTF_8);
			}
		}
	}
	
	public Boolean performAddVal {get; set;}
	
	public CSM_PlaysListCompCtrl()
	{
		playAdded = false;
	}
	
	public String playbookId
	{
		get; 
		set {
			if(value != null)
			{
				playbookId = value;
			}
		}
	}
	
	public List<CSM_Play__c> getPlayList() {
		this.populatePlays();
		return playList;
	}
	
	private void populatePlays() {
		playList = new List<CSM_Play__c>();
		try
		{
			playList = CSM_PlaysDataAccess.populatePlayList();
		}
		catch (Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	}
	
	public PageReference activatePlay() {
    	try {
	    	if(!String.isEmpty(playId))
	    	{
	    		boolean isSuccessful = CSM_PlaysDataAccess.activatePlays(new List<String>{playId});
	    		playId = '';	
	    	}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
    	return null;
    	
    }
    public PageReference deactivatePlay() {
    	try {
	    	if(!String.isEmpty(playId))
	    	{
	    		boolean isSuccessful = CSM_PlaysDataAccess.deactivatePlays(new List<String>{playId});
	    		playId = '';	
	    	}
    	}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
    	return null;
    }
    
    public PageReference createPlay() {
    	PageReference pageRef = Page.CSM_PlayManagement;
    	if(String.isNotBlank(retURL) && retURL.indexOf('CSM_PlaybookManagement') != -1){
    		retURL = retURL.indexOf('CSM_PlaybookManagement') != -1?retURL:retURL + '?id=' + playbookId;
	    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM, playbookId);
    	}
    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM, playbookId);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL, retURL);
    	pageRef.setRedirect(true);
    	return PageRef;
    	
    }
    
    public PageReference addPlay() {
    	if (playBookId!=null && playId!=null){
    		playAdded = CSM_PlaybookPlayDataAccess.addPlayToPlaybook(playbookId, playId);
			if(playAdded)
			{
    			return cancelPlay();
			}
    	} else {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_MSG_PLAY_ALREADY_ADDED_TO_PLAYBOOK));
    	}
    	return null;
    }
    
    public PageReference editPlay() {
    	PageReference pageRef = Page.CSM_PlayManagement;
    	if(String.isNotBlank(retURL) && retURL.indexOf('CSM_PlaybookManagement') != -1){
    		retURL = retURL.indexOf('CSM_PlaybookManagement') != -1?retURL:retURL + '?id=' + playbookId;
	    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM, playbookId);
    	}
    	pageRef.getParameters().put(CSM_Constants.ID_PARAM,playid);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL, retURL);
    	pageRef.setRedirect(true);
    	return PageRef;
    }
    
    public PageReference cancelPlay() {
    	PageReference pageRef; 
		if(!String.isEmpty(retUrl))
		{
			PageRef = new PageReference(retUrl);
		}
		else
		{
			pageRef = Page.CSM_PlaybooksList;
			
		}
		pageRef.setRedirect(true);
		return pageRef;
    }
    /*
    @Description - Get Playbooks associated to Play which is selected for Delete.It is created as part of US317.
    */
    public PageReference getPlayBooksCountForPlay()	{
    	List<CSM_PlaybookPlay__c> PlaybookList = new List<CSM_PlaybookPlay__c>();
		PlayBookDisplayName = '';
		try
		{
			PlaybookList = CSM_PlaybookPlayDataAccess.getPlaybookPlaysforPlay(removePlayId);
			system.debug('@@@ PB LIst: '+PlaybookList);
			if(PlaybookList!=null && !PlaybookList.isEmpty())
			{
				PlayBookCount = PlaybookList.size();
				if(PlayBookCount <= 5)
				{
					List<String> pbNamesList = new List<String>();
					for(CSM_PlaybookPlay__c pb : PlaybookList){
						pbNamesList.add(pb.CSM_Playbook__r.CSM_Display_Name__c);
					}
					PlayBookDisplayName = JSON.serialize(pbNamesList);
				}
			}
			else
				PlayBookCount =  0;
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
    }
    /*
    @Description - Delete Play which is selected for Delete.It is created as part of US317.
    */
    public PageReference deletePlay() {
		boolean isPlayDelete;
		try
		{
			//Check Permission for Delete for PLAY object, if then delete.			
			isPlayDelete = CSM_PlaysDataAccess.deletePlay(removePlayId);
			
			if (isPlayDelete) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_MSG_PLAY_DELETE));
			}

		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
}