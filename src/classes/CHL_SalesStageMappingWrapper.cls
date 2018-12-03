public with sharing class CHL_SalesStageMappingWrapper {
	public String keyClassName {get; set; }
    public REN_BaseMainController baseMainController{get; set; }
    public String leftSideLabel {get; set; }
    public String rightSideLabel {get; set; }
    public String typeLabel {get; set;}
    public String leftPickListObjectName {get; set;}
	public String leftPickListObjFieldName {get; set; }
	public String typeObjectName {get; set; }
	public String typeObjFieldName {get; set; }
	public String rightPickListObjectName {get; set; }
	public String rightPickListObjFieldName {get; set; }
	
 	public CHL_SalesStageMappingWrapper(String keyClassName,REN_BaseMainController baseMainController, String leftSideLabel, String rightSideLabel, String typeLabel, 
 	String leftPickListObjectName, String leftPickListObjFieldName, String typeObjectName, String typeObjFieldName, String rightPickListObjectName, String rightPickListObjFieldName) {
    	this.keyClassName = keyClassName;
        this.baseMainController = baseMainController;
        this.leftSideLabel = leftSideLabel;
        this.rightSideLabel = rightSideLabel;
        this.typeLabel = typeLabel;
        this.leftPickListObjectName = leftPickListObjectName;
		this.leftPickListObjFieldName = leftPickListObjFieldName;
		this.typeObjectName = typeObjectName;
		this.typeObjFieldName = typeObjFieldName;
		this.rightPickListObjectName = rightPickListObjectName;
		this.rightPickListObjFieldName = rightPickListObjFieldName;
   	}
}