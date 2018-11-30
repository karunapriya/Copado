/**
 * Created Date : Jan 9, 2017
 * Developed By : Nidhi.
 *
 * Function : REN_DocuSignDataSetup class is used for data-setup of request structure.This class is created for DocuSign functionality.
 * Support Email  : Nidhi@comitydesigns.com
 * Version : 1.0
 *
 * Modification Log
 *
 * Developer Name 	 	User Story  		Date 				Version 	 	Description
 *____________________________________________________________________________________________________
 *
 * Nidhi 				US2018 				Jan 9, 2017 		1.1 			@description
 * 
 */

public class REN_DocuSignDataSetup {

    public REN_DocuSignWrapper.InputWrapper inputWrapperObj;
    private string langCode;
    private Pagereference pageRef;
    public REN_DocuSignDataSetup (REN_DocuSignWrapper.InputWrapper obj, String langCode){
        inputWrapperObj = obj;
        this.langCode = langCode;
    }
    
    //@description : This method returns the JSON object to for envelope which includes details of Document,recipients etc.
    public String envelopeWrapper(){
        String emailSubject = 'Agreement' ;
        String emailBlurb ='Sending you this request for your electronic signature and enter or update confidential payment information.\n\nPlease review and electronically sign by following the link below. ';
        REN_DocuSignWrapper  envelopeWrapperObj = new REN_DocuSignWrapper ();
        envelopeWrapperObj.emailSubject = inputWrapperObj.emailSubject;
        envelopeWrapperObj.emailBlurb = inputWrapperObj.headerContent; 
        envelopeWrapperObj.envelopeIdStamping = 'false';
        envelopeWrapperObj.documents = createDocument();
        envelopeWrapperObj.recipients = createRecipients();
        envelopeWrapperObj.CustomFields = createCustomFields();
        envelopeWrapperObj.status = 'Sent';
        system.debug('\n\n check this string :: ' + JSON.serialize(envelopeWrapperObj));
        String jsonStr = JSON.serialize(envelopeWrapperObj);
        return jsonStr;
    }

    //@description : This method is used to create Document with the required attributes.
    public List<REN_DocuSignWrapper.Document> createDocument(){
        List<REN_DocuSignWrapper.Document> documentList = new List<REN_DocuSignWrapper.Document>();
        REN_DocuSignWrapper.Document documentObj = new REN_DocuSignWrapper.Document();
        documentObj.name = inputWrapperObj.DocumentName;
        documentObj.documentId = '1';
        documentObj.order = '1';
        documentObj.documentBase64 = 'Base64';
        documentObj.documentBase64 = EncodingUtil.base64Encode(inputWrapperObj.DocumentText);
        documentList.add(documentObj);
        return documentList;
    }

    //@description : This method is used to create Recipients with the required attributes.
    public REN_DocuSignWrapper.Recipients createRecipients(){
        REN_DocuSignWrapper.Recipients recipientsObj = new REN_DocuSignWrapper.Recipients();
        List<REN_DocuSignWrapper.Signer> signersList = new List<REN_DocuSignWrapper.Signer>();
        REN_DocuSignWrapper.Signer signerObj = new REN_DocuSignWrapper.Signer();
        signerObj.name = inputWrapperObj.userName;
        signerObj.email = inputWrapperObj.email;
        signerObj.ClientUserId = '1';
        signerObj.recipientId = '1';
        signerObj.Tabs = createTabs();
        signerObj.emailNotification = setLanguageCode();
        signersList.add(signerObj);
        recipientsObj.signers = signersList;
        return recipientsObj;
    }
    
    public REN_DocuSignWrapper.emailNotification  setLanguageCode(){
        REN_DocuSignWrapper.emailNotification emp= new REN_DocuSignWrapper.emailNotification();
        emp.supportedLanguage=langCode!=null?langCode.subString(0,2):'en';
        emp.emailSubject = inputWrapperObj.emailSubject;
        
        pageRef = Page.REN_LabelTranslatorPlaceholder;
        pageRef.getParameters().put('languageCode', langCode);
        REN_LabelTranslatorAPI tranlatorApi = new REN_LabelTranslatorAPI ();
        
        if(!test.isRunningTest()){
        	emp.emailBody= tranlatorApi.translatedLabelsMap(new set<Pagereference>{pageRef}).get('REN_LBL_DOCUSIGN_HEADER');
        } else {
        	emp.emailBody= 'test';
        }
        return emp;
    }
    
    //@description : This method is used to create tabs with the required attributes.
    public REN_DocuSignWrapper.Tabs createTabs(){
        REN_DocuSignWrapper.Tabs tabObj = new REN_DocuSignWrapper.Tabs();
        tabObj.signHereTabs = createSignHereTab();
        return tabObj;
    }
    
    //@description : This method is used to create SignHere tab with the required attributes.
    public List<REN_DocuSignWrapper.SignHereTab> createSignHereTab(){
        List<REN_DocuSignWrapper.SignHereTab> signHereTabList = new List<REN_DocuSignWrapper.SignHereTab>();
        REN_DocuSignWrapper.SignHereTab signHereTabObj = new REN_DocuSignWrapper.SignHereTab();
        signHereTabObj.documentId = '1';
        signHereTabObj.pageNumber = '1';
        signHereTabObj.recipientId = '1' ;
        signHereTabObj.name = inputWrapperObj.signHereName;
        signHereTabObj.xPosition = inputWrapperObj.signHereXPosition;
        signHereTabObj.yPosition = inputWrapperObj.signHereYPosition;
        signHereTabObj.anchorString = inputWrapperObj.signHereAnchorString;
        signHereTabObj.anchorXOffset = inputWrapperObj.signHereAnchorXOffset;
        signHereTabObj.anchorYOffset = inputWrapperObj.signHereAnchorYOffset;
        signHereTabList.add(signHereTabObj);
        return signHereTabList;
    }

    public REN_DocuSignWrapper.CustomFields createCustomFields() {
        REN_DocuSignWrapper.CustomFields customFieldsObj = new  REN_DocuSignWrapper.CustomFields();
        customFieldsObj.textCustomFields = createTextFields();
        return customFieldsObj;
    }
    
    //@description : This method is used for text field creation.
    public List<REN_DocuSignWrapper.TextCustomField> createTextFields(){
        List<REN_DocuSignWrapper.TextCustomField> customFieldList = new List<REN_DocuSignWrapper.TextCustomField>();
        REN_DocuSignWrapper.TextCustomField customFieldObj = new REN_DocuSignWrapper.TextCustomField();
        customFieldObj.fieldId = 'OppId';
        customFieldObj.name = 'DSFSSourceObjectId';
        customFieldObj.show = 'false';
        customFieldObj.value = inputWrapperObj.oppId;
        customFieldList.add(customFieldObj);
        return customFieldList;
    }

    //@description : This method is used for Recipent Authentication.
    public String getRecipentAuthentication(){
        REN_DocuSignWrapper.RecipentAuthentication recipentAuthObj = new REN_DocuSignWrapper.RecipentAuthentication();
        recipentAuthObj.authenticationInstant = string.valueof(system.now());
        recipentAuthObj.returnUrl = inputWrapperObj.returnUrl;
        recipentAuthObj.userName = inputWrapperObj.userName;
        recipentAuthObj.email = inputWrapperObj.email;
        recipentAuthObj.clientUserId = '1';
        recipentAuthObj.authenticationMethod = inputWrapperObj.recipientAuthenticationMethod;
        String jsonStr = JSON.serialize(recipentAuthObj);
        return jsonStr;
    }
}