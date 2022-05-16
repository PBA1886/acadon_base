// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 5282620 "ACA Container Content"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    LookupPageId = "ACA Container Contents";
    DrillDownPageId = "ACA Container Contents";

    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(2; "Parent Directory"; Text[250])
        {
        }
        field(3; Level; Integer)
        {
        }
        field(4; "Full Name"; Text[250])
        {
        }
        field(10; Name; Text[250])
        {
        }
        field(11; "Creation-Time"; DateTime)
        {
        }
        field(12; "Last-Modified"; DateTime)
        {
        }
        field(13; "Content-Length"; Integer)
        {
        }
        field(14; "Content-Type"; Text[50])
        {
        }
        field(15; BlobType; Text[15])
        {
        }
        field(100; "XML Value"; Blob)
        {
        }
        field(110; URI; Text[250])
        {
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    var
        RequestObject: Codeunit "ACA Request Object";
        StorageAccountName: Text;
        ContainerName: Text;

    procedure SetBaseInfos(NewRequestObject: Codeunit "ACA Request Object")
    begin
        StorageAccountName := RequestObject.GetStorageAccountName();
        ContainerName := RequestObject.GetContainerName();
        RequestObject := NewRequestObject;
    end;

    procedure SetBaseInfos(NewStorageAccountName: Text; NewContainerName: Text; NewRequestObject: Codeunit "ACA Request Object")
    begin
        StorageAccountName := NewStorageAccountName;
        ContainerName := NewContainerName;
        RequestObject := NewRequestObject;
    end;

    procedure AddNewEntryFromNode(var Node: XmlNode; XPathName: Text)
    var
        HelperLibrary: Codeunit "ACA Helper Library";
        NameFromXml: Text;
        OuterXml: Text;
        ChildNodes: XmlNodeList;
        PropertiesNode: XmlNode;
    begin
        NameFromXml := HelperLibrary.GetValueFromNode(Node, XPathName);
        Node.WriteTo(OuterXml);
        Node.SelectSingleNode('.//Properties', PropertiesNode);
        ChildNodes := PropertiesNode.AsXmlElement().GetChildNodes();
        if ChildNodes.Count = 0 then
            Rec.AddNewEntry(NameFromXml, OuterXml)
        else
            Rec.AddNewEntry(NameFromXml, OuterXml, ChildNodes);
    end;

    procedure AddNewEntry(NameFromXml: Text; OuterXml: Text)
    var
        ChildNodes: XmlNodeList;
    begin
        AddNewEntry(NameFromXml, OuterXml, ChildNodes);
    end;

    procedure AddNewEntry(NameFromXml: Text; OuterXml: Text; ChildNodes: XmlNodeList)
    var
        NextEntryNo: Integer;
        Outstr: OutStream;
    begin
        if NameFromXml.Contains('/') then
            AddParentEntry(NameFromXml);

        NextEntryNo := GetNextEntryNo();

        Rec.Init();
        Rec."Entry No." := NextEntryNo;
        Rec."Parent Directory" := GetDirectParentName(NameFromXml);
        Rec.Level := GetLevel(NameFromXml);
        Rec."Full Name" := CopyStr(NameFromXml, 1, 250);
        Rec.Name := GetName(NameFromXml);
        SetPropertyFields(ChildNodes);
        Rec."XML Value".CreateOutStream(Outstr);
        Outstr.Write(OuterXml);
        Rec.Insert(true);
    end;

    local procedure AddParentEntry(NameFromXml: Text)
    var
        NextEntryNo: Integer;
    begin
        if ParentExist(NameFromXml) then
            exit;

        NextEntryNo := GetNextEntryNo();

        Rec.Init();
        Rec."Entry No." := NextEntryNo;
        Rec.Level := GetLevel(NameFromXml) - 1;
        Rec.Name := GetDirectParentName(NameFromXml);
        Rec."Parent Directory" := GetDirectParentName(NameFromXml);
        Rec."Content-Type" := 'Directory';
        Rec.Insert(true);
    end;

    local procedure SetPropertyFields(ChildNodes: XmlNodeList)
    var
        FormatHelper: Codeunit "ACA Format Helper";
        HelperLibrary: Codeunit "ACA Helper Library";
        RecRef: RecordRef;
        FldRef: FieldRef;
        ChildNode: XmlNode;
        PropertyName: Text;
        PropertyValue: Text;
        FldNo: Integer;
    begin
        foreach ChildNode in ChildNodes do begin
            PropertyName := ChildNode.AsXmlElement().Name;
            PropertyValue := ChildNode.AsXmlElement().InnerText;
            if PropertyValue <> '' then begin
                RecRef.GetTable(Rec);
                if HelperLibrary.GetFieldByName(Database::"ACA Container Content", PropertyName, FldNo) then begin
                    FldRef := RecRef.Field(FldNo);
                    case FldRef.Type of
                        FldRef.Type::DateTime:
                            FldRef.Value := FormatHelper.ConvertToDateTime(PropertyValue);
                        FldRef.Type::Integer:
                            FldRef.Value := FormatHelper.ConvertToInteger(PropertyValue);
                        else
                            FldRef.Value := PropertyValue;
                    end;
                end;
            end;
            RecRef.SetTable(Rec);
        end;
    end;

    local procedure GetNextEntryNo(): Integer
    begin
        if Rec.FindLast() then
            exit(Rec."Entry No." + 1)
        else
            exit(1);
    end;

    local procedure GetLevel(Name: Text): Integer
    var
        StringSplit: List of [Text];
    begin
        if not Name.Contains('/') then
            exit(0);
        StringSplit := Name.Split('/');
        exit(StringSplit.Count() - 1);
    end;

    local procedure GetName(Name: Text): Text[250]
    var
        StringSplit: List of [Text];
    begin
        if not Name.Contains('/') then
            exit(CopyStr(Name, 1, 250));
        StringSplit := Name.Split('/');
        exit(CopyStr(StringSplit.Get(StringSplit.Count()), 1, 250));
    end;

    local procedure GetDirectParentName(Name: Text): Text[250]
    var
        FileManagement: Codeunit "File Management";
    begin
        if not Name.Contains('/') then
            exit('root');

        exit(CopyStr(FileManagement.GetDirectoryName(Name), 1, 250));
    end;

    /// <summary>
    /// The value in "Name" might be shortened (because it could be longer than 250 characters)
    /// Use this function to retrieve the original name of the Blob (read from saved XmlNode)
    /// </summary>
    /// <returns></returns>
    local procedure GetFullNameFromXML(): Text
    var
        HelperLibrary: Codeunit "ACA Helper Library";
        Node: XmlNode;
        NameFromXml: Text;
    begin
        GetXmlNodeForEntry(Node);
        NameFromXml := HelperLibrary.GetValueFromNode(Node, './/Name');
        exit(NameFromXml);
    end;

    local procedure GetXmlNodeForEntry(var Node: XmlNode)
    var
        InStr: InStream;
        XmlAsText: Text;
        Document: XmlDocument;
    begin
        Rec.CalcFields("XML Value");
        Rec."XML Value".CreateInStream(InStr);
        InStr.Read(XmlAsText);
        XmlDocument.ReadFrom(XmlAsText, Document);
        Node := Document.AsXmlNode();
    end;

    local procedure ParentExist(NameFromXml: Text) Result: Boolean
    begin
        Rec.SetRange(Name, GetDirectParentName(NameFromXml));
        Result := not Rec.IsEmpty();
        Rec.SetRange(Name);
    end;

    procedure GetRequestObject(var NewRequestObject: Codeunit "ACA Request Object")
    begin
        NewRequestObject := RequestObject;
    end;

    procedure DownloadBlob(OriginalRequestObject: Codeunit "ACA Request Object")
    var
        API: Codeunit "ACA Blob Storage API";
        Operation: Enum "ACA Blob Storage Operation";
    begin
        if Rec."Content-Type" = 'Directory' then
            exit;

        OriginalRequestObject.SetOperation(Operation::GetBlob);
        OriginalRequestObject.SetBlobName(GetFullNameFromXML());
        API.DownloadBlobAsFile(OriginalRequestObject);
    end;
}
