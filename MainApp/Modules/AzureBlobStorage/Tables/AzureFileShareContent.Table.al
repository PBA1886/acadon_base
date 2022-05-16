table 5282618 "ACA Azure File Share Content"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    LookupPageId = "ACA Azure File Share Content";
    DrillDownPageId = "ACA Azure File Share Content";

    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(10; Name; Text[250])
        {
        }
        field(13; "Content-Length"; Integer)
        {
        }
        field(20; CreationTime; DateTime)
        {
            Caption = 'CreationTime', Locked = true;
        }
        field(21; LastAccessTime; DateTime)
        {
            Caption = 'LastAccessTime', Locked = true;
        }
        field(22; LastWriteTime; DateTime)
        {
            Caption = 'LastWriteTime', Locked = true;
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
        ShareName: Text;

    procedure SetBaseInfos(NewRequestObject: Codeunit "ACA Request Object")
    begin
        StorageAccountName := RequestObject.GetStorageAccountName();
        ShareName := RequestObject.GetContainerName();
        RequestObject := NewRequestObject;
    end;

    procedure SetBaseInfos(NewStorageAccountName: Text; NewContainerName: Text; NewRequestObject: Codeunit "ACA Request Object")
    begin
        StorageAccountName := NewStorageAccountName;
        ShareName := NewContainerName;
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
        NextEntryNo := GetNextEntryNo();

        Rec.Init();
        Rec."Entry No." := NextEntryNo;
        Rec.Name := GetName(NameFromXml);
        SetPropertyFields(ChildNodes);
        Rec."XML Value".CreateOutStream(Outstr);
        Outstr.Write(OuterXml);
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
                if HelperLibrary.GetFieldByName(Database::"ACA Azure File Share Content", PropertyName, FldNo) then begin
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

    local procedure GetName(Name: Text): Text[250]
    var
        StringSplit: List of [Text];
    begin
        if not Name.Contains('/') then
            exit(CopyStr(Name, 1, 250));
        StringSplit := Name.Split('/');
        exit(CopyStr(StringSplit.Get(StringSplit.Count()), 1, 250));
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

    procedure GetRequestObject(var NewRequestObject: Codeunit "ACA Request Object")
    begin
        NewRequestObject := RequestObject;
    end;

    procedure DownloadFile(OriginalRequestObject: Codeunit "ACA Request Object")
    var
        API: Codeunit "ACA File Share API";
        DownloadFromRequestObject: Codeunit "ACA Request Object";
        Operation: Enum "ACA Blob Storage Operation";
    begin
        DownloadFromRequestObject.InitializeRequest(OriginalRequestObject.GetStorageAccountName(), OriginalRequestObject.GetContainerName(), OriginalRequestObject.GetConnectionType());
        DownloadFromRequestObject.InitializeAuthorization(OriginalRequestObject.GetAuthorizationType(), OriginalRequestObject.GetSecret());
        DownloadFromRequestObject.SetOperation(Operation::GetFile);
        DownloadFromRequestObject.SetBlobName(OriginalRequestObject.GetBlobName() + GetFullNameFromXML());
        API.DownloadBlobAsFile(DownloadFromRequestObject);
    end;
}
