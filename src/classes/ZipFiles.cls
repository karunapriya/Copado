public class ZipFiles {
    // Zip file paths
	public List<String> paths {get;set;}
    // Generated zip file data (see receiveZipFile)
	public transient String zipFileData {get;set;}
	
	public ZipFiles()
	{
		// Info message to ask the user to wait (no real time progress messages yet)
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 
			'Zip processing for the attacments has started please wait, you will be redirected to the resulting Document once this is completed.'));
				
		// Use Attachment names as zip entry path names for this example
		List<Attachment> attachments = [select Name from Attachment where ParentId ='0Q0o0000000G2u1'];
		paths = new List<String>();
        for(Attachment attachment : attachments){
			paths.add(attachment.Name);			
        }
	}
    
	public PageReference receiveZipFile()
	{
        System.debug('In ReceiveFile');
		// Receive the generated zip file and store it (in this case as a Document)
		Document document = new Document();
		document.Name = 'ZippedFile.zip';
		document.FolderId = UserInfo.getUserId();
		document.Body = EncodingUtil.base64Decode(zipFileData);
		insert document;
		System.debug('Out ReceiveFile');
		return new PageReference('/servlet/servlet.FileDownload?file='+document.Id);
	}
    
	@RemoteAction
	public static String getZipFileEntry(String path, String state)
	{
		// Retrieve or generate the Base64 encoded data for each file path to be added to the zip
		Attachment attachment = [select Name, Body from Attachment where ParentId =:state and Name =:path];
		return EncodingUtil.base64Encode(attachment.body);
	}
}