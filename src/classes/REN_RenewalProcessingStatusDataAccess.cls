/**
 * Created Date		: Sep 1, 2016
 * Developed By		: admin, Comity Designs, Inc.
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
 * admin					User Story				Sep 1, 2016			1.1					@description
 *
 */
public with sharing class REN_RenewalProcessingStatusDataAccess {
	
	private static final Boolean entitlementPkgInstalled = CSM_AccessController.hasField(
														REN_Constants.OBJ_OPPORTUNITY, 
														CSM_Util.nameSpacePrefix21+REN_Constants.OBJ_OPP_APPEND_SERV_CONTRACT);
    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	public static void saveProcessingStatusRecords(List<REN_Renewal_Processing_Status__c> processingStatusList){
		List<String> fieldList = new List<String>{'REN_Source_Opportunity__c', 'REN_Renewal_Opportunity__c', 'REN_Source_for_Renewed_Opportunity__c'};
		if(entitlementPkgInstalled){
			fieldList.add(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c');
			fieldList.add(CSM_Util.nameSpacePrefix21 + 'REN_Source_for_Service_Contract__c');
		}
		
     	CSM_Util.checkCRUD_FLS('REN_Renewal_Processing_Status__c', fieldList, CSM_Constants.DML_OPERATION_INSERT);
     	insert processingStatusList;
	}

	public static void updatProcessingStatusRecords(List<REN_Renewal_Processing_Status__c> processingStatusList){
		List<String> fieldList = new List<String>{'REN_Failed__c', 'REN_Failure_Msg__c', 'REN_Source_for_Renewed_Opportunity__c'};
		if(entitlementPkgInstalled){
			fieldList.add(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c');
			fieldList.add(CSM_Util.nameSpacePrefix21 + 'REN_Source_for_Service_Contract__c');
		}
     	CSM_Util.checkCRUD_FLS('REN_Renewal_Processing_Status__c', fieldList, CSM_Constants.DML_OPERATION_UPDATE);
     	update processingStatusList;
	}
	
    public static List<REN_Renewal_Processing_Status__c> getRecordsByIds(Set<ID> processedRpsIdSet){
    	List<REN_Renewal_Processing_Status__c> recordList = new List<REN_Renewal_Processing_Status__c>();
		if(processedRpsIdSet != null && !processedRpsIdSet.isEmpty()){
			String queryString = 'Select r.REN_Source_Opportunity__c, r.REN_Source_Opportunity__r.REN_Append_Renewal_Opportunity__c, r.REN_OLIs_Qualified__c, r.REN_Assets_Qualified__c, r.REN_CLIs_Qualified__c, r.REN_Renewal_Opportunity__c, r.Id, r.REN_Source_for_Renewed_Opportunity__c '
				+ (CSM_AccessController.hasField('Opportunity', CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c') ? (', r.REN_Source_Opportunity__r.' + CSM_Util.nameSpacePrefix21 + 'REN_Append_Service_Contract__c') : '')
				+ (CSM_AccessController.hasField('REN_Renewal_Processing_Status__c', CSM_Util.nameSpacePrefix21 + 'REN_Source_for_Service_Contract__c') ? (', r.' + CSM_Util.nameSpacePrefix21 + 'REN_Source_for_Service_Contract__c') : '')
				+ (CSM_AccessController.hasField('REN_Renewal_Processing_Status__c', CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c') ? (', r.' + CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c') : '')
				+ ', r.REN_RLIs_Qualified_Asset__c, r.REN_RLIs_Qualified_CLI__c'
				+ ' From REN_Renewal_Processing_Status__c r ' 
				+ ' WHERE id in :processedRpsIdSet';
			List<String> fieldList = new List<String>{'REN_Source_Opportunity__c', 'REN_Renewal_Opportunity__c', 'REN_Source_for_Renewed_Opportunity__c'};
			if(entitlementPkgInstalled){
				fieldList.add(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c');
				fieldList.add(CSM_Util.nameSpacePrefix21 + 'REN_Source_for_Service_Contract__c');
			}
			CSM_Util.checkCRUD_FLS('REN_Renewal_Processing_Status__c', fieldList, CSM_Constants.DML_OPERATION_READ);
			recordList = Database.query(queryString);
		}
		return recordList;
    }
	
    public static void deleteAllRPS(List<REN_Renewal_Processing_Status__c> listToDelete){
		if(listToDelete != null && !listToDelete.isEmpty()){
	        CSM_Util.checkCRUD_FLS('REN_Renewal_Processing_Status__c', null,CSM_Constants.DML_OPERATION_DELETE);
			delete listToDelete;
		}
    }
	public static List<REN_Renewal_Processing_Status__c> getProcessingStatusByIds(Set<Id> arpIds){
		List<String> fieldList = new List<String>{'REN_Source_Opportunity__c', 'REN_Renewal_Opportunity__c'};
		if(entitlementPkgInstalled){
			fieldList.add(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c');
		}
	    CSM_Util.checkCRUD_FLS('REN_Renewal_Processing_Status__c', fieldList, CSM_Constants.DML_OPERATION_READ);
		String commaSeparatedFields = String.join(fieldList, ',');
		String soql = 'Select ' + commaSeparatedFields + ' FROM REN_Renewal_Processing_Status__c where id in :arpIds';
		return Database.query(soql);
    }
    
	public static List<REN_Renewal_Processing_Status__c> getCompletedProcessingStatusByIds(Set<Id> arpIds){
		List<String> fieldList = new List<String>{'REN_Renewal_Opportunity__c'};
	    CSM_Util.checkCRUD_FLS('REN_Renewal_Processing_Status__c', fieldList, CSM_Constants.DML_OPERATION_READ);
		return [select REN_Renewal_Opportunity__c, REN_Renewal_Opportunity__r.id from REN_Renewal_Processing_Status__c where ID in :arpIds AND REN_Is_Renewal_Completed__c = true AND REN_Renewal_Opportunity__c != null];
    }
    
    /**
    * @description : This  method that can be used for obtaining the Renewal Processing Status as per the where clause.
    * @param Where clause as String
    * @param List of Renewal Processing Status.
    */
	public static List<REN_Renewal_Processing_Status__c> getProcessingStatusRecByCondition(String whereClauseStr){
		List<String> fieldList = new List<String>{'REN_Source_Opportunity__c','REN_Assets_Created__c','REN_Assets_Qualified__c', 'REN_CLIs_Qualified__c','REN_No_of_failure_line_items__c',
												'REN_OLIs_Created__c','REN_RLIs_Created_for_Asset__c','REN_RLIs_Created_for_CLI__c','REN_RLIs_Qualified_Asset__c','REN_RLIs_Qualified_CLI__c','REN_Failure_Msg__c',
												'REN_Is_Renewal_Completed__c','REN_Renewal_Opportunity__c','REN_OLIs_Qualified__c','REN_CLIs_Created__c'};
		if(entitlementPkgInstalled){
			fieldList.add(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c');
		}
     	CSM_Util.checkCRUD_FLS('REN_Renewal_Processing_Status__c', fieldList, CSM_Constants.DML_OPERATION_READ);
     	List<REN_Renewal_Processing_Status__c> renProcessingList = new List<REN_Renewal_Processing_Status__c>();
     	Integer recLimit = CSM_AdminDataAccess.getRecLimit(REN_Constants.REC_LIMIT_AUTOMATED_GENRATION_LOG_GRID);
     	String queryString = 'Select id,Name,REN_Source_Opportunity__c,REN_Source_Opportunity__r.name,REN_Renewal_Opportunity__r.name,REN_Assets_Created__c,REN_Assets_Qualified__c ,REN_CLIs_Qualified__c,REN_CLIs_Created__c,REN_No_of_failure_line_items__c,REN_OLIs_Created__c,REN_RLIs_Created_for_Asset__c,REN_RLIs_Created_for_CLI__c,REN_RLIs_Qualified_Asset__c,REN_RLIs_Qualified_CLI__c,REN_Failure_Msg__c,';
     	if(entitlementPkgInstalled){
			queryString += CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c, ';
		}
     	queryString += 'REN_Is_Renewal_Completed__c,REN_Renewal_Opportunity__c,REN_OLIs_Qualified__c  from REN_Renewal_Processing_Status__c ' + whereClauseStr + ' order by CreatedDate desc limit ' +recLimit;
     	renProcessingList =  Database.query(queryString);
     	return renProcessingList; 
	}
	
	public static List<REN_Renewal_Processing_Status__c> getProcessingStatusRecBySourceOppId(Set<Id> sourceOppId){
		List<String> fieldList = new List<String>{'REN_Source_Opportunity__c','REN_Assets_Created__c','REN_Assets_Qualified__c', 'REN_CLIs_Qualified__c','REN_No_of_failure_line_items__c',
												'REN_OLIs_Created__c','REN_RLIs_Created_for_Asset__c','REN_RLIs_Created_for_CLI__c','REN_RLIs_Qualified_Asset__c','REN_RLIs_Qualified_CLI__c','REN_Failure_Msg__c',
												'REN_Is_Renewal_Completed__c','REN_Renewal_Opportunity__c','REN_OLIs_Qualified__c','REN_CLIs_Created__c'};
		if(entitlementPkgInstalled){
			fieldList.add(CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c');
		}
     	CSM_Util.checkCRUD_FLS('REN_Renewal_Processing_Status__c', fieldList, CSM_Constants.DML_OPERATION_READ);
     	List<REN_Renewal_Processing_Status__c> renProcessingList = new List<REN_Renewal_Processing_Status__c>();
     	//Integer recLimit = CSM_AdminDataAccess.getRecLimit(REN_Constants.REC_LIMIT_AUTOMATED_GENRATION_LOG_GRID);
     	String queryString = 'Select id,Name,REN_Source_Opportunity__c,REN_Source_Opportunity__r.name,REN_Renewal_Opportunity__r.name,REN_Assets_Created__c,REN_Assets_Qualified__c ,REN_CLIs_Qualified__c,REN_CLIs_Created__c,REN_No_of_failure_line_items__c,REN_OLIs_Created__c,REN_RLIs_Created_for_Asset__c,REN_RLIs_Created_for_CLI__c,REN_RLIs_Qualified_Asset__c,REN_RLIs_Qualified_CLI__c,REN_Failure_Msg__c,';
     	if(entitlementPkgInstalled){
			queryString += CSM_Util.nameSpacePrefix21 + 'REN_Service_Contract__c, ';
		}
     	queryString += 'REN_Is_Renewal_Completed__c,REN_Renewal_Opportunity__c,REN_OLIs_Qualified__c  from REN_Renewal_Processing_Status__c WHERE REN_Source_Opportunity__c IN: sourceOppId  order by CreatedDate';
     	renProcessingList =  Database.query(queryString);
     	return renProcessingList; 
	}
}