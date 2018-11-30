public class ZipFilesServer {
    public ZipFilesServer(){
        // Info message to ask the user to wait (no real time progress messages yet)
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 
			'Zip processing for the attacments has started please wait, you will be redirected to the resulting Document once this is completed.'));
				
    }
	public void receiveZipFile()
	{
        System.debug('In ReceiveFile');
        Zippex testZippex = new Zippex();
        for(Attachment attachment : [select Name, Body from Attachment where ParentId ='0Q0o0000000G2u1']){
			testZippex.addFile(attachment.Name, attachment.body, null);			
        }
        Blob zipFileData = testZippex.getZipArchive();
        System.debug('In ReceiveFile');
		// Receive the generated zip file and store it (in this case as a Document)
		Document document = new Document();
		document.Name = 'ZippedFileServer.zip';
		document.FolderId = UserInfo.getUserId();
		document.Body = zipFileData;
		insert document;
		System.debug('Out ReceiveFile');
		//return new PageReference('/servlet/servlet.FileDownload?file='+document.Id);
	}
}