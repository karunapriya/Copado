/** 
 * @author		Karunapriya Rameshwaram(karunapriya@comitydesigns.com)
 * @date		09.22.2014
 * @description	CSM_PlayDetailsCtrl class for CSM_PlayDetails page
 */
public with sharing class CSM_PlayDetailsCtrl {

	public boolean hasCSMAccess {get; private set;}
	public Boolean hasRenewAccess {get; private set;}
	public CSM_Play__c play {get; set;}
	public String playId {get; set;}
	public String retUrl {get; private set;}
	
	/**
	 * @description controller
	 */
	public CSM_PlayDetailsCtrl() {
		
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
		playId = ApexPages.currentPage().getParameters().get(CSM_Constants.ID_PARAM);
		if(ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL) != null)
		{
			retUrl = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL),CSM_Constants.UTF_8);
		}
		getPlayDetails();
	}
	
	/**
	 * @description gets the play details for the playId
	 */
	private void getPlayDetails(){
		play = new CSM_Play__c();
		try
		{
			play = CSM_PlaysDataAccess.populatePlayInformation(playId);
		}
		catch (Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	}
	
	/**
	 * @description gets return url for when navigating to the play detail page 
	 */
	public pageReference goBack() {
		PageReference pageRef = new PageReference(retUrl);
		pageRef.setRedirect(true);
		return pageRef;
	}
}