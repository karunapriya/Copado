public with sharing class REN_RenewRelationshipBusinessLayer extends CSM_BusinessLayer {

 private CSM_User_Preferences__c userPreferenceObj = new CSM_User_Preferences__c();
 private  List<Schema.FieldSetMember> fieldSetMemberList =  null;
 
 
    public REN_RenewRelationshipBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
        userPreferenceObj = CSM_UserPreferencesDataAccess.getUserPreferences(UserInfo.getUserId(),'REN_Manage_RR_Grid_Columns__c');
        fieldSetMemberList =  SObjectType.REN_Renews_To__c.FieldSets.REN_ManageRenewals_Fieldset.getFields();        
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
        return getRenewalRelationShipWrapperList();
    }
    
    private CSM_GridResponseWrapper getRenewalRelationShipWrapperList()
    {
        CSM_GridResponseWrapper renewalRelationshipWrapperList = new CSM_GridResponseWrapper();
        
       	try{
	        
	        renewalRelationshipWrapperList.header = setRenRelListHeader();
	        renewalRelationshipWrapperList.hasAction = false;
	        renewalRelationshipWrapperList.hasDetail = false;
	        renewalRelationshipWrapperList.hasCheckbox = true;
	        List<REN_Renews_To__c> RRlist;
			 RRlist = getRecordList();
	        renewalRelationshipWrapperList.row = setRenRelationshipRows(RRlist, renewalRelationshipWrapperList.header);
		    system.debug('\n\n~~~gridResponseWrapper: '+renewalRelationshipWrapperList);
		  
       	} catch(Exception e) {
			renewalRelationshipWrapperList.errorMessage = e.getMessage(); 
			system.debug(e.getStackTraceString());      		
       	}
       	
       	//renewalRelationshipWrapperList.row = setRenRelationshipRows(getRecordList(), renewalRelationshipWrapperList.header);
       	system.debug('renewalRelationshipWrapperList-----'+renewalRelationshipWrapperList);
       	 return renewalRelationshipWrapperList;
    } 
    
	private List<REN_Renews_To__c> getRecordList(){
		String filterStr = ' REN_Renews_To__c = \''+this.inputWrapper.params.opptyId + '\''; 
		//List<REN_Renews_To__c> renewalRelationShipList = REN_RenewRelationshipDataAccess.getRenewalRelationshipForOppty(this.inputWrapper.params.opptyId);
		String nameSpace = CSM_Util.getNamespace();//Added 2419
		List<REN_Renews_To__c> renewalRelationShipList = REN_RenewRelationshipDataAccess.getDataUsingFieldSet(
														nameSpace + REN_Constants.OBJ_REN_RENEWS_TO,
														fieldSetMemberList, new Set<String>{nameSpace +'REN_Product__c'} ,
														filterStr);
		
		system.debug('renewalRelationshipList::' + renewalRelationShipList);
		return renewalRelationShipList;
		
	}  
	
	private List<CSM_GridRowWrapper> setRenRelationshipRows(List<sObject> renewalRelationShipList, List<CSM_GridColumnWrapper> colList) {
		//US3335 
		List<OpportunityLineItem> lstOfOLI = REN_OpportunityLineItemDataAccess.getOpportunityLineItemList(new set<String>{this.inputWrapper.params.opptyId});
		Map<Id, Id> rliToOliMap = new Map<Id, Id>();
		Set<Id> validOliIdSet = new Set<Id>();
		for (OpportunityLineItem oli : lstOfOLI) {
        	rliToOliMap.put(oli.REN_Renewable_Line_Item__c, oli.Id);
        	validOliIdSet.add(oli.Id);
        }

		List<OpportunityLineItem> opportunityProductList = REN_OpportunityLineItemDataAccess.getOpportunityProducts(this.inputWrapper.params.opptyId, validOliIdSet);
		system.debug('opportunityProductList::'+opportunityProductList);
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
        Map<Id, String> opptyLineItemMap = new Map<Id, String>();
        String clmNamespace = CSM_Util.getNamespace();
       if(opportunityProductList != null && !opportunityProductList.isEmpty()) {
        	for(OpportunityLineItem sObjOpptyProduct : opportunityProductList) {
        		opptyLineItemMap.put(sObjOpptyProduct.id, sObjOpptyProduct.Product2.name);
        	}
        }
        
		if(renewalRelationShipList != null && !renewalRelationShipList.isEmpty()) {
            Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
            String userLocale = UserInfo.getLocale();			
			
			for(sObject sObj : renewalRelationShipList) {
				System.debug('ZZZ - '+sObj);
				CSM_GridRowWrapper row = new CSM_GridRowWrapper();

				row.id = (String)sObj.get('Id');
				row.sObj = sObj;
				row.isMC = CSM_Util.checkMCEnabled();
                row.columns = new List<CSM_GridColumnWrapper>();
				row.namespace = clmNamespace;
				row.lineMap = opptyLineItemMap;
				row.opptyProduct = rliToOliMap.get(sObj.Id);
                if (colList!=null){
                   row.columns = colList;
                   gridRowWrapper.add(row);	
                }
			}
		}
         return gridRowWrapper;
	}
	   	

    private List<CSM_GridColumnWrapper> setRenRelListHeader()
    {
        List<CSM_GridColumnWrapper> gridColumnWrapperList = new List<CSM_GridColumnWrapper>();
        CSM_GridColumnWrapper gridColumnWrapper = null;
		String manageRRColumnStr = '';
		if(userPreferenceObj != null){
			if(userPreferenceObj.REN_Manage_RR_Grid_Columns__c != null){
				manageRRColumnStr  = userPreferenceObj.REN_Manage_RR_Grid_Columns__c.toLowerCase();
				system.debug(manageRRColumnStr+'Entire List in Business Layer');
			}
		}
		Set<String> fieldSet = new Set<String>();
		String fldpath ='';
		String nameSpace = CSM_Util.getNamespace();
        Map<String, Schema.SobjectField> fields = REN_Renews_To__c.getSObjectType().getDescribe().fields.getMap();
		for(Schema.FieldSetMember fld :fieldSetMemberList){
			fldpath = fld.getFieldPath();
			/*if(String.isNotBlank(nameSpace) && fldpath.startsWithIgnoreCase(nameSpace)){
				fldpath =  fldpath.removeStartIgnoreCase(nameSpace);
			}*/
			fieldSet.add(fldpath);
			gridColumnWrapper = new CSM_GridColumnWrapper();
			gridColumnWrapper.apiName = fldpath;
			system.debug('fld.getFieldPath::'+fldpath);
			gridColumnWrapper.label = fld.getLabel();
			gridColumnWrapper.valueCol = fldpath;
			gridColumnWrapper.dataType = ''+fld.getType();
			gridColumnWrapper.filterControl = 'select';
			
			if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fldpath.contains('.')){
				//US2419 
				//String fieldPath = fldpath.remove(nameSpace);
                DescribeFieldResult dfr = fields.get(fldpath).getDescribe(); //US2419 
                //DescribeFieldResult dfr = fields.get(fld.getFieldPath()).getDescribe();
            	List<Schema.SObjectType> oTypeList = dfr.getReferenceTo();
            	if(!oTypeList.isEmpty()){
            		String refObjName = oTypeList[0].getDescribe().getName();
            		if(CSM_AccessController.hasField(refObjName, 'Name')){
            			gridColumnWrapper.valueCol = dfr.getRelationshipName() + '.Name';
						gridColumnWrapper.lookUpIdCol = fldpath;				
            		}else if (fld.getFieldPath().contains('REN_Contract_Line_Item__c')){
            			gridColumnWrapper.valueCol = dfr.getRelationshipName() + '.LineItemNumber';
    					gridColumnWrapper.lookUpIdCol = fldpath;				
            		}
            	}
			}else if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DATETIME) ){
				gridColumnWrapper.isDateCol = true;
				gridColumnWrapper.filterControl = '';
				
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
			if(manageRRColumnStr.contains(gridColumnWrapper.apiName.toLowerCase())){
				gridColumnWrapper.isVisible = false;
			}
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
		
		gridColumnWrapper = new CSM_GridColumnWrapper();
		gridColumnWrapper.apiName = 'Oppty_Product';
		gridColumnWrapper.label = Label.REN_LBL_OPPORTUNITY_PRODUCT;
		gridColumnWrapper.valueCol = 'Oppty_Product';
        gridColumnWrapper.isDateCol = false;
		gridColumnWrapper.isSortable = true;
		gridColumnWrapper.isVisible = true;
		gridColumnWrapper.dataType = 'STRING';
		gridColumnWrapperList.add(gridColumnWrapper); 
        return gridColumnWrapperList;
    }
      
}