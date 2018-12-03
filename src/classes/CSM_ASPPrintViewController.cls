public with sharing class CSM_ASPPrintViewController {

	public List<CSM_Account_Plan__c> acctPlanList{get;set;}
	public Boolean hasCSMAccess {get; private set;}
	public String aspId{get;set;}
	public CSM_ASPPrintViewController(ApexPages.StandardController stdController){
		try{
			this.aspId = stdController.getId();
			this.acctPlanList =  CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(this.aspId, null);
			hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled || SS_LicenseCheck.getInstance().isRenewEnabled;
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	}
}