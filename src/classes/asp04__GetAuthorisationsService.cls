/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/GetAuthorisations/*')
global class GetAuthorisationsService {
    global GetAuthorisationsService() {

    }
    @HttpPost
    global static asp04.GetAuthorisationsService.GetAuthorisationsResponse GetAuthorisations(asp04.GetAuthorisationsService.GetAuthorisationsRequest request) {
        return null;
    }
global class GetAuthorisationsRequest {
    global String RecordID;
    global List<asp04.GetAuthorisationsService.UrlParameter> UrlParameters;
    global GetAuthorisationsRequest() {

    }
}
global class GetAuthorisationsResponse {
    global String AddressCity;
    global String AddressCountry;
    global String AddressPostalCode;
    global String AddressState;
    global String AddressStreet;
    global Long AuthorisationAmount;
    global String CompanyName;
    global Boolean CPAGranted;
    global String CurrencyCode;
    global String Email;
    global String ErrorMessage;
    global String FirstName;
    global String LanguageCode;
    global String LastName;
    global List<asp04.GetAuthorisationsService.PassThroughParameter> PassThroughParameters;
    global String PaymentRoute;
    global String PhoneNumber;
    global Boolean Success;
    global String UrlCancel;
    global String UrlError;
    global String UrlExit;
    global Boolean UseHostedPage;
    global GetAuthorisationsResponse() {

    }
}
global class PassThroughParameter {
    global Boolean IsDisplayOnly;
    global String Key;
    global String Value;
    global PassThroughParameter() {

    }
}
global class UrlParameter {
    global String Key;
    global String Value;
    global UrlParameter() {

    }
}
}
