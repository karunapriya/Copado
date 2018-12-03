/**
 * Created Date     : April 18, 2018
 * Developed By     : Rucha Palasapure, Comity Designs, Inc.
 *
 * Function         : @description - This class is used to handle get and post request for Quote Bulk Import service from Case.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log :
 *
 * Developer Name           User Story              Date            Version     Description
 *____________________________________________________________________________________________________
 *
 * Rucha Palasapure           US3344              April 18, 2018         1.0        description   
 *
 */

public with sharing class REN_BulkCasesService extends REN_JSONAPIBusinessLayer{
	
    	/* This method is used to handle GET response to fetch Quote details from Fieldset  */
	public override String getResponse(Set<String> oppIdSet){
		REN_JSONAPIPayLoad payLoadParent = REN_QuoteBulkImportHelper.getQuoteObjectMetaData(oppIdSet);
		system.debug('payLoadParent :: '+ JSON.serialize(payLoadParent));
		return JSON.serialize(payLoadParent);
	}
	
	/* This method is used to handle POST response for Quote which will create new Quote and QLIs */
	public override String postResponse(Set<String> caseIdSet, REN_JSONAPIPayLoad payLoad) {
		Set<String> oppIdSet = new Set<String>();   	
		List<String> caeFieldsList = new List<String>{'Opportunity__c','Status'};
     	List<sObject> caseList = CSM_CaseDataAccess.getCaseDetailsById(caseIdSet, caeFieldsList);   	
     	if(caseList != null && !caseList.isEmpty()){
     		if(CSM_AccessController.hasField('Case', CSM_Util.nameSpacePrefixSolnExtn + 'Opportunity__c')){
     			oppIdSet.add((Id)caseList[0].get(CSM_Util.nameSpacePrefixSolnExtn+'Opportunity__c')); 
     		}
     	}
     	REN_JSONAPIPayLoad payLoadObj = REN_QuoteBulkImportHelper.createQuoteAndQlis(payLoad, oppIdSet);
     	if(payLoadObj.status == 'SUCCESS'){
     		caseList[0].put('Status','Ready');
			CSM_CaseDataAccess.updateCases(caseList,caeFieldsList);
     	}
     	System.debug('payLoad ::' + JSON.serialize(payLoadObj));
     	return JSON.serialize(payLoadObj);
    }
	
}