/**
 * Created Date     : Apr 19, 2018
 * Developed By     : Bhagyashri, Comity Designs, Inc.
 *
 * Function         : @description - This class will return all the lables required for LT.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Bhagyashri                   US3240              Apr 19, 2018            1.1     This class will return all the lables required for LT.
 *
 */
public with sharing class REN_LabelsService extends REN_JSONAPIBusinessLayer {
    
    public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
        return null;
    }
    
    /***This method will retuen JSON for all LT labels**/
    
     public override String getResponse(Set<String> paramSet) {
        REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
        payLoadParent.data = new List<REN_JSONAPIPayLoad.mainData>();
        String inputParam = (new List<String>(paramSet))[0];
        String[] inputParamsArray = inputParam.contains(':') ? inputParam.split(':') : null ;
        system.debug('>>inputParamsArray  :: '+inputParamsArray);
        String langCode = inputParamsArray != null ? inputParamsArray[1] : 'en-US';
        String opptyId = inputParamsArray != null ? inputParamsArray[0] : '';
        System.debug('langCode : '+langCode+'::opptyId::'+opptyId);
        String labelValue;
        payLoadParent.status = 'SUCCESS';
        Pagereference pageRef;
        payLoadParent.links = new Map<String, String>();
        if(opptyId == 'importquotes'){
            pageRef = Page.REN_QuoteImportLabelTranslator;
            pageRef.setAnchor('REN_QuoteImportLabelTranslator');
            payLoadParent.links.put('self','/importquotes/labels');
        }else{
            pageRef = Page.REN_LabelTranslatorPlaceholder;
            payLoadParent.links.put('self','/labels');
            payLoadParent = updateContactLanguage(payLoadParent, new set<String>{opptyId}, new set<String>{langCode});
        }
        pageRef.getParameters().put('languageCode', langCode);
        REN_LabelTranslatorAPI lblTranslator = new REN_LabelTranslatorAPI();
        Map<String,String> translatedMap = lblTranslator.translatedLabelsMap(new set<Pagereference>{pageRef});
        
        REN_JSONAPIPayLoad.mainData payLoad;
        payLoad = new REN_JSONAPIPayLoad.mainData();
        payLoad.type = 'labels';
        payLoad.Id = 'labels';
        payload.attributes = translatedMap;
        payLoadParent.data.add(payLoad);
        payLoadParent.action = 'GET';
        System.debug('payLoad >>>> ' + JSON.serialize(payLoad));
        return JSON.serialize(payLoadParent);
    }

    public REN_JSONAPIPayLoad updateContactLanguage(REN_JSONAPIPayLoad payLoadParent, Set<String> oppIdSet, Set<String> langCodeSet) {
        String opptyId = (new List<String>(oppIdSet))[0];
        String langCode = (new List<String>(langCodeSet))[0];
        Savepoint sp = Database.setSavepoint();
        List<REN_JSONAPIPayLoad.Error> errorList = new List<REN_JSONAPIPayLoad.Error>();
        try {
            if(String.isNotBlank(opptyId))  {
                List<OpportunityContactRole> opptyRoleList = REN_OpportunityDataAccess.getPrimaryContacts(oppIdSet);
                Contact primaryContact ;
                if(!opptyRoleList.isEmpty() && opptyRoleList != null){
                    primaryContact = new Contact(Id=opptyRoleList[0].contactId);
                    primaryContact.REN_Prefered_Language_Code__c = String.isNotBlank(langCode) ? langCode : '';
                    List<String> contactFieldList = new List<String>{'REN_Prefered_Language_Code__c','HasOptedOutOfEmail'};
                    CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_CONTACT, contactFieldList,CSM_Constants.DML_OPERATION_UPDATE);         
                    CSM_ContactDataAccess.updateContact(new List<contact>{primaryContact}, new List<String>{'Id','REN_Prefered_Language_Code__c'});
                }             
            } else {
                payLoadParent.status = 'ERROR';
                errorList.add(new REN_LowTouchUtil().createErrorList('ERROR', system.Label.CHL_LBL_STAGE_ONLOAD, 'ERROR', system.Label.CHL_LBL_STAGE_ONLOAD));
                REN_LowTouchUtil.updateErrorLog(system.label.CHL_LBL_STAGE_ONLOAD, system.Label.CHL_LBL_STAGE_ONLOAD, opptyId);
                payLoadParent.errors = errorList;
            }
            //payLoadParent.errors = errorList;
        }   catch(Exception e){
            Database.rollback(sp);
            payLoadParent.status = 'ERROR';
            errorList.add(new REN_LowTouchUtil().createErrorList('Exception', system.Label.CHL_LBL_STAGE_ONLOAD, 'Exception occured', e.getMessage()));
            REN_LowTouchUtil.updateErrorLog(system.label.CHL_LBL_STAGE_ONLOAD, e.getMessage(), opptyId);
            payLoadParent.errors = errorList;
        }
        return payLoadParent;
    }
    
  
}