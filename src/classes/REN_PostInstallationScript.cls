global class REN_PostInstallationScript implements InstallHandler{
    
    global void onInstall(InstallContext context) {
        if (context.previousVersion() == null) {
            insertTriggerEnablement();
        }  
    }
    
    private void insertTriggerEnablement() {
        CSM_TriggerEnablement__c cTriggerEnablement  = CSM_TriggerEnablement__c.getOrgDefaults();
        cTriggerEnablement.REN_ServiceContractTrigger__c = true;
        cTriggerEnablement.CSM_ContractLineItemTrigger__c = true;
        upsert cTriggerEnablement;
    }
    
}