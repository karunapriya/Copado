global class REN_OLITriggerParams {
    global Map<ID, SObject> oldRecordsMap {get; set;}
    global Map<ID, SObject> newRecordsMap {get; set;}
    
    //Used within SE
    global Set<String> fieldToValidate {get; set;}
    global Set<String> missingFields {get; set;}
    global String allInvalidFieldsToUpdate{get; set;}
}