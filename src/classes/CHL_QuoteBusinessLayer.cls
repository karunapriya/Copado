/**
  * @description : CHL_QuoteBusinessLayer class is used to return JSON response to show the list of quotes associated with the  partner opportunity.
    @Params : It accepts input from CHL_GridInputWrapper.
*/
public with sharing class CHL_QuoteBusinessLayer {

	//public CHL_AngularTabsInputWrapper inputWrapper;   
	public Map<String, Schema.FieldSet> quoteFsMap;
	public CHL_GridInputWrapper gridInputWrapper;      
	 
	/*public CHL_QuoteBusinessLayer(CHL_AngularTabsInputWrapper inputWrapper){
        this.inputWrapper = inputWrapper;    
    }*/
    
 	public CHL_QuoteBusinessLayer(CHL_GridInputWrapper inputWrapper){
        this.gridInputWrapper = inputWrapper;
    }
   
    /**
      * @description : This method returns the JSON object to show list of quotes associated with the  partner opportunity.
    */
    public CHL_AngularResponeWrapper constructGridWrapper() {
    	List <CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = new List <CHL_AngularResponeWrapper.CHL_ColumnHeader>();
    	List <CHL_AngularResponeWrapper.CHL_GridData> recordList = new List <CHL_AngularResponeWrapper.CHL_GridData>();
    	boolean isFromGlobalSearch = false;
        if(CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
        	string sObjectName = CHL_Constants.OBJ_QUOTE;
        	//describe the provided sObject  
			Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
			Schema.DescribeSObjectResult res = globalDescribe.get(sObjectName).getDescribe();  
			//get the fields set map  
			quoteFsMap = res.fieldSets.getMap();
			//String nameSpacePrefix = CSM_Util.getNamespace();
       		if (quoteFsMap.containsKey(CHL_Util.quoteExtnNameSpace + CHL_Constants.QUOTE_DETAILS_FIELDSET_NAME)) {
       			List <SObject> quoteList = new List <sObject>();
       			//this.gridInputWrapper.q = 'global';
       			if(this.gridInputWrapper.q != null && String.isNotBlank(this.gridInputWrapper.q))	{
       				quoteList = CHL_QuoteDataAccess.getQuotesBySOSL(this.gridInputWrapper);
			    	isFromGlobalSearch = true;
			    	recordList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(quoteList, CHL_Util.quoteExtnNameSpace+CHL_Constants.QUOTE_DETAILS_FIELDSET_NAME, CHL_Constants.OBJ_QUOTE);
				} else {
	       			set<Id> partnerOptyIds = new set<Id>{gridInputWrapper.queryparams.oppId};
	       			quoteList = CHL_QuoteDataAccess.getQuotesListFromFieldSet(partnerOptyIds, CHL_Util.quoteExtnNameSpace+CHL_Constants.QUOTE_DETAILS_FIELDSET_NAME);
	       			isFromGlobalSearch = false;
	       			recordList = CHL_ResponseWrapperUtil.getRecordDetailsListFromFieldSet(quoteList, CHL_Util.quoteExtnNameSpace+CHL_Constants.QUOTE_DETAILS_FIELDSET_NAME, CHL_Constants.OBJ_QUOTE, gridInputWrapper.queryparams.oppId);	       			
	       		}
	       		colHeaderList = CHL_ResponseWrapperUtil.getColumnHeaderFromFieldSet(CHL_Util.quoteExtnNameSpace+CHL_Constants.QUOTE_DETAILS_FIELDSET_NAME, CHL_Constants.OBJ_QUOTE,isFromGlobalSearch);
       			
       		}
        }
    	Boolean selectionNeeded = this.gridInputWrapper.q != null && String.isNotBlank(this.gridInputWrapper.q) ? false : true;	
   		CHL_AngularResponeWrapper quoteWrap = new CHL_AngularResponeWrapper();
   		quoteWrap.columnHeader = colHeaderList;
   		quoteWrap.gridData = recordList;
   		quoteWrap.gridConfiguration = CHL_Util.getGridExportOptions(false,'',selectionNeeded);
   		//system.debug(' \n\n QuoteList --- :: ' + json.serialize(quoteWrap));
   		return quoteWrap;
       	//return null;
    }
    
}