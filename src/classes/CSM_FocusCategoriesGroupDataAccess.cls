/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.18.2014
* @description    CSM_FocusCategoriesGroupDataAccess class related to saving Data to Salesforce  
*/
public with sharing class CSM_FocusCategoriesGroupDataAccess {
	
	public List<CSM_FocusCategoryGroupWrapper> focusCategoryGroupList {get; private set;}
	public Map<Id, CSM_Focus_Category_Group__c> focusCategoryGroupMap {get; private set;}
	public Boolean hasTiles {get; private set;}
	public Map<String, CSM_FocusCategoryGroupWrapper> focusCategoryGroupActiveMap {get; private set;}
	private Map<Integer, CSM_FocusCategoryGroupWrapper> focusCategoryGroupWrapperMap {get; set;}
	private List<SelectOption> fcgSelectOptions;
	private Boolean selectOptionVal {get; set;}
	private String groupId {get; set;}
	
	public CSM_FocusCategoriesGroupDataAccess() {
		selectOptionVal = false;
		
	}			
	
	/**
	* @description populateWrapperClass adds all the values from the FocusCategoryGroup 
	*
	* @return null 
	*/
	public void populateWrapperClass(String fcGroupId) {
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_FCG_ISACTIVE,CSM_Constants.OBJ_FCG_DISPLAY_NAME, CSM_Constants.OBJ_FCG_OWNERID, CSM_Constants.OBJ_FCG_ORDER_AUTO_ID,
													CSM_Constants.OBJ_FCG_GROUP_TYPE, CSM_Constants.OBJ_FCG_ORDER, CSM_Constants.OBJ_FCG_CATEGORY_COLUMN_COUNT};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_FCG,
																										CSM_Constants.DML_OPERATION_READ, fcFieldList);
    	focusCategoryGroupList = new List<CSM_FocusCategoryGroupWrapper>();
		if (noAccessList.isEmpty())
    	{
			focusCategoryGroupWrapperMap = new Map<Integer, CSM_FocusCategoryGroupWrapper>();
			focusCategoryGroupActiveMap = new Map<String, CSM_FocusCategoryGroupWrapper>();
			fcgSelectOptions = new List<SelectOption>();
			fcgSelectOptions.add(new SelectOption('', Label.CSM_LBL_PLEASESELECT));
			groupId = fcGroupId;
			List<CSM_Focus_Category_Group__c> fcGroupList;
			focusCategoryGroupMap = new Map<Id, CSM_Focus_Category_Group__c>();
    		if (fcGroupId!=null){
				fcGroupList = [SELECT Id, Name, OwnerId, Owner.Name, CSM_IsActive__c, CSM_Display_Name__c, CSM_Order_Auto_Id__c, CSM_Group_Type__c, 
																					CSM_Order__c, CSM_Category_Column_Count__c FROM CSM_Focus_Category_Group__c 
																					WHERE Id =: fcGroupId ORDER BY CSM_Display_Name__c  ASC  LIMIT 1];

    		} else {
				fcGroupList = [SELECT Id, Name, OwnerId, Owner.Name, CSM_IsActive__c, CSM_Display_Name__c, CSM_Order_Auto_Id__c, CSM_Group_Type__c, 
																					CSM_Order__c, CSM_Category_Column_Count__c 
																					FROM CSM_Focus_Category_Group__c ORDER BY CSM_Display_Name__c  ASC,CSM_Order__c  LIMIT 1000];
    		}
    		
			hasTiles = false;
			if (fcGroupList!=null && !fcGroupList.isEmpty()) {
				for (CSM_Focus_Category_Group__c fcGroup : fcGroupList) {
					CSM_FocusCategoryGroupWrapper fcGW = new CSM_FocusCategoryGroupWrapper();
					fcGW.GroupId = fcGroup.Id;
					fcGW.GroupName = fcGroup.CSM_Display_Name__c;
					fcGW.GroupType = fcGroup.CSM_Group_Type__c;
					fcGW.GroupActive = fcGroup.CSM_IsActive__c;
					if (fcGW.GroupType == CSM_Constants.CSM_FOCUS_CATEGORIES_TYPE_TILES){
						hasTiles = true;
					} 
					fcGW.GroupOrder = String.valueOf(fcGroup.CSM_Order__c);
		
					fcGW.GroupOwnerName = fcGroup.Owner.Name;
					fcGW.GroupOwnerId = fcGroup.OwnerId;
					fcGW.GroupColumnsCount = Integer.valueOf(fcGroup.CSM_Category_Column_Count__c);
					fcGW.UniqueId = Integer.valueOf(fcGroup.CSM_Order_Auto_Id__c);
					
					if (fcGW.GroupActive == true && selectOptionVal == true){
						if (fcGW.GroupType == CSM_Constants.CSM_FOCUS_CATEGORIES_TYPE_MAIN) {
							fcgSelectOptions.add(new SelectOption(fcGW.GroupId, fcGW.GroupName));
							
						}
						focusCategoryGroupActiveMap.put(fcGW.GroupId, fcGW);
					} 

					focusCategoryGroupList.add(fcGW);
					focusCategoryGroupWrapperMap.put(fcGW.UniqueId, fcGW);
					focusCategoryGroupMap.put(fcGroup.Id, fcGroup);
				}
				
				focusCategoryGroupList.sort();
				
			} 
    	}
    	else
    	{
    		 String[] arguments = new String[] {CSM_CONSTANTS.OBJ_FCG + ':'+String.valueOf(noAccessList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_ACCESSIBLE, arguments)); 
    	}
	}
	
		
	/**
	* @description populateWrapperClass adds all the values from the FocusCategoryGroup 
	*
	* @return null 
	*/
	public void populateWrapperClass() {
		populateWrapperClass(null);
	}
	
	/**
	* @description createFocusCategoryGroup - Create new category Group based on category name and type (Main/Tiles)
	*
	* @return null 
	*/
	public void createFocusCategoryGroup(String focusCategoryGroupName, String focusCategoryGroupType) {
		Integer rowNum = 1;
		Integer uniqueNum = 1;
		if (!focusCategoryGroupList.isEmpty()){
			focusCategoryGroupList.sort();
			rowNum = Integer.valueOf(focusCategoryGroupList[focusCategoryGroupList.size()-1].GroupOrder)+1;
			uniqueNum = Integer.valueOf(focusCategoryGroupList[focusCategoryGroupList.size()-1].UniqueId)+1;
		}
		// Create Category Group
		CSM_FocusCategoryGroupWrapper fcGroup = new CSM_FocusCategoryGroupWrapper();
		fcGroup.GroupName = focusCategoryGroupName;
		fcGroup.GroupType = focusCategoryGroupType;
		fcGroup.GroupOrder = String.valueOf(rowNum);
		fcGroup.GroupActive = true;
		
		fcGroup.UniqueId = uniqueNum;
		focusCategoryGroupWrapperMap.put(uniqueNum, fcGroup);
		focusCategoryGroupList.add(fcGroup);
	}

	/**
	* @description saveAndRetrieveId - Save Category Group based on Unique Id and return ID based on row id
	*
	* @return null 
	*/
	public String saveAndRetrieveId(Integer focusCategoryGroupUniqueId) {
		String fcGroupId = null;
		// Check if there is a record to insert
		if (focusCategoryGroupWrapperMap.containsKey(focusCategoryGroupUniqueId)) {
			CSM_FocusCategoryGroupWrapper fcGW = focusCategoryGroupWrapperMap.get(focusCategoryGroupUniqueId);
			
			// Check if the group id exist
			if (fcGW.GroupId!=null){
				fcGroupId = fcGW.GroupId;
			} else {
				// Get the focus Category Group and insert and retrieve the id for the inserted record
				CSM_Focus_Category_Group__c fcGroup = createFCGroup(fcGW);
				List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_FCG_ISACTIVE,CSM_Constants.OBJ_FCG_DISPLAY_NAME, 
					    CSM_Constants.OBJ_FCG_OWNERID, CSM_Constants.OBJ_FCG_GROUP_TYPE, 
					    CSM_Constants.OBJ_FCG_ORDER, CSM_Constants.OBJ_FCG_NAME};
		       
		        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(
		            CSM_CONSTANTS.OBJ_FCG, CSM_Constants.DML_OPERATION_UPSERT, fcFieldList);
		            
		        if (noAccessList.isEmpty())
		        {    
					upsert fcGroup;
					fcGroupId = fcGroup.Id;
					fcGW.GroupColumnsCount = Integer.valueOf(fcGroup.CSM_Category_Column_Count__c);
					fcGW.GroupId = fcGroup.Id;
					focusCategoryGroupMap.put(fcGroup.Id, fcGroup);
		        }
		        else
		        {
		        	String[] arguments = new String[] {CSM_CONSTANTS.OBJ_FCG + ':'+String.valueOf(noAccessList)};
		    		throw new CSM_AccessController.AccessControlDmlException( String.format(
		    		System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments)); 
		        }
			}
		}
		return fcGroupId;
	}
	
	/**
	* @description createFCGroup - Create record based on information entered by the user both based on insert or update
	*
	* @return CSM_Focus_Category_Group__c - return created focus category group record 
	*/
	private CSM_Focus_Category_Group__c createFCGroup(CSM_FocusCategoryGroupWrapper fcGW) {
		CSM_Focus_Category_Group__c	fcGroup;
		if (focusCategoryGroupMap.containsKey(fcGW.GroupId)){
			fcGroup = focusCategoryGroupMap.get(fcGW.GroupId);
		} else {
			fcGroup = new CSM_Focus_Category_Group__c();
		}
		fcGroup.CSM_Display_Name__c = fcGW.GroupName;
		fcGroup.CSM_Group_Type__c = fcGW.GroupType;
		fcGroup.CSM_IsActive__c = fcGW.GroupActive;
		fcGroup.Name = fcGW.GroupName;
		
		if (fcGW.GroupOwnerId!=null){
			fcGroup.OwnerId = fcGW.GroupOwnerId;
		} else {
			fcGroup.OwnerId = UserInfo.getUserId();
		}
		fcGroup.CSM_Order__c = Integer.valueOf(fcGW.GroupOrder);
		return fcGroup;			
	}
	
	/**
	* @description createFCGroup - Create record based on information entered by the user both based on insert or update
	*
	* @return CSM_Focus_Category_Group__c - return created focus category group record 
	*/
	public void saveFocusCategoryGroup() {
		List<String> fcFieldList = new List<String>{CSM_Constants.OBJ_FCG_ISACTIVE,CSM_Constants.OBJ_FCG_DISPLAY_NAME, 
		        CSM_Constants.OBJ_FCG_OWNERID, CSM_Constants.OBJ_FCG_GROUP_TYPE, 
		        CSM_Constants.OBJ_FCG_ORDER, CSM_Constants.OBJ_FCG_NAME};
		List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_CONSTANTS.OBJ_FCG,
																										CSM_Constants.DML_OPERATION_UPSERT, fcFieldList);
    	if (noAccessList.isEmpty())
    	{
			if (focusCategoryGroupList!=null && focusCategoryGroupList.size()>0){
				List<CSM_Focus_Category_Group__c> fcGroupToUpdate = new List<CSM_Focus_Category_Group__c>();
				for (CSM_FocusCategoryGroupWrapper fcGW: focusCategoryGroupList){
					CSM_Focus_Category_Group__c fcGroup = createFCGroup(fcGW);
					fcGroupToUpdate.add(fcGroup);				
				}  
				upsert fcGroupToUpdate;
				populateWrapperClass(groupId); 
			}
    	}
    	else
    	{
    		 String[] arguments = new String[] {CSM_CONSTANTS.OBJ_FCG + ':'+String.valueOf(noAccessList)};
    		 throw new CSM_AccessController.AccessControlDmlException( String.format(
    		 System.Label.CSM_MSG_OBJECT_NOT_UPSERTABLE, arguments)); 
    	}
	}
	
	/**
	* @description getFocusCategoryGroups - Create selectoptions for Category Groups
	*
	* @return CSM_Focus_Category_Group__c - return created focus category select options 
	*/
	public List<SelectOption> getFocusCategoryGroups() {
		selectOptionVal = true;
		populateWrapperClass();
		return fcgSelectOptions;
	}
	
	  /**
	   * @description Clone Focus Category Group and insert clone records
	   * @param List<String> of focusCategoryGroup Id
	   * @return List<CSM_Focus_Category_Group__c>  focusCategoryGroup Records
	   */
	  public List<CSM_Focus_Category_Group__c> cloneFocusCategoryGroup(List<String> focusCategoryGroupId) {
		    Integer rowNum = 1;
			Integer uniqueNum = 1;
			if (!this.focusCategoryGroupList.isEmpty()){
				this.focusCategoryGroupList.sort();
				rowNum = Integer.valueOf(this.focusCategoryGroupList[this.focusCategoryGroupList.size()-1].GroupOrder)+1;
			}
	      List<CSM_Focus_Category_Group__c> focusCategoryGroupList = new List<CSM_Focus_Category_Group__c> ();
	      CSM_Focus_Category_Group__c focusCategoryGroup = GetFocusCategoryGroupRecord(focusCategoryGroupId[0]);
	      CSM_Focus_Category_Group__c clonedFocusCategoryGroup = focusCategoryGroup.clone(false, true);
	      String displayName = Label.CSM_LBL_CLONE_PREFIX + ' ' + focusCategoryGroup.CSM_Display_Name__c;
	      clonedFocusCategoryGroup.CSM_Display_Name__c = displayName.length() > 40 ? displayName.substring(0, 40) : displayName;
	      clonedFocusCategoryGroup.CSM_Order__c = rowNum;
 		  clonedFocusCategoryGroup.CSM_IsActive__c =focusCategoryGroup.CSM_IsActive__c;
	         List<String> focusCategoryGroupFieldList = new List<String> {
	          CSM_Constants.OBJ_FCG_DISPLAY_NAME,
	              CSM_Constants.OBJ_FCG_GROUP_TYPE,
	              CSM_Constants.OBJ_FCG_ORDER,
	              CSM_Constants.OBJ_FCG_CATEGORY_COLUMN_COUNT,
	              CSM_Constants.OBJ_FCG_ISACTIVE
	      };
	
	      List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCG,
	          CSM_Constants.DML_OPERATION_INSERT, focusCategoryGroupFieldList);
	      if (noAccessList.isEmpty()) {
	          focusCategoryGroupList.add(clonedFocusCategoryGroup);
	          insert focusCategoryGroupList;
	      } else {
	          String[] arguments = new String[] {
	              CSM_Constants.OBJ_FCG + ':' + String.valueOf(noAccessList)
	          };
	          throw new CSM_AccessController.AccessControlDmlException(String.format(System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE,
	              arguments));
	      }
	
	      return focusCategoryGroupList;
	  }
	
	/**
	  * @description Clone FocusCategoryColumn records and insert clone records
	  * @param List<CSM_Focus_Category_Group__c> of FocusCategoryGroup records and List<String> of focusCategoryGroup Id's.
	  * @return List<CSM_Focus_Category_Column__c>  FocusCategoryColumn Records
	  */
	 public List<CSM_Focus_Category_Column__c> cloneFocusCategoryColumn(List<CSM_Focus_Category_Group__c> newFocusCategoryGroupList, List<String> focusCategoryGroupId) {
	     List<CSM_Focus_Category_Column__c> focusCategoryColumnCloneList = new List<CSM_Focus_Category_Column__c> ();
	     List<CSM_Focus_Category_Column__c> focusCategoryColumnList = GetFocusCategoryColumnList(focusCategoryGroupId[0]);
	     if (!focusCategoryColumnList.isEmpty()) {
		     Id newFocusCategoryGroupId = newFocusCategoryGroupList[0].Id;
		
		     List<String> focusCategoryColumnFieldList = new List<String> {
		             CSM_Constants.OBJ_FCC_COLUMN_ORDER,
		             CSM_Constants.OBJ_FCC_CATEGORY_GROUP,
		             CSM_Constants.OBJ_FCC_CATEGORIES_COUNT,
		             CSM_Constants.OBJ_FCC_DISPLAY_NAME,
		             CSM_Constants.OBJ_FCC_ISACTIVE  
		     };  
		 
		     List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FCC,
		         CSM_Constants.DML_OPERATION_INSERT, focusCategoryColumnFieldList);
		     if (noAccessList.isEmpty()) {
		         for (CSM_Focus_Category_Column__c fcc: focusCategoryColumnList) {
		             String oldfccId = fcc.CSM_Focus_Category_Group__c;
		             CSM_Focus_Category_Column__c newFcc = fcc.clone(false, false, false, false);
		             newFcc.CSM_Focus_Category_Group__c = newFocusCategoryGroupId;
		             newFcc.Focus_Category_Column_Old_Id__c = fcc.Id;
		             String displayName = Label.CSM_LBL_CLONE_PREFIX + ' ' + fcc.CSM_Display_Name__c;
		             newFcc.CSM_Display_Name__c = displayName.length() > 40 ? displayName.substring(0, 40) : displayName;
		             focusCategoryColumnCloneList.add(newFcc);
		         }
		     }
		
		     if (noAccessList.isEmpty() && !focusCategoryColumnCloneList.isEmpty()) {
		         insert focusCategoryColumnCloneList;
		     } else {
		         String[] arguments = new String[] {
		             CSM_Constants.OBJ_FCC + ':' + String.valueOf(noAccessList)
		         };
		         throw new CSM_AccessController.AccessControlDmlException(String.format(System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE,
		             arguments));
		     }
	     }
	     return focusCategoryColumnCloneList;
	 }

	 /**
	  * @description Clone FocusCategory records and insert clone records
	  * @param List<CSM_Focus_Category__c> of focusCategory Records.
	  * @return void method
	  */
	public static void insertFocusCategory(List<CSM_Focus_Category__c> focusCategoryList) {
	
	    if (!focusCategoryList.isEmpty()) {
	        List<String> focusCategoryFieldList = new List<String> {
	            CSM_Constants.OBJ_FC_CATEGORY_COLUMN,
	                CSM_Constants.OBJ_FC_FOCUS_CATEGORY_VIEW,
	                CSM_Constants.OBJ_FC_ISACTIVE,
	                CSM_Constants.OBJ_FC_VIEW_ORDER
	        };
	        List<String> noAccessList = CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(CSM_Constants.OBJ_FC,
	            CSM_Constants.DML_OPERATION_INSERT, focusCategoryFieldList);
	
	        if (noAccessList.isEmpty()) {
	            insert focusCategoryList;
	        } else {
	            String[] arguments = new String[] {
	                CSM_Constants.OBJ_FC + ':' + String.valueOf(noAccessList)
	            };
	            throw new CSM_AccessController.AccessControlDmlException(String.format(System.Label.CSM_MSG_OBJECT_NOT_INSERTABLE,
	                arguments));
	        }
	    }
	}
	 
	 /**
	  * @description returns focusCategoryGroup record by doing query.
	  * @param String, focusCategoryGroup Id.
	  * @return CSM_Focus_Category_Group__c, focusCategoryGroup record.
	  */
	 private static CSM_Focus_Category_Group__c GetFocusCategoryGroupRecord(String focusCategoryGroupId) {
	 	 CSM_Focus_Category_Group__c focusCategoryGroup;
	 	 if (focusCategoryGroupId !=null) {
	     	CSM_QueryBuilder q = new CSM_QueryBuilder(CSM_Constants.OBJ_FCG, '');
	     	focusCategoryGroup = Database.Query(q.GetQueryById(CSM_Constants.OBJ_AP_ID, focusCategoryGroupId));
	 	 }
	     return focusCategoryGroup;
	 }  
	
	 /**
	  * @description returns FocusCategoryColumn List by doing query.
	  * @param List<CSM_Focus_Category_Column__c> , FocusCategoryColumn List.
	  * @return List<CSM_Focus_Category_Column__c> , GetFocusCategoryColumn records.
	  */
	 private static List<CSM_Focus_Category_Column__c> GetFocusCategoryColumnList(String focusCategoryGroupId) {
	 	List<CSM_Focus_Category_Column__c> FocusCategoryColumnRecordList ;
	 	if (focusCategoryGroupId !=null) {
	     CSM_QueryBuilder q = new CSM_QueryBuilder(CSM_Constants.OBJ_FCC, '');
	     FocusCategoryColumnRecordList = Database.Query(q.GetQueryById(CSM_Constants.OBJ_FCC_CATEGORY_GROUP, focusCategoryGroupId));
	 	}
	     return FocusCategoryColumnRecordList;
	 }
	 
	public static void deleteFocusCategoryGroup(CSM_Focus_Category_Group__c fcg) 
	{
		
	}	 
	 
	/*Added for US315 to delete the Focus Category Group*/
	public static void deleteFocusCategoryGroup(List<CSM_Focus_Category_Group__c> fcgList) 
	{
		try{
			//List<CSM_Focus_Category_Group__c> fcgList = new List<CSM_Focus_Category_Group__c>();
			//fcgList.add(fcg);
			System.Debug('GeoupDelete' + fcgList[0].Id);
			CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_FCG, null, CSM_Constants.DML_OPERATION_DELETE);
			delete fcgList;		
		}
		catch (exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
		}	

	}
	 
	 
	 
}