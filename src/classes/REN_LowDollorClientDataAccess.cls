/**
 * Created Date		: Jan 13, 2017
 * Developed By		: Tanvi, Comity Designs, Inc.
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
 * Tanvi					User Story				Jan 13, 2017			1.1					@description
 *
 */
public with sharing class REN_LowDollorClientDataAccess {

    

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	// MARK: Your method goes here
	
	public static List<REN_Low_Dollar_Client__c> getLowDollarClientDetails() {
        //List<String> lowdollarclientFields = new List<String>{};
        //CSM_Util.checkCRUD_FLS('REN_Low_Dollar_Client__c', lowdollarclientFields, 'Read'); 
       return [Select Id, name,REN_Logo_URL__c from REN_Low_Dollar_Client__c limit 1];
    }
	
	
}