/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.18.2014
* @description    CSM_FocusCategoriesColumnDataAccess class related to saving Data to Salesforce  
*/
public with sharing class CSM_FocusCategoriesColumnDataAccess {
	
	public List<CSM_FocusCategoryColumnWrapper> focusCategoryColumnList {get; private set;}
	public Map<String, CSM_Focus_Category_Column__c> focusCategoryColumnMap {get; private set;}
	private Map<String, CSM_FocusCategoryColumnWrapper> focusCategoryColumnActiveMap {get; private set;}
	private Map<Integer, CSM_FocusCategoryColumnWrapper> focusCategoryColumnWrapperMap {get; set;}
	
	/**
	* @description populateWrapperClass adds all the values from the FocusCategoryColumn 
	*
	* @return null 
	*/
	public void populateWrapperClass(String fcGroupId, String fcColumnId, Set<String> focusCategoryGroups) {
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_FCC_ID, CSM_Constants.OBJ_FCC_NAME, CSM_Constants.OBJ_FCG_ISACTIVE,CSM_Constants.OBJ_FCG_DISPLAY_NAME, 
			CSM_Constants.OBJ_FCG_ORDER_AUTO_ID, CSM_Constants.OBJ_FCG_CATEGORY_GROUP, CSM_Constants.OBJ_FCC_CATEGORIES_COUNT, CSM_Constants.OBJ_FCC_COLUMN_ORDER};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_FCC,
																										CSM_Constants.DML_OPERATION_READ, fcFieldList);
		if (noAccessList.isEmpty())
    	{
	    	focusCategoryColumnList = new List<CSM_FocusCategoryColumnWrapper>();
			focusCategoryColumnWrapperMap = new Map<Integer, CSM_FocusCategoryColumnWrapper>();
			focusCategoryColumnActiveMap = new Map<String, CSM_FocusCategoryColumnWrapper>();
			if (fcColumnId!=null){
				focusCategoryColumnMap = new Map<String, CSM_Focus_Category_Column__c> ([SELECT Id, Name, CSM_IsActive__c, CSM_Display_Name__c, CSM_Order_Auto_Id__c, 
				                                                                    CSM_Focus_Category_Group__c,
																					CSM_Categories_Count__c, CSM_Column_Order__c FROM CSM_Focus_Category_Column__c 
																					WHERE Id =: fcColumnId LIMIT 1]);
    		} else {
    			List<String> fcgFieldList = new List<String>{CSM_Constants.OBJ_FCG_GROUP_TYPE};
    			
    			List<String> noFcgAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_FCG,CSM_Constants.DML_OPERATION_READ, fcgFieldList);
				if (noFcgAccessList.isEmpty())
    	        {																						
	    			if (fcGroupId != null) {
						focusCategoryColumnMap = new Map<String, CSM_Focus_Category_Column__c> ([SELECT Id, Name, CSM_IsActive__c, CSM_Display_Name__c, CSM_Order_Auto_Id__c, 
						                                                                CSM_Focus_Category_Group__c,
																						CSM_Categories_Count__c, CSM_Column_Order__c, 
																						CSM_Focus_Category_Group__r.CSM_Group_Type__c FROM CSM_Focus_Category_Column__c 
																						WHERE CSM_Focus_Category_Group__c =: fcGroupId 
																						LIMIT 100]);
	    			} else if (focusCategoryGroups != null) {
						focusCategoryColumnMap = new Map<String, CSM_Focus_Category_Column__c> ([SELECT Id, Name, CSM_IsActive__c, CSM_Display_Name__c, CSM_Order_Auto_Id__c,
						                                                                       CSM_Focus_Category_Group__c,
																						CSM_Categories_Count__c, CSM_Column_Order__c, 
																						CSM_Focus_Category_Group__r.CSM_Group_Type__c FROM CSM_Focus_Category_Column__c 
																						WHERE CSM_Focus_Category_Group__c IN: focusCategoryGroups LIMIT 100]);
	    			} else {
						focusCategoryColumnMap = new Map<String, CSM_Focus_Category_Column__c> ([SELECT Id, Name, CSM_IsActive__c, CSM_Display_Name__c, CSM_Order_Auto_Id__c, CSM_Focus_Category_Group__c,
																						CSM_Categories_Count__c, CSM_Column_Order__c, 
																						CSM_Focus_Category_Group__r.CSM_Group_Type__c FROM CSM_Focus_Category_Column__c 
																						LIMIT 100]);
	    			}
    	        }
    	        else
    	        {
    	        	String[] arguments = new String[] {CSM_CONSTANTS.OBJ_FCG + ':'+String.valueOf(noFcgAccessList)};
		    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
		    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
    	        }
    		}
			if (focusCategoryColumnMap!=null && !focusCategoryColumnMap.isEmpty()) {
				for (CSM_Focus_Category_Column__c fcColumn : focusCategoryColumnMap.values()) {
					CSM_FocusCategoryColumnWrapper fcCW = new CSM_FocusCategoryColumnWrapper();
					fcCW.ColumnId = fcColumn.Id;
					fcCW.ColumnName = fcColumn.CSM_Display_Name__c;
					fcCW.ColumnOrder = String.valueOf(fcColumn.CSM_Column_Order__c);
					fcCW.ColumnActive = fcColumn.CSM_IsActive__c;
					fcCW.GroupId = fcColumn.CSM_Focus_Category_Group__c;
					fcCW.ColumnCategoryCount = Integer.valueOf(fcColumn.CSM_Categories_Count__c);
					fcCW.UniqueId = Integer.valueOf(fcColumn.CSM_Order_Auto_Id__c);
					fcCW.GroupHasTiles = fcColumn.CSM_Focus_Category_Group__r.CSM_Group_Type__c == CSM_Constants.CSM_FOCUS_CATEGORIES_TYPE_TILES;
					if (focusCategoryGroups!=null && fcCW.ColumnActive){
						focusCategoryColumnActiveMap.put(fcCW.ColumnId, fcCW);
					}
					focusCategoryColumnList.add(fcCW);
					focusCategoryColumnWrapperMap.put(fcCW.UniqueId, fcCW);
				}
				focusCategoryColumnList.sort();
			} 
    	}
    	else
    	{
    		 String[] arguments = new String[] {CSM_CONSTANTS.OBJ_FCC + ':'+String.valueOf(noAccessList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments));
    	}
	}
		
	/**
	* @description populateWrapperClass adds all the values from the FocusCategoryColumn 
	*
	* @return null 
	*/
	public void populateWrapperClass() {
		populateWrapperClass(null, null, null);
	}
			
	/**
	* @description populateWrapperClass adds all the values from the FocusCategoryColumn 
	*
	* @return null 
	*/
	public void createFocusCategoryColumn(String fcGroupId, String focusCategoryColumName) {
		Integer rowNum = 1;
		Integer uniqueNum = 1;
		if (!focusCategoryColumnList.isEmpty()){
			focusCategoryColumnList.sort();
			rowNum = Integer.valueOf(focusCategoryColumnList[focusCategoryColumnList.size()-1].ColumnOrder)+1;
			uniqueNum = Integer.valueOf(focusCategoryColumnList[focusCategoryColumnList.size()-1].UniqueId)+1;
		}
		CSM_FocusCategoryColumnWrapper fcColumn = new CSM_FocusCategoryColumnWrapper();
		fcColumn.ColumnName = focusCategoryColumName;
		fcColumn.GroupId = fcGroupId;
		fcColumn.ColumnOrder = String.valueOf(rowNum);
		fcColumn.ColumnActive = true;
		fcColumn.UniqueId = uniqueNum;
		focusCategoryColumnWrapperMap.put(uniqueNum, fcColumn);
		focusCategoryColumnList.add(fcColumn);
	}
	
	public CSM_FocusCategoryColumnWrapper saveAndRetrieveId(Integer focusCategoryColumnUniqueId) {
		CSM_FocusCategoryColumnWrapper fcCW;
		if (focusCategoryColumnWrapperMap.containsKey(focusCategoryColumnUniqueId)) {
			fcCW = focusCategoryColumnWrapperMap.get(focusCategoryColumnUniqueId);
			if (fcCW.ColumnId==null){
				CSM_Focus_Category_Column__c fcColumn = createFCColumn(fcCW);
				List<String> fccFieldList = new List<String>{CSM_Constants.OBJ_FCC_DISPLAY_NAME, CSM_Constants.OBJ_FCC_ISACTIVE, CSM_Constants.OBJ_FCC_NAME,
					CSM_Constants.OBJ_FCC_COLUMN_ORDER};
				List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
				    CSM_CONSTANTS.OBJ_FCC,
		            CSM_Constants.DML_OPERATION_UPSERT, fccFieldList);
		        if (noAccessList.isEmpty())
    	        {    
					upsert fcColumn;
					focusCategoryColumnMap.put(fcColumn.Id, fcColumn);
					fcCW.ColumnId = fcColumn.Id;
					fcCW.ColumnCategoryCount = Integer.valueOf(fcColumn.CSM_Categories_Count__c);
					
					// Get the category column populated again so that we have updated list
					saveFocusCategoryColumn();
    	        }
    	        else 
    	        {
    	        	String[] arguments = new String[] {CSM_CONSTANTS.OBJ_FCC + ':'+String.valueOf(noAccessList)};
		    		throw new CSM_AccessController.AccessControlDmlException( String.format(
		    		System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments));
    	        }
			}
		}
		return fcCW;
	}
		
	
	private CSM_Focus_Category_Column__c createFCColumn(CSM_FocusCategoryColumnWrapper fcCW) {
		CSM_Focus_Category_Column__c	fcColumn;
		if (focusCategoryColumnMap.containsKey(fcCW.ColumnId)){
			fcColumn = focusCategoryColumnMap.get(fcCW.ColumnId);
		} else {
			fcColumn = new CSM_Focus_Category_Column__c();
			fcColumn.CSM_Focus_Category_Group__c = fcCW.GroupId;
		}
		fcColumn.CSM_Display_Name__c = fcCW.ColumnName;
		fcColumn.CSM_IsActive__c = fcCW.ColumnActive;
		fcColumn.Name = fcCW.ColumnName;
		fcColumn.CSM_Column_Order__c = Integer.valueOf(fcCW.ColumnOrder);
		return fcColumn;			
	}
	
	public void saveFocusCategoryColumn() {
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_FCG_ISACTIVE,CSM_Constants.OBJ_FCG_DISPLAY_NAME, 
													CSM_Constants.OBJ_FCC_COLUMN_ORDER,
													CSM_Constants.OBJ_FCC_NAME};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_FCC,
																					CSM_Constants.DML_OPERATION_UPSERT, fcFieldList);
    	if (noAccessList.isEmpty())
    	{
			if (focusCategoryColumnList!=null && focusCategoryColumnList.size()>0){
				String fcGroupId;
				
				List<CSM_Focus_Category_Column__c> fcColumnToUpdate = new List<CSM_Focus_Category_Column__c>();
				for (CSM_FocusCategoryColumnWrapper fcCW: focusCategoryColumnList){
					CSM_Focus_Category_Column__c fcColumn = createFCColumn(fcCW);
					fcGroupId = fcCW.GroupId;
					fcColumnToUpdate.add(fcColumn);				
				}  
				upsert fcColumnToUpdate;
				populateWrapperClass(fcGroupId, null, null);
			}
    	}
    	else
    	{
    		 String[] arguments = new String[] {CSM_CONSTANTS.OBJ_FCC + ':'+String.valueOf(noAccessList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments)); 
    	}
	}
	
	/**
	* @description delete the focus category column
	* @return boolean value of success or failure deletion
	*/
	
	public boolean deleteFocusCategoryColumn(Integer focusCategoryColumnUniqueId) {	

		CSM_Focus_Category_Column__c fcColumn;
		CSM_FocusCategoryColumnWrapper fcCW;
		
		//get focusCategoryColumnWrapper
		if (focusCategoryColumnWrapperMap.containsKey(focusCategoryColumnUniqueId)) {
			fcCW = focusCategoryColumnWrapperMap.get(focusCategoryColumnUniqueId);
		}
		
		if (fcCW != null ) {
			if (focusCategoryColumnMap.containsKey(fcCW.ColumnId)){				
				fcColumn = focusCategoryColumnMap.get(fcCW.ColumnId);
				
				if (fcColumn != null) {
					//perform the delete operation
					CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_FC_CATEGORY_COLUMN, null, CSM_Constants.DML_OPERATION_DELETE);
					delete fcColumn;
					return true;
				}
				else {
					return false;
				}
			}
			else {
				return false;
			}
		}
		else {
			return false;
		}
		return false;
	}

	/**
	* @description getFocusCategoryColumnActiveMap - Create selectoptions for Category Groups
	*
	* @return CSM_Focus_Category_Group__c - return created focus category select options 
	*/
	public Map<String, CSM_FocusCategoryColumnWrapper> getFocusCategoryColumnActiveMap(Set<String> focusCategoryGroups) {
		populateWrapperClass(null, null, focusCategoryGroups);
		return focusCategoryColumnActiveMap;
	}
}