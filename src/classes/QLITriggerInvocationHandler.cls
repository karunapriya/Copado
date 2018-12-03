global with sharing class QLITriggerInvocationHandler extends SS_FeatureInvocation.FeatureHandler {
    
    global override void featureInvocation(Object parameters) {
        QuoteFxConversionHandler.validateObjectFieldsToUpdate(parameters);
    }
}