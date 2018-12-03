/**
* @description : CHL_UserSettingsWrapper class is to set input and output value for userSetting.
*/
public with sharing class CHL_UserSettingsWrapper {
		
		public List<CHL_Locale> locales {get;set;}
		public List<CHL_Language> languages {get;set;}
		public List<CHL_Currency> currencies {get;set;}
		
		public CHL_Locale locale {get;set;}
		public CHL_Language language {get;set;}	
		public CHL_Currency userCurrency {get;set;}
		public Boolean useCookies {get;set;}

}