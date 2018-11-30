/**
* Created Date    : Feb 7, 2017
* Developed By    : admin, Comity Designs, Inc.
*
* Function      : @description - Description about the functionality that the class provides
* Support Email   : email
* Version      : 1.0
*
* Modification Log
*
* Developer Name      User Story        Date      Version       Description
*____________________________________________________________________________________________________
*
* admin          User Story        Feb 7, 2017      1.1          @description
*
*/
public class CHL_PartnerOpportunitySyncBusinessLayer extends CSM_BusinessLayer{
    private  List<Schema.FieldSetMember> fieldSetMemberList =  null;
    public CHL_PartnerOpportunitySyncBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){
        return getPartnerOpportunityWrapperList();
    }
    
    private CSM_GridResponseWrapper getPartnerOpportunityWrapperList()
    {
        CSM_GridResponseWrapper PartnerOpprtunityWrapperList = new CSM_GridResponseWrapper();
        try{
            PartnerOpprtunityWrapperList.header = setPOListHeader();
            PartnerOpprtunityWrapperList.hasAction = true;
            PartnerOpprtunityWrapperList.hasDetail = false;
            PartnerOpprtunityWrapperList.hasCheckbox = false;
            list<CHL_Partner_Opportunity__c> POList=getRecordList();            
            PartnerOpprtunityWrapperList.row = setPartnerOpportunityRows(POList, PartnerOpprtunityWrapperList.header);
        }catch(Exception e) {
            PartnerOpprtunityWrapperList.errorMessage = e.getMessage(); 
            system.debug(e.getStackTraceString());              
        }
        return PartnerOpprtunityWrapperList;
    }
    private List<CHL_Partner_Opportunity__c> getRecordList(){
        set<string> oppIds=new set<string>();
        oppIds.add(this.inputWrapper.params.opptyId);
        //List<CHL_Partner_Opportunity__c> partnerOpportunityList = CHL_PartnerOpportunityDataAccess.getPartnerOpportunityByIdAndFieldSet(oppIds,fieldSetMemberList);
        List<CHL_Partner_Opportunity__c> partnerOpportunityList = CHL_PartnerOpportunityDataAccess.getPoDetailsbyFieldset(oppIds,CSM_Util.getNamespace()+'CHL_Partner_Opportunity_Sync');             
        return partnerOpportunityList;
    }  
    
    private List<CSM_GridRowWrapper> setPartnerOpportunityRows(List<sObject> sObjectList, List<CSM_GridColumnWrapper> colList) {
        list<CHL_Partner_Opportunity__c> partnerOpportunityList=(list<CHL_Partner_Opportunity__c>)sObjectList;
        List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
        Map<Id, String> partnerOppMap = new Map<Id, String>();
        String clmNamespace = CSM_Util.getNamespace();
       
        if(partnerOpportunityList != null && !partnerOpportunityList.isEmpty()) {
            Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
            String userLocale = UserInfo.getLocale();           
            
            for(sObject sObj : sObjectList) {
                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
                row.id = (String)sObj.get('Id');
                setRowAction(row);
                row.sObj = sObj;
                row.isMC = CSM_Util.checkMCEnabled();
                row.columns = new List<CSM_GridColumnWrapper>();
                row.namespace = clmNamespace;
                //row.lineMap = partnerOppMap;
                if (colList!=null){
                    row.columns = colList;
                    gridRowWrapper.add(row); 
                }
            }
        }
        system.debug('gridRowWrapper'+gridRowWrapper);
        return gridRowWrapper;
    }
    
    private List<CSM_GridColumnWrapper> setPOListHeader()
    {
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();
        CSM_GridColumnWrapper poColumn = null;
        String POColumnStr = '';     
        Set<String> fieldSet = new Set<String>();
        String fldpath ='';       
        String nameSpace = CSM_Util.getNamespace();
        fieldSetMemberList=CHL_Util.getFieldSet(nameSpace+'CHL_Partner_Opportunity_Sync',nameSpace+'CHL_Partner_Opportunity__c');
        
        if(fieldSetMemberList != null && !fieldSetMemberList.isEmpty()) {
        	String fieldAPIName = '';
       		String lookupField;
			for(Schema.FieldSetMember fld :fieldSetMemberList) {
	            poColumn = new CSM_GridColumnWrapper();
	            fldpath = fld.getFieldPath();
				poColumn.apiName = fld.getFieldPath();
				fieldAPIName = fld.getFieldPath();
				poColumn.label = fld.getLabel();	
				poColumn.valueCol = fld.getFieldPath();
				if(string.valueof(fld.getType()) == 'REFERENCE' && !fieldAPIName.contains('.') && !fieldAPIName.contains('Owner') && fieldAPIName.contains('__c')) {       
	                lookupField = fieldAPIName.replace('__c', '__r');
	                poColumn.valueCol = lookupField+'.Name';  
					poColumn.lookUpIdCol = fld.getFieldPath(); 	                                           
	            }
				if (String.valueOf(fld.getType()) == CHL_Constants.TYPE_DATE) {
					poColumn.dataType = CHL_Constants.TYPE_DATE;
					poColumn.isDateCol = true;
				} else if(String.valueOf(fld.getType()) == CHL_Constants.TYPE_CURRENCY) {
					poColumn.dataType = CHL_Constants.TYPE_CURRENCY;
					poColumn.isCurrencyCol = true;
				} 
				if(poColumn.valueCol == 'CreatedById') {
					poColumn.valueCol = 'CreatedBy.Name';
					poColumn.lookUpIdCol = fld.getFieldPath();
				}
				poColumn.isSortable = true;
				gridClmWrapper.add(poColumn);           
	        }
	        if(!fieldSet.contains('Id')){
	            poColumn = new CSM_GridColumnWrapper();
	            poColumn.apiName = 'Id';
	            poColumn.label = 'Id';
	            poColumn.valueCol = 'Id';
	            poColumn.lookUpIdCol = 'Id';
	            poColumn.isVisible = false;
	            poColumn.isSwitchable = false;
	            poColumn.isSortable = true;
	            gridClmWrapper.add(poColumn);   
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