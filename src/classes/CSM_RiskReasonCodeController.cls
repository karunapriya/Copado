public with sharing class CSM_RiskReasonCodeController {
	//private final Task taskObj;
	public List<SelectOption> riskReasonList {get; private set;}
	public CSM_RiskReasonCodeController(ApexPages.StandardController stdController) {
 		riskReasonList = CSM_AdminDataAccess.getObjectList(CSM_Constants.OBJ_LIST_RISK_REASON_COMBINED);
 		//this.taskObj = (Task)stdController.getRecord();
 	}   	
}