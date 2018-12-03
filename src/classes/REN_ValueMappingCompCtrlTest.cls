@isTest
private class REN_ValueMappingCompCtrlTest {
	static REN_ValueMappingCompCtrl child;
	static REN_Value_Mapping__c obj;
	static List<SelectOption> optionList;

	static void setup() {
		child = new REN_ValueMappingCompCtrl();
		REN_ValueMappingCtrl parentObj = new REN_ValueMappingCtrl();
		REN_FieldMappingInputWrapper vMappigInputWrapper = new REN_FieldMappingInputWrapper('', '', system.label.REN_RENEWAL_STAT_VAL_MAP, parentObj, '', '', '', '', '', '');
		child.fmInputWrapper = vMappigInputWrapper;
		optionList = new List<SelectOption>();
		optionList.add(new SelectOption('','Select One'));
		obj = new REN_Value_Mapping__c();
		obj.REN_Record_Key__c = REN_Constants.REN_RR_STATUS_MAP;
		obj.REN_Value__c = 'Open=Open,Lost=Lost,Won=Won';
		insert obj;
		system.assertNotEquals(obj,null);
	}
	
    static testMethod void ValueMappingCompCtrl_Positive() {
        Test.startTest();
        	setup();
        	child.objectName = CSM_Util.getNamespace() + 'REN_Renews_To__c';
        	child.objFieldName = CSM_Util.getNamespace() + 'REN_Renewal_Status__c';
        	child.getRenewalStatus();
        	PageReference pageRef = child.save();
        	system.assertEquals(pageRef,null);
        	child.selectOptions = optionList;
        	delete obj;
        	child.getRenewalStatus();
        Test.stopTest();
    }
    static testMethod void ValueMappingCompCtrl_Negative() {
    	User CSMUser = CSM_TestDataUtility.createTestUser('Standard User');
    	setup();
        Test.startTest();
	        system.runas(CSMUser){
	        	PageReference pageRef = child.save();
	        	system.assertEquals(pageRef,null);
	        }
        Test.stopTest();
    }
}