/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		09.03.2014
 * @description	CSM_ContactWidgetCompCtrl class for CSM_ContactWidgetComp component
 */

public with sharing class CSM_ContactWidgetCompCtrl {

	
	public Integer csmRelatedSize {get; private set;}
	public String contactToUpdate {get; set;}
	public String whatIdVal {get; set;}
	public String whoIdVal {get; set;}
	private ApexPages.StandardSetController stdCon;
	private Integer PageSize; 
	//MF commented for viewState performance
	//private List<Contact> contactList = new List<Contact>();
	
	/**
	 * @description controller
	 */
	public CSM_ContactWidgetCompCtrl() {
		csmRelatedSize = 0;
		pageSize = 3;
	}
	
	/**
	 * @description accountId from page 
	 */
	public String accountId {
		get; 
		set {
			if(value != null)
			{
				accountId = value;
				populateContact();
				
			}			
		}
	}
	
	/**
	 * @description id of the task view to return to when going to email page 
	 */
	public String taskViewId {
		get; 
		set {
			if(value != null)
			{
				taskViewId = value;
				
			}
		}
	}
	
	/**
	 * @description id account of the account plan 
	 */
	public String successPlanId {
		get; 
		set {
			if(value != null)
			{
				successPlanId = value;
				
			}
		}
	}
	
	/**
	 * @description get the contact and assign them to the set controller 
	 */
	public void populateContact() {
		try {
			//MF Moved here for view state performance
			List<Contact> contactList = new List<Contact>();
			if(!String.isBlank(accountId))
			{
				contactList = CSM_ContactDataAccess.populateContactInformation(accountId);
				csmRelatedSize = 0;
				
				for(Contact c : contactLIst)
				{
					if(c.csm_related__c)
					{
						csmRelatedSize++;
					}
				}
				stdCon = new ApexPages.StandardSetController(contactList);
				//pageSize = 3;
				stdCon.setPageSize(pageSize);
			}else{
				stdCon = null;
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
	}
	
	/**
	 * @description gets the contacts and displays to page
	 * @return List<Contact> 
	 */
	public List<Contact> getContacts() {
		if(stdCon != null)
		{
			return (List<Contact>) stdCon.getRecords();
		}
		else
		{
			return null;
		}
	}
	
	/**
	 * @description accountId from page 
	 */
	public Integer conSize
	{
		get {
			if(stdCon != null)
			{
				return stdCon.getResultSize();
			}
			else 
			{
				return 0;
			} 
		}
		private set;
	}
	
	/**
	 * @description returns the pageSize of the set
	 * @return Integer 
	 */
	public Integer getPageSize() {
		if(stdCon != null)
		{
			return stdCon.getPageSize();
		}
		else
		{
			return 0;
		}
	}
	
	/**
	 * @description sets the page size of set when the user clicks display more 
	 */
	public void setPageSize() {
		if(stdCon != null)
		{
			stdCon.setPageSize(pageSize);
		}
	}
	
	/**
	 * @description increments page size and sets size on set controller 
	 */
	public PageReference updatePageSize() {
		pageSize +=3;
		setPageSize();
		return null;
	}

	/**
	 * @description increments page size and sets size on set controller 
	 */
	public PageReference reducePageSize() {
		pageSize -=3;
		setPageSize();
		return null;
	}


	
	/**
	 * @description updates the contact to be related to the CSM 
	 */
	public PageReference relateContact()
	{
		boolean isSuccess = false;
		try
		{
			if(!String.isBlank(contactToUpdate))
			{
				isSuccess = CSM_ContactDataAccess.relateContact(new List<String>{contactToUpdate});
				populateContact();
				contactToUpdate = '';
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
	
	/**
	 * @description updates the contact to not be related to the CSM 
	 */
	public PageReference unrelateContact()
	{
		boolean isSuccess = false;
		try
		{
			if(!String.isBlank(contactToUpdate))
			{
				isSuccess = CSM_ContactDataAccess.unrelateContact(new List<String>{contactToUpdate});
				populateContact();
				contactToUpdate = '';
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		return null;
	}
	
	/**
	 * @description navigate to the email contact page. Associates it to contact 
	 */
	public PageReference emailToWhatId() {
		try {

			String url = CSM_Constants.EMAIL_URL+whatIdVal +CSM_Constants.EMAIL_CONTACT_PARAM + whoIdVal +CSM_Constants.PARAM_RETURN_URL+getRetURL();
			
			// Get the List View through standard page
			PageReference pageRef = new PageReference(url);
			pageRef.setRedirect(true);
			return pageRef;
		}
    	catch (exception ex)
    	{
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
    		return null;
    	}
		
	}
	
	/**
	 * @description gets return url for when navigating to the email page 
	 */
	private String getRetURL(){
		// Get current page url through page reference 
		if(!String.isBlank(taskViewId))
		{
			PageReference pageRefTemp = Page.CSM_TaskList;
			String retURL = pageRefTemp.getURL()  + CSM_Constants.PARAM_VIEWID_URL + taskViewId;
			return retURL;
		}
		else if (!String.isBlank(successPlanId))
		{
			PageReference pageRefTemp = Page.CSM_AccountSuccessPlan;
			String retURL = pageRefTemp.getURL()  + CSM_Constants.ID_VAL + successPlanId;
			return retURL;
		}
		return null;
		
	}
	
	/**
	 * @description navigate to contact details page 
	 */
	public PageReference redirectToContact() {
		try { 
			if(!String.isBlank(contactToUpdate))
			{
				String url = '/' + contactToUpdate;
				PageReference pageRef = new PageReference(url);
				pageRef.setRedirect(true);
				return PageRef;
			}
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
		}
		return null;

	}
	
	
}