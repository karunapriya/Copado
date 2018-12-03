/**
 * Created Date		: Mar 14, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
 *
 * Function			: Added this class as part of Code Refactor
 * Support Email 	: email
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Sheetal					US2155					Mar 14, 2017	1.1					Added as part of 709
 *
 */
public with sharing class CHL_GlobalSearchWrapper {
	public String id;
    public String type;
    public String name;
    public string pid;

    public CHL_GlobalSearchWrapper(sObject sObj, String objType, String ParentId) {
        if(sObj != null) {
            this.id = (String)sObj.get('Id');
            this.type = objType;
            if(objType == 'RQ') {
				this.name = (String)sObj.get('subject');
			} else if(objType == 'CT') {
				this.name = (String)sObj.get('LineItemNumber');
			} else {
				this.name = (String)sObj.get('Name');
			}
			this.pid = ParentId;
        } 
    }
}