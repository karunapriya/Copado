/**
 * Created Date		: Apr 5, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: @description - This class will return all the lables required for LT.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Bhagyashri				US3240				Apr 5, 2018			1.1					This class will return all the lables required for LT.
 *
 */
public with sharing class REN_LowTouchLabelsService extends REN_LowTouchBusinessLayer {
	
	public override String postResponse(Set<String> oppIdSet, REN_LowTouchPayLoad payLoad){
    	return null;
    }
	
	/***This method will retuen JSON for all LT labels**/
	
	 public override String getResponse(Set<String> langCodeSet) {
	    REN_LowTouchPayLoad payLoadParent = new REN_LowTouchPayLoad();
	    payLoadParent.data = new List<REN_LowTouchPayLoad.mainData>();
	    String  langCode =(new List<String>(langCodeSet))[0];
	    system.debug('langCode ::'+langCode);
	    REN_LabelTranslatorAPI lblTranslator = new REN_LabelTranslatorAPI();
	    Map<String,String> translatedMap = lblTranslator.translatedLabelsMap(langCode);
	    REN_LowTouchPayLoad.mainData payLoad;
	    payLoad = new REN_LowTouchPayLoad.mainData();
		payLoad.type = 'label';
	    payLoad.Id = 'LABEL-ID';
		payload.attributes = translatedMap;
		payLoadParent.data.add(payLoad);
	    payLoadParent.action = 'GET';
	    payLoadParent.links = new Map<String, String>();
	    payLoadParent.links.put('Self','/labels');   	
	   	system.debug('>>>JSON.serialize(payLoadParent) ::'+JSON.serialize(payLoadParent));
	   	return JSON.serialize(payLoadParent);
		
	}

  
}