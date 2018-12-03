/**
 * Created Date     : Jan 11, 2017
 * Developed By     : Sheetal, Comity Designs, Inc.
 *
 * Function         : This class is to fetch records from cstom settings. Created for US1981 where we need to display records in grid.
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Sheetal                  US1981                  Jan 11, 2017    1.1                 Added class in sprint 701
 *
 */
public with sharing class REN_LowTouchAdminDataAccess {
     public static List<REN_Low_Dollar_Client__c> getLowTouchAdminRecords(){
        return REN_LowTouchClientDataAccess.getLowTouchRecords();                 
    }
    public static REN_Low_Dollar_Client__c getLowTouchAdminRecordsById(String recordId){
        return REN_LowTouchClientDataAccess.getLowTouchRecordsById(recordId);                 
    }
    
	/*public static List<REN_OpportunityWrapper> getOpportunityDetails(List<String> oppIds,Map<String,String> mapOfTranslatedLabels){
        List<REN_OpportunityWrapper> oppWrapperList=new List<REN_OpportunityWrapper>();       
        try{
            List<Opportunity> records=new List<Opportunity>();        
            if(oppIds!=null){ 
                String oppIdList= '' ;
                for(String oppId: oppIds){
                    oppIdList+= '\'' + oppId+ '\',';
                }                       
                oppIdList= oppIdList.lastIndexOf(',') > 0 ? '(' + oppIdList.substring(0,oppIdList.lastIndexOf(',')) + ')' : oppIdList;
                String filterStr = ' Id IN'+oppIdList;                       
                List<Schema.FieldSetMember> fieldSetMemberList =  SObjectType.Opportunity.FieldSets.REN_Low_Touch_Renewal_Information.getFields();
                Set<String> additionalFields=new set<String>();
                Map<String,String[]> fieldTypeMap=new Map<String,String[]>();            
                system.debug('' +fieldSetMemberList);
                  
                records = REN_OpportunityDataAccess.getDataUsingFieldWithoutFormat(fieldSetMemberList, additionalFields, filterStr, 100); 
                if(records != null && !records.isEmpty()){
                    
                    oppWrapperList = getOppDetailByCurrencyFilter(fieldSetMemberList,records,mapOfTranslatedLabels);
                    
                }  
            }
        }catch(Exception ex){
            system.debug(ex.getStackTraceString());
        }
        return oppWrapperList;
    }
    
    
    /*private static List<REN_OpportunityWrapper> getOppDetailByCurrencyFilter(List<Schema.FieldSetMember> fieldSetMemberList,List<Opportunity> records,Map<String,String> mapOfTranslatedLabels){
        List<REN_OpportunityWrapper> oppWrapperList = new List<REN_OpportunityWrapper>();
        //Map<String,String> mapOfTranslatedLabels = new Map<String,String>();	
        Map<String, String> localeMap = CSM_Util.getLocaleDateMap();
        String quotePDFURL = REN_HandleOpportunityStageUpdate.getQuotePDFContent(records[0].Id);
        String BaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String nameSpacePrefix = CSM_Util.getNamespace();
        REN_OpportunityWrapper oppWrapperObj;
        for(Schema.FieldSetMember fieldMember:fieldSetMemberList)	{
            oppWrapperObj = new REN_OpportunityWrapper();
            oppWrapperObj.fieldName = fieldMember.getFieldPath();
            system.debug(fieldMember.getFieldPath());
            if(fieldMember.getFieldPath().contains('.')){
                String[] splitStr = fieldMember.getFieldPath().split('\\.');
                oppWrapperObj.fieldValue = (String)records[0].getSObject(splitStr[0]).get(splitStr[1]);
            }else{
                if(records[0].get(fieldMember.getFieldPath())!=null){
                    if(fieldMember.getType().equals(Schema.DisplayType.CURRENCY)){
                        
                    	oppWrapperObj.type = 'Currency';                        
                        oppWrapperObj.fieldValue = ''+((Decimal)records[0].get(fieldMember.getFieldPath())).setScale(2);
                        if(UserInfo.isMultiCurrencyOrganization()){                        
                            oppWrapperObj.fieldValue = String.valueOf(records[0].get('CurrencyIsoCode'))+' '+oppWrapperObj.fieldValue;
                        }else{
                            oppWrapperObj.fieldValue = UserInfo.getDefaultCurrency()+' '+oppWrapperObj.fieldValue;
                        }
                        
                    }else if(fieldMember.getType().equals(Schema.DisplayType.DATE)) {
                        oppWrapperObj.type = 'Date';
                        Date dt = Date.parse(String.valueOf(records[0].get(fieldMember.getFieldPath())));
                        oppWrapperObj.fieldValue = dt.year()+'/'+dt.month()+'/'+dt.day();
                   
                    }else if(fieldMember.getType().equals(Schema.DisplayType.DATETIME)){
                        oppWrapperObj.type = 'DateTime';
                        DateTime dt = DateTime.parse(String.valueOf(records[0].get(fieldMember.getFieldPath())));
                        oppWrapperObj.fieldValue = dt.format('yyyy/MM/dd HH:mm:ss');
                    }else if(fieldMember.getType().equals(Schema.DisplayType.INTEGER)|| fieldMember.getType().equals(Schema.DisplayType.DOUBLE)){
                        oppWrapperObj.type = ''+fieldMember.getType();
                        oppWrapperObj.fieldValue = String.valueOf(records[0].get(fieldMember.getFieldPath()));
                    }else
                    {
                        oppWrapperObj.fieldValue = String.valueOf(records[0].get(fieldMember.getFieldPath()));
                    }
                }
                
            }
            //mapOfTranslatedLabels = getTranslatedStringForLabel(fieldMember.getLabel(),lang_param);
            oppWrapperObj.fieldLabel = mapOfTranslatedLabels != null && mapOfTranslatedLabels.containsKey(fieldMember.getFieldPath()) ? mapOfTranslatedLabels.get(fieldMember.getFieldPath()) : fieldMember.getLabel(); //de_text;//
            oppWrapperObj.BaseURL = BaseURL;
	        oppWrapperObj.SSNameSpace = nameSpacePrefix;
	        oppWrapperObj.QuotePDF = quotePDFURL;
	        oppWrapperList.add(oppWrapperObj);
        }
        
     return oppWrapperList;
    }*/
    
    
    /*public static REN_ToggleLowTouchConfiguration getLowTouchConfig(){
        List<REN_Low_Dollar_Client__c> listLowTouchClient= REN_LowTouchClientDataAccess.getLowDollarClientDetails();
        
        REN_Low_Dollar_Client__c lowTouchConfig = null;
        if(listLowTouchClient!=null && !listLowTouchClient.isEmpty()){
           lowTouchConfig  = listLowTouchClient.get(0);
        }
        REN_ToggleLowTouchConfiguration lwTouchConfig = new REN_ToggleLowTouchConfiguration();
        if(lowTouchConfig != null){
            lwTouchConfig.isDocuSignActive= lowTouchConfig.REN_Docusign__c?true:false;
        
            lwTouchConfig.isLiveChatActive = lowTouchConfig.REN_Live_Agent__c?true:false;
        
            lwTouchConfig.isFileUploadActive = lowTouchConfig.REN_PO_Upload__c?true:false;             
        }
        return lwTouchConfig;
    }*/
}