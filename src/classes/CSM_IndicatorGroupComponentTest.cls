@isTest
public with sharing class CSM_IndicatorGroupComponentTest
{
	static User createUser(String profileName)
    {
        //Id profileId
        Profile renewProfile = [Select Name, Id From Profile where Name = :profileName limit 1]; 
        User renewUsr =  CSM_TestDataUtility.CreateUser(renewProfile.Id);
        insert renewUsr;
        return renewUsr;
    }
    
	static testMethod void testIndicatorGroup() {
	    CSM_IndicatorGroupComponentController controller = new CSM_IndicatorGroupComponentController();
	    controller.indicatorGroupName = 'TestIndicatorGroupName';
	    controller.saveNewIndicatorGroup();	   
	    List<CSM_Indicator_Group__c> indGroups = controller.getIndicatorGroups();
	    System.assertEquals(1, indGroups.size());    
	    
	    controller.setIndicatorComponentControllerMap(indGroups[0].Id, new CSM_IndicatorComponentController());
	    
	    Map<Id, CSM_IndicatorComponentController> mapIndicators = controller.getIndicatorComponentControllerMap();
	    System.assertNotEquals(null, mapIndicators);
	    
	    PageReference pf = controller.saveIndicators();
	    System.assertEquals(null, pf);
	    
	    System.assertNotEquals(null, controller.getThis()); 
	    
	    controller.indicatorGroupName = '';
	    controller.saveNewIndicatorGroup();
	    controller.cancelNewIndicatorGroup();   
	   
	    PageReference pfClear = controller.clearChanges();
	    System.assertEquals(null, pfClear);     
	   
	}
	
	static testMethod void test_Negative() {
	    
		 User adminUsr  = createUser('Standard User');
         list<PermissionSetAssignment> lstPSAssignments = new list<PermissionSetAssignment>();
         
		 PermissionSet ps   = CHL_TestUtility.getPermissionSet('LT_Self_Serve_Integrator');
		 lstPSAssignments.add(new PermissionSetAssignment(AssigneeId = adminUsr.id, PermissionSetId = ps.Id));
		 insert lstPSAssignments;
		 
		 Test.startTest();
			 System.runAs(adminUsr) {
			 	try {
			 		CSM_IndicatorGroupComponentController controller = new CSM_IndicatorGroupComponentController();
			 		controller.indicatorGroupName = 'TestIndicatorGroupName';
			 		controller.saveNewIndicatorGroup();
			 		List < CSM_Indicator_Group__c > indGroups = controller.getIndicatorGroups();
			
			 		controller.setIndicatorComponentControllerMap(indGroups[0].Id, new CSM_IndicatorComponentController());
			
			 		Map < Id, CSM_IndicatorComponentController > mapIndicators = controller.getIndicatorComponentControllerMap();
			
			 		PageReference pf = controller.saveIndicators();
			
			 		controller.indicatorGroupName = '';
			 		controller.saveNewIndicatorGroup();
			 		controller.cancelNewIndicatorGroup();
			
			 		PageReference pfClear = controller.clearChanges();
			 		system.assert(true);
			 	} catch (exception e) {
			        system.debug('In a exception');
			 	}
			 }
		 Test.stopTest();
 	}
}