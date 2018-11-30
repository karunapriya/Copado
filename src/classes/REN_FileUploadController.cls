/**
 * Created Date     : Jan 25, 2017 
 * Developed By     : Dheeraj, Comity Designs, Inc.
 *
 * Function         : @description - Upload file form Lightning components
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj S.                 US2006              Jan 25, 2017         1.1                 @description
 *
 */
global with sharing class REN_FileUploadController {
   
    public string oppId{get;set;}
    public string renId{get;set;}
    public boolean isSaved{get;set;}
    public boolean ltException{get;set;}
    public string accessToken{get;set;}
    public string returnURL{get;set;}
    public string baseURL{get;set;}
    public string jsPath{get;set;}
    private String CUSTOM_DOMAIN_POSTFIX;
    private final String LIGHTNING_URL_POSTFIX = '.lightning.force.com';
    public string cssPath{get;set;}
    private final String PREFIX='Signed PO - ';
    private final String COMMIT_LEVEL = 'Commit_Level__c';
    private final String ERROR_MSG= system.Label.REN_ERR_FILE_UPLOAD;
    private final String SUCCESS_MSG=system.label.REN_LBL_SIGNED_PO_CONFIRMATION;
    private final String PO_RECEIVED ='PO Received';
    private final String COMMIT_LEVEL_YELLOW = 'Yellow';
    public string langCode{get;set;}    
    
    public REN_FileUploadController() {
        String namespace = CSM_Util.getNamespace();
        this.CUSTOM_DOMAIN_POSTFIX = String.isEmpty(namespace)?'--c':'--' + namespace.removeEnd('__');
        renId = ApexPages.currentPage().getParameters().get('renId');
        system.debug('renId in VF :: '+renId);
        oppId = REN_Util.getDecryptedData(renId);
		langCode = ApexPages.currentPage().getParameters().get('lang');
        accessToken = ApexPages.currentPage().getParameters().get('oauth_token');
        baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        isSaved = false;
        List<String> cssLinks = new List<String>();
        ltException = false;
        String lightningUrl = baseURL.substringBefore((this.CUSTOM_DOMAIN_POSTFIX).toLowerCase()) + this.LIGHTNING_URL_POSTFIX;
        //cssLinks.add(lightningUrl + '/resource/LT_Resources/lowtouch/styles/icons.css');
        cssLinks.add(lightningUrl + '/resource/LT_Resources/lowtouch/styles/bootstrap.min.css');
        cssLinks.add(lightningUrl + '/resource/LT_Resources/lowtouch/styles/main.css');
        cssPath = JSON.serialize(cssLinks);
        List<String> jsLinks = new List<String>();
        jsLinks.add(lightningUrl + '/resource/'+namespace+'CSM_Resources/vendor/jquery/jquery-1.11.1.min.js');
        jsPath = JSON.serialize(jsLinks);
        /*Cookie cook = new cookie('language','de',null,-1,false);
	        List<Cookie> cookies = new List<Cookie>();
	        cookies.add(cook);
	        ApexPages.currentPage().setCookies(cookies);*/
    }
    
    public Attachment attachment {
        get {
            if (attachment == null)
            attachment = new Attachment();
            return attachment;
        }
        set;
    }
    
    public String ltUrl {
        get {
            if (ltUrl == null){
                /*List<REN_Low_Dollar_Client__c> ltEndPoint;
                ltEndPoint = REN_LowTouchClientDataAccess.getLowDollarClientDetails();
                if(ltEndPoint != null && ltEndPoint.size() > 0){
                    ltUrl = (ltEndPoint[0].REN_Low_Touch_Admin_URL__c).removeEnd('/');
                }*/
                ltUrl = (String) CSM_Admin__c.getOrgDefaults().REN_Low_Touch_User_URL__c;
            }
            system.debug('@@@ ltUrl'+ ltUrl);
            return ltUrl;
        }
        set;
     }
     
    public pagereference upload() {
        System.Savepoint sp = Database.setSavepoint();
        try {
	        List<String> attachFieldList = new List<String>{'OwnerId','ParentId','IsPrivate','Name'};                       
	        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_ATTACHMENT, attachFieldList, CSM_Constants.DML_OPERATION_UPSERT);
	        List<String> oppFieldList = new List<String>{'StageName','REN_LT_Renewal_Details__c','REN_Notify_Opportunity_Owner__c','Probability'};
	        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITY, oppFieldList, CSM_Constants.DML_OPERATION_UPDATE);    
	        attachment.OwnerId = UserInfo.getUserId();
	        attachment.ParentId = oppId; // the record the file is attached to
	        attachment.IsPrivate = false;
	        //List<REN_Low_Dollar_Client__c> ltEndPoint;
	        Opportunity selectedOppty;
	        List<Opportunity> oppToRedirect = REN_OpportunityDataAccess.getOpportunityDetailByIdWithSyncQuote(new List<String>{oppId});
        	sp = Database.setSavepoint();
            selectedOppty = getOpportunityDetails(oppId);
            /*ltEndPoint = REN_LowTouchClientDataAccess.getLowDollarClientDetails();
            if(ltEndPoint!=null && ltEndPoint.size()>0){
                returnUrl = ltEndPoint[0].REN_Low_Touch_Admin_URL__c+'home?renId='+selectedOppty.REN_Low_Touch_Renewal_Id__c+'&lang='+langCode;
            }*/
            returnUrl = (String) CSM_Admin__c.getOrgDefaults().REN_Low_Touch_User_URL__c+'home?renId='+selectedOppty.REN_Low_Touch_Renewal_Id__c+'&lang='+langCode;
            if(CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn+COMMIT_LEVEL)) {
                selectedOppty.StageName = PO_RECEIVED;
                selectedOppty.REN_Notify_Opportunity_Owner__c  = true;
                selectedOppty.REN_LT_Renewal_Details__c = system.Label.REN_PAY_VIA_PO;
                OpportunityStage oppStage = REN_OpportunityDataAccess.getProbabilityValueByStage(PO_RECEIVED);
		  	  	selectedOppty.Probability = oppStage.DefaultProbability;
                selectedOppty.put(CSM_Util.nameSpacePrefixSolnExtn+COMMIT_LEVEL, COMMIT_LEVEL_YELLOW);
                CSM_CaseDataAccess.createBookingRequest(oppToRedirect[0].id);
                attachment.Name = PREFIX+attachment.Name;
                insert attachment;
                isSaved = true;
                REN_OpportunityDataAccess.updateOpportunitySObject(new List<Opportunity>{selectedOppty}, oppFieldList);
            }
           
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ERROR_MSG));
            Database.rollback(sp);
            isSaved = false;
            ltException = true;
            insertLtError(ex, oppId);
            return null;
        } finally {
            attachment = new Attachment(); 
        }        
      
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,SUCCESS_MSG));
        return null;
    }
      
	@RemoteAction
	global static RemoteResponse upload(String attachmentName, String attachmentBody, String oppId) {
    	RemoteResponse response = new RemoteResponse();
        return response;
	}
	
    private static Opportunity getOpportunityDetails(String oppId) {
        Opportunity selectedOppty;    
        List<Opportunity> oppToRedirect = REN_OpportunityDataAccess.getOpportunityDetailByIdWithSyncQuote(new List<String>{oppId});
        if(oppToRedirect != null && oppToRedirect.size() > 0) {
            selectedOppty = oppToRedirect.get(0);
        }
        return selectedOppty;
    }
      
    private static void insertLtError(Exception ex, String oppId) {
        REN_Error_Log__c errorLog = new REN_Error_Log__c();
        errorLog.REN_Error_Description__c = ex.getMessage();
        errorLog.REN_Flow__c = Label.REN_LT_PAY_VIA_PO;
        errorLog.REN_OpportunityId__c = oppId;
        REN_LT_ErrorLogDataAccess.insertErrorLog(new List<REN_Error_Log__c>{errorLog});
    }
    
    global with sharing class RemoteResponse {
		
	}
}