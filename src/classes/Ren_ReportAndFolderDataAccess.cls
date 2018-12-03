public with sharing class Ren_ReportAndFolderDataAccess {
	
	public static boolean hasAccessOnFolder(String folderName){
		
        List<String> fieldListForCRUD = new List<String>{REN_Constants.OBJ_FOLDER_FLD_DEVELOPER_NAME};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_FOLDER, fieldListForCRUD, CSM_Constants.DML_OPERATION_READ);
		
		List<Folder> folderList = [SELECT id FROM Folder where DeveloperName =: folderName];
		return (FolderList != null && !FolderList.isEmpty());
	}
	
	public static List<Report> getReportsByDateFromFolder(String folderName, boolean isOrderByCreatedDate){
		
        List<String> fieldListForReportCRUD = new List<String>{REN_Constants.OBJ_FOLDER_FLD_DEVELOPER_NAME};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_REPORT,fieldListForReportCRUD, CSM_Constants.DML_OPERATION_READ);
        
        List<String> fieldListForFolderCRUD = new List<String>{REN_Constants.OBJ_FOLDER_FLD_DEVELOPER_NAME};
        CSM_Util.checkCRUD_FLS(REN_Constants.OBJ_FOLDER, fieldListForFolderCRUD, CSM_Constants.DML_OPERATION_READ);
        List<Report> reportList = null;
        if(isOrderByCreatedDate){
        	reportList = [SELECT id, Name, format FROM Report WHERE OwnerId in (SELECT id FROM folder where developerName =: folderName) order by CreatedDate asc limit 10000];
        }else{
        	reportList = [SELECT id, Name, format FROM Report WHERE OwnerId in (SELECT id FROM folder where developerName =: folderName) order by name limit 10000];
        }
		return reportList;
	}
	
	public static List<SelectOption> getCannedReports(String objectName, Set<String> folderNames){
        
        List<SelectOption> reportList = new List<SelectOption>();
        
        if(folderNames != null && !folderNames.isEmpty() && !String.isEmpty(objectName)){
            for(Report rep : [Select Id, Name,Format from Report where Format = 'tabular' And (FolderName In : folderNames OR CreatedById =: UserInfo.getUserId())]){
                String reportId = (String)rep.get('Id');
                if(objectName.contains(Reports.ReportManager.describeReport(reportId).getReportMetadata().getReportType().getLabel())){
                    reportList.add(new SelectOption(rep.Id, rep.Name));
                }
            }
            return reportList;
        }
        return null;
    }
}