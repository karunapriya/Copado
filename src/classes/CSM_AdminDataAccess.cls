public with sharing class CSM_AdminDataAccess {

	private Static Map<String, Integer> limitMap;
	public static CSM_Admin__c getCSMAdminInstance() {
		return CSM_Admin__c.getInstance();
	}
		
	public static Set<String> getObjectSet(String objectType){
		Set<String> objectSet = new Set<String>();
		
		List<String> values = new List<String>();
		if (getCSMAdminInstance()!=null) {
			if (objectType==CSM_Constants.OBJ_LIST_INDICATORS) {
				
				values = getCSMAdminInstance().CSM_IndicatorObjects__c.split(';');
			}
			if (objectType==CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES) {
		        values = getCSMAdminInstance().CSM_Focus_Category_Objects__c.split(';');
			}
			if (objectType == CSM_Constants.OBJ_LIST_PLAYS &&
				getCSMAdminInstance().CSM_Play_Objects__c!=null) {
				values = getCSMAdminInstance().CSM_Play_Objects__c.split(';');
			}
			if (objectType==CSM_Constants.OBJ_LIST_HEALTH_COLORS) {
		        values = getCSMAdminInstance().CSM_Health_Status_Colors__c.split(';');
			}
			if (objectType==CSM_Constants.OBJ_LIST_PHASE_COLORS) {
		        values = getCSMAdminInstance().CSM_Phase_Colors__c.split(';');
			}
			if (objectType == CSM_Constants.OBJ_LIST_HEALTH_OPTIONS)
			{
				 values = getCSMAdminInstance().CSM_Health_Status_Options__c.split(';');
			}
			if (objectType == CSM_Constants.OBJ_LIST_OPPTY_RELATED_LIST &&
				getCSMAdminInstance().REN_Opportunity_Related_List__c!=null) {
				values = getCSMAdminInstance().REN_Opportunity_Related_List__c.split(';');
			}
		}
		 for (String objectName: values) {
            objectSet.add(objectName.trim());
        }           
        
        return objectSet;
	}
	
	public static List<String> getAdminList(String objectType){
		List<String> objectList = new List<String>();
		
		List<String> values = new List<String>();
		if (getCSMAdminInstance()!=null) {
			if (objectType==CSM_Constants.OBJ_LIST_INDICATORS) {
				
				values = getCSMAdminInstance().CSM_IndicatorObjects__c.split(';');
			}
			if (objectType==CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES) {
		        values = getCSMAdminInstance().CSM_Focus_Category_Objects__c.split(';');
			}
			if (objectType==CSM_Constants.OBJ_LIST_HEALTH_COLORS) {
				if (getCSMAdminInstance().CSM_Health_Status_Colors__c != null)
				{
		            values = getCSMAdminInstance().CSM_Health_Status_Colors__c.split(';');
				}
			}
			if (objectType==CSM_Constants.OBJ_LIST_PHASE_COLORS) {
				if (getCSMAdminInstance().CSM_Phase_Colors__c != null)
				{
		            values = getCSMAdminInstance().CSM_Phase_Colors__c.split(';');
				}
			}
			if (objectType == CSM_Constants.OBJ_LIST_HEALTH_OPTIONS)
			{
				if (getCSMAdminInstance().CSM_Health_Status_Options__c != null)
				{
				    values = getCSMAdminInstance().CSM_Health_Status_Options__c.split(';');
				}
			}
		}
		 for (String objectName: values) {
            objectList.add(objectName.trim());
        }           
        return objectList;
	}
	public static List<SelectOption> getObjectList(String objectType){	
		return getObjectList(objectType, null);
	}

	
	public static List<SelectOption> getObjectList(String objectType, String objectToIgnore){
		List<SelectOption> objectList = new List<SelectOption>();
		
		List<String> values = new List<String>();
		if (getCSMAdminInstance()!=null) {
			if (objectType==CSM_Constants.OBJ_LIST_INDICATORS && 
				getCSMAdminInstance().CSM_IndicatorObjects__c!=null) {
				values = getCSMAdminInstance().CSM_IndicatorObjects__c.split(';');
			}
			if (objectType==CSM_Constants.OBJ_LIST_FOCUS_CATEGORIES &&
				getCSMAdminInstance().CSM_Focus_Category_Objects__c!=null) {
		        values = getCSMAdminInstance().CSM_Focus_Category_Objects__c.split(';');
			}
			if (objectType == CSM_Constants.OBJ_LIST_PLAYS &&
				getCSMAdminInstance().CSM_Play_Objects__c!=null) {
				values = getCSMAdminInstance().CSM_Play_Objects__c.split(';');
			}
			if (objectType == CSM_Constants.OBJ_LIST_RISK_REASON &&
				getCSMAdminInstance().CSM_Risk_Reason__c!=null) {
				values = getCSMAdminInstance().CSM_Risk_Reason__c.split(';');
				if(getCSMAdminInstance().CSM_Risk_Reason_Cont__c != null){
					values.addAll(getCSMAdminInstance().CSM_Risk_Reason_Cont__c.split(';'));
				}
			}
			else if(objectType == CSM_Constants.OBJ_LIST_RISK_REASON &&
					getCSMAdminInstance().CSM_Risk_Reason_Cont__c != null){
				values = getCSMAdminInstance().CSM_Risk_Reason_Cont__c.split(';');
			}
			if (objectType == CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS &&
				getCSMAdminInstance().CSM_Risk_Reason_Dismiss__c!=null) {
				values = getCSMAdminInstance().CSM_Risk_Reason_Dismiss__c.split(';');
				if(getCSMAdminInstance().CSM_Risk_Reason_Dismiss_Cont__c != null){
					values.addAll(getCSMAdminInstance().CSM_Risk_Reason_Dismiss_Cont__c.split(';'));
				}
			}
			else if(objectType == CSM_Constants.OBJ_LIST_RISK_REASON_DISMISS && 
					getCSMAdminInstance().CSM_Risk_Reason_Dismiss_Cont__c != null){
					values = getCSMAdminInstance().CSM_Risk_Reason_Dismiss_Cont__c.split(';');
			}
			if (objectType == CSM_Constants.OBJ_LIST_OPPTY_RELATED_LIST &&
				getCSMAdminInstance().REN_Opportunity_Related_List__c!=null) {
				values = getCSMAdminInstance().REN_Opportunity_Related_List__c.split(';');
			}
			if (objectType == CSM_Constants.OBJ_LIST_FILTER_ATTRIBUTES &&
				getCSMAdminInstance().CSM_Overview_Filter_Attributes__c!=null) {
				values = getCSMAdminInstance().CSM_Overview_Filter_Attributes__c.split(';'); 
			}
			if (objectType == CSM_Constants.OBJ_LIST_SP_FILTER_ATTRIBUTES &&
				getCSMAdminInstance().CSM_Overview_SP_Filter_Attribute__c!=null) {
				values = getCSMAdminInstance().CSM_Overview_SP_Filter_Attribute__c.split(';'); 
			}
			if (objectType == CSM_Constants.OBJ_LIST_TASK_FILTER_ATTRIBUTES &&
				getCSMAdminInstance().CSM_Overview_Task_Filter_Attributes__c!=null) {
				values = getCSMAdminInstance().CSM_Overview_Task_Filter_Attributes__c.split(';'); 
			}			
			if (objectType == CSM_Constants.OBJ_LIST_RISK_REASON_COMBINED) {
				if(getCSMAdminInstance().CSM_Risk_Reason__c!=null) {
					values.addAll(getCSMAdminInstance().CSM_Risk_Reason__c.split(';'));
				}
				if(getCSMAdminInstance().CSM_Risk_Reason_Cont__c != null){
					values.addAll(getCSMAdminInstance().CSM_Risk_Reason_Cont__c.split(';'));
				}
				if (getCSMAdminInstance().CSM_Risk_Reason_Dismiss__c!=null) {
					values.addAll(getCSMAdminInstance().CSM_Risk_Reason_Dismiss__c.split(';'));
				}
				if (getCSMAdminInstance().CSM_Risk_Reason_Dismiss_Cont__c != null){
					values.addAll(getCSMAdminInstance().CSM_Risk_Reason_Dismiss_Cont__c.split(';'));
				}
			}
		}
		if (objectType != CSM_Constants.OBJ_LIST_OPPTY_RELATED_LIST) {
			objectList.add(new SelectOption('', Label.CSM_LBL_PLEASESELECT));
		}
        if (values!=null && !values.isEmpty()){
			for (String objectName: values) {
				if (objectToIgnore==null || (objectToIgnore!=null && objectName.toLowerCase()!=objectToIgnore)){
					if (objectName.indexOf('=')>-1){
						String[] nameValuePair = objectName.split('=');
						if (nameValuePair.size()>1){
							objectList.add(new SelectOption(nameValuePair[0].trim(), nameValuePair[1].trim()));
						} else {
							objectList.add(new SelectOption(nameValuePair[0].trim(), nameValuePair[0].trim()));
						}
						
					} else {
	            		objectList.add(new SelectOption(objectName.trim(), objectName.trim()));
					}
				}
	        }           
        }
        return objectList;
	}
		
	public static Integer getAccountPlanSelectedTab(){
		
		Decimal selectedTab = 0;
		
		CSM_Admin__c csmAdmin = getCSMAdminInstance();
		if (csmAdmin!=null && csmAdmin.CSM_Default_Plan_Tab__c!=null) {
			selectedTab = csmAdmin.CSM_Default_Plan_Tab__c;
		}
		if (selectedTab==null){
			selectedTab = 0;
		} 
				
		if (selectedTab > 5 || selectedTab < 0){
			selectedTab = 0;
		}
		
		return Integer.valueOf(selectedTab);
	}
			
	public static Integer getFocusCategoryColumnLimit(){
		Integer columnLimit = 0;
		CSM_Admin__c csmAdmin = getCSMAdminInstance();
		if (csmAdmin!=null && csmAdmin.CSM_Focus_Category_Column_Limit__c!=null) {
			columnLimit = (Integer)csmAdmin.CSM_Focus_Category_Column_Limit__c;
		}
		if (columnLimit==null){
			columnLimit = 4;
		}
		if (columnLimit==0 || columnLimit>4){
			columnLimit = 4;
		}
		return columnLimit;
	}
		
	public static Integer getFocusCategoryRecLimit(){
		Integer recLimit = 0;
		CSM_Admin__c csmAdmin = getCSMAdminInstance();
		if (csmAdmin!=null && csmAdmin.CSM_Focus_Categories_Rec_To_Display__c!=null) {
			recLimit = (Integer)csmAdmin.CSM_Focus_Categories_Rec_To_Display__c;
		}
		if (recLimit==null){
			recLimit = 10;
		}
		if (recLimit==0 || recLimit>20){
			recLimit = 10;
		}
		return recLimit;
	}	
		
	public static Integer getFocusCategoryMaxRecLimit(){
		Integer maxRecLimit = 0;
		CSM_Admin__c csmAdmin = getCSMAdminInstance();
		if (csmAdmin!=null && csmAdmin.CSM_Focus_Category_Max_Records__c!=null) {
			maxRecLimit = (Integer)csmAdmin.CSM_Focus_Category_Max_Records__c;
		}
		if (maxRecLimit==null){
			maxRecLimit = 1000;
		}
		if (maxRecLimit==0 || maxRecLimit>1000){
			maxRecLimit = 1000;
		}
		return maxRecLimit;
	}		
		
	public static Integer getFocusCategoryTilesLimit(){
		Integer tilesLimit = 0;
		CSM_Admin__c csmAdmin = getCSMAdminInstance();
		if (csmAdmin!=null && csmAdmin.CSM_Focus_Category_Tiles_Limit__c!=null) {
			tilesLimit = (Integer)csmAdmin.CSM_Focus_Category_Tiles_Limit__c;
		}
		if (tilesLimit==null || (tilesLimit!=null && tilesLimit==0)){
			tilesLimit = 8;
		}
		return tilesLimit;
	}
		
	public static Integer getRecLimit(String screenName){
		Integer maxRecLimit = 0;
		Integer maxLimit = 0;
		CSM_Admin__c csmAdmin = getCSMAdminInstance();
		if (limitMap==null){
			limitMap = new Map<String, Integer>();
		}
		if (limitMap.containsKey(screenName)){
			maxRecLimit = limitMap.get(screenName);
		} else {
			if (screenName == CSM_Constants.REC_LIMIT_ASSETS && csmAdmin!=null) {
				maxLimit = 2500;
				if (csmAdmin.CSM_Asset_Rec_Limit__c!=null && csmAdmin.CSM_Asset_Rec_Limit__c < maxLimit) {
					maxRecLimit = (Integer)csmAdmin.CSM_Asset_Rec_Limit__c;
				}
			}
			if (screenName == CSM_Constants.REC_LIMIT_FOCUS_CATEGORIES && csmAdmin!=null) {
				maxLimit = 10000;
				if (csmAdmin.CSM_Focus_Categories_Rec_Limit__c!=null) {
					maxRecLimit = (Integer)csmAdmin.CSM_Focus_Categories_Rec_Limit__c;
				}
			}
			if (screenName == CSM_Constants.REC_LIMIT_SERVICE_CONTRACT && csmAdmin!=null) {
				maxLimit = 2500;
				if (csmAdmin.CSM_Service_Contract_Rec_Limit__c!=null && csmAdmin.CSM_Service_Contract_Rec_Limit__c < maxLimit) {
					maxRecLimit = (Integer)csmAdmin.CSM_Service_Contract_Rec_Limit__c;
				}
			}
			if (screenName == CSM_Constants.REC_LIMIT_HEALTH_CHARTS && csmAdmin!=null) {
				maxLimit = 5000;
				if (csmAdmin.CSM_Health_Charts_Rec_Limit__c!=null) {
					maxRecLimit = (Integer)csmAdmin.CSM_Health_Charts_Rec_Limit__c;
				}
			}
			if (screenName == CSM_Constants.REC_LIMIT_SUCCESS_TASKS && csmAdmin!=null) {
				maxLimit = 5000;
				if (csmAdmin.CSM_Success_Task_Rec_Limit__c!=null) {
					maxRecLimit = (Integer)csmAdmin.CSM_Success_Task_Rec_Limit__c;
				}
			}
			if (screenName == CSM_Constants.REC_LIMIT_ACTIONS && csmAdmin!=null) {
				maxLimit = 500;
				if (csmAdmin.CSM_Actions_Rec_Limit__c!=null) {
					maxRecLimit = (Integer)csmAdmin.CSM_Actions_Rec_Limit__c;
				}
			}
			if (screenName == CSM_Constants.REC_LIMIT_ACTIVITY_HISTORY && csmAdmin!=null) {
				maxLimit = 500;
				if (csmAdmin.CSM_Activity_History_Rec_Limit__c!=null) {
					maxRecLimit = (Integer)csmAdmin.CSM_Activity_History_Rec_Limit__c;
				}
			}
			if (screenName == CSM_Constants.REC_LIMIT_OPPORTUNITIES && csmAdmin!=null) {
				maxLimit = 1000;
				if (csmAdmin.CSM_Opportunity_Rec_Limit__c!=null) {
					maxRecLimit = (Integer)csmAdmin.CSM_Opportunity_Rec_Limit__c;
				}
			}
			if (screenName == CSM_Constants.REC_LIMIT_PLAYBOOK && csmAdmin!=null) {
				maxLimit = 250;
				if (csmAdmin.CSM_Playbook_Rec_Limit__c!=null) {
					maxRecLimit = (Integer)csmAdmin.CSM_Playbook_Rec_Limit__c;
				}
			}
			if (screenName == REN_Constants.REC_LIMIT_BATCH_OPP_GENRATION_GRID && csmAdmin!=null) {
				maxLimit = 250;
				if (csmAdmin.REN_Batch_OppGenration_Grid_Rec_Limit__c!=null) {
					maxRecLimit = (Integer)csmAdmin.REN_Batch_OppGenration_Grid_Rec_Limit__c;
				}
			}
			if (screenName == REN_Constants.REC_LIMIT_AUTOMATED_GENRATION_LOG_GRID && csmAdmin!=null) {
				maxLimit = 250;
				if (csmAdmin.REN_Automated_Gen_Log_Rec_Limit__c!=null) {
					maxRecLimit = (Integer)csmAdmin.REN_Automated_Gen_Log_Rec_Limit__c;
				}
			}
			//Eswar's opinion - The following logic won't work because you keep changing the maxLimit/maxRecLimit for every IF block above.
			if (maxRecLimit==null){
				maxRecLimit = maxLimit;
			}
			if (maxRecLimit==0 || maxRecLimit>maxLimit){
				maxRecLimit = maxLimit;
			}
			limitMap.put(screenName, maxRecLimit);
		}
		return maxRecLimit;
	}
		
	public static Boolean getIsSCOUTAvailable(){
		Boolean isSCOUTAvailable = false;
		CSM_Admin__c csmAdmin = getCSMAdminInstance();
		if (csmAdmin!=null && csmAdmin.CSM_SCOUT_Installed__c!=null) {
			isSCOUTAvailable = (Boolean)csmAdmin.CSM_SCOUT_Installed__c;
		}
		return isSCOUTAvailable;
	} 
	 
	public static CSM_HelpLinks__c getCSMHelpLinksInstance() {
		return CSM_HelpLinks__c.getInstance();
	}
	
	public static Boolean isRLVersion2CanvasAppSelected(){
		Boolean isVersion2Selected = false;
		CSM_Admin__c csmAdmin = getCSMAdminInstance();
		if (csmAdmin!=null && csmAdmin.CSM_Use_Revenue_Link_v2_Canvas_App__c != null) {
			isVersion2Selected = (Boolean)csmAdmin.CSM_Use_Revenue_Link_v2_Canvas_App__c;
		}
		return isVersion2Selected;
	}
}