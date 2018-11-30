/**
 * Created Date		: Nov 30, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Business layer for Segment Details page
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1863					Nov 30, 2016	1.0					Initial development
 *
 */
public with sharing class REN_SegmentDetailBusinessLayer extends CSM_BusinessLayer{
	private  List<Schema.FieldSetMember> fieldSetMemberList =  null;
    private String namespace;
    
    public REN_SegmentDetailBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
        
        if(this.inputWrapper.params.selectedTaskFilter == REN_Constants.OBJ_SE_TYPE_ABRLM) {
        	fieldSetMemberList =  SObjectType.Asset.FieldSets.REN_Asset_Segment_Columns.getFields();
    	} else if(this.inputWrapper.params.selectedTaskFilter == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH) {
    		fieldSetMemberList =  SObjectType.Opportunity.FieldSets.REN_Opportunity_Segment_Columns.getFields();
    	}
        system.debug('this.inputWrapper.params.selectedTaskFilter----'+this.inputWrapper.params.selectedFilterClause);
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
			gridColumnWrapper.label = fld.getLabel();
			gridColumnWrapper.valueCol = fldpath;
			gridColumnWrapper.dataType = ''+fld.getType();
		
            if(fldpath.contains('Contact.Id')){
                    gridColumnWrapper.valueCol = fldpath.replaceAll('Contact.Id', 'Contact.Name');
            }
            
			if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fldpath.contains('.')){
				if(fldpath.contains('REN_Contract_Line_Item__c')){
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
					 || fld.getType().equals(Schema.DisplayType.INTEGER)){			
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

		if(this.inputWrapper.params.selectedTaskFilter == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH) {
		if(CSM_AccessController.hasField(REN_Constants.OBJ_OPPORTUNITY,'SyncedQuoteId')){
			gridColumnWrapper = new CSM_GridColumnWrapper();
        	gridColumnWrapper.apiName = 'SyncedQuote.Name';
        	gridColumnWrapper.label = 'Synced Quote';
        	gridColumnWrapper.valueCol = 'SyncedQuote.Name';
       		gridColumnWrapper.isSortable = true;
        	gridColumnWrapper.customColumnSorter = 'customColumnSorter'; 
        	gridColumnWrapper.dataAlign = 'right';
        	gridColumnWrapper.isNumberCol = true;
        	gridColumnWrapperList.add(gridColumnWrapper);
		}
		if(!fieldSet.contains('contactid')){
			gridColumnWrapper = new CSM_GridColumnWrapper();
    		gridColumnWrapper.apiName = 'contactid';
    		gridColumnWrapper.label = 'Contact';
   	 		gridColumnWrapper.valueCol = 'contactid';
        	
    		gridColumnWrapper.isSortable = true;
    		gridColumnWrapper.customColumnSorter = 'customColumnSorter'; 
    		gridColumnWrapper.dataAlign = 'right';
    		gridColumnWrapperList.add(gridColumnWrapper);
		}
		if(!fieldSet.contains('contactid')){
			gridColumnWrapper = new CSM_GridColumnWrapper();
    		gridColumnWrapper.apiName = 'contact.Email';
    		gridColumnWrapper.label = 'Contact Email';
   	 		gridColumnWrapper.valueCol = 'contact.Email';
        	
    		gridColumnWrapper.isSortable = true;
    		gridColumnWrapper.customColumnSorter = 'customColumnSorter'; 
    		gridColumnWrapper.dataAlign = 'right';
    		gridColumnWrapperList.add(gridColumnWrapper);
		}	
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
	        List<Sobject> records;
	        	        
	        CSM_Admin__c adminSettings = CSM_Admin__c.getInstance();
	        Integer recordLimit = Integer.valueOf(adminSettings.REN_Segment_Members_Limit__c);
	        if(recordLimit == null) {
	        	recordLimit = 1000;
	        }
			String filter = '';
            system.debug('this.inputWrapper.params.selectedFilterClause --------------'+this.inputWrapper.params.selectedFilterClause);
			if(string.isNotEmpty(this.inputWrapper.params.selectedFilterClause) && this.inputWrapper.params.selectedFilterClause != null && !this.inputWrapper.params.selectedFilterClause.equals('error')) {
				filter = ' WHERE ' + this.inputWrapper.params.selectedFilterClause;
			}
			system.debug('filter --------------'+filter);
			
            
            if(!this.inputWrapper.params.selectedFilterClause.equals('error')) {
	        	if(this.inputWrapper.params.selectedTaskFilter == REN_Constants.OBJ_SE_TYPE_ABRLM) {
                	records = new List<Asset>();
	        		records = REN_AssetDataAccess.getAssetsByIds(fieldSetMemberList,new Set<String>{ this.inputWrapper.params.opptyId },filter,recordLimit,this.inputWrapper.params.accountId);
                
	        	} else if(this.inputWrapper.params.selectedTaskFilter == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH) {
	        	
                	records = new List<Opportunity>();
					if(string.isNotEmpty(this.inputWrapper.params.taskOrViewId) && (this.inputWrapper.params.taskOrViewId).contains('true')==true){
                		List<Opportunity> OppWithCR = REN_OpportunityDataAccess.getOpportunitiesByIdsWithContactRole(fieldSetMemberList,new Set<String>{ this.inputWrapper.params.opptyId },filter,recordLimit); 
               	 		Set<ID> UpdatedrecordIds = new Set<ID>();
                    	Set<ID> recordwithoutemail = new Set<ID>();
                    	for(Opportunity oppt:OppWithCR){
                        	if(oppt.OpportunityContactRoles.isEmpty()){
                            	UpdatedrecordIds.add((String)oppt.get('id'));
                        	}else{
                            	recordwithoutemail.add((String)oppt.get('id'));
                        	}
                    	}
                		records.clear();
                		list<OpportunityContactRole> cr=REN_OpportunityDataAccess.getOpportunityContactRoleswithoutcontact(recordwithoutemail);
                		Set<ID> op=new Set<ID>();
                		for(OpportunityContactRole c:cr){
                    		UpdatedrecordIds.add(c.OpportunityId );
                		}
               			records = REN_OpportunityDataAccess.getOpportunitiesByIdsWithInvalidContact(fieldSetMemberList,UpdatedrecordIds,recordLimit); 
               		}else{
                     	List<Opportunity> OppWithCR = REN_OpportunityDataAccess.getOpportunitiesByIdsWithContactRole(fieldSetMemberList,new Set<String>{ this.inputWrapper.params.opptyId },filter,recordLimit); 
               	 		Set<ID> UpdatedrecordIds = new Set<ID>();
                    	Set<ID> recordwithoutemail = new Set<ID>();
                    	for(Opportunity oppt:OppWithCR){
                        	if(!oppt.OpportunityContactRoles.isEmpty()){
                            	recordwithoutemail.add((String)oppt.get('id'));
                        	}
                    	}
                		records.clear();
                		list<OpportunityContactRole> cr=REN_OpportunityDataAccess.getOpportunityContactRoleswithcontact(recordwithoutemail);
                		Set<ID> op=new Set<ID>();
                		for(OpportunityContactRole c:cr){
                    		UpdatedrecordIds.add(c.OpportunityId );
                		}
               			records = REN_OpportunityDataAccess.getOpportunitiesByIdsWithInvalidContact(fieldSetMemberList,UpdatedrecordIds,recordLimit);  
                   	}
            	}else{
             		records=NULL;
           		}
			}
	        	        
	    	if (records != null && !records.isEmpty()){
                Boolean isMC = CSM_Util.checkMCEnabled();
	    		for(SObject record : records) {
	        		CSM_GridRowWrapper row = new CSM_GridRowWrapper();
                	row.id = (String) record.get('Id');
                	row.sObj = record;
                	row.columns = new List<CSM_GridColumnWrapper>();
                	row.namespace = this.namespace;
                	row.columns = colList;
                	row.hasGridImage = true;
                    row.isMC = isMC;
					gridRowWrapper.add(row);
	      		}
	   		}
    	}
    	return gridRowWrapper;
    }
}