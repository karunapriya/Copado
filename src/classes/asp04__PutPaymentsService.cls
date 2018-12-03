/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/PutPayments/*')
global class PutPaymentsService {
    global PutPaymentsService() {

    }
    @HttpPost
    global static asp04.PutPaymentsService.PutPaymentsResponse PutPayments(asp04.PutPaymentsService.PutPaymentsRequest request) {
        return null;
    }
global class PassThroughParameter {
    global String Key;
    global String Value;
    global PassThroughParameter() {

    }
}
global class PutPaymentRequestDetail {
    global String AccountName;
    global String AccountReference;
    global String AddressCity;
    global String AddressCountry;
    global String AddressPostalCode;
    global String AddressState;
    global String AddressStreet;
    global Long Amount;
    global String AsperatoReference;
    global String AsperatoRepeatReference;
    global String AuthorisationID;
    global String CardType;
    global String CompanyName;
    global String CurrencyCode;
    global String Email;
    global String ErrorCode;
    global String FirstName;
    global String LanguageCode;
    global String LastName;
    global List<asp04.PutPaymentsService.PassThroughParameter> PassThroughParameters;
    global Date PaymentDate;
    global String PaymentRoute;
    global String PaymentScheduleID;
    global String PhoneNumber;
    global String PSPReference;
    global String PSPRepeatToken;
    global String SalesforceId;
    global String Source;
    global String StatusDescription;
    global Boolean Success;
    global PutPaymentRequestDetail() {

    }
}
global class PutPaymentResponseDetail {
    global String ErrorMessage;
    global String SalesforceId;
    global Boolean Success;
    global PutPaymentResponseDetail() {

    }
}
global class PutPaymentsRequest {
    global List<asp04.PutPaymentsService.PutPaymentRequestDetail> PutPaymentRequestDetails;
    global PutPaymentsRequest() {

    }
}
global class PutPaymentsResponse {
    global String ErrorMessage;
    global List<asp04.PutPaymentsService.PutPaymentResponseDetail> PutPaymentResponseDetails;
    global Boolean Success;
    global PutPaymentsResponse() {

    }
}
}
