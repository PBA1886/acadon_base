codeunit 5282623 "ACA File Share API"
{
    // Based on Codeunit BlobStorageAPI
    // See: https://docs.microsoft.com/en-US/rest/api/storageservices/file-service-rest-api

    // #region (GET) List Shares

    /// <summary>
    /// List all Shares in specific Storage Account and outputs the result to the user
    /// see: https://docs.microsoft.com/en-US/rest/api/storageservices/list-shares
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure ListShares(var RequestObject: Codeunit "ACA Request Object")
    begin
        ListShares(RequestObject, true);
    end;

    /// <summary>
    /// List all Shares in specific Storage Account
    /// see: https://docs.microsoft.com/en-US/rest/api/storageservices/list-shares
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListShares(var RequestObject: Codeunit "ACA Request Object"; ShowOutput: Boolean)
    var
        FileShare: Record "ACA Azure File Share";
    begin
        ListShares(RequestObject, FileShare, ShowOutput);
    end;

    /// <summary>
    /// List all Shares in specific Storage Account
    /// see: https://docs.microsoft.com/en-US/rest/api/storageservices/list-shares
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="FileShare">Collection of the result (temporary record).</param>
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListShares(var RequestObject: Codeunit "ACA Request Object"; var FileShare: Record "ACA Azure File Share"; ShowOutput: Boolean)
    var
        WebRequestHelper: Codeunit "ACA Web Request Helper";
        HelperLibrary: Codeunit "ACA Helper Library";
        Operation: Enum "ACA Blob Storage Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        RequestObject.SetOperation(Operation::ListShares);

        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error

        NodeList := HelperLibrary.CreateFileShareNodeListFromResponse(ResponseText);
        FileShare.SetBaseInfos(RequestObject);
        HelperLibrary.FileShareNodeListTotempRecord(NodeList, FileShare);
        if ShowOutput then
            HelperLibrary.ShowTempRecordLookup(FileShare);
    end;
    // #endregion

    // #region (GET) ListFiles
    /// <summary>
    /// Lists the Blobs in a specific container and outputs the result to the user
    /// see: https://docs.microsoft.com/de-de/rest/api/storageservices/list-directories-and-files
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure ListFiles(var RequestObject: Codeunit "ACA Request Object")
    begin
        ListFiles(RequestObject, true);
    end;

    /// <summary>
    /// Lists the Blobs in a specific container
    /// see: https://docs.microsoft.com/de-de/rest/api/storageservices/list-directories-and-files
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListFiles(var RequestObject: Codeunit "ACA Request Object"; ShowOutput: Boolean)
    var
        FileShareContent: Record "ACA Azure File Share Content";
    begin
        ListFiles(RequestObject, FileShareContent, ShowOutput);
    end;

    /// <summary>
    /// Lists the Blobs in a specific container
    /// see: https://docs.microsoft.com/de-de/rest/api/storageservices/list-directories-and-files
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="FileShareContent">Collection of the result (temporary record).</param>
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListFiles(var RequestObject: Codeunit "ACA Request Object"; var FileShareContent: Record "ACA Azure File Share Content"; ShowOutput: Boolean)
    var
        HelperLibrary: Codeunit "ACA Helper Library";
        WebRequestHelper: Codeunit "ACA Web Request Helper";
        Operation: Enum "ACA Blob Storage Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        RequestObject.SetOperation(Operation::ListFileShareContent);

        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error

        NodeList := HelperLibrary.CreateFileNodeListFromResponse(ResponseText);
        FileShareContent.SetBaseInfos(RequestObject);
        HelperLibrary.BlobNodeListToTempRecord(NodeList, FileShareContent);
        if ShowOutput then
            HelperLibrary.ShowTempRecordLookup(FileShareContent);
    end;
    // #endregion (GET) ListFiles

    // #region (GET) ListDirectories
    /// <summary>
    /// Lists the Blobs in a specific container and outputs the result to the user
    /// see: https://docs.microsoft.com/de-de/rest/api/storageservices/list-directories-and-files
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    procedure ListDirectories(var RequestObject: Codeunit "ACA Request Object")
    begin
        ListDirectories(RequestObject, true);
    end;

    /// <summary>
    /// Lists the Blobs in a specific container
    /// see: https://docs.microsoft.com/de-de/rest/api/storageservices/list-directories-and-files
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListDirectories(var RequestObject: Codeunit "ACA Request Object"; ShowOutput: Boolean)
    var
        FileShareContent: Record "ACA Azure File Share Content";
    begin
        ListDirectories(RequestObject, FileShareContent, ShowOutput);
    end;

    /// <summary>
    /// Lists the Blobs in a specific container
    /// see: https://docs.microsoft.com/de-de/rest/api/storageservices/list-directories-and-files
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>    
    /// <param name="FileShareContent">Collection of the result (temporary record).</param>
    /// <param name="ShowOutput">Determines if the result should be shown as a Page to the user.</param>
    procedure ListDirectories(var RequestObject: Codeunit "ACA Request Object"; var FileShareContent: Record "ACA Azure File Share Content"; ShowOutput: Boolean)
    var
        HelperLibrary: Codeunit "ACA Helper Library";
        WebRequestHelper: Codeunit "ACA Web Request Helper";
        Operation: Enum "ACA Blob Storage Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        RequestObject.SetOperation(Operation::ListFileShareContent);

        WebRequestHelper.GetResponseAsText(RequestObject, ResponseText); // might throw error

        NodeList := HelperLibrary.CreateDirectoryNodeListFromResponse(ResponseText);
        FileShareContent.SetBaseInfos(RequestObject);
        HelperLibrary.BlobNodeListToTempRecord(NodeList, FileShareContent);
        if ShowOutput then
            HelperLibrary.ShowTempRecordLookup(FileShareContent);
    end;
    // #endregion (GET) ListDirectories

    // #region (GET) Get File from Share
    /// <summary>
    /// Downloads (GET) a Blob as a File from a Share
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-file
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure DownloadBlobAsFile(var RequestObject: Codeunit "ACA Request Object")
    var
        BlobName: Text;
        TargetStream: InStream;
    begin
        DownloadBlobAsStream(RequestObject, TargetStream);
        BlobName := RequestObject.GetBlobName();
        DownloadFromStream(TargetStream, '', '', '', BlobName);
    end;

    /// <summary>
    /// Downloads (GET) a Blob as a InStream from a Share
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="TargetStream">The result InStream containg the content of the Blob.</param>
    procedure DownloadBlobAsStream(var RequestObject: Codeunit "ACA Request Object"; var TargetStream: InStream)
    var
        WebRequestHelper: Codeunit "ACA Web Request Helper";
        Operation: Enum "ACA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::GetFile);
        WebRequestHelper.GetResponseAsStream(RequestObject, TargetStream);
    end;

    /// <summary>
    /// Downloads (GET) a Blob as Text from a Container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="TargetText">The result Text containg the content of the Blob.</param>
    procedure DownloadBlobAsText(var RequestObject: Codeunit "ACA Request Object"; var TargetText: Text)
    var
        WebRequestHelper: Codeunit "ACA Web Request Helper";
        Operation: Enum "ACA Blob Storage Operation";
    begin
        RequestObject.SetOperation(Operation::GetFile);
        WebRequestHelper.GetResponseAsText(RequestObject, TargetText);
    end;
    // #endregion

    // #region (PUT) Create Directory
    /// <summary>
    /// Creates a new Directory in the File Share
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-directory
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    procedure CreateDirectory(var RequestObject: Codeunit "ACA Request Object")
    var
        WebRequestHelper: Codeunit "ACA Web Request Helper";
        Operation: Enum "ACA Blob Storage Operation";
        CreateDirectoryOperationNotSuccessfulErr: Label 'Could not create directory %1.', Comment = '%1 = Directory Name';
    begin
        RequestObject.SetOperation(Operation::CreateDirectory);
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(CreateDirectoryOperationNotSuccessfulErr, RequestObject.GetContainerName()));
    end;
    // #endregion

    // #region (PUT) Copy File
    /// <summary>
    /// The Copy File operation copies a File to a destination within the storage account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-file
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="SourceName">Specifies the name of the source blob or file.</param>
    procedure CopyFile(var RequestObject: Codeunit "ACA Request Object"; SourceName: Text)
    var
        LeaseId: Guid;
    begin
        CopyFile(RequestObject, SourceName, LeaseId);
    end;

    /// <summary>
    /// The Copy Blob operation copies a File to a destination within the storage account.
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-file
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="SourceName">Specifies the name of the source blob or file.</param>
    /// <param name="LeaseId">Required if the destination blob has an active lease. The lease ID specified must match the lease ID of the destination blob.</param>
    procedure CopyFile(var RequestObject: Codeunit "ACA Request Object"; SourceName: Text; LeaseId: Guid)
    var
        WebRequestHelper: Codeunit "ACA Web Request Helper";
        Operation: Enum "ACA Blob Storage Operation";
        CopyOperationNotSuccessfulErr: Label 'Could not copy %1 to %2.', Comment = '%1 = Source, %2 = Destination';
    begin
        RequestObject.SetOperation(Operation::CopyFile);
        RequestObject.SetCopySourceNameHeader(SourceName);
        if not IsNullGuid(LeaseId) then
            RequestObject.SetLeaseIdHeader(LeaseId);
        WebRequestHelper.PutOperation(RequestObject, StrSubstNo(CopyOperationNotSuccessfulErr, SourceName, RequestObject.ConstructUri()));
    end;
    // #endregion (PUT) Copy Blob

    procedure DeleteFileFromShare(var RequestObject: Codeunit "ACA Request Object")
    var
        WebRequestHelper: Codeunit "ACA Web Request Helper";
        Operation: Enum "ACA Blob Storage Operation";
        DeleteFileOperationNotSuccessfulErr: Label 'Could not delete file %1 in share %2.', Comment = '%1 = File Name; %2 = Share Name';
    begin
        RequestObject.SetOperation(Operation::DeleteFile);
        WebRequestHelper.DeleteOperation(RequestObject, StrSubstNo(DeleteFileOperationNotSuccessfulErr, RequestObject.GetBlobName(), RequestObject.GetContainerName()));
    end;

    // #region (PUT) Upload Blob into File Share
    /// <summary>
    /// Uploads (PUT) the content of an InStream to a File Share
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-file
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="BlobName">The Name of the Blob to Upload.</param>
    /// <param name="SourceStream">The Content of the Blob as InStream.</param>
    procedure UploadBlobIntoContainerStream(var RequestObject: Codeunit "ACA Request Object"; BlobName: Text; var SourceStream: InStream)
    var
        SourceContent: Variant;
    begin
        SourceContent := SourceStream;
        RequestObject.SetBlobName(BlobName);
        UploadBlobIntoContainer(RequestObject, SourceContent);
    end;

    /// <summary>
    /// Uploads (PUT) the content of a Text-Variable to a Container
    /// see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-file
    /// </summary>
    /// <param name="RequestObject">A Request Object containing the necessary parameters for the request.</param>
    /// <param name="BlobName">The Name of the Blob to Upload.</param>
    /// <param name="SourceText">The Content of the Blob as Text.</param>
    procedure UploadBlobIntoContainerText(var RequestObject: Codeunit "ACA Request Object"; BlobName: Text; SourceText: Text)
    var
        SourceContent: Variant;
    begin
        SourceContent := SourceText;
        RequestObject.SetBlobName(BlobName);
        UploadBlobIntoContainer(RequestObject, SourceContent);
    end;

    local procedure UploadBlobIntoContainer(var RequestObject: Codeunit "ACA Request Object"; var SourceContent: Variant)
    var
        WebRequestHelper: Codeunit "ACA Web Request Helper";
        Operation: Enum "ACA Blob Storage Operation";
        Content: HttpContent;
        EmptyContent: HttpContent;
        ContentLength: Integer;
        UploadBlobOperationNotSuccessfulErr: Label 'Could not upload %1 to %2', Comment = '%1 = File Name; %2 = Share';
        CreateFileOperationNotSuccessfulErr: Label 'Could not create file %1', Comment = '%1 = File Name';
    begin
        WebRequestHelper.SetContent(Content, SourceContent);
        ContentLength := WebRequestHelper.GetContentLength(SourceContent);

        // Create File
        RequestObject.SetOperation(Operation::CreateFile);
        WebRequestHelper.AddEmptyContentHeader(EmptyContent, RequestObject, ContentLength);
        WebRequestHelper.PutOperation(RequestObject, EmptyContent, StrSubstNo(CreateFileOperationNotSuccessfulErr, RequestObject.GetBlobName()));

        // Put Range
        RequestObject.ClearHeaders();
        RequestObject.SetOperation(Operation::PutRange);
        WebRequestHelper.AddFileToContentHeader(Content, RequestObject, ContentLength);
        WebRequestHelper.PutOperation(RequestObject, Content, StrSubstNo(UploadBlobOperationNotSuccessfulErr, RequestObject.GetBlobName(), RequestObject.GetContainerName()));
    end;
    // #endregion
}
