public with sharing class VishCompCtrl {

	public VishCompCtrl() {
		system.debug('Comp Ctrl');
	}
	
	public String vishStr {
		get {
			system.debug('vish Str get');
			return vishStr;
		}
		set {
			system.debug('vish Str get');
			vishStr = value;
		}
	}
}