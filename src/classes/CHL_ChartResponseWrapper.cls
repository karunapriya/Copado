public with sharing class CHL_ChartResponseWrapper {
	
	public List<String> categories = new List<String>();
	public Set<Data> chartSeries = new  Set<Data>();
	public string currencyCode{get;set;}
	
	public CHL_ChartResponseWrapper(Map< String, Map< Boolean, Integer > > chartStatusMap){
		
		Data updateNoStatus = new Data(Label.CHL_LBL_OPPS_UPDATED);
		Data updateStatus = new Data(Label.CHL_LBL_OPPS_NEED_UPDATE);
		
		for(String mapKey : chartStatusMap.keyset()){
			categories.add(mapKey);
			Map< Boolean, Integer >  statusMap = chartStatusMap.get(mapKey);
			
			if(statusMap.get(true) != null){
				updateStatus.data.add(statusMap.get(true)) ;
				chartSeries.add(updateStatus);
			}
			
			if(statusMap.get(false) != null){
			    updateNoStatus.data.add(statusMap.get(false)) ;
				chartSeries.add(updateNoStatus);
			}
		}
	}
	
	public class Data{
    	public String name;
    	public List<Integer> data  = new List<Integer>();
  	
	  	public Data(String ValueName){
	  		name = ValueName;
	  	}
 	}

}