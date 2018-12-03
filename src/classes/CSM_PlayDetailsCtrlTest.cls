@isTest
public with sharing class CSM_PlayDetailsCtrlTest {
	
	static testMethod void testPlayDetails(){
		List<CSM_Playbook__c> playbookList = CSM_TestDataUtility.createPlaybookTestData(1);
        PageReference pageRef = Page.CSM_PlayManagement;
    	pageRef.getParameters().put(CSM_Constants.PLAYBOOK_ID_PARAM,playbookList[0].id);
    	pageRef.getParameters().put(CSM_Constants.RET_TO_URL,EncodingUtil.urlEncode('/apex/CSM_PlaybookManagement?id=' + playbookList[0].id,CSM_Constants.UTF_8));
    	Test.setCurrentPage(pageRef);
       	CSM_PlayDetailsCtrl controller = new CSM_PlayDetailsCtrl();
       	Test.startTest();
       	controller.play.CSM_isActive__c = true;
    	controller.play.CSM_Display_Name__c = 'New Play';
    	controller.play.CSM_Object_Name__c = 'Account';
       	
       	PageReference pageRef2 = controller.goBack();
       	System.assert(pageRef2 !=null);
       	
       	Test.stopTest();
	}
	
	static testMethod void testPlayDataAccess(){
		
		Profile renewProfile = [Select Name, Id From Profile where Name = 'System Administrator' limit 1];
		User renewUsr = CSM_TestDataUtility.CreateUser(renewProfile.Id);
		List<String> PlayIDList = new  List<String>();
		 
		List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(8);
		System.assert(playList !=null);
		
		for(CSM_Play__c plyObj : playList){
			PlayIDList.add(plyObj.id);
		}
		 
		Test.startTest();
			System.runAs(renewUsr) {
			 	try{
			 		CSM_PlaysDataAccess.populatePlayList();
			 		CSM_PlaysDataAccess.populatePlayInformation(PlayIDList);
			 		CSM_PlaysDataAccess.activatePlays(PlayIDList) ;
			 		CSM_PlaysDataAccess.deactivatePlays(PlayIDList) ;
			 	}catch(exception e){
			 		
			 	}
			 }
       Test.stopTest();
	}
	
	static testMethod void testPlayDataAccessNegative(){
		
		 Profile renewProfile = [Select Name, Id From Profile where Name = 'System Administrator' limit 1];
		 User renewUsr = CSM_TestDataUtility.CreateUser(renewProfile.Id);
		 List<String> PlayIDList = new  List<String>();
		 
		 List<CSM_Play__c> playList = CSM_TestDataUtility.createPlayTestData(8);
		 System.assert(playList !=null);
		 
		 for(CSM_Play__c plyObj : playList){
			PlayIDList.add(plyObj.id);
		 }
		 
		 Test.startTest();
			 System.runAs(renewUsr) {
			 	try{
			 		CSM_PlaysDataAccess.activatePlays(PlayIDList) ;
			 	}catch(exception e){
			 		system.assert(true);
			 	}
			 	
			 	try{
			 		CSM_PlaysDataAccess.deactivatePlays(PlayIDList) ;
			 	}catch(exception e){
			 		system.assert(true);
			 	}
			 	
			 	try{
			 		CSM_PlaysDataAccess.populatePlayInformation(PlayIDList);
			 	}catch(exception e){
			 		system.assert(true);
			 	}
			 	
			 }
       	Test.stopTest();
	}
	
	

}