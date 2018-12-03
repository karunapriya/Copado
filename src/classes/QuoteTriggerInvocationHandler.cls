global with sharing class QuoteTriggerInvocationHandler extends SS_FeatureInvocation.FeatureHandler{
    global override void featureInvocation(Object parameters){
		QuoteFxConversionHandler.validateObjectFieldsToUpdate(parameters);
	}
}