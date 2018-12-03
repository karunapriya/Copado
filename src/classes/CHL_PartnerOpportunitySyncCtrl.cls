/**
 * Created Date     : Feb 7, 2017
 * Developed By     : admin, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * admin                    User Story              Feb 7, 2017         1.1                 @description
 *
 */
public with sharing class CHL_PartnerOpportunitySyncCtrl{

    public String opptyId {get;set;}
    public string namespace{get;set;}
    public string syncingVaule{get;set;}
    public String channelNoAccessMsg {get; private set;}
    public string partnerOptyId{get;set;}
    public List<CHL_Partner_Opportunity__c> partnerOptyList;
    public CSM_DataGridAttribute PartnerOpportunityGridAttribute{get; set; }
     public boolean showPopup {get;set;}
    public Boolean hasChannelAccess {
        get;
        private set;
    }
   
     public CHL_PartnerOpportunitySyncCtrl(ApexPages.StandardSetController standardSetController){     
        try{
            //SS_LicenseCheck.getUserType();
            opptyId = ApexPages.currentPage().getParameters().get('Id');
            namespace=CSM_Util.getNamespace();
            setGridAttributes();
            Syncing();
            showPopup=false;
        }
        catch(Exception e){
            system.debug('Error : ' + e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CHL_GENERAL_ERROR + e.getMessage()));
        }
    }
    
    private void setGridAttributes()
    {                                
        PartnerOpportunityGridAttribute = new CSM_DataGridAttribute();        
        PartnerOpportunityGridAttribute.tableName = 'PartnerOpportunity';//'PARTNER_OPPORTUNITY';
        PartnerOpportunityGridAttribute.objectType ='PARTNER_OPPORTUNITY';
        PartnerOpportunityGridAttribute.viewName ='PartnerOpportunity';
        PartnerOpportunityGridAttribute.clickDataToSelect=CSM_Constants.GRID_ATTR_FALSE;
        PartnerOpportunityGridAttribute.gridToolBarId=CSM_Constants.GRID_ATTR_TOOLBAR;
        PartnerOpportunityGridAttribute.hasSearch=CSM_Constants.GRID_ATTR_TRUE;
        PartnerOpportunityGridAttribute.hasShowColumns=CSM_Constants.GRID_ATTR_TRUE;
        PartnerOpportunityGridAttribute.showGlobalSelect=CSM_Constants.GRID_ATTR_TRUE; 
        PartnerOpportunityGridAttribute.showExport=CSM_Constants.GRID_ATTR_TRUE;
        
        CSM_CustomGridInputWrapper.CSM_CustomGridParams gridInputParams = new CSM_CustomGridInputWrapper.CSM_CustomGridParams();  
        gridInputParams.opptyId = opptyId;
        PartnerOpportunityGridAttribute.params = JSON.serialize(gridInputParams);
        Map<String, String> localeMap = CSM_Util.getLocaleDateTimeMap();
        PartnerOpportunityGridAttribute.userDateFormat =localeMap.get(userInfo.getLocale());
    }
    
    public PageReference cancel(){
        PageReference retPage = new PageReference('/' + opptyId);
        retPage.setRedirect(true);
        return retPage;
    }
       
   public void Syncing() {     
        channelNoAccessMsg = SS_Constants.SS_NO_LICENSE_MSG;  
        hasChannelAccess = SS_LicenseCheck.getInstance().isChannelEnabled;      
        Set<ID> poOptyIds = new set<ID>();
        poOptyIds.add(partnerOptyId);
        partnerOptyList = CHL_PartnerOpportunityDataAccess.getPartnerOpportunityDataById(poOptyIds);
        if(partnerOptyList != null && !partnerOptyList.isEmpty()) {
          OpptyId = partnerOptyList[0].CHL_Opportunity__c;
        }
   }
   
   public PageReference Save() {
     try {
         syncing();
       List<sObject> listToUpdate = new List<sObject>();
         system.debug('partnerOptyList--'+partnerOptyList);
       if(partnerOptyList != null && !partnerOptyList.isEmpty()) {
       	 if(this.syncingVaule.equalsIgnoreCase(CSM_Constants.STR_NONE)) {
       	 	this.syncingVaule = ' ';
       	 }
       	 
         partnerOptyList[0].CHL_Syncing__c = this.syncingVaule; 
         listToUpdate.add(partnerOptyList[0]);
         CHL_PartnerOpportunityDataAccess.updatePartnerOpportunity(listToUpdate);
       }       
     }
      catch(Exception ex){
        system.debug('IN D ERROR : ');
      ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));     
    }
        PageReference retPage = new PageReference('/' + opptyId);
        retPage.setRedirect(true);
        return retPage;
   }
     public void getPOId()
    {
        //showPopup = true;
        partnerOptyId=Apexpages.currentPage().getParameters().get('POId'); 
        //return null;
    }    
    public void Close()
    {
        showPopup = false;
        //return null;
    }
}