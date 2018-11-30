/**
 * Created Date		: April 26, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
 *
 * Function			: IB Report Page Controller class.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Dilip					US3340					April 26, 2018	1.1			 		Added in sprint 757
**/

public class REN_IBReportController extends REN_BaseMainController {
    
    public REN_QueryBuilderWrapper queryBuilderInputWrapper {get;set;}
    private REN_Renew_Configuration__c renewConfigObj;
    public String selectedObject {get;set;}
    public List<SelectOption> reportList {get;set;}
    public String selectedReport {get;set;}
    public boolean isReportSelEnable {get;set;}
    private List<String> reportColumnList;
    public CSM_DataGridAttribute dataGridAttribute{get; set;} 
    public String criteria {get; set;}
	public String selCurrency {get; set;}
    public String fieldSetName {get; set;} 
    public String parentIdCSV{get;set;}
    public string responseStr{get;set;}
    private String reportFields;
    private String jsonFilterCriteria;
    
    
    
    //Constructor of REN_IBReportController
    public REN_IBReportController(ApexPages.StandardSetController controller){
        try{
        	reportFields = '';
        	responseStr = '';
            selectedReport = '--None--';
            //selectedObject = 'app_coveredassets__x';
            selectedObject = 'Opportunity';
            isReportSelEnable = false;
            fieldSetName = 'REN_Generate_IB_Report';
            this.renewConfigObj = new REN_Renew_Configuration__c();
            parentIdCSV = '';
            
            queryBuilderInputWrapper = new REN_QueryBuilderWrapper(selectedObject);
            
            reportList = new List<SelectOption>();
            reportList.add(new SelectOption('--None--','--None--'));
            
            Set<String> covAssetIdSet = new Set<String>();
            
            for(Report rep : [Select Id from Report where FolderName = 'IB Report' OR CreatedById =: UserInfo.getUserId()]){
                String reportId = (String)rep.get('Id');
                Reports.ReportResults results = Reports.ReportManager.runReport(reportId);
                Reports.ReportMetadata rm = results.getReportMetadata();
                if(rm.getReportType().getLabel() == 'app_coveredassets'){
                	reportList.add(new SelectOption(rm.getId(),rm.getName()));
                }
            }
            
            covAssetIdSet.add('Id');
            
            if(!covAssetIdSet.isEmpty()){
                parentIdCSV = JSON.serialize(covAssetIdSet);
            }
            setGridAttributes();
        }catch(Exception excp){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input - '+excp.getMessage());
			ApexPages.addMessage(myMsg);
        }
        
    }//End of constructor
    
    
    private void setGridAttributes(){                                
		dataGridAttribute = new CSM_DataGridAttribute();        
		dataGridAttribute.tableName = 'IBReportSearch';
		dataGridAttribute.objectType ='IBReportSearch';
		dataGridAttribute.viewName ='IBReportSearch';
		dataGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
		dataGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
		dataGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
		dataGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
		dataGridAttribute.showExport ='true';
		dataGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
        criteria = '';
		CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
		gridInputParams.selectedFilterClause = criteria;
		gridInputParams.gridCurrency = selCurrency;
        System.debug('**gridInputParams ' + gridInputParams);
		dataGridAttribute.params = JSON.serialize(gridInputParams);
        Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		dataGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
	}
    
    public PageReference findFor(){
    	try{
    		
    		REN_QueryBuilderCompController queryBuilderObj = new REN_QueryBuilderCompController();
        	queryBuilderObj.queryBuilder(queryBuilderInputWrapper);
        	List<Schema.FieldSetMember> fieldSetMemberList = CHL_Util.getFieldSet(fieldSetName, selectedObject);
            Integer recordLimit = (Integer)CSM_Admin__c.getInstance().REN_IB_Report_Records_Limit__c;
            //https://sqa.dev.ssi-cloud.com/odata/frb1/dell_report/app_coveredassets
            String fieldsName = '';
            Boolean isValid = REN_QueryBuilderHelper.validateCriteria(queryBuilderInputWrapper);
    		
    		if(isValid){
            	jsonFilterCriteria = REN_IBReportODataController.formODataQueryInJson(queryBuilderInputWrapper.columnFilterList,queryBuilderInputWrapper.filterLogic);
        	
            	for(Schema.FieldSetMember fld :fieldSetMemberList){
	            	fieldsName += fld.getLabel() + ',';
            	}
            
            	Integer index = fieldsName.lastIndexOf(',');
            	if(index != -1) {
                	fieldsName = fieldsName.substring(0,index);
            	}
                String finalQuery = '{"filter":"'+jsonFilterCriteria+'","select":"'+fieldsName+'"}';
            
            	REN_IBReportCallout calout = new REN_IBReportCallout();
            	responseStr = calout.postHttpRequest(finalQuery,'?$top='+ recordLimit +'&$select='+fieldsName,'GET').getBody();
        		isReportSelEnable = true;
            }
        }catch(Exception excp){
            System.debug('**Exception ' + excp.getStackTraceString());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input - '+excp.getMessage());
			ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    public PageReference createIBReport(){
        String endPoint = 'https://sqa.dev.ssi-cloud.com/odata/frb1/dell_report/app_coveredassets';
        String finalQuery = '';
        try{
        	
        	reportColumnList = Reports.ReportManager.runReport(selectedReport).getReportMetadata().getDetailColumns();
            
            for(String str : reportColumnList){
                reportFields += str + ', ';
            }
            Integer fieldindex = reportFields.lastIndexOf(',');
            if(fieldindex != -1) {
                reportFields = reportFields.substring(0,fieldindex);
            }
            
            setGridAttributes();
        	
	        finalQuery = '{"filter":"'+jsonFilterCriteria +'","select":"' +reportFields +'","userId":"'+UserInfo.getUserId()+'"}';
	        
	        REN_IBReportCallout callout = new REN_IBReportCallout();
	        callout.postHttpRequest(finalQuery,endPoint,'POST');  
        }
        catch(Exception excp){
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input - '+excp.getMessage());
			ApexPages.addMessage(myMsg);
        }
        return null;  
    }

}