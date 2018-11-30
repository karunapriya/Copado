public with sharing class REN_ValueMappingCtrl extends REN_BaseMainController {
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
	public String fieldName {
		get {
			return CSM_Util.getNamespace()+'REN_Renewal_Status__c';
		}
		set;
	}
	public REN_ValueMappingCtrl() {
      	helpParam = CSM_Constants.HELP_PLAYS;
      	populateFieldMappingInputWrapper();
		picklistValues = getPicklistValues();
	}
	
	private void populateFieldMappingInputWrapper(){
		this.inputWrapperList = new List<REN_FieldMappingInputWrapper>();
		this.inputWrapperList.add(new REN_FieldMappingInputWrapper('', '', system.label.REN_RENEWAL_STAT_VAL_MAP, this, '', '', '', '', '', ''));
	}
	public List<SelectOption> getPicklistValues() {
		picklistValues = new List<SelectOption>();
		picklistValues.add(new SelectOption('','Select One'));
		picklistValues.add(new SelectOption('Open','Open'));
		picklistValues.add(new SelectOption('Won','Won'));
		picklistValues.add(new SelectOption('Lost','Lost'));
		return picklistValues;
	}
	public PageReference redirectToMappingsPage() {
    	PageReference pageRef = Page.ren_renewalmappings;
		pageRef.getParameters().put('tabCategory','Renewal');
		pageRef.setRedirect(true);
		return pageRef;
    }
    public PageReference saveValueMapping() {
	    try {
	    	Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
	    	for(REN_BaseChildController baseChildController : baseChildControllerMap.values()){
	    		if(baseChildController instanceof REN_ValueMappingCompCtrl) {
					((REN_ValueMappingCompCtrl)baseChildController).save();
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