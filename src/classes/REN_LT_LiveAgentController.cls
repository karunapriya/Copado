/**
 * Created Date		: Jan 25, 2017
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Tanvi					User Story				Jan 25, 2017			1.1					@description
 * 
 */
public with sharing class REN_LT_LiveAgentController {

    public string chatbuttonId {get;set;}
    public string deploymentId {get;set;}
    public string deploymentURL {get;set;}
    public string apiEndPointURL {get;set;}
    public string contactName {get;set;}
    public string oppID {get;set;}
    public string orgID {get;set;}
    private String CUSTOM_DOMAIN_POSTFIX;
    private final String LIGHTNING_URL_POSTFIX = '.lightning.force.com';
    public string cssPath{get;set;}
    public string langCode{get;set;}    
    public string renId{get;set;}
    
    public REN_LT_LiveAgentController() {
	    
        String namespace = CSM_Util.getNamespace();
        this.CUSTOM_DOMAIN_POSTFIX = String.isEmpty(namespace)?'--c':'--' + namespace.removeEnd('__');
        langCode = ApexPages.currentPage().getParameters().get('lang');
		List<REN_LT_LiveAgentDetails__c> liveAgentList =  REN_LT_LiveAgentDetails__c.getall().values();
		REN_LT_LiveAgentDetails__c liveAgentObj;
        for(integer i=0;i<liveAgentList.size();i++) {
            if(liveAgentList[i].REN_LT_Language__c == langCode) {
            	system.debug('in d if : '+liveAgentList[i].REN_LT_Language__c);
                liveAgentObj = liveAgentList[i];
                //break;
            } else if(liveAgentList[i].REN_LT_Language__c == '' || liveAgentList[i].REN_LT_Language__c == null || (liveAgentList[i].REN_LT_Language__c).containsIgnorecase('en')) {
                system.debug('in d else : '+liveAgentList[i].REN_LT_Language__c);
                liveAgentObj = liveAgentList[i];
                //break;
            }
        }
        system.debug('liveAgentObj: '+liveAgentObj);
		chatbuttonId = liveAgentObj != null ? liveAgentObj.REN_LT_Chat_button_Id__c : '';
		deploymentId = liveAgentObj != null ? liveAgentObj.REN_LT_Deployment_Id__c : '';
		deploymentURL = liveAgentObj != null ? liveAgentObj.REN_LT_Deployment_URL__c :'';
		apiEndPointURL = liveAgentObj != null ? liveAgentObj.REN_LT_Chat_Init_URL__c :'';		
		
		renId = ApexPages.currentPage().getParameters().get('renId');
        system.debug('renId in VF :: '+renId);
        oppId = REN_Util.getDecryptedData(renId);
		orgId = String.valueOf(UserInfo.getOrganizationId()).substring(0, 15);
		
		List<String> cssLinks = new List<String>();
		String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
		String lightningUrl = baseURL.substringBefore((this.CUSTOM_DOMAIN_POSTFIX).toLowerCase()) + this.LIGHTNING_URL_POSTFIX;
        
        //cssLinks.add(lightningUrl + '/resource/LT_Resources/lowtouch/styles/icons.css');
        cssLinks.add(lightningUrl + '/resource/LT_Resources/lowtouch/styles/bootstrap.min.css');
        cssLinks.add(lightningUrl + '/resource/LT_Resources/lowtouch/styles/main.css');
        cssPath = JSON.serialize(cssLinks);
		
		List<OpportunityContactRole> opptyRoleList = REN_OpportunityDataAccess.getPrimaryContacts(new set<String>{oppID});
		
		if(opptyRoleList != null && !opptyRoleList.isEmpty()) {
		    contactName = opptyRoleList[0].Contact.FirstName != null ? opptyRoleList[0].Contact.FirstName : '' + opptyRoleList[0].Contact.LastName;
		} else {
		    contactName = 'LDT Visitor';
		}
    }
}