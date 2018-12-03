/**
 * Created Date		: Apr 19, 2018
 * Developed By		: Bhagyashri, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Bhagyashri					User Story				Apr 19, 2018			1.1					@description
 *
 */
public with sharing abstract class REN_JSONAPIBusinessLayer {
	public abstract String getResponse(Set<String> oppIdSet);
	public abstract String postResponse(Set<String> oppIdSet, REN_JSONAPIPayLoad payLoad);
}