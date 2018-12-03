public with sharing class EntitlementUtils {

    public static void EntitlementCreation(List<Account> accList){
        List<Entitlement> entToInsetList = new List<Entitlement>();
        List<SlaProcess> slaProcess = EntitlementDataAccess.getSlaProcesses(true, true);
        if(!slaProcess.isEmpty()){
	        for(Account acc : accList){
	            Entitlement ent = new Entitlement(Name = 'Entitlement - ' + acc.Name,
	                AccountId = acc.Id,
	                StartDate = System.Today(),
	                SlaProcessId = slaProcess[0].Id);
	            entToInsetList.add(ent);
	        }
	        
	        if(entToInsetList.size() > 0) {
	        	EntitlementDataAccess.insertEntitlementList(entToInsetList);
	        }
	    }
    }
}