public with sharing class REN_CommonSearchBusinessLayer extends CSM_BusinessLayer {

	private List<Schema.FieldSetMember> fieldSetMemberList = null;
    private List<String> parentIDList;
	private String objectName;
	private String fieldSetName;
    private Boolean hasMassUpdateAccess;
    private Integer recordLimit;
    
    
	public REN_CommonSearchBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
        if(inputWrapper.params.IdSet!=null){
           parentIDList = inputWrapper.params.idSet;
        }
        if(inputWrapper.params.objectName!=null){
         	objectName = inputWrapper.params.objectName;
        }
        if(inputWrapper.params.fieldSetName!=null){
         	fieldSetName = inputWrapper.params.fieldSetName;
        }
        if(inputWrapper.params.hasMassUpdateAccess != null){
            hasMassUpdateAccess = inputWrapper.params.hasMassUpdateAccess;
        }
        if(inputWrapper.params.recordLimit != null){
            recordLimit = inputWrapper.params.recordLimit;
        }
        system.debug('@@@@@@@@ parentIDSet :: '+ parentIDList + '@@ objectName' + objectName +'@@ fieldSetName' + fieldSetName + '@@ hasMassUpdateAccess ' + hasMassUpdateAccess);
    }

	public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
    	//try{
        	return getCommonSearchWrapper();
    	/*}catch(Exception e){
    		system.debug('Exception: ' + e);
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.getMessage()));
    	}
    	return null;*/
    }

	private List<sObject>  getParentObjRecords(List<String> parentObjIdSet,String objectName, String fieldSetName){
        Set<String> fieldNameSet = new Set<String>();
        if(String.isNotBlank(fieldSetName)){
            fieldNameSet = CHL_Util.getFieldsFromFieldSet(fieldSetName, objectName);
        } else {
            fieldNameSet.add('id');
            if (CSM_AccessController.hasField(objectName, 'Name')){
                fieldNameSet.add('Name');
            }
        }
       Set<String> firstFilterSet = new Set<String>();
       firstFilterSet.addAll(parentIDList);
       
       String fieldSelectSOQL;
       if(String.isNotBlank(fieldSetName)){
       	   List <Schema.FieldSetMember> fieldSetMemberList = CHL_Util.getFieldSet(fieldSetName, objectName); 
       	   fieldSelectSOQL = REN_Util.getSelectSOQLFieldStr(objectName, fieldSetMemberList, null);
       } else {
       	   fieldSelectSOQL = (CSM_AccessController.hasField(objectName, 'Name')) ? ' ID,Name ' : ' ID ';
       }
       
       if(recordLimit == null){
           recordLimit = (Integer)CSM_Admin__c.getInstance().REN_Custom_Search_Records_Limit__c;
       }
       system.debug('$$$$ fieldSelectSOQL '+ fieldSelectSOQL + ' $$$$ firstFilterSet '+ firstFilterSet);
       List<sObject> parentSObjectList =  REN_OpportunityDataAccess.getObjectRecordsList(objectName, fieldSelectSOQL, ' ID IN :firstFilterSet ', firstFilterSet, recordLimit);
       system.debug('$$$$ parentSObjectList '+ parentSObjectList);
       return parentSObjectList;        
    }

	private CSM_GridResponseWrapper getCommonSearchWrapper(){
        CSM_GridResponseWrapper gridResponseWrapper = new CSM_GridResponseWrapper();
        gridResponseWrapper.header = setGridHeader();
        gridResponseWrapper.hasAction = false;
        gridResponseWrapper.hasDetail = false;
        gridResponseWrapper.hasCheckbox = (objectName == 'Opportunity') ? true : hasMassUpdateAccess;
        List<sObject> parentRecList = getParentObjRecords(parentIDList, objectName, fieldSetName);
        gridResponseWrapper.row = setGridRows(parentRecList, gridResponseWrapper.header);
        return gridResponseWrapper;
    }

	private List<CSM_GridRowWrapper> setGridRows(List<sObject> parentRecList, List<CSM_GridColumnWrapper> colList) {
        system.debug('$$$$ parentRecList ::  '+ parentRecList);
        system.debug('$$$$ colList ::  '+ colList);
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
        String clmNamespace = CSM_Util.getNamespace();
        if(parentRecList != null && !parentRecList.isEmpty()) {
            Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
            String userLocale = UserInfo.getLocale();           
            String reasonCode='';
            for(sObject sObj : parentRecList) {
                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
                row.id = (String)sObj.get('Id');
                row.sObj = sObj;
                row.isMC = CSM_Util.checkMCEnabled();
                row.columns = new List<CSM_GridColumnWrapper>();
                row.namespace = clmNamespace;
                reasonCode='';
                if (colList!=null){
                   row.columns = colList;
                   gridRowWrapper.add(row); 
                }
            }
        }
         return gridRowWrapper;
    }

	private List<CSM_GridColumnWrapper> setGridHeader(){
        List<CSM_GridColumnWrapper> gridColumnWrapperList = new List<CSM_GridColumnWrapper>();
        CSM_GridColumnWrapper gridColumnWrapper = null;
        Set<String> fieldSet = new Set<String>();
        String fldpath ='';
        String nameSpace = CSM_Util.getNamespace();
    	if(String.isNotBlank(fieldSetName)){
	        List<Schema.FieldSetMember> fieldSetMemberList = CHL_Util.getFieldSet(fieldSetName, ObjectName);
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
	            if(fldpath.contains('CaseNumber')){
	            	gridColumnWrapper.lookUpIdCol = 'Id';
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
		}else{
            gridColumnWrapper = new CSM_GridColumnWrapper();
            gridColumnWrapper.apiName = 'Id';
            gridColumnWrapper.label = 'Id';
            gridColumnWrapper.valueCol = 'Id';
            gridColumnWrapper.lookUpIdCol = 'Id';
            gridColumnWrapper.isVisible = true;
            gridColumnWrapper.isSwitchable = false;
            gridColumnWrapper.isSortable = true;
            
            gridColumnWrapperList.add(gridColumnWrapper);   
         
	        if (CSM_AccessController.hasField(objectName, 'Name')){
	            gridColumnWrapper = new CSM_GridColumnWrapper();
	            gridColumnWrapper.apiName = 'Name';
	            gridColumnWrapper.label = 'Name';
	            gridColumnWrapper.valueCol = 'Name';
	            gridColumnWrapper.isDateCol = false;
	            gridColumnWrapper.isSortable = true;
	            gridColumnWrapper.isVisible = true;
	            gridColumnWrapper.dataType = 'STRING';
	            gridColumnWrapperList.add(gridColumnWrapper);
	         }
    	}
        return gridColumnWrapperList;
    }

}