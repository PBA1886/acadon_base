codeunit 5282620 "ACA Rest Client"
{
    var
        WebServiceConnectionErr: Label 'The website %1 is not available', Comment = '%1 = Website Url';
        WebServiceResponseInvalidErr: Label 'The response from the website %1 is invalid and cannot convert into json:\\%2', Comment = '%1 = Website Url,%2 = Error Message';

    #region Request Helper Procedures
    [TryFunction]
    procedure TrySendRequest(Method: Enum "Http Request Type"; Url: Text; RequestObject: JsonObject; var ResponseMessage: HttpResponseMessage; var ResponseToken: JsonToken)
    begin
        SendRequest(Method, Url, RequestObject, ResponseMessage, ResponseToken);
    end;

    procedure SendRequest(Method: Enum "Http Request Type"; Url: Text; RequestObject: JsonObject; var ResponseMessage: HttpResponseMessage; var ResponseToken: JsonToken) Successful: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeSendRequest(Method, Url, RequestObject, ResponseMessage, ResponseToken, Successful, IsHandled);
        DoSendRequest(Method, Url, RequestObject, ResponseMessage, ResponseToken, Successful, IsHandled);
        OnAfterSendRequest(Method, Url, RequestObject, ResponseMessage, ResponseToken, Successful);
    end;

    local procedure DoSendRequest(Method: Enum "Http Request Type"; Url: Text; RequestObject: JsonObject; var ResponseMessage: HttpResponseMessage; var ResponseToken: JsonToken; var Successful: Boolean; IsHandled: Boolean)
    var
        ResponseText: Text;
    begin
        if IsHandled then
            exit;

        if not SendRequest(Method, Url, RequestObject, ResponseMessage, ResponseText) then
            Error(WebServiceConnectionErr, Url);

        if not CheckIsValidResponse(ResponseText, ResponseToken) then
            Error(WebServiceResponseInvalidErr, Url, ResponseText);

        Successful := ResponseMessage.IsSuccessStatusCode();
    end;

    local procedure SendRequest(Method: Enum "Http Request Type"; Url: Text; RequestObject: JsonObject; var ResponseMessage: HttpResponseMessage; var ResponseText: Text): Boolean
    var
        Client: HttpClient;
        Content: HttpContent;
        MethodNotSupportedErr: Label 'The Method %1 is not supported', Comment = '%1 = Http-Method';
    begin
        CreateHttpClient(Client, Content, RequestObject);

        case Method of
            Method::GET:
                if not Client.Get(Url, ResponseMessage) then
                    exit(false);
            Method::DELETE:
                if not Client.Delete(Url, ResponseMessage) then
                    exit(false);
            Method::PUT:
                if not Client.Put(Url, Content, ResponseMessage) then
                    exit(false);
            Method::POST:
                if not Client.Post(Url, Content, ResponseMessage) then
                    exit(false);
            else
                Error(MethodNotSupportedErr, Method);
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(true);
    end;

    local procedure CreateHttpClient(var Client: HttpClient; var Content: HttpContent; Request: JsonObject)
    var
        IsHandled: Boolean;
    begin
        OnBeforeCreateHttpClient(Client, Content, Request, IsHandled);

        DoCreateHttpClient(Content, Request, IsHandled);

        OnAfterCreateHttpClient(Client, Content, Request);
    end;

    local procedure DoCreateHttpClient(var Content: HttpContent; Request: JsonObject; IsHandled: Boolean)
    var
        Headers: HttpHeaders;
        RequestText: Text;
    begin
        if IsHandled then
            exit;

        Request.WriteTo(RequestText);
        Content.WriteFrom(RequestText);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
    end;
    #endregion

    #region Response Helper Procedures
    local procedure CheckIsValidResponse(ResponseText: Text; var ResultJsonToken: JsonToken) IsValid: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckIsValidResponse(ResponseText, ResultJsonToken, IsValid, IsHandled);

        DoCheckIsValidResponse(ResponseText, ResultJsonToken, IsValid, IsHandled);

        OnAfterCheckIsValidResponse(ResponseText, ResultJsonToken, IsValid);
    end;

    local procedure DoCheckIsValidResponse(ResponseText: Text; var ResultJsonToken: JsonToken; var IsValid: Boolean; IsHandled: Boolean): Boolean
    begin
        if IsHandled then
            exit;

        IsValid := ResultJsonToken.ReadFrom(ResponseText);
    end;
    #endregion

    #region Events
    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendRequest(Method: Enum "Http Request Type"; Url: Text; var RequestObject: JsonObject; var ResponseMessage: HttpResponseMessage; var ResponseToken: JsonToken; var Successful: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSendRequest(Method: Enum "Http Request Type"; Url: Text; RequestObject: JsonObject; ResponseMessage: HttpResponseMessage; ResponseToken: JsonToken; Successful: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateHttpClient(var Client: HttpClient; var Content: HttpContent; var Request: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateHttpClient(var Client: HttpClient; var Content: HttpContent; Request: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckIsValidResponse(ResponseText: Text; var ResultJsonToken: JsonToken; var IsValid: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckIsValidResponse(ResponseText: Text; var ResultJsonToken: JsonToken; var IsValid: Boolean)
    begin
    end;
    #endregion
}