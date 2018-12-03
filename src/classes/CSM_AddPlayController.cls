/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		08.05.2014
 * @description	CSM_AddPlaybookController controller class Add Playbook page
 */

public with sharing class CSM_AddPlayController {
	
	public Boolean hasCSMAccess {get; private set;}
    public Boolean hasRenewAccess {get; private set;}
    public String retURL {get; set;}
	public String playbookId {get; set;}
	public String playId {get; set;}
	public boolean addPlay {get; set;}
	public String titleHeader {get; set;}
	public String subtitleHeader {get; set;}
	
	/** 
 	 * @description	constructor 
 	 */
	public CSM_AddPlayController() {
		hasCSMAccess = SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
        //Get url parameters
		retURL = ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL);
		playbookId = ApexPages.currentPage().getParameters().get(CSM_Constants.PLAYBOOK_ID_PARAM);
		playId = ApexPages.currentPage().getParameters().get('pId');
		if(ApexPages.currentPage().getParameters().get(CSM_Constants.ADD_PARAM) == 'true'){
			addPlay = true;
		}
		else {
			addPlay = false;
		}
		//If the title is passed use it, otherwise use default
		if(ApexPages.currentPage().getParameters().get(CSM_Constants.TITLE_PARAM) != null) {
			titleHeader = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(CSM_Constants.TITLE_PARAM),CSM_Constants.UTF_8);
		}
		else {
			titleHeader = Label.CSM_LBL_PLAYBOOK_MGMT;
		}
		//Set subtitle header
		subtitleHeader = Label.CSM_LBL_PLAY_ADD;
			
			
	}
	

}