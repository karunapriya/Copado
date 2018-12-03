/**
 * Created Date		: April 26, 2018
 * Developed By		: Dilip, Comity Designs, Inc.
 *
 * Function			: IB Export Page Controller class.
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

public with sharing class REN_IBExportController extends REN_BaseMainController {
    
    
    public REN_BaseMainController baseMainController {get; private set;}
    public List<SelectOption> reportList {get;set;}
    private List<String> reportColumnList;
    public CSM_DataGridAttribute dataGridAttribute{get; set;} 
    public string responseStr{get;set;}
    public String selReportId {get; set;}
    public boolean showQueryBuilder {get;set;}
    private String baseNamespace;
    public REN_ConfigSettings configSettings {get; set;}

    public String fieldSetName {get; set;}
    public String invokingObject {get; set;}

    public Integer gridRecordLimit {get;set;}
	public String displayMsg {get;set;}
	public String exportFileName {get;set;}
    
    //Constructor of REN_IBExportController
    public REN_IBExportController(){
        super();
        try{
            
            responseStr = '';
			showQueryBuilder = false;
			exportFileName = '';
            baseNamespace = CSM_Util.getNamespace();

            configSettings = new REN_ConfigSettings();
            configSettings.flowName = 'IB Export';
        	configSettings.initializeConfigSettings(baseNamespace, new List<String>{'IB Export','Generate IB Export'});
            System.debug('ZZZ - configSettings '+configSettings);

        	if(configSettings.configSettingObj == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_Config_Setting_Error, new List<String>{configSettings.flowName}));
                ApexPages.addMessage(myMsg);
            }else if(String.isEmpty((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c'))){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Empty_Object_Error);
                ApexPages.addMessage(myMsg);
            }else if(String.isEmpty((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Field_Set_Name__c'))){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Empty_FieldSet_Error);
                ApexPages.addMessage(myMsg);
            }else if(String.isEmpty((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Columns__c'))){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Filterable_Fields_Error);
                ApexPages.addMessage(myMsg);
            }else if(String.isEmpty((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Named_Credential__c')) || String.isEmpty((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Named_Credential_URL_Extension__c'))){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Named_Credential_Error);
                ApexPages.addMessage(myMsg);
            }else if(!Schema.getGlobalDescribe().containsKey((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c'))){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_Object_Config_Error, new List<String>{(String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c')}));
                ApexPages.addMessage(myMsg);
            }else if(!Schema.getGlobalDescribe().get((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c')).getDescribe().FieldSets.getMap().containsKey((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Field_Set_Name__c'))){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_FieldSet_Config_Error, new List<String>{(String)configSettings.configSettingObj.get(baseNamespace + 'REN_Field_Set_Name__c')}));
                ApexPages.addMessage(myMsg);
            }else if(CHL_Util.getFieldSet((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Field_Set_Name__c'), (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c')).size() <= 0){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_NoField_FieldSet_Error, new List<String>{(String)configSettings.configSettingObj.get(baseNamespace + 'REN_Field_Set_Name__c')}));
                ApexPages.addMessage(myMsg);
            }else if(!Schema.getGlobalDescribe().get((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c')).getDescribe().FieldSets.getMap().containsKey((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Columns__c'))){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_FieldSet_Config_Error, new List<String>{(String)configSettings.configSettingObj.get(baseNamespace + 'REN_Columns__c')}));
                ApexPages.addMessage(myMsg);
            }else if(CHL_Util.getFieldSet((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Columns__c'), (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c')).size() <= 0){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_NoField_FieldSet_Error, new List<String>{(String)configSettings.configSettingObj.get(baseNamespace + 'REN_Columns__c')}));
                ApexPages.addMessage(myMsg);
            }else {
                invokingObject = (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c');
                fieldSetName = (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Field_Set_Name__c');
                System.debug('fieldSetName - '+fieldSetName + ' and invokingObject - '+invokingObject);
                showQueryBuilder = true;
                baseMainController = this;
            }
            
            setGridAttributes();
        }catch(Exception excp){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CHL_GENERAL_ERROR + excp.getMessage());
			ApexPages.addMessage(myMsg);
        }
        
    }//End of constructor
    
    private void setGridAttributes(){                                
		dataGridAttribute = new CSM_DataGridAttribute();        
		dataGridAttribute.tableName = 'IBExportSearch';
		dataGridAttribute.objectType ='IBExportSearch';
		dataGridAttribute.viewName ='IBExportSearch';
		dataGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_FALSE;
		dataGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
		dataGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_FALSE;
		dataGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
		dataGridAttribute.showExport ='false';
		dataGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
		gridInputParams.selectedFilterClause = '';
		gridInputParams.gridCurrency = null;
		gridRecordLimit = (Integer)CSM_Admin__c.getInstance().REN_IB_Export_Records_Limit__c;
        dataGridAttribute.params = JSON.serialize(gridInputParams);
        Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
		dataGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
	}
    
    public PageReference findFor(){
    	try{
            system.debug('configSettingMap::'+configSettings.configSettingMap);
            configSettings.flowName = 'IB Export';
            exportFileName = '';
    		if(reportList == null || reportList.isEmpty()) {
    			reportList = Ren_ReportAndFolderDataAccess.getCannedReports((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c'), 
            	 															new Set<String>{'IB Export'});	
    		}	 
    
    		//REN_QueryBuilderCompController queryBuilderObj = new REN_QueryBuilderCompController();
        	//queryBuilderObj.queryBuilder(queryBuilderInputWrapper);
        	
            REN_QueryBuilderCompController baseChildController = (REN_QueryBuilderCompController)this.getBaseChildController();
            responseStr = baseChildController.doSearch();
	        
        }catch(Exception excp){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CHL_GENERAL_ERROR + excp.getMessage());
			ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    public PageReference createIBExport(){
        String finalQuery = '';
        
        try{
        	REN_QueryBuilderCompController baseChildController = (REN_QueryBuilderCompController)this.getBaseChildController();
        	string reportFields = '';
            system.debug('configSettings.configSettingMap:::::::::::::::'+configSettings.configSettingMap);
            configSettings.configSettingObj = null;
            if(configSettings.configSettingMap.containsKey('Generate IB Export'))
        		configSettings.configSettingObj = configSettings.configSettingMap.get('Generate IB Export');
    		system.debug('configSettings.configSettingObj::::::::::::::::'+configSettings.configSettingObj);
        	if(configSettings.configSettingObj != null && !String.isEmpty((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Named_Credential__c'))
        		&& !String.isEmpty((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Named_Credential_URL_Extension__c'))){
                reportColumnList = Reports.ReportManager.describeReport(selReportId).getReportMetadata().getDetailColumns();
	        	
	            for(String str : reportColumnList){
	                reportFields += str.replace((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Invoking_Object__c') + '.', '') + ',';
	            }
	            reportFields = reportFields.replaceAll('__c', '');
                Integer fieldindex = reportFields.lastIndexOf(',');
	            if(fieldindex != -1) {
	                reportFields = reportFields.substring(0,fieldindex);
	            }
	            
	            String jsonFilterCriteria = REN_IBExportODataController.formODataQueryInJson(baseChildController.inputWrapper.columnFilterList,baseChildController.inputWrapper.filterLogic, false, '');
                
		        finalQuery = '{"filter":"' + jsonFilterCriteria +'","select":"' + reportFields +'",' + (String.isNotBlank(exportFileName) ? '"fileName":"' + exportFileName + '",' : '') + '"userId":"'+UserInfo.getUserId()+'"}';
		        System.debug('**finalQuery ' + finalQuery);
		        REN_RSIntegrationUtil.REN_RSIntegrationWrapper wrapper = new REN_RSIntegrationUtil.REN_RSIntegrationWrapper();
                wrapper.jsonData = finalQuery;
                wrapper.endPointToAppend = '';
                wrapper.action = 'POST';
                wrapper.namedCredential = (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Named_Credential__c');
            	wrapper.namedCredentialExtn = (String)configSettings.configSettingObj.get(baseNamespace + 'REN_Named_Credential_URL_Extension__c');
            	System.debug('**wrapper ' + wrapper);
                
                REN_RSIntegrationUtil callout = new REN_RSIntegrationUtil();
                HttpResponse resp = callout.postHttpRequest(wrapper);
                
                if(resp == null || resp.getStatusCode() != 200){
                	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_IBExport_Response_Error);
                    ApexPages.addMessage(myMsg);
                    return null;
                }else{
                	String successMsg = '';
                	responseStr = resp.getBody();
                	JSONParser parser = System.JSON.createParser(responseStr);
                    while(parser.nextToken() != null){
                        if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'value')){
                            parser.nextToken();
                            successMsg = parser.getText();
                        }                         
                    }  
                	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, successMsg);  
                	ApexPages.addMessage(myMsg);
                	return null;       
                } 
                
		    }else if(configSettings.configSettingObj == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, String.format(Label.REN_LBL_Config_Setting_Error, new List<String>{'Generate IB Export'}));
				ApexPages.addMessage(myMsg);
            }else if(String.isEmpty((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Named_Credential__c')) || 
                     String.isEmpty((String)configSettings.configSettingObj.get(baseNamespace + 'REN_Named_Credential_URL_Extension__c'))){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.REN_LBL_Named_Credential_Error);
				ApexPages.addMessage(myMsg);    
            }
        }
        catch(Exception excp){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.CHL_GENERAL_ERROR + excp.getMessage());
			ApexPages.addMessage(myMsg);
            return null;
        }
        return null;  
    }
    
    public PageReference refreshMessages() {
        if(String.isNotBlank(displayMsg)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, displayMsg));
        }
        return null;
    }

}