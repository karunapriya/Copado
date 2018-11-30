public with sharing class REN_FieldMappingInputWrapper {
	
	public String fromObjectName{get;set;}
	public String toObjectName{get;set;}
	public String mappingName{get;set;}
	public REN_BaseMainController baseMainController{get;set;}
	public String sourceFieldLabel{get;set;}
	public String sectionLabel{get;set;}
	public String fromLabel{get;set;}
	public String toLabel{get;set;}
	public String gridHeader{get;set;}
	public boolean isDefaultShow{get;set;}
	public String parentIdsToRefresh{get;set;}
	
	public REN_FieldMappingInputWrapper(String fromObjectName, String toObjectName, String mappingName, 
										REN_BaseMainController baseMainController, String sourceFieldLabel, 
										String sectionLabel, String fromLabel, String toLabel, String gridHeader,String parentIdsToRefresh){
		this.fromObjectName = fromObjectName;
		this.toObjectName = toObjectName;
		this.mappingName = mappingName;
		this.baseMainController = baseMainController;
		this.sourceFieldLabel = sourceFieldLabel;
		this.sectionLabel = sectionLabel;
		this.fromLabel = fromLabel;
		this.toLabel = toLabel;
		this.gridHeader = gridHeader;
		this.isDefaultShow = true;
		this.parentIdsToRefresh=parentIdsToRefresh;
	}
}