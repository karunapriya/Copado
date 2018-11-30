public with sharing class REN_DateMappingCtrl extends REN_BaseMainController{
    public List<SelectOption> picklistValues {get; private set;}
	public String helpParam {get; set;}
	public String tabCategory {get; set;} 
	public List<REN_FieldMappingInputWrapper> inputWrapperList{get;set;}
	public REN_BaseMainController thisController{
		get{
			return this;
		}
			set;}
	public String objectName {
		get {
			return CSM_Util.getNamespace()+'REN_Renews_To__c';
		}
		set;
	}
	public REN_DateMappingCtrl() {
      	helpParam = CSM_Constants.HELP_PLAYS;
      	populateFieldMappingInputWrapper();
	}
	
	private void populateFieldMappingInputWrapper(){ 
		this.inputWrapperList = new List<REN_FieldMappingInputWrapper>();
		this.inputWrapperList.add(new REN_FieldMappingInputWrapper('', '', system.label.REN_PREVIOUS_PRICE_CALCULATION, this, '', '', '', '', '', ''));
	}
	
	public PageReference redirectToMappingsPage() {
    	PageReference pageRef = Page.ren_renewalmappings;
		pageRef.getParameters().put('tabCategory','Renewal');
		pageRef.setRedirect(true);
		return pageRef;
    }
   
    public PageReference saveDateMapping() {
	    try {
	    	Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
	    	for(REN_BaseChildController baseChildController : baseChildControllerMap.values()){
	    		if(baseChildController instanceof REN_DateMappingCompCtrl) {
					((REN_DateMappingCompCtrl)baseChildController).save();
				}
	    	}
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, String.format(Label.REN_MSG_RENEWAL_CONFIG_SAVED, new String[]{'Mappings '})));
	    }
	    catch(exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, REN_Util.getGenericErrorMessage(e, e.getMessage())));
		}
    	return null;
    }
}