public with sharing class REN_EditClosedSaleOpptyCtrl {
 	private String oppId {get;set;}
    public String stageValid {get;set;}
    public Boolean permissionValid {get;set;}
    
    public REN_EditClosedSaleOpptyCtrl(){
    	String csmNamespace = CSM_Util.getNamespace();
        oppId = apexpages.currentpage().getparameters().get('id');
        stageValid = apexpages.currentpage().getparameters().get('stageValid');
        permissionValid = SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_Edit_Closed_Sale_Opportunities);
    }
    
    public PageReference redirect(){
        Id recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity - Edit').getRecordTypeId();
        return (new PageReference('/'+oppId+'/e?RecordType='+ recordtypeId +'&retURL=%2F'+oppId));
    }
    
    public PageReference back(){
        return new PageReference('/' + oppId);
    }
}