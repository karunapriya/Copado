public with sharing class SalesTargetExtension {
    
    public Sales_Target__c thisSalesTarget {get; set;}
    ApexPages.StandardController controller;
    
    public Boolean selectAll {get; set;}
    public Integer bulkTarget {get; set;}
    //public List<Generated_Operations_Target__c> generatedOpsTargetList {get;set;}
    Map<Id, Sales_Target_Line_Item__c> generatedSalesTargetMap;
    public List<GenSalesTargetWrapper> genSalesTargetWrapperList {get;set;}
    
    public List<SelectOption> updateOptions {get;set;}
    public String updateMode {get; set;}
    
    public Boolean editMode{get;set;}
    
    Set<ID> salesTargetIdSet = new Set<ID>();   
   
    
    public SalesTargetExtension(ApexPages.StandardController controller) {
        thisSalesTarget = (Sales_Target__c)controller.getRecord();
        this.controller = controller;
        
        editMode = false;
        
        updateOptions = new List<SelectOption>();
        updateOptions.add(new SelectOption('Single','Single'));
        updateOptions.add(new SelectOption('Mass','Mass'));
        salesTargetIdSet.add(thisSalesTarget.Id);
        generatedSalesTargetMap = SalesTargetDataAccess.getSalesTargetLineItemMapById(salesTargetIdSet);
        
        genSalesTargetWrapperList = new List<GenSalesTargetWrapper>();
        for(Sales_Target_Line_Item__c gen : SalesTargetDataAccess.getSalesTargetLineItemByStartDate(salesTargetIdSet)){
        	GenSalesTargetWrapper gsw = new GenSalesTargetWrapper();
            gsw.selectGenSales = false;
            gsw.genSales = gen;
            genSalesTargetWrapperList.add(gsw);
        }
        
    }
    
    public pageReference saveChanges(){
        PageReference retUrl = controller.view();
        
        List<Sales_Target_Line_Item__c> genSalesTargetToUpdateList = new List<Sales_Target_Line_Item__c>();
        List<String> salesTargetLIFieldList = new List<String>{Util.solnExtnNameSpace+'Target__c'};
        System.debug('####DEBUG generatedSalesTargetMap: ' + generatedSalesTargetMap);
        System.debug('####DEBUG genSalesTargetWrapperList: ' + genSalesTargetWrapperList);
        for(GenSalesTargetWrapper gsw : genSalesTargetWrapperList){
            if(updateMode == 'Single'){
                if(gsw.genSales.Target__c != generatedSalesTargetMap.get(gsw.genSales.Id).Target__c){
					genSalesTargetToUpdateList.add(gsw.genSales);                    
                }
                
            }
            
            if(updateMode == 'Mass'){
                if(gsw.selectGenSales == true){
                    gsw.genSales.Target__c = bulkTarget;
                    genSalesTargetToUpdateList.add(gsw.genSales);
                }
            }
        }
        
        try{
            //controller.save();
            if(genSalesTargetToUpdateList.size() > 0) SalesTargetDataAccess.updateSalesTargetLI(genSalesTargetToUpdateList, salesTargetLIFieldList);
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        System.debug('####DEBUG genSalesTargetToUpdateList.size(): ' + genSalesTargetToUpdateList.size());
        editMode = false;
        return retUrl;
    }
    
    public pageReference goToEditPage(){
        editMode = true;
        updateMode = 'Single';
        //PageReference editPage = new PageReference('/apex/OperationsTargetEditPage');
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
    
    public class GenSalesTargetWrapper{
        public Boolean selectGenSales {get;set;}
        public Sales_Target_Line_Item__c genSales {get;set;}
    }
    
    /****BEGIN METHODS CALLED BY SALES TARGET TRIGGER TO GENERATE SALES TARGET ITEMS****/
    
    public static void generateSalesTarget(List<Sales_Target__c> salesTargetList){
        
        List<SalesTargetWrapper> salesTargetWrapperList = new List<SalesTargetWrapper>();
        List<Sales_Target_Line_Item__c> stToGenerateList = new List<Sales_Target_Line_Item__c>();
        String namespace = Util.solnExtnNameSpace;
		List<String> salesTargetLIFieldList = new List<String>{//namespace+'Sales_Target__c',
			namespace+'Start_Date__c',namespace+'End_Date__c'};
        salesTargetWrapperList = dateBreakDown(salesTargetList);
		
		for(SalesTargetWrapper stw : salesTargetWrapperList){
			for(Date sDate : stw.startDateList){
				Sales_Target_Line_Item__c gst = new Sales_Target_Line_Item__c(
					Sales_Target__c = stw.salesTarget.Id,
					Start_Date__c = sDate,
					End_Date__c = stw.endDateMap.get(sDate));
				stToGenerateList.add(gst);
			}
		}

		if(stToGenerateList.size() > 0){
			SalesTargetDataAccess.insertSalesTargetLI(stToGenerateList,salesTargetLIFieldList);
		}
	}
    
    public static List<SalesTargetWrapper> dateBreakDown(List<Sales_Target__c> salesTargetList){
		List<SalesTargetWrapper> salesTargetWrapperList = new List<SalesTargetWrapper>();
		List<Date> startDateList;
		Map<Date, Date> endDateMap;
		Set<String> periodIds = new Set<String>();
		
		for(Sales_Target__c st : salesTargetList){
			periodIds.add(st.Period__c);
		}
        
		Map<Id, Period__c> periodMap = PeriodDataAccess.getPeriodRecordsById(periodIds);
        
		for(Sales_Target__c st : salesTargetList){
			SalesTargetWrapper stwItem = new SalesTargetWrapper();
			startDateList = new List<Date>();
			endDateMap = new Map<Date, Date>();
			Date tempStartDate = periodMap.get(st.Period__c).Period_Start_Date__c;
			Date periodEndDate = periodMap.get(st.Period__c).Period_End_Date__c;
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
			
			stwItem.salesTarget = st;
			stwItem.startDateList = startDateList;
			stwItem.endDateMap = endDateMap;
			salesTargetWrapperList.add(stwItem);
		}
		
		return salesTargetWrapperList;
    }
	
	public class SalesTargetWrapper{
		Sales_Target__c salesTarget {get;set;}
		List<Date> startDateList {get;set;}
		Map<Date, Date> endDateMap {get;set;}
	}
    
}