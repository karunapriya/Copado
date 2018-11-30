public with sharing class CSM_FocusCategoryViewController  extends REN_BaseMainController{
    public Boolean hasDisplayName {get; set;}
	public Boolean hasCSMAccess {get; private set;}
	public Boolean hasRenewAccess {get; private set;}
	public String fcViewId {get; private set;}
	public String fcViewObject {get; private set;}
	public CSM_Focus_Category_View__c fcView {get; private set;}
	public String cancelURL {get; private set;}
	public String helpParam {get; set;}
	private Map<String, CSM_FocusCategoryViewColumnCmpCtrl> fcvcComponentControllerMap;
	public String tabCategory {get; set;} 
	public List<SelectOption> allCurrencyFields {get; set;}
	public REN_LogicBuilderInputWrapper lbInputWrapper {get; set;}	
	private List<CSM_Focus_Category_View_Criteria__c> criteriaList;	
	public Boolean isValidCriteria {get; set;}
	public CSM_FocusCategoryViewController ctrl {get; private set;}
	public REN_BaseMainController baseCtrl {get; private set;}	
	public String retUrl {get; private set;}
	public String objType {get; set;}
	public list<SelectOption> allFields{get;set;}
    public string selectedField{get;set;}
    public string selectedOrder{get;set;}
    public Boolean isTile {get; set;}
	
				
	public CSM_FocusCategoryViewController() {
		ctrl = this; 
		
		
		baseCtrl = this;		
		helpParam = CSM_Constants.HELP_FOCUS_CATEGORY_VIEWS;
		// Check CSM Access
		hasCSMAccess =SS_LicenseCheck.getInstance().isCSMEnabled;
        hasRenewAccess =SS_LicenseCheck.getInstance().isRenewEnabled;
        
		fcViewId = ApexPages.currentPage().getParameters().get(CSM_Constants.OBJ_IG_ID);
		String fcViewObject = ApexPages.currentPage().getParameters().get(CSM_Constants.OBJ_TYPE);
		cancelURL = ApexPages.currentPage().getParameters().get(CSM_Constants.CANCEL_URL);
		retUrl=ApexPages.currentPage().getParameters().get(CSM_Constants.RET_URL);
		objType = ApexPages.currentPage().getParameters().get(CSM_Constants.OBJ_TYPE);
		
			
		if (fcViewId!=null && fcViewId.length()>0){
			fcViewId = String.escapeSingleQuotes(fcViewId);
			List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
			try
			{
				fcViewList = CSM_FocusCategoryViewDataAccess.findFCVByViewID(fcViewId);
			}
			catch (exception ex)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			}
			if (fcViewList!=null && !fcViewList.isEmpty()){
				fcView = fcViewList[0];
				fcViewObject = fcView.CSM_Object_Name__c;
				hasDisplayName = true;
				lbInputWrapper = new REN_LogicBuilderInputWrapper(fcView,CSM_Constants.OBJ_FCV_CRITERIA,
										fcViewObject,'fcv1',false,this,'', 'refreshLB1', 'onChangeDate1',true,'');	
				if(fcView.CSM_Sort_By__c!=null && fcView.CSM_Sort_Order__c!=null){
                    selectedField=fcView.CSM_Sort_By__c;
                    selectedOrder=fcView.CSM_Sort_Order__c;
                }
                else{
                	//Added for DE2454
                	String objName = fcViewObject;
                    if(fcViewObject.endsWithIgnoreCase('__c')){
                        objName = '';
                        objName = CSM_Util.getNamespace() + fcViewObject;
                    }
 					selectedField=Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get('LastModifiedDate').getDescribe().getName();
                    //selectedField=Schema.getGlobalDescribe().get(fcViewObject).getDescribe().fields.getMap().get('LastModifiedDate').getDescribe().getName();
                    selectedOrder='Desc';
                }	
                isTile = fcView.CSM_IsTile__c;
			} else {
				lbInputWrapper = new REN_LogicBuilderInputWrapper(new CSM_Focus_Category_View__c(),CSM_Constants.OBJ_FCV_CRITERIA,
										fcViewObject,'fcv1',false,this,'', 'refreshLB1', 'onChangeDate1',true,'');
			}
		}
			
		if (fcViewObject!=null){
			populateCurrencyFields(fcViewObject);
			populateFields(fcViewObject);
			if (fcView==null){
				fcView = new CSM_Focus_Category_View__c();
				fcView.CSM_Object_Name__c = fcViewObject;
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,Label.CSM_MSG_OBJECT_TYPE_REQ));
		}
	}

	private PageReference getPageRef(String url){
		PageReference pageRef = new PageReference(url);
		pageRef.getParameters().put('tabCategory', 'Admin');
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	public PageReference fcViewCreate() {
		List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
    	if (fcView!=null && fcView.CSM_Display_Name__c!=null && fcView.CSM_Display_Name__c.trim().length()>0){
    		fcView.Name = fcView.CSM_Display_Name__c;
    		fcViewList.add(fcView);
    		try
    		{
    			fcViewList = CSM_FocusCategoryViewDataAccess.upsertFCV(fcViewList);
    		}
			catch (exception ex)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
			}
    		if(!ApexPages.HasMessages(ApexPages.SEVERITY.ERROR)) {
    			fcView = fcViewList[0];
    			PageReference pageRef = Page.CSM_FocusCategoryView;
    			pageRef.getParameters().put(CSM_Constants.OBJ_IG_ID, fcView.id);
    			pageRef.getParameters().put(CSM_Constants.OBJ_TYPE, fcViewObject);
    			pageRef.getParameters().put(CSM_Constants.CANCEL_URL, cancelURL);
    			pageRef.setRedirect(true);
    			return pageRef;
    			
    		}
    	}
    	return null;
		
	}
	public PageReference fcViewSave() {
		try
        {  
        	hasDisplayName = false;
        	List<CSM_Focus_Category_View__c> fcViewList = new List<CSM_Focus_Category_View__c>();
        	List<String> fcViewIdList = new List<String>();
        	PageReference fcListViewURL=Page.CSM_FocusCategoryViewList;
        	fcListViewURL.getParameters().put('tabCategory', 'Admin');
        	if (String.isBlank(fcView.CSM_Display_Name__c)) {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.Label.CSM_FC_DISPLAY_NAME_MSG));
	            return null;
	        }
        	if (fcView!=null && fcView.CSM_Display_Name__c!=null && fcView.CSM_Display_Name__c.trim().length()>0){
        		fcView.Name = fcView.CSM_Display_Name__c;
        		fcView.CSM_Sort_By__c=selectedField;
                fcView.CSM_Sort_Order__c=selectedOrder;
                if(isTile != fcView.CSM_IsTile__c) {
                	List<CSM_Focus_Category_Display_Order__c> orderingRecord = CSM_FocusCategoryDisplayOrderDataAccess.getFCDisplayOrderByFCVId(new Set<Id>{fcView.id});
                	if(orderingRecord != null && !orderingRecord.isEmpty()) {
                		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, System.Label.CSM_LBL_TYPE_CHANGE_VALIDATION));
	            		return null;
                	}
                }
        		//fcView.RLM_Currency_Code__c = fcvCritComponentController.corpCurr;
        		//fcViewList.add(fcView);
				fcViewIdList.add(fcView.Id);        		
        		/*try
        		{
        			fcViewList = CSM_FocusCategoryViewDataAccess.upsertFCV(fcViewList);
        		}
				catch (exception ex)
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
				}
        		if(!ApexPages.HasMessages(ApexPages.SEVERITY.ERROR)) {
        			fcView = fcViewList[0];
        		}
				if (fcView.Id!=null){
					fcViewIdList.add(fcView.Id);
					hasDisplayName = true;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_FOCUS_CATEGORY_VIEW_SAVED));
				}*/
				validateCriteriaQueryAndSave();        	
	        	if (fcvcComponentControllerMap != null && isValidCriteria )
			    {
			        for (CSM_FocusCategoryViewColumnCmpCtrl fcvcController: fcvcComponentControllerMap.values())
			        {
			        	fcvcController.Save();
			        }
			        if(!ApexPages.HasMessages(ApexPages.SEVERITY.ERROR))
					{				
						ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_FOCUS_CATEGORY_VIEW_COLUMNS_SAVED));
					}
			    } 
			    
			    
			    /*if (fcvCritComponentControllerMap != null)
			    {
			        for (CSM_FocusCategoryViewCriteriaCmpCtrl fcvCritController: fcvCritComponentControllerMap.values())
			        {
			        	fcvCritController.saveCriteria();
			        }
			        if(!ApexPages.HasMessages(ApexPages.SEVERITY.ERROR))
					{				
						ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_FOCUS_CATEGORY_VIEW_CRITERIA_SAVED));
					}
			    }*/
			    /*if (fcViewIdList!=null && !fcViewIdList.isEmpty() && 
			    	((fcvcComponentControllerMap != null && !fcvcComponentControllerMap.isEmpty()) || 
			    	(fcvCritComponentControllerMap != null && !fcvCritComponentControllerMap.isEmpty()))) {*/
				saveVisibiltiy();
		    	if(isValidCriteria){
			    	CSM_FocusCategoryViewDataAccess.updateSOQL(fcViewIdList);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, Label.CSM_MSG_FOCUS_CATEGORY_VIEW_SOQL_SAVED));
		    	}
        	}
        	
          if(isValidCriteria){
		    if(retUrl!=null){
               return getPageRef(retUrl);
            }else{
               return fcListViewURL;
            }
          }
        }
        catch(Exception ex)
        {       
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
    		return null;
        }
		return null;
	}
	
	public PageReference fcViewCancel() {
		if (cancelURL!=null){
			/*if (fcvcComponentControllerMap != null && !fcvcComponentControllerMap.isEmpty()){
		    	fcViewSave();
		    }*/
			deleteFCV();			   	
			return getPageRef(cancelURL);
		}
		return null;
	}
	    		
	/**
	* @description get method to return the Indicator Controller Map
	*/
	public  Map<String, CSM_FocusCategoryViewColumnCmpCtrl> getFCVCComponentControllerMap()
	{
		return fcvcComponentControllerMap;
	}
	
	/**
	* @description get method to return the Indicator Controller Map
	* @param the Indicator Group Id assocated with this controller
	* @param the controller assocated with thsi Indicator Group Id
	*/
	public void setFCVCComponentControllerMap(String key, CSM_FocusCategoryViewColumnCmpCtrl compController)
	{
		if (fcvcComponentControllerMap == null)
		{
			fcvcComponentControllerMap = new Map<String, CSM_FocusCategoryViewColumnCmpCtrl>();			
		}
		fcvcComponentControllerMap.put(key, compController);
	}
		    		
	private void populateCurrencyFields(String fcViewObject){
   		this.allCurrencyFields = new List<SelectOption>();
   		this.allCurrencyFields.add(new SelectOption('', ' '));
   		try{
		    List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(fcViewObject);
			for( Schema.SObjectField tmpfield :fieldList) { 
				if (String.valueOf(tmpfield.getDescribe().getType()) == CSM_Constants.TYPE_CURRENCY) { 
						this.allCurrencyFields.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
					}
			   		CSM_Util.sortSelectOptionByLabel(this.allCurrencyFields);
			}
		}catch (exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
		this.allCurrencyFields[0] = new SelectOption('', 'No Header');
	}
	
	
	private void validateCriteriaQueryAndSave(){
		Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
		for(REN_BaseChildController baseChildController : baseChildControllerMap.values()){
			if(baseChildController instanceof REN_LogicBuilderCmpCtrl){
				((REN_LogicBuilderCmpCtrl)baseChildController).performSave();
				isValidCriteria = ((REN_LogicBuilderCmpCtrl)baseChildController).isValidCSMCriteria;
			}
		}
	}
	
	private void saveVisibiltiy(){
		Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
		for(REN_BaseChildController baseChildController : baseChildControllerMap.values()){
			if(baseChildController instanceof CSM_FocusCategoryRestrctVisibiltyCmpCtrl){
				((CSM_FocusCategoryRestrctVisibiltyCmpCtrl)baseChildController).performSave(fcViewId);
			}
		}
	}
	
    public void deleteFCV(){
    	List<CSM_Focus_Category_View__c> lstFCV = CSM_FocusCategoryViewDataAccess.getToDeleteFCV();
		if(lstFCV != null && !lstFCV.isEmpty()){
			CSM_FocusCategoryViewDataAccess.deleteFCV(lstFCV);
		}    	
    }
	private void populateFields(String fcViewObject){
   		this.allFields = new List<SelectOption>();
   		try{
		    List<Schema.SObjectField> fieldList = CSM_AccessController.getInstance().returnPermissionFieldsNameList(fcViewObject);
			for( Schema.SObjectField tmpfield :fieldList) { 
				if(!tmpfield.getDescribe().getType().equals(Schema.DisplayType.REFERENCE) && !tmpfield.getDescribe().getType().equals(Schema.DisplayType.TEXTAREA) && !tmpfield.getDescribe().getType().equals(Schema.DisplayType.MULTIPICKLIST)){
					this.allFields.add(new SelectOption(tmpField.getDescribe().getName(), tmpField.getDescribe().getLabel()));
                }
			   	CSM_Util.sortSelectOptionByLabel(this.allFields);
			}
		}catch (exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}
	}	
}