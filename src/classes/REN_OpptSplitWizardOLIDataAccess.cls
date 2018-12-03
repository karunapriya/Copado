/**
 * Created Date		: Nov 21, 2016
 * Developed By		: Aditya, Comity Designs, Inc.
 *
 * Function			: Data access for Opportuntiy split - Opportuntiy line items
 * Support Email 	: aditya@comitydesigns.com
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * Aditya					US1760					Nov 21, 2016	1.0					Initial development
 *
 */
public with sharing class REN_OpptSplitWizardOLIDataAccess {
	
	public static List<SObject> getDataUsingFieldSet( String objectName, List<Schema.FieldSetMember> fieldSetMemberList, Set<String> additionalFieldSet,String filterStr) {   
        Set<String> fsFieldSet = new Set<String>();
        Set<String> refrenceFieldSet = new Set<String>();
        String queryString = '';
        String nameSpace = CSM_Util.getNamespace();
        
        for(Schema.FieldSetMember fld :fieldSetMemberList){
            String fldStr = fld.getFieldPath();
            if (nameSpace!=null && nameSpace.length()>0){
                fldStr = fldStr.replace(nameSpace, '');
            }
            if(fld.getType().equals(Schema.DisplayType.REFERENCE) && !fld.getFieldPath().contains('.')){
                String fName = fld.getFieldPath().removeEndIgnoreCase('Id').replace('__c', '__r') + (fld.getFieldPath().contains('REN_Contract_Line_Item__c') ? '.LineItemNumber':'.Name' ); //****
                if(!refrenceFieldSet.contains(fName)){
                    queryString += ', ' + fName; 
                     refrenceFieldSet.add(fName);
                }
            }
            
			if(!refrenceFieldSet.contains(fld.getFieldPath())){                  
				if(fld.getType().equals(Schema.DisplayType.DATE) || fld.getType().equals(Schema.DisplayType.DOUBLE) ||
					fld.getType().equals(Schema.DisplayType.CURRENCY) || fld.getType().equals(Schema.DisplayType.DATETIME)){
					if (UserInfo.isMultiCurrencyOrganization() && fld.getType().equals(Schema.DisplayType.CURRENCY)){
						queryString += ', format(convertCurrency(' + fld.getFieldPath() + '))';
					} else {
						queryString += ', format(' + fld.getFieldPath() + ')';
					}
				}
				else {   
					queryString += ', ' + fld.getFieldPath();
				}
			} 
			system.debug('***'+fld);
			if(!fld.getFieldPath().contains('.')){
			    fsFieldSet.add(fldStr);
			}
			refrenceFieldSet.add(fldStr);
        }
		if(UserInfo.isMultiCurrencyOrganization() && !queryString.contains('CurrencyIsoCode')){
		    queryString += ', CurrencyIsoCode';
		    fsFieldSet.add('CurrencyIsoCode'); 
		}
		if(additionalFieldSet != null){
		    for(String s : additionalFieldSet){
		        if(!refrenceFieldSet.contains(s)){
		            fsFieldSet.add(s);
		            queryString += ','+ s;  
		        }
		    }
		}
        List<String> fsFieldList = new List<String>(fsFieldSet);
        
        CSM_Util.checkCRUD_FLS(objectName , fsFieldList, CSM_Constants.DML_OPERATION_READ);
        queryString = 'SELECT ' + queryString.removeStart(',') + ' FROM   ' + objectName + ' WHERE id != null ' + (String.isBlank(filterStr) ? '':(' AND (' + filterStr + ' )'));
        
        system.debug(fieldSetMemberList + '\n\n queryString in oopt split oli --- :: ' + queryString);
        List<SObject> sObjectList = Database.query(queryString);
        return sObjectList;
    }
}