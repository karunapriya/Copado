/**
* @description  CHL_UserSettingsCompCtrl class is used to manage user related settings i.e. user language.
*/
public with sharing class CHL_UserSettingsCompCtrl {
	public String selectedLanguage{get; set;}
	public List<SelectOption> userLanguageList{get; set;}
    
 	public CHL_UserSettingsCompCtrl(){ 
 		Set<String> languageToHideSet = getHidenLanguageSet();  
 		userLanguageList = new List<SelectOption>();
		Map<String, String> userLanguageMap = CHL_UserSettingsBusinessLayer.getAllLanguages();
		for(String languageKey : userLanguageMap.keySet()){
			if(!languageToHideSet.contains(languageKey)){
				userLanguageList.add(new SelectOption(languageKey,userLanguageMap.get(languageKey)));
			}
		}
		selectedLanguage = ApexPages.currentPage().getParameters().get('lang');
 	} 
 	
 	/**
	 * @description : This method will set all the language which is hidden from user.
	*/ 
 	public Set<String> getHidenLanguageSet(){
 		Set<String> languageToHideSet = new Set<String>();
 		//TO DO: language to be added in set.
 		return languageToHideSet;
 	} 

}