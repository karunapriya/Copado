/**
 * Created Date     : Jan 9, 2017 
 * Developed By     : Dheeraj, Comity Designs, Inc.
 *
 * Function         : @description - for LDT Lightning component action
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj S.                 US1970        Jan 9, 2017         1.1                 @description
 *
 */

public with sharing class REN_HandleOpportunityStageUpdate {
    
    public static final String COMMIT_LEVEL='Commit_Level__c';
    public static final String QUOTE_DELIVERED='Quote Delivered';
    public static final String NO_SERVICE = 'No Service';
    public static final String OBJ_OPP_QUOTE_NUMBER = 'LT_Synced_Quote_Number__c';
       
    @AuraEnabled
    public static Opportunity getOpportunity(Id oppId)
    {
        Opportunity op = REN_OpportunityDataAccess.getOpportunityDetailByIdWithSyncQuote(new List<String>{oppId}).get(0);
        if (op.IsClosed && (op.StageName != 'PO Received' && op.StageName != 'No Service')) {
             //isValid =false;   
             updateErrorLog(system.Label.REN_LT_CLOSED_OPPORTUNITY, Label.CHL_LBL_OPP_CLOSED, oppId); 
        }
        return op;
    }
    
    @AuraEnabled
    public static String getPaymentInfo(ID opportunityId, String langCode){ 
        SObject paymentObj = null;
        String nameSpaceOfAsperato = CSM_Util.nameSpaceOfAsperato;
        String returnStr = '';
        System.Savepoint sp;
        try{
            if(opportunityId == null){
                System.debug('\n\n~~~~~1: ');
            }else{
                if(CSM_AccessController.hasObject(nameSpaceOfAsperato + 'Payment__c')){
                    REN_Payment_Config__c paymentConfig = REN_Payment_Config__c.getOrgDefaults();
                    CSM_Admin__c lowTouchCS = CSM_Admin__c.getOrgDefaults();
                    paymentObj = CSM_AccessController.newSObject(nameSpaceOfAsperato + 'Payment__c');
                    if(CSM_AccessController.hasField(nameSpaceOfAsperato + 'Payment__c', 'REN_Opportunity__c')){
                        Opportunity oppRocord = (REN_OpportunityDataAccess.getOpportunityAllDetailsById(new List<String>{opportunityId + ''}))[0];
                        List<OpportunityContactRole> oppContactList = CSM_ContactDataAccess.getContactFromOpp(new Set<ID> {oppRocord.id});
                        String billingCountry = oppContactList != null && !oppContactList.isEmpty() && oppContactList[0].Contact.MailingCountry != '' && !String.isblank(oppContactList[0].Contact.MailingCountry) ? oppContactList[0].Contact.MailingCountry : 'United States';
                        String retUrl = lowTouchCS.REN_Low_Touch_User_URL__c  + 'home?renId=' + oppRocord.REN_Low_Touch_Renewal_Id__c ;
                        paymentObj.put('REN_Opportunity__c', oppRocord.id);
                        paymentObj.put(nameSpaceOfAsperato + 'Amount__c', oppRocord.Amount);
                        paymentObj.put(nameSpaceOfAsperato + 'Billing_Address_Country__c', billingCountry);
                        paymentObj.put(nameSpaceOfAsperato + 'Payment_Stage__c', paymentConfig.REN_Payment_Stage__c);
                        paymentObj.put(nameSpaceOfAsperato + 'Payment_Route_Options__c', paymentConfig.REN_Payment_Route_Options__c);
                        paymentObj.put(nameSpaceOfAsperato + 'Success_Endpoint__c', retUrl + '&pmt=s');
                        paymentObj.put(nameSpaceOfAsperato + 'Cancel_Endpoint__c', retUrl + '&pmt=c');
                        paymentObj.put(nameSpaceOfAsperato + 'Fail_Endpoint__c', retUrl + '&pmt=f');
                        //paymentObj.put(nameSpaceOfAsperato + 'Card_Type__c', 'Visa');
                        if (UserInfo.isMultiCurrencyOrganization()){
                            paymentObj.put('CurrencyIsoCode', oppRocord.get('CurrencyIsoCode'));
                        }
                        retUrl = langCode != null && langCode != '' ? retUrl + '&lang='+langCode : retUrl; 
                        if(paymentConfig.LT_Set_Contact_Info_by_default__c){
                            if(oppContactList != null && !oppContactList.isEmpty()){
                                 Contact cObj = oppContactList[0].Contact;
                                 //paymentObj.put(nameSpaceOfAsperato + 'Account_Name__c', cObj.Account.name);
                                 paymentObj.put(nameSpaceOfAsperato + 'Billing_Address_Street__c', cObj.MailingStreet);
                                 paymentObj.put(nameSpaceOfAsperato + 'Billing_Address_City__c', cObj.MailingCity);
                                 paymentObj.put(nameSpaceOfAsperato + 'Billing_Address_State__c', cObj.MailingState);
                                 paymentObj.put(nameSpaceOfAsperato + 'Billing_Address_Country__c', cObj.MailingCountry);
                                 paymentObj.put(nameSpaceOfAsperato + 'Billing_Address_PostalCode__c', cObj.MailingPostalCode);
                                 paymentObj.put(nameSpaceOfAsperato + 'Email__c', cObj.Email);
                                 paymentObj.put(nameSpaceOfAsperato + 'First_Name__c', cObj.FirstName);
                                 paymentObj.put(nameSpaceOfAsperato + 'Last_Name__c', cObj.LastName);
                            }
                        }
                        Set<String> fieldSetForCrudFLS = new Set<String>{};
                        List<sObject> paymentObjList = new List<sObject>{paymentObj};
                        sp = Database.setSavepoint();
                        REN_PaymentDataAccess.insertPaymentList(paymentObjList, fieldSetForCrudFLS);
                        Set<ID> paymentIdSet = new Set<ID>{paymentObj.id};
                        if(CSM_AccessController.hasField(nameSpaceOfAsperato + 'Payment__c', 'REN_Asperato_URL__c')){                           
                            fieldSetForCrudFLS.add('REN_Asperato_URL__c');
                            List<SObject> paymentList = REN_PaymentDataAccess.getPaymentList(paymentIdSet, fieldSetForCrudFLS);
                            paymentObj = (sObject)paymentList[0];
                            system.debug('paymentObj : '+paymentObj);
                        }   
                    }else{
                        System.debug('\n\n~~~~~2: ');                        
                        returnStr += system.Label.REN_LT_OPPORTUNITY_ERROR;
                        REN_HandleOpportunityStageUpdate.updateErrorLog(System.label.REN_PAY_VIA_CREDIT_CARD, system.Label.REN_LT_OPPORTUNITY_ERROR, opportunityId);
                    }
                }else{
                    System.debug('\n\n~~~~~3: ');
                    returnStr += system.Label.REN_LT_ASPERATO_PACKAGE_ERROR;
                    REN_HandleOpportunityStageUpdate.updateErrorLog(System.label.REN_PAY_VIA_CREDIT_CARD, system.Label.REN_LT_ASPERATO_PACKAGE_ERROR, opportunityId);
                 }
            }
        }catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            //returnStr += e.getMessage();
            returnStr = 'Exception';
            updateErrorLog(system.Label.REN_PAY_VIA_CREDIT_CARD, e.getMessage(), opportunityId);            
            Database.rollback(sp);
            return returnStr;
        }
        System.debug('\n\n~~~~~5: ' + returnStr);
       // returnStr = 'return';
        if(paymentObj != null && paymentObj.id != null ){
            if(CSM_AccessController.hasField(nameSpaceOfAsperato + 'Payment__c', 'REN_Asperato_URL__c')){
                returnStr = (String)paymentObj.get('REN_Asperato_URL__c');
                returnStr= langCode != '' && langCode.containsIgnoreCase('fr') ? returnStr + '&lang=FR' : returnStr; 
            } else {
                returnStr = 'Exception';
                REN_HandleOpportunityStageUpdate.updateErrorLog(System.label.REN_PAY_VIA_CREDIT_CARD, system.Label.REN_LT_ASPERATO_ERROR, opportunityId);
            }
        }
        return returnStr;
    }
    
    @AuraEnabled
    public static boolean updateOppStageOnLoad(Id oppId,String langCode,String source){
        try {
            List<String> opportunityFieldList = new List<String>{'REN_Primary_Contact__c','REN_LT_Renewal_Details__c',REN_Constants.OBJ_OPP_PROBABILITY,REN_Constants.OBJ_OPP_STAGE};
            CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_OPPORTUNITY, opportunityFieldList,CSM_Constants.DML_OPERATION_UPDATE);
            
            List<String> contactFieldList = new List<String>{'REN_Prefered_Language_Code__c','HasOptedOutOfEmail'};
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_CONTACT, contactFieldList,CSM_Constants.DML_OPERATION_UPDATE);
            
            System.debug('Opp Id'+ oppId);
            if(String.isNotBlank(oppId)){
                Opportunity op = REN_OpportunityDataAccess.getOpportunityDetailByIdWithSyncQuote(new List<String>{oppId},false).get(0);
                if(String.isBlank((String)op.get('syncedquoteid')) || (String)op.get('syncedquoteid') == null) {
                    updateErrorLog(system.Label.CHL_LBL_STAGE_ONLOAD, Label.REN_LT_SYNCED_QUOTE_ERR, oppId); 
                    return false;
                } else {
                    List<OpportunityContactRole> opptyRoleList = REN_OpportunityDataAccess.getPrimaryContacts(new set<String>{oppID});
                    if(!String.isNotEmpty(source)){
                        if(CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn+COMMIT_LEVEL)){
                            sObject obj = (sObject) op;
                            obj.put(CSM_Util.nameSpacePrefixSolnExtn+COMMIT_LEVEL, 'Red');
                            op = (Opportunity) obj;
                        }
                        op.StageName = QUOTE_DELIVERED;
                        OpportunityStage oppStage = REN_OpportunityDataAccess.getProbabilityValueByStage(QUOTE_DELIVERED);
                        op.Probability = oppStage.DefaultProbability;
                    }else if(source!=null && source.equals('unsubscribe')){
                        op.REN_LT_Renewal_Details__c='unsubscribed';
                    }
                    if(!opptyRoleList.isEmpty()){
                        op.REN_Primary_Contact__c = opptyRoleList[0].contactId;
                        Contact primaryContact = new Contact(Id=op.REN_Primary_Contact__c);
                        
                        if(source!=null && source.equals('unsubscribe')){
                            primaryContact.HasOptedOutOfEmail= true;
                        }
                        primaryContact.REN_Prefered_Language_Code__c = langCode != null && langCode != '' ?langCode : '';
                        system.debug('&&&  Update Primary Contact '+primaryContact);
                        update primaryContact;
                    }
                    update op;
                    return true;
                }
            }
        } catch(Exception e){
            System.debug('\n\n~~~~~4: ' + e);
            updateErrorLog(system.label.CHL_LBL_STAGE_ONLOAD, e.getMessage(), oppId);
           
        }
        return false;
    }
            
    @AuraEnabled
    public static boolean updateOppRejectStatus(Id oppId, String renStatus, String renOption){
        System.debug('Opp Id---'+ oppId);
        System.Savepoint sp;
        try {
            if(String.isNotBlank(oppId)){
              sp = Database.setSavepoint();
              Opportunity op = [Select id,StageName from opportunity where id =: oppId];              
              List<REN_Renews_To__c> rliListToUpdate = new List<REN_Renews_To__c>();
              List<REN_Renews_To__c> rliList = REN_RenewRelationshipDataAccess.getLstRenRelationshipByRenewalStatus(new List<Opportunity>{op});
              if(rliList != null && !rliList.isEmpty()) {
                  op.StageName = NO_SERVICE;              
                  OpportunityStage oppStage = REN_OpportunityDataAccess.getProbabilityValueByStage(NO_SERVICE);
                  op.Probability = oppStage.DefaultProbability;
                  op.REN_Notify_Opportunity_Owner__c  = true;
                  op.REN_LT_Renewal_Details__c = renOption;
                  //update op;
                  REN_OpportunityDataAccess.updateOpportunitySObject(new List<SObject>{op},new List<String>{'Probability','REN_Notify_Opportunity_Owner__c','REN_LT_Renewal_Details__c'});
                  for(REN_Renews_To__c rli : rliList){
                      rli.REN_Renewal_Status__c  = renStatus;
                      rliListToUpdate.add(rli);
                  }
                  if(rliListToUpdate.size()>0){
                      //update rliListToUpdate;
                      REN_RenewRelationshipDataAccess.updateRenewalRelationship(rliListToUpdate,new List<String>{'REN_Renewal_Status__c'});
                      List<OpportunityLineItem> optyLineItemListToUpdate = REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(new Set<String>{'OpportunityId','Id'} , new Set<String>{String.Valueof(oppId)});
                      REN_OpportunityLineItemRenewalHandler.resetOpportunityColumns(optyLineItemListToUpdate);
                  }
                  return true;
              } else {
                updateErrorLog(system.Label.REN_DO_NOT_RENEW, system.Label.REN_NO_RLI_OPP, oppId);
                return false;
              }
            }
        } catch(Exception e) {
            Database.rollback(sp);
            updateErrorLog(system.Label.REN_DO_NOT_RENEW, e.getMessage(), oppId);
           
        }
        return false;
    }
    
    @AuraEnabled
    public static string updatePOReceivedStatus(Id oppId){
        System.debug('Opp Id'+ oppId);
        try { 
            if(String.isNotBlank(oppId)){
               REN_DocuSignApiCall docuSignObj  = new REN_DocuSignApiCall();
               String urlToDocSign = docuSignObj.sendEnvelope(new set<Id>{oppId});
               return urlToDocSign;         
            }
        } catch(Exception e) {
            updateErrorLog('Docusign', e.getMessage(), oppId);
            return 'Exception';
         }
        return null;
    }
    
    @AuraEnabled
    public static string getQuotePDFContent(Id oppId) {
        String selOptionForDownload = CHL_Util.getQuotePDFOption();
        system.debug('selOptionForDownload :: '+selOptionForDownload);
        string pdflink = '';
        if(String.isNotBlank(selOptionForDownload) && selOptionForDownload.containsIgnoreCase(Label.CHL_LBL_ATTACHMENT)){
            List<Opportunity> lstOfOpp = REN_OpportunityDataAccess.getOpportunitySyncQuote(new Set<String>{oppId});
            Opportunity opp = lstOfOpp[0];

            if(CSM_AccessController.hasField('Opportunity', 'SyncedQuoteId')) {
                Id syncQuoteId = (Id)opp.get('SyncedQuoteId');
                List<sObject> lstOfAttch = CHL_AttachmentDataAccess.getAttachmentListByParentId(new Set<Id>{syncQuoteId},true);
                //system.debug('ATTACH ID :: '+lstOfAttch[0].get('Id')+':::'+lstOfAttch[0].get('ContentType'));
                pdflink = lstOfAttch  != null && !lstOfAttch.isEmpty()?'data:'+lstOfAttch[0].get('ContentType')+';base64,'+ EncodingUtil.Base64Encode((Blob) lstOfAttch[0].get('body')):'';
            }
           // pdflink = /servlet/servlet.FileDownload?file=
        }   else{
            List<sObject> quoteDocList = CHL_QuoteDataAccess.getSyncedQuotePDFByOpp(new set<ID>{oppId});//'006j000000WJJ2a'
            pdflink = quoteDocList != null && !quoteDocList.isEmpty()?'data:application/pdf;base64,'+ EncodingUtil.Base64Encode((Blob) quoteDocList[0].get('document')):'';
        }
        return pdflink;
    }
    
    @AuraEnabled
    public static List<REN_OpportunityWrapper> getOppDetail(Id oppId,Map<String,String> translatedValueMap){
        return REN_LowTouchAdminDataAccess.getOpportunityDetails(new List<String>{oppId},translatedValueMap);
    }
        
    @AuraEnabled
    public static string getPORejectOptionMap(){
        Map<String,String> mapofRejectOptions = new Map<String,String>();
        string nameSpacePrefix = CSM_Util.getNamespace();
        for(REN_Field_Mappings__c fmObj: REN_FieldMappingsDataAccess.getFieldMappingListByConfig(null,'RENEW_STATUS_FIELD')) {
            mapofRejectOptions.put(fmObj.REN_To_Field_API_Name__c, fmObj.REN_Default_Value__c);
        }
        system.debug('mapofRejectOptions' +mapofRejectOptions);
        return json.serialize(mapofRejectOptions);
    }
    
   @AuraEnabled
    public static List<REN_LT_RenewalConfirmationWrapper> getOppRecordDetails(String oppObjId, String paymentStatus){
    List<REN_LT_RenewalConfirmationWrapper> renObj = new List<REN_LT_RenewalConfirmationWrapper>();
    REN_LT_RenewalConfirmationWrapper renLtConfirmation = new REN_LT_RenewalConfirmationWrapper();
        //REN_LT_Synced_Quote_Number__c
    try {
        List<sObject> oppLst = REN_OpportunityDataAccess.getOpportunitySyncQuote(new set<String>{oppObjId});
        List<Opportunity> oppList = oppLst;//REN_OpportunityDataAccess.getOpportunitySyncQuote(new set<String>{oppObjId});
        if('s' == paymentStatus && !oppList.isEmpty() && !(oppList[0].isClosed || oppList[0].StageName == 'PO Received')){
            oppList[0].StageName = 'PO Received';           
            OpportunityStage oppStage = REN_OpportunityDataAccess.getProbabilityValueByStage('PO Received');
            oppList[0].Probability = oppStage.DefaultProbability;
            oppList[0].REN_Notify_Opportunity_Owner__c  = true;
            oppList[0].REN_LT_Renewal_Details__c = system.Label.REN_PAY_VIA_ASPERATO;
            if(CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn + COMMIT_LEVEL)){
                 oppList[0].put(CSM_Util.nameSpacePrefixSolnExtn + COMMIT_LEVEL, 'Yellow');
            }
            REN_OpportunityDataAccess.updateOpportunityforRenewals(oppList);
            CSM_CaseDataAccess.createBookingRequest(oppList[0].id);
         }
         renLtConfirmation.opportunityObj = (Opportunity)oppLst[0];
        
         if(CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefixSolnExtn+OBJ_OPP_QUOTE_NUMBER)){
              renLtConfirmation.FieldValue = (String)oppLst[0].get(CSM_Util.nameSpacePrefixSolnExtn+OBJ_OPP_QUOTE_NUMBER);
         }
         system.debug('renLtConfirmation---'+renLtConfirmation);
         renObj.add(renLtConfirmation);
         system.debug('renObj---'+renObj);
        
        
        system.debug('oppList--->'+oppList);
        return renObj;
        } catch(Exception e) {
            updateErrorLog(system.label.REN_LT_OPPORTUNITY_DETAILS, e.getMessage(), oppObjId);
            renObj = null;
            return renObj;
        }
    }
     @AuraEnabled
    public static REN_ToggleLowTouchConfiguration getLTConfiguration(){
        return REN_LowTouchAdminDataAccess.getLowTouchConfig();
    }
    
    @AuraEnabled
    public static string getClientName() {
        List<REN_Low_Dollar_Client__c> lowDollarClientList = REN_LowTouchAdminDataAccess.getLowTouchAdminRecords();
        String clientName = '';
        if(lowDollarClientList.size() == 1) {
            clientName = lowDollarClientList[0].name;
        }
        return clientName;
    }
    
    public static void updateErrorLog(String flow, String e, ID opportunityId) {
        REN_Error_Log__c errorLog = new REN_Error_Log__c();
        errorLog.REN_Error_Description__c = e;
        errorLog.REN_Flow__c = flow;
        errorLog.REN_OpportunityId__c = String.valueOf(opportunityId);
        REN_LT_ErrorLogDataAccess.insertErrorLog(new List<REN_Error_Log__c>{errorLog});
    }
}