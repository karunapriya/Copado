public with sharing class REN_ReportChartDisplayController {
	public list<SelectOption> leftPickList {get; set;}
    public list<SelectOption> rightPickList {get; set;}  
    public list<ID> leftSelectedOptions{get; set;}
    public list<ID> rightSelectedOptions{get; set;}
	private CSM_User_Preferences__c preferenceObj;
	public List<Folder> folderList;
	public Map<String, Report> reportMap{get; set;}
	
	public boolean isSaveBtnVisible{get; set;}
	public boolean isChooseChartBtnVisible{get; set;}
	public boolean isNoFilesInFolderVisible{get; set;}
	public boolean isFolderAccess{get; set;}
	public boolean isPanelVisible{get; set;}

  	public REN_ReportChartDisplayController(){
   		isChooseChartBtnVisible = true;
   		isNoFilesInFolderVisible = false;
   		isPanelVisible = false;
		reportMap = new Map<String, Report>(Ren_ReportAndFolderDataAccess.getReportsByDateFromFolder(REN_Constants.REN_INSIGHTS_FOLDER, true));
		
   		leftSelectedOptions = new list<ID>();
   		isFolderAccess = Ren_ReportAndFolderDataAccess.hasAccessOnFolder(REN_Constants.REN_INSIGHTS_FOLDER);
   		preferenceObj = CSM_UserPreferencesUtil.getUserPreferences(UserInfo.getUserId(), 'Ren_Insights_Selected_Reports__c');  
       	
       		if(preferenceObj != null && String.isNotBlank(preferenceObj.Ren_Insights_Selected_Reports__c)){
   				List<String> selectedCharts = preferenceObj.Ren_Insights_Selected_Reports__c.split(';'); 
    			if(selectedCharts != null){
    				for(String s:selectedCharts){
    					if(reportMap.containsKey(s.trim())){
    						reportListToDisplay.add(s.trim());
    					}
    				}
    			}
			}else if(preferenceObj.Ren_Insights_Selected_Reports__c == null){
				if(reportMap != null){
					for(Report r: reportMap.values()){
						if(reportListToDisplay.size() > 5){
							break;
						}
						reportListToDisplay.add(r.id);
					}
				}
			}
			
			system.debug('\n\n reportListToDisplay :: ' + reportListToDisplay );	
			
	}
    
   	public PageReference selectReports(){
   		
   		leftPickList = new list<SelectOption>();
   		rightPickList = new list<SelectOption>();
   		leftSelectedOptions = new list<ID>();
   		rightSelectedOptions = new list<ID>();
   		
        List<Report> reportList = Ren_ReportAndFolderDataAccess.getReportsByDateFromFolder(REN_Constants.REN_INSIGHTS_FOLDER, false);
        if(reportList != null){
            for(Report rpt : reportList){
            	SelectOption so = new SelectOption(rpt.id, rpt.name);
            	leftPickList.add(so);
            } 
            getUserPref();       
        } 
        isSaveBtnVisible = true;
        isChooseChartBtnVisible = false;
        isPanelVisible = true;
        reportListToDisplay.clear();
        return null;  
    }
    
    
    public boolean isReportInFolder {
		get{
			return  !reportMap.isEmpty();
		} 
		set;
	}
	
	
	 public boolean isSelectedReportsInFolder {
		get{
			return ((reportListToDisplay != null && !reportListToDisplay.isEmpty()));
		} 
		set;
	}
	
	
	public List<String> reportListToDisplay {
		get{
			if(reportListToDisplay==null) reportListToDisplay= new List<String>(); 
				return reportListToDisplay;
			}
		set;
	}
    
    public PageReference moveLeftToRight(){
    	if(!leftSelectedOptions.isEmpty()){
    		Set<ID> leftSelectedIdSet = new Set<ID>(leftSelectedOptions);
    		for(Integer i = leftPickList.size()-1; i > -1; i--){
    		if(leftSelectedIdSet.contains(leftPickList[i].getValue())){
	    			if(rightPickList.size() > 5){
	    				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Warning,System.Label.REN_LBL_MAX_ROWS_ADDED));
	    		}else{
	    				rightPickList.add(leftPickList[i]);
	    				leftPickList.remove(i);
	    			}
    			}
    		}
    	}
    	return null;
    }

    public PageReference moveRightToLeft(){
    	if(!rightSelectedOptions.isEmpty()){
    		Set<ID> rightSelectedIdSet = new Set<ID>(rightSelectedOptions);
    		for(Integer i = rightPickList.size()-1; i > -1; i--){
    		if(rightSelectedIdSet.contains(rightPickList[i].getValue())){
    				leftPickList.add(rightPickList[i]);
    				rightPickList.remove(i);
    		}
    		}
    	}
    	return null;
    }
    
     public PageReference moveUp() {
        set<ID> selectedIdSet = new set<ID>(rightSelectedOptions);
        if(rightPickList != null && rightPickList.size() > 1){
            for(Integer j = 1; j < rightPickList.size(); j++){
             if(selectedIdSet.contains(rightPickList[j].getValue()) && !selectedIdSet.contains(rightPickList[j-1].getValue())){
                	SelectOption tempSelectOption = rightPickList[j];
                	rightPickList[j] = rightPickList[j-1];
                	rightPickList[j-1] = tempSelectOption;
              }
            }
        }
        return null;
    }
    
     public PageReference moveDown() {
        set<ID> selectedIdSet = new set<ID>(rightSelectedOptions);
        if(rightPickList != null && rightPickList.size() > 1){
        	  for(Integer j = rightPickList.size()-2; j > -1 ; j--){
               if(selectedIdSet.contains(rightPickList[j].getValue()) && !selectedIdSet.contains(rightPickList[j+1].getValue())){
                	SelectOption tempSelectOption = rightPickList[j+1];
                	rightPickList[j+1] = rightPickList[j];
                	rightPickList[j] = tempSelectOption;
               }
            }
        }
        return null;
    }

	public void getUserPref() {
      	preferenceObj = CSM_UserPreferencesUtil.getUserPreferences(UserInfo.getUserId(), 'Ren_Insights_Selected_Reports__c');   
       	if(preferenceObj != null && String.isNotBlank(preferenceObj.Ren_Insights_Selected_Reports__c)){
       		if(preferenceObj.Ren_Insights_Selected_Reports__c != '-'){
	       		List<String> selectedCharts = preferenceObj.Ren_Insights_Selected_Reports__c.split(';'); 
	        	if(selectedCharts != null){
	        		for(String s:selectedCharts){
	        			leftSelectedOptions.add(ID.valueOf(s.trim()));
	        		}
	        	}
        	}
       	}else{//Default
        	List<Report> reportList = Ren_ReportAndFolderDataAccess.getReportsByDateFromFolder(REN_Constants.REN_INSIGHTS_FOLDER, true);
			if(reportList != null){
				for(Report r: reportList){
				if(leftSelectedOptions.size() > 5){
						break;
				}
					leftSelectedOptions.add(r.id);
				}
			}
		}
		moveLeftToRight();
       	leftSelectedOptions.clear();
	}
	
    public void saveUserPreferences() {
    	reportListToDisplay.clear();
        String reportIds = '';
        if(preferenceObj == null ){
        	preferenceObj = new CSM_User_Preferences__c();
        }
        system.debug('\n rightPickList:' + rightPickList);
        for(SelectOption so: rightPickList){
        system.debug(so.getValue() +'\n so:' + so);
        	reportListToDisplay.add(so.getValue());
            reportIds +=  so.getValue() + ';' ;
        }
        if(reportIds.length() > 0){
        	reportIds = reportIds.subString(0, reportIds.length()-1);
        }else{
        	reportIds = '-';
        }
        preferenceObj.Ren_Insights_Selected_Reports__c  = reportIds;
        CSM_UserPreferencesUtil.saveUserPreference(new List<CSM_User_Preferences__c>{preferenceObj}, 'Ren_Insights_Selected_Reports__c'); 
        isSaveBtnVisible = false;
        isChooseChartBtnVisible = true;
        isPanelVisible = false;
    }

}