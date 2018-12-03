public with sharing class CHL_SalesStageMappingDataAccess {
    public static List<CHL_Sales_Stage_Mapping__c> saveSalesStageMapping(List<CHL_Sales_Stage_Mapping__c> salesStageMappingList) {
	
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_FLD_MO_SALES_STAGE,
													CHL_CONSTANTS.OBJ_FLD_PO_SALES_STAGE,
													CHL_CONSTANTS.OBJ_FLD_PO_TYPE};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_SALES_STAGE_MAPPING, fcFieldList, CSM_Constants.DML_OPERATION_UPSERT);
		
		upsert salesStageMappingList;

		return salesStageMappingList;
	}
	public static List<CHL_Sales_Stage_Mapping__c> getSalesStageMapping() {
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_FLD_MO_SALES_STAGE,
													CHL_CONSTANTS.OBJ_FLD_PO_SALES_STAGE,
													CHL_CONSTANTS.OBJ_FLD_PO_TYPE};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_SALES_STAGE_MAPPING, fcFieldList, CSM_Constants.DML_OPERATION_READ);

		return [select Id, CHL_Master_Opportunity_Sales_Stage__c, CHL_Partner_Opportunity_Sales_Stage__c, CHL_Partner_Opportunity_Type__c from CHL_Sales_Stage_Mapping__c limit 1000];
	}
	public static void deleteSalesStageMapping(List<CHL_Sales_Stage_Mapping__c> salesStageMappingList) {
		List<String> fcFieldList = new List<String>{CHL_CONSTANTS.OBJ_FLD_MO_SALES_STAGE,
													CHL_CONSTANTS.OBJ_FLD_PO_SALES_STAGE,
													CHL_CONSTANTS.OBJ_FLD_PO_TYPE};
		
		CSM_Util.checkCRUD_FLS(CHL_CONSTANTS.OBJ_SALES_STAGE_MAPPING, fcFieldList, CSM_Constants.DML_OPERATION_DELETE);
		
		delete salesStageMappingList;
	}
}