/**
 * Created Date		: Sep 30, 2016
 * Developed By		: Nkonkar, Comity Designs, Inc.
 *
 * Function			: @description - Custom Permission of Solution Extension.
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Nkonkar					User Story				Sep 30, 2016			1.1					@description
 *
 */
public with sharing class PermissionUtil {
	public static final String PS_CanCreateOpportunity = 'CanCreateOpportunity';
	public static final String PS_CanEditDelOpptLineItem = 'CanEditDelOpptLineItem';
	public static final String PS_DataServicesUser = 'DataServicesUser';
	public static final String PS_EnableSolExtnFeature = 'EnableSolExtnFeature';
	public static final String PS_IntegrationUser = 'IntegrationUser';
	public static final String PS_OperationServicesEditUser = 'OperationServicesEditUser';
	public static final String PS_OperationServicesUser = 'OperationServicesUser';
	public static final String PS_ReadOnlyUser = 'ReadOnlyUser';
	public static final String PS_SalesManager = 'SalesManager';
	public static final String PS_SalesRep = 'SalesRep';
	public static final String PS_SalesUser = 'SalesUser';
	public static final String PS_SolExtChannelUser = 'SolExtChannelUser';
	public static final String PS_SystemAdminUser = 'SystemAdminUser';
	public static final String PS_CanEditCases='CanEditCases';
	public static final String PS_Edit_Closed_Sale_Opportunities = 'Prism_Edit_Closed_Sale_Opportunities';
	public static final String nameSpace = Util.solnExtnNameSpace.removeEnd('__');
	private static Set<String> assignedCustomPermissions;

	public static Boolean isCustomPermissionAssigned(String customPermissionName){
		if(assignedCustomPermissions == null) {
			retrieveAssignedCustomPermissions();
		}
		Boolean isCustomPermissionAssigned = (assignedCustomPermissions == null || assignedCustomPermissions.isEmpty())
											?false
											:assignedCustomPermissions.contains(customPermissionName);
		return isCustomPermissionAssigned;
	}
	
	private static void retrieveAssignedCustomPermissions() {
		if(assignedCustomPermissions == null) {
			BasePackageParamsWrapper params = new BasePackageParamsWrapper();
	        params.className = 'SS_LicenseCheck';
	        params.methodName = 'retrieveAssignedCustomPermissions';
	        SS_BasePackageAccess.getInstance().paramJson = JSON.serialize(params);
	        String value = SS_BasePackageAccess.getInstance().invoke();
	        if(String.isNotBlank(value)){
	        	assignedCustomPermissions = (Set<String>)JSON.deserialize(value, Set<String>.class);
	        }
		}
	}
}