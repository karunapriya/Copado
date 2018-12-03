/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/PutMessages/*')
global class PutMessagesService {
    global PutMessagesService() {

    }
    @HttpPost
    global static asp04.PutMessagesService.PutMessagesResponse PutMessages(asp04.PutMessagesService.PutMessagesRequest request) {
        return null;
    }
global class PutMessageRequestDetail {
    global String Action;
    global String EventReference;
    global String MessageText;
    global String ReasonCode;
    global String Resource;
    global Boolean Success;
    global String TransactionReference;
    global PutMessageRequestDetail() {

    }
}
global class PutMessagesRequest {
    global List<asp04.PutMessagesService.PutMessageRequestDetail> Messages;
    global PutMessagesRequest() {

    }
}
global class PutMessagesResponse {
    global String ErrorMessage;
    global Boolean Success;
    global PutMessagesResponse() {

    }
}
}
