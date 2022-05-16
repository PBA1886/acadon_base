// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 5282622 "ACA Container"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    LookupPageId = "ACA Container";
    DrillDownPageId = "ACA Container";

    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(10; Name; Text[250])
        {
        }
        field(11; "Last-Modified"; DateTime)
        {
        }
        field(12; LeaseStatus; Text[15])
        {
        }
        field(13; LeaseState; Text[15])
        {
        }
        field(14; DefaultEncryptionScope; Text[50])
        {
        }
        field(15; DenyEncryptionScopeOverride; Boolean)
        {
        }
        field(16; HasImmutabilityPolicy; Boolean)
        {
        }
        field(17; HasLegalHold; Boolean)
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
        NextEntryNo := GetNextEntryNo();

        Rec.Init();
        Rec."Entry No." := NextEntryNo;
        Rec.Name := CopyStr(NameFromXml, 1, 250);
        SetPropertyFields(ChildNodes);
        Rec."XML Value".CreateOutStream(Outstr);
        Outstr.Write(OuterXml);
        //Rec.URI := HelperLibrary.ConstructUrl(StorageAccountName, RequestObject, Operation::ListContainerContents, ContainerName, NameFromXml);
        Rec.Insert(true);
    end;

    local procedure GetNextEntryNo(): Integer
    begin
        if Rec.FindLast() then
            exit(Rec."Entry No." + 1)
        else
            exit(1);
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
                if HelperLibrary.GetFieldByName(Database::"ACA Container", PropertyName, FldNo) then begin
                    FldRef := RecRef.Field(FldNo);
                    case FldRef.Type of
                        FldRef.Type::DateTime:
                            FldRef.Value := FormatHelper.ConvertToDateTime(PropertyValue);
                        FldRef.Type::Integer:
                            FldRef.Value := FormatHelper.ConvertToInteger(PropertyValue);
                        FldRef.Type::Boolean:
                            FldRef.Value := FormatHelper.ConvertToBoolean(PropertyValue);
                        else
                            FldRef.Value := PropertyValue;
                    end;
                end;
            end;
            RecRef.SetTable(Rec);
        end;
    end;
}
