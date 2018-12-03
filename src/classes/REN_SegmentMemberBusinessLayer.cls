public with sharing class REN_SegmentMemberBusinessLayer extends CSM_BusinessLayer{
    
    private String namespace;
    public REN_SegmentMemberBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
        return getSMWrapperList();
    }
    
    private CSM_GridResponseWrapper getSMWrapperList(){
        //business logic for setting up Lists for <CSM_GridRowWrapper> and <CSM_GridColumnWrapper>
        CSM_GridResponseWrapper SMWrapperList = new CSM_GridResponseWrapper();
        this.namespace = CSM_Util.getNamespace();
        List<sObject> SMList;   
        System.debug('selectedTaskFilter='+this.inputWrapper.params.selectedTaskFilter);
        if(this.inputWrapper.params.selectedTaskFilter == REN_Constants.OBJ_SE_TYPE_ABRLM) {
        	SMWrapperList.header = setSMHeader();
    	} else if(this.inputWrapper.params.selectedTaskFilter == REN_Constants.OBJ_SE_TYPE_LOW_TOUCH) {
    		SMWrapperList.header = setSMHeaderForOpp();
    	}
	  	SMList = REN_SegmentMemberDataAccess.getSegmentMembersForClause(this.inputWrapper.params.selectedFilterClause);
	    system.debug(+SMList.isEmpty());
        SMWrapperList.hasCheckbox = true;
        SMWrapperList.hasDetail = false;
        //setup the CSM_GridRowWrapper for the column values to be fed in it, maintain the order in which the headers are created.
        SMWrapperList.row = setSMRows(SMList, SMWrapperList.header);
        return SMWrapperList;
    }

	private List<CSM_GridRowWrapper> setSMRows(List<sObject> SMList, List<CSM_GridColumnWrapper> colList){
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
        if(SMList != null && !SMList.isEmpty()){
            for(sObject sObj : SMList){
                system.debug('Not empty');
                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
              
                row.id = (String)sObj.get('Id');
                row.sObj = sObj;
				row.namespace = this.namespace;
                row.columns = new List<CSM_GridColumnWrapper>();
               	if (colList!=null){
					row.columns = colList;
            	    gridRowWrapper.add(row);
                    system.debug(' row.sObj------------------------->'+ row.sObj);
				}
			}
        }
		return gridRowWrapper;
	}
    
	private List<CSM_GridColumnWrapper> setSMHeader(){
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

        //CAUTION: The order has te be maintained for the headers to be set and the response columns
       CSM_GridColumnWrapper colNew = new CSM_GridColumnWrapper();
 	 	colNew.apiName = 'REN_Asset__c';
        colNew.label = 'Asset';
        colNew.valueCol = 'REN_Asset__r.Name';
        //colNew.lookUpId = 'Name';
        colNew.lookUpIdCol = '';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(colNew);	
        
         colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'Product2.Name';
        colNew.label = 'Product Name';
        colNew.valueCol = 'REN_Asset__r.Product2.Name';
        colNew.lookUpIdCol = '';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName ='Account.Name';
        colNew.label = Schema.SobjectType.Account.fields.Name.label;
        colNew.valueCol = 'REN_Asset__r.Account.Name';
        colNew.lookUpIdCol = 'AccountId';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(colNew);

        //Close Date
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'REN_Start_Date__c';
		colNew.label = 'Start Date';
		colNew.valueCol = 'REN_Asset__r.REN_Start_Date__c';
		colNew.isSortable = true;
		colNew.isDateCol = true;
		gridClmWrapper.add(colNew);
        
  		//Close Date
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'REN_End_Date__c';
		colNew.label = 'End Date';
		colNew.valueCol = 'REN_Asset__r.REN_End_Date__c';
		colNew.isSortable = true;
		colNew.isDateCol = true;
		gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'Price';
        colNew.label = 'Price'+ ' ('+UserInfo.getDefaultCurrency() +')';
        colNew.valueCol = 'REN_Asset__r.Price';
        colNew.isSortable = true;
        colNew.isCurrencyCol=true;
        colNew.customColumnSorter = 'customColumnSorter'; 
        colNew.dataAlign = 'right';
       // colNew.isNumberCol = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Asset__r.Contact.Name';
        colNew.label = 'ContactID';
        colNew.valueCol = 'REN_Asset__r.Contact.Name';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter'; 
        colNew.dataAlign = 'right';
        colNew.isNumberCol = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'Id';
		colNew.label = 'Id';
		colNew.valueCol = 'Id';
		colNew.lookUpIdCol = 'Id';
		colNew.isVisible = false;
		colNew.isSwitchable = false;
		colNew.isSortable = true;
		gridClmWrapper.add(colNew); 
        
        return gridClmWrapper;
    }
    
    private List<CSM_GridColumnWrapper> setSMHeaderForOpp(){
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();
 		String nameSpacePrefix = CSM_Util.getNamespace();
        //CAUTION: The order has te be maintained for the headers to be set and the response columns
        CSM_GridColumnWrapper colNew = new CSM_GridColumnWrapper();
        
        //Opportunity       
        colNew.apiName = 'REN_Opportunity__c';
        colNew.label = 'Opportunity Name';
        colNew.valueCol = nameSpacePrefix + 'REN_Opportunity__r.Name';
        colNew.lookUpIdCol = '';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName ='Account.Name';
        colNew.label = 'Account Name';
        colNew.valueCol = 'REN_Opportunity__r.Account.Name';
        colNew.lookUpIdCol = 'AccountId';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(colNew);

        //Sales Stage
       	colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'StageName';
		colNew.label = Schema.SobjectType.Opportunity.fields.StageName.label;
		colNew.valueCol = 'REN_Opportunity__r.StageName';
		colNew.isSortable = true;
        colNew.isCurrencyCol=true;
        colNew.customColumnSorter = 'customColumnSorter'; 
        colNew.dataAlign = 'right';
        //colNew.isNumberCol = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Renewal_Target__c';
        colNew.label = 'Renewal Target' + ' ('+UserInfo.getDefaultCurrency() +')';
        colNew.valueCol = 'REN_Opportunity__r.REN_Renewal_Target__c';
        colNew.isSortable = true;
        colNew.isCurrencyCol=true;
        colNew.customColumnSorter = 'customColumnSorter'; 
        //colNew.dataAlign = 'right';
        colNew.isNumberCol = true;
        gridClmWrapper.add(colNew);
        
        //Close Date
		colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'CloseDate';
		colNew.label = Schema.SobjectType.Opportunity.fields.CloseDate.label;
		colNew.valueCol = 'REN_Opportunity__r.CloseDate';
		colNew.isSortable = true;
		colNew.isDateCol = true;
		gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Opportunity__r.Owner.Name';
        colNew.label = 'Owner';
        colNew.valueCol = 'REN_Opportunity__r.Owner.Name';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter'; 
        colNew.dataAlign = 'right';
        colNew.isNumberCol = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
        colNew.apiName = 'REN_Segment_Primary_Contact__r.Name';
        colNew.label = 'ContactID';
        colNew.valueCol = 'REN_Segment_Primary_Contact__r.Name';
        colNew.isSortable = true;
        colNew.customColumnSorter = 'customColumnSorter'; 
        colNew.dataAlign = 'right';
        colNew.isNumberCol = true;
        gridClmWrapper.add(colNew);
        
        colNew = new CSM_GridColumnWrapper();
		colNew.apiName = 'Id';
		colNew.label = 'Id';
		colNew.valueCol = 'Id';
		colNew.lookUpIdCol = 'Id';
		colNew.isVisible = false;
		colNew.isSwitchable = false;
		colNew.isSortable = true;
		gridClmWrapper.add(colNew); 
		
		if(CSM_AccessController.hasField('REN_Segment_Member__c',CHL_Util.quoteExtnNameSpace + 'REN_SyncedQuote_Id__c')){
        	system.debug('Inside the loop');
        	system.debug('CHL_Util.quoteExtnNameSpace'+CHL_Util.quoteExtnNameSpace);               
	        colNew = new CSM_GridColumnWrapper();
	        colNew.apiName = CHL_Util.quoteExtnNameSpace + 'REN_SyncedQuote_Id__c';
	        colNew.label = 'Synced Quote';
	        colNew.valueCol = CHL_Util.quoteExtnNameSpace + 'REN_SyncedQuote_Id__r.Name';
	       	colNew.isSortable = true;
	        colNew.customColumnSorter = 'customColumnSorter'; 
	        colNew.dataAlign = 'right';
	        colNew.isNumberCol = true;
	        gridClmWrapper.add(colNew);
	    }
		      
		return gridClmWrapper;
    }
    
}