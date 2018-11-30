/**
 * Created Date		: Nov 21, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Business layer for Opportunity split - Opportuntiy line items
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1760					Nov 21, 2016	1.0					Initial development
 *
 */
public with sharing class REN_OpptSplitWizardOLIBusinessLayer extends CSM_BusinessLayer {
	private String namespace;
	 private  List<Schema.FieldSetMember> fieldSetMemberList =  null;
    
    public REN_OpptSplitWizardOLIBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
        fieldSetMemberList =  SObjectType.OpportunityLineItem.FieldSets.REN_Product_Line_Items_on_Split.getFields();        
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){        
        CSM_GridResponseWrapper pbResponseWrapper = new CSM_GridResponseWrapper();
        this.namespace = CSM_Util.getNamespace();
        
        try
        {
            pbResponseWrapper.header = getGridHeader();
            pbResponseWrapper.row = getGridRows(pbResponseWrapper.header);
            pbResponseWrapper.hasCheckbox = true;
            pbResponseWrapper.hasAction = false;
            pbResponseWrapper.hasDetail = false;
        }
        catch(Exception e)
        {
            pbResponseWrapper.errorMessage = e.getMessage();
            system.debug(e);
        }
        
        return pbResponseWrapper;
    }
    
	/*
	** @Description: Gets grid header details
	** @returns: List of grid column objects
	*/
    private List<CSM_GridColumnWrapper> getGridHeader() {
    	List<CSM_GridColumnWrapper> gridColumnWrapperList = new List<CSM_GridColumnWrapper>();
        CSM_GridColumnWrapper gridColumnWrapper = null;
		
		Set<String> fieldSet = new Set<String>();
		String fldpath ='';

		for(Schema.FieldSetMember fld :fieldSetMemberList){
			fldpath = fld.getFieldPath();

			fieldSet.add(fldpath);
			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = fldpath;
			system.debug('fld.getFieldPath::'+fldpath);
			gridColumnWrapper.label = fld.getLabel();
			gridColumnWrapper.valueCol = fldpath;
			gridColumnWrapper.dataType = ''+fld.getType();
			
			if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fldpath.contains('.')){
				if(fldpath.contains('REN_Contract_Line_Item__c')){ //****
					gridColumnWrapper.valueCol = fldpath.replace('__c', '__r') +'.LineItemNumber';
				}else {
					gridColumnWrapper.valueCol = fldpath.removeEndIgnoreCase('Id').replace('__c', '__r') +'.Name';
				}
				gridColumnWrapper.lookUpIdCol = fldpath;				
			}else if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DATETIME) ){
				gridColumnWrapper.isDateCol = true;
			}
			
			gridColumnWrapper.isSortable = true;
			gridColumnWrapper.customColumnSorter = 'customColumnSorter';
			gridColumnWrapper.isCurrencyCol = false;
			if(fld.getType().equals(Schema.DisplayType.CURRENCY)){
				gridColumnWrapper.dataAlign = 'right';
				gridColumnWrapper.label = gridColumnWrapper.label + ' ('+UserInfo.getDefaultCurrency() +')';	    	
		     	gridColumnWrapper.isCurrencyCol = true;
			}
			if (fld.getType().equals(Schema.DisplayType.DOUBLE)
					 || fld.getType().equals(Schema.DisplayType.INTEGER)) 
			{			
                gridColumnWrapper.dataAlign = 'right';
            }
			
			gridColumnWrapper.isDateCol = fld.getType().equals(Schema.DisplayType.DATE)?true:false;

			gridColumnWrapperList.add(gridColumnWrapper);
		}      
		 
		if(!fieldSet.contains('Id')){
			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = 'Id';
			gridColumnWrapper.label = 'Id';
			gridColumnWrapper.valueCol = 'Id';
			gridColumnWrapper.lookUpIdCol = 'Id';
			gridColumnWrapper.isVisible = false;
			gridColumnWrapper.isSwitchable = false;
			gridColumnWrapper.isSortable = true;
			gridColumnWrapperList.add(gridColumnWrapper); 	
		}
		
        return gridColumnWrapperList;
    }
    
    /*
    ** @description: Gets grid rows
    ** @returns: List of grid row objects
    */
    private List<CSM_GridRowWrapper> getGridRows(List<CSM_GridColumnWrapper> colList){
    	List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
    	
    	if(colList!=null) {
	        Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
	        String userLocale = UserInfo.getLocale();
	        List<Sobject> olis = new List<CSM_Batch_Filter__c>();
	        
	        String filterStr = ' Opportunity.Id = \''+ this.inputWrapper.params.opptyId + '\'';
	        
	        olis = REN_OpportunityLineItemDataAccess.getDataUsingFieldSet(
															fieldSetMemberList,
															new Set<String>{'Id'},
															filterStr);
	        
	        system.debug('^^^^ olis: ' + olis);
	        	        
	        if (olis != null && !olis.isEmpty()){
	            for(SObject oli : olis) {
	                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
	                row.id = (String) oli.get('Id');
	                row.sObj = oli;
	                row.columns = new List<CSM_GridColumnWrapper>();
	                row.namespace = this.namespace;
	                row.columns = colList;
	                row.hasGridImage = true;
	                	                
	                gridRowWrapper.add(row);
	            }
	        }
    	}
        
        return gridRowWrapper;
    }
}