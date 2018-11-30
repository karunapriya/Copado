public with sharing class CHL_MultiSelectListWrapper {
    public List<SelectOption> leftOptionList {get;set;}
    public List<SelectOption> rightOptionList {get;set;}
    public String leftListLable{get;set;}
    public String rightListLable{get;set;}
    public String leftToRghtfuncName {get;set;}
    public String rghtToLeftfuncName {get;set;}
    public String moveUpfuncName {get;set;}//Added for US1024
    public String moveDownfuncName {get;set;}//Added for US1024
    public String keyClassName {get;set;}
    public boolean isUpDownVisible {get;set;}
    public REN_BaseMainController baseMainController{get;set;}
    //public String leftToRghtName{get;set;}
    public Integer numOfDisabledOption{get;set;}
    
    public CHL_MultiSelectListWrapper(String keyClassName,String leftListLable, String rightListLable, List<String> leftList, List<String> rightList,
                                      String leftToRghtName,String rghtToLeftName,String moveUpName,String moveDownName,REN_BaseMainController baseMainController,boolean visibleUpDown,Integer numOfDisabledOption){
        this.leftListLable = leftListLable;
        this.rightListLable = rightListLable;
        this.leftOptionList = new List<SelectOption>();
        this.rightOptionList = new List<SelectOption>();
        this.leftToRghtfuncName = leftToRghtName;
        this.rghtToLeftfuncName = rghtToLeftName;
        this.moveUpfuncName = moveUpName;
        this.moveDownfuncName = moveDownName;
        this.keyClassName = keyClassName;
        this.isUpDownVisible = visibleUpDown;
        this.baseMainController = baseMainController;
        
        //These number of options will be disabled for selection and move up & down.
        this.numOfDisabledOption = numOfDisabledOption;
    
        Set <String> rightSelectedSet = new Set <String> ();        
        Integer i=1;
        if(rightList != null && !rightList.isEmpty()){
            rightSelectedSet.addAll(rightList);
            for(String op: rightList){
                if(String.isNotBlank(op)){
                    SelectOption so = new SelectOption(op, op,i<=numOfDisabledOption?true:false);
                    i++;                    
                    rightOptionList.add(so);
                }
            }
        }
        
        
        if(leftList != null && !leftList.isEmpty()){
            for(String op: leftList){
                if(!rightSelectedSet.contains(op)){
                    SelectOption so = new SelectOption(op, op);
                    leftOptionList.add(so);
                }
            }
        }
        
       
        if(rightOptionList.size() <= 0){
            SelectOption so = new SelectOption(CHL_Constants.STR_NONE, CHL_Constants.STR_NONE);
            rightOptionList.add(so);
        } else if (leftOptionList.size() <= 0){
            SelectOption so = new SelectOption(CHL_Constants.STR_NONE, CHL_Constants.STR_NONE);
            leftOptionList.add(so);
        }
    }
    
    //Move options from right to left
    public void addOptionsInLeft(List<String> selectedOptions){
        addOptionsInList(rightOptionList, leftOptionList, selectedOptions);
    }   
    
    //Move options from left to right
    public void addOptionsInRight(List<String> selectedOptions){
        addOptionsInList(leftOptionList, rightOptionList, selectedOptions);
        integer count=1;
        if(rightOptionList!=null &&rightOptionList.size()>0){
            for(SelectOption sOpt:rightOptionList){
                if(count<=numOfDisabledOption){
                    sOpt.setDisabled(true);
                }
                count++;
            }
        }
    }   
    
    //Get all options from right list
    public String getAllOptionsFromRight(){
        return getAllOptionsWithDelimeter(rightOptionList);
    }

    
    private void addOptionsInList(List<SelectOption> fromOptionList, List<SelectOption> toOptionList, List<String> shiftableList){
        system.debug('\n\n Called from addOptionsInList ::');
        Set<String> selectedSet = new Set<String> (shiftableList);
        for (Integer i = fromOptionList.size() - 1; i > -1; i--) {
            if (selectedSet.contains(fromOptionList[i].getValue())) {
                toOptionList.add(fromOptionList[i]);
                fromOptionList.remove(i);
            }
        }
        Set<String> toOptionSet = new Set<String>();
        for(SelectOption option : toOptionList){
            toOptionSet.add(option.getValue());
        }
        
        if(toOptionSet.contains(CHL_Constants.STR_NONE)){
            toOptionSet.remove(CHL_Constants.STR_NONE);
        }
        
        toOptionList.clear();
        for(String setToAdd : toOptionSet){
            SelectOption so = new SelectOption(setToAdd, setToAdd);
            toOptionList.add(so);
        }
        
        if (fromOptionList.size() <= 0){
            SelectOption so = new SelectOption(CHL_Constants.STR_NONE, CHL_Constants.STR_NONE);
            fromOptionList.add(so);
        }
        
    }

    private String getAllOptionsWithDelimeter(List<SelectOption> optionList){
        String allOptionWithDelimeter = '';
        for(SelectOption sOption : optionList){
            if(sOption.getvalue() != CHL_Constants.STR_NONE){
                allOptionWithDelimeter += sOption.getvalue() + ';' ;
            }
        }
        return allOptionWithDelimeter;
    }

    public void moveOptionUp(List<String> selectedOptions){
        system.debug('\n\n test');
        Set<String> selectOptionSet = new Set<String>();
        selectOptionSet.addall(selectedOptions);
        system.debug('\n\n @@ rightOptionList :: ' + rightOptionList);
        system.debug('\n\n @@ selectOptionSet :: ' + selectOptionSet);
        for(Integer i = 1; i < rightOptionList.size(); i++ ){
            system.debug('\n\n @@ rightOptionList[i] :: ' + rightOptionList[i].getValue());
            system.debug('\n\n @@ selectOptionSet[i-1] ::  ' + rightOptionList[i-1].getValue());
            if(i>numOfDisabledOption)
            if(selectOptionSet.contains(rightOptionList[i].getValue()) && !selectOptionSet.contains(rightOptionList[i-1].getValue())){
                system.debug('\n\n @@ inside if condtion  ::  ');
                SelectOption tempSelectOption = rightOptionList[i];
                rightOptionList[i] = rightOptionList[i-1];
                rightOptionList[i-1] = tempSelectOption;
            }
        }
    }   
    
    public void moveOptionDown(List<String> selectedOptions){
        Set<String> selectOptionSet = new Set<String>();
        selectOptionSet.addall(selectedOptions);
        for(Integer i = rightOptionList.size()-2; i >= 0 ; i--){
            if(selectOptionSet.contains(rightOptionList[i].getValue()) && !selectOptionSet.contains(rightOptionList[i+1].getValue())){
                SelectOption tempSelectOption = rightOptionList[i];
                rightOptionList[i] = rightOptionList[i+1];
                rightOptionList[i+1] = tempSelectOption;
            }
        }
    }
}