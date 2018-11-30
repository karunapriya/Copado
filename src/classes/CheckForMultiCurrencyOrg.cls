/**
* @author         Tanvi(tanvi@comitydesigns.com)
* @date           04.30.2015
* @description    CheckForMultiCurrencyOrg will return flag as true or false if Organization Multicurrency is ON or Off.
				  This class is mainly created to use in javascript code.	
*/
global class CheckForMultiCurrencyOrg {
	webService static boolean getIsMultiCurrencyOn() {
        return UserInfo.isMultiCurrencyOrganization();
   }
}