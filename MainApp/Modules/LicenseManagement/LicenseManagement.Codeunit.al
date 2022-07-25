codeunit 5282619 "ACA License Management"
{
    TableNo = "ACA License Information";

    trigger OnRun()
    var
        AppInfo: ModuleInfo;
    begin
        Rec.SetFilter(Id, '<>%1', '');
        if Rec.FindSet() then
            repeat
                if NavApp.GetModuleInfo(Rec.Id, AppInfo) then
                    LicenseExpired := CheckLicenseExpired(AppInfo.Id);
            until (Rec.Next() = 0) or LicenseExpired;
    end;

    var
        FormatHelper: Codeunit "ACA Format Helper";
        BaseUriTxt: Label 'https://acadonappsourcestorage.table.core.windows.net/', Locked = true;
        StorageAccountTxt: Label 'acadonappsourcestorage', Locked = true;
        AzureTableNameTxt: Label 'AppSourceLicensing', Locked = true;
        LicenseExpired: Boolean;

    /// <summary>
    /// Checks if the test license expired.
    /// </summary>
    procedure CheckLicenseExpired(AppId: Guid): Boolean
    var
        TempLicenseInformation: Record "ACA License Information" temporary;
        EndDate: Date;
        DateExpressionTok: Label '<+%1D>', Locked = true;
    begin
        if IsNullGuid(AppId) then
            exit;

        if LicenseCheckNeeded() then
            exit;

        if not GetLicenseInformation(AppId, TempLicenseInformation) then
            exit;

        UpdateLicenseInformation(AppId, TempLicenseInformation);

        if TempLicenseInformation.IsLicensed then
            exit;

        EndDate := CalcDate(StrSubstNo(DateExpressionTok, TempLicenseInformation.TestPeriodLength), DT2Date(TempLicenseInformation.Timestamp));
        exit(EndDate < Today());
    end;

    local procedure LicenseCheckNeeded(): Boolean
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        exit(not EnvironmentInfo.IsOnPrem() and
                EnvironmentInfo.IsProduction() and
                EnvironmentInfo.IsSaaS() and
                EnvironmentInfo.IsSaaSInfrastructure())
    end;

    local procedure GetLicenseInformation(AppId: Guid; var TempLicenseInformation: Record "ACA License Information" temporary): Boolean
    var
        LicenseInfoJson: JsonObject;
    begin
        LicenseInfoJson := GetLicenseFromAzureTable(AppId);
        if TempLicenseInformation.FromJson(LicenseInfoJson) then
            exit(true);

        LicenseInfoJson := RegisterLicense(AppId);
        if TempLicenseInformation.FromJson(LicenseInfoJson) then
            exit(true);
    end;

    local procedure UpdateLicenseInformation(AppId: Guid; var TempLicenseInformation: Record "ACA License Information" temporary)
    var
        Payload: JsonObject;
    begin
        if (TempLicenseInformation.NoOfUsers = GetUserCount()) and (TempLicenseInformation.NoOfCompanies = GetCompanyCount()) then
            exit;


        Payload := GenerateJsonPayload(AppId, TempLicenseInformation.IsLicensed, TempLicenseInformation.TestPeriodLength);
        UpdateTenantToAzureTable(AppId, Payload);
    end;

    local procedure RegisterLicense(AppId: Guid): JsonObject
    begin
        exit(RegisterLicense(AppId, 30));
    end;

    procedure RegisterLicense(AppId: Guid; TestPeriodLength: Integer): JsonObject
    begin
        exit(InsertLicenseToAzureTable(AppId, TestPeriodLength));
    end;

    local procedure GetLicenseFromAzureTable(AppId: Guid): JsonObject
    var
        TableAPIAuth: Codeunit "ACA Table API Authorization";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        RequestHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        UriTok: Label '%1%2(PartitionKey=''%3'',RowKey=''%4'')?$RowKey,select=Timestamp,TestPeriodLength,IsLicensed', Locked = true;
    begin
        RequestMsg.Method(Format(Enum::"Http Request Type"::GET));
        RequestMsg.SetRequestUri(StrSubstNo(UriTok, BaseUriTxt, AzureTableNameTxt, GetPartitionKey(), GetRowKey(AppId)));
        RequestMsg.GetHeaders(RequestHeaders);
        AddHeader(RequestHeaders, 'Date', FormatHelper.GetRfc1123DateTime());
        AddHeader(RequestHeaders, 'x-ms-version', Format(StorageServiceAuthorization.GetDefaultAPIVersion()));
        AddHeader(RequestHeaders, 'Accept', 'application/json;odata=nometadata');
        AddHeader(RequestHeaders, 'DataServiceVersion', '3.0;NetFx');

        TableAPIAuth.Authorize(RequestMsg, StorageAccountTxt);

        if not Client.Send(RequestMsg, Response) then
            exit;

        if Response.IsBlockedByEnvironment() then
            LogBlockedEnvironment(AppId);

        if not Response.IsSuccessStatusCode() then
            exit;

        exit(GetResponseAsJsonObject(Response));
    end;

    local procedure InsertLicenseToAzureTable(AppId: Guid; TestPeriodLength: Integer): JsonObject
    var
        TableAPIAuth: Codeunit "ACA Table API Authorization";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        RequestHeaders, ContentHeaders : HttpHeaders;
        Payload: JsonObject;
        PayloadText: Text;
    begin
        if IsNullGuid(AppId) then
            exit;

        Payload := GenerateJsonPayload(AppId, false, TestPeriodLength);
        GetPayloadText(Payload, PayloadText);
        if StrLen(PayloadText) = 0 then
            exit;

        RequestMsg.Method(Format(Enum::"Http Request Type"::POST));
        RequestMsg.SetRequestUri(BaseUriTxt + AzureTableNameTxt);
        RequestMsg.GetHeaders(RequestHeaders);
        AddHeader(RequestHeaders, 'Date', FormatHelper.GetRfc1123DateTime());
        AddHeader(RequestHeaders, 'x-ms-version', Format(StorageServiceAuthorization.GetDefaultAPIVersion()));
        AddHeader(RequestHeaders, 'Accept', 'application/json;odata=nometadata');
        Content.WriteFrom(PayloadText);
        Content.GetHeaders(ContentHeaders);
        AddHeader(ContentHeaders, 'Content-Type', 'application/json');
        AddHeader(ContentHeaders, 'Content-Length', Format(StrLen(PayloadText)));
        RequestMsg.Content(Content);

        TableAPIAuth.Authorize(RequestMsg, StorageAccountTxt);

        if not Client.Send(RequestMsg, Response) then
            exit;

        if Response.IsBlockedByEnvironment() then
            LogBlockedEnvironment(AppId);

        if not Response.IsSuccessStatusCode() then
            exit;

        exit(GetResponseAsJsonObject(Response));
    end;

    local procedure UpdateTenantToAzureTable(AppId: Guid; var Payload: JsonObject): Boolean
    var
        TableAPIAuth: Codeunit "ACA Table API Authorization";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        RequestHeaders, ContentHeaders : HttpHeaders;
        PayloadText: Text;
        UriTok: Label '%1%2(PartitionKey=''%3'', RowKey=''%4'')', Locked = true;
    begin
        if Payload.Keys().Count() <= 0 then
            exit;

        GetPayloadText(Payload, PayloadText);
        if StrLen(PayloadText) = 0 then
            exit;

        RequestMsg.Method(Format(Enum::"Http Request Type"::PUT));
        RequestMsg.SetRequestUri(StrSubstNo(UriTok, BaseUriTxt, AzureTableNameTxt, GetPartitionKey(), GetRowKey(AppId)));
        RequestMsg.GetHeaders(RequestHeaders);
        AddHeader(RequestHeaders, 'Date', FormatHelper.GetRfc1123DateTime());
        AddHeader(RequestHeaders, 'x-ms-version', Format(StorageServiceAuthorization.GetDefaultAPIVersion()));
        AddHeader(RequestHeaders, 'Accept', 'application/json;odata=nometadata');
        AddHeader(RequestHeaders, 'If-Match', '*');
        Content.WriteFrom(PayloadText);
        Content.GetHeaders(ContentHeaders);
        AddHeader(ContentHeaders, 'Content-Type', 'application/json');
        AddHeader(ContentHeaders, 'Content-Length', Format(StrLen(PayloadText)));
        RequestMsg.Content(Content);
        TableAPIAuth.Authorize(RequestMsg, StorageAccountTxt);

        if not Client.Send(RequestMsg, Response) then
            exit(false);

        exit(Response.IsSuccessStatusCode);
    end;

    local procedure GetResponseAsJsonObject(Repsonse: HttpResponseMessage) ResponseAsJson: JsonObject
    var
        ResponseText: Text;
    begin
        if Repsonse.Content.ReadAs(ResponseText) then;
        if ResponseAsJson.ReadFrom(ResponseText) then;
    end;

    local procedure GenerateJsonPayload(AppId: Guid; IsLicensed: Boolean; TestPeriodLength: Integer) Payload: JsonObject
    begin
        Payload.Add('PartitionKey', GetPartitionKey());
        Payload.Add('RowKey', GetRowKey(AppId));
        Payload.Add('NoOfUsers', GetUserCount());
        Payload.Add('NoOfCompanies', GetCompanyCount());
        Payload.Add('IsLicensed', IsLicensed);
        Payload.Add('TestPeriodLength', TestPeriodLength);
    end;

    local procedure GetPartitionKey(): Text
    var
        TenantInfo: Codeunit "Tenant Information";
    begin
        exit(TenantInfo.GetTenantId());
    end;

    local procedure GetRowKey(AppId: Guid): Text
    begin
        exit(Format(AppId).TrimEnd('}').TrimStart('{'));
    end;

    local procedure GetUserCount(): Integer
    var
        User: Record User;
    begin
        User.SetRange(State, User.State::Enabled);
        exit(User.Count());
    end;

    local procedure GetCompanyCount(): Integer
    var
        Company: Record Company;
    begin
        Company.SetRange("Evaluation Company", false);
        exit(Company.Count());
    end;

    [TryFunction]
    local procedure GetPayloadText(var Payload: JsonObject; var PayloadText: Text)
    begin
        Payload.WriteTo(PayloadText);
    end;

    local procedure AddHeader(var ContentHeaders: HttpHeaders; Name: Text; Value: Text)
    begin
        ContentHeaders.Remove(Name);
        ContentHeaders.Add(Name, Value)
    end;

    local procedure LogBlockedEnvironment(AppId: Guid)
    var
        LogEventIdTok: Label 'ACALF0001', Locked = true;
        LogDimensionTok: Label 'LicenseMgmt', Locked = true;
        LogDimension2Tok: Label 'License', Locked = true;
        LogValueTok: Label 'LicenseFailed', Locked = true;
        MessageTok: Label 'Licensing for app "%1" failed. Could not access Azure Table.', Locked = true;
    begin
        LogMessage(LogEventIdTok, StrSubstNo(MessageTok, AppId), Verbosity::Critical, DataClassification::OrganizationIdentifiableInformation,
            TelemetryScope::All, LogDimensionTok, LogValueTok, LogDimension2Tok, AppId);
    end;

    procedure LicenseIsExpired(): Boolean
    begin
        exit(LicenseExpired);
    end;
}