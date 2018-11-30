/**
 * Created Date     : Jan 17, 2017
 * Developed By     : Tanvi, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Tanvi                    User Story              Jan 17, 2017            1.1                 @description
 *
 */
public with sharing class REN_LT_HeaderFooterController {

    

    /**
     * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
    // MARK: Your method goes here
    
    
    @AuraEnabled
    public static String getLogo() {
        String logoURL = getStaticResourcePath('LT_Resources') + '/lowtouch/images/low-touch-logo.png' ;
        return logoURL;
    }
    
     @AuraEnabled
    public static REN_Low_Dollar_Client__c getClientDetails() {
        return REN_LowTouchClientDataAccess.getLowDollarClientDetails()[0];        
    }
    
    @AuraEnabled
    public static List<String> getCSSLinks() {
        List<String> cssLinks = new List<String>();
        String baseURL = getStaticResourcePath('LT_Resources');
        cssLinks.add( baseURL+ '/lowtouch/styles/bootstrap.min.css');
        //cssLinks.add( baseURL+ '/lowtouch/styles/icons.css');
        cssLinks.add( baseURL+ '/lowtouch/styles/main.css');
        return cssLinks;
    }
    
    public static String getStaticResourcePath(string sRname) {
        List<StaticResource> staticResourceList = [SELECT Id,name, SystemModStamp FROM StaticResource WHERE Name =:sRname LIMIT 1];
        Organization orgInfo = [SELECT IsSandbox, InstanceName FROM Organization WHERE id=:Userinfo.getOrganizationId()];
        String instanceName = '';
        if(orgInfo.isSandbox){
        	instanceName = orgInfo.InstanceName.toLowerCase() + '.';
        }
        String resourcePath = staticResourceList != null && !staticResourceList.isEmpty()? '/resource/'
                    + String.valueOf(((DateTime)staticResourceList[0].get('SystemModStamp')).getTime())
                    + '/' 
                    + staticResourceList[0].get('Name') : '';
        
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        baseURL = baseURL.replace(instanceName + 'my.salesforce', 'lightning.force');
        return baseURL + resourcePath;
    }
       
    public class REN_LowTouchLandingComponents{
        @AuraEnabled
        public List<REN_Header_Footer_Links__c> headerLinks;
        @AuraEnabled
        public List<REN_Header_Footer_Links__c> footerLinks;
        @AuraEnabled
        public String logoURL;
        @AuraEnabled
        public REN_Low_Dollar_Client__c clientDetails;
        @AuraEnabled
        public List<String> cssLinks;
        @AuraEnabled
        public String logoLink;
        @AuraEnabled
        public REN_ToggleLowTouchConfiguration lowTouchConfig;        
    }
    
    @AuraEnabled
    public static REN_LowTouchLandingComponents getLandingComponents(String lang_Param) {
       REN_LowTouchLandingComponents attr = new REN_LowTouchLandingComponents();
       Map<String, String> userLanguageMap = CHL_Util.fetchUserLanguagePicklistValue();
       String lang = userLanguageMap != null && !userLanguageMap.isEmpty() ? userLanguageMap.get(lang_Param):'';
        attr.headerLinks = REN_HeaderFooterDataAccess.getLinksBasedOnType('Header',lang);
        attr.footerLinks = REN_HeaderFooterDataAccess.getLinksBasedOnType('Footer',lang);
        attr.logoURL = getLogo();
        REN_Low_Dollar_Client__c clientDetails = getClientDetails();
        attr.logoLink = clientDetails.REN_Logo_URL__c;
        attr.cssLinks = getCSSLinks();
        REN_ToggleLowTouchConfiguration lowTouchConfig = new REN_ToggleLowTouchConfiguration();
        if(lowTouchConfig != null){
            lowTouchConfig.isDocuSignActive= clientDetails.REN_Docusign__c?true:false;        
            lowTouchConfig.isLiveChatActive = clientDetails.REN_Live_Agent__c?true:false;        
            lowTouchConfig.isFileUploadActive = clientDetails.REN_PO_Upload__c?true:false;       
            lowTouchConfig.isPaymentActive = clientDetails.REN_Asparato_Payment__c?true:false;             
        }
        attr.lowTouchConfig = lowTouchConfig;
        return attr;
    } 
     
    @AuraEnabled
    public static REN_ToggleLowTouchConfiguration getLTConfiguration(){
        return REN_LowTouchAdminDataAccess.getLowTouchConfig();
    }
    
    @AuraEnabled
    public static String getDecryptedOppId(String encryptData){
        String oppId = REN_Util.getDecryptedData(encryptData);
        return oppId;
    }
    
    @AuraEnabled
    public static String getSSNamespace() {
    	return CSM_Util.getNamespace();
    }
    
    @AuraEnabled
    public static String getLanguages() {
        Map<String, String> userLanguageMap = CHL_Util.fetchUserLanguagePicklistValue();
        return json.serialize(userLanguageMap);       
    }
    
    @AuraEnabled
    public static Map<String,String> getTranslatedStringsMap(String lang_Param) {
        Map<String,String> mapOfStrings = new Map<String,String>();
        String langCode = lang_Param != null && lang_Param != '' ? lang_Param : 'en_US';        
        REN_LabelTranslatorAPI lbltranslator = new REN_LabelTranslatorAPI();        
        return lbltranslator.translatedLabelsMap(langCode);
    }
    
    @AuraEnabled
    public static OpportunityContactRole getContactLangCode(String oppId){
    	Opportunity oppObj = REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<String>{oppId}).get(0);
        List<OpportunityContactRole> opptyRoleList = REN_OpportunityDataAccess.getPrimaryContacts(new set<String>{oppId},String.valueof(oppObj.AccountId));
        if(opptyRoleList == null ||opptyRoleList.isEmpty() ) {
        	REN_HandleOpportunityStageUpdate.updateErrorLog(system.Label.CHL_LBL_STAGE_ONLOAD, System.label.REN_INVALID_CONTACT, oppId); 
        	return null;
        } else {
        	return opptyRoleList.get(0);
        }
    }    
}