// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 5282621 "ACA Blob Storage Operation"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = '', Locked = true;
    }
    value(10; ListContainers)
    {
        Caption = 'List Containers', Locked = true;
    }
    value(11; ListContainerContents)
    {
        Caption = 'List Container Contents', Locked = true;
    }
    value(12; PutContainer)
    {
        Caption = 'Create Container', Locked = true;
    }
    value(13; DeleteContainer)
    {
        Caption = 'Delete Container', Locked = true;
    }
    value(14; GetContainerMetadata)
    {
        Caption = 'Get Container Metadata', Locked = true;
    }
    value(15; SetContainerMetadata)
    {
        Caption = 'Set Container Metadata', Locked = true;
    }
    value(16; GetContainerAcl)
    {
        Caption = 'Get Container ACL', Locked = true;
    }
    value(17; SetContainerAcl)
    {
        Caption = 'Set Container ACL', Locked = true;
    }
    value(20; GetBlob)
    {
        Caption = 'Get Blob', Locked = true;
    }
    value(21; PutBlob)
    {
        Caption = 'Upload Blob', Locked = true;
    }
    value(22; DeleteBlob)
    {
        Caption = 'Delete Blob', Locked = true;
    }
    value(23; CopyBlob)
    {
        Caption = 'Copy Blob', Locked = true;
    }
    value(24; AbortCopyBlob)
    {
        Caption = 'Abort Copy Blob', Locked = true;
    }
    value(25; GetBlobMetadata)
    {
        Caption = 'Get Blob Metadata', Locked = true;
    }
    value(26; SetBlobMetadata)
    {
        Caption = 'Set Blob Metadata', Locked = true;
    }
    value(30; LeaseContainer)
    {
        Caption = 'Lease Container', Locked = true;
    }
    value(31; LeaseBlob)
    {
        Caption = 'Lease Blob', Locked = true;
    }
    value(40; GetBlobServiceProperties)
    {
        Caption = 'Get Blob Service Properties', Locked = true;
    }
    value(41; SetBlobServiceProperties)
    {
        Caption = 'Set Blob Service Properties', Locked = true;
    }
    value(50; GetBlobProperties)
    {
        Caption = 'Get Blob Properties', Locked = true;
    }
    value(51; SetBlobProperties)
    {
        Caption = 'Set Blob Properties', Locked = true;
    }
    value(100; ListShares)
    {
        Caption = 'List Shares', Locked = true;
    }
    value(101; ListFileShareContent)
    {
        Caption = 'List File Share Content', Locked = true;
    }
    value(102; GetFile)
    {
        Caption = 'Get File', Locked = true;
    }
    value(103; CreateDirectory)
    {
        Caption = 'Create Directory', Locked = true;
    }
    value(104; CreateFile)
    {
        Caption = 'Create File', Locked = true;
    }
    value(105; CopyFile)
    {
        Caption = 'Copy File', Locked = true;
    }
    value(106; DeleteFile)
    {
        Caption = 'Delete File', Locked = true;
    }
    value(107; PutRange)
    {
        Caption = 'Put Range', Locked = true;
    }
}
