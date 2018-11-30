public with sharing class REN_CurrencyExchangeRateDataAccess {
	public static final boolean IS_ACM_ENABLED = Schema.getGlobalDescribe().containsKey('DatedConversionRate');
	private static List<sObject> datedConversionRateList = null;
	private static Map<String, Decimal> ACM_CONVERSION_RATE_MAP = new Map<String, Decimal>();
	private static Map<String, Decimal> STATIC_CONVERSION_RATE_MAP = new Map<String, Decimal>();

	/**
	 * @description Get converted currency based on ACM exchange rate. If date is not defined in ACM, it will be converted based on static exchange rate.
	 * @param currencyName currency ISO code Name
	 * @return Decimal converson rate
	 * @example CurrencyExchangeRateDataAccess.acmCurrencyConversion(100.50, 'USD', 'INR', dateTypeField)
	 */
	public static Decimal acmCurrencyConversion(Decimal amount, String fromCurrency, String toCurrency, Date dateTypeField){
		Decimal returnAmt = amount;
		if ((UserInfo.isMultiCurrencyOrganization() || Test.isRunningTest() ) && amount != null && amount != 0 &&  fromCurrency != toCurrency){
			Decimal fromCurrencyExchangeRate = getAcmOrStaticRate(fromCurrency, dateTypeField);
			Decimal toCurrencyExchangeRate = getAcmOrStaticRate(toCurrency, dateTypeField);
			returnAmt = amount * (toCurrencyExchangeRate / fromCurrencyExchangeRate);
		}
		return returnAmt;
	}

	/**
	 * @description Get converted currency based on static exchange rate.
	 * @param currencyName currency ISO code Name
	 * @return Decimal converson rate
	 * @example CurrencyExchangeRateDataAccess.staticCurrencyConversion(100.50, 'USD', 'INR')
	 */
	public static Decimal staticCurrencyConversion(Decimal amount, String fromCurrency, String toCurrency){
		Decimal returnAmt = amount;
		if ((UserInfo.isMultiCurrencyOrganization() || Test.isRunningTest()) && amount != null && amount != 0 &&  fromCurrency != toCurrency){
			Decimal fromCurrencyExchangeRate = getStaticExchangeRate(fromCurrency);
			Decimal toCurrencyExchangeRate = getStaticExchangeRate(toCurrency);
			returnAmt = amount * (toCurrencyExchangeRate / fromCurrencyExchangeRate);
		}
		return returnAmt;
	}


	/**
	 * @description Get ACM exchange rate. If date is not defined in ACM, it will return static exchange rate.
	 * @param currencyName currency ISO code Name
	 * @return Decimal converson rate
	 * @example CurrencyExchangeRateDataAccess.getAcmOrStaticRate('USD', dateTypeField)
	 */
	public static Decimal getAcmOrStaticRate(String currencyName, Date dateTypeField){
		Decimal returnValue = 1;
		String key = null;
		if(!UserInfo.isMultiCurrencyOrganization() && !Test.isRunningTest()){
			return returnValue;
		}else if(dateTypeField == null){
			key = currencyName;
			if(!ACM_CONVERSION_RATE_MAP.containsKey(key)){
				returnValue = getStaticExchangeRate(currencyName);
				ACM_CONVERSION_RATE_MAP.put(key, returnValue); // First time find, add it into Map
			}
		}else if(dateTypeField != null && String.isNotBlank(currencyName)){
			key = currencyName +': '+ String.valueOf(dateTypeField);
			if(!ACM_CONVERSION_RATE_MAP.containsKey(key)){
				boolean isExchangeRateFound = false;
				if(datedConversionRateList == null){
					datedConversionRateList = getDatedConversionRateList();
				}
				for(SObject sObj: datedConversionRateList){
					if((String) sObj.get('IsoCode') == currencyName){
						if( dateTypeField >= (Date) sObj.get('StartDate') && dateTypeField < (Date) sObj.get('NextStartDate')){
							isExchangeRateFound = true;
							returnValue = (Decimal)sObj.get('conversionrate');
							break;
						}
					}
				}
				if(!isExchangeRateFound){
					returnValue = getStaticExchangeRate(currencyName);
				}
				ACM_CONVERSION_RATE_MAP.put(key, returnValue); // First time find, add it into Map
			}
		}
		returnValue = ACM_CONVERSION_RATE_MAP.get(key);
		return returnValue;
	}

	/**
	 * @description Get static exchange rate.
	 * @param currencyName currency ISO code Name
	 * @return Decimal converson rate
	 * @example CurrencyExchangeRateDataAccess.getStaticExchangeRate('USD')
	 */
	public static decimal getStaticExchangeRate(String currencyName){
		getConversionRateMap();
		Decimal exchangeRate = STATIC_CONVERSION_RATE_MAP.get(currencyName);
		if (exchangeRate == null){
			exchangeRate = 1;
		}
		return exchangeRate;
	}

	private static Map<String, Decimal> getConversionRateMap(){
		if(UserInfo.isMultiCurrencyOrganization() && STATIC_CONVERSION_RATE_MAP.isEmpty()){
			//CSM_Util.checkCRUD_FLS('currencytype', new List<String>{'conversionrate', 'isocode'}, CSM_Constants.DML_OPERATION_READ);
			String querystring = 'SELECT conversionrate, isocode, IsCorporate FROM currencytype LIMIT 2000';
			List<SObject> currencylst = Database.query(queryString);
			for(SObject s: currencylst){
				STATIC_CONVERSION_RATE_MAP.put((String)s.get('isocode'), (Decimal)s.get('conversionrate'));
			}
		}
		return STATIC_CONVERSION_RATE_MAP;
	}

	private static List<sObject> getDatedConversionRateList() {
		List<sObject> returnList;
		if(REN_CurrencyExchangeRateDataAccess.IS_ACM_ENABLED && datedConversionRateList == null){
			List<String> fieldList = new List<String> {'ConversionRate','IsoCode','NextStartDate','StartDate'};
			String queryString = 'Select ' + String.join(fieldList, ',') + ' FROM DatedConversionRate LIMIT 5000'; 
			system.debug('\n\n~~~~ queryString:' + queryString);
			returnList = Database.query(queryString);
		}else{
			returnList = new List<sObject>();
		}
		return returnList;
		
	}

}