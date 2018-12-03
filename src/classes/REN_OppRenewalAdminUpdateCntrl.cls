public with sharing class REN_OppRenewalAdminUpdateCntrl extends REN_BaseGrandParentController{
	
	 public Boolean hasRenewAccess {
        get;
        private set;
    }
    public Boolean theLinksAreVisible {
        get;
        private set;
    }
    public String helpParam {
        get;
        set;
    }
     public String CorpCurrencyCode{get;set;}
    
    
    public String tabCategory {get; set;} 

    public REN_OppRenewalAdminUpdateCntrl() {
        super();
        this.theLinksAreVisible = true;
        CorpCurrencyCode=CSM_Util.getCorpCurrency();
        hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;   
        
        helpParam = CSM_Constants.HELP_OPPORTUNITY_UPDATES;
        if (ApexPages.currentPage().getParameters().get(CSM_Constants.ADMIN_HYPERLINK_FLAG) == 'false' /*&&
            CSM_Util.isUserAnSystemAdmin() != true*/) {
            this.theLinksAreVisible = false;
        } 
    }
	public PageReference redirectToBatchOppGeneration() {
		PageReference pageRef = Page.REN_BatchOppGeneration;
		pageRef.getParameters().put('tabCategory', 'Renewal');
		pageRef.setRedirect(true);
		return pageRef;
	}
	public PageReference saveRenewOpptAdmin(){
        Map<String, REN_BaseMainController> baseMainControllerMap = getBaseMainControllerMap();
        for(REN_BaseMainController baseMainController : baseMainControllerMap.values()){
			if(baseMainController instanceof REN_OppRenewalAdminUpdateCompCntrl){
                ((REN_OppRenewalAdminUpdateCompCntrl)baseMainController).save();
            }
        }
        return null;
    }  
     public PageReference cancel(){
        PageReference pageRef = Page.CSM_Admin;
        pageRef.getParameters().put('tabCategory', 'Renewal');
        pageRef.setRedirect(true);
        return pageRef;

    }   
    public PageReference manageMappings(){
        PageReference pageRef = Page.ren_renewalmappings;
        pageRef.getParameters().put('tabCategory', 'Renewal');
        pageRef.setRedirect(true);
        return pageRef;
    }
}