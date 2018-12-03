/**
 * @author       Michelle Lairson (michelle@comitydesigns.com)    
 * @date         07/29/2016
 * @description  Entitlement Data Access class
 */
public with sharing class EntitlementDataAccess
{
	/**
    * @description : This method returns a list of entitlement records for the given set of account ids
    * @param a set of account ids
    * @return a list of entitlement records
    */
	public static List<Entitlement> getEntitlementListByAccount(Set<String> accountSet) 
    {
    	Util.checkCRUD_FLS('Entitlement', new List<String> {'AccountId'}, Constants.DML_OPERATION_READ);
	    return [SELECT Id, AccountId FROM Entitlement WHERE AccountId IN :accountSet LIMIT 9999];
    }
    
	public static void insertEntitlementList(List<Entitlement> entitlementList) 
    {
    	Util.checkCRUD_FLS('Entitlement', new List<String>{'AccountId','StartDate','SlaProcessId',
    		'Name'}, Constants.DML_OPERATION_INSERT);
	    insert entitlementList;
    }
    
    /**
    * @description : This method returns a list of SlaProcess records
    * @param boolean is active
    * @param booealn version default
    * @return a list of SlaProcess records
    */
    public static List<SlaProcess> getSlaProcesses(Boolean IsActive, Boolean isVersionDefault){
    	List<String> slaProcessFieldList = new List<String> {'IsActive','IsVersionDefault'};
    	Util.checkCRUD_FLS('SlaProcess', slaProcessFieldList, Constants.DML_OPERATION_READ);
    	return [SELECT Id, IsActive, IsVersionDefault, Name FROM SlaProcess 
                           WHERE IsActive = :IsActive AND IsVersionDefault = :isVersionDefault LIMIT 1];
    }
    
}