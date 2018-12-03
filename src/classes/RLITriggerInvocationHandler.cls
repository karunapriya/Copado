global with sharing class RLITriggerInvocationHandler extends SS_FeatureInvocation.FeatureHandler {
    
    global override void featureInvocation(Object parameters) {
        	RenewableLineItemHandlerHelper.validateFieldsUpdate(parameters);
    }
}