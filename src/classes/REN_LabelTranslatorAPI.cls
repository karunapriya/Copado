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
public with sharing class REN_LabelTranslatorAPI {

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	// MARK: Your method goes here
	
	public Map<String,String> translatedLabelsMap(Set<Pagereference> pageRefSet){
        String labelValue;
        Pagereference pageRef = (new List<Pagereference>(pageRefSet))[0];
        if(Test.isRunningTest()) {
        	labelValue = '97';	
        }else{
        	labelValue = pageRef.getContent().toString();	
        	system.debug('labelValue  ::'+labelValue);
        }
        system.debug('labelValue ::'+labelValue);
        String[] label;
        Map<String,String> mapOfLabels = new Map<String,String>();
        String[] labelList;
        if(pageRef.getAnchor() == 'REN_QuoteImportLabelTranslator'){
        	labelList = labelValue.split('#');	
        }else{
        	labelList = labelValue.split(';');	
        }
        
        system.debug('labelValue  : '+labelList.size());
        
        for(integer i=0; i<labelList.size();i++) {
        	if(labelList[i] != null && labelList[i].contains('=')) {
        		label = labelList[i].split('=');
        		//system.debug(label);
        		if(label != null) {
        			mapOfLabels.put(label[0].trim(),label[1]);
        		}
        	}
        }
        
        //system.debug('labelValue  : '+mapOfLabels);
        return mapOfLabels;
    }
}