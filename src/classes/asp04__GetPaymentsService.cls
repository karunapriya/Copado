/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/GetPayments/*')
global class GetPaymentsService {
    global GetPaymentsService() {

    }
    @HttpPost
    global static asp04.GetPaymentsService.GetPaymentsResponse GetPayments(asp04.GetPaymentsService.GetPaymentsRequest request) {
        return null;
    }
global class GetPaymentsRequest {
    global String RecordID;
    global List<asp04.GetPaymentsService.UrlParameter> UrlParameters;
    global GetPaymentsRequest() {

    }
}
global class GetPaymentsResponse {
    global String AddressCity;
    global String AddressCountry;
    global String AddressPostalCode;
    global String AddressState;
    global String AddressStreet;
    global Long Amount;
    global String AuthorisationID;
    global String CompanyName;
    global String CurrencyCode;
    global Date DueDate;
    global String Email;
    global String ErrorMessage;
    global String FirstName;
    global String LanguageCode;
    global String LastName;
    global List<asp04.GetPaymentsService.PassThroughParameter> PassThroughParameters;
    global String PaymentFrequency;
    global String PaymentRoute;
    global String PaymentScheduleID;
    global String PhoneNumber;
    global String SalesforceId;
    global Boolean Success;
    global String UrlCancel;
    global String UrlError;
    global String UrlExit;
    global Boolean UseHostedPage;
    global GetPaymentsResponse() {

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
