public with sharing class REN_OpportunityDetailController {
	public String ownerName {get;set;}
	public String actName {get;set;}
   	public String probability {get; set;}
   	public String stageName {get; set;}
   	
	public Opportunity opportunityObject {
		get; 
		set {
			if(value != null)
			{
				opportunityObject = value;
				if (opportunityObject != null) {
					setAcctAndOwnerName();	
					setProbabilityValue();	
				}
			}			
		}
	}
	public Map<String, boolean> currencyFormulaFieldMap{get;set;} 
	
 	public string recordCurrencyCode{
       get{
            if(String.isBlank(recordCurrencyCode) && opportunityObject != null){
                  if(UserInfo.isMultiCurrencyOrganization() && CSM_Util.returnIfCurrencyISOCodeExists(CSM_Constants.OBJ_OPPORTUNITY))     {
                      recordCurrencyCode = (String)opportunityObject.get(REN_Constants.REN_CURRENCY_ISO_CODE) + ' ';
                  }else{
                      recordCurrencyCode = CSM_Util.convertCurrencyNameToSymbol(UserInfo.getDefaultCurrency()) + ' ';
                  }
             }
            return recordCurrencyCode;
       }
       private set;
    }
	
	
	public REN_OpportunityDetailController() {
		getCurrencyFormulaField();
	}
	
	public void setAcctAndOwnerName() {
		if (opportunityObject != null) {
			List<Opportunity> opptObjList = new List<Opportunity>();
			if (opportunityObject.get('AccountId') != null && opportunityObject.get('ownerId') != null) {
				String acctId = String.valueOf(opportunityObject.get('AccountId'));
				String ownerId = String.valueOf(opportunityObject.get('OwnerId'));
				opptObjList = REN_OpportunityDataAccess.getOpportunityByAcctIdAndName(acctId, ownerId);	
				if (opptObjList != null && !opptObjList.isEmpty())	{
					ownerName = (String) opptObjList[0].getSobject('Owner').get('Name');
					actName = (String) opptObjList[0].getSobject('Account').get('Name');
				}
			}										
		}	
	}
	
	public void setProbabilityValue() {
		if (opportunityObject != null) {
			OpportunityStage opptStageObjList = new OpportunityStage();
			if (opportunityObject.get('StageName') != null) {
				String stageName = String.valueOf(opportunityObject.get('StageName'));
				opptStageObjList = REN_OpportunityDataAccess.getProbabilityValueByStage(stageName);
				if (opptStageObjList != null)	{
					if (opportunityObject.get('Probability') == null){
					opportunityObject.put('Probability',opptStageObjList.DefaultProbability);
					}
				}
			}										
		}	
	}
	
	public List<SelectOption> getActivePricebooks(){
		List<Pricebook2> pbList = REN_PricebookDataAccess.getPriceBookDetail();
		List<SelectOption> priceBookOptions = new List<SelectOption>();
		for(Pricebook2 pb : pbList){
			priceBookOptions.add(new SelectOption(pb.Id, pb.Name));
		}
		return priceBookOptions;
	}
	
	public void getCurrencyFormulaField(){
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get('Opportunity');
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
		currencyFormulaFieldMap = new Map<String, boolean>();
		
		for( Schema.SObjectField tmpfield :fieldMap.values()){         
           DescribeFieldResult fldResult = tmpField.getDescribe();
           Schema.DisplayType fldType = fldResult.getType();
           String  fldName = fldResult.getName();
              if (fldType == Schema.DisplayType.CURRENCY){
                 currencyFormulaFieldMap.put(String.valueOf(fldName),fldResult.isCalculated());
               }
        }
	}
	public PageReference getProbabilityValue() {
		OpportunityStage opptStageObjList = new OpportunityStage();
		opptStageObjList = REN_OpportunityDataAccess.getProbabilityValueByStage(stageName);
		if (opptStageObjList != null)	{
			probability = String.valueOf(opptStageObjList.DefaultProbability);
		}
		return null;
	}
}