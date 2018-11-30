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
 * Vishal					US3345				May 21, 2018			1.1					@description
 *
 */
public with sharing class REN_IBExportDownloadCtrl {
    //FileId sent over to RS Service
	private String fileId {get; set;}
    
    //Config object to retrieve Name Credentials
    private sObject configSettingObj;
    
    //IBReport URL for us to download
    public String ibReportURL {get; private set;}
    
    //Initial variable set to downloadFile and then close the tab
    public Boolean downloadFile {get; private set;}
    
    //Constructor - initialize the downloadFile boolean variable and retrieve the FileId
    public REN_IBExportDownloadCtrl() {
        downloadFile = false;
        fileId = ApexPages.currentPage().getParameters().get('fileId');
    }
    
    //Retrieve the Config, make the call to RS and retrieve the URL for the IB Export
    private String getIBExportURL(){
        string responseStr = null;

        String baseNamespace = CSM_Util.getNamespace();

        // New IB Export Download Flow
        Set<String> flowNames = new Set<String>{'IB Export Download'};
        sObject configSettingObj;    
        
        // Get the configuration
        List<sObject> configSettingList = REN_RSIntegrationUtil.getConfigSettings(flowNames);
        if(configSettingList != null && !configSettingList.isEmpty()){
            configSettingObj = configSettingList[0];
        }
        
        // Need the Named Credentials
        if(configSettingObj == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There is no Configuration Record for IB Export Download in the Org. Contact your System Admin to configure this feature before using it.');
            ApexPages.addMessage(myMsg);
        }else if(String.isEmpty((String)configSettingObj.get(baseNamespace + 'REN_Named_Credential__c'))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The user credentials are not present in the Org. Contact your System Admin to configure this feature before using it.');
            ApexPages.addMessage(myMsg);
        }else if(String.isEmpty((String)configSettingObj.get(baseNamespace + 'REN_Named_Credential_URL_Extension__c'))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The user credentials are not present in the Org. Contact your System Admin to configure this feature before using it.');
            ApexPages.addMessage(myMsg);
        }else {
            
            // Create the wrapper to call RS oData Action
            REN_RSIntegrationUtil.REN_RSIntegrationWrapper wrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();

			//Named Credentials
            wrapper.namedCredential = (String)configSettingObj.get(baseNamespace + 'REN_Named_Credential__c');
            wrapper.namedCredentialExtn = (String)configSettingObj.get(baseNamespace + 'REN_Named_Credential_URL_Extension__c');
            
            //Download Param - FileId
            Map<String, String> ibReportDownloadParam = new Map<String, String>();
            ibReportDownloadParam.put('fileId', this.fileId);
            String jsonStr = JSON.serialize(ibReportDownloadParam);
			wrapper.jsonData = jsonStr;
            
            //Action set to Get
            wrapper.action = 'GET';
            
            //Call the RS oData action to get the URL
            REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
            HttpResponse resp = callout.postHttpRequest(wrapper);
            
            //Check the response and set the message or response str accordingly
            if(resp == null || resp.getStatusCode() != 200){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occurred while processing your request. Contact your System Admin.');
                ApexPages.addMessage(myMsg);
            }else{
                responseStr = resp.getBody();           
            }    
        }
        return responseStr;
    }
    
    //Get the URL, set DownloadFile variable and IBReportURL and download the file through UI
    public PageReference authenticateAndDownload(){
        try{
            System.debug('In Here - ');
            downloadFile = true;
            ibReportURL = getIBExportURL();
            if (ibReportURL==null){
                this.ibReportURL = 'https://vishlightningss-dev-ed--c.na78.content.force.com/sfc/servlet.shepherd/version/download/0681N000003IaXW?asPdf=false&operationContext=CHATTER';
            }
            System.debug('ibReportURL - '+ibReportURL);
        } 
        catch (exception ex) {
            System.debug('Error - '+ex.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error -'+ex.getMessage());
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
}