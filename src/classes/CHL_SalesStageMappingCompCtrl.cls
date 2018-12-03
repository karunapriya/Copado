public with sharing class CHL_SalesStageMappingCompCtrl extends REN_BaseChildController {
	public List<CHL_SalesStageMappingInternalWrapper> wrapSalesStageMapList {get; set; }
	public List<CHL_Sales_Stage_Mapping__c> salesStageMappingList {get; set; }
	public List<CHL_Sales_Stage_Mapping__c> salesStageToDelete {get; set; }
	public String deleteRec {get; set; }
	public String leftPickListObjectName {get; set;}
	public String leftPickListObjFieldName {get; set; }
	public String typeObjectName {get; set; }
	public String typeObjFieldName {get; set; }
	public String rightPickListObjectName {get; set; }
	public String rightPickListObjFieldName {get; set; }
	public String lLabel {get; set; }
	public String rLabel {get; set; }
	public String typeLabel {get; set; }
	public List<SelectOption> leftPickListOptions {get; set; }
	public List<SelectOption> rightPickListOptions {get; set; }
	public List<SelectOption> typePickListOptions {get; set; }
	
	public CHL_SalesStageMappingCompCtrl() {
		populateData();
    }
    public void populateData() {
    	salesStageMappingList = CHL_SalesStageMappingDataAccess.getSalesStageMapping();
    	if(salesStageMappingList != null && !salesStageMappingList.isEmpty())
    	{
	    	wrapSalesStageMapList = new List<CHL_SalesStageMappingInternalWrapper>();
			for(CHL_Sales_Stage_Mapping__c salesStageMapRec : salesStageMappingList) {
				wrapSalesStageMapList.add(new CHL_SalesStageMappingInternalWrapper(salesStageMapRec.CHL_Master_Opportunity_Sales_Stage__c,
																					salesStageMapRec.CHL_Partner_Opportunity_Sales_Stage__c,
																					salesStageMapRec.CHL_Partner_Opportunity_Type__c,
																					salesStageMapRec.id));
			}
			this.salesStageToDelete = salesStageMappingList;
    	}
    }
    public CHL_SalesStageMappingWrapper salesStageMappingWrp {
		get;
		set {
			if(value != null){
				salesStageMappingWrp = value;
				this.objectNameSuper = salesStageMappingWrp.keyClassName;
				this.baseMainController = salesStageMappingWrp.baseMainController;
				lLabel = salesStageMappingWrp.leftSideLabel;
				rLabel = salesStageMappingWrp.rightSideLabel;
				typeLabel = salesStageMappingWrp.typeLabel;
				leftPickListObjectName = salesStageMappingWrp.leftPickListObjectName;
				leftPickListObjFieldName = salesStageMappingWrp.leftPickListObjFieldName;
				typeObjectName = salesStageMappingWrp.typeObjectName;
				typeObjFieldName = salesStageMappingWrp.typeObjFieldName;
				rightPickListObjectName = salesStageMappingWrp.rightPickListObjectName;
				rightPickListObjFieldName = salesStageMappingWrp.rightPickListObjFieldName;
				if(String.isNotBlank(leftPickListObjectName) && (String.isNotBlank(leftPickListObjFieldName))) {
					leftPickListOptions = setPickListValues(leftPickListObjectName, leftPickListObjFieldName);
				}
				if(String.isNotBlank(typeObjectName) && (String.isNotBlank(typeObjFieldName))) {
					typePickListOptions = setPickListValues(typeObjectName, typeObjFieldName);
				}
				if(String.isNotBlank(rightPickListObjectName) && (String.isNotBlank(rightPickListObjFieldName))) {
					rightPickListOptions = setPickListValues(rightPickListObjectName, rightPickListObjFieldName);
				}
	  		}
		}
	}
    public pageReference addSalesStageMappingRow() {
    	if(this.wrapSalesStageMapList == null) {
	    	this.wrapSalesStageMapList = new List<CHL_SalesStageMappingInternalWrapper>();
    	}  	
    	this.wrapSalesStageMapList.add(new CHL_SalesStageMappingInternalWrapper('','','',String.valueOf(wrapSalesStageMapList.size()+1)));
    	return null;
    }
    public class CHL_SalesStageMappingInternalWrapper {
    	public String leftPickList {get; set;}
        public String rightPickList {get; set;}
        public String typePickList {get;set;}
        public String identifier {get; set;}
 		public CHL_SalesStageMappingInternalWrapper(String leftSidePickList,String rightSidePickList, String typePickList, String identifier) {
            this.leftPickList = leftSidePickList;
            this.rightPickList = rightSidePickList;
            this.typePickList = typePickList;
            this.identifier = identifier;
        }
    }
    public List<SelectOption> setPickListValues(String objectName, String fieldName) {
   		List<SelectOption> options = new List<SelectOption>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
		Schema.DescribeSObjectResult objectResult = objType.getDescribe();
		Schema.DescribeFieldResult fieldResult = objectResult.fields.getMap().get(fieldName).getDescribe();
    	List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
    	CSM_Admin__c csmAdmin = CSM_Admin__c.getInstance();
		Set<String> stageNameSet = new Set<String>();
		if(csmAdmin.Inside_Sales_Stages__c != null && csmAdmin.Inside_Sales_Stages__c.contains(',')) {
            for(String str : csmAdmin.Inside_Sales_Stages__c.split(',')){
                stageNameSet.add(str.toUpperCase());
            }
        }
    	options.add(new SelectOption('', 'Select One'));
   		for(Schema.PicklistEntry value : pickListEntry) {
   			if((!stageNameSet.isEmpty() && !stageNameSet.contains(value.getLabel().toUpperCase())) || stageNameSet.isEmpty()){
   				options.add(new SelectOption(value.getLabel(), value.getValue()));
   			}
   		}
   		return options;
	}
	public void performSave(){
    	try{ 
    		salesStageMappingList = new List<CHL_Sales_Stage_Mapping__c>();
    		integer duplicateFlag;
    		integer allCnt;
    		integer loseWinCnt;
    		if(this.wrapSalesStageMapList != null && !this.wrapSalesStageMapList.isEmpty()) {
    			CHL_Sales_Stage_Mapping__c salesStageMappingRecord;
				for(CHL_SalesStageMappingInternalWrapper wrapper : this.wrapSalesStageMapList) {
					salesStageMappingRecord = new CHL_Sales_Stage_Mapping__c();
					if((String.isBlank(wrapper.leftPickList)) || (String.isBlank(wrapper.typePickList)) || (String.isBlank(wrapper.rightPickList))) {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CHL_SALES_STAGE_MAP_MSG_1));
						break;
					} else if((String.isNotBlank(wrapper.leftPickList)) && (String.isNotBlank(wrapper.typePickList))) {
						duplicateFlag=0;
						allCnt=0;
						loseWinCnt=0;
						for(CHL_SalesStageMappingInternalWrapper wrap : this.wrapSalesStageMapList) {
							system.debug((wrapper.leftPickList == wrap.leftPickList)+'----'+(wrapper.typePickList == wrap.typePickList));
							if((wrapper.leftPickList == wrap.leftPickList) && (wrapper.typePickList == wrap.typePickList)) {
								duplicateFlag++;
								if((String.isNotBlank(wrap.typePickList)) && (wrap.typePickList.contains('All Partner Opportunities'))) {
									allCnt++;
								} else {
									loseWinCnt++;
								}
								if(duplicateFlag > 1) {
									duplicateFlag = 0;  
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CHL_SALES_STAGE_MAP_MSG_2));
									break;
								}
							} else if(wrapper.leftPickList == wrap.leftPickList && (wrapper.typePickList != wrap.typePickList)) {
								if((String.isNotBlank(wrap.typePickList)) && (wrap.typePickList.contains('All Partner Opportunities'))) {
									allCnt++;
								} else {
									loseWinCnt++;
								}
								if(allCnt > 0 && loseWinCnt > 0) {
									allCnt = 0;
									loseWinCnt = 0;
									ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CHL_SALES_STAGE_MAP_MSG_2));
									break;
								}
							}
						}
						if((ApexPages.HasMessages(ApexPages.severity.ERROR))) {
							break;
						}
					}
					salesStageMappingRecord.CHL_Master_Opportunity_Sales_Stage__c = wrapper.leftPickList;
					salesStageMappingRecord.CHL_Partner_Opportunity_Type__c = wrapper.typePickList;
					salesStageMappingRecord.CHL_Partner_Opportunity_Sales_Stage__c = wrapper.rightPickList;
					salesStageMappingList.add(salesStageMappingRecord);
				}
				if(!(ApexPages.HasMessages(ApexPages.severity.ERROR))) {
					if(this.salesStageToDelete != null && !this.salesStageToDelete.isEmpty()) {
						CHL_SalesStageMappingDataAccess.deleteSalesStageMapping(this.salesStageToDelete);	
					}
					salesStageMappingList = CHL_SalesStageMappingDataAccess.saveSalesStageMapping(salesStageMappingList);
					if(salesStageMappingList != null && !salesStageMappingList.isEmpty()) {
						populateData();
					}	
				}
    		} else {
    			salesStageMappingList = CHL_SalesStageMappingDataAccess.getSalesStageMapping();
    			if(salesStageMappingList != null && !salesStageMappingList.isEmpty()) {
    				CHL_SalesStageMappingDataAccess.deleteSalesStageMapping(salesStageMappingList);	
    			}
    		}
    	} catch(exception ex) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
    	}
    }
    public PageReference removeFromList() {
    	if(String.isNotBlank(this.deleteRec)) {
	    	for(integer i=0;i<this.wrapSalesStageMapList.size();i++) {
	    		if(wrapSalesStageMapList[i].identifier.equals(this.deleteRec)) {
	    			this.wrapSalesStageMapList.remove(i);
	    			break;
	    		}
	    	}
    	}
    	return null;
    }
}