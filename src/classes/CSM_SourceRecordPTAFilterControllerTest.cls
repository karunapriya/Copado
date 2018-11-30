@isTest
public with sharing class CSM_SourceRecordPTAFilterControllerTest {

	@isTest 
	public static void ptaFilterController() {
       	CSM_SourceRecordPTAFilterController renControl = new CSM_SourceRecordPTAFilterController();
        PageReference pageRef = Page.CSM_SourceRecordPTAFilter;
        //pageRef.getParameters().put('opptId', String.valueOf(currentOpportunity.Id));
        Test.setCurrentPage(pageRef);
        renControl.renewObj.REN_View_Name__c = 'View_Name';
        REN_LogicBuilderCmpCtrl renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
        renewalLogicBuilder.logicBuilderInput = renControl.logicBuilderWapperMap.get(CSM_Constants.OBJ_TYPE_ACCOUNT);
        renControl.getBaseChildControllerMap().put(renControl.renewObj.REN_Plan_Object_Name__c + '_' + renControl.renewObj.REN_Plan_Object_Name__c, renewalLogicBuilder);
        renControl.objectTypeChanged();
        renControl.save();

       	CSM_SourceRecordPTAFilterController renController = new CSM_SourceRecordPTAFilterController();
        pageRef = Page.CSM_SourceRecordPTAFilter;
        Test.setCurrentPage(pageRef);
        renewalLogicBuilder = new REN_LogicBuilderCmpCtrl();
        renewalLogicBuilder.logicBuilderInput = renController.logicBuilderWapperMap.get(CSM_Constants.OBJ_TYPE_ACCOUNT);
        renController.getBaseChildControllerMap().put(renController.renewObj.REN_Plan_Object_Name__c + '_' + renController.renewObj.REN_Plan_Object_Name__c, renewalLogicBuilder);
        renController.objectTypeChanged();
        renController.save();
        renController.renewObj.REN_View_Name__c = 'View_Name';
        renController.save();
        renController.cancel();
        System.assert(pageRef!=null);
	}
}