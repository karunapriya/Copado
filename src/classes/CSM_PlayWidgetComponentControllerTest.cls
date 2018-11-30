@isTest
public with sharing class CSM_PlayWidgetComponentControllerTest {
	public static List<CSM_Playbook__c> playbooks;
	public static List<CSM_Play__c> plays;
	
	static testMethod void testPlayWidget(){
		setup();		
        Test.startTest();
       	
       	CSM_PlayWidgetComponentController controller = new CSM_PlayWidgetComponentController();
       	if(plays[0].Id != null){
       		controller.playId = plays[0].Id;
       	}
       	controller.taskViewId = '1231231';
        controller.successPlanId = '';
       	System.assert(controller.playDescription==null);
       	
       	PageReference pageRef = controller.detailPage();
       	System.assert(pageRef !=null);
       	
       	Test.stopTest();
	}

	static void setup(){
		playbooks = CSM_TestDataUtility.createPlaybookTestData(1);
		plays = CSM_TestDataUtility.createPlayTestData(1);	
	}
}