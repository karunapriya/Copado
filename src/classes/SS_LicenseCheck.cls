/**
* @author         Vishal Patel(vishal@comitydesigns.com)
* @date           07.21.2014
* @description    SS_LicenseCheck class checks if the user has license for appropriate feature  
*/
public with sharing class SS_LicenseCheck {
	
	private SS_LicenseCheck() {}
	private static SS_LicenseCheck singletonInstance;
	public static SS_LicenseCheck getInstance(){
		if(singletonInstance == null){
			singletonInstance = new SS_LicenseCheck();
		}
		return singletonInstance;
	}
	
	public Boolean isCSMEnabled {
		get {
			if(this.isCSMEnabled == null){
				this.isCSMEnabled = this.hasFeatureLicense(SS_Constants.SS_LICENSE_TYPE_CSM);
			}
			return this.isCSMEnabled;
		}
		private set;
	}
	
	public Boolean isRenewEnabled {
		get {
			if(this.isRenewEnabled == null){
				this.isRenewEnabled = this.hasFeatureLicense(SS_Constants.SS_LICENSE_TYPE_RENEW);
			}
			return this.isRenewEnabled;
		}
		private set;
	}
	
	public Boolean isChannelEnabled {
		get {
			if(this.isChannelEnabled == null){
				this.isChannelEnabled = this.hasFeatureLicense(SS_Constants.SS_LICENSE_TYPE_CHANNEL);
			}
			return this.isChannelEnabled;
		}
		private set;
	}
	
	public Set<String> assignedCustomPermissionSet {
		get {
			if(this.assignedCustomPermissionSet == null){
				this.assignedCustomPermissionSet = this.retrieveAssignedCustomPermissions();
			}
			return this.assignedCustomPermissionSet;
		}
		private set;
	}
	
	private Set<String> getAssignedCustomPermissionsByUser(String userId) {
		Set<String> assignedCustomPermissions = this.retrieveAssignedCustomPermissions(userId);
		return assignedCustomPermissions;
	}
	
	public Set<String> assignedPermissionSets {
		get {
			if(this.assignedPermissionSets == null){
				this.assignedPermissionSets = this.retieveAssignedPermissionSet();
			}
			return this.assignedPermissionSets;
		}
		private set;
	}
	
	public Boolean isCustomPermissionAssignedByUser(String permissionSetName, String userId) {
		Set<String> assignedCustomPermissions = this.getAssignedCustomPermissionsByUser(userId);
		return assignedCustomPermissions.contains(permissionSetName);
	}
	
	public Boolean isPermissionSetAssigned(String permissionSetName) {
		return this.assignedPermissionSets.contains(permissionSetName);
	}
	
	public Boolean isCustomPermissionAssigned(String customPermissionName) {
		return this.assignedCustomPermissionSet.contains(customPermissionName);
	}
	
	public Boolean isDynamicCustomPermissionAssigned(String customPermissionName) {
		Set<String> assignedDynamicCPSet = retrieveDynamicCustomPermissionsForCurrentUser(customPermissionName);
		return assignedDynamicCPSet != null && !assignedDynamicCPSet.isEmpty() ? assignedDynamicCPSet.contains(customPermissionName) : false;
	}
	
	private Boolean hasFeatureLicense(String feature) {
		Boolean hasLicense = false;
        SS_License__c ssLicenseSetting = this.getSSLicenseCustomSetting();
        if(SS_Constants.SS_LICENSE_TYPE_CSM.equals(feature)) {
        	hasLicense = ssLicenseSetting.CSM__c;
        } 
        else if (SS_Constants.SS_LICENSE_TYPE_RENEW.equals(feature)){
        	hasLicense = ssLicenseSetting.Renew__c;
        }
        else if (SS_Constants.SS_LICENSE_TYPE_CHANNEL.equals(feature)){
        	hasLicense = ssLicenseSetting.Channel__c;
        }
        return hasLicense;
	}
	
	private SS_License__c getSSLicenseCustomSetting() {
    	// Retrieve default enable application values from custom settings
    	SS_License__c ssLicenseSetting;
        SS_License__c ssLicenseUser = SS_License__c.getInstance(UserInfo.getUserId());
        if (ssLicenseUser != null) { 
            ssLicenseSetting =  ssLicenseUser;
        } 
        return ssLicenseSetting;
    }
    
    private Set<String> retrieveAssignedCustomPermissions(){
    	Set<String> assignedCPSet = retrieveAssignedCustomPermissions(UserInfo.getUserId());
    	return assignedCPSet;
    }
    
    /**
     * Needed to make this method public, as it is being required to call from BasePackageAccess class for SE.
     **/
    private Set<String> retrieveAssignedCustomPermissions(String userId){
    	Set<String> sExtCustomPermissionSetName = new Set<String>{SS_Constants.PS_DataServicesUser, 
    																SS_Constants.PS_CanCreateOpportunity, 
    																SS_Constants.PS_CanEditDelOpptLineItem, 
    																SS_Constants.PS_IntegrationUser, //TODO: This we might need to remove later based on clarification.
    																SS_Constants.PS_OperationServicesEditUser,
    																SS_Constants.PS_OperationServicesUser,
    																SS_Constants.PS_SalesManager,
    																SS_Constants.PS_SalesRep, 
    																SS_Constants.PS_SystemAdminUser,
    																SS_Constants.PS_CanEditCases,
    																SS_Constants.PS_REN_Playmaker,
    																SS_Constants.PS_LT_Self_Serve_Integrator,
    																SS_Constants.PS_ChannelCommunity,
    																SS_Constants.PS_ManageFocusCategory,
    																SS_Constants.PS_IBExportUser,
    																SS_Constants.PS_Mass_Transfer_Opportunities,
    																SS_Constants.PS_Edit_Closed_Sale_Opportunities
    																};
    	Set<String> assignedCPSet = new Set<String>();
    	List<CustomPermission> customPermissions = [SELECT Id, DeveloperName 
    														FROM CustomPermission 
    														WHERE DeveloperName IN : sExtCustomPermissionSetName];
    	if(customPermissions != null && !customPermissions.isEmpty()){
        	Map<id,CustomPermission> mapCustomPermission = new Map<id,CustomPermission>(customPermissions);
			List<SetupEntityAccess> setupEntities =[SELECT SetupEntityId FROM SetupEntityAccess 
													WHERE SetupEntityId in :mapCustomPermission.keySet() AND ParentId IN (SELECT PermissionSetId
             										FROM PermissionSetAssignment 
             										WHERE AssigneeId = :userId)];
             if(!setupEntities.isEmpty()){
             	for(SetupEntityAccess se: setupEntities){
           			if(mapCustomPermission.containsKey(se.SetupEntityId)) {
               			assignedCPSet.add(mapCustomPermission.get(se.SetupEntityId).DeveloperName);
           			}
           		}
        	}
		}
		return assignedCPSet;
	}
	
	private Set<String> retieveAssignedPermissionSet(){
		Set<String> setOfPS = new Set<String>();
		List<PermissionSetAssignment> lstOfCurrentAssignment = [SELECT PermissionSetId, PermissionSet.Name 
																FROM PermissionSetAssignment 
																WHERE AssigneeId =: UserInfo.getUserId()];
		for(PermissionSetAssignment PSAssignment: lstOfCurrentAssignment){
			setOfPS.add(PSAssignment.PermissionSet.Name);
		}
		return setOfPS;
	}
	
	private Set<String> retrieveDynamicCustomPermissionsForCurrentUser(String customPermission){
    	
    	Set<String> assignedCPSet = new Set<String>();
    	List<CustomPermission> customPermissions = [SELECT Id, DeveloperName 
    														FROM CustomPermission 
    														WHERE DeveloperName =: customPermission];
    	if(customPermissions != null && !customPermissions.isEmpty()){
        	Map<id,CustomPermission> mapCustomPermission = new Map<id,CustomPermission>(customPermissions);
			List<SetupEntityAccess> setupEntities =[SELECT SetupEntityId FROM SetupEntityAccess 
													WHERE SetupEntityId in :mapCustomPermission.keySet() AND ParentId IN (SELECT PermissionSetId
             										FROM PermissionSetAssignment 
             										WHERE AssigneeId = :UserInfo.getUserId())];
             if(!setupEntities.isEmpty()){
             	for(SetupEntityAccess se: setupEntities){
           			if(mapCustomPermission.containsKey(se.SetupEntityId)) {
               			assignedCPSet.add(mapCustomPermission.get(se.SetupEntityId).DeveloperName);
           			}
           		}
        	}
		}
		return assignedCPSet;
	}
}