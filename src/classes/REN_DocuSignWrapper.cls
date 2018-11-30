/**
 * Created Date : Jan 9, 2017
 * Developed By : Nidhi.
 *
 * Function : This class is used for creating Request JSON. This class is created for DocuSign functionality.
 * Support Email  : Nidhi@comitydesigns.com
 * Version : 1.0
 *
 * Modification Log
 *
 * Developer Name User Story Date Version  Description
 *____________________________________________________________________________________________________
 *
 * Nidhi US2018 Jan 9, 2017 1.1 @description
 * 
 */
public with sharing class REN_DocuSignWrapper {
    public string emailSubject { get; set; }
    public string emailBlurb { get; set; }
    public string envelopeIdStamping { get; set; }
    public List<Document> documents { get; set; }
    public Recipients recipients { get; set; }
    public CustomFields CustomFields { get; set; }
    public string status { get; set; }

    public class Document{
        public string name { get; set; }
        public string documentId { get; set; }
        public string order { get; set; }
        public string documentBase64 { get; set; }
    }

    public class SignHereTab{
        public string documentId { get; set; }
        public string pageNumber { get; set; }
        public string recipientId { get; set; }
        public string name { get; set; }
        public string xPosition { get; set; }
        public string yPosition { get; set; }
        public string anchorString{ get; set; }
        public string anchorXOffset{ get; set; }
        public string anchorYOffset{ get; set; }
    }

    public class Tabs{
        public List<SignHereTab> signHereTabs { get; set; }
    }

    public class Signer{
        public string name { get; set; }
        public string email { get; set; }
        public string ClientUserId { get; set; }
        public string recipientId { get; set; }
        public Tabs Tabs { get; set; }
        public emailNotification emailNotification{get;set;}
    }

    public class Recipients{
        public List<Signer> signers { get; set; }
    }

    public class TextCustomField{
        public string fieldId;
        public string name;
        public string show;
        public string value;
    }

    public class CustomFields{
        public List<TextCustomField> textCustomFields;
    }

    /* This class is used for embedded flow for recipent authentication*/
    public class RecipentAuthentication{
        public string authenticationInstant;
        public string returnUrl;
        public string userName;
        public string email;
        public string clientUserId;
        public string authenticationMethod;
    }
    
    public class InputWrapper{
        public String email;
        public String userName;
        public String returnUrl;
        public String oppId;
        public String clientUserId;
        public Blob DocumentText;
        public String DocumentName; 
        public String emailSubject;
        public String headerContent;
        public String recipientAuthenticationMethod;
        public String signHereAnchorString;
        public String signHereAnchorXOffset;
        public String signHereAnchorYOffset;
        public String signHereName;
        public String signHereXPosition;
        public String signHereYPosition;       
        
    }
    
    public class emailNotification{
       public String supportedLanguage;
       public string emailSubject;
       public String emailBody;
    }
}