public with sharing class CSM_GridActionWrapper
{
    public String typeAction{get; set;}
    public String hrefAction{get; set;}
    public String onclickAction {get; set;}
    public String titleAction {get; set;}
    public String classAction {get; set;}
    public String actionName {get; set;}
    public String actionId {get; set;}
    public String actionValue {get; set;}
    
    public CSM_GridActionWrapper(String typeOfAction)
    {
        this.typeAction = typeOfAction;
    }
}