/**
 * @author       Eswar Bala (eswar@comitydesigns.com)    
 * @date         05/25/2016
 * @description  utility class
 */
public with sharing class Util {
    
    private static String NAME_SPACE_CLASS_NAME = '';
    private static Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = new Map<String, Schema.Sobjecttype>();     
    private static ApexClass cs;
    private static Map<String, Decimal> CONVERSION_RATE = new Map<String, Decimal>();
    
    //todo: remove the dupe here.
    public static String solnExtnNameSpace{
        get {
            if (solnExtnNameSpace==null){
                solnExtnNameSpace = '';
                try{
                    List<ApexClass> tr =[select NamespacePrefix from ApexClass where Name = 'QuoteFxConversionHandler'];
                    if (tr!=null && !tr.isEmpty()){
                        solnExtnNameSpace = (String.isNotBlank(tr[0].nameSpacePrefix) ?  tr[0].nameSpacePrefix + '__' :  '');
                    }
                } catch(Exception ex) {
                    
                }
            }
            return solnExtnNameSpace;
        }
        private set;
    }
    
    public static String baseNameSpace{
        get {
            if (baseNameSpace==null){
                baseNameSpace = '';
                try{
                    List<ApexClass> cls =[select NamespacePrefix from ApexClass where Name = 'CSM_CaseTriggerHandler'];
                    if (cls!=null && !cls.isEmpty()){
                        baseNameSpace = (String.isNotBlank(cls[0].nameSpacePrefix) ?  cls[0].nameSpacePrefix + '__' :  '');
                    }
                } catch(Exception ex) {
                    
                }
            }
            return baseNameSpace;
        }
        private set;
    }
    
    public static void checkCRUD_FLS(String objectApiName, List<String> fieldListForCRUD, String dmlOperationType) {
        List<String> noAccessFieldList = AccessController.getInstance().returnNoPermissionFieldsNameList(objectApiName, dmlOperationType, fieldListForCRUD);
        system.debug('\n\n @@@ noAccessFieldList :: ' + noAccessFieldList);
        if (!noAccessFieldList.isEmpty()){   
             throw new AccessController.AccessControlDmlException( String.format(
                System.Label.LBL_OBJECT_NOT_ACCESSIBLE, new String[] {objectApiName + ':'+String.valueOf(noAccessFieldList)}));
        }
    }
    

    
    public static Long defaultDifferentInMin(Id bhId, Datetime startDateTime, Datetime endDateTime){
        //BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        Long differentInMilisecond = BusinessHours.diff(bhId, startDateTime, endDateTime);
        Long differentInMinute = differentInMilisecond / (1000 * 60);
        return differentInMinute;
    }

    public static void setErrorInObjects (List<sObject> objList, Exception ex){
        String errorMsg = ex.getMessage();
        system.debug(Logginglevel.ERROR, errorMsg +'\n\n~~~~ Exception:' + ex.getStackTraceString());
        
        for (Integer i = 0; i < objList.size(); i++){
            objList[i].addError(errorMsg);
        } 
    }
    
   
    //Added for US2683
    public static List<SObject> getOpptyLineItemsById(Set<Id> optyLineItemIdSet, Set<String> queryFields, Set<String> crudFLSFlds){
        List<SObject> oliList; 
        String nameSpace = solnExtnNameSpace;
        Set<String> fieldSet = new Set<String>();
        if(queryFields != null && !queryFields.isEmpty()){
            String fieldName = '';
            for(String queryField : queryFields) {
                if(queryField.startsWith(nameSpace)) {
                    fieldName = queryField.removeStart(nameSpace);
                } else {
                    fieldName = queryField;
                }
                fieldSet.add(fieldName.toLowerCase());
            }
        }
        oliList = DynamicObjectDataAccess.getObjectListBySetInWhereClause(fieldSet, 'OpportunityLineItem', optyLineItemIdSet, crudFLSFlds);
        return oliList;  
    }  
    
    //Added for US2683
    public static void updateSObject(String objectName, List<SObject> sObjectToUpdate, List<String> sObjFieldList) {
        checkCRUD_FLS(objectName, sObjFieldList, Constants.DML_OPERATION_UPDATE);
         if(!sObjectToUpdate.isEmpty()) {        
             update sObjectToUpdate;
         }
    }
    // US2725 
    public static Integer getCustomListSetting(String batchName) {
		Integer batchSize;
		Map<String, CSM_Batch_Job_Config__c> batchJobConfigMap = CSM_Batch_Job_Config__c.getAll();
		if(batchJobConfigMap != null && batchJobConfigMap.containsKey(batchName)) {
			batchSize = (Integer)batchJobConfigMap.get(batchName).CSM_Batch_Size__c;
		}
		return batchSize;
	}
	//Added for US2773
	public static Set<String> convertCSVtoSet(String csvValue, String delimitedStr){
		Set<String> strSet = new Set<String>();
		if(String.isNotBlank(csvValue)){
			List<String> sList = csvValue.split(delimitedStr);
			for(String s:sList){
		    	strSet.add(s.trim());
		    }
		}
		return strSet;
	}
    
}