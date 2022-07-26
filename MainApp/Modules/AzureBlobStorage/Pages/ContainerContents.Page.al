// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 5282624 "ACA Container Contents"
{
    Caption = 'Container Contents';
    PageType = List;
    SourceTable = "ACA Container Content";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                IndentationColumn = Rec.Level;
                IndentationControls = Name;
                field("Parent Directory"; Rec."Parent Directory")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Parent Directory of the Container.';
                    Visible = false;
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    ToolTip = 'The count of parent directories.';
                    Visible = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'The Container name.';

                    trigger OnAssistEdit()
                    begin
                        Rec.DownloadBlob(OriginalRequestObject);
                    end;
                }
                field("Creation-Time"; Rec."Creation-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'The datetime when the Container was created.';
                }
                field("Last-Modified"; Rec."Last-Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the last datetime when the container was edited.';
                }
                field("Content-Length"; Rec."Content-Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Content-Length of the Container.';
                    BlankZero = true;
                }
                field("Content-Type"; Rec."Content-Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Content-Type of the Container.';
                }
                field(BlobType; Rec.BlobType)
                {
                    ApplicationArea = All;
                    ToolTip = 'The BlobType of the Container.';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(ShowEntryDetails)
            {
                Caption = 'Show Entry Details';
                ToolTip = 'Shows details that are stored in the field XML Value.';
                Image = ViewDetails;
                ApplicationArea = All;

                trigger OnAction()
                var
                    InStr: InStream;
                    OuterXml: Text;
                begin
                    if not Rec."XML Value".HasValue then
                        exit;

                    Rec.CalcFields("XML Value");
                    Rec."XML Value".CreateInStream(InStr);
                    InStr.Read(OuterXml);
                    Message(OuterXml);
                end;
            }

            action(GetBlobPropertiesAction)
            {
                Caption = 'Get Properties';
                ToolTip = 'The Get Blob Service Properties operation gets the properties of a storage account''s Blob service, including properties for Storage Analytics and CORS (Cross-Origin Resource Sharing) rules.';
                Image = ViewDetails;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    GetBlobProperties(Rec.Name);
                end;
            }

            action(SetBlobPropertiesAction)
            {
                Caption = 'Set Properties (Dummy)';
                ToolTip = 'The Set Properties operation sets system properties on the blob.';
                Image = ViewDetails;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    SetBlobProperties(Rec.Name);
                end;
            }

            action(GetBlobMetadataAction)
            {
                Caption = 'Get Metadata';
                ToolTip = 'The Get Metadata operation returns all user-defined metadata for the specified blob.';
                Image = ViewDetails;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    GetBlobMetadata(Rec.Name);
                end;
            }

            action(SetBlobMetadataAction)
            {
                Caption = 'Set Metadata';
                ToolTip = 'The Set Metadata operation sets user-defined metadata for the specified blob as one or more name-value pairs.';
                Image = ViewDetails;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    SetBlobMetadata(Rec.Name);
                end;
            }

            action(CopyBlobAction)
            {
                Caption = 'Copy Blob';
                ToolTip = 'The Copy Blob operation copies a blob to a destination within the storage account.';
                Image = ViewDetails;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    CopyBlob(Rec.Name);
                end;
            }

            action(AbortCopyBlobAction)
            {
                Caption = 'Abort Copy Blob';
                ToolTip = 'The Abort Copy Blob operation aborts a pending Copy Blob operation.';
                Image = ViewDetails;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    if IsNullGuid(GlobalCopyId) then
                        Error('You need to initiate a "Copy Blob"-action first');
                    AbortCopyBlob(GlobalCopyId, GlobalLastDestContainer, GlobalLastDestBlobName);
                end;
            }

            action(AcquireLeaseBlob)
            {
                Caption = 'Acquire Lease';
                ToolTip = 'Establishes a lock on a Blob for delete operations.';
                Image = ViewDetails;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    BlobAcquireLease(Rec.Name);
                end;
            }
            action(RenewLeaseBlob)
            {
                Caption = 'Renew Lease';
                ToolTip = 'Renews a lock on a Blob to keep it locked again for the same amount of time as before.';
                Image = ViewDetails;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    BlobRenewLease(Rec.Name, GlobalLeaseId);
                end;
            }
            action(ReleaseLeaseBlob)
            {
                Caption = 'Release Lease';
                ToolTip = 'Releases a lock on a Blob if it is no longer needed so that another client may immediately acquire a lease against the container.';
                Image = ViewDetails;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    BlobReleaseLease(Rec.Name, GlobalLeaseId);
                end;
            }
        }
    }
    var
        OriginalRequestObject: Codeunit "ACA Request Object";
        GlobalLeaseId: Guid;
        GlobalCopyId: Guid;
        GlobalLastDestContainer: Text;
        GlobalLastDestBlobName: Text;

    procedure AddEntry(ContainerContent: Record "ACA Container Content")
    begin
        Rec.TransferFields(ContainerContent);
        Rec.Insert();
    end;

    procedure InitializeFromTempRec(var ContainerContent: Record "ACA Container Content")
    begin
        if not ContainerContent.FindSet(false, false) then
            exit;

        ContainerContent.GetRequestObject(OriginalRequestObject);
        repeat
            ContainerContent.CalcFields("XML Value");
            Rec.TransferFields(ContainerContent);
            Rec.Insert();
        until ContainerContent.Next() = 0;
    end;

    local procedure CopyBlob(BlobName: Text)
    var
        API: Codeunit "ACA Blob Storage API";
        RequestObject: Codeunit "ACA Request Object";
        SourceRequestObject: Codeunit "ACA Request Object";
        URIHelper: Codeunit "ACA URI Helper";
        InputDialog: Page "ACA Input Dialog Copy Blob";
        Operation: Enum "ACA Blob Storage Operation";
        DestStorAccName: Text;
        DestContainer: Text;
        DestBlobName: Text;
        SourceURI: Text;
    begin
        // Get Information from User
        InputDialog.InitPage(OriginalRequestObject.GetStorageAccountName(), OriginalRequestObject.GetContainerName(), BlobName);
        if InputDialog.RunModal() <> Action::OK then
            exit;
        InputDialog.GetResults(DestStorAccName, DestContainer, DestBlobName);

        // Create two "Request Objects"; one for Source one for Destination
        InitializeRequestObjectFromOriginal(SourceRequestObject, Rec."Full Name"); // copy from "OriginalRequestObject"
        SourceRequestObject.SetOperation(Operation::CopyBlob);

        InitializeRequestObjectFromOriginal(RequestObject, DestBlobName); // copy from "OriginalRequestObject"
        RequestObject.InitializeRequest(DestStorAccName, DestContainer, DestBlobName); // Update with user Values
        GlobalLastDestContainer := DestContainer;
        GlobalLastDestBlobName := DestBlobName;

        // Create URI for Source Blob
        SourceURI := URIHelper.ConstructUri(SourceRequestObject);

        API.CopyBlob(RequestObject, SourceURI);
        GlobalCopyId := RequestObject.GetCopyIdFromResponseHeaders();
    end;

    local procedure AbortCopyBlob(CopyId: Guid; ContainerName: Text; BlobName: Text)
    var
        API: Codeunit "ACA Blob Storage API";
        RequestObject: Codeunit "ACA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, '');
        RequestObject.SetContainerName(ContainerName);
        RequestObject.SetBlobName(BlobName);
        API.AbortCopyBlob(RequestObject, CopyId);
    end;

    local procedure GetBlobProperties(BlobName: Text)
    var
        API: Codeunit "ACA Blob Storage API";
        RequestObject: Codeunit "ACA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.GetBlobProperties(RequestObject);
    end;

    local procedure SetBlobProperties(BlobName: Text)
    var
        API: Codeunit "ACA Blob Storage API";
        RequestObject: Codeunit "ACA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        RequestObject.AddOptionalHeader('x-ms-blob-content-type', 'application/octet-stream');
        API.SetBlobProperties(RequestObject);
    end;

    local procedure InitializeRequestObjectFromOriginal(var RequestObject: Codeunit "ACA Request Object"; BlobName: Text)
    begin
        if BlobName = '' then
            BlobName := OriginalRequestObject.GetBlobName();
        RequestObject.InitializeAuthorization(OriginalRequestObject.GetAuthorizationType(), OriginalRequestObject.GetSecret());
        RequestObject.InitializeRequest(OriginalRequestObject.GetStorageAccountName(), OriginalRequestObject.GetContainerName(), BlobName);
    end;

    local procedure GetBlobMetadata(BlobName: Text)
    var
        API: Codeunit "ACA Blob Storage API";
        RequestObject: Codeunit "ACA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.GetBlobMetadata(RequestObject);
    end;

    local procedure SetBlobMetadata(BlobName: Text)
    var
        API: Codeunit "ACA Blob Storage API";
        RequestObject: Codeunit "ACA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        RequestObject.SetMetadataNameValueHeader('Dummy', 'DummyValue01');
        API.SetBlobMetadata(RequestObject);
    end;

    local procedure BlobAcquireLease(BlobName: Text)
    var
        API: Codeunit "ACA Blob Storage API";
        RequestObject: Codeunit "ACA Request Object";
    begin
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.BlobLeaseAcquire(RequestObject, 15);
        GlobalLeaseId := RequestObject.GetHeaderValueFromResponseHeaders('x-ms-lease-id');
        Message('Initiated 15-second lease. Saved LeaseId to Global variable');
    end;

    local procedure BlobRenewLease(BlobName: Text; LeaseId: Guid)
    var
        API: Codeunit "ACA Blob Storage API";
        RequestObject: Codeunit "ACA Request Object";
    begin
        if IsNullGuid(LeaseID) then
            Error('You need to call "Acquire Lease" first (global variable "LeaseId" is not set)');
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.BlobLeaseRenew(RequestObject, LeaseID);
    end;

    local procedure BlobReleaseLease(BlobName: Text; LeaseId: Guid)
    var
        API: Codeunit "ACA Blob Storage API";
        RequestObject: Codeunit "ACA Request Object";
    begin
        if IsNullGuid(LeaseID) then
            Error('You need to call "Acquire Lease" first (global variable "LeaseId" is not set)');
        InitializeRequestObjectFromOriginal(RequestObject, BlobName);
        API.BlobLeaseRelease(RequestObject, LeaseID);
    end;
}
