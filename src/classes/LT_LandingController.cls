global with sharing class LT_LandingController {
    public String at {get; private set;}
    public String lang {get; private set;}
    public string chatbuttonId {get;set;}
    public string deploymentId {get;set;}
    public string deploymentURL {get;set;}
    public string apiEndPointURL {get;set;}
    public string contactName {get;set;}
    public string oppId {get;set;}
    public string orgID {get;set;}
    public List<REN_Header_Footer_Links__c> headerLinks {get;set;}
    public List<REN_Header_Footer_Links__c> footerLinks {get;set;}
    public REN_Low_Dollar_Client__c clientDetails {get;set;}
    public boolean isChatEnabled {get;set;}
    
	public LT_LandingController(){
        lang = ApexPages.currentPage().getParameters().get('lang');   
        oppId = ApexPages.currentPage().getParameters().get('oppId'); 
        System.debug('LANG ---> '+ApexPages.currentPage().getParameters());
        at = REN_LowTouchIntegration.getAccessToken();
        List<REN_LT_LiveAgentDetails__c> liveAgentList =  REN_LT_LiveAgentDetails__c.getall().values();		
		Map<String, REN_LT_LiveAgentDetails__c> liveAgentMap = new Map<String, REN_LT_LiveAgentDetails__c>();
        for(integer i=0;i<liveAgentList.size();i++) {
            if(liveAgentList[i].REN_LT_Language__c == lang) {
            	system.debug('in d if : '+liveAgentList[i].REN_LT_Language__c);
                //liveAgentObj = liveAgentList[i];
                liveAgentMap.put(liveAgentList[i].REN_LT_Language__c, liveAgentList[i]);
            } else if(liveAgentList[i].REN_LT_Language__c == '' || liveAgentList[i].REN_LT_Language__c == null || (liveAgentList[i].REN_LT_Language__c).containsIgnorecase('en')) {
                system.debug('in d else : '+liveAgentList[i].REN_LT_Language__c);
                //liveAgentObj = liveAgentList[i];
                liveAgentMap.put('en-US', liveAgentList[i]);
            }
        }
        REN_LT_LiveAgentDetails__c liveAgentObj = liveAgentMap != null ? liveAgentMap.get(lang) : null;
        system.debug('liveAgentObj: '+liveAgentObj);
		chatbuttonId = liveAgentObj != null ? liveAgentObj.REN_LT_Chat_button_Id__c : '';
		deploymentId = liveAgentObj != null ? liveAgentObj.REN_LT_Deployment_Id__c : '';
		deploymentURL = liveAgentObj != null ? liveAgentObj.REN_LT_Deployment_URL__c :'';
		apiEndPointURL = liveAgentObj != null ? liveAgentObj.REN_LT_Chat_Init_URL__c :'';
		orgId = String.valueOf(UserInfo.getOrganizationId()).substring(0, 15);
		Map<String, String> userLanguageMap = CHL_Util.fetchUserLanguagePicklistValue();
       	String languageParam = userLanguageMap != null && !userLanguageMap.isEmpty() ? userLanguageMap.get(lang):'';
		headerLinks = REN_HeaderFooterDataAccess.getLinksBasedOnType('Header', languageParam);
		footerLinks = REN_HeaderFooterDataAccess.getLinksBasedOnType('Footer', languageParam);
		clientDetails = REN_LowTouchClientDataAccess.getLowtouchClientRecordForGuestUser()[0];
		List<OpportunityContactRole> opptyRoleList = REN_OpportunityDataAccess.getPrimaryContacts(new set<String>{oppId});
		isChatEnabled = clientDetails != null ? clientDetails.REN_Live_Agent__c : false;
		if(opptyRoleList != null && !opptyRoleList.isEmpty()) {
		    contactName = opptyRoleList[0].Contact.FirstName != null ? opptyRoleList[0].Contact.FirstName : opptyRoleList[0].Contact.LastName;
		} else {
		    contactName = 'DRVisitor';
		}
    }
    
	/**
    * @description : This variable dynamically loads the static resource in the community landing page.
                     This resource should dynamically load the locale js file as per user locale.
    */
    public String locName {
		get 
		{ 
            locName = String.isNotBlank(lang) && lang != null ? '/angular/i18n/angular-locale_'+CHL_Util.getAngularGridLocaleForUserLocale(lang)+'.js' : 'en-US.js';
			return locName;
		}
        set;
     }
     
     public string lowTouchLogoURL {
        get{
            List<Document> documentList = [Select d.Id From Document d where d.DeveloperName = 'LowTouch_Logo' limit 1];
            SS_License__c ssLicenseObj = SS_License__c.getOrgDefaults();
            lowTouchLogoURL = documentList != null && !documentList.isEmpty() ? ssLicenseObj.REN_Domain__c+'/servlet/servlet.ImageServer?id='+documentList[0].Id+'&oid='+orgId : '';
            //lowTouchLogoURL = 'http://www.acme-group.net/Content/Images/acmegroup-logo.png';
            system.debug('lowTouchLogoURL :: '+lowTouchLogoURL);
            return lowTouchLogoURL; 
        }
        set;
    }
    
    
    @RemoteAction
    global static String gateway(String inputValue){
    	/*string oppReq = '{"status":"SUCCESS","meta":{"definitions":{"opportunity":{"type":"object","title":"opportunity","required":[],"relationships":{"account":{"type":"object","title":"account","required":["name"],"relationships":null,"properties":{"name":{"type":"STRING","title":"Account Name","order":0,"display":true,"dbRequired":true,"apiName":"name"}}}},"properties":{"quote-link":{"type":"url","title":"quote-link","order":0,"display":true,"dbRequired":null,"apiName":null},"amount":{"type":"CURRENCY","title":"Amount","order":1,"display":true,"dbRequired":false,"apiName":"amount"}}}}},"links":null,"included":[{"type":"account","relationships":null,"links":{"self":"/opportunity/006f100000c1an4AAA/relationships/account"},"Id":"001j000000XBiYbAAL","attributes":{"name":"Child2 Account"}}],"flowName":"PO Upload","errors":[],"error":null,"data":[{"type":"opportunity","relationships":{"account":{"links":{"related":"/opportunity/006f100000c1an4AAA/account","self":"/opportunity/006f100000c1an4AAA/relationships/account"},"data":{"Id":"001j000000XBiYbAAL","type":"account"}}},"links":{"self":"/opportunity/006f100000c1an4AAA"},"Id":"006f100000c1an4AAA","attributes":{"quote-link":"068f10000047BuBAAU","amount":"26652.00"}}],"action":"POST"}"';
        REN_LowTouchPayLoad payLoad = (REN_LowTouchPayLoad) JSON.deserialize(oppReq, REN_LowTouchPayLoad.class);
        new REN_LowTouchOpportunitiesService().postResponse('006f100000c1an4AAA', payLoad);
        return oppReq;*/
        String data = '';
        REN_JSONAPIRouter ltRouter = new REN_JSONAPIRouter();
        data = ltRouter.getPostRequest(inputValue);
        system.debug('data :: '+data);
        return data;
    }
  
}