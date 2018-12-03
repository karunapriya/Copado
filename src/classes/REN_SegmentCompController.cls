/**
 * Created Date		: Dec 2, 2016
 * Developed By		: prashant, Comity Designs, Inc.
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
 * prashant					User Story				Dec 2, 2016			1.1					@description
 * 
 */
public with sharing class REN_SegmentCompController extends REN_BaseMainController{
	/*public String segmentFilterValueForFields 
    {
        get
        {
            return segmentFilterValueForFields;
        }
        set
        {
            segmentFilterValueForFields = value;
            //clearCriteria();
        }
    }*/
	public String selectedObject{get; set;}
    public String criteria {get; set;}
    public String selCurrency {get; set;}    
    public List<REN_LogicBuilderInputWrapper> lbInputWrapperList{get;set;}
	public String cancelUrl{get; set;}
    @TestVisible
    private Boolean isEntitlementEnabled{get;set;}
    private String currentOpportunityId{get; set;}
    private String nameSpace;
    @TestVisible
    private REN_Renew_Configuration__c renewOppObj;
    private REN_Renew_Configuration__c renewObj;
    private REN_Renew_Configuration__c renewalRenewObj;
    @TestVisible
    private REN_Renew_Configuration__c renewalRenewOpAssetObj;
    private REN_Renew_Configuration__c renewalRenewOpAssetAccountObj;
    public Boolean displayErrorMsg {get; set;}
    
    public REN_LogicBuilderInputWrapper segmentLogicInputWrapperObj{get;set;}

    public REN_SegmentCompController() {
	    
		 super();
        this.nameSpace = CSM_Util.getNamespace();
         
        //system.debug('segmentFilterValueForFields--+'+segmentFilterValueForFields);
        this.selectedObject = REN_Constants.OBJ_ASSET;
        //this.currentOpportunityId = ApexPages.currentPage().getParameters().get('Id');
        displayErrorMsg = false;
        //system.debug('segmentLogicInputWrapperObj------>'+segmentLogicInputWrapperObj);
        this.renewOppObj = new REN_Renew_Configuration__c(REN_Record_Key__c=REN_Constants.OBJ_OPPORTUNITY);
        this.renewObj = new REN_Renew_Configuration__c(REN_Record_Key__c=REN_Constants.OBJ_ASSET);
        this.renewalRenewObj = new REN_Renew_Configuration__c(REN_Record_Key__c='RenewalRelationshipOppAsset');
        this.renewalRenewOpAssetAccountObj = new REN_Renew_Configuration__c(REN_Record_Key__c='RenewalRelationshipOppAssetAcc');
        this.lbInputWrapperList = new List<REN_LogicBuilderInputWrapper>();
        map<string,list<REN_LogicBuilderInputWrapper>> mapLG = new map<string,list<REN_LogicBuilderInputWrapper>>();
        REN_LogicBuilderInputWrapper rrLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_ASSET, 
                                            'SegmentFiltereAsset_', true, this, 'Segmentation Filter', 
                                            'refreshLB3', 'onChangeDate4', false, '');
        this.lbInputWrapperList.add(rrLogicBuilderInputWrapper);   
        mapLG.put(REN_Constants.OBJ_ASSET,lbInputWrapperList);
        REN_LogicBuilderInputWrapper rrAOLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewalRenewObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_REN_RENEWS_TO, 
                                            'SegmentFilterRLI_', true, this, 'Segmentation Filter', 
                                            'refreshLB3', 'onChangeDate4', false, 'REN_Source_Opportunity__c,REN_Asset__c');
        this.lbInputWrapperList.add(rrAOLogicBuilderInputWrapper);  
         mapLG.put(REN_Constants.OBJ_REN_RENEWS_TO,lbInputWrapperList); 
        REN_LogicBuilderInputWrapper rrAOALogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewalRenewOpAssetAccountObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_REN_RENEWS_TO, 
                                            'SegmentFilterRLI_', true, this, 'Segmentation Filter', 
                                            'refreshLB3', 'onChangeDate4', false, 'REN_Source_Opportunity__c,REN_Source_Opportunity__r.AccountId,REN_Asset__c');
        this.lbInputWrapperList.add(rrAOALogicBuilderInputWrapper);   
         mapLG.put(REN_Constants.OBJ_REN_RENEWS_TO,lbInputWrapperList);
        REN_LogicBuilderInputWrapper oppLogicBuilderInputWrapper = new REN_LogicBuilderInputWrapper(this.renewOppObj, REN_Constants.OBJ_LC, REN_Constants.OBJ_OPPORTUNITY, 
                                            'SegmentFilterOpportunity_', true, this, 'Segmentation Filter', 
                                            'refreshLB3', 'onChangeDate4', false, '');
        this.lbInputWrapperList.add(oppLogicBuilderInputWrapper);   
         mapLG.put(REN_Constants.OBJ_OPPORTUNITY,lbInputWrapperList);
	}
	
    public PageReference findFor(){
        try{
        	if(!Test.isRunningTest()){
        		system.debug('IN---- -');
	            findForCriteria();
        	}
        	  this.criteria = ApexPages.hasMessages()?'error':this.constructSearchSQOL();
        	  system.debug('criteria -' + this.criteria);
			  if(this.selectedObject != null && this.selectedObject != '' && !String.isEmpty(this.selectedObject)){
		      REN_SegmentLogicBuilderCmpCtrl  selectedCtrl = this.findLogicBuilderInstance();    
		      system.debug('selectedCtrl ---' + selectedCtrl);
		      this.selCurrency = selectedCtrl.corpCurr;
			}
        	
        }
        catch(Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input - '+ex.getMessage());
            ApexPages.addMessage(myMsg);
        }

        return null;
    }
    
    private String constructSearchSQOL(){
       /* String renewalRelationCriteria = this.renewalRenewObj.REN_Filter_Criteria__c;
        system.debug('soqlWhere $$$$$$$>>>>>>renewalRelationCriteria>>>>>>> '+renewalRelationCriteria);
		String soqlWhere ='';
		if(String.isNotBlank(renewalRelationCriteria)){
			soqlWhere = 'From REN_Renews_To__c  Where (' + renewalRelationCriteria + '))';
		}else{
			soqlWhere = 'From REN_Renews_To__c';
		}
    	if(String.isNotBlank(renewalRelationCriteria)&& String.isNotBlank(soqlWhere)){
    		soqlWhere = soqlWhere.substring(0, soqlWhere.length()-1); //remove end bracket
    	}*/
    	
    	
        //String renewalRelationCriteria = this.renewalRenewObj.REN_Filter_Criteria__c;
        String queryField;
		if(this.selectedObject.equals(REN_Constants.OBJ_ASSET)){
			this.criteria = this.renewObj.REN_Filter_Criteria__c;
			queryField = 'REN_Asset__c';
		}else if(this.selectedObject.equals(REN_Constants.OBJ_OPPORTUNITY)){
			this.criteria = this.renewOppObj.REN_Filter_Criteria__c;
			queryField =  REN_Constants.OBJ_OPPORTUNITY;
		}if(this.selectedObject.equals(REN_Constants.OBJ_REN_RENEWS_TO)){
			this.criteria = this.renewalRenewObj.REN_Filter_Criteria__c;
			queryField = nameSpace + 'REN_Renews_To__c';
		}
		system.debug('----->criteria--'+criteria);
		String soqlWhere = ' Where ' + '(' + criteria + ')';//REN_Util.constructWhereClauseForSegment(criteria,renewalRelationCriteria,queryField);
		system.debug('----->criteria-check-   Where '+soqlWhere);
		//add condition to filter out assets related to currentOpportunityId
    	/*if(String.isNotBlank(renewalRelationCriteria)&& String.isNotBlank(soqlWhere)&& String.isNotBlank(currentOpportunityId)){
    		soqlWhere = soqlWhere.substring(0, soqlWhere.length()-1); //remove end bracket
    		soqlWhere +=  ' AND REN_Renews_To__c != \'' + currentOpportunityId + '\')';
    	}*/
       	system.debug('soqlWhere $$$$$$$>>>>>>>>>>>>> '+soqlWhere);
        return soqlWhere;
    }
    
  
    @TestVisible
    private void findForCriteria(){
        REN_SegmentLogicBuilderCmpCtrl  selectedCtrl = this.findLogicBuilderInstance();
        if(selectedCtrl != null){
            selectedCtrl.performFind();
        }
        system.debug('selectedCtrl--->'+selectedCtrl);
        if(selectedCtrl != null){
            selectedCtrl.performFind();
        }
        system.debug('selectedCtrl--->'+selectedCtrl);
    }
    
    private REN_SegmentLogicBuilderCmpCtrl  findLogicBuilderInstance(){
        String uniqueLogicBuilderInstance;
        system.debug('this.selectedObject---------'+this.selectedObject);
        if(this.selectedObject.equals(REN_Constants.OBJ_REN_RENEWS_TO)){
        	uniqueLogicBuilderInstance = 'SegmentFilterRLI__' + this.selectedObject;
        	system.debug('IN RR----');
        }else if(this.selectedObject.equals(REN_Constants.OBJ_ASSET)){
        	uniqueLogicBuilderInstance = 'SegmentFiltereAsset__' + this.selectedObject;
        	system.debug('IN AS-----');
        }else if(this.selectedObject.equals(REN_Constants.OBJ_OPPORTUNITY)){
        	uniqueLogicBuilderInstance = 'SegmentFilterOpportunity__' + this.selectedObject;
        	system.debug('IN Opp------');
        }
        Map<String, REN_BaseChildController> baseChildControllerMap = getBaseChildControllerMap();
        system.debug('baseChildControllerMap--->'+baseChildControllerMap);
        system.debug('uniqueLogicBuilderInstance--->'+uniqueLogicBuilderInstance);
        system.debug('baseChildControllerMap.get--->'+baseChildControllerMap.get(uniqueLogicBuilderInstance));
        return (REN_SegmentLogicBuilderCmpCtrl )baseChildControllerMap.get(uniqueLogicBuilderInstance);
    }
    
    public void showLogicBuilder(){
        this.clearCriteria();
    }
    
    private void clearCriteria(){
    	if(findLogicBuilderInstance() != null){
        REN_SegmentLogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance();
        this.clearLogicBuilderValues(selectedCtrl);
        // clear renewal values.
        selectedCtrl = this.findLogicBuilderInstance();
        this.clearLogicBuilderValues(selectedCtrl);
    	}
    }
    
    private void clearLogicBuilderValues(REN_SegmentLogicBuilderCmpCtrl selectedCtrl){
    	if(selectedCtrl != null){
        	if(selectedCtrl.criteriaWrapperList != null){
	            selectedCtrl.criteriaWrapperList.clear();
	            selectedCtrl.populateDefaultCriteria();
        	}
        	//selectedCtrl.corpCurr = UserInfo.getDefaultCurrency(); Commented for DE1129
        }
    }
    
    public List<SelectOption> getItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(REN_Constants.OBJ_ASSET, system.label.REN_LBL_ASSETS));
        options.add(new SelectOption(REN_Constants.OBJ_REN_RENEWS_TO, 'AOR'));
        options.add(new SelectOption(REN_Constants.OBJ_REN_RENEWS_TO,'AORA'));
        options.add(new SelectOption(REN_Constants.OBJ_OPPORTUNITY, REN_Constants.OBJ_OPPORTUNITY));
        
        /*if(this.isEntitlementEnabled){
            options.add(new SelectOption(REN_Constants.OBJ_CONTRACT_LINE_ITEM, 'Service Contract Line Items'));
        }*/
        /*if(!this.isDefaultCurrencySet){
        	REN_LogicBuilderCmpCtrl selectedCtrl = this.findLogicBuilderInstance(false);
        	if(UserInfo.isMultiCurrencyOrganization() && selectedCtrl != null){
	        	selectedCtrl.corpCurr = UserInfo.getDefaultCurrency();
	        }
        	this.isDefaultCurrencySet = true;
        }*/
        return options;
    }
    
    public with sharing class PricebookEntryException extends Exception {}
}