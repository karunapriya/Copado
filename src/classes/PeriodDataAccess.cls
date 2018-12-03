/**
 * @author       Nikita Konkar (nikita@comitydesigns.com)    
 * @date         08/24/2016
 * @description  Period Data Access class
 */
public with sharing class PeriodDataAccess {
	
	public static Map<Id, Period__c> getPeriodRecordsById(Set<String> periodIds){
		String namespace = Util.solnExtnNameSpace;
		List<String> periodFieldList = new List<String>{namespace + Constants.PERIOD_START_DATE, 
			namespace + Constants.PERIOD_END_DATE};
		Util.checkCRUD_FLS(Constants.OBJ_PERIOD, periodFieldList, Constants.DML_OPERATION_READ);
		return new Map<Id, Period__c>([SELECT Period_Start_Date__c, Period_End_Date__c FROM Period__c WHERE Id IN :periodIds limit 50000]);
	}
    
}