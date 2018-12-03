/**
 * Created Date		: May 21, 2018
 * Developed By		: Vishal, Comity Designs, Inc.
 *
 * Function			: @description - Using the File Id, it makes a trip to RS webservice to retrieve the URL and download that file
 * Support Email 	: smitah@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Vishal									May 21, 2018			1.1					@description
 *
 */
public with sharing class REN_DownloadCtrl {
    //FileId sent over to RS Service
	private String attachmentId {get; set;}
    
    //Config object to retrieve Name Credentials
    private sObject configSettingObj;
    
    //IBReport URL for us to download
    public String ibReportURL {get; private set;}
    
    //Initial variable set to downloadFile and then close the tab
    public Boolean downloadFile {get; private set;}
    public String timeoutLimit {get; set;}
    public Boolean isSuccess {get; set;}
    
    //Constructor - initialize the downloadFile boolean variable and retrieve the FileId
    public REN_DownloadCtrl() {
        downloadFile = false;
        timeoutLimit = '';
        isSuccess = false;
        attachmentId = ApexPages.currentPage().getParameters().get('attachmentId');
    }
    
    //Retrieve the Config, make the call to RS and retrieve the URL for the IB Export
    private String getIBExportURL(){
        string responseStr = null;

        String baseNamespace = CSM_Util.getNamespace();
        timeoutLimit = CSM_Admin__c.getOrgDefaults().REN_TimeOut_Limit__c;
        if(timeoutLimit != null && timeoutLimit != ''){
        	timeoutLimit = String.valueof((Integer.valueof(timeoutLimit.trim()) * 1000));
        }else{
        	timeoutLimit = '10000';
        }
        // New IB Export Download Flow
        Set<String> flowNames = new Set<String>{'IB Export Download'};
        sObject configSettingObj;    
        
        // Get the configuration
        List<sObject> configSettingList = REN_RSConfigurationDataAccess.getConfigSettings(flowNames);
        if(configSettingList != null && !configSettingList.isEmpty()){
            configSettingObj = configSettingList[0];
        }
        
        // Need the Named Credentials
        if(configSettingObj == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_Config_Setting_Error, new List<String>{'IB Export Download'}));
            ApexPages.addMessage(myMsg);
        }else if(String.isEmpty((String)configSettingObj.get(baseNamespace + 'REN_Named_Credential__c'))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Named_Credential_Error);
            ApexPages.addMessage(myMsg);
        }else if(String.isEmpty((String)configSettingObj.get(baseNamespace + 'REN_Named_Credential_URL_Extension__c'))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Named_Credential_Error);
            ApexPages.addMessage(myMsg);
        }else {
            
            // Create the wrapper to call RS oData Action
            REN_RSIntegrationUtil.REN_RSIntegrationWrapper wrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();

			//Named Credentials
            wrapper.namedCredential = (String)configSettingObj.get(baseNamespace + 'REN_Named_Credential__c');
            wrapper.namedCredentialExtn = (String)configSettingObj.get(baseNamespace + 'REN_Named_Credential_URL_Extension__c');
            if (wrapper.namedCredentialExtn != null){
	            wrapper.namedCredentialExtn += '?attachmentId='+this.attachmentId;
			}
            
            //Action set to Get
            wrapper.action = 'GET';
            
            //Call the RS oData action to get the URL
            REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
            HttpResponse resp = callout.postHttpRequest(wrapper);
            System.debug('resp - '+resp);
            //Check the response and set the message or response str accordingly
            if(resp == null || resp.getStatusCode() != 200){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_IBExport_Response_Error);
                ApexPages.addMessage(myMsg);
            }else{
                responseStr = resp.getBody(); 
                isSuccess = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.REN_LBL_IBEXPORT_DOWNLOAD_FROM_CHATTER);
                ApexPages.addMessage(myMsg);                                   
            }    
        }
        return responseStr;
    }
    
    //Get the URL, set DownloadFile variable and IBReportURL and download the file through UI
    public PageReference authenticateAndDownload(){
        //PageReference page;
        try{
            System.debug('In Here - ');
            downloadFile = true;
            String result = getIBExportURL();
            DownloadStructure structure = (DownloadStructure)JSON.deserialize(result, DownloadStructure.class);
            //if (ibReportURL==null){
            //    this.ibReportURL = 'https://vishlightningss-dev-ed--c.na78.content.force.com/sfc/servlet.shepherd/version/download/0681N000003IaXW?asPdf=false&operationContext=CHATTER';
            //}
            ibReportURL = structure.url;
            
            //if (ibReportURL!=null){
            //    page = new PageReference(ibReportURL);
            //	page.setRedirect(true);
            //}

            System.debug('ibReportURL - '+ibReportURL);
        } 
        catch (exception ex) {
            System.debug('Error - '+ex.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error -'+ex.getMessage());
            ApexPages.addMessage(myMsg);
        }
        //return page;
        return null;
    }
    
    private with sharing class DownloadStructure {
        String attachmentId {get; set;}
        String url {get; set;}
        String success {get; set;}
    }
}