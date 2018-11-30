/**
 * Created Date		: Jun 25, 2018
 * Developed By		: Smita, Comity Designs, Inc.
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
 * Smita					US3533				Jun 25, 2018			1.1					@description
 *
 */
public with sharing class REN_MessageWrapper {
	public  error error{get;set;}
    public class error{
    	public string code{get;set;}
        public String message{get;set;}
	} 
}