/** 
 * @author		Karunapriya Rameshwaram(karunapriya@comitydesigns.com)
 * @date		09.05.2014
 * @description	CSM_PlayWidgetComponentController class for CSM_PlayWidget component
 */
public with sharing class CSM_PlayWidgetComponentController {

	public CSM_Play__c playWidget {get; private set;}
	public String playName {get; set;}
	public String playDescription {get; set;}
	public String playDescriptionTmp {get; set;}	
	public Integer detailCount {get; set;}
	
	/**
	 * @description controller
	 */
	public CSM_PlayWidgetComponentController() {
		detailCount = 0;
	}
	
	/**
	 * @description id of the play  
	 */
	public String playId {
		get; 
		set{
			if(value !=null){
				playId = value;
				getPlayDetails();
			}
		}
	}
	
	/**
	 * @description id of the task view to return to when going to detail page 
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
	 * @description id of the account plan 
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
	 * @description gets the play details for the playId
	 */
	private void getPlayDetails(){
		detailCount = 0;		
		playWidget = new CSM_Play__c();
		try
		{
			playWidget = CSM_PlaysDataAccess.populatePlayInformation(playId);
			
			if(playWidget !=null){													  
				playName = playWidget.CSM_Display_Name__c;
				playDescriptionTmp = playWidget.CSM_Play_Description__c;
				
				if(playDescriptionTmp != null && playDescriptionTmp.length() > CSM_Constants.PLAY_DESC_DISPLAY_COUNT){
					detailCount = playDescriptionTmp.length();
					playWidget.CSM_Play_Description__c = playDescriptionTmp.substring(0, CSM_Constants.PLAY_DESC_DISPLAY_COUNT);
				}
			}
		}
		catch (Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	}
	
	/**
	 * @description navigate to play details page 
	 */
	public PageReference detailPage(){
		String rUrl = getRetURL();
    	rUrl = EncodingUtil.urlEncode(rUrl, CSM_Constants.UTF_8);
		PageReference pageRef = Page.CSM_PlayDetails;
		pageRef.getParameters().put(CSM_Constants.ID_PARAM, playId);
		pageRef.getParameters().put(CSM_Constants.RET_TO_URL,rUrl);
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	/**
	 * @description gets return url for when navigating to the detail page 
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
	
}