/**
  * @description : CHL_CaseBusinessLayer class is used to return JSON response to show all  the cases related to logged-in user .
    @Params : It accepts input from CHL_GridInputWrapper.
*/
public with sharing class CHL_SalesRequestBusinessLayer {
    
     public CHL_GridInputWrapper inputWrapper;  
    
     public CHL_SalesRequestBusinessLayer(CHL_GridInputWrapper inputWrapper){
        this.inputWrapper = inputWrapper;
    }
    
    public CHL_AngularResponeWrapper constructGridWrapper() {
        List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = getColumnHeader();
        List<SObject> caseList = getRecordList();
        List<CHL_AngularResponeWrapper.CHL_GridData> recordList = getRecordDetailsList(caseList); 
    	Boolean selectionNeeded = this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q) ? false : true;	
        CHL_AngularResponeWrapper salesReqWrap = new CHL_AngularResponeWrapper(); 
		salesReqWrap.gridConfiguration = CHL_Util.getGridExportOptions(Boolean.valueOf(CHL_Util.isDownloadable),Label.CHL_LBL_SALES_REQUEST,false);
        salesReqWrap.columnHeader = colHeaderList;
        salesReqWrap.gridData = recordList;
		system.debug('EXPORT : '+JSON.serialize(salesReqWrap.gridConfiguration));
        return salesReqWrap;
    }

    private List<SObject> getRecordList(){
    	List<sObject> caseList = new List<sObject>();
    	//this.inputWrapper.q = 'global';    
    	if(this.inputWrapper.q != null && String.isNotBlank(this.inputWrapper.q))	{
		    return CSM_CaseDataAccess.getCasesBySOSL(this.inputWrapper);
		} else if(inputWrapper.queryParams.requestType != null){
        	String filterCondition = this.inputWrapper.queryParams.requestType;
        	caseList = CSM_CaseDataAccess.getCasesByFilterCondition(filterCondition, '');
    	} else if(this.inputWrapper.queryParams.accountId != null){//Added for US908
    		caseList = CSM_CaseDataAccess.getCasesByFilterCondition('', this.inputWrapper.queryParams.accountId);
    	} else if(this.inputWrapper.queryParams.oppID != null){// Added for US3113
    		String filterCondition = '';
    		String tempVar = this.inputWrapper.queryParams.oppID + '%\'';
    		filterCondition = 'Where CHL_Related_To_Text__c like ' + '\'' + tempVar ;
    		caseList = CSM_CaseDataAccess.getCasesByFilterCondition(filterCondition ,'');
    	}
        return caseList;
    }
    
    public List<CHL_AngularResponeWrapper.CHL_GridData> getRecordDetailsList(List<sObject> sObjectList) {  
        List < CHL_AngularResponeWrapper.CHL_GridData > recordList = new List < CHL_AngularResponeWrapper.CHL_GridData > ();
        integer counter = 0;
        Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
        String userLocale = UserInfo.getLocale();
        String nameSpacePrefix = CSM_Util.getNamespace();
        String nameSpaceField;
        for (sObject sObj: sObjectList) {
            CHL_AngularResponeWrapper.CHL_GridData wrp = new CHL_AngularResponeWrapper.CHL_GridData();
            wrp.recordID = String.valueOf(sObj.get('id'));
            wrp.index = counter;
            wrp.canEdit = false;
        	wrp.pid = String.valueOf(sObj.get('id'));
            Map <String, CHL_AngularResponeWrapper.CHL_RecordDetails> recordMap = new Map <String, CHL_AngularResponeWrapper.CHL_RecordDetails> ();
            for (string tmpfield: CHL_CONSTANTS.GRID_CASE_COLUMNS) {
                CHL_AngularResponeWrapper.CHL_RecordDetails rec = new CHL_AngularResponeWrapper.CHL_RecordDetails();
                String fieldValue;
                String referenceColName;
                string lookupId = '';  
                 if(tmpfield.contains(CHL_Constants.CASE_NUMBER))  {
                	fieldValue = String.valueOf(sObj.get(tmpfield));
                	lookupId = (String)sObj.get('Id');
                 }else if(tmpfield.contains(CHL_Constants.CASE_CLOSED_DATE) || tmpfield.contains(CHL_Constants.CASE_CREATED_DATE)) {
                    fieldValue = sObj.get(tmpfield) != null?String.valueOf(sObj.get(tmpfield)):''; //Todo: ADD namespace condition
                    
                    if(fieldValue != null && (fieldValue).trim() != '') {
                        //Datetime currentDateVal = Datetime.valueOf(fieldValue);
                        //fieldValue = CSM_Util.getLocaleFormattedDateValue(userLocale,currentDateVal,localeMap);
                        fieldValue = (Date.valueOf(fieldValue)).format();
                    }
                }else if (tmpfield.contains(CHL_Constants.CASE_ACCOUNTID) || tmpfield.contains(CHL_Constants.CASE_CREATED_BY)) {
                	sObject sObjVar;
                	if(tmpfield.contains(CHL_Constants.CASE_ACCOUNTID)){
                		sObjVar = sObj.getSObject(CHL_CONSTANTS.CASE_ACCOUNT);
                	}
                	if(tmpfield.contains(CHL_Constants.CASE_CREATED_BY)){
                		sObjVar = sObj.getSObject(CHL_CONSTANTS.CASE_CREATED_BY);
                	}
                	if(sObjVar != null)   {
                        fieldValue = (String)sObjVar.get('Name');
                    } else {
                        fieldValue= '';
                    }
                } else if(tmpfield.contains(CHL_Constants.CASE_RELATED_TO_TXT)){
                	fieldValue = sObj.get(tmpfield) != null ? String.valueOf(sObj.get(tmpfield)):'';
                    if(String.isNotBlank(fieldValue)){
						fieldValue = fieldValue.mid(18, fieldValue.length());
                    }
                }
                else if(tmpfield.contains(CHL_Constants.CASE_SUBTYPE) || tmpfield.contains('Status')){
                	nameSpaceField = tmpfield.contains(CHL_Constants.CASE_SUBTYPE) ? nameSpacePrefix + tmpfield : tmpfield;
                	fieldValue = sObj.get(nameSpaceField) != null ? String.valueOf(sObj.get(nameSpaceField)):'';
                    if(String.isNotBlank(fieldValue)){
                    	Map<String,String> pickListValueMap = CHL_Util.getPickListValueMap('Case',nameSpaceField);
						fieldValue = pickListValueMap != null ? pickListValueMap.get(fieldValue) : fieldValue;
                    }
                    system.debug(tmpfield+':::'+nameSpaceField+'::::'+fieldValue);
                }
                else{
                    fieldValue = String.valueOf(sObj.get(tmpfield));
                }
                
                if (fieldValue != null) {
                        rec.value = String.valueOf(fieldValue);
                        rec.lookupId = lookupId;
                        recordMap.put(tmpfield, rec);
                }
            }
            counter = counter + 1;
            wrp.rowData = recordMap;
            recordList.add(wrp);
        
        }
        return recordList;
    }
    
    private List<CHL_AngularResponeWrapper.CHL_ColumnHeader> getColumnHeader()  {
        
        List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = new List<CHL_AngularResponeWrapper.CHL_ColumnHeader>();
      
        CHL_AngularResponeWrapper.CHL_ColumnHeader colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName =  CHL_Constants.CASE_SUBTYPE; //CSM_Util.getNamespace() + 
        colHeader.label = Label.CHL_LBL_REQUEST_TYPE;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = CHL_Constants.CASE_NUMBER;
        colHeader.label = Label.CHL_REQUEST_NUM;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeader.cellView = 'DETAIL_LINK';
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = CHL_Constants.CASE_ACCOUNTID;
        colHeader.label = Label.CHL_Account;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = CHL_Constants.CASE_STATUS;
        colHeader.label = Schema.SobjectType.Case.fields.Status.label;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = CHL_Constants.CASE_CREATED_DATE;
        colHeader.label = Label.CHL_DATE_OPENED;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = true;
        colHeader.dataType = 'DATETIME';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = CHL_Constants.CASE_CLOSED_DATE;
        colHeader.label = Label.CHL_DATE_CLOSED;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = true;
        colHeader.dataType = 'DATETIME';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = CHL_Constants.CASE_CREATED_BY;
        colHeader.label = Label.CSM_LBL_FROM;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = true;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = CHL_Constants.CASE_DESCRIPTION;
        colHeader.label = Schema.SobjectType.Case.fields.Description.label;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = CHL_Constants.CASE_SUBJECT;
        colHeader.label = Schema.SobjectType.Case.fields.Subject.label;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
        colHeader.apiName = CHL_Constants.CASE_RELATED_TO_TXT;
        colHeader.label = Label.CSM_LBL_RELATEDTO;
        colHeader.isSortable = true;
        colHeader.isSwitchable = true;
        colHeader.isDateCol = false;
        colHeader.dataType = 'STRING';
        colHeader.readOnly = true;
        colHeader.isSimple = true;
        colHeader.remoteOptions = false;
        colHeaderList.add(colHeader);
        
        return colHeaderList;
     }

	  /**
      * @description : This method returns the filter options for Case types for Request Tab.
      */
   
	 public static List<CHL_PartnerOpportunityFilters.CHL_CaseTypes> getCaseTypes() {
        List<CHL_PartnerOpportunityFilters.CHL_CaseTypes> caseList = new List<CHL_PartnerOpportunityFilters.CHL_CaseTypes>();
        for(String str :CHL_Constants.PREDEFINED_FILTER_CASE_OPTIONS){
            CHL_PartnerOpportunityFilters.CHL_CaseTypes requestType = new CHL_PartnerOpportunityFilters.CHL_CaseTypes();
            if(str.equals(Label.CHL_LBL_ALL_REQUESTS) ){
                requestType.id = 'ALL';
                requestType.name = str;
                caseList.add(requestType);
            }else if(str.equals(Label.CHL_LBL_MY_OPEN_REQUESTS)){
                requestType.id = 'OPEN';
                requestType.name = str;
                caseList.add(requestType);
            } else if(str.equals(Label.CHL_LBL_MY_CLOSED_REQUESTS))  {
                requestType.id = 'CLOSED';
                requestType.name = str;
                caseList.add(requestType);
            } 
        }
        return caseList;
    }
    
   /**
      * @description : This method returns the Details of Case from fieldSet.
                  	   Added for US904.
   */
   public static Object getCaseDetailsFromFieldSet(String inputvalue) {    
        CHL_AngularTabsInputWrapper inputWrapper = (CHL_AngularTabsInputWrapper)JSON.deserialize(inputValue, CHL_AngularTabsInputWrapper.class);
        String caseId = inputWrapper.requestId;   
        List<Case> caseList =  CSM_CaseDataAccess.getCaseDetailsByFieldSet(caseId, CHL_Constants.CASE_DETAILS_FIELDSET_NAME);     
        List<CHL_DetailTabResponseWrapper> caseDetailWrapperList = CHL_ResponseWrapperUtil.getObjectDetailsFromFieldSet(caseList, CSM_Util.getNamespace() + CHL_Constants.CASE_DETAILS_FIELDSET_NAME, CSM_Constants.OBJ_CASE);
       	system.debug('\n\n @@@Case Details :: ' + caseDetailWrapperList);
       	return caseDetailWrapperList[0];
   }
   
   
}