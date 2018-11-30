public with sharing abstract class CSM_DialogBusinessLayer {
	
	protected CSM_DialogInputParams inputWrapper;
	public CSM_DialogBusinessLayer(CSM_DialogInputParams inputWrapper){
		this.inputWrapper = inputWrapper;
	}
	public abstract List<Map<String, String>> retrieveObjectWrapperList();
}