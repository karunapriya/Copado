public with sharing class CHL_AngularResponeWrapper {
    
    public string status{get;set;}
    public string errorMessage{get;set;}
    public boolean noChange{get { if(noChange== null) noChange=false; return noChange;}set;}
    public list<CHL_GridData> gridData{get;set;}
    public list<CHL_ColumnHeader> columnHeader{get;set;}
    public CHL_GridConfiguration gridConfiguration{get;set;}
    
    public class CHL_GridData{      
        public String recordId{get;set;}
        public boolean canEdit{get;set;}        
        public integer index{get;set;}
        public boolean updated{get;set;}
        public Map<String,CHL_RecordDetails> rowData; 
        public string pid; //This is to set Parent Id for all the objects that are children of Accounts, Opportunities. It is created mainly for Global Search
    }
    
    public class CHL_ColumnHeader{
        public String label{get;set;}
        public Boolean isDateCol{get;set;}
        public Boolean isSortable{get;set;}
        public String apiName{get;set;}
        public Boolean isSwitchable{get;set;}
        public string dataType{get;set;}
        public string url{get;set;}
        public string currencyCode{get;set;}
        public Boolean readOnly{get;set;}
        public Boolean isSimple{get;set;}
        public String cellView{get;set;}
        public string editor{get;set;}
        public Boolean remoteOptions{get;set;}
        public String optionsApiName{get;set;}
        public Boolean visible{get;set;}
        public List<CHL_ColumnOptions> options{get;set;}
    }
    
    public Class CHL_RecordDetails{
       public String value;
       public String lookupId;
       public string url{get;set;}
       public string currencyCode{get;set;}
       public boolean needsUpdate{get;set;}
    }
    
    public class CHL_ColumnOptions{
      public String value;
      public String lookupId;
    }
    
    public class CHL_GridExportConfig{
       public CHL_PDFConfig pdf {get;set;}
       public CHL_CSVConfig csv {get;set;}
    }
    
    public class CHL_PDFConfig{
       public String headerLabel {get;set;}
       public String pageSize {get;set;}
       public Integer maxGridWidth {get;set;}
    }
    
    public class CHL_CSVConfig{
       public String fileName {get;set;}
     }
    
    public class CHL_GridConfiguration{      
      public boolean exportPdf{get;set;}
      public boolean exportCsv{get;set;}        
      public boolean selection{get;set;}
      public boolean sorting{get;set;}
      public CHL_GridExportConfig exportConfig {get;set;}
    }
}