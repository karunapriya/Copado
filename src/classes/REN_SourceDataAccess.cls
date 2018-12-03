public with sharing class REN_SourceDataAccess {
	
	public static void saveSourceRecords(List<REN_Source__c> sourceList){
		List<String> fieldList = new List<String>{'REN_Contributor__c', 'REN_Inheriting_Opportunity__c', 'REN_Reason__c', 'REN_Type__c'};
		if (CSM_AccessController.hasField('REN_Source__c', CSM_Util.nameSpacePrefix21 + 'REN_Contributor_SC__c')){
			fieldList.add(CSM_Util.nameSpacePrefix21 + 'REN_Contributor_SC__c');
		}
     	CSM_Util.checkCRUD_FLS('REN_Source__c', fieldList, CSM_Constants.DML_OPERATION_INSERT);
     	insert sourceList;
	}

    public static void deleteAllSources(List<REN_Source__c> sourceListToDelete){
		if(sourceListToDelete != null && !sourceListToDelete.isEmpty()){
	        CSM_Util.checkCRUD_FLS('REN_Source__c', null,CSM_Constants.DML_OPERATION_DELETE);
			delete sourceListToDelete;
		}
    }

}