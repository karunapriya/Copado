public with sharing class CSM_FocusCategoryViewListBusinessLayer extends CSM_BusinessLayer{
    private String namespace;
    
    public CSM_FocusCategoryViewListBusinessLayer(CSM_CustomGridInputWrapper inputWrapper){
        super(inputWrapper);
    }
    
    public override CSM_GridResponseWrapper retrieveSObjectWrapperList(){        
        CSM_GridResponseWrapper pbResponseWrapper = new CSM_GridResponseWrapper();
        this.namespace = CSM_Util.getNamespace();
        
        try
        {
            pbResponseWrapper.header = getGridHeader();
            pbResponseWrapper.row = getGridRows(pbResponseWrapper.header);
            pbResponseWrapper.hasCheckbox = false;
            pbResponseWrapper.hasAction = true;
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
	** @returns: List of grid column wrapper
	*/
    private List<CSM_GridColumnWrapper> getGridHeader() {
        List<CSM_GridColumnWrapper> gridClmWrapper = new List<CSM_GridColumnWrapper>();

        //CAUTION: The order has to be maintained for the headers to be set and the response columns
        
        CSM_GridColumnWrapper fcvColumn = new CSM_GridColumnWrapper();
        
        fcvColumn = new CSM_GridColumnWrapper();
        fcvColumn.apiName = CSM_Constants.OBJ_FCV_DISPLAY_NAME;
        fcvColumn.label = Label.CSM_FCV_Display_Name;
        fcvColumn.valueCol = CSM_Constants.OBJ_FCV_DISPLAY_NAME;
        fcvColumn.isLinkCol = false;
        fcvColumn.isSortable = true;
        fcvColumn.isSwitchable = true;
        fcvColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(fcvColumn);
        
        fcvColumn = new CSM_GridColumnWrapper();
        fcvColumn.apiName = CSM_Constants.OBJ_FCV_OBJECT_NAME;
        fcvColumn.label = Label.CSM_FCV_Object_Name;
        fcvColumn.valueCol = CSM_Constants.OBJ_FCV_OBJECT_NAME;
        fcvColumn.isLinkCol = false;
        fcvColumn.isSortable = true;
        fcvColumn.isSwitchable = true;
        fcvColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(fcvColumn);        
        
        fcvColumn = new CSM_GridColumnWrapper();
        fcvColumn.apiName = CSM_Constants.OBJ_FCV_IS_TILE;
        fcvColumn.label = Label.CSM_FCV_Is_Tile;
        fcvColumn.valueCol = CSM_Constants.OBJ_FCV_IS_TILE;
        fcvColumn.isLinkCol = false;
        fcvColumn.isSortable = true;
        fcvColumn.isSwitchable = true;
        fcvColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(fcvColumn);
             
        fcvColumn = new CSM_GridColumnWrapper();
        fcvColumn.apiName = CSM_Constants.OBJ_FCV_IS_ACTIVE;
        fcvColumn.label = Label.CSM_FCV_Is_Active;
        fcvColumn.valueCol = CSM_Constants.OBJ_FCV_IS_ACTIVE;
        fcvColumn.isLinkCol = false;
        //fcvColumn.isSortable = false;
        fcvColumn.isSortable = true;
        fcvColumn.isSwitchable = true;
        //fcvColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(fcvColumn);
        
        fcvColumn = new CSM_GridColumnWrapper();
        fcvColumn.apiName = CSM_Constants.OBJ_FCV_CURRENCY_HEADER;
        fcvColumn.label = Label.CSM_FCV_Currency_Header;
        fcvColumn.valueCol = CSM_Constants.OBJ_FCV_CURRENCY_HEADER;
        fcvColumn.isLinkCol = false;
        fcvColumn.isSortable = true;
        fcvColumn.isSwitchable = true;
        fcvColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(fcvColumn);
        
        fcvColumn = new CSM_GridColumnWrapper();
        fcvColumn.apiName = CSM_Constants.OBJ_FCV_FILTER_BY_OWNER;
        fcvColumn.label = Label.CSM_FCV_Filter_By_Owner_Value;
        fcvColumn.valueCol = CSM_Constants.OBJ_FCV_FILTER_BY_OWNER;
        fcvColumn.isLinkCol = false;
        fcvColumn.isSortable = true;
        fcvColumn.isSwitchable = true;
        fcvColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(fcvColumn);
        
        fcvColumn = new CSM_GridColumnWrapper();
        fcvColumn.apiName = CSM_Constants.OBJ_BF_LAST_MODIFIED_BY_NAME;
        fcvColumn.label = Label.CSM_LBL_LAST_MODIFIED_BY;
        fcvColumn.valueCol = CSM_Constants.OBJ_BF_LAST_MODIFIED_BY_NAME;
        fcvColumn.isLinkCol = true;
        fcvColumn.isSortable = true;
        fcvColumn.isSwitchable = true;
        fcvColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(fcvColumn);
        
        fcvColumn = new CSM_GridColumnWrapper();
        fcvColumn.apiName = CSM_Constants.OBJ_BF_LAST_MODIFIED_DATE;
        fcvColumn.label = Label.CSM_LBL_LASTMOD_ON;
        fcvColumn.valueCol = CSM_Constants.OBJ_BF_LAST_MODIFIED_DATE;
        fcvColumn.isLinkCol = false;
        fcvColumn.isSortable = true;
        fcvColumn.isSwitchable = true;
        fcvColumn.customColumnSorter = 'customColumnSorter';
        gridClmWrapper.add(fcvColumn);
        
        return gridClmWrapper;
    }
    
    private List<CSM_GridRowWrapper> getGridRows(List<CSM_GridColumnWrapper> colList){
    	List<CSM_GridRowWrapper> gridRowWrapper = new List<CSM_GridRowWrapper>();
    	
    	if(colList!=null) {
	        Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
	        String userLocale = UserInfo.getLocale();
	        List<Sobject> fcvs = new List<CSM_Focus_Category_View__c>();
	        
	        //Boolean isManageFocusCategories = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_ManageFocusCategory);
	       //if(isManageFocusCategories) {
	        	fcvs = CSM_FocusCategoryViewDataAccess.getAllFocusCategoryViews();
	        //} else {
	        //	fcvs = CSM_FocusCategoryViewDataAccess.getAllFocusCategoryViewsByUser(UserInfo.getUserId());
	       // }
			
	        if (fcvs != null && !fcvs.isEmpty()){
	            for(SObject fcv : fcvs) {
	                CSM_GridRowWrapper row = new CSM_GridRowWrapper();
	                row.id = (String) fcv.get('Id');
	                row.sObj = fcv;
	                row.columns = new List<CSM_GridColumnWrapper>();
	                row.namespace = this.namespace;
	                row.columns = colList;
	                row.hasGridImage = true;
	                
	                setRowAction(row, fcv);
	                
	                gridRowWrapper.add(row);
	            }
	        }
    	}
        
        return gridRowWrapper;
    }
    
    private void setRowAction(CSM_GridRowWrapper row, sObject fcv){
		row.actions = new List<CSM_GridActionWrapper>();
		
		CSM_GridActionWrapper actionWrapper = new CSM_GridActionWrapper('Edit');
		actionWrapper.hrefAction = 'javascript:void(0);';
		actionWrapper.onclickAction = 'editClick("' + row.id + '")';
		actionWrapper.titleAction = Label.CSM_LBL_EDIT;
		row.actions.add(actionWrapper);
		
		actionWrapper = new CSM_GridActionWrapper('Del');
		actionWrapper.hrefAction = 'javascript:void(0);';
		actionWrapper.onclickAction = 'confirmDelete("' + row.id + '")';
		actionWrapper.titleAction = Label.REN_Delete;
		row.actions.add(actionWrapper);
		
		actionWrapper = new CSM_GridActionWrapper('Clone');
		actionWrapper.hrefAction = 'javascript:void(0);';
		actionWrapper.onclickAction = 'cloneClick("'+ row.id + '")';
		actionWrapper.titleAction = Label.CSM_LBL_CLONE;
		row.actions.add(actionWrapper);
		
		actionWrapper = new CSM_GridActionWrapper('Result Set');
		actionWrapper.hrefAction = 'javascript:void(0);';
		actionWrapper.onclickAction = 'resultSetClick("' + row.id + '", "' + fcv.get(CSM_Constants.OBJ_FCV_OBJECT_NAME) + '")';
		actionWrapper.titleAction = Label.CSM_ResultSet;
		row.actions.add(actionWrapper);
	}  
}