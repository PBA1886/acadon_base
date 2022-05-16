// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 5282625 "ACA Helper Library"
{
    Access = Internal;

    trigger OnRun()
    begin

    end;

    var
        ResultCollectionEmptyMsg: Label 'The result set is empty';
    //PropertyPlaceholderLbl: Label '%1: %2', Comment = '%1 = Property Name, %2 = Property Value';

    // #region Container-specific Helper
    procedure ContainerNodeListTotempRecord(NodeList: XmlNodeList; var ContainerContent: Record "ACA Container Content")
    begin
        NodeListToTempRecord(NodeList, './/Name', ContainerContent);
    end;

    procedure ContainerNodeListTotempRecord(NodeList: XmlNodeList; var Container: Record "ACA Container")
    begin
        NodeListToTempRecord(NodeList, './/Name', Container);
    end;

    procedure CreateContainerNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Containers/Container'));
    end;
    // #endregion

    // #region Blob-specific Helper
    procedure CreateBlobNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Blobs/Blob'));
    end;

    procedure BlobNodeListToTempRecord(NodeList: XmlNodeList)
    var
        ContainerContent: Record "ACA Container Content";
    begin
        BlobNodeListToTempRecord(NodeList, ContainerContent);
    end;

    procedure BlobNodeListToTempRecord(NodeList: XmlNodeList; var ContainerContent: Record "ACA Container Content")
    begin
        NodeListToTempRecord(NodeList, './/Name', ContainerContent);
    end;

    // #endregion

    // #region Share-specific Helper
    procedure FileShareNodeListTotempRecord(NodeList: XmlNodeList; var FileShareContent: Record "ACA Azure File Share Content")
    begin
        NodeListToTempRecord(NodeList, './/Name', FileShareContent);
    end;

    procedure FileShareNodeListTotempRecord(NodeList: XmlNodeList; var FileShare: Record "ACA Azure File Share")
    begin
        NodeListToTempRecord(NodeList, './/Name', FileShare);
    end;

    procedure CreateFileShareNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Shares/Share'));
    end;

    procedure BlobNodeListToTempRecord(NodeList: XmlNodeList; var FileShareContent: Record "ACA Azure File Share Content")
    begin
        NodeListToTempRecord(NodeList, './/Name', FileShareContent);
    end;

    procedure CreateFileNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Entries/File'));
    end;

    procedure CreateDirectoryNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Entries/Directory'));
    end;
    // #endregion

    procedure ShowTempRecordLookup(var ContainerContent: Record "ACA Container Content")
    var
        ContainerContents: Page "ACA Container Contents";
    begin
        if ContainerContent.IsEmpty() then begin
            Message(ResultCollectionEmptyMsg);
            exit;
        end;
        ContainerContents.InitializeFromTempRec(ContainerContent);
        ContainerContents.Run();
    end;

    procedure ShowTempRecordLookup(var Container: Record "ACA Container")
    begin
        if Container.IsEmpty() then begin
            Message(ResultCollectionEmptyMsg);
            exit;
        end;
        Page.Run(0, Container);
    end;

    procedure ShowTempRecordLookup(var FileShare: Record "ACA Azure File Share")
    begin
        if FileShare.IsEmpty() then begin
            Message(ResultCollectionEmptyMsg);
            exit;
        end;
        Page.Run(0, FileShare);
    end;

    procedure ShowTempRecordLookup(var FileShareContent: Record "ACA Azure File Share Content")
    var
        FileShareContentPage: Page "ACA Azure File Share Content";
    begin
        if FileShareContent.IsEmpty() then begin
            Message(ResultCollectionEmptyMsg);
            exit;
        end;

        FileShareContentPage.InitializeFromTempRec(FileShareContent);
        FileShareContentPage.Run();
    end;

    procedure LookupContainerContent(var ContainerContent: Record "ACA Container Content"): Text
    var
        ContainerContentReturn: Record "ACA Container Content";
        ContainerContents: Page "ACA Container Contents";
    begin
        if ContainerContent.IsEmpty() then
            exit('');

        ContainerContent.FindSet(false, false);
        repeat
            ContainerContents.AddEntry(ContainerContent);
        until ContainerContent.Next() = 0;
        ContainerContents.LookupMode(true);
        if ContainerContents.RunModal() = Action::LookupOK then begin
            ContainerContents.GetRecord(ContainerContentReturn);
            exit(ContainerContentReturn."Full Name");
        end;
    end;

    // #region XML Helper
    local procedure GetXmlDocumentFromResponse(var Document: XmlDocument; ResponseAsText: Text)
    var
        ReadingAsXmlErr: Label 'Error reading Response as XML.';
    begin
        if not XmlDocument.ReadFrom(ResponseAsText, Document) then
            Error(ReadingAsXmlErr);
    end;

    local procedure CreateXPathNodeListFromResponse(ResponseAsText: Text; XPath: Text): XmlNodeList
    var
        Document: XmlDocument;
        RootNode: XmlElement;
        NodeList: XmlNodeList;
    begin
        GetXmlDocumentFromResponse(Document, ResponseAsText);
        Document.GetRoot(RootNode);
        RootNode.SelectNodes(XPath, NodeList);
        exit(NodeList);
    end;

    procedure GetValueFromNode(Node: XmlNode; XPath: Text): Text
    var
        Node2: XmlNode;
        Value: Text;
    begin
        Node.SelectSingleNode(XPath, Node2);
        Value := Node2.AsXmlElement().InnerText();
        exit(Value);
    end;

    local procedure NodeListToTempRecord(NodeList: XmlNodeList; XPathName: Text; var ContainerContent: Record "ACA Container Content")
    var
        Node: XmlNode;
    begin
        if not ContainerContent.IsTemporary() then
            Error('');
        ContainerContent.DeleteAll();

        if NodeList.Count = 0 then
            exit;
        foreach Node in NodeList do
            ContainerContent.AddNewEntryFromNode(Node, XPathName);
    end;

    local procedure NodeListToTempRecord(NodeList: XmlNodeList; XPathName: Text; var FileShare: Record "ACA Azure File Share")
    var
        Node: XmlNode;
    begin
        if not FileShare.IsTemporary() then
            Error('');
        FileShare.DeleteAll();

        if NodeList.Count() = 0 then
            exit;

        foreach Node in NodeList do
            FileShare.AddNewEntryFromNode(Node, XPathName);
    end;

    local procedure NodeListToTempRecord(NodeList: XmlNodeList; XPathName: Text; var FileShareContent: Record "ACA Azure File Share Content")
    var
        Node: XmlNode;
    begin
        if not FileShareContent.IsTemporary() then
            Error('');
        FileShareContent.DeleteAll();

        if NodeList.Count = 0 then
            exit;
        foreach Node in NodeList do
            FileShareContent.AddNewEntryFromNode(Node, XPathName);
    end;

    local procedure NodeListToTempRecord(NodeList: XmlNodeList; XPathName: Text; var Container: Record "ACA Container")
    var
        Node: XmlNode;
    begin
        if not Container.IsTemporary() then
            Error('');
        Container.DeleteAll();

        if NodeList.Count = 0 then
            exit;
        foreach Node in NodeList do
            Container.AddNewEntryFromNode(Node, XPathName);
    end;
    // #endregion

    // #region Format Helper
    procedure GetFieldByName(TableNo: Integer; FldName: Text; var FldNo: Integer): Boolean
    var
        Fld: Record Field;
    begin
        Clear(FldNo);
        Fld.Reset();
        Fld.SetRange(TableNo, TableNo);
        Fld.SetRange(FieldName, FldName);
        if Fld.FindFirst() then
            FldNo := Fld."No.";
        exit(FldNo <> 0);
    end;
    // #endregion
}
