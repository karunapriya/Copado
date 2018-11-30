/**
 * Created Date		: Mar 2, 2017
 * Developed By		: Sheetal, Comity Designs, Inc.
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
 * admin					User Story				Mar 2, 2017			1.1					@description
 *
 */
public with sharing class CHL_QueryBuilderResponseWrapper {

    

    /**
	 * @description One or more lines that provide an overview of the method
     * @param paramName A description of what the parameter does, use multiple @param for multiple params
     * @return A description of the return value from the method
     * @example Example code usage. This will be wrapped in tags to preserve whitespace
     */
	public List<CHL_OppPredicates> oppPredicates {get; set;}
	
	public class CHL_OppPredicates {
		public String id {get; set;}
		public String value {get; set;}
		public String type {get; set;}
		public String url {get; set;}
		public String objectType {get; set;}
		public String apiName {get; set;}
		public Boolean isUsable {get; set;}
		public List<CHL_Operators> operators {get; set;}
		public List<CHL_Options> options {get; set;}
	}
	
	public class CHL_Operators {
		public String id {get; set;}
		public String value {get; set;}
	}
	
	public class CHL_Options {
		public String id {get; set;}
		public String name {get; set;}
	}
}