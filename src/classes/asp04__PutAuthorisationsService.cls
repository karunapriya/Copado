/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/PutAuthorisations/*')
global class PutAuthorisationsService {
    global PutAuthorisationsService() {

    }
    @HttpPost
    global static asp04.PutAuthorisationsService.PutAuthorisationsResponse PutAuthorisations(asp04.PutAuthorisationsService.PutAuthorisationsRequest request) {
        return null;
    }
global class PassThroughParameter {
    global String Key;
    global String Value;
    global PassThroughParameter() {

    }
}
global class PutAuthorisationRequestDetail {
    global String AccountName;
    global String AccountReference;
    global String AddressCity;
    global String AddressCountry;
    global String AddressPostalCode;
    global String AddressState;
    global String AddressStreet;
    global String AsperatoRepeatReference;
    global String CardType;
    global String CompanyName;
    global Boolean CPAGranted;
    global String CurrencyCode;
    global Date EffectiveDate;
    global String Email;
    global String ErrorCode;
    global Date ExpiryDate;
    global String FirstName;
    global String LanguageCode;
    global String LastName;
    global String MandateReference;
    global List<asp04.PutAuthorisationsService.PassThroughParameter> PassThroughParameters;
    global String PaymentFrequency;
    global String PaymentRoute;
    global String PhoneNumber;
    global String PSPRepeatToken;
    global Long RegularAmount;
    global String SalesforceId;
    global String Source;
    global String StatusDescription;
    global Boolean Success;
    global PutAuthorisationRequestDetail() {

    }
}
global class PutAuthorisationResponseDetail {
    global String ErrorMessage;
    global String SalesforceId;
    global Boolean Success;
    global PutAuthorisationResponseDetail() {

    }
}
global class PutAuthorisationsRequest {
    global List<asp04.PutAuthorisationsService.PutAuthorisationRequestDetail> PutAuthorisationRequestDetails;
    global PutAuthorisationsRequest() {

    }
}
global class PutAuthorisationsResponse {
    global String ErrorMessage;
    global List<asp04.PutAuthorisationsService.PutAuthorisationResponseDetail> PutAuthorisationResponseDetails;
    global Boolean Success;
    global PutAuthorisationsResponse() {

    }
}
}
