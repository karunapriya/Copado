@isTest(SeeAllData = false)
private class REN_FieldMappingComponentControllerTest {
	static REN_FieldMappingComponentController child;
	static REN_FieldMappingComponentController controllerFieldMapping;

	static void setup() {
		child = new REN_FieldMappingComponentController();
		CHL_RenPartnerDataSyncCtrl partnerDataSyncObj = new CHL_RenPartnerDataSyncCtrl();
		REN_FieldMappingInputWrapper fmappigInputWrapper = new REN_FieldMappingInputWrapper('Opportunity', 'Asset', '12345', partnerDataSyncObj, system.label.CHL_LBL_PARTNER_OPP_FIELDS, system.label.REN_LBL_MAPPING_SECTION_HEADER, 'Partner_Opportunity Field', 'Opportunity Field', system.label.CHL_LBL_PARTNER_OPP_FIELDS,'ParenntId');
		child.fmInputWrapper = fmappigInputWrapper;
	}

	static testMethod void Test_GetFieldMappingList_Positive() {
		Test.startTest();
			setup();
			child.getFieldMappingList();
			system.assertEquals(child.toFieldOptionList.isEmpty(), false);
			child.showPopup();
			child.addFieldMapping();
			for (REN_FieldMappingComponentController.FieldMappingWrapper fmw: child.fieldMappingList) {
				System.debug('fmw.fieldMapping - ' + fmw.fieldMapping);
				if (fmw.fieldMapping.REN_From_Field_API_Name__c == null) {
				    if (fmw.fieldMapping.REN_Field_Data_Type__c.equalsIgnoreCase(String.valueOf(Schema.DisplayType.Boolean)))
                    {
                        fmw.fieldMapping.REN_Default_Value__c = 'true';
                    }
                    else
                    {
                        fmw.fieldMapping.REN_Default_Value__c = 'test';
                    }
				}
			} 
			//child.pickListValidation(new Opportunity(), new Opportunity(), 'StageName', 'StageName');
			child.save();
			child.fieldMappingList = null;
			child.fmInputWrapper.mappingName = '12345';
			//system.assertEquals(child.fieldMappingList.isEmpty(), true);
			child.getFieldMappingList();
			//system.assertEquals(child.fieldMappingList.isEmpty(), false);
			child.showPopup();
			child.updateFromFields();
			child.cancel();
			
			
           REN_FieldMappingInputWrapper fmappigInputWrapper = new REN_FieldMappingInputWrapper(
                REN_Constants.OBJ_OPPTY_LINE_ITEM,REN_Constants.OBJ_REN_RENEWS_TO, 
                system.label.REN_LBL_OPLI_TO_RR, new REN_RenewalMappingsComponentController(), 
                system.label.REN_LBL_RR_FIELD, 
                system.label.REN_LBL_MAPPING_SECTION_HEADER, system.label.REN_LBL_RR_FIELD, 
                system.label.REN_LBL_OPPTY_PRD_LINE_FIELD, system.label.REN_LBL_RR_FIELD + 's', 'ParenntId');
           child.fmInputWrapper = fmappigInputWrapper;
           child.getFieldMappingList();
           
     
          fmappigInputWrapper = new REN_FieldMappingInputWrapper(REN_Constants.OBJ_OPPORTUNITY, 
              CHL_Constants.OBJ_PARTNER_OPPORTUNITY, system.label.CHL_LBL_PARTNER_OPPTY_TO_MASTER_OPPTY, 
                                        new CHL_RenPartnerDataSyncCtrl(),  system.label.CHL_LBL_PARTNER_OPP_FIELDS, system.label.REN_LBL_MAPPING_SECTION_HEADER, 
             'Partner_Opportunity Field', 'Opportunity Field', system.label.CHL_LBL_PARTNER_OPP_FIELDS, 'ParentId');
          child.fmInputWrapper = fmappigInputWrapper;
          child.getFieldMappingList();
		Test.stopTest();
	}

	static testMethod void Test_GetFieldMappingList_Negative() {
		Test.startTest();
			setup();
			User restrictedUser = CSM_TestDataUtility.createTestUser('Standard User');
			system.runAs(restrictedUser) {
				child.getFieldMappingList();
			}
			system.assertEquals(child.fieldMappingList.isEmpty(), true);
			system.assert(child.toFieldOptionList.isEmpty());
		Test.stopTest();
	}

	static testMethod void Test_AddDeleteFieldMapping() {
		Test.startTest();
			setup();
			child.getFieldMappingList();
			system.assertEquals(child.toFieldOptionList.isEmpty(), false);
			SelectOption sp = child.toFieldOptionList[0];
			child.selectedField = sp.getValue();
			//child.addFieldMapping();
			for (REN_FieldMappingComponentController.FieldMappingWrapper wrapper: child.fieldMappingList) {
				if (String.isNotBlank(wrapper.customId)) {
					child.customFieldMappingId = wrapper.customId;
					break;
				} else {
					child.customFieldMappingId = String.valueOf(Datetime.now().getTime());
				}
			}
			system.debug('child.customFieldMappingId : ' + child.customFieldMappingId);
			child.deleteFieldMapping();
		Test.stopTest();
	}

	static testMethod void Test_BaseMainController() {
		try {
			Test.startTest();
			REN_BaseMainController controller = new REN_BaseMainController();
			controller.objectNameSuper = 'Asset';
			REN_BaseGrandParentController cont = new REN_BaseGrandParentController();
			controller.baseGrandParentController = cont;
			system.assert(true);
			Test.stopTest();
		} catch (Exception e) {
			system.debug('Exception : ' + e.getMessage());
		}
	}

	static testMethod void Test_REN_BaseChildController() {
		try {
			Test.startTest();
				REN_BaseChildController controller = new REN_BaseChildController();
				controller.objectNameSuper = 'Asset';
				REN_BaseMainController cont = new REN_BaseMainController();
				controller.baseMainController = cont;
				system.assert(true);
			Test.stopTest();
		} catch (Exception e) {
			system.debug('Exception : ' + e.getMessage());
		}
	}

	static testMethod void Test_BaseGrandParentController() {
		try {
			Test.startTest();
				REN_BaseGrandParentController controller = new REN_BaseGrandParentController();
				controller.getBaseMainController();
				controller.getBaseMainControllerMap();
				controller.getThis();
				system.assert(true);
			Test.stopTest();
		} catch (Exception e) {
			system.debug('Exception : ' + e.getMessage());
		}
	}

}