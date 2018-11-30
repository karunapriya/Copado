/*
Created By: PES
Created On: 2nd April 2015
Modified On : 11th June 2015
Apex page:  REN_WaterfallReport_Charts 
Test class: REN_WaterfallReportControllerTest */

public with sharing class REN_RenewalsInsightController
{ 
    public String data{ get { return populateChart(); } }
    public String currentFilter{ get; set;}
    public String quarterFilter{ get; set;}
    public String ownerFilter{ get; set;}
    public String countryFilter{ get; set;}
    public String defaultFilter{get;set;}
    public List<SelectOption> quarterList {get;set;}
    public List<SelectOption> ownerList {get;set;}
    public List<SelectOption> countryList {get;set;}
    public String baseCurrency {get { return userinfo.getDefaultCurrency(); }} 
    public String baseCurrencySymbol {get;set;}   
       
    @TestVisible private decimal total_Target=0;
    @TestVisible private decimal total_Resolved=0;
    @TestVisible private decimal total_Lost=0;
    @TestVisible private decimal total_Won=0;
    @TestVisible private decimal pipe_Total_Won=0;
    @TestVisible private decimal pipe_Adds_Total_Won=0;
    @TestVisible private decimal target_Unresolved=0;
    @TestVisible private decimal total_Conversion_Delta=0;       
    
    public String rptAvailable {get;set;}
    public String rptUnresolved {get;set;}
    public String rptResolved {get;set;}
    public String rptLost {get;set;}
    public String rptWon {get;set;}
    public String rptConversion {get;set;}
    public String rptAddWon {get;set;}
    public String rptPipeWon {get;set;}
    private Set<String> quarterSet;
    private Set<String> countrySet;
    private Set<String> ownerSet;
    private list<integer> lstCurrQuarterYear;
    private transient list<opportunity> renewalOppList;
    private transient list<opportunity> closeWonOppList;
    private final String defaultOption = 'All';    
    private list<Report> reportList = new list<Report>();
    
    //Default constructor
    public REN_RenewalsInsightController() 
    {                
        prepareChartData();
        setReportId();
		lstCurrQuarterYear = REN_OpportunityDataAccess.UpdateExpQuarterYear(System.Now().Date());
		System.debug('lstCurrQuarterYear - '+lstCurrQuarterYear);
        if(lstCurrQuarterYear!=null && !lstCurrQuarterYear.IsEmpty()) {
            defaultFilter = 'Q'+lstCurrQuarterYear[0] + ' FY' + lstCurrQuarterYear[1];
            currentFilter = defaultFilter;
        }                
        baseCurrencySymbol = CSM_Util.convertCurrencyNameToSymbol(baseCurrency);
        prepareFilter();
        System.debug('Initial currentFilter - '+currentFilter);
        filterChart();        
    } 
    
   //Returns data to be displayed in chart
  public String populateChart()
   {      
        String conversionOppColor = '#86d503';
        String addedOppColor = '#86d503';                   
        if(total_conversion_delta < 0)
        {
            conversionOppColor = '#A8A8A8';
        }
        if(pipe_Adds_total_won < 0)
        {
            addedOppColor = '#A8A8A8';
        }
        String chartData ='{name: "' +REN_Constants.AVAILABLE_OPPORTUNITY + '"  ,y:' + total_target + '},{name: " ' + REN_Constants.UNRESOLVED_OPPORTUNITY + ' ",y:' + Target_unresolved + '}, {name: " ' + REN_Constants.RESOLVED_OPPORTUNITY + ' ",' + REN_Constants.HCHRT_LITERAL_ISINTERMEDIATESUM + ':true},{name: " '+REN_Constants.LOST_OPPORTUNITY + ' ",y:' + total_lost + '}, {name: " ' +REN_Constants.WON_OPPORTUNITY + ' " ,'+REN_Constants.HCHRT_LITERAL_ISSUM + ':true},{name: " ' + REN_Constants.CONVERSION_OPPORTUNITY + ' ",y:' + total_conversion_delta + ',color:" '+conversionOppColor+ '"},{name: " ' +REN_Constants.ADDED_OPPORTUNITY + ' ",y:' + pipe_Adds_total_won + ',color:"'+addedOppColor +'"},{name: " ' + REN_Constants.TOTAL_OPPORTUNITY + ' ",'+REN_Constants.HCHRT_LITERAL_ISSUM +':true}';
        return chartData;         
   }
    
   //return two lists of opportunity. one with Stage "Closed Won" and other without it
   private void prepareChartData()
   {
        String queryStageName = 'Closed Won';
        renewalOppList = REN_OpportunityDataAccess.getRenewalOppListForChartData();
        closeWonOppList = REN_OpportunityDataAccess.getCloseWonOppListForChartData(queryStageName);
   }
   
   //Fetch reports from 'CSM_Reports' folder and assign the report ids to respective properties  
   public void setReportId()
   {
        List<Report> reportList = REN_OpportunityDataAccess.getReportList();//[SELECT Name FROM Report WHERE OwnerId in (SELECT id FROM folder where developerName =: REN_Constants.REPORTNAME)];
        if(reportList.size() > 0)
        {
            for(Report rpt : reportList)
            {
                if(rpt.Name == REN_Constants.RENEWAL_TARGET_TOTAL_AVAILABLE)
                    rptAvailable = string.ValueOf(rpt.Id);
                else if(rpt.Name == REN_Constants.RENEWAL_TARGET_UNRESOLVED)
                    rptUnresolved = string.ValueOf(rpt.Id);
                else if(rpt.Name == REN_Constants.RENEWAL_TARGET_RESOLVED)
                    rptResolved = string.ValueOf(rpt.Id);
                else if(rpt.Name == REN_Constants.RENEWAL_TARGET_LOST)
                    rptLost = string.ValueOf(rpt.Id);
                else if(rpt.Name == REN_Constants.RENEWAL_TARGET_WON)
                    rptWon = string.ValueOf(rpt.Id);            
                else if(rpt.Name == REN_Constants.CONVERSION_DELTA)
                    rptConversion = string.ValueOf(rpt.Id);
                else if(rpt.Name == REN_Constants.PIPELINE_ADDS_WON)
                    rptAddWon = string.ValueOf(rpt.Id);
                else if(rpt.Name == REN_Constants.PIPELINE_WON)
                    rptPipeWon = string.ValueOf(rpt.Id);          
            }        
        }   
    }
    
	//To populate values in three filters (Expiration Quarter, Account Team, Country)
	private Void prepareFilter()
	{
		Set<String> tempOwnerSet = new Set<String>();
		List<String> tempOwnerList = new List<String>();
		Set<String> tempCountrySet = new Set<String>();
		List<String> tempCountryList = new List<String>(); 
		Set<String> tempQuarterSet = new Set<String>();
		List<String> tempQuarterList = new List<String>();  
		quarterList = new List<SelectOption>();
		ownerList  = new List<SelectOption>();
		countryList = new List<SelectOption>();
		       
		try
		{       
			String tempQuarterFilter = '';
			Boolean existQuarterFilter = false;
			String yearVal = String.valueOf(Datetime.now().year());
			String tempQuarterFilterBackup = '';
			// set owner, country and quarter sets for opportunities irrespective of sales stage
			for(Opportunity opp: renewalOppList)
			{
		        tempOwnerSet.add(opp.Owner.Name);
		        if (opp.AccountId !=null) {
		        	tempCountrySet.add(opp.Account.BillingCountry);
		        }
		        if (opp.REN_Expiration_Quarter_Year__c!=null){
		        	tempQuarterSet.add(opp.REN_Expiration_Quarter_Year__c);
		        	System.debug('yearVal - '+yearVal);
		        	System.debug('opp.REN_Expiration_Quarter_Year__c - '+opp.REN_Expiration_Quarter_Year__c);
		        	System.debug('opp.REN_Expiration_Quarter_Year__c indexOf - '+opp.REN_Expiration_Quarter_Year__c.indexOf(yearVal));
		        	tempQuarterFilterBackup = opp.REN_Expiration_Quarter_Year__c;
			        if (existQuarterFilter == false && opp.REN_Expiration_Quarter_Year__c.indexOf(yearVal)>-1){
			        	tempQuarterFilter = opp.REN_Expiration_Quarter_Year__c;	
			        }
		        
		        	System.debug('Check opp.REN_Expiration_Quarter_Year__c - ' + opp.REN_Expiration_Quarter_Year__c);
		        	System.debug('Check currentFilter - ' + currentFilter);
		        	System.debug('Check equal - ' + opp.REN_Expiration_Quarter_Year__c.indexOf(currentFilter));
			        if (currentFilter!=null && opp.REN_Expiration_Quarter_Year__c.indexOf(currentFilter)>-1){
			        	existQuarterFilter = true;
			        }
		        }			       
			}
			// set owner, country and quarter sets for opportunities with sales stage "closed won"
			for(Opportunity opp : closeWonOppList)
			{
				tempOwnerSet.add(opp.Owner.Name);
				if (opp.AccountId !=null) {
		        	tempCountrySet.add(opp.Account.BillingCountry);
				}
				if (opp.REN_Expiration_Quarter_Year__c!=null){
		        	tempQuarterSet.add(opp.REN_Expiration_Quarter_Year__c);
		        	System.debug('yearVal - '+yearVal);
		        	System.debug('opp.REN_Expiration_Quarter_Year__c - '+opp.REN_Expiration_Quarter_Year__c);
		        	System.debug('opp.REN_Expiration_Quarter_Year__c indexOf - '+opp.REN_Expiration_Quarter_Year__c.indexOf(yearVal));
			        tempQuarterFilterBackup = opp.REN_Expiration_Quarter_Year__c;
			        if (existQuarterFilter == false && opp.REN_Expiration_Quarter_Year__c.indexOf(yearVal)>-1){
			        	tempQuarterFilter = opp.REN_Expiration_Quarter_Year__c;	
			        }
		        	System.debug('Check opp.REN_Expiration_Quarter_Year__c - ' + opp.REN_Expiration_Quarter_Year__c);
		        	System.debug('Check currentFilter - ' + currentFilter);
		        	System.debug('Check equal - ' + opp.REN_Expiration_Quarter_Year__c.indexOf(currentFilter));
			        if (existQuarterFilter == false && currentFilter!=null && opp.REN_Expiration_Quarter_Year__c.indexOf(currentFilter)>-1){
			        	existQuarterFilter = true;
			        }
				}
               
			}
	         if(existQuarterFilter==false) {
	         	currentFilter = tempQuarterFilterBackup;
	         	if (!String.isBlank(tempQuarterFilter)){
	         		currentFilter = tempQuarterFilter;
	         	}
	         }
           System.debug('Check currentFilter - ' + currentFilter);
           System.debug('Check tempQuarterFilter - ' + tempQuarterFilter);
           
			//Prepare owner multiselect list
			String owners = '';
            ownerList.Add(new SelectOption('',defaultOption));
			if(!tempOwnerSet.isEmpty() && tempOwnerSet != null){
				tempOwnerList.addAll(tempOwnerSet);
				tempOwnerList.sort();
				for(String owner: tempOwnerList){
					ownerList.add(new SelectOption(owner,owner));
					if (owners.length()>0){
						owners += ',';
					}
					owners += owner;
			
				}
				tempOwnerSet.clear();
				if (owners.length()>0){
					currentFilter+= '#'+owners;
				}
			}
           
			//Prepare country multiselect list
			String countries = '';
			countryList.Add(new SelectOption('',defaultOption));
			if(!tempCountrySet.isEmpty() && tempCountrySet != null){
				tempCountryList.clear(); 
				tempCountryList.addAll(tempCountrySet);
				tempCountryList.sort();
				for(String country: tempCountryList){
					if(String.isNotEmpty(country)) {  
						countryList.add(new SelectOption(country,country));
					}
					if (country!=null){
						if (countries.length()>0){
							countries += ',';
						}
						countries += country;
					}
				}   
				tempCountrySet.clear();
				if (countries.length()>0){
					currentFilter+= '#'+countries;
				}
			}     
                   
			//Prepare quarter multiselect list
			List<String> tempStr = new List<String>();
			QuarterList.Add(new SelectOption('',defaultOption));
			if(!tempQuarterSet.isEmpty() && tempQuarterSet != null)
			{
				tempQuarterList.clear(); 
				tempQuarterList.addAll(tempQuarterSet);
				for(String quarter: tempQuarterList)
				{
					if(String.isNotEmpty(quarter)) 
					{
						string[] quarterArray = quarter.split(' ');
						if(quarterArray != null && quarterArray.size() > 1) {
							tempStr.add(quarterArray[1] +' '+quarterArray[0]);
						}
                 
					}
				}
                tempStr.sort();
                integer i = 0;
                for(string str: tempStr)
                {
                   String[] finalStr = str.split(' ');                  
                   tempStr[i] = finalStr[1] +' '+finalStr[0];
                   QuarterList.add(new SelectOption(tempStr[i],tempStr[i])); 
                   i++;                  
                                                         
                } 
                tempQuarterSet.clear();
			} 
			System.debug('ZZZ ownerList - ' + ownerList);
			System.debug('ZZZ countryList - ' + countryList);
			System.debug('ZZZ currentFilter - ' + currentFilter);    
              
		}
		catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
		}
		finally {
			tempOwnerSet = null;
			tempOwnerList = null;
			tempCountrySet = null;
			tempCountryList = null;
			tempQuarterSet = null;
			tempQuarterList = null;
		}
	}
 
	//Called from UI to filter chart data as well as invoked from default constructor
	public pagereference filterChart()
	{
		quarterSet = new set<String>();
		countrySet = new set<String>();
		ownerSet = new set<String>();
		total_Target = 0;
		total_Resolved = 0;
		total_Lost = 0;
		total_Won = 0;
		pipe_Total_Won = 0;
		pipe_Adds_Total_Won = 0;
		target_Unresolved =0;
		total_Conversion_Delta=0;
		String[] filters;
		try
		{
	        if(String.isEmpty(currentFilter) || currentFilter.equals('##'))
	        {           
               currentFilter = defaultFilter;  
            }            
            filters = currentFilter.split('#');
            if(filters != null && !filters.isEmpty())
            {
            	if(filters.size() > 0 && String.isNotEmpty(filters[0]))
                {
                   	quarterSet.AddAll(filters[0].split(','));
                }
                
                if(filters.size() > 1 && String.isNotEmpty(filters[1]))
                {
                   ownerSet.AddAll(filters[1].split(','));
                }
                
                if(filters.size() > 2 && String.isNotEmpty(filters[2]))
                {
                   countrySet.AddAll(filters[2].split(','));
                }
            }
            System.debug('ZZZZ quarterSet - '+quarterSet);
            System.debug('ZZZZ ownerSet - '+ownerSet);
            System.debug('ZZZZ countrySet - '+countrySet);
            total_Target = fetchWaterfallData(rptAvailable);
            System.debug('ZZZZ total_Target - '+total_Target);
            target_Unresolved = fetchWaterfallData(rptUnresolved);
            System.debug('ZZZZ target_Unresolved - '+target_Unresolved);
            total_Resolved = fetchWaterfallData(rptResolved);
            System.debug('ZZZZ total_Resolved - '+total_Resolved);
            total_Lost = fetchWaterfallData(rptLost);
            System.debug('ZZZZ total_Lost - '+total_Lost);
            total_Won = fetchWaterfallData(rptWon);
            System.debug('ZZZZ total_Won - '+total_Won);
            total_Conversion_Delta = fetchWaterfallData(rptConversion);
            System.debug('ZZZZ total_Conversion_Delta - '+total_Conversion_Delta);
            pipe_Adds_Total_Won = fetchWaterfallData(rptAddWon);
            System.debug('ZZZZ pipe_Adds_Total_Won - '+pipe_Adds_Total_Won);
            pipe_Total_Won = fetchWaterfallData(rptPipeWon);
            System.debug('ZZZZ pipe_Total_Won - '+pipe_Total_Won);
            
                    
            pipe_Total_Won = pipe_Total_Won.setScale(0);
            System.debug('ZZZZ pipe_Total_Won - '+pipe_Total_Won);
            pipe_Adds_Total_Won = pipe_Adds_Total_Won.setScale(0);
            System.debug('ZZZZ pipe_Adds_Total_Won - '+pipe_Adds_Total_Won);
            total_Target = total_Target.setScale(0);
            System.debug('ZZZZ total_Target - '+total_Target);
            total_Won = total_Won.setScale(0);
            System.debug('ZZZZ total_Won - '+total_Won);
            total_Resolved = total_Resolved.setScale(0);        
            System.debug('ZZZZ total_Resolved - '+total_Resolved);
            total_Lost = 0 - total_Lost ;
            total_Lost = total_Lost.setScale(0);
            target_Unresolved  = 0-(total_Target - total_Resolved);
            target_Unresolved = target_Unresolved.setScale(0); 
            System.debug('ZZZZ target_Unresolved - '+target_Unresolved);
            total_Conversion_Delta = total_Conversion_Delta.setScale(0);  
            System.debug('ZZZZ total_Conversion_Delta - '+total_Conversion_Delta);     
        }
        //Exception if Report Cross 500 synchronously
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
        }
        finally
        {
          quarterSet = null;
          countrySet = null;
          ownerSet = null;
          filters = null;
        }
        return null;
   }

    //Pass reportId and fetch the data from corresponding report
    private Decimal fetchWaterfallData(String rptId)
    {
        String quarterFilter = getFilterString(quarterSet);
        String countryFilter = getFilterString(countrySet);
        String ownerFilter =   getFilterString(ownerSet);
        
        Reports.ReportMetadata reportMetadata = Reports.ReportManager.describeReport(rptId).getReportMetadata();
        List<Reports.ReportFilter> filters = new List<Reports.ReportFilter>(); 
        Reports.ReportFilter newFilter = new Reports.ReportFilter();
        
        String nameSpace = CSM_Util.getNamespace();
        
        newFilter.setColumn('Opportunity.' + nameSpace +  'REN_Is_CLM_Renewal__c');
        newFilter.setOperator('equals');
        newFilter.setValue('true');
        filters.add(newFilter);
        
        newFilter = new Reports.ReportFilter();
        newFilter.setColumn('Opportunity.'+ nameSpace +'REN_Expiration_Quarter_Year__c');
        newFilter.setOperator('contains');
        newFilter.setValue(quarterFilter);
        filters.add(newFilter);
        
        newFilter = new Reports.ReportFilter();
        newFilter.setColumn('FULL_NAME');
        newFilter.setOperator('contains');
        newFilter.setValue(ownerFilter);
        filters.add(newFilter);
        
        newFilter = new Reports.ReportFilter();
        newFilter.setColumn('ADDRESS1_COUNTRY');
        newFilter.setOperator('contains');
        newFilter.setValue(countryFilter);
        filters.add(newFilter);
        
        reportMetadata.setReportFilters(filters);
        Reports.reportResults results  = Reports.ReportManager.runReport(rptId,reportMetadata, false);
        Reports.ReportFact grandTotal = (Reports.ReportFact)results.getFactMap().get('T!T');
        Decimal grandTotalAmount =  (Decimal)(grandTotal.getAggregates().get(0).getValue());
        return grandTotalAmount;
    }
    
    //Convert string set to comma separated string 
	private String getFilterString(set<String> filterSet)
	{
        String commaSeparatedList='';
        if(filterSet != null && !filterSet.isEmpty())
        {
            for(String str : filterSet)
            {
                commaSeparatedList += str + ',' ;
            }
        commaSeparatedList = commaSeparatedList.subString(0,commaSeparatedList.length()-1);
        }
	    return commaSeparatedList;
	}
    
	//Fetch Corporate currency of the organization 
    public String getCorporateCurrency()
    {
        return CSM_Util.getCorpCurrency();
    }
}