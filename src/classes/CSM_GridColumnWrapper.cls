public with sharing class CSM_GridColumnWrapper {
	public String recordID {get; set;}
	public String apiName {get; set;}
	public String label {get; set;}
	public String value {get; set;}
	public String lookUpId {get; set;}
	public Boolean isSortable {get; set;}
	public Boolean isSwitchable {get; set;}
	public String valueCol {get; set;}
	public String lookUpIdCol {get; set;}
	public Boolean isDateCol {get; set;}
	public String filterControl {get; set;}
	public String hiddenDate {get; set;}
	public String hiddenValue {get; set;}
	public String dataType {get; set;}
	public Boolean isCurrencyCol {get; set;}
	public Boolean isNumberCol {get; set;}
	public String customColumnSorter {get;set;}
	public Boolean isLinkCol {get;set;}
	
	public CSM_GridImageWrapper gridImage {get; set;}
	public Boolean isVisible {
		get {
			if(isVisible == null){
				isVisible = true;
			}
			return isVisible;
		}
		set;
	}
	public String dataAlign {
		get
		{
			if (dataAlign == null)
			{
			    dataAlign = 'center';
		    }
		    return dataAlign;
		}
		set;
	}
}