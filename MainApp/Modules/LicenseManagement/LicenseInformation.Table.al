table 5282617 "ACA License Information"
{
    TableType = Temporary;
    Access = Internal;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Id; Guid) { Caption = '', Locked = true; }
        field(10; FirstInstalledAt; Date) { Caption = '', Locked = true; }
        field(20; TestPeriodLength; Integer) { Caption = '', Locked = true; }
        field(30; IsLicensed; Boolean) { Caption = '', Locked = true; }
        field(40; NoOfUsers; Integer) { Caption = '', Locked = true; }
        field(50; NoOfCompanies; Integer) { Caption = '', Locked = true; }
    }

    keys
    {
        key(PK; "Id") { }
    }

    procedure FromJson(LicenseInfo: JsonObject): Boolean
    var
        JsonManagement: Codeunit "ACA Json Management";
        AppIdTok: Label 'RowKey', Locked = true;
        FirstInstalledAtTok: Label 'FirstInstalledAt', Locked = true;
        TestPeriodLengthTok: Label 'TestPeriodLength', Locked = true;
        IsLicensedTok: Label 'IsLicensed', Locked = true;
        NoOfUsersTok: Label 'NoOfUsers', Locked = true;
        NoOfCompaniesTok: Label 'NoOfCompanies', Locked = true;
    begin
        if LicenseInfo.Keys().Count() < 1 then
            exit(false);

        Rec.Init();
        Rec.Id := JsonManagement.GetValueAsText(AppIdTok, LicenseInfo);
        Rec.FirstInstalledAt := JsonManagement.GetValueAsDate(FirstInstalledAtTok, LicenseInfo);
        Rec.TestPeriodLength := JsonManagement.GetValueAsInteger(TestPeriodLengthTok, LicenseInfo);
        Rec.IsLicensed := JsonManagement.GetValueAsBoolean(IsLicensedTok, LicenseInfo);
        Rec.NoOfUsers := JsonManagement.GetValueAsInteger(NoOfUsersTok, LicenseInfo);
        Rec.NoOfCompanies := JsonManagement.GetValueAsInteger(NoOfCompaniesTok, LicenseInfo);
        Rec.Insert();

        exit(not IsNullGuid(Rec.Id));
    end;
}