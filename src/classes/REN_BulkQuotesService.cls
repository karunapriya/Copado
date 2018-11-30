/**
 * Created Date     : April 18, 2018
 * Developed By     : Rucha Palasapure, Comity Designs, Inc.
 *
 * Function         : @description - This class is used to handle get and post request for Quote Bulk Import service from Opportunity.
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

public with sharing class REN_BulkQuotesService extends REN_JSONAPIBusinessLayer {
    
	/* This method is used to handle GET response to fetch Quote details from Fieldset */
	
	public override String getResponse(Set<String> oppIdSet){
		REN_JSONAPIPayLoad payLoadParent = REN_QuoteImportHelper.getQuoteObjectMetaData(oppIdSet);
		system.debug('payLoadParent :: '+ JSON.serialize(payLoadParent));
		return JSON.serialize(payLoadParent);
	}
	
	
	/* This method is used to handle POST response for Quote which will create new Quote and QLIs */
	
	public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad) {
     	REN_JSONAPIPayLoad payLoadObj = REN_QuoteImportHelper.createQuoteAndQlis(payLoad, oppIdSet);
     	System.debug('payLoad :: ' + JSON.serialize(payLoadObj));
     	return JSON.serialize(payLoadObj);
    }
}