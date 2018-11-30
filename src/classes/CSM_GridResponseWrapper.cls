global with sharing class CSM_GridResponseWrapper {
	public List<CSM_GridRowWrapper> row {get; set;}
	public List<CSM_GridColumnWrapper> header {get; set;}
    public Map<String, CSM_GridColumnWrapper> headerMap {get; set;}
	public Boolean hasCheckbox {get; set;}
	public Boolean hasAction {get; set;}
	public Boolean hasDetail {get; set;}

	public String errorMessage {get; set;}
	public Map<String, String> dialogBoxValue{get;set;}

}