global with sharing class SS_FeatureInvocation {
	
	public interface IFeatureHandler {
		void featureInvocation(Object parameters);
	}
	
	global abstract class FeatureHandler implements IFeatureHandler {
		global virtual void featureInvocation(Object parameters) {}
		private void invoke(Object parameters) {
			this.featureInvocation(parameters);
		}
	}
	
	public void invoke(FeatureHandler handler, Object parameters) {
        handler.invoke(parameters);
    }
    
    global void invoke(String className, Object parameters) {
        Type typeObj = type.forName(className);
        Object handler = typeObj.newInstance();
        if (handler instanceof FeatureHandler) {
            invoke((FeatureHandler) handler, parameters);
        }
    }
    /** @param: nameSpace- this marameter should be blank ('') in case of local file's instance is required in Managed package. 
    */
    public void invoke(String nameSpace, String className, Object parameters) {
        Type typeObj = type.forName(nameSpace, className);
        Object handler = typeObj.newInstance();
        if (handler instanceof FeatureHandler) {
            invoke((FeatureHandler) handler, parameters);
        }
    }
}