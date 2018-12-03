public with sharing class OperationsTargetExtension {
    
    public Operations_Target__c thisOperationsTarget {get; private set;}
    ApexPages.StandardController controller;
    
    public Boolean selectAll {get; set;}
    public Integer bulkTarget {get; set;}
    Map<Id, Operations_Target_Line_Item__c> generatedOpsTargetMap;
    public List<GenOpsTargetWrapper> genOpsTargetWrapperList {get;set;}
    
    public List<SelectOption> caseRecordTypeOptions {get;set;}
    public Map<String,Id> caseRecordTypeMap {get;set;}
    
    public List<SelectOption> updateOptions {get;set;}
    public String updateMode {get; set;}
    
    public Boolean editMode{get;set;}
    
    public OperationsTargetExtension(ApexPages.StandardController controller) {
        thisOperationsTarget = (Operations_Target__c)controller.getRecord();
        this.controller = controller;
        initializeRecordType();
        initializeView();        
    }
    
    
    private void initializeRecordType(){
        caseRecordTypeMap = getCaseRecordTypeMap();
        caseRecordTypeOptions = new List<SelectOption>();
        caseRecordTypeOptions.add(new SelectOption('', '--None--'));
        for(String s : caseRecordTypeMap.keySet()){
            caseRecordTypeOptions.add(new SelectOption(s, s));
        }
    }
    
    
    public void initializeView(){
        editMode = false;
        
        updateOptions = new List<SelectOption>();
        updateOptions.add(new SelectOption('Single','Single'));
        updateOptions.add(new SelectOption('Mass','Mass'));
        generatedOpsTargetMap = OperationsTargetDataAccess.getOperationLineItemMapByOperation(new Set<String>{thisOperationsTarget.Id});
        genOpsTargetWrapperList = new List<GenOpsTargetWrapper>();
        for (Operations_Target_Line_Item__c gen : OperationsTargetDataAccess.getOperationLineItemListByOperationTargetIds(new Set<String>{thisOperationsTarget.Id}))
        {
            GenOpsTargetWrapper gow = new GenOpsTargetWrapper();
            gow.selectGenOps = false;
            gow.genOps = gen;
            genOpsTargetWrapperList.add(gow);
        }
    }
    
    public pageReference saveChanges(){
        PageReference retUrl = controller.view();
        
        List<Operations_Target_Line_Item__c> genOpsTargetToUpdateList = new List<Operations_Target_Line_Item__c>();
        for(GenOpsTargetWrapper gow : genOpsTargetWrapperList){
            if(updateMode == 'Single'){
                if(gow.genOps.Target__c != generatedOpsTargetMap.get(gow.genOps.Id).Target__c){
                    genOpsTargetToUpdateList.add(gow.genOps);                    
                }
                
            }
            
            if(updateMode == 'Mass'){
                if(gow.selectGenOps == true){
                    gow.genOps.Target__c = bulkTarget;
                    genOpsTargetToUpdateList.add(gow.genOps);
                }
            }
        }
        
        try{
            //controller.save();
            if(genOpsTargetToUpdateList.size() > 0)
            {
                 OperationsTargetDataAccess.updateOperationsTargetLineItems(genOpsTargetToUpdateList,  new List<String>{Util.solnExtnNameSpace + 'Target__c'});     
            }
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        //System.debug('####DEBUG genOpsTargetToUpdateList.size(): ' + genOpsTargetToUpdateList.size());
        return retUrl;
    }
    
    public pageReference goToEditPage(){
        editMode = true;
        updateMode = 'Single';
        return null;
    }
    
    public Boolean getEditModeOrMass(){
        if(!editMode || updateMode == 'Mass')
            return true;
        else
            return false;
    }
    
    public Boolean getEditModeAndSingle(){
        if(editMode && updateMode == 'Single')
            return true;
        else
            return false;
    }
    
    public class GenOpsTargetWrapper{
        public Boolean selectGenOps {get;set;}
        public Operations_Target_Line_Item__c genOps {get;set;}
    }
    
    /****BEGIN METHODS CALLED BY OPS TARGET TRIGGER TO GENERATE OPS TARGET ITEMS****/
    
    public static Map<String,Id> getCaseRecordTypeMap(){
        Map<String,Id> caseRecordTypeMap = new Map<String,Id>();
        String objectName = 'Case';
        Schema.DescribeSObjectResult sObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sObjectResult.getRecordTypeInfos();
        
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            if(info.getName() == 'Master')
                continue;
            caseRecordTypeMap.put(info.getName(),info.getRecordTypeId());
        }
        return caseRecordTypeMap;
    }
    
    public static void generateOperationsTarget(List<Operations_Target__c> operationsTargetList){
        
        List<OpsTargetWrapper> opsTargetWrapperList = new List<OpsTargetWrapper>();
        List<Operations_Target_Line_Item__c> otToGenerateList = new List<Operations_Target_Line_Item__c>();
        
        opsTargetWrapperList = dateBreakDown(operationsTargetList);
        
        for(OpsTargetWrapper otw : opsTargetWrapperList){
            for(Date sDate : otw.startDateList){
                Operations_Target_Line_Item__c got = new Operations_Target_Line_Item__c(
                    Operations_Target__c = otw.opsTarget.Id,
                    Start_Date__c = sDate,
                    End_Date__c = otw.endDateMap.get(sDate));
                otToGenerateList.add(got);
            }
        }

        if(otToGenerateList.size() > 0){
        	String nameSpace = Util.solnExtnNameSpace;
            List<String> oliFieldList = new List<String>{ 
            	nameSpace+'Start_Date__c',nameSpace+'End_Date__c'};
            OperationsTargetDataAccess.insertOperationsTargetLineItems(otToGenerateList, oliFieldList);
        }
    }
    
    public static List<OpsTargetWrapper> dateBreakDown(List<Operations_Target__c> operationsTargetList){
        List<OpsTargetWrapper> opsTargetWrapperList = new List<OpsTargetWrapper>();
        List<Date> startDateList;
        Map<Date, Date> endDateMap;
        Set<String> periodIds = new Set<String>();
        
        for(Operations_Target__c ot : operationsTargetList){
            periodIds.add(ot.Period__c);
        }
        
        Map<Id, Period__c> periodMap = PeriodDataAccess.getPeriodRecordsById(periodIds);
        
        for(Operations_Target__c ot : operationsTargetList){
            OpsTargetWrapper otwItem = new OpsTargetWrapper();
            startDateList = new List<Date>();
            endDateMap = new Map<Date, Date>();
            Date tempStartDate = periodMap.get(ot.Period__c).Period_Start_Date__c;
            Date periodEndDate = periodMap.get(ot.Period__c).Period_End_Date__c;
            Date defaultDate = Date.newInstance(1900, 1, 7);
            
            while(tempStartDate <= periodEndDate){
                startDateList.add(tempStartDate);
                if(Math.mod(defaultDate.daysBetween(tempStartDate), 7) == 0){
                    if(tempStartDate.addDays(7) > periodEndDate){
                        endDateMap.put(tempStartDate, periodEndDate);
                        tempStartDate = periodEndDate.addDays(1);
                    }
                    else{
                        endDateMap.put(tempStartDate, tempStartDate.addDays(7));
                        tempStartDate = tempStartDate.addDays(8);
                    }
                }
                else if(Math.mod(defaultDate.daysBetween(tempStartDate), 7) == 1){
                    if(tempStartDate.addDays(6) > periodEndDate){
                        endDateMap.put(tempStartDate, periodEndDate);
                        tempStartDate = periodEndDate.addDays(1);
                    }
                    else{
                        endDateMap.put(tempStartDate, tempStartDate.addDays(6));
                        tempStartDate = tempStartDate.addDays(7);
                    }
                }
                else if(Math.mod(defaultDate.daysBetween(tempStartDate), 7) == 2){
                    if(tempStartDate.addDays(5) > periodEndDate){
                        endDateMap.put(tempStartDate, periodEndDate);
                        tempStartDate = periodEndDate.addDays(1);
                    }
                    else{
                        endDateMap.put(tempStartDate, tempStartDate.addDays(5));
                        tempStartDate = tempStartDate.addDays(6);
                    }
                }
                else if(Math.mod(defaultDate.daysBetween(tempStartDate), 7) == 3){
                    if(tempStartDate.addDays(4) > periodEndDate){
                        endDateMap.put(tempStartDate, periodEndDate);
                        tempStartDate = periodEndDate.addDays(1);
                    }
                    else{
                        endDateMap.put(tempStartDate, tempStartDate.addDays(4));
                        tempStartDate = tempStartDate.addDays(5);
                    }
                }
                else if(Math.mod(defaultDate.daysBetween(tempStartDate), 7) == 4){
                    if(tempStartDate.addDays(3) > periodEndDate){
                        endDateMap.put(tempStartDate, periodEndDate);
                        tempStartDate = periodEndDate.addDays(1);
                    }
                    else{
                        endDateMap.put(tempStartDate, tempStartDate.addDays(3));
                        tempStartDate = tempStartDate.addDays(4);
                    }
                }
                else if(Math.mod(defaultDate.daysBetween(tempStartDate), 7) == 5){
                    if(tempStartDate.addDays(2) > periodEndDate){
                        endDateMap.put(tempStartDate, periodEndDate);
                        tempStartDate = periodEndDate.addDays(1);
                    }
                    else{
                        endDateMap.put(tempStartDate, tempStartDate.addDays(2));
                        tempStartDate = tempStartDate.addDays(3);
                    }
                }
                else{
                    if(tempStartDate.addDays(1) > periodEndDate){
                        endDateMap.put(tempStartDate, periodEndDate);
                        tempStartDate = periodEndDate.addDays(1);
                    }
                    else{
                        endDateMap.put(tempStartDate, tempStartDate.addDays(1));
                        tempStartDate = tempStartDate.addDays(2);
                    }
                }
            }
            
            otwItem.opsTarget = ot;
            otwItem.startDateList = startDateList;
            otwItem.endDateMap = endDateMap;
            opsTargetWrapperList.add(otwItem);
        }
        
        return opsTargetWrapperList;
    }
    
    public class OpsTargetWrapper{
        Operations_Target__c opsTarget {get;set;}
        List<Date> startDateList {get;set;}
        Map<Date, Date> endDateMap {get;set;}
    }
    
}