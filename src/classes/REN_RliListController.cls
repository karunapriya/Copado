/**
 * Created Date     : Jul 21, 2017
 * Developed By     : Dheeraj, Comity Designs, Inc.
 *
 * Function         : @description - Description about the functionality that the class provides
 * Support Email    : email
 * Version          : 1.0
 *
 * Modification Log
 *
 * Developer Name           User Story              Date            Version             Description
 *____________________________________________________________________________________________________
 *
 * Dheeraj                  User Story              Jul 21, 2017            1.1                 @description
 * 
 */
public with sharing class REN_RliListController {

    public List<REN_RenewLineWrapper> rliWrapperList{get;set;}
    public Integer numberOfRowToRemove {get;set;}
    public List<Schema.FieldSetMember> fldMembers{get;set;}
    public string namespace{get;set;}
    public REN_RliListController(){
        fldMembers=CHL_Util.getFieldSet((CSM_Util.getNamespace()+'REN_Manual_Opp_Generation'),(CSM_Util.getNamespace()+'REN_Renews_To__c'));
        namespace = CSM_Util.getNamespace();
    }
  
    
    // The method to remove an item from the list
    public PageReference removeOpli(){
       this.rliWrapperList.remove(this.numberOfRowToRemove);  
       this.updateCustomId();
       return null;
    }
    
    private void updateCustomId(){
        for(Integer i=0; i<this.rliWrapperList.size(); i++){
            REN_RenewLineWrapper wrapper = this.rliWrapperList.get(i);
            wrapper.customId = i;
        }
    }
   
}