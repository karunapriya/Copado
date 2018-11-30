/**
 * Created Date		: Feb 23, 2017
 * Developed By		: Chandra, Comity Designs, Inc.
 *
 * Function			: @description - Payment Data Access class
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Chandra					User Story				Feb 23, 2017			1.1					@description
 *
*/
public with sharing class REN_PaymentDataAccess {


    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
      */
	// TODO: Your method goes here
	
	/*public static void insertPaymentList(List<sObject> paymentList, Set<String> fieldSetForCrudFLS){
		String nameSpaceOfAsperato = CSM_Util.nameSpaceOfAsperato;
     	CSM_Util.checkCRUD_FlsPermissions(nameSpaceOfAsperato + 'Payment__c', fieldSetForCrudFLS, CSM_Constants.DML_OPERATION_INSERT);
     	
     	insert paymentList;
	}

    public static List<sObject> getPaymentList(Set<ID> paymentIdSet, Set<String> paymentObjectFieldSet){
    	String nameSpaceOfAsperato = CSM_Util.nameSpaceOfAsperato;
    	paymentObjectFieldSet.add('Id');     	
     	CSM_Util.checkCRUD_FlsPermissions(CSM_Util.nameSpaceOfAsperato + 'Payment__c', paymentObjectFieldSet, CSM_Constants.DML_OPERATION_READ);
		String soql = 'Select ' + String.join(new List<String>(paymentObjectFieldSet), ',') + ' FROM ' + nameSpaceOfAsperato + 'Payment__c' + ' WHERE id in : paymentIdSet';
		system.debug('soql : ' + soql);
		return Database.query(soql);
    }*/
    
   public static List<Sobject> insertLowTouchPaymentList(String objectName, List<sObject> paymentList, Set<String> fieldSetForCrudFLS){
     	CSM_Util.checkCRUD_FlsPermissions(objectName, fieldSetForCrudFLS, CSM_Constants.DML_OPERATION_INSERT);
     	if(!paymentList.IsEmpty()){	
     		insert paymentList;	
     	}
     	return paymentList;
	}
	
	public static List<Sobject> getLowTouchPaymentList(String objectName, Set<ID> paymentIdSet, Set<String> paymentObjectFieldSet){
		CSM_Util.checkCRUD_FlsPermissions(objectName, paymentObjectFieldSet, CSM_Constants.DML_OPERATION_READ);
		String queryString = CSM_Util.getSOQLString(objectName, paymentObjectFieldSet, 'Id IN:paymentIdSet', null, null);
		return Database.query(queryString);
	}
	
	public static List<Sobject> updateLowtouchPaymentList(String objectName, List<sObject> paymentList, Set<String> fieldSetForCrudFLS){
     	CSM_Util.checkCRUD_FlsPermissions(objectName, fieldSetForCrudFLS, CSM_Constants.DML_OPERATION_INSERT);
     	if(!paymentList.IsEmpty()){
     		update paymentList;	
     	}
     	return paymentList;
	}

}