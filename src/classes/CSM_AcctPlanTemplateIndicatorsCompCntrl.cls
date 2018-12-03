/** 
 * @author      Mike Faust(mike@comitydesigns.com)
 * @date        08.13.2014
 * @description CSM_AcctPlanTemplateIndicatorsCompCntrl controller class for the Success Plan template indicator component 
 */

public with sharing class CSM_AcctPlanTemplateIndicatorsCompCntrl {

    public boolean isEditable {get; set;}
    public String indicatorToUpdate {get; set;}
    private List<CSM_Account_Plan_Template_Indicator__c> accountPlanTemplateIndicatorList;
    private List<CSM_AcctPlanTemplateIndicatorWrapper> indicatorWrapperList; 
    public Integer successPlanCount {get; set;}
    public String acctSuccessPlanDisplayName {get; set;}  
    public String indicatorToDeleteId {get; set;}
    public Integer orderId {get; set;}  
    public String helpParam {get; set;}
    public Boolean mcEnabled {get; set;}
    public String corpCurrCode{get;set;}
    public List<SelectOption> currList{get;set;}
        
    /** 
     * @description constructor
     */
    public CSM_AcctPlanTemplateIndicatorsCompCntrl(){
        indicatorToDeleteId = '';
        successPlanCount = 0;   
        helpParam = CSM_Constants.HELP_SUCCESS_PLAN_TEMPLATE_INDICATORS;
        currList = CSM_Util.currencyPicklist(); 
        mcEnabled = CSM_Util.checkMCEnabled();
    }
    /** 
     * @description theSuccess Plan template reference
     * @return CSM_Account_Plan_Template__c
     */
    public CSM_Account_Plan_Template__c theAccountPlanTemplate 
    { get; 
        set {
            if (value != null)
            {
                theAccountPlanTemplate = value;
            }
        }
    }
    
    
    /**
     * @description Creating local reference to the CSM_AccountPlanTemplateController so that 
     *              setIndicatorComponentControllerMap may be used.
     * @return CSM_AccountPlanTemplateController
     */
    public CSM_AccountPlanTemplateController CSM_AccountPlanTemplateController
    { 
        get; 
        set 
        {
            if (value != null) 
            {
                CSM_AccountPlanTemplateController = value;      
                CSM_AccountPlanTemplateController.setaccountPlanTemplateIndicatorsCompCntrl(this);
            }
        }
    }
    
    /** 
     * @description gets the Success Plan template indicators and builds the wrapper class to contain the information
     */
    public void populateAccountPlanTemplateIndicators() {
        indicatorWrapperList = new List<CSM_AcctPlanTemplateIndicatorWrapper>();
        accountPlanTemplateIndicatorList = new List<CSM_Account_Plan_Template_Indicator__c>(); 
        try
        {
            CSM_Account_Plan_Template__c acctPlanTemp = CSM_AccountPlanTemplateDataAccess.populateAccountPlanTemplateInformation(theAccountPlanTemplate.id);
            if(acctPlanTemp.CSM_Currency_Code__c != null && acctPlanTemp.CSM_Currency_Code__c !=''){
                corpCurrCode = acctPlanTemp.CSM_Currency_Code__c;
            }
            else{
                corpCurrCode = CSM_Util.getCorpCurrency();
            }
            accountPlanTemplateIndicatorList = CSM_AcctPlanTemplateIndicatorDataAccess.accountPlanTemplateIndicators(theAccountPlanTemplate.id);
            for (CSM_Account_Plan_Template_Indicator__c p : accountPlanTemplateIndicatorList)
            {
                CSM_AcctPlanTemplateIndicatorWrapper newWrap = new CSM_AcctPlanTemplateIndicatorWrapper(p);
                indicatorWrapperList.add(newWrap);
            }
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
    }
    
    
    /** 
     * @description get method that returns the list of indicator wrappers
     * @return List<IndicatorWrapper>
     */
    public List<CSM_AcctPlanTemplateIndicatorWrapper> getIndicatorWrapperList()
    {
        if(indicatorWrapperList == null)
        {
            populateAccountPlanTemplateIndicators();
        }
        return indicatorWrapperList;
    }   
    
    /** 
     * @description method to perform validation and save on the indicators. 
     * It validates that if a from/to is populate the related type is populated
     * It also validates that if the type is populated a related from/to is pouplated
     * Then converts the the wrapper to a list of CSM_Account_Plan_Template_Indicator__c to save
     * @return boolean
     */
    public boolean saveIndicators()
    {
        accountPlanTemplateIndicatorList.clear();
        
        boolean isValid = true;
        for(CSM_AcctPlanTemplateIndicatorWrapper w : indicatorWrapperList)
        {
            //Verify that if the criteria is populated, that either the from or to field is populated
            //if date type compares different fields 
            if(w.indicator.CSM_Criteria_1_Type__c != null && ((w.indicatorType != CSM_constants.TYPE_DATE && 
                String.isEmpty(w.indicator.CSM_Criteria_1_From_Value__c) && String.isEmpty(w.indicator.CSM_Criteria_1_To_Value__c))
                || (w.indicatorType == CSM_constants.TYPE_DATE &&
                (w.indicator.CSM_Criteria_1_From_Date__c == null && w.indicator.CSM_Criteria_1_To_Date__c == null))))
            {
                w.indicator.CSM_criteria_1_type__c.addError(Label.CSM_MSG_IND_CRITERIA);
                isValid = false;
            }
            if(w.indicator.CSM_Criteria_2_Type__c != null && ((w.indicatorType != CSM_constants.TYPE_DATE &&
                    String.isEmpty(w.indicator.CSM_Criteria_2_From_Value__c) && String.isEmpty(w.indicator.CSM_Criteria_2_To_Value__c))
                    || (w.indicatorType == CSM_constants.TYPE_DATE &&
                (w.indicator.CSM_Criteria_2_From_Date__c == null && w.indicator.CSM_Criteria_2_To_Date__c == null))))
            {
                w.indicator.CSM_criteria_2_type__c.addError(Label.CSM_MSG_IND_CRITERIA);
                isValid = false;
            }
            if(w.indicator.CSM_Criteria_3_Type__c != null && ((w.indicatorType != CSM_constants.TYPE_DATE &&
                String.isEmpty(w.indicator.CSM_Criteria_3_From_Value__c) && String.isEmpty(w.indicator.CSM_Criteria_3_To_Value__c))
                || (w.indicatorType == CSM_constants.TYPE_DATE &&
                (w.indicator.CSM_Criteria_3_From_Date__c == null && w.indicator.CSM_Criteria_3_To_Date__c == null))))
            {
                w.indicator.CSM_criteria_3_type__c.addError(Label.CSM_MSG_IND_CRITERIA);
                isValid = false;
            }
            //Verify that if the from or to field is populated, that the criteria type is populated 
            //If type is date, compares different fields
            if(w.indicator.CSM_Criteria_1_Type__c == null && ((w.indicatorType != CSM_constants.TYPE_DATE &&
                (!String.isEmpty(w.indicator.CSM_Criteria_1_From_Value__c) || !String.isEmpty(w.indicator.CSM_Criteria_1_To_Value__c)))
                || (w.indicatorType == CSM_constants.TYPE_DATE &&
                (w.indicator.CSM_Criteria_1_From_Date__c != null || w.indicator.CSM_Criteria_1_To_Date__c != null))))
            {
                w.indicator.CSM_criteria_1_type__c.addError(Label.CSM_MSG_IND_CRITERIA_TYPE);
                isValid = false;
            }
            if(w.indicator.CSM_Criteria_2_Type__c == null && ((w.indicatorType != CSM_constants.TYPE_DATE &&
                (!String.isEmpty(w.indicator.CSM_Criteria_2_From_Value__c) || !String.isEmpty(w.indicator.CSM_Criteria_2_To_Value__c)))
                || (w.indicatorType == CSM_constants.TYPE_DATE &&
                (w.indicator.CSM_Criteria_2_From_Date__c != null || w.indicator.CSM_Criteria_2_To_Date__c != null))))
            {
                w.indicator.CSM_criteria_2_type__c.addError(Label.CSM_MSG_IND_CRITERIA_TYPE);
                isValid = false;
            }
            if(w.indicator.CSM_Criteria_3_Type__c == null && ((w.indicatorType != CSM_constants.TYPE_DATE &&
                (!String.isEmpty(w.indicator.CSM_Criteria_3_From_Value__c) || !String.isEmpty(w.indicator.CSM_Criteria_3_To_Value__c)))
                || (w.indicatorType == CSM_constants.TYPE_DATE &&
                (w.indicator.CSM_Criteria_3_From_Date__c != null || w.indicator.CSM_Criteria_3_To_Date__c != null))))
            {
                w.indicator.CSM_criteria_3_type__c.addError(Label.CSM_MSG_IND_CRITERIA_TYPE);
                isValid = false;
            }
            //Defaults the other fields to blank/null values based on what type of indicator it is
            if(w.isDateIndicator)
            {
                w.indicator.CSM_Criteria_1_From_Value__c = '';
                w.indicator.CSM_Criteria_1_To_Value__c = '';
                w.indicator.CSM_Criteria_2_From_Value__c = '';
                w.indicator.CSM_Criteria_2_To_Value__c = '';
                w.indicator.CSM_Criteria_3_From_Value__c = '';
                w.indicator.CSM_Criteria_3_To_Value__c = '';
            }
            else
            {
                w.indicator.CSM_Criteria_1_From_Date__c = null;
                w.indicator.CSM_Criteria_1_To_Date__c = null;
                w.indicator.CSM_Criteria_2_From_Date__c = null;
                w.indicator.CSM_Criteria_2_To_Date__c = null;
                w.indicator.CSM_Criteria_3_From_Date__c = null;
                w.indicator.CSM_Criteria_3_To_Date__c = null;
            }
            //Add indicator to list for saving
            accountPlanTemplateIndicatorList.add(w.indicator);
        }
        try
        {
            if(isValid)
            {
                //perform save
                boolean successful = CSM_AcctPlanTemplateIndicatorDataAccess.updateAccountPlanTemplateIndicators(accountPlanTemplateIndicatorList);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,Label.CSM_MSG_IND_CRITERIA_SAVE));                
                return successful;
            }
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
        return isValid;
    }
    
    /** 
     * @description adds a new indicator to the wrapper class
     * @return PageReference
     */
    public PageReference addIndicator() {
        //Adds a new indicator to the list
        indicatorWrapperList.add(new CSM_AcctPlanTemplateIndicatorWrapper(new CSM_Account_Plan_Template_Indicator__c(csm_account_plan_template__c=theAccountPlanTemplate.id, csm_isactive__c=true, csm_order__c=indicatorWrapperList.size()+1)));
        return null;
    } 
    
    /** 
     * @description queries the CSM_Indicator to get the indicator information for the wrapper whose indicator value changed
     * @return PageReference
     */
    public pageReference updateIndicatorInformation() {
        try {
            List<CSM_Indicator__c> indicatorList = CSM_IndicatorDataAccess.getIndicatorById(indicatorToUpdate);
            if(!indicatorList.isEmpty())
            {
                //Loop through wrapper class, find the matching update and update the value
                for(CSM_AcctPlanTemplateIndicatorWrapper w : indicatorWrapperList)
                {
                    if(indicatorList[0].id == w.indicator.CSM_Indicator__c)
                    {
                        //Since value changed, update the default values
                        w.indicatorDisplay = indicatorList[0].CSM_Object_Name__c + '.' + indicatorList[0].CSM_Object_Field_Name__c;
                        w.indicatorType = indicatorList[0].CSM_Object_Field_Type__c;
                        if (w.indicator.CSM_Criteria_1_type__c == null){
                            w.indicator.CSM_Criteria_1_type__c = null;
                        }
                        if (w.indicator.CSM_Criteria_2_type__c == null){
                            w.indicator.CSM_Criteria_2_type__c = null;
                        }
                        if (w.indicator.CSM_Criteria_3_type__c == null){
                            w.indicator.CSM_Criteria_3_type__c = null;
                        }
                        if(indicatorList[0].CSM_Object_Field_Type__c == CSM_Constants.TYPE_DATE)
                        {
                            w.isDateIndicator = true;
                        }
                        else
                        {
                            w.isDateIndicator = false;
                        }
                    }
                }
            }
            //reset the indicatorToUpdate field
            indicatorToUpdate = '';
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return null;
    }
    
    /** 
    * @description get the success Plans count for the success plan template to show on the confirmation popup
    * @return PageReference
    */
  
    public PageReference getAccountSuccessPlansCount() {
        List<CSM_Account_Plan__c> acctPlanList = new List<CSM_Account_Plan__c>();
        successPlanCount = 0;
        acctSuccessPlanDisplayName = '';        
        try {
            acctPlanList = CSM_AccountPlanDataAccess.getAccountPlansByTemplateId(theAccountPlanTemplate.id);
            if(acctPlanList!=null && !acctPlanList.isEmpty()) { 
                successPlanCount = acctPlanList.size();
                if(successPlanCount <= 5) {
                    List<String> tempObjList = new List<String>();
                    for(CSM_Account_Plan__c ap : acctPlanList) {
                        tempObjList.add(ap.CSM_DisplayName__c);
                        //acctSuccessPlanDisplayName = acctSuccessPlanDisplayName + ap.CSM_DisplayName__c + '\\n\t\t';
                    }
                    acctSuccessPlanDisplayName = JSON.serialize(tempObjList);
                }
            }     
        }
        catch (exception ex) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
        return null; 
    }
  
  
    /** 
     * @description removes the success plan template and indicators association
     */
    public PageReference removePlanIndicator() {
        
        boolean isSuccessFulDelete; 
        try {
            isSuccessFulDelete = CSM_AcctPlanTemplateIndicatorDataAccess.removeAcctPlanTmplIndicatorById(indicatorToDeleteId);
            
            if (isSuccessFulDelete) {
                //TODO: Make the Label for this
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Info, Label.CSM_MSG_TMPL_IND_DELETE));
            }
            //repopulate the indicator Wrapper List
            //indicatorWrapperList = null;
            //populateAccountPlanTemplateIndicators();
            
            for(Integer rowNum=0; rowNum<this.indicatorWrapperList.size(); rowNum++){
                CSM_AcctPlanTemplateIndicatorWrapper wrapper = this.indicatorWrapperList.get(rowNum);
                if(rowNum == orderId){
                    this.indicatorWrapperList.remove(rowNum);
                    break;
                }
                
            }
            
        }
        catch (exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
        }
        return null;
    }
}