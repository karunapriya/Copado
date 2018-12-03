public with sharing class REN_RenewalMappingsAdminController {

  public Boolean hasRenewAccess {get; private set;}
  public String helpParam {get; set;}
  public String tabCategory {get; set;}
  public Boolean isSolExtLTIntegrator{get;private set;} 
  public REN_RenewalMappingsAdminController() 
  {
      hasRenewAccess = SS_LicenseCheck.getInstance().isRenewEnabled;
      helpParam = CSM_Constants.HELP_MAPPINGS;      
      isSolExtLTIntegrator=SS_LicenseCheck.getInstance().isCustomPermissionAssigned(SS_Constants.PS_LT_Self_Serve_Integrator);
  }
}