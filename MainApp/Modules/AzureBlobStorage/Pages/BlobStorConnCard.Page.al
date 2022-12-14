// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 5282629 "ACA Blob Stor. Conn. Card"
{

    Caption = 'Blob Storage Connection Card';
    PageType = Card;
    SourceTable = "ACA Blob Storage Connection";
    UsageCategory = None;
    PromotedActionCategories = 'New,Process,Reports,View Container,Create Container,Delete Container,Upload,Download,Delete Blob,Lease,Properties';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Identifier';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description';
                }
                field("Connection Type"; Rec."Connection Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which API will be used.';

                    trigger OnValidate()
                    begin
                        SetVisibility();
                    end;
                }
                field("Storage Account Name"; Rec."Storage Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The name (not the complete URL) for the Storage Account';
                }
                field("API Version"; Rec."API Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'The API Version to use';
                }
            }
            group(RequestObject)
            {
                field("Authorization Type"; Rec."Authorization Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'The way of authorizing API calls';
                }
                field(Secret; Rec.Secret)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shared access signature Token or SharedKey';
                }
            }
            group(Container)
            {
                Visible = ConnectionIsBlobContainer;
                field("Source Container Name"; Rec."Source Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Name of the Container (or Directory) to download files from';
                }
                field("Target Container Name"; Rec."Target Container Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Name of the Container (or Directory) to upload files to';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(OpenTester)
            {
                Caption = 'Open Test-Page';
                Image = TestFile;
                ApplicationArea = All;
                ToolTip = 'Use this page to test API actions and view the "raw" HTTP response for it';
                RunObject = page "ACA Request Test";
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = ConnectionIsBlobContainer;
            }
            group(View)
            {
                Caption = 'View Container';
                Visible = ConnectionIsBlobContainer;
                action(ListContainers)
                {
                    ApplicationArea = All;
                    Caption = 'List all Containers';
                    Image = LaunchWeb;
                    ToolTip = 'List all available Containers in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction();
                    begin
                        Rec.ListContainers();
                    end;
                }
                action(ListShares)
                {
                    ApplicationArea = All;
                    Caption = 'List all Shares';
                    Image = LaunchWeb;
                    ToolTip = 'List all available Shares in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    Visible = ConnectionIsFileShare;

                    trigger OnAction();
                    begin
                        Rec.ListShares();
                    end;
                }

                action(ListSourceContents)
                {
                    ApplicationArea = All;
                    Caption = 'List Contents of Source';
                    Image = LaunchWeb;
                    ToolTip = 'List all files in the Source Container';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction();
                    begin
                        Rec.ListContentSource();
                    end;
                }

                action(ListTargetContents)
                {
                    ApplicationArea = All;
                    Caption = 'List Contents of Target';
                    Image = LaunchWeb;
                    ToolTip = 'List all files in the Target Container';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category4;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction();
                    begin
                        Rec.ListContentTarget();
                    end;
                }
            }
            group(CreateContainers)
            {
                Caption = 'Create Containers';
                Visible = ConnectionIsBlobContainer;
                action(TestCreateSourceContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Create Source Container';
                    Image = LaunchWeb;
                    ToolTip = 'Create the Container (specified in "Source Container Name") in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category5;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction();
                    begin
                        Rec.CreateSourceContainer();
                    end;
                }

                action(TestCreateTargetContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Create Target Container';
                    Image = LaunchWeb;
                    ToolTip = 'Create the Container (specified in "Target Container Name") in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category5;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction();
                    begin
                        Rec.CreateTargetContainer();
                    end;
                }
            }
            group(DeleteContainers)
            {
                Caption = 'Delete Containers';
                Visible = ConnectionIsBlobContainer;
                action(TestDeleteSourceContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Delete Source Container';
                    Image = LaunchWeb;
                    ToolTip = 'Delete the Container (specified in "Source Container Name") in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction();
                    begin
                        Rec.DeleteSourceContainer();
                    end;
                }

                action(TestDeleteTargetContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Delete Target Container';
                    Image = LaunchWeb;
                    ToolTip = 'Delete the Container (specified in "Target Container Name") in the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction();
                    begin
                        Rec.DeleteTargetContainer();
                    end;
                }
            }
            group(Lease)
            {
                Caption = 'Lease...';
                Visible = ConnectionIsBlobContainer;
                action(LeaseContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Acquire Lease Container';
                    Image = LaunchWeb;
                    ToolTip = 'Acquires a lease for a container';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category10;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.ContainerLeaseAcquireSource();
                    end;
                }

                action(ReleaseContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Release Lease Container';
                    Image = LaunchWeb;
                    ToolTip = 'Release a lease for a container';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category10;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    var
                        NullGuid: Guid;
                    begin
                        Rec.ContainerLeaseReleaseSource(NullGuid);
                    end;
                }

                action(RenewLeaseContainer)
                {
                    ApplicationArea = All;
                    Caption = 'Renew Lease Container';
                    Image = LaunchWeb;
                    ToolTip = 'Renew a lease for a container';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category10;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    var
                        NullGuid: Guid;
                    begin
                        Rec.ContainerLeaseRenewSource(NullGuid);
                    end;
                }
            }
            group(UploadFile)
            {
                Caption = 'Upload';
                Visible = ConnectionIsBlobContainer;

                action(UploadFileUISource)
                {
                    ApplicationArea = All;
                    Caption = 'Upload File (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'Upload a file in the Container (specified in "Source Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.UploadFileUI(Rec."Source Container Name");
                    end;
                }
                action(UploadFileUITarget)
                {
                    ApplicationArea = All;
                    Caption = 'Upload File (Target)';
                    Image = LaunchWeb;
                    ToolTip = 'Upload a file in the Container (specified in "Target Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category7;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.UploadFileUI(Rec."Target Container Name");
                    end;
                }
            }
            group(DownloadFile)
            {
                Caption = 'Download';
                Visible = ConnectionIsBlobContainer;

                action(DownloadFileUISource)
                {
                    ApplicationArea = All;
                    Caption = 'Download File (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'Download a file from the Container (specified in "Source Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category8;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.DownloadFileUI(Rec."Source Container Name");
                    end;
                }
                action(DownloadFileUITarget)
                {
                    ApplicationArea = All;
                    Caption = 'Download File (Target)';
                    Image = LaunchWeb;
                    ToolTip = 'Download a file from the Container (specified in "Target Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category8;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.DownloadFileUI(Rec."Target Container Name");
                    end;
                }
            }

            group(DeleteBlob)
            {
                Caption = 'Delete Blob';
                Visible = ConnectionIsBlobContainer;

                action(DeleteBlobUISource)
                {
                    ApplicationArea = All;
                    Caption = 'Delete File (Source)';
                    Image = LaunchWeb;
                    ToolTip = 'Delete a file from the Container (specified in "Source Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category9;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.DeleteBlobFromSourceContainerUI();
                    end;
                }
                action(DeleteBlobUITarget)
                {
                    ApplicationArea = All;
                    Caption = 'Delete File (Target)';
                    Image = LaunchWeb;
                    ToolTip = 'Delete a file from the Container (specified in "Target Container Name") of the Storage Account';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category9;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.DeleteBlobFromTargetContainerUI();
                    end;
                }
            }
            group(BlobProperties)
            {
                Caption = 'Properties';
                Visible = ConnectionIsBlobContainer;
                action(GetServiceProperties)
                {
                    ApplicationArea = All;
                    Caption = 'Get Service Properties';
                    ToolTip = 'The Get Blob Service Properties operation gets the properties of a storage account''s Blob service, including properties for Storage Analytics and CORS (Cross-Origin Resource Sharing) rules.\n\nFor detailed information about CORS rules and evaluation logic, see CORS Support for the Storage Services.';
                    Image = LaunchWeb;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.GetBlobServiceProperties();
                    end;
                }
                action(SetServiceProperties)
                {
                    ApplicationArea = All;
                    Caption = 'Set Service Properties';
                    ToolTip = 'The Set Blob Service Properties operation sets properties for a storage account''s Blob service endpoint, including properties for Storage Analytics, CORS (Cross-Origin Resource Sharing) rules and soft delete settings.\n\nYou can also use this operation to set the default request version for all incoming requests to the Blob service that do not have a version specified.\n\nSee CORS Support for the Storage Services for more information on CORS rules.';
                    Image = LaunchWeb;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.SetBlobServiceProperties();
                    end;
                }

                action(GetContainerMetadataSource)
                {
                    ApplicationArea = All;
                    Caption = 'Get Container Metadata (Source)';
                    ToolTip = 'The Get Container Metadata operation returns all user-defined metadata for the container.';
                    Image = LaunchWeb;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.GetContainerMetadataSource();
                    end;
                }

                action(SetContainerMetadataSource)
                {
                    ApplicationArea = All;
                    Caption = 'Set Container Metadata (Source)';
                    ToolTip = 'The Set Container Metadata operation sets one or more user-defined name-value pairs for the specified container.';
                    Image = LaunchWeb;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.SetContainerMetadataSource();
                    end;
                }

                action(GetContainerAclSource)
                {
                    ApplicationArea = All;
                    Caption = 'Get Container ACL (Source)';
                    ToolTip = 'The Get Container ACL operation gets the permissions for the specified container. The permissions indicate whether container data may be accessed publicly.';
                    Image = LaunchWeb;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.GetContainerAclSource();
                    end;
                }

                action(SetContainerAclSource)
                {
                    ApplicationArea = All;
                    Caption = 'Set Container ACL (Source)';
                    ToolTip = 'The Set Container ACL operation sets the permissions for the specified container. The permissions indicate whether blobs in a container may be accessed publicly.';
                    Image = LaunchWeb;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category11;
                    Visible = ConnectionIsBlobContainer;

                    trigger OnAction()
                    begin
                        Rec.SetContainerAclSource();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetVisibility();
    end;

    var
        [InDataSet]
        ConnectionIsBlobContainer, ConnectionIsFileShare : Boolean;

    local procedure SetVisibility()
    begin
        ConnectionIsBlobContainer := Rec."Connection Type" = Rec."Connection Type"::"Blob Container";
        ConnectionIsFileShare := Rec."Connection Type" = Rec."Connection Type"::"File Share";
    end;
}
