public with sharing class CHL_AttachmentBusinessLayer {

 	public CHL_GridInputWrapper inputWrapper;

	public CHL_AttachmentBusinessLayer(CHL_GridInputWrapper inputWrapper) {
		this.inputWrapper = inputWrapper;
	}
	
	public CHL_AngularResponeWrapper constructGridWrapper() {
		List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = getColumnHeaderForCaseAttachment();
		List<SObject > caseAttachmentList = getAttachmentDetailsForCase();
		List<CHL_AngularResponeWrapper.CHL_GridData> recordList = getAttachmentDetailsList(caseAttachmentList);
		CHL_AngularResponeWrapper salesAttacmentReqWrap = new CHL_AngularResponeWrapper();
		/*CHL_AngularResponeWrapper.CHL_GridConfiguration gridConfig = new CHL_AngularResponeWrapper.CHL_GridConfiguration();
		gridConfig.exportPdf = false;
		gridConfig.exportCsv = false;
		gridConfig.sorting = true;
		gridConfig.selection = false;*/
		salesAttacmentReqWrap.gridConfiguration = CHL_Util.getGridExportOptions(false,'',false);
		salesAttacmentReqWrap.columnHeader = colHeaderList;
		salesAttacmentReqWrap.gridData = recordList;
		return salesAttacmentReqWrap;
	}
	
	public List<SObject> getAttachmentDetailsForCase() {
		Set<ID> caseIdSet = new Set<ID>();
		caseIdSet.add(inputWrapper.queryParams.requestId);
		List<sObject> attachmentList = CHL_AttachmentDataAccess.getAttachmentListByParentId(caseIdSet);
		return attachmentList;
	}
	
	public List<CHL_AngularResponeWrapper.CHL_GridData> getAttachmentDetailsList(List<sObject> sObjectList) {
		List<CHL_AngularResponeWrapper.CHL_GridData> recordList = new List<CHL_AngularResponeWrapper.CHL_GridData>();
		integer counter = 0;
		Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
        String userLocale = UserInfo.getLocale();
		for (sObject sObj: sObjectList) {
			CHL_AngularResponeWrapper.CHL_GridData wrp = new CHL_AngularResponeWrapper.CHL_GridData();
			wrp.recordID = String.valueOf(sObj.get(CHL_Constants.FL_ID));
			wrp.index = counter;
			wrp.canEdit = false;
	
			Map<String, CHL_AngularResponeWrapper.CHL_RecordDetails> recordMap = new Map<String, CHL_AngularResponeWrapper.CHL_RecordDetails>();
	
			for (string tmpfield: CHL_Constants.GRID_CASE_ATTACHMENT_COLUMNS) {
				CHL_AngularResponeWrapper.CHL_RecordDetails rec = new CHL_AngularResponeWrapper.CHL_RecordDetails();
				String fieldValue;
				String referenceColName;
				String urlValue = '';
				/*if (tmpfield.contains(CHL_Constants.OBJ_ATT_LAST_MODIFIED_DATE)) {
					fieldValue = String.valueOf(sObj.get(tmpfield)); //Todo: ADD namespace condition
					if (fieldValue != null && (fieldValue).trim() != '') {
						Datetime currentDateVal = Datetime.valueOf(fieldValue);
						fieldValue = currentDateVal.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss') + '+00:00';
					}
				} else if (tmpfield.contains(CHL_Constants.OBJ_ATT_LAST_MODIFIED_BY)) {
					sObject sObjVar = sObj.getSObject(CHL_Constants.OBJ_ATT_LAST_MODIFIED_BY);
					if (sObjVar != null) {
						fieldValue = (String) sObjVar.get(CHL_Constants.OBJ_PO_NAME);
					} else {
						fieldValue = '';
					}
				} else*/
				if (tmpfield.contains(CHL_Constants.OBJ_PO_NAME)) {
					fieldValue = (String) sObj.get(tmpfield);
					urlValue = Site.getPathPrefix()+'/servlet/servlet.FileDownload?file=' + String.valueOf(sObj.get('id'));
				}else if (tmpfield.contains(CHL_Constants.CASE_CREATED_DATE)) {
					fieldValue = String.valueOf(sObj.get(tmpfield)); //Todo: ADD namespace condition
					if (fieldValue != null && (fieldValue).trim() != '') {
						Datetime currentDateVal = Datetime.valueOf(fieldValue);
                        fieldValue = CSM_Util.getLocaleFormattedDateValue(userLocale,currentDateVal,localeMap);
					}
				} else if (tmpfield.contains(CHL_Constants.OBJ_CASECOMM_CREATED_BY_ID)) {
					sObject sObjVar = sObj.getSObject('CreatedBy');
					if (sObjVar != null) {
						fieldValue = (String) sObjVar.get(CHL_Constants.OBJ_PO_NAME);
					} else {
						fieldValue = '';
					}
				} 
				if (fieldValue != null) {
						rec.value = String.valueOf(fieldValue);
						rec.url = urlValue;
						recordMap.put(tmpfield, rec);
				}
			}
			counter = counter + 1;
			wrp.rowData = recordMap;
			recordList.add(wrp);
	
		}
		system.debug('\n\n @@@attachment Rec list  :: ' + recordList);
		return recordList;
	}
	
	private List<CHL_AngularResponeWrapper.CHL_ColumnHeader> getColumnHeaderForCaseAttachment() {
		List<CHL_AngularResponeWrapper.CHL_ColumnHeader> colHeaderList = new List<CHL_AngularResponeWrapper.CHL_ColumnHeader>();
		CHL_AngularResponeWrapper.CHL_ColumnHeader colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
	
		colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
		colHeader.apiName = CHL_Constants.OBJ_PO_NAME;
		colHeader.label = Schema.SobjectType.Attachment.fields.Name.label;
		colHeader.isSortable = true;
		colHeader.isSwitchable = true;
		colHeader.isDateCol = false;
		colHeader.dataType = 'LINK';
		colHeader.url = 'url';
		colHeader.readOnly = true;
		colHeader.isSimple = false;
		colHeaderList.add(colHeader);
	
		colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
		colHeader.apiName = CHL_Constants.CASE_CREATED_DATE;
		colHeader.label = Schema.SobjectType.Attachment.fields.CreatedDate.label;
		colHeader.isSortable = true;
		colHeader.isSwitchable = true;
		colHeader.isDateCol = true;
		colHeader.dataType = 'DATETIME';
		colHeader.readOnly = true;
		colHeader.isSimple = true;
		colHeader.remoteOptions = false;
		colHeaderList.add(colHeader);
		
		colHeader = new CHL_AngularResponeWrapper.CHL_ColumnHeader();
		colHeader.apiName = CHL_Constants.OBJ_CASECOMM_CREATED_BY_ID;
		colHeader.label = Label.CSM_LBL_CREATED_BY;
		colHeader.isSortable = true;
		colHeader.isSwitchable = true;
		colHeader.isDateCol = true;
		colHeader.dataType = 'STRING';
		colHeader.readOnly = true;
		colHeader.isSimple = true;
		colHeader.remoteOptions = false;
		colHeaderList.add(colHeader);
	
		return colHeaderList;
	}
}