/**
 * Created Date		: Jul 31, 2018
 * Developed By		: Tanvi, Comity Designs, Inc.
 *
 * Function			: Data Access Class for RS Language support Object
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Tanvi					US3643				Jul 31, 2018			1.1				Globalization support for Dell Automation
 *
 */
public with sharing class REN_RSLanguageSupportDataAccess {

    

    /**
	 * @description : Below Method will return Map of English string with corresponding translated String incolves in RS Feature.   
     */
	
	public static Map<String, String> getMapOfTranslatedStrings(Set<String> languageCodeSet, List<String> requestedFieldsList){
		CSM_Util.checkCRUD_FLS('REN_RS_Language_Support__c', requestedFieldsList, CSM_Constants.DML_OPERATION_READ);
		Map<String, String> translatedStringMap = new Map<String, String>();
		List<REN_RS_Language_Support__c> languageSupportList = new List<REN_RS_Language_Support__c>([SELECT REN_English_Text__c, REN_Language_Code__c, REN_Translated_Text__c, Id FROM REN_RS_Language_Support__c WHERE REN_Language_Code__c IN :languageCodeSet limit 10000]);
		for(REN_RS_Language_Support__c lang:languageSupportList) {
			translatedStringMap.put(lang.REN_English_Text__c, lang.REN_Translated_Text__c);
		}
		return translatedStringMap;
	}
}