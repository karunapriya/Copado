public with sharing class REN_LogicBuilderInputWrapper {

	public SObject parentObject{get;set;}
	public String criteriaObject{get;set;}
	public String logicBuilderObject{get;set;}
	public String logicBuilderExtName{get;set;}
	public Boolean isSearch{get;set;}
	public REN_BaseMainController baseMainController{get;set;}
	public String titleLabel{get;set;}
	public String refreshFunctionName{get;set;}
	public String onChangeFunctionName{get;set;}
	public Boolean showUserLookup{get;set;}	
	public String relatedFields {get;set;}
	
	// SET this field's value ONLY IF you want to create single instance of LogicBuilder on page.
	public String lbSingleInstanceKey {get;set;}
	public Boolean isBulkSearch{get;set;}
	public Set<String> firstFilterSet{get;set;}

	public Boolean isCurrencyOptionDisabled {get;set;}
	public REN_LogicBuilderInputWrapper dependentLogicBuilder{get;set;}
	
	
	
	public REN_LogicBuilderInputWrapper(SObject parentObject, String criteriaObject, 
										String logicBuilderObject, String logicBuilderExtName, 
										Boolean isSearch, REN_BaseMainController baseMainController, 
										String titleLabel, String refreshFunctionName, String onChangeFunctionName){
		this(parentObject, criteriaObject, logicBuilderObject, logicBuilderExtName, isSearch, 
				baseMainController, titleLabel, refreshFunctionName, onChangeFunctionName, false, null);
	}
	
	public REN_LogicBuilderInputWrapper(SObject parentObject, String criteriaObject, 
										String logicBuilderObject, String logicBuilderExtName, 
										Boolean isSearch, REN_BaseMainController baseMainController, 
										String titleLabel, String refreshFunctionName, String onChangeFunctionName,
										Boolean showUserLookup,String relatedFields){
		this.parentObject = parentObject;
		this.criteriaObject = criteriaObject;
		this.logicBuilderObject = logicBuilderObject;
		this.logicBuilderExtName = logicBuilderExtName;
		this.isSearch = isSearch;
		this.baseMainController = baseMainController;
		this.titleLabel = titleLabel;
		this.refreshFunctionName = refreshFunctionName;
		this.onChangeFunctionName = onChangeFunctionName;
		this.showUserLookup = (showUserLookup == null)?false:showUserLookup;
		this.relatedFields = relatedFields;
		isCurrencyOptionDisabled = false;
		isBulkSearch = false;
	}
}