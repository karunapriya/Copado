public with sharing class CSM_AccountSuccessPlanController
{
    public Boolean hasCSMAccess {get; private set;}
    public Boolean hasRenewAccess {get; private set;}
    public CSM_Account_Plan__c acctPlan {get; set;}
    public Integer selectedTab {get; set;}
    public String helpParam {get; set;} 
    public List<liValues> liList {get; private set;}
    public String aspPrintURL {get; private set;}
    public Boolean isEntitlementEnabled{get;set;}
    public CSM_AccountSuccessPlanController (ApexPages.StandardController stdController)
    {
        try
        {
        	this.isEntitlementEnabled = CSM_AccessController.hasObject(REN_Constants.OBJ_SERVICECONTRACT);
            hasCSMAccess = SS_LicenseCheck.getInstance().isCSMEnabled;
            hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
            System.debug('hasRenewAccess - '+hasRenewAccess);
            liList = new List<liValues>();
            liList.add(new liValues('#actions', Label.CSM_LBL_ACTIONS, 'Actions'));
            liList.add(new liValues('#activityStream', Label.CSM_LBL_ACTIVITY_STREAM, 'ActivityStream'));
            liList.add(new liValues('#playBooks', Label.CSM_LBL_PLAYBOOKS, 'Playbooks'));
            if (hasCSMAccess){
            	liList.add(new liValues('#usage', Label.CSM_LBL_USAGE, 'Usage'));
            }
            if (hasRenewAccess){
            	liList.add(new liValues('#assets', Label.REN_LBL_ASSETS, 'Assets'));
            	if(this.isEntitlementEnabled){
	            	liList.add(new liValues('#serviceContracts', 'Service Contracts', 'SC'));
            	}
            }
            liList.add(new liValues('#details', Label.CSM_LBL_DETAILS, 'Details'));
            helpParam = CSM_Constants.HELP_SUCCESS_PLAN_DETAILS;
            String accountId = ApexPages.currentPage().getParameters().get(CSM_Constants.OBJ_T_ACCOUNTID);
            String id = ApexPages.currentPage().getParameters().get(CSM_Constants.OBJ_IG_ID);
            String selectedTabString = ApexPages.currentPage().getParameters().get(CSM_Constants.SELECTED_TAB);
            
            if (String.isBlank(selectedTabString)){
                selectedTab = CSM_AdminDataAccess.getAccountPlanSelectedTab();
            }
            else
            {
            	selectedTab = Integer.valueOf(selectedTabString);
            }
            if (accountId!=null || id != null){
                List<CSM_Account_Plan__c> acctPlanList =  CSM_AccountPlanDataAccess.getAccountPlanByIdOrAccount(id, accountId);
                if (acctPlanList!=null && !acctPlanList.isEmpty()){
                    this.acctPlan = acctPlanList[0];
                } else {
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.CSM_MSG_SUCCESS_PLAN_NOT_ASSOCIATED_TO_ACCOUNT));
                }
            } else {
                this.acctPlan = (CSM_Account_Plan__c)stdController.getRecord();    
            }
            PageReference aspPrintPageRef = Page.CSM_ASPPrintView;
        	aspPrintURL = aspPrintPageRef.getURL();
        	if (this.acctPlan!=null){
        		aspPrintPageRef.getParameters().put(CSM_Constants.ID_PARAM, this.acctPlan.id);
        		aspPrintURL = aspPrintPageRef.getUrl();
        	}
        	
        }
        catch (Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }
    }
    
    public class liValues {
    	public String linkValue {get; set;}
    	public String linkDescValue {get; set;}
    	public String linkInternalValue{get;set;}
    	public liValues(String liValue, String liDescValue, String linkInternalValue){
    		linkValue = liValue;
    		linkDescValue = liDescValue;
    		this.linkInternalValue = linkInternalValue;
    	}
    }
    
    public String packageVersion {
		get {
			if(String.isBlank(packageVersion)) {
				packageVersion = CSM_Util.getPackageVersion();
			}
			return packageVersion;
		} set;
	}
    
    public String scoutUrl {
		get {
			if(String.isBlank(scoutUrl)) {
				scoutUrl = CSM_Util.getScoutAnalyticsUrl();
			}
			return scoutUrl;
		} set;
	}

    
}