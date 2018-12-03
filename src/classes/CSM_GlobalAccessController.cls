/**
 * Created Date		: Nov 8, 2016
 * Developed By		: anilpilaka, Comity Designs, Inc.
 *
 * Function			: This class methods can be invoked by any extension package code for checking access control.
 * Support Email 	: 
 * Version			: 1.0
 *
 * Modification Log
 *
 * Developer Name			User Story				Date			Version 			Description
 *____________________________________________________________________________________________________
 *
 * anilpilaka			    US1700				Nov 8, 2016			1.0				Inital Version
 *
 */
global with sharing class CSM_GlobalAccessController {

    

    /**
	 * @description : Check if a given object has a specific field
     * @param : objName : object Name, fieldName : field Name from the object
     * @return : Boolen true/false , if the object as a specific field mentioned in the parameter
     *
     */
	
	global Static boolean hasField(String objName, String fieldName){
	   return CSM_AccessController.hasField(objName, fieldName);
	}
	    
	global Static List<String> returnNoPermissionFieldsNameList(String objName, String operationType, List<String> fieldNames){
	   return CSM_AccessController.getInstance().returnNoPermissionFieldsNameList(objName,operationType,fieldNames);
	}
	
	global Static boolean objectCrudCheck(String objName, String operationType){
	   return CSM_AccessController.getInstance().objectCrudCheck(objName, operationType);
	}
	
	global Static void objectCrudCheck(String objName, List<String> fieldList, String operationType){
	   CSM_Util.checkCRUD_FLS(objName, fieldList, operationType);
	}
	
}