/**
 * Created Date		: Feb 20, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Wrapper which gets values from share object
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					U2113				   	Feb 20, 2017	1.1					Added as part of 707
 *
 */
public with sharing class CSM_ShareWrapper {
	public String visibility{get;set;}
	public Set<String> shareIds {get;set;}
}