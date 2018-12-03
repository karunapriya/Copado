/**
 * Created Date		: Sep 6, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
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
 * Dilip					User Story				Sep 6, 2018			1.1					@description
 *
 */
public with sharing class REN_RSFieldOperatorDataAccess {
	public static List<REN_RS_Field_Operator__c> getRSFieldOperators(List<String> fieldsList, List<String> additionalFieldsList, List<String> whereConditionList){
        CSM_Util.checkCRUD_FLS('REN_RS_Field_Operator__c', fieldsList, CSM_Constants.DML_OPERATION_READ);
        
        if(additionalFieldsList != null && !additionalFieldsList.isEmpty()){
            fieldsList.addAll(additionalFieldsList);
        }
        
        String soqlStr = 'SELECT ' + String.join(fieldsList, ',') + ' FROM REN_RS_Field_Operator__c ' + whereConditionList[0];
        System.debug('***soqlStr ' + soqlStr);
        return Database.query(soqlStr);
    }    
}