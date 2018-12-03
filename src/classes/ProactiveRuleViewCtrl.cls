public with sharing class ProactiveRuleViewCtrl {
    public Proactive_Rule__c thisProRule {get; set;}
    public List<Proactive_Rule_Line_Item__c> ProRuleLineItemList {get; set;}
    public List<Proactive_Case_Setup__c> ProCaseSetupList {get; set;}
    public List<SelectOption> OppFieldOptions = new List<SelectOption>();
    public List<SelectOption> CaseFieldOptions = new List<SelectOption>();
    public boolean ProRuleEdit {get; set;}
    public boolean ProRuleLineItemEdit {get; set;}
    public boolean ProCaseSetupEdit {get; set;}
    //Map<String, String> typeMap = new Map<String, String>();
    
    public ProactiveRuleViewCtrl(ApexPages.StandardController controller) {
        thisProRule = (Proactive_Rule__c)controller.getRecord();
        setOppFieldOptions();
        setCaseFieldOptions();
        initialize();
    }
    
    public void initialize() {
        getProRuleLineItemList();
        getProCaseSetupList();
        ProRuleEdit = false;
        ProRuleLineItemEdit = false;
        ProCaseSetupEdit = false;
    }
    
    public void setOppFieldOptions() {
        OppFieldOptions.add(new SelectOption('', '--None--'));
        Map<String, Schema.SObjectField> oppSchemaMap = Schema.SObjectType.Opportunity.fields.getMap();
        for(Schema.SObjectField sfield : oppSchemaMap.Values()){
        	if (sfield.getDescribe().isFilterable())
        	{
                OppFieldOptions.add(new SelectOption(sfield.getDescribe().getName(), sfield.getDescribe().getLabel()));
                //typeMap.put(String.valueOf(sfield.getDescribe().getName()), String.valueOf(sfield.getDescribe().getType()));
        	}
        }
    }
    public void setCaseFieldOptions() {
        CaseFieldOptions.add(new SelectOption('', '--'+Label.LBL_NONE+'--'));
        Map<String, Schema.SObjectField> caseSchemaMap = Schema.SObjectType.Case.fields.getMap();
        for(Schema.SObjectField sfield : caseSchemaMap.Values()){
            CaseFieldOptions.add(new SelectOption(sfield.getDescribe().getName(), sfield.getDescribe().getLabel()));
        }
    }
    
    public List<SelectOption> getOppFieldOptions() {
        return OppFieldOptions;
    }
    
    public List<SelectOption> getCaseFieldOptions() {
        return CaseFieldOptions;
    }
    
    public void getProRuleLineItemList() {
        ProRuleLineItemList = ProactiveDataAccess.getProactiveLineItemsByRule(new Set<Id>{thisProRule.Id});
    }
    
    public void getProCaseSetupList() {
        ProCaseSetupList = ProactiveDataAccess.getProactiveCaseSetupByRule(new Set<String>{thisProRule.Id});
    }
    
    public void addProRuleLineItem() {
        Proactive_Rule_Line_Item__c prl = new Proactive_Rule_Line_Item__c(Proactive_Rule__c = thisProRule.Id);
        ProRuleLineItemList.add(prl);
    }
    
    public void addProCaseSetup() {
        Proactive_Case_Setup__c pcs = new Proactive_Case_Setup__c(Proactive_Rule__c = thisProRule.Id);
        ProCaseSetupList.add(pcs);
    }
    
    public void onProRuleEdit() {
        ProRuleEdit = true;
    }
    
    public void offProRuleEdit() {
        ProRuleEdit = false;
    }
    
    public void onProRuleLineItemEdit() {
        ProRuleLineItemEdit = true;
    }
    
    public void offProRuleLineItemEdit() {
        ProRuleLineItemEdit = false;
    }
    
    public void onProCaseSetupEdit() {
        ProCaseSetupEdit = true;
    }
    
    public void offProCaseSetupEdit() {
        ProCaseSetupEdit = false;
    }
    
    public void cancelEdit() {
        initialize();
    }
    
    public PageReference SaveProRuleLineItem() {
        Map<Id, Proactive_Rule_Line_Item__c> ProRuleLineItemMap = new Map<Id, Proactive_Rule_Line_Item__c>(ProactiveDataAccess.getProactiveLineItemsByRule(new Set<Id>{thisProRule.Id}));
                                                                                    
        List<Proactive_Rule_Line_Item__c> prlToInsertList = new List<Proactive_Rule_Line_Item__c>();
        List<Proactive_Rule_Line_Item__c> prlToUpdateList = new List<Proactive_Rule_Line_Item__c>();
        List<Proactive_Rule_Line_Item__c> prlToDeleteList = new List<Proactive_Rule_Line_Item__c>();

        for (Proactive_Rule_Line_Item__c prl : ProRuleLineItemList) {
            if (prl.Id != null) {
                if(prl.Delete_Action__c == false){
                    if(prl.Field__c != ProRuleLineItemMap.get(prl.Id).Field__c ||
                        prl.Operator__c != ProRuleLineItemMap.get(prl.Id).Operator__c ||
                        prl.Value__c != ProRuleLineItemMap.get(prl.Id).Value__c) {
                        prlToUpdateList.add(prl);
                    }
                }
                else prlToDeleteList.add(prl);
            }
            else{
                if(prl.Delete_Action__c == false){
                    prlToInsertList.add(prl);
                }
            }
        }
        
        try {
            String namespace = Util.solnExtnNameSpace;
             List<String> proRuleItemsFieldList = new List<String>{
             	namespace +'Delete_Action__c', namespace +'Field__c', 
        	 	namespace +'Value__c',namespace +'Type__c',namespace +'Operator__c'};
        	 	
            if (prlToUpdateList.size() > 0)
            {
                ProactiveDataAccess.updateProactiveItems(prlToUpdateList, proRuleItemsFieldList);
            }
            if (prlToInsertList.size() > 0)
            {
            	ProactiveDataAccess.insertProactiveItems(prlToInsertList, proRuleItemsFieldList);
            }
            if (prlToDeleteList.size() > 0)
            {
            	ProactiveDataAccess.deleteProactiveItems(prlToDeleteList);
            }
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        offProRuleLineItemEdit();

        return new PageReference('/' + thisProRule.Id);
    }
    
    public PageReference SaveProCaseSetup() {
        Map<Id, Proactive_Case_Setup__c> ProCaseSetupMap = new Map<Id, Proactive_Case_Setup__c>(ProactiveDataAccess.getProactiveCaseSetupByRule(new Set<String>{thisProRule.Id}));
                                                                                    
        List<Proactive_Case_Setup__c> pcsToInsertList = new List<Proactive_Case_Setup__c>();
        List<Proactive_Case_Setup__c> pcsToUpdateList = new List<Proactive_Case_Setup__c>();
        List<Proactive_Case_Setup__c> pcsToDeleteList = new List<Proactive_Case_Setup__c>();

        for(Proactive_Case_Setup__c pcs : ProCaseSetupList) {
            if(pcs.Id != null) {
                if(pcs.Delete_Action__c == false) {
                    if(pcs.Field__c != ProCaseSetupMap.get(pcs.Id).Field__c ||
                        pcs.Value__c != ProCaseSetupMap.get(pcs.Id).Value__c) {
                        pcsToUpdateList.add(pcs);
                    }
                }
                else pcsToDeleteList.add(pcs);
            }
            else {
                if(pcs.Delete_Action__c == false) {
                    pcsToInsertList.add(pcs);
                }
            }
        }
        
        try {
        	String nameSpace = Util.solnExtnNameSpace;
            List<String> proCaseSetupFieldList = new List<String>{nameSpace +'Delete_Action__c', 
            	nameSpace +'Field__c',nameSpace +'Value__c'};
            if (pcsToUpdateList.size() > 0)
            {
                ProactiveDataAccess.updateProactiveCase(pcsToUpdateList, proCaseSetupFieldList);
            }
            if (pcsToInsertList.size() > 0)
            {
            	ProactiveDataAccess.insertProactiveCase(pcsToInsertList, proCaseSetupFieldList);
            }
            if (pcsToDeleteList.size() > 0)
            {
            	ProactiveDataAccess.deleteProactiveCase(pcsToDeleteList);
            }
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        offProCaseSetupEdit();

        return new PageReference('/' + thisProRule.Id);
    }
}