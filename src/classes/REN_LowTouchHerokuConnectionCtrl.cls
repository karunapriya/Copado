/**
 * Created Date     : Jan 9, 2017
 * Developed By     : Sheetal, Comity Designs, Inc.
 *
 * Function         : This page and controller is used to Authorize a third party application.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Sheetal                  US1981              Jan 9, 2017         1.1                 Added class in sprint 701
 *
 */
public with sharing class REN_LowTouchHerokuConnectionCtrl {
    public CSM_DataGridAttribute oauthSetupGridAttribute{get; set;}
    public List<REN_Low_Dollar_Client__c> recordList {get; set;}
    public String recordId{get;set;}
    public String oauthUrl{get;set;}    
    private String CUSTOM_DOMAIN_POSTFIX;
    private final String LIGHTNING_URL_POSTFIX = '.lightning.force.com';
    public String helpParam {get; set;} 
    private String communityURL;
    
    public REN_LowTouchHerokuConnectionCtrl() {
        helpParam = CSM_Constants.HELP_LOW_TOUCH;
        String namespace = CSM_Util.getNamespace();
        this.CUSTOM_DOMAIN_POSTFIX = String.isEmpty(namespace)?'--c':'--' + namespace.removeEnd('__');
        Map<string, REN_Low_Dollar_Client__c> lowTouchAdmin = new Map<String,REN_Low_Dollar_Client__c>(REN_LowTouchClientDataAccess.getLowDollarClientDetails());
        recordList = new List<REN_Low_Dollar_Client__c>();
        for(REN_Low_Dollar_Client__c value : lowTouchAdmin.values()) {
            recordList.add(value);
        }
        if(CSM_AccessController.hasObject('Network')){
	        try{
		        List<sObject> lstOfCommunities = Database.query('SELECT Name,UrlPathPrefix,Id FROM Network where name =\'DigitalRenewals\'');
		        if(lstOfCommunities!=null && !lstOfCommunities.isEmpty()){
		            communityURL = Network.getLoginUrl((Id)lstOfCommunities.get(0).get('Id'));
		            system.debug('Community URL: '+communityURL);
		        }
	        }catch(Exception e){
	        	communityURL = '';
	        }
        }else{
        	communityURL ='';
        }
        
        oauthSetupGridAttribute = new CSM_DataGridAttribute();
        oauthSetupGridAttribute.tableName = 'oAuthSetupPage';
        oauthSetupGridAttribute.objectType  = 'oAuthSetupPage';
        oauthSetupGridAttribute.viewName = 'oAuthSetupPage';
        oauthSetupGridAttribute.gridToolBarId = 'grid-toolbar';
        oauthSetupGridAttribute.hasSearch = 'false';
        oauthSetupGridAttribute.stateSave = 'false';
        oauthSetupGridAttribute.hasShowColumns = 'false';
        oauthSetupGridAttribute.showExport ='false';
        oauthSetupGridAttribute.showGlobalSelect = 'false';
        oauthSetupGridAttribute.params = '{}';
        Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
        oauthSetupGridAttribute.userDateFormat = localeMap.get(userInfo.getLocale());
    }
    
    public PageReference deleteOAuthRecord() {
        if(String.isNotBlank(recordId)) {
             REN_Low_Dollar_Client__c recordList = REN_LowTouchAdminDataAccess.getLowTouchAdminRecordsById(recordId);
             String strUrl = recordList.REN_Low_Touch_Admin_URL__c + 'revokeAccess?orgid=' + UserInfo.getOrganizationId();
             HttpRequest req = new HttpRequest(); 
             req.setEndpoint(strUrl); 
             req.setMethod('GET'); 

             Http http = new Http(); 
             HTTPResponse res = http.send(req); 
             if(res.getStatusCode() == 200){
                recordList.REN_Low_Touch_Admin_URL__c= null;
                if(REN_LowTouchClientDataAccess.deleteLowTouchRecord(new List<REN_Low_Dollar_Client__c>{recordList})){                  
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.REN_DELETE_OAUTH));
                }               
             }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_DELETE_OAUTH_ERROR));             
             }
        }       
        return null;
    }
    
    public PageReference authorizeHerokuOrg() {
        PageReference pageRef = null;
        if(String.isNotBlank(recordId)) {
            REN_Low_Dollar_Client__c recordList = REN_LowTouchAdminDataAccess.getLowTouchAdminRecordsById(recordId);
            String lightningUrl = URL.getSalesforceBaseUrl().toExternalForm();
            lightningUrl = lightningUrl.substringBefore((this.CUSTOM_DOMAIN_POSTFIX).toLowerCase()) + this.LIGHTNING_URL_POSTFIX;
            organization orgInfo = [select IsSandbox from Organization where id=:Userinfo.getOrganizationId()];
            string environment = orgInfo.IsSandbox ? 'sandbox' : 'production';
             if(String.isNotBlank(communityURL)){
                Integer indexOf = communityURL.lastIndexOfIgnoreCase('/login');
                if(indexOf>-1){
                    communityURL = communityURL.subString(0,indexOf);
                }
            }else{
                communityURL='';
            }
            this.oauthUrl = recordList.REN_Low_Touch_Admin_URL__c + 'renewUserAccess?sfdcurl=' + lightningUrl+'&env='+environment+'&communityUrl='+communityURL; //sandbox
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.REN_INVALID_URL));
        }
        return pageRef;
    }
}