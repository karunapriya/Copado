/**
* @description    CHL_OverviewWrapper class for data that is returned on the channel partner landing overview page
*/

public with Sharing Class CHL_OverviewWrapper{
  
	public String channelPartner;
  	public Integer newOpps;
  	public Integer updateOpps;
  	public Integer completedRequests;
  	public List<CHL_ExpiredMatrix> expiredOpps;  
   	public CHL_CurrentQuarter currentQuarter{get;set;}
   	public list<CHL_Quarters> quarters{get;set;}
   	public List<String> countries{get;set;}
   	public list<CHL_ResellerReps> resellerReps{get;set;}
   	public list<CHL_DistributorReps> distributorReps{get;set;}  
    public List<CHL_Years> years{get;set;}
    public CHL_CurrentYear currentYear{get;set;}
    
    
    public class CHL_ResellerReps{
    	public String name{get;set;}
      	public String id{get;set;}
    }
    
    public class CHL_DistributorReps{
      	public String name{get;set;}
      	public String id{get;set;}
    }
  
  	public class CHL_ExpiredMatrix{
     	public String count;
     	public String name;
     	public String amount;
  	}
  	

}