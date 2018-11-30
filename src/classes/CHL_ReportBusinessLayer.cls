public with sharing class CHL_ReportBusinessLayer {
	
	public static List<CHL_ReportWrapper>  getReportDetails(String inputvalue) {
	 	List<CHL_ReportWrapper> reportWrapperlist = new List<CHL_ReportWrapper>();
		String nameSpacePrefix = CSM_Util.getNamespace();
		Boolean is2TierEnabled = false;
		if(!CHL_OpptyStatusLogDataAccess.opptyStatusLogList.isEmpty()) {
			is2TierEnabled = (Boolean)(CHL_OpptyStatusLogDataAccess.opptyStatusLogList[0]).get(nameSpacePrefix+'CHL_Enable_2_Tier_Pricing__c');
		}
		Account acc = (Account)CHL_Util.currentUserDetails[0].getSobject('Account');
        String currentUserAccountType = acc <>null ? (String)acc.get('CHL_Partner_Account_Type__c'): '';
		
		String reportFolderName = is2TierEnabled && (currentUserAccountType == 'Reseller' || currentUserAccountType== null)? 'Reseller_Portal_Reports' : 'Portal_Reports';
		Boolean isAccess = Ren_ReportAndFolderDataAccess.hasAccessOnFolder(reportFolderName);
		
		List<Report> reportInFolderList = Ren_ReportAndFolderDataAccess.getReportsByDateFromFolder(reportFolderName,false);
		if(Test.isRunningTest()){
			reportInFolderList = Ren_ReportAndFolderDataAccess.getReportsByDateFromFolder('CSM_Reports',false);
		}
		system.debug('reportInFolderList' + reportInFolderList );
		
		Set<String> selectedReports =  new Set<String>();
		CSM_User_Preferences__c userPref = CSM_UserPreferencesUtil.getUserPreferences(userinfo.getUserId(),CHL_Constants.PORTAL_REPORTS_USER_PREF);
	    if(userPref.CHL_Selected_Community_Reports__c<>null)
	    	selectedReports.addAll(userPref.CHL_Selected_Community_Reports__c.split(';'));
	    	
		if(!reportInFolderList.isEmpty() ){
			for(Report reportObj :reportInFolderList ){
				CHL_ReportWrapper reportWrapperObj = new CHL_ReportWrapper();
				reportWrapperObj.id = reportObj.id;
				reportWrapperObj.id = reportWrapperObj.id.subString(0,15);
				reportWrapperObj.name = reportObj.name;
				reportWrapperObj.tileVisible = selectedReports.contains(reportWrapperObj.id)?true:false;
				reportWrapperObj.style = reportObj.format.Equals('Tabular')?'TABLE':'CHART';
				reportWrapperlist.add(reportWrapperObj);
		  }
			system.debug('Check this :' + json.serialize(reportWrapperlist));
	 	}
	 	return reportWrapperlist;
	 }
	 
	 public static String saveReports(String inputvalue) {
	   	CHL_ReportWrapper reportWrapper = new CHL_ReportWrapper();
	   	reportWrapper = (CHL_ReportWrapper) JSON.deserialize(inputvalue, CHL_ReportWrapper.class);
	   	
	   	Set<String> selectedReports = new Set<String>();
	   	
	   	CSM_User_Preferences__c userPref = CSM_UserPreferencesUtil.getUserPreferences(userinfo.getUserId(),CHL_Constants.PORTAL_REPORTS_USER_PREF);
	    if(userPref.CHL_Selected_Community_Reports__c<>null)
	    	selectedReports.addAll(userPref.CHL_Selected_Community_Reports__c.split(';'));
	   	
	   	 if(reportWrapper.tileVisible)
	   	     selectedReports.add(reportWrapper.id);
	   	   else
	   	     selectedReports.remove(reportWrapper.id);
	   	
	   	
	   	String strSelected = '';
	   	for(String selRep:selectedReports)
	   	  strSelected += selRep+';';
	     	 
	   	userPref.CHL_Selected_Community_Reports__c = strSelected;
	   	CSM_UserPreferencesUtil.saveUserPreference( new List<CSM_User_Preferences__c>{userPref}, CHL_Constants.PORTAL_REPORTS_USER_PREF);
	   	
	   	return CHL_Constants.STR_SUCCESS;
	 }
	 
	public class CHL_ReportWrapper {
			public String id;
			public String name;
			public boolean tileVisible;
			public String style;
	}

}