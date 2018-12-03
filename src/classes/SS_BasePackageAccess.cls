/**
 * Created Date		: Nov 10, 2016
 * Developed By		: Amit, Comity Designs, Inc.
 *
 * Function			: Global class to allow access between packages (CSM, Quote Extn, Entitlement Extn). Idea is to keep the core
 					  functionality logic in the base package. This class will work as interface for other packages, in case they want 
 					  to use the core functionality logic.
 * Support Email 	: servicesource@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Amit						US1686					Nov 10, 2016	1.0					Added the class in 2.13 major version.
 *
 */
global with sharing class SS_BasePackageAccess {

	private SS_BasePackageAccess() {}
	private static SS_BasePackageAccess singletonInstance;
	private InputParams params;
	
	// Json string parameter. This will be provided by the external class calling this class.
	// Based on the value of this variable, this class will call base class methods.
	global String paramJson;
	
	/**
	 * Creates the signleton instance of this class if not already exists.
	 * @return singleton instacne of this class.
	 **/
	global static SS_BasePackageAccess getInstance(){
		if(singletonInstance == null){
			singletonInstance = new SS_BasePackageAccess();
		}
		return singletonInstance;
	}
	
	/**
	 * Executes the base package functionality based on the information provided in the paramJson variable.
	 * It won't do anything if paramJson does not contain the relevant information.
	 * @return Json string containing the required information of the functionality.
	 **/
	global String invoke() {
		String value = '';
		if(String.isNotBlank(paramJson)){
			this.params = (InputParams)JSON.deserialize(paramJson, InputParams.class);
			if(String.isNotBlank(this.params.className) && String.isNotBlank(this.params.methodName)){
				if(this.params.className == 'SS_LicenseCheck'){
					if(this.params.methodName.equalsIgnoreCase('retrieveAssignedCustomPermissions')){
						value = JSON.serialize(SS_LicenseCheck.getInstance().assignedCustomPermissionSet);
					}
				} else{
					System.Type classNameType = System.Type.forName(this.params.className);
					Object objInstance = classNameType.newInstance();
					if(objInstance instanceof CHL_QuoteExtension){
						if(this.params.methodName.equalsIgnoreCase('markPrimaryQuote')){
							CHL_QuoteExtension.markPrimaryQuote(params.sObjIds);
						}else if(this.params.methodName.equalsIgnoreCase('createDistributorQuotesAndQlis')){
							CHL_QuoteExtension.createDistributorQuotesAndQlis(params.sObjIds);
						}else if(this.params.methodName.equalsIgnoreCase('syncQuoteFromOpportunity')){
							CHL_QuoteExtension.syncQuoteFromOpportunity(params.sObjIds);
						}
					}else if(objInstance instanceof REN_OpportunityLineItemRenewalHandler){
                        if(this.params.methodName.equalsIgnoreCase('oliAfterTriggerEvent')){
                            REN_OpportunityLineItemRenewalHandler.oliAfterTriggerEvent(params.sObjIds);
                        }
                    }else if(objInstance instanceof REN_FieldMappingsDataAccess){
                        if(this.params.methodName.equalsIgnoreCase('getFieldMappingListByConfig')){
                            value = JSON.serialize(REN_FieldMappingsDataAccess.getFieldMappingListByConfig(params.toObject,params.fromObject));
                        }
                    }
				}
			}
		}
		return value;
	}
	
	private class InputParams {
		private Set<Id> sObjIds;
		private String className;
		private String methodName;
		private String nameSpace;
		private String customPermissionName;
		private String triggerName;
		private String toObject;
		private String fromObject;
		
	}
}