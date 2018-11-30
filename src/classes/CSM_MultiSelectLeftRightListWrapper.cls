/**
 * Created Date		: Feb 17, 2017
 * Developed By		: abirjepatil, Comity Designs, Inc.
 *
 * Function			: @description - Description about the functionality that the class provides
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * abirjepatil					User Story				Feb 17, 2017			1.1					@description
 * 
 */
public with sharing class CSM_MultiSelectLeftRightListWrapper {

    public List<SelectOption> leftOptionList {get;set;}
    public List<SelectOption> rightOptionList {get;set;}
    public List<SelectOption> publicGroupList {get;set;}    
    public List<SelectOption> roleGroupList {get;set;}    
    public List<SelectOption> roleSubordGroupList {get;set;}    
    public List<SelectOption> userList {get;set;}    
    public String leftListLabel{get;set;}
    public String rightListLabel{get;set;}
    public String prefix{get;set;}    
    public REN_BaseMainController baseMainController{get;set;}  
    public Integer maxRightListSize {get; set;}
    //public REN_BaseChildController baseChildController{get;set;}    
      
    public CSM_MultiSelectLeftRightListWrapper(String leftListLabel, String rightListLabel, List<SelectOption> leftList, List<SelectOption> rightList,REN_BaseMainController baseMainController, String prefix,List<SelectOption> publicGroupList, List<SelectOption> roleGroupList, List<SelectOption> roleSubordGroupList, List<SelectOption> userList, Integer maxRightListSize) {
        this.leftListLabel = leftListLabel;
        this.rightListLabel = rightListLabel;
        this.leftOptionList = leftList;
        this.rightOptionList = rightList;
        this.publicGroupList = publicGroupList;        
        this.roleGroupList = roleGroupList;
        this.roleSubordGroupList = roleSubordGroupList;        
        this.userList = userList;        
        this.prefix = prefix;
        this.baseMainController = baseMainController;  
        this.maxRightListSize = maxRightListSize;      
        //this.baseChildController = baseChildController;        
    }
}