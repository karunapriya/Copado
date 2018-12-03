/**
 * Created Date		: Feb 2, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: This Business layer diplays Quote records related to Partner Opportunity.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2049					Feb 2, 2017		1.1					Added in Sprint705
 *
 */
public with sharing class CHL_QuoteOnPOBusinessLayer extends CSM_BusinessLayer {
	public Map<String, Schema.FieldSet> quoteFsMap;
	public CHL_QuoteOnPOBusinessLayer(CSM_CustomGridInputWrapper inputWrapper) {
		super(inputWrapper);
	}
	
	public override CSM_GridResponseWrapper retrieveSObjectWrapperList() {
		return getQuoteWrapperList();
	}
	
	private CSM_GridResponseWrapper getQuoteWrapperList() {
		CSM_GridResponseWrapper quoteResponseWrapper = new CSM_GridResponseWrapper();
   	    quoteResponseWrapper.hasCheckbox = false;
	    quoteResponseWrapper.hasAction = true;
	    quoteResponseWrapper.hasDetail = false;
		quoteResponseWrapper.header = setOpportunityHeader();
		quoteResponseWrapper.row = setQuoteRows(getQuoteList(), quoteResponseWrapper.header);
        return quoteResponseWrapper;
	}
	
	private List<SObject> getQuoteList() {
		List<SObject> quoteList = new List<SObject>();
		if(CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
			if (quoteFsMap.containsKey(CHL_Util.quoteExtnNameSpace + CHL_Constants.QUOTE_LIST_FIELDSET_NAME)) {
				Set<Id> partOpptyIds = new Set<Id>();
				partOpptyIds.add((Id)this.inputWrapper.params.opptyId);
				quoteList = CHL_QuoteDataAccess.getPOQuotesListFromFieldSet(partOpptyIds, CHL_Util.quoteExtnNameSpace+CHL_Constants.QUOTE_LIST_FIELDSET_NAME);
			}
		}
		return quoteList;
	}
	
	private List<CSM_GridRowWrapper> setQuoteRows(List<sObject> quoteList, List<CSM_GridColumnWrapper> colList) {
		List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
		for(sObject sObj : quoteList) {
			CSM_GridRowWrapper row = new CSM_GridRowWrapper();
			row.id = (String)sObj.get('Id');
			setRowAction(row);
			row.sObj = sObj;
			row.isMC = CSM_Util.checkMCEnabled();
			row.namespace = CHL_Util.quoteExtnNameSpace;
			row.columns = new List<CSM_GridColumnWrapper>();
			row.hasGridImage = true;
			if (colList!=null) {
				row.columns = colList;
				gridRowWrapper.add(row);
			}
		}
		return gridRowWrapper;
	}
	
	private List<CSM_GridColumnWrapper> setOpportunityHeader() {
		List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();
		CSM_GridColumnWrapper quoteColumn = new CSM_GridColumnWrapper();
		if (CSM_AccessController.hasObject(CHL_Constants.OBJ_QUOTE)) {
			string sObjectName = CHL_Constants.OBJ_QUOTE;
			Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
			Schema.DescribeSObjectResult res = globalDescribe.get(sObjectName).getDescribe();  
			quoteFsMap = res.fieldSets.getMap();
			List<Schema.FieldSetMember> fieldSetMembers = null;
			if (quoteFsMap.containsKey(CHL_Util.quoteExtnNameSpace + CHL_Constants.QUOTE_LIST_FIELDSET_NAME)) {
				fieldSetMembers = CHL_Util.getFieldSet(CHL_Util.quoteExtnNameSpace+CHL_Constants.QUOTE_LIST_FIELDSET_NAME, CHL_Constants.OBJ_QUOTE);
			}
			if(Test.isRunningTest()){
    			String namespace = CSM_Util.getNamespace();
        		fieldSetMembers = CHL_Util.getFieldSet(namespace + CHL_Constants.PARTNER_OPP_DETAILS_FIELDSET_NAME, namespace + 'CHL_Partner_Opportunity__c');
	        }
	        if(fieldSetMembers != null && !fieldSetMembers.isEmpty()) {
	        	String fieldAPIName = '';
	        	String lookupField = '';
				for(Schema.FieldSetMember fld :fieldSetMembers) {
		            quoteColumn = new CSM_GridColumnWrapper();
					quoteColumn.apiName = fld.getFieldPath();
					fieldAPIName = fld.getFieldPath();
					quoteColumn.label = fld.getLabel();	
					quoteColumn.valueCol = fld.getFieldPath();
					if(string.valueof(fld.getType()) == 'REFERENCE' && !fieldAPIName.contains('.') && !fieldAPIName.contains('Owner') && fieldAPIName.contains('__c')) {       
		                lookupField = fieldAPIName.replace('__c', '__r');
		                quoteColumn.valueCol = lookupField+'.Name';  
						quoteColumn.lookUpIdCol = fld.getFieldPath(); 	                                           
		            }
					if (String.valueOf(fld.getType()) == CHL_Constants.TYPE_DATE) {
						quoteColumn.dataType = CHL_Constants.TYPE_DATE;
						quoteColumn.isDateCol = true;
					} else if(String.valueOf(fld.getType()) == CHL_Constants.TYPE_CURRENCY) {
						quoteColumn.dataType = CHL_Constants.TYPE_CURRENCY;
						quoteColumn.isCurrencyCol = true;
					} 
					if(quoteColumn.valueCol == 'CreatedById') {
						quoteColumn.valueCol = 'CreatedBy.Name';
						quoteColumn.lookUpIdCol = fld.getFieldPath();
					}
					quoteColumn.isSortable = true;
					gridClmWrapper.add(quoteColumn);           
		        }
	        }
		}
		return gridClmWrapper;
	}
	private void setRowAction(CSM_GridRowWrapper row) {
		row.actions = new List<CSM_GridActionWrapper>();
			CSM_GridActionWrapper checkWrap = new CSM_GridActionWrapper('checkboxAction');
			checkWrap.actionName = 'uniqueCBox'+ inputWrapper.viewName;
			checkWrap.actionId = 'cbID'+ inputWrapper.viewName + '_' + row.id;
			checkWrap.classAction =  'cbGrid' + inputWrapper.viewName;
			checkWrap.actionValue = row.id;
			row.actions.add(checkWrap);
			System.debug('$$here is the checkWrap'+checkWrap);
		    
	}
}