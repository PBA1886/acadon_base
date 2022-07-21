table 5282617 "ACA License Information"
{
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Id; Guid) { }
        field(10; Timestamp; DateTime) { }
        field(20; TestPeriodLength; Integer) { }
        field(30; IsLicensed; Boolean) { }
        field(40; NoOfUsers; Integer) { }
        field(50; NoOfCompanies; Integer) { }
    }

    keys
    {
        key(PK; "Id") { }
    }

    procedure FromJson(LicenseInfo: JsonObject): Boolean
    var
        JToken: JsonToken;
        AppIdTok: Label 'RowKey', Locked = true;
        TimestampTok: Label 'Timestamp', Locked = true;
        TestPeriodLengthTok: Label 'TestPeriodLength', Locked = true;
        IsLicensedTok: Label 'IsLicensed', Locked = true;
        NoOfUsersTok: Label 'NoOfUsers', Locked = true;
        NoOfCompaniesTok: Label 'NoOfCompanies', Locked = true;
    begin
        if LicenseInfo.Keys().Count() < 1 then
            exit(false);

        Rec.Init();
        if LicenseInfo.Get(AppIdTok, JToken) then
            Rec.Id := GetText(JToken);

        if LicenseInfo.Get(TimestampTok, JToken) then
            Rec.Timestamp := GetDateTime(JToken);

        if LicenseInfo.Get(TestPeriodLengthTok, JToken) then
            Rec.TestPeriodLength := GetInteger(JToken);

        if LicenseInfo.Get(IsLicensedTok, JToken) then
            Rec.IsLicensed := GetBool(JToken);

        if LicenseInfo.Get(NoOfUsersTok, JToken) then
            Rec.NoOfUsers := GetInteger(JToken);

        if LicenseInfo.Get(NoOfCompaniesTok, JToken) then
            Rec.NoOfCompanies := GetInteger(JToken);

        Rec.Insert();
        exit(true);
    end;

    local procedure GetBool(JToken: JsonToken): Boolean
    var
        JValue: JsonValue;
    begin
        if not JToken.IsValue() then
            exit;

        JValue := JToken.AsValue();
        if not (JValue.IsNull() or JValue.IsUndefined()) then
            exit(JValue.AsBoolean());
    end;


    local procedure GetInteger(JToken: JsonToken): Integer
    var
        JValue: JsonValue;
    begin
        if not JToken.IsValue() then
            exit;

        JValue := JToken.AsValue();
        if not (JValue.IsNull() or JValue.IsUndefined()) then
            exit(JValue.AsInteger());
    end;

    local procedure GetText(JToken: JsonToken): Text
    var
        JValue: JsonValue;
    begin
        if not JToken.IsValue() then
            exit;

        JValue := JToken.AsValue();
        if not (JValue.IsNull() or JValue.IsUndefined()) then
            exit(JValue.AsText());
    end;

    local procedure GetDateTime(JToken: JsonToken): DateTime
    var
        JValue: JsonValue;
    begin
        if not JToken.IsValue() then
            exit;

        JValue := JToken.AsValue();
        if not (JValue.IsNull() or JValue.IsUndefined()) then
            exit(JValue.AsDateTime());
    end;

}