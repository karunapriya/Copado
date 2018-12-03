public with sharing class CHL_PortalGroupWrapper {
		
    	public Account partnerAccount {get; set;}
        public Boolean selected {get; set;}
        public User partnerUser {get;set;}
 		public CHL_PortalGroupWrapper(Account a,User u) {
            partnerAccount = a;
            partnerUser = u;
            selected = false;
        }
}