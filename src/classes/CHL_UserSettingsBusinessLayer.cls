/**
 * @description : CHL_UserSettingsBusinessLayer class is used to manage all the User settings i.e. Locale and languages related operations.
*/
public with sharing class CHL_UserSettingsBusinessLayer {
    /**
     * @description : This method will fetch all the available user locales and languages to display in portal. Added for US1165.
    */ 
    public static CHL_UserSettingsWrapper getUserSettings() {
        CHL_UserSettingsWrapper userLocaleWrapperObj = new  CHL_UserSettingsWrapper();

        List<CHL_Locale> localeList = new List<CHL_Locale>();
        Map<String, String> localeMap = getAllLocales();
        CHL_Locale localeObj;
        for (String localeKey : localeMap.keySet()) {
            localeObj = new CHL_Locale();
            localeObj.id = localeKey;
            localeObj.value = localeMap.get(localeKey);
            localeList.add(localeObj);
        }

        List<CHL_Language> languagesList = new List<CHL_Language>();
        Map<String, String> languageMap = getAllLanguages();
        CHL_Language languageObj;
        for (String languageKey : languageMap.keySet()) {
            languageObj = new CHL_Language();
            languageObj.id = languageKey;
            languageObj.value = languageMap.get(languageKey);
            languagesList.add(languageObj);
        }
        
        List<CHL_Currency> currencyList  = new List<CHL_Currency>();
        Map<String, String> currencyMap = getAllCurrencies();
        
        if(currencyMap != null){
            CHL_Currency currencyObj;
            for (String currencyKey : currencyMap.keySet()) {
                currencyObj = new CHL_Currency();
                currencyObj.id = currencyKey;
                currencyObj.value = currencyMap.get(currencyKey);
                currencyList.add(currencyObj);
            }
        }
        
        userLocaleWrapperObj.locales = localeList;
        userLocaleWrapperObj.languages =  languagesList;
        userLocaleWrapperObj.currencies = currencyList;
        system.debug('\n\n @@ check :: ' + JSON.serialize(userLocaleWrapperObj));
        return userLocaleWrapperObj;
    }

    /**
    * @description : Used to get information for all locales from user object .
    */
    public static Map<String, String> getAllLocales(){
        Map<String, String> localeMap = new Map<String, String>();
        Schema.PicklistEntry[] locales = Schema.SObjectType.User.fields.LocaleSidKey.PicklistValues;
        for (PicklistEntry locale : locales) {
            if(locale.isActive()) {
                localeMap.put(locale.getValue(), locale.getLabel());
            }
        }
        return localeMap;
    }
    
    /**
    * @description : Used to get information for all languages from user object .
    */
    public static Map<String, String> getAllLanguages(){
       
        Map<String,String> mapOfLang = new Map<String,String>();
       	String activeLanguage = CHL_OpptyStatusLogDataAccess.opptyStatusLogListGuestUser != null && !CHL_OpptyStatusLogDataAccess.opptyStatusLogListGuestUser.isEmpty() ? CHL_OpptyStatusLogDataAccess.opptyStatusLogListGuestUser[0].CHL_Active_Languages__c : '';
      	if(String.isNotBlank(activeLanguage)){
      		mapOfLang = CHL_Util.splitLanguages(new List<String>(CHL_Util.splitStages(activeLanguage)));
  		}	else{
      		mapOfLang.put('en_US','English');
      	}
        return mapOfLang;
    }

    /**
    * @description : Used to get logged-in user locale information.
    */
    public static CHL_Locale getCurrentUserLocale(){
        CHL_Locale locale = new CHL_Locale();
        Map<String, String> localeMap = getAllLocales();
        String userLocale = userinfo.getLocale();
		locale.id = userLocale.tolowerCase().replaceAll('_','-');		
        locale.value = localeMap.get(userLocale);
        system.debug('userLocaleWrapperObj :: ' +   JSON.serialize( locale));
        return  locale;
    }
    
    /**
    * @description : Used to get logged-in user language information.
    */
    public static CHL_Language getCurrentUserLanguage(){
        CHL_Language language = new CHL_Language();
        Map<String, String> languageMap = getAllLanguages();
        String userLanguage = UserInfo.getLanguage();
        language.id = userLanguage;
        language.value = languageMap.get(userLanguage);
        system.debug('\n\n userLocaleWrapperObj :: ' +   JSON.serialize( language));
        return  language;
    }
    
    /**
    * @description : Used to get logged-in user currency.
    */
    public static CHL_Currency getCurrentUserCurrency(){
        CHL_Currency currencyObj = new CHL_Currency();
        if(UserInfo.isMultiCurrencyOrganization()){
            Map<String, String> currencyMap = getAllCurrencies();
            String userCurrency = UserInfo.getDefaultCurrency();
            currencyObj.id = userCurrency;
            currencyObj.value = currencyMap.get(userCurrency);
            system.debug('\n\n userLocaleWrapperObj for currency :: ' +  JSON.serialize(currencyObj));
        }
        return  currencyObj;
    }

    /**
     * @description : This method will updated the user locale and language from portal. Added for US1165.
        inputValue : '{"locale": {"id": "ja","value": "Japanese"},"language" : {"id" : "zh_CN","value": "Chinese (Simplified)"}}}';
        inputValue : '{"locale": {"id": "fr_CH","value": "French (Switzerland)"},"language" : {"id" : "es","value": "Spanish"}}}';
    */  
    public static object updateUserSettings(string inputvalue){
        CHL_UserSettingsWrapper userSettingsObj = (CHL_UserSettingsWrapper)JSON.deserialize(inputvalue, CHL_UserSettingsWrapper.class);        
        setUserSettings(new Set<Id>{UserInfo.getUserId()}, userSettingsObj);
        return userSettingsObj;
    }

    /**
     * @description : Used as helper method for Updating user locale and language.  Added for US1165.
     * @param : Accepts Set of User Id, language and locale Id. 
    */
    public static void setUserSettings(Set<Id> userIdSet, CHL_UserSettingsWrapper usrSettingObj){
        if(userIdSet != null && !userIdSet.isEmpty() ){
            List<Id> userIdList =  new  List<Id>();
            userIdList.addAll(userIdSet);
            
            Set<String> userFieldSet = new Set<String>();
            
            List<User> userList = CHL_Util.getUserInformationById(userIdList);
            for(User usr : userList){
                if(usrSettingObj.language != null && usrSettingObj.language.id !=  null){
                    usr.LanguageLocaleKey = usrSettingObj.language.id;  
                    userFieldSet.add('LanguageLocaleKey');
                }
                if(usrSettingObj.locale != null && usrSettingObj.locale.id !=  null){
                    usr.LocaleSidKey = usrSettingObj.locale.id.replaceAll('-','_');
                    userFieldSet.add('LocaleSidKey'); 
                }
                
                if(UserInfo.isMultiCurrencyOrganization()){
                    if(usrSettingObj.userCurrency != null && usrSettingObj.userCurrency.id !=  null){
                        usr.put('DefaultCurrencyIsoCode' , usrSettingObj.userCurrency.id);
                        userFieldSet.add('DefaultCurrencyIsoCode'); 
                    }
                }
                usr.CHL_Use_Cookies_for_Channel__c = usrSettingObj.useCookies != null && usrSettingObj != null  ? usrSettingObj.useCookies : false;
                usr.CHL_Cookies_Timestamp__c = DateTime.now();
                userFieldSet.add('CHL_Use_Cookies_for_Channel__c');
                userFieldSet.add('CHL_Cookies_Timestamp__c');
            }
        
            system.debug('\n\n @@ userList to update:: ' + userList);
            List<String> userFieldList = new List<String>();
            userFieldList.addAll(userFieldSet);
            CSM_Util.checkCRUD_FLS(CSM_Constants.OBJ_USER, userFieldList, CSM_Constants.DML_OPERATION_UPDATE);
            update userList;   //Don't have UserData Access class.
            
        }
    } 
  
    /**
    * @description : Used to get information for all currency from user object .
    */
    public static Map<String, String> getAllCurrencies(){
        Map<String, String> currencyMap;
        if(UserInfo.isMultiCurrencyOrganization()){
            currencyMap = new Map<String, String>();
            Map<String, Schema.SObjectType> GlobalMap = Schema.getGlobalDescribe();
            Schema.DescribeSObjectResult obj = GlobalMap.get(CSM_Constants.OBJ_USER).getDescribe();
            Schema.DescribeFieldResult currencyIsoField = obj.Fields.getMap().get(CHL_Constants.OBJ_USER_FLD_CURRENCY_ISO).getDescribe();
            if(currencyIsoField != null){
                List<Schema.PicklistEntry> currencyIsoPickListVal  = currencyIsoField.getPicklistValues();
                for (PicklistEntry currencyUsr : currencyIsoPickListVal) {
                  if(currencyUsr.isActive()) {
                    currencyMap.put(currencyUsr.getValue(), currencyUsr.getLabel());
                  }
                }
            }
            system.debug('\n\n @@ currencyMap ::' + currencyMap);
            return currencyMap;
        } else {
            return null;
        }
    }
    
}