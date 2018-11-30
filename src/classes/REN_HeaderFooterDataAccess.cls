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
public with sharing class REN_HeaderFooterDataAccess {

    

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	// MARK: Your method goes here
	
	public static List<REN_Header_Footer_Links__c> getLinksBasedOnType(String strLinkType,String lang_Param) { 
    	list<REN_Header_Footer_Links__c> objLinks= [SELECT Name, REN_Link__c,REN_Language__c FROM REN_Header_Footer_Links__c WHERE REN_Link_Type__c =: strLinkType AND (REN_Language__c=:lang_Param OR REN_Language__c=:null) order by REN_Link_Order__c limit 100];
       	list<REN_Header_Footer_Links__c> objLinksToShow=new list<REN_Header_Footer_Links__c>();
        for(REN_Header_Footer_Links__c objLink:objLinks){           
        	if(String.isNotBlank(objLink.REN_Language__c))
            {
                objLinksToShow.add(objLink);
            }
        }
        return objLinksToShow != null && !objLinksToShow.isEmpty() ? objLinksToShow : objLinks;
    }    
}