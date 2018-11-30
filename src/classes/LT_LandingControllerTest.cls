/**
 * Created Date     : April 04, 2018
 * Developed By     : Nidhi, Comity Designs, Inc.
 *
 * Function         : Test Coverage for LT_LandingController and other related classes.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Nidhi                    US3309\US3314       April 04, 2018  1.1                 Added in sprint 755
**/
@isTest
public with sharing class LT_LandingControllerTest {
    
    @testSetup 
    static void setup() { 
        List<Account> accList = CSM_TestDataUtility.createAccount(1);
        system.assert(accList.get(0).Id != null);
        
        List<Contact> contList = CSM_TestDataUtility.createContacts(accList[0].Id,1);
        contList[0].REN_Prefered_Language_Code__c='en_US';
        contList[0].Email = 'test@test.com';
        update contList;
        
        Opportunity oppObj = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting',
                                    CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, 
                                    REN_Earliest_Expiration_Date__c = System.Today() + 2);
        insert oppObj;
        
        OpportunityContactRole objOppConRole=new OpportunityContactRole();
        objOppConRole.OpportunityId=oppObj.id;
        objOppConRole.ContactId=contList[0].Id;
        objOppConRole.IsPrimary=true;
        insert objOppConRole;
        
        Case caseObj = new Case();
        caseObj.AccountId = accList[0].Id;
        /*if (CSM_AccessController.hasField('Case', CSM_Util.nameSpacePrefixSolnExtn + 'Opportunity__c')){
            caseObj.put('Opportunity__c', oppObj.id);   
        }*/
        
        caseObj.ContactId = contList[0].Id;
        insert caseObj;
        
        List<REN_Field_Mappings__c> fieldMappingList = new List<REN_Field_Mappings__c>();
        fieldMappingList.add(REN_TestDataUtility.createFieldMapping('Test 1' ,'' ,'NS - Product Decommissioned - PPD' ,'' ,'' ,'RENEW_STATUS_FIELD' ,false ,'Product no longer in use'));
        fieldMappingList.add(REN_TestDataUtility.createFieldMapping('Test 2' ,'' ,'NS - Third Party Maintenance - SPM' ,'' ,'' ,'RENEW_STATUS_FIELD' ,false ,'Using 3rd Party Maintenance provider'));
        insert fieldMappingList;
        
        REN_Renews_To__c renRelationObj = new REN_Renews_To__c();
        renRelationObj.Name = 'Partner Renewal';
        renRelationObj.REN_Renews_To__c = oppObj.Id;
        renRelationObj.REN_Renewal_Status__c = 'Open';
        insert renRelationObj;
    }
    
    /***Start----- Test methods for LT landing ctrl**/
    //Test method for controller.
    static testmethod void testMethodCtrl(){
        REN_Low_Dollar_Client__c lowTouchData = new REN_Low_Dollar_Client__c();
        lowTouchData.REN_Low_Touch_Admin_URL__c='http://testUrl.com/';
        lowTouchData.REN_Docusign__c= true;
        lowTouchData.REN_Live_Agent__c = true;
        lowTouchData.REN_PO_Upload__c = true;  
        insert lowTouchData;
        LT_LandingController cntrl = new LT_LandingController();
        String locName = cntrl.locName;
        String lowTouchLogoURL = cntrl.lowTouchLogoURL;
        
        System.assert(lowTouchLogoURL != Null);
    }
    
    /*** Start --- Test methods for REN_LowTouchCasesService ****/
    
    //Test method of post request for case creation.
    static testmethod void testRequestPostMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue = '{"links": {"self": "/opportunity/'+ oppList[0].id+'/cases"},"data": [{"attributes": {"Subject": "subject","ContactId": "Laste","ContactEmail": "test@test.com","ContactPhone": "99999","ContactMobile": "9090909000"}}],"action": "POST"}';
        LT_LandingController.gateway(inputValue);
    }
    
    static testmethod void testRequestPostMethodForNewContactCreation(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue = '{"links": {"self": "/opportunity/'+ oppList[0].id+'/cases"},"data": [{"attributes": {"Subject": "subject","ContactId": "Laste","ContactEmail": "test1111@test.com","ContactPhone": "99999","ContactMobile": "9090909000"}}],"action": "POST"}';
        LT_LandingController.gateway(inputValue);
    }

    //Test method of get request to fetch contact details.
    static testmethod void testRequestGetMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue = '{"links":{"self":"/opportunity/'+ oppList[0].id+'/cases"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
    }
    
    /*** End --- Test methods for REN_LowTouchCasesService ****/
    
    /*** Start --- Test methods for REN_LowTouchOpportunitiesService ****/
    static testmethod void testOppPostMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue = '{"status":"SUCCESS","meta":{"definitions":{"opportunity":{"type":"object","title":"opportunity","required":[],"relationships":{"account":{"type":"object","title":"account","required":["name"],"relationships":null,"properties":{"name":{"type":"STRING","title":"Account Name","order":0,"display":"true","dbRequired":"true","apiName":"name"}}}},"properties":{"quoteNumber":{"type":"STRING","title":"quoteNumber","order":1,"display":"false","dbRequired":null,"apiName":null},"stagename":{"type":"STRING","title":"stagename","order":1,"display":"false","dbRequired":null,"apiName":null},"quote-link":{"type":"url","title":"quote-link","order":0,"display":"false","dbRequired":null,"apiName":null},"amount":{"type":"CURRENCY","title":"Amount","order":1,"display":"true","dbRequired":"false","apiName":"amount"}}}}},"links":{"self":"/opportunities/'+oppList[0].Id+'"},"included":[{"type":"account","relationships":null,"links":{"self":"/opportunity/006f100000cQKbPAAW/relationships/account"},"Id":"001j000000h5ueXAAQ","attributes":{"name":"Test Account_4Feb"}}],"errors":[],"data":[{"type":"opportunity","relationships":{"account":{"links":{"related":"/opportunity/006f100000cQKbPAAW/account","self":"/opportunity/006f100000cQKbPAAW/relationships/account"},"data":{"Id":"001j000000h5ueXAAQ","type":"account"}}},"links":{"self":"/opportunity/006f100000cQKbPAAW"},"Id":"006f100000cQKbPAAW","attributes":{"quoteLink":"https://tanvi-comity-dev-dev-ed.my.salesforce.com/secur/frontdoor.jsp?sid=00Dj0000000JSsz!AQQAQPltiCpT14iFkYnK3jTaKEy0hFmnvMTdPDTS6MV0XnJuj1_6m80bCsWiBIKZ7IBhugIybDwDNtFMZFQoePfVttlOOF11&retURL=https://tanvi-comity-dev-dev-ed.my.salesforce.com/sfc/servlet.shepherd/version/download/068f1000004Aa49AAC?asPdf=false","stageName":"PO_RECEIVED","quoteNumber":"00002429","stagename":"Quote Delivered","quote-link":"false","amount":"2001.00"}}],"action":"POST"}';
        LT_LandingController.gateway(inputValue);
        REN_JSONAPIPayLoad payLoad = (REN_JSONAPIPayLoad) JSON.deserialize(inputValue, REN_JSONAPIPayLoad.class);
        REN_LowTouchUtil.LowTouchWrapper ltWrapper = new REN_LowTouchUtil.LowTouchWrapper();
        ltWrapper.payLoad = payLoad;
        ltWrapper.langCode = 'en-US';
        ltWrapper.oppIdSet = new Set<Id>{oppList[0].Id};
        REN_LowTouchOpportunities.updateOppStageOnLoad(ltWrapper);
    }
    
    //Test method of post request for opportunity.
    static testmethod void testOppGetMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue = '{"links":{"self":"/opportunities/'+ oppList[0].id+'"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
    }
    
    /*** End --- Test methods for REN_LowTouchOpportunitiesService ****/
    
    /*** Start --- Test methods for REN_LowTouchReasonsService ****/
    //Test method of get request to fetch field mapping details.
    static testmethod void testReasonsGetMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue = '{"links":{"self":"/opportunity/'+oppList[0].id+'/reasons"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
    }
    
    //Test method of post request to update opportunity rejection status.
    static testmethod void testReasonsPostMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        List<REN_Field_Mappings__c> fieldMappingList = [select Id from REN_Field_Mappings__c limit 2];
        List<REN_Renews_To__c> rliList = [select Id, REN_Renewal_Status__c, REN_Renews_To__c from REN_Renews_To__c limit 1];
        system.assert(oppList != null);
        String inputValue = '{"status":null,"meta":{"definitions":{"ren_field_mappings__c":{"type":"object","title":"ren_field_mappings__c","required":[],"relationships":{},"properties":{"ren_to_field_api_name__c":{"type":"STRING","title":"To Field API Name","order":"2","display":"true","dbRequired":"false","apiName":"ren_to_field_api_name__c"},"ren_default_value__c":{"type":"STRING","title":"Default Value","order":"1","display":"true","dbRequired":"false","apiName":"ren_default_value__c"},"selected":{"type":"BOOLEAN","title":"selected","order":"0","display":"false","dbRequired":"false","apiName":"selected"}}}}},"links":{"self":"/opportunities/'+oppList[0].id+'/reasons"},"included":[],"errors":null,"data":[{"type":"ren_field_mappings__c","relationships":null,"links":{"self":"/ren_field_mappings__c/a0Qj000000Bz00iEAB"},"Id":"a0Qj000000Bz00iEAB","attributes":{"ren_to_field_api_name__c":"NS - Third Party Maintenance - SPM","ren_default_value__c":"Will Use 3rd Party Maintenance Provider","selected":"false"}},{"type":"ren_field_mappings__c","relationships":null,"links":{"self":"/ren_field_mappings__c/a0Qj000000Bz00jEAB"},"Id":"a0Qj000000Bz00jEAB","attributes":{"ren_to_field_api_name__c":"NS - Customer Cost-Benefit Decision - SCB","ren_default_value__c":"Customer Cost-Benefit Decision","selected":"false"}},{"type":"ren_field_mappings__c","relationships":null,"links":{"self":"/ren_field_mappings__c/a0Qj000000Bz00ZEAR"},"Id":"a0Qj000000Bz00ZEAR","attributes":{"ren_to_field_api_name__c":"NS - Other Data Management - RDM","ren_default_value__c":"Will Use Time & Materials","selected":"true"}},{"type":"ren_field_mappings__c","relationships":null,"links":{"self":"/ren_field_mappings__c/a0Qj000000Bz00YEAR"},"Id":"a0Qj000000Bz00YEAR","attributes":{"ren_to_field_api_name__c":"NS - Product Decommissioned - PPD","ren_default_value__c":"Product No longer in user","selected":"false"}},{"type":"ren_field_mappings__c","relationships":null,"links":{"self":"/ren_field_mappings__c/a0Qf100000DmXiBEAV"},"Id":"a0Qf100000DmXiBEAV","attributes":{"ren_to_field_api_name__c":"Lost","ren_default_value__c":"Product Not good","selected":"false"}}],"action":"POST"}';
        //String inputValue = '{"url":null,"status":null,"meta":{"definitions":{"ren_field_mappings__c":{"type":"object","title":"ren_field_mappings__c","required":[],"relationships":{},"properties":{"ren_to_field_api_name__c":{"type":"STRING","title":"To Field API Name","order":2,"display":true,"dbRequired":false,"apiName":"ren_to_field_api_name__c"},"ren_default_value__c":{"type":"STRING","title":"Default Value","order":1,"display":true,"dbRequired":false,"apiName":"ren_default_value__c"},"selected":{"type":"BOOLEAN","title":"selected","order":0,"display":false,"dbRequired":false,"apiName":"selected"}}}}},"links":null,"included":[],"errors":null,"error":null,"data":[{"type":"ren_field_mappings__c","relationships":null,"links":{"self":"/ren_field_mappings__c/'+fieldMappingList[0].Id+'"},"Id":"fieldMappingList[0].Id","attributes":{"ren_to_field_api_name__c":"NS - Product Decommissioned - PPD","ren_default_value__c":"Product no longer in use","selected":"false"}},{"type":"ren_field_mappings__c","relationships":null,"links":{"self":"/ren_field_mappings__c/'+fieldMappingList[1].Id+'"},"Id":"fieldMappingList[1].Id","attributes":{"ren_to_field_api_name__c":"NS - Third Party Maintenance - SPM","ren_default_value__c":"Using 3rd Party Maintenance provider","selected":"false"}}],"action":"POST"}';
        LT_LandingController.gateway(inputValue);
    }
    
    /*** End --- Test methods for REN_LowTouchReasonsService ****/
    
    /*** Start --- Test methods for REN_PaymentService ****/
    //Test method of post request for payment via credit card.
    static testmethod void testPaymentServiceGetMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        REN_PaymentsService paymentService = new REN_PaymentsService();
        paymentService.objectName = 'REN_Low_Touch_Payment__c';
        paymentService.getObjectAndAdditionalFields();
        //if(CSM_AccessController.hasObject('REN_Low_Touch_Payment__c')) {
            String inputValue ='{"links":{"self":"/opportunity/'+oppList[0].id+'/paymentmethods/cc"},"action":"GET"}';
            string gateway = LT_LandingController.gateway(inputValue);
        //}
        
    }
    
    //Test method of post request for payment via credit card.
    static testmethod void testPaymentServicePostMethod(){
        List<Opportunity> oppList = [select id, Amount from opportunity limit 1];
        string oppId = oppList[0].Id;
        system.assert(oppList != null);
        if(CSM_AccessController.hasObject('REN_Low_Touch_Payment__c')) {
            SObject paymentObj = CSM_AccessController.newSObject('REN_Low_Touch_Payment__c');
            paymentObj.put('REN_Status__c', 'Awaiting Submission');
            paymentObj.put('REN_Amount__c', oppList[0].Amount);
            paymentObj.put('REN_Opportunity__c', oppId);
            paymentObj.put('REN_Payment_Date__c', system.today());
            insert paymentObj;
            String queryString  = 'Select Id ,REN_Status__c from REN_Low_Touch_Payment__c where REN_Opportunity__c = : oppId ';
            List<sObject> paymentList = Database.query(queryString); 
            system.assert(oppList != null);
        }
            String inputValue ='{"links":{"self":"/opportunity/'+oppList[0].id+'/paymentmethods/cc"},"action":"POST"}';
            //String inputValue ='{ "status": "SUCCESS", "meta": { "definitions": { "ren_low_touch_payment__c": { "type": "object", "title": "ren_low_touch_payment__c", "required": [], "relationships": {}, "properties": { "ren_expiration__c": { "type": "STRING", "title": "Expiration", "order": 10, "display": "true", "dbRequired": "false", "apiName": "ren_expiration__c" }, "ren_cardholders_name__c": { "type": "STRING", "title": "Cardholders name", "order": 9, "display": "true", "dbRequired": "false", "apiName": "ren_cardholders_name__c" }, "ren_card_number__c": { "type": "STRING", "title": "Card number", "order": 8, "display": "true", "dbRequired": "false", "apiName": "ren_card_number__c" }, "ren_cvv__c": { "type": "STRING", "title": "CVV", "order": 7, "display": "true", "dbRequired": "false", "apiName": "ren_cvv__c" }, "ren_last_name__c": { "type": "TEXTAREA", "title": "Last Name", "order": 6, "display": "true", "dbRequired": "false", "apiName": "ren_last_name__c" }, "ren_first_name__c": { "type": "TEXTAREA", "title": "First Name", "order": 5, "display": "true", "dbRequired": "false", "apiName": "ren_first_name__c" }, "ren_billing_address_street__c": { "type": "TEXTAREA", "title": "Billing Address Street", "order": 4, "display": "true", "dbRequired": "false", "apiName": "ren_billing_address_street__c" }, "ren_billing_address_state__c": { "type": "STRING", "title": "Billing Address State", "order": 3, "display": "true", "dbRequired": "false", "apiName": "ren_billing_address_state__c" }, "ren_billing_address_postalcode__c": { "type": "STRING", "title": "Billing Address PostalCode", "order": 2, "display": "true", "dbRequired": "false", "apiName": "ren_billing_address_postalcode__c" }, "ren_billing_address_country__c": { "type": "STRING", "title": "Billing Address Country", "order": 1, "display": "true", "dbRequired": "false", "apiName": "ren_billing_address_country__c" }, "ren_billing_address_city__c": { "type": "STRING", "title": "Billing Address City", "order": 0, "display": "true", "dbRequired": "false", "apiName": "ren_billing_address_city__c" } } } } }, "links": { "self": "/opportunities'+ oppList[0].id +'paymentmethods/cc" }, "included": [], "errors": null, "data": [{ "type": "ren_low_touch_payment__c", "relationships": null, "links": { "self": "/ren_low_touch_payment__c/paymentList[0].Id" }, "Id": "paymentList[0].Id", "attributes": { "ren_expiration__c": null, "ren_cardholders_name__c": null, "ren_card_number__c": "123456789", "ren_cvv__c": "123", "ren_last_name__c": "bhagyashri", "ren_first_name__c": "jadhav", "ren_billing_address_street__c": null, "ren_billing_address_state__c": null, "ren_billing_address_postalcode__c": null, "ren_billing_address_country__c": "India", "ren_billing_address_city__c": "pune" } }], "action": "POST" }';
            LT_LandingController.gateway(inputValue);
        //}
    }
    
    /*** End --- Test methods for REN_PaymentService ****/
    
    /*** Start --- Test methods for REN_LowTouchReasonsService ****/
    static testmethod void testLabelsGetMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue = '{"links":{"self":"/opportunity/'+oppList[0].id+'/labels/de"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
    }
    /*** End --- Test methods for REN_LowTouchReasonsService ****/
    
    /*** Start --- Test methods for REN_LowTouchPaymentMethodsService ****/
    static testmethod void testPaymentMethodsGetMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue = '{"links":{"self":"/opportunity/'+oppList[0].id+'/paymentmethods"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
    }
    /*** End --- Test methods for REN_LowTouchPaymentMethodsService ****/
    
    /*** Start --- Test methods for REN_DocuSignService ****/
    
    //Test method of post request for docusign.
    static testmethod void testDocuSignServiceGetMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue ='{"links":{"self":"/opportunity/'+oppList[0].id+'/paymentmethods/ds"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
    }
    
    //Test method of post request for docusign.
    static testmethod void testDocuSignServicePostMethod(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue ='{"links":{"self":"/opportunity/'+oppList[0].id+'/paymentmethods/ds"},"action":"POST"}';
        LT_LandingController.gateway(inputValue);
    }
    /*** End --- Test methods for REN_DocuSignService ****/
    
    //For Unsubscribe Flow
    static testmethod void testContactsGETMethod(){
        List<Contact> conList = [select id,HasOptedOutOfEmail from contact limit 1];
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue ='{"links":{"self":"/opportunity/'+oppList[0].id+'/contacts"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
        System.assert(inputValue.contains(oppList[0].id));
    }
    static testmethod void testContactsGET_NegativeMethod(){
        List<Account> accList = [select id from Account limit 1];
        Opportunity oppObj = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting',
                                    CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, 
                                    REN_Earliest_Expiration_Date__c = System.Today() + 2);
        insert oppObj;
        system.assert(oppObj != null);
        String inputValue ='{"links":{"self":"/opportunity/'+oppObj.id+'/contacts"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
        inputValue = '{"status":"SUCCESS","meta":null,"links":{"self":"/opportunities/'+oppObj.Id+'/contacts"},"included":null,"errors":null,"data":[{"type":"Contact","relationships":null,"links":null,"Id":"003f1000021NHLJAA4","attributes":{"unsubscribed":"true","phone":null,"email":"tanvi@comitydesigns.com","name":"Test Contact4Feb"}}],"action":"POST"}';
        LT_LandingController.gateway(inputValue);
    }
    
    //For Unsubscribe Flow
    static testmethod void testContactsPOSTMethod(){
        List<Contact> conList = [select id,HasOptedOutOfEmail from contact limit 1];
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue = '{"status":"SUCCESS","meta":null,"links":{"self":"/opportunities/'+oppList[0].Id+'/contacts"},"included":null,"errors":null,"data":[{"type":"Contact","relationships":null,"links":null,"Id":"003f1000021NHLJAA4","attributes":{"unsubscribed":"true","phone":null,"email":"tanvi@comitydesigns.com","name":"Test Contact4Feb"}}],"action":"POST"}';
        LT_LandingController.gateway(inputValue);
    }
    
    static testmethod void testPulseGET(){
        String inputValue ='{"action": "GET", "links":{"self":"/pulse"}}';
        LT_LandingController.gateway(inputValue);
        System.assert(inputValue != Null);
    }
    static testmethod void testOliGET(){
        REN_Low_Dollar_Client__c lowTouchData = new REN_Low_Dollar_Client__c();
        lowTouchData.REN_Low_Touch_Admin_URL__c='http://testUrl.com/';
        lowTouchData.REN_Docusign__c= true;
        lowTouchData.REN_Live_Agent__c = true;
        lowtouchData.REN_Expose_OLI__c = true;
        lowTouchData.REN_PO_Upload__c = true;  
        insert lowTouchData;
        List<Account> accList = [select id from Account limit 1];
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        CSM_Admin__c oliLimitSetting = CSM_Admin__c.getOrgDefaults();
        oliLimitSetting.REN_Low_Touch_OLI_Limit__c = 10;
        String inputValue ='{"links":{"self":"/opportunity/'+oppList[0].id+'/Olis"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
        System.assert(inputValue != Null);
    }
    
    static testmethod void testLanguage(){
        REN_LT_Active_Languages__c activeLang = new REN_LT_Active_Languages__c();
        activeLang.REN_LT_Language_Code__c = 'fr';
        activeLang.REN_LT_Language_Native_Value__c = 'français';
        activeLang.Name = 'French';
        insert activeLang;
        List<Account> accList = [select id from Account limit 1];
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue ='{"links":{"self":"/opportunity/'+oppList[0].id+'/languages"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
        System.assert(inputValue != Null);
    }
    
    static testmethod void testLanguage_Negative(){
        
        List<Account> accList = [select id from Account limit 1];
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue ='{"links":{"self":"/opportunity/'+oppList[0].id+'/languages"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
        System.assert(inputValue != Null);
    }
    
    static testmethod void testLabelsGetMethod_importquotes(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        String inputValue = '{"links":{"self":"/opportunity/importquotes/labels/de"},"action":"GET"}';
        LT_LandingController.gateway(inputValue);
    }
    
    static testmethod void testEmailTemplate(){
        List<Opportunity> oppList = [select id from opportunity limit 1];
        system.assert(oppList != null);
        REN_LT_EmailTemplateController emailCtrl = new REN_LT_EmailTemplateController();
        emailCtrl.OpptId = oppList[0].Id;
        emailCtrl.oppty = oppList[0];
        emailCtrl.orderNumber = '1234';
    }
    
    static testmethod void test_Paymentdataaccess(){
        List<Opportunity> oppList = [select Id, name from opportunity limit 1];
        List<Account> accList = [select Id from account limit 1];
        Opportunity oppObj = new Opportunity(Name = 'TestOpp', StageName = 'Prospecting',
                                    CloseDate = System.Today(), AccountId = accList.get(0).Id, Type = 'New Customer', Amount = 100, Probability = 90, 
                                    REN_Earliest_Expiration_Date__c = System.Today() + 2);
        REN_PaymentDataAccess.insertLowTouchPaymentList('Opportunity',new List<sObject>{oppObj}, new Set<String>{'Name'});        
        REN_PaymentDataAccess.getLowTouchPaymentList('Opportunity',new Set<Id>{oppList[0].Id}, new Set<String>{'Name'});
        REN_PaymentDataAccess.updateLowtouchPaymentList('Opportunity',oppList, new Set<String>{'Name'});   
        system.assert(oppList != null);
    }
    
}