public with sharing class CSM_SCOUTCanvasComponentCtrl {

	private List<SObject> acctList;
	public Boolean SCOUTExist {get; set;}
	public String acctId {get; set;}
	public String errorMessage{get;set;}
	
	public CSM_SCOUTCanvasComponentCtrl(){
		//this.SCOUTExist = true;
	}
	
	public Component.Apex.CanvasApp getTheCanvas(){
		this.SCOUTExist = true;		
		return checkIfAppsInstalled();
    }
    
    @TestVisible
    private List<SObject> getAccountList(Boolean loadVersion2) {
    	List<SObject> sobjList;
    	try {
    		
			//in cases when acctId is not being set until this point
			if (this.acctId == null) {
				this.acctId = ApexPages.currentPage().getParameters().get(CSM_Constants.OBJ_T_ACCOUNTID);
			}
			if (this.acctId == null) {
           		String id = ApexPages.currentPage().getParameters().get(CSM_Constants.OBJ_IG_ID);
           		
				List<CSM_Account_Plan__c> acctPlanList =  CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(id, '');
				CSM_Account_Plan__c acctPlan;
	           	if (acctPlanList!=null && !acctPlanList.isEmpty()){
	               	this.acctId = acctPlanList[0].CSM_AccountId__c;
	           	}           		
    		}
           	    		
    		String soql;
    		if (loadVersion2){
    			sobjList = CSM_ScoutDataAccess.getScoutCustomerList(new set<Id>{this.acctId});
    		} else {
    			sobjList = CSM_ScoutDataAccess.getScoutAccountList(new set<Id>{this.acctId});
    		}
    	} catch (Exception ex) {
    		this.SCOUTExist = false;
    	}
    	return sobjList;
    }
    
    public PageReference refreshSCOUT() {
    	return null;
    }
    
    @TestVisible
    private Component.Apex.CanvasApp checkIfAppsInstalled(){
    	Component.Apex.CanvasApp canvasApp;
    	this.errorMessage = null;
    	if(CSM_AdminDataAccess.isRLVersion2CanvasAppSelected()){
    		if(CSM_AccessController.hasObject(CSM_Constants.OBJ_SA_SREV_CUSTOMER)){
    			canvasApp = this.createCanvasAppComponent(true);
    			this.SCOUTExist = this.errorMessage == null;
    		}else if(CSM_AccessController.hasObject(CSM_Constants.OBJ_SA_SACF)){
    			this.errorMessage = system.label.CSM_CANVAS_APP_2_NOT_AVAILABLE;
    			this.SCOUTExist = false;
    		}else{
    			this.SCOUTExist = false;
    		}
    	}else{
    		if(CSM_AccessController.hasObject(CSM_Constants.OBJ_SA_SACF)){
    			canvasApp = this.createCanvasAppComponent(false);
    			this.SCOUTExist = this.errorMessage == null;
    		}else if(CSM_AccessController.hasObject(CSM_Constants.OBJ_SA_SREV_CUSTOMER)){
    			this.errorMessage = system.label.CSM_CANVAS_APP_1_NOT_AVAILABLE;
    			this.SCOUTExist = false;
    		}else{
    			this.SCOUTExist = false;
    		}
    	}
       	return canvasApp;
	}
	
	@TestVisible
	private Component.Apex.CanvasApp createCanvasAppComponent(Boolean loadVersion2){
		Component.Apex.CanvasApp canvasApp = new Component.Apex.CanvasApp();
    	canvasApp.width = '100%';
    	canvasApp.height = '800';
    	canvasApp.scrolling = 'yes';
		if(loadVersion2){
			canvasApp.namespacePrefix = 'ScoutForSREV';
	    	canvasApp.applicationName ='Scout_By_ServiceSource_UI';
	    	List<SObject> acctList = this.getAccountList(true);

	    	if(this.SCOUTExist && acctList != null && !acctList.isEmpty()){
	    		if (acctList[0].get('ScoutForSREV__Customer_Instance_Code__c')!=null && acctList[0].get('ScoutForSREV__Customer_Reference_Id__c')!=null){
		    		canvasApp.parameters = '{ instance: \'' + acctList[0].get('ScoutForSREV__Customer_Instance_Code__c')+ '\', entity: \'organization\', externalid: \'' + acctList[0].get('ScoutForSREV__Customer_Reference_Id__c') + '\', report: \'OrganizationDetailCustomerSummary\'}';
	    		} else {
	    			this.errorMessage = system.label.CSM_LBL_SCOUT_SREV_FIELD_NULL_MSG;
	    		}
	    	} else {
	    		this.errorMessage = system.label.CSM_LBL_SCOUT_SREV_FIELD_NOT_ACCESSIBLE_MSG;
	    	}
		}else{
			canvasApp.namespacePrefix = 'ScoutAnalytics';
	    	canvasApp.applicationName ='Optimizer_Detail';
	    	List<SObject> acctList = this.getAccountList(false);
	    	if(this.SCOUTExist && acctList != null && !acctList.isEmpty()){
	    		if (acctList[0].get('ScoutAnalytics__CustomerInstanceCode__c')!=null && acctList[0].get('ScoutAnalytics__Businessunit_did__c')!=null){
	    			canvasApp.parameters = '{ instance: \'' + acctList[0].get('ScoutAnalytics__CustomerInstanceCode__c')+ '\', entity: \'organization\', did: \'' + acctList[0].get('ScoutAnalytics__Businessunit_did__c') + '\', externalid: \'' + acctList[0].get('ID') + '\', report: \'OrganizationDetailCustomerSummary\'}';
	    		} else {
	    			this.errorMessage = system.label.CSM_LBL_SCOUT_ANALYTICS_FIELD_NULL_MSG;
	    		}
	    	} else {
	    		this.errorMessage = system.label.CSM_LBL_SCOUT_ANALYTICS_FIELD_NOT_ACCESSIBLE_MSG;
	    	}
		}
		return canvasApp;
	}
}