/** 
 * @author		Mike Faust(mike@comitydesigns.com)
 * @date		08.05.2014
 * @description	CSM_AddPlaybookController controller class Add Playbook page
 */

public with sharing class CSM_AddPlaybookController {
	
	public Boolean hasCSMAccess {get; private set;}
    public Boolean hasRenewAccess {get; private set;}
    public String retURL {get; set;}
	public String accountPlanTemplateId {get; set;}
	public String accountPlanId {get; set;}
	public boolean addPlaybook {get; set;}
	public String titleHeader {get; set;}
	public String subtitleHeader {get; set;}
	
	/** 
 	 * @description	constructor 
 	 */
	public CSM_AddPlaybookController() {
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
        //Get url parameters
		retURL = ApexPages.currentPage().getParameters().get(CSM_Constants.RET_TO_URL);
		accountPlanTemplateId = ApexPages.currentPage().getParameters().get(CSM_Constants.ACCT_PLAN_TEMPLATE);
		accountPlanId = ApexPages.currentPage().getParameters().get(CSM_Constants.ACCT_PLAN_ID);
		if(ApexPages.currentPage().getParameters().get(CSM_Constants.ADD_PARAM) == 'true')
			addPlaybook = true;
		else
			addPlaybook = false;
		//If the title is passed use it, otherwise use default
		if(ApexPages.currentPage().getParameters().get(CSM_Constants.TITLE_PARAM) != null)
			titleHeader = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get(CSM_Constants.TITLE_PARAM),CSM_Constants.UTF_8);
		else
			titleHeader = Label.CSM_LBL_ACCT_PLAN_TEMPLATE;
		//Set subtitle header
		subtitleHeader = Label.CSM_LBL_PLAYBOOK_ADD;
			
			
	}
	

}