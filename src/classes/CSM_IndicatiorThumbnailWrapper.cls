public with sharing class CSM_IndicatiorThumbnailWrapper {
	
	public String indicatorLabel {get; set;}
	public Object indicatorData {get; set;}
	public String indicatorImg {get; set;}
	public String indicatorBackgroundColor {get; set;}
	public String borderStyle {get; set;}
	public String styleClassInd {get; set;}
	public String dataType {get; set;}
	public Double indicatorDouble {get; set;}
	public String currencyCode {get; set;}
	public String currencyCodeSymbol {get; set;}
	public Integer indicatorInteger {get; set;}
	
	
	public CSM_IndicatiorThumbnailWrapper(String label)
	{    		
		this.indicatorLabel = label;
		this.borderStyle = 'borderLineStyle';  
	}
	
}