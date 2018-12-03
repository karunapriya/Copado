public with sharing class CSM_ObjectFilterWidgetCompCtrl{
    
    public Boolean isFilterWidget {get; set;}
    public REN_Renew_Configuration__c renewConfig {get; set;}
    
    public String renConfigId {
        get; 
        set {
                renConfigId = value;
                getRenewConfig();
        }
    }
    
    
    public  CSM_ObjectFilterWidgetCompCtrl(){
        isFilterWidget =  false;
    }
    
    public REN_Renew_Configuration__c getRenewConfig(){
        if(String.isEmpty(renConfigId)){
            renewConfig = null;
        }else{
            renewConfig = REN_RenewConfigurationDataAccess.getRenewConfigByIdy(renConfigId);
        }
        return renewConfig;
    }
    
    
    public String getFilterCriteria(){
        REN_Renew_Configuration__c renewConfig = new REN_Renew_Configuration__c(); 
        if(String.isEmpty(renConfigId)){
            renewConfig = null;
            return null;
        }else{
	        renewConfig = REN_RenewConfigurationDataAccess.getPTAFilterCriteria(renConfigId);
        	return renewConfig.REN_Filter_Criteria__c;	         
        }

    }
    
	public String getViewName(){
		String recKey = null; 
		if(renewConfig != null && renewConfig.REN_View_Name__c != null){
			recKey = renewConfig.REN_View_Name__c;
		}
		return recKey;
	}    
    
    public String getRecordsReturned(){
        String recRet = null;
        String criteria;
        if(renewConfig != null && renewConfig.REN_Filter_Criteria__c != null){
            criteria = ' From ' + renewConfig.REN_Plan_Object_Name__c + ' where '+ renewConfig.REN_Filter_Criteria__c;
        }
        try{
            Integer recCount = REN_RenewConfigurationDataAccess.getPTAObjectFilterCount(criteria, 40001);
            if(recCount > 40000){
                recRet = ' > 40,000';
            }
            else{
                recRet = '' + recCount;
            }
        }
        catch(Exception e){
            recRet = '0';
        }
        return recRet;      
    }
    
}