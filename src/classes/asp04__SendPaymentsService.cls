/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SendPaymentsService implements asp04.ISendPaymentsService {
    global SendPaymentsService() {

    }
    global asp04.SendPaymentsService.SendPaymentResponse SendPayments(asp04.SendPaymentsService.SendPaymentRequest request) {
        return null;
    }
global class SendPaymentRequest {
    global String companyRef;
    global Boolean isSandbox;
    global List<asp04.SendPaymentsService.SendPaymentRequestDetail> recurringPayments;
    global SendPaymentRequest() {

    }
}
global class SendPaymentRequestDetail {
    global Long amount;
    global String crossReference;
    global Date dueDate;
    global String frequency;
    global String orderId;
    global String paymentCurrency;
    global String recordId;
    global String type;
    global SendPaymentRequestDetail() {

    }
}
global class SendPaymentResponse {
    global List<asp04.SendPaymentsService.SendPaymentResponseDetail> responses;
    global SendPaymentResponse() {

    }
}
global class SendPaymentResponseDetail {
    global String error;
    global Id recordId;
    global Boolean success;
    global SendPaymentResponseDetail() {

    }
}
}
