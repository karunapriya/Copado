public virtual class CSM_CustomPaginator
{
	private List<SObject> resourcesList;
	private ApexPages.StandardSetController setController;
 /* Pagination */
    public Integer totalPages {get; set;}
    public Integer pageNumber {get; set;}
    public Integer pageSize {get; set;}

	/**
     * Returns the underlying ApexPages.StandardSetController object.
     */
    public virtual void initiateSetController(List<SObject> listOfSObject) 
    {
        setController = new ApexPages.StandardSetController(listOfSObject);
        
        // Check the set controller and assign the page size
        if (setController.getResultSize() > 0) 
        {
			if (setController.getRecords().size() > pageSize) 
				// sets the number of records in each page set 				
				setController.setPageSize(pageSize); 
			else
				// sets the number of records in each page set 				
				setController.setPageSize(setController.getRecords().size());
        }
       
    }
    
    public void initiateResourcesList(List<SObject> listOfSObject)
    {
    	resourcesList = new List<SObject>();
    	resourcesList = listOfSObject;
    }
    
    
 /* Method: getResults
     * Description: displays results to screen based on pagination sets 
     */
    public List<SObject> getResults() {
    	
        List<SObject> tempWrapper = new List<SObject>();
        if(setController != null)
        {
        	return (List<sObject>) setController.getRecords();	
        }
        else if (resourcesList !=null)
        {
	        Integer startIndex = (pageNumber-1) * pageSize;
	        Integer endIndex =  startIndex + pageSize;
	        for(Integer i=startIndex; i < endIndex && i < resourcesList.size(); i++){                
	    		tempWrapper.add(resourcesList[i]);
	        }
        }
        return tempWrapper;
    }
    
    /* Method: getTotalPages
    * Description: sets the total pages for pagination 
    */
   public Integer getTotalPages() {
                //resourcesList.size() / pageSize;
        Integer intTotalPages = 0;
        Integer resultSize = getResultSize();
        Integer oddRecordCount = Math.mod(resultSize, pageSize);
        intTotalPages = ((resultSize - oddRecordCount) / pageSize) + (oddRecordCount > 0 ? 1 : 0);
        return intTotalPages;
    }
    

    /* Pagination Navigation */ 
	public void first() {
		if(setController != null)
       	{ 
       		setController.first();
       		pageNumber = 1;
       	}
       	else if (resourcesList != null)
       	{
        	pageNumber = 1;
       	}
    }
    
    /*returns the last page of records*/
    public void last() {
        if(setController != null)
        {
        	setController.last();
        	pageNumber = getTotalPages();
        	
        }
        else if (resourcesList != null)
        {
        	pageNumber = getTotalPages();
        }
    }
    
    /*returns the previous page of records*/
    public void Previous() {
    	if(setController != null)
    	{
    		setController.previous();
    		if(pageNumber > 0)
            	pageNumber--;
    	}  
    	else if (resourcesList != null)
    	{   
        	if(pageNumber > 0)
            	pageNumber--;
    	}
    }
    
    /*returns the next page of records*/
	public void Next() {
    	if(setController != null)
    	{
    		setController.next();
    		if (pageNumber < totalPages)      
        		pageNumber++;
    	}
    	else if (resourcesList != null)
    	{
    		if (pageNumber < totalPages)      
        		pageNumber++;	
    	}
       
    }
    
    public Boolean getHasPrevious() {
    	boolean hasPrevious = false;
    	if(setController != null)
    	{
    		hasPrevious = setController.getHasPrevious();
    	}
    	else if(resourcesList != null)
    	{
	        if (pageNumber > 1)
	            hasPrevious = true;
    	}
    	return hasPrevious;
    }

    public Boolean getHasNext() {
    	boolean hasNext = false;
    	if(setController != null)
    	{
    		hasNext = setController.getHasNext();
    	}
    	else if (resourcesList != null)
    	{
        	if (pageNumber < totalPages)
            	hasNext = true;
    	}
    	return hasNext;
        
    }
    
    
	public Integer getResultSize() {
    	Integer intResultSize =0;
       	if(setController != null)
       	{
       		intResultSize = setController.getResultSize();
       	}
      	else if (resourcesList!= null)
      	{
       		intResultSize  = resourcesList.size();  
      	}
      	return intResultSize;
    }

    public Integer getPageCount() {
        return totalPages;
    }
    public void updatePages() {
    	//first(); 
        this.pageSize = pageSize;
        if(setController != null)
        {
        	setController.setPageSize(pageSize);
        }
        totalPages = getTotalPages();
        first();
    }
    
    /*Added as part of US314 to maintain the user on the page on which the user performed the delete*/
    public void updatePagesafterDelete(Integer currentPageNumber) {
        this.pageSize = pageSize;
        if(this.setController != null)
        {
        	this.setController.setPageSize(pageSize);
        }
        this.totalPages = this.getTotalPages();
        if(currentPageNumber > this.totalPages){
        	this.pageNumber = currentPageNumber - 1; 
        	this.setController.setpageNumber(this.pageNumber);
        } else {
        	this.pageNumber = currentPageNumber;    
        	this.setController.setpageNumber(this.pageNumber);
        }
    }
    
    //public virtual void savePageSize(){}
}