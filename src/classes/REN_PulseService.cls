/**
 * Created Date		: May 25, 2018
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: @description - Low Touch service for Session Expiration
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Tanvi										May 25, 2018			1.1			@description - Low Touch service for Session Expiration.
 *
 */
 public with sharing class REN_PulseService extends REN_JSONAPIBusinessLayer {
    
    public override String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad){
    	return null;
    }
    
    public override String getResponse(Set<String> paramSet) {
    	REN_JSONAPIPayLoad payLoadParent = new REN_JSONAPIPayLoad();
    	payLoadParent.status = 'SUCCESS';
    	system.debug('>>>JSON.serialize(payLoadParent) ::'+JSON.serialize(payLoadParent));
	   	return JSON.serialize(payLoadParent);
    }
}