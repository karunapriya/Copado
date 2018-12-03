/**
 * Created Date : Jan 9, 2017
 * Developed By : Nidhi.
 *
 * Function : Class is used to consume REST API calls for DocuSign functionality.
 * Support Email : Nidhi@comitydesigns.com
 * Version : 1.0
 *
 * Modification Log
 *
 * Developer Name       User Story          Date Version        Description
 *____________________________________________________________________________________________________
 *
 * Nidhi                US2018              Jan 9, 2017 1.1     @description
 * 
 */

public class REN_DocuSignApiCall{ 
    //private string preferedLang;
    private Map<String,string> mapOfTranslation;
    public static final String STR_CONFIG_MISSING = 'ConfigrationMissing';
    private final String STR_EXCEPTION = 'Exception';
   
    
	public String sendEnvelope(Set<Id> oppIdSet){ 
    	Id oppId = (new List<Id>(oppIdSet))[0];
        system.debug('\n\n @@@ oppId :: ' + oppId );
        String docuSignPdfURL;
        Pagereference pageRef;
        Boolean isQuoteEnabled = CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE);   
        REN_DocuSignWrapper.InputWrapper inputWrapObj = new REN_DocuSignWrapper.InputWrapper();
        
        // To fetch Contact info 
        List<OpportunityContactRole> contactList = CSM_ContactDataAccess.getContactFromOpp(oppIdSet);
        string preferedLang = contactList != null && !contactList.isEmpty() && String.isNotBlank(contactList[0].Contact.REN_Prefered_Language_Code__c) ? contactList[0].Contact.REN_Prefered_Language_Code__c:'en-US';
        system.debug('/n/n @@ contactList :: ' + contactList);
        if(contactList[0].Contact.Email != null){
            inputWrapObj.email = contactList[0].Contact.Email;
            inputWrapObj.userName = contactList[0].Contact.LastName;
            //preferedLang = String.isNotBlank(contactList[0].Contact.REN_Prefered_Language_Code__c)?contactList[0].Contact.REN_Prefered_Language_Code__c:'en-US';
        }
        if(!test.isRunningTest()){
        	pageRef = Page.REN_LabelTranslatorPlaceholder;
        	pageRef.getParameters().put('languageCode', preferedLang);
        	REN_LabelTranslatorAPI tranlatorApi = new REN_LabelTranslatorAPI ();
        	mapOfTranslation = tranlatorApi.translatedLabelsMap(new set<Pagereference>{pageRef});
        } else {
        	mapOfTranslation = new Map<String,string>();   
       		mapOfTranslation.put('en-US','en-US');
        }
        
        DocuSignCustomSettings dsCustomSettingObj = new DocuSignCustomSettings(mapOfTranslation);
        String checkCustomSeting = dsCustomSettingObj.checkConfig();
        String autoHeader = dsCustomSettingObj.getAutoHeader();
        
         if(String.isBlank(autoHeader)){
            docuSignPdfURL = STR_EXCEPTION;
            REN_LowTouchUtil.updateErrorLog(System.label.REN_LBL_DOCUSIGN, System.label.REN_LBL_DOCUSIGN_ERROR_MSG , oppId);
            return docuSignPdfURL ;
        }
        
        if(checkCustomSeting != null ){
            if(checkCustomSeting.equals(STR_CONFIG_MISSING)){
                return checkCustomSeting;
            }
        }
        
        inputWrapObj.emailSubject= dsCustomSettingObj.emailSubject;
        inputWrapObj.headerContent = dsCustomSettingObj.headerContent;
        inputWrapObj.recipientAuthenticationMethod = dsCustomSettingObj.recipientAuthenticationMethod;
        inputWrapObj.signHereAnchorString = dsCustomSettingObj.signHereAnchorString;
        inputWrapObj.signHereAnchorXOffset = dsCustomSettingObj.signHereAnchorXOffset;
        inputWrapObj.signHereAnchorYOffset = dsCustomSettingObj.signHereAnchorYOffset;
        inputWrapObj.signHereName = dsCustomSettingObj.signHereName; 
        inputWrapObj.signHereXPosition = dsCustomSettingObj.signHereXPosition;
        inputWrapObj.signHereYPosition = dsCustomSettingObj.signHereYPosition;
        
        //This Endpoint supports creating an envelope. Rest Api URi = 'https://demo.docusign.net/restapi/v2/accounts/';
        String endPoint = dsCustomSettingObj.restApiUri + dsCustomSettingObj.accountID+'/envelopes'; 

        //List<Opportunity> oppToRedirect = REN_OpportunityDataAccess.getOpportunityDetailByIdWithSyncQuote(new List<String>{oppId});
        //Set-Up inputWrapper Object as per the custom setting
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String namespace = CSM_Util.getNamespace();
        String namespaceParam = String.isEmpty(namespace)?'':'&ssNamespace='+namespace;
        String lowTouchURL= (String) CSM_Admin__c.getOrgDefaults().REN_Low_Touch_User_URL__c;
        inputWrapObj.returnUrl = lowTouchURL+'?lang='+preferedLang + '&oppId='+oppId+'#!/opp/'+ oppId+'/checkout?'; //'?lang='+preferedLang +
        inputWrapObj.oppId = oppId;

        //To fetch synced Quote pdf from QuoteDocument
        if(isQuoteEnabled){
            List<sObject> quoteDocList = CHL_QuoteDataAccess.getSyncedQuotePDFByOpp(new set<ID>{oppId});
            system.debug('/n/n @@ quoteDocList :: ' + quoteDocList);
            Blob pdfBlob;
            if(quoteDocList != null && !quoteDocList.isEmpty()){
                inputWrapObj.DocumentText =(Blob) quoteDocList[0].get('Document');  
                inputWrapObj.DocumentName = (String) quoteDocList[0].get('name');
            } 
        }

        HTTPResponse res; 
        try{ 
            res = getHTTPResponse(inputWrapObj,autoHeader,preferedLang ,mapOfTranslation, endPoint);
            REN_ResponseWrapper wrapInst = REN_ResponseWrapper.parse(res.getBody());
            system.debug('@@@ res.getStatusCode() --  ' + res.getStatusCode());
            if(res.getStatusCode() == 201){
                //For Embededed Signing
                String endPointEmbedded = dsCustomSettingObj.restApiUri + dsCustomSettingObj.accountID+'/envelopes/'+wrapInst.envelopeId +'/views/recipient'; 
                res = getEmbeddedResponse(inputWrapObj, autoHeader,wrapInst.envelopeId, preferedLang, mapOfTranslation, endPointEmbedded);
                REN_ResponseWrapper wrapInst1 = REN_ResponseWrapper.parse(res.getBody());
                docuSignPdfURL = wrapInst1.url; 
            } else {
                docuSignPdfURL = STR_EXCEPTION;
                REN_LowTouchUtil.updateErrorLog(System.label.REN_LBL_DOCUSIGN, res.getStatus(), oppId);
            }
            //return docuSignPdfURL;
        } 
        catch(Exception e){ 
            system.debug('/n @@ invoking Exception  ' + e);
            REN_LowTouchUtil.updateErrorLog(System.label.REN_LBL_DOCUSIGN, e.getMessage(), oppId);
            docuSignPdfURL = STR_EXCEPTION;
            return docuSignPdfURL;
        } 
        return docuSignPdfURL;
    } 

    public HTTPResponse getHTTPResponse(REN_DocuSignWrapper.InputWrapper inputWrapObj,String autoHeader,String prefLang,Map<String,string> mapOfTransLang, String endpoint){
        if(inputWrapObj != null){
            String nameSpace = CSM_Util.getNamespace();
            DocuSignCustomSettings dsCustomSettingObj = new DocuSignCustomSettings(mapOfTransLang);
            REN_DocuSignDataSetup apiCallObj = new  REN_DocuSignDataSetup(inputWrapObj,prefLang);
            String json= apiCallObj.envelopeWrapper();
            HttpRequest req = new HttpRequest(); 
            req.setEndpoint(endpoint); 
            req.setMethod('POST'); 

            //Authorization header generating using DocuSign credentials. 
            String authorizationHeader = autoHeader;
            req.setHeader('X-DocuSign-Authentication', authorizationHeader); 
            req.setHeader('Accept','application/json'); 
            req.setHeader('Content-Length','162100'); 
            req.setHeader('Content-Type','application/json'); 
            req.setHeader('Content-Disposition','form-data'); 
            req.setBody(json); 
            Http http = new Http(); 
            HTTPResponse res = http.send(req);
            return res;
        }
        return null;
    }

    public HTTPResponse getEmbeddedResponse(REN_DocuSignWrapper.InputWrapper inputWrapObj, String autoHeader ,String envId,String prefLang,Map<String,string> mapOfTransLang, String endpoint){
        if(endpoint != null){
            HttpRequest reqEmbeded = new HttpRequest(); 
            String nameSpace = CSM_Util.getNamespace();
            DocuSignCustomSettings dsCustomSettingObj = new DocuSignCustomSettings(mapOfTransLang);
            reqEmbeded.setEndpoint(endpoint); 
            reqEmbeded.setMethod('POST'); 
            //Authorization header generating using DocuSign credentials. 
            String authoHeaderEmbeded = autoHeader; 
            reqEmbeded.setHeader('X-DocuSign-Authentication', authoHeaderEmbeded); 
            reqEmbeded.setHeader('Accept','application/json'); 
            reqEmbeded.setHeader('Content-Type','application/json'); 
            REN_DocuSignDataSetup apiCallObj = new  REN_DocuSignDataSetup(inputWrapObj,prefLang);
            String jsonReq = apiCallObj.getRecipentAuthentication();
            reqEmbeded.setBody(jsonReq); 
            Http http = new Http(); 
            HTTPResponse res = http.send(reqEmbeded);
            system.debug('@@@@ res :: ' + res);
            return res;
     }
        return null;
    }

    public class DocuSignCustomSettings{
        String accountID;
        String userName;
        String passWord;
        String integratorKey;
        String returnUrl;
        String emailSubject;
        String restApiUri;
        String headerContent;
        String recipientAuthenticationMethod;
        String signHereAnchorString;
        String signHereAnchorXOffset;
        String signHereAnchorYOffset;
        String signHereName;
        String signHereXPosition;
        String signHereYPosition;

        public DocuSignCustomSettings(Map<String,string> mapOfTranslation){
            accountID = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_Acount_ID__c;
            integratorKey = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_IntegratorKey__c;
            //returnUrl = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_ReturnURL__c;
            emailSubject = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_EmailSubject__c;
            restApiUri = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_RESTAPIUrl__c;
            headerContent = mapOfTranslation.get('REN_LBL_DOCUSIGN_HEADER');
            recipientAuthenticationMethod = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_RecipientAuthenticationMethod__c;
            signHereAnchorString = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_SignHereAnchorString__c;
            signHereAnchorXOffset = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_SignHereAnchorXOffset__c;
            signHereAnchorYOffset = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_SignHereAnchorYOffset__c;
            signHereName =  mapOfTranslation.get('REN_LBL_DOCUSIGN_SIGN_HERE');
            signHereXPosition = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_SignHereXPosition__c;
            signHereYPosition = (String) REN_DocuSign_Config__c.getOrgDefaults().REN_SignHereYPosition__c;
        }

        public String checkConfig(){
            if(String.isBlank(accountID) || String.isBlank(integratorKey) || String.isBlank(emailSubject) ||
                    String.isBlank(headerContent) || String.isBlank(recipientAuthenticationMethod) || String.isBlank(signHereAnchorString) || String.isBlank(signHereAnchorXOffset) ||
                    String.isBlank(signHereAnchorYOffset) || String.isBlank(signHereName) ||
                    String.isBlank(signHereXPosition) || String.isBlank(signHereYPosition)){
                system.debug('/n/n @@ ConfigrationMissing' );
                return REN_DocuSignApiCall.STR_CONFIG_MISSING ;
            } 
            return null;
        }

		public String getAutoHeader(){
            system.debug('/n @@ invoking getAutoHeader');
            String headerStr;
            String userName = (String) SS_License__c.getOrgDefaults().REN_DocuSignUserName__c;
            String password = (String) SS_License__c.getOrgDefaults().REN_DocuSignPassword__c;
            
            if(!String.isBlank(integratorKey) && !String.isBlank(userName) && !String.isBlank(password)){
                headerStr = '<DocuSignCredentials><Username>'+ userName +'</Username><Password>'+ password +'</Password><IntegratorKey>'+integratorKey+'</IntegratorKey></DocuSignCredentials>';
            }
            system.debug('/n @@ invoking getAutoHeader ::  '+ headerStr);
            return headerStr; 
        }
    } // End of DocuSignCustomSettings class.
   
}