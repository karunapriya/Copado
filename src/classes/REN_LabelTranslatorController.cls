/**
 * Created Date		: May 31, 2017
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
 * Tanvi					User Story				May 31, 2017			1.1					@description
 * 
 */
public with sharing class REN_LabelTranslatorController {

    public String labelCode {get;set;}
    public String languageCode {get;set;}
    public List<Schema.FieldSetMember> fieldSetList{get;set;}
    private Map<String, Schema.FieldSet> quoteFsMap;
    
    public REN_LabelTranslatorController() {
	    
		fieldSetList = new List <Schema.FieldSetMember>();
		if(CSM_AccessController.hasObject('Quote')){
			Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
			Schema.DescribeSObjectResult res = globalDescribe.get('Quote').getDescribe();
	    	quoteFsMap = res.fieldSets.getMap();		
		}
	    if(quoteFsMap.containsKey(CSM_Util.nameSpacePrefixSolnExtn + 'REN_Quote_Fields_for_Bulk_Import')){
	   		fieldSetList = 	CHL_Util.getFieldSet(CSM_Util.nameSpacePrefixSolnExtn + 'REN_Quote_Fields_for_Bulk_Import', 'Quote');
	   	}
		Map<String, String> reqParams = ApexPages.currentPage().getParameters(); 
       	labelCode = reqParams.get('labelCode');
       	languageCode = reqParams.get('languageCode');
	}

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	// MARK: Your method goes here
}