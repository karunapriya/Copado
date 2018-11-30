public with sharing class CSM_FocusCategoriesGroupService {

    public static void cloneFocusCategory(List<CSM_Focus_Category_Column__c> newFocusCategoryColumnList) {
        Map<Id,Id> focusCategoryColumnIdMap = new Map<Id,Id>();
        List<String> focusCategoryColumnList = new List<String>();
        if (!newFocusCategoryColumnList.isEmpty()) {
            for (CSM_Focus_Category_Column__c fcc: newFocusCategoryColumnList) {
                focusCategoryColumnList.add(fcc.Focus_Category_Column_Old_Id__c);
                focusCategoryColumnIdMap.put(fcc.Focus_Category_Column_Old_Id__c, fcc.Id);
            }
            List<CSM_Focus_Category__c> focusCategoryList = CSM_FocusCategoriesGroupService.GetFocusCategoryList(focusCategoryColumnList);
            if (!focusCategoryList.isEmpty()) {
                List<CSM_Focus_Category__c> focusCategoryCloneList = new List<CSM_Focus_Category__c>();
                for (CSM_Focus_Category__c fc: focusCategoryList) {
                    CSM_Focus_Category__c focusCategory = fc.clone(false, false, false, false);
                    focusCategory.CSM_Focus_Category_Column__c = focusCategoryColumnIdMap.get(fc.CSM_Focus_Category_Column__c);
                    String name = Label.CSM_LBL_CLONE_PREFIX + ' ' + fc.Name;
                    focusCategory.Name = name.length() > 40 ? name.substring(0, 40) : name;
                    focusCategoryCloneList.add(focusCategory);
                }
                CSM_FocusCategoriesGroupDataAccess.insertFocusCategory(focusCategoryCloneList);
            }
        }
    }


    /**
     * @description returns GetFocusCategory List by doing query.
     * @param List<CSM_Focus_Category__c> , FocusCategory List.
     * @return List<CSM_Focus_Category__c> , FocusCategory records.
     */
    private static List<CSM_Focus_Category__c> GetFocusCategoryList(List<String> focusCategoryColumnIdList) {
        List<CSM_Focus_Category__c> FocusCategoryList = new List<CSM_Focus_Category__c>();
        if (!focusCategoryColumnIdList.isEmpty()) {
            CSM_QueryBuilder q = new CSM_QueryBuilder(CSM_Constants.OBJ_FC, '');
            FocusCategoryList = Database.Query(q.GetQueryByIdList(CSM_Constants.OBJ_FC_CATEGORY_COLUMN, focusCategoryColumnIdList));
        }
        return FocusCategoryList;
    }
}