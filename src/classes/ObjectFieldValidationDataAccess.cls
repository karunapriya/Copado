public with sharing class ObjectFieldValidationDataAccess{

    public List<Object_Field_Validation__c> getRecordsByObjectName(String objApiName){
    	String namespace = Util.solnExtnNameSpace;
        List<String> allAccessibleFields = new List<String>{namespace+'Object_API_Name__c',namespace+'Field_API_Name__c',namespace+'isActive__c'};
        Util.checkCRUD_FLS('Object_Field_Validation__c', allAccessibleFields , Constants.DML_OPERATION_READ);
        return [SELECT Object_API_Name__c, Field_API_Name__c, isActive__c from Object_Field_Validation__c where Object_API_Name__c = :objApiName AND  isActive__c = true];
	}                
}