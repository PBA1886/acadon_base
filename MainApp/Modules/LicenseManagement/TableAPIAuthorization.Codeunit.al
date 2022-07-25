codeunit 5282634 "ACA Table API Authorization"
{
    //Copied from System App - Storage Service Authorization.
    //Can be replaced by System App as soon as system app supports Authorization for Azure Table API
    Access = Internal;

    [NonDebuggable]
    procedure Authorize(var HttpRequest: HttpRequestMessage; StorageAccount: Text)
    var
        Headers: HttpHeaders;
    begin
        HttpRequest.GetHeaders(Headers);

        Headers.Remove('Authorization');
        Headers.Add('Authorization', GetSharedKeySignature(HttpRequest, StorageAccount));
    end;

    [NonDebuggable]
    local procedure GetSharedKeySignature(HttpRequest: HttpRequestMessage; StorageAccount: Text): Text
    var
        StringToSign: Text;
        Signature: Text;
        SignaturePlaceHolderLbl: Label 'SharedKeyLite %1:%2', Locked = true;
    begin
        StringToSign := CreateSharedKeyStringToSign(HttpRequest, StorageAccount);
        Signature := GetAccessKeyHashCode(StringToSign, GetSharedKey());
        exit(StrSubstNo(SignaturePlaceHolderLbl, StorageAccount, Signature));
    end;

    local procedure CreateSharedKeyStringToSign(Request: HttpRequestMessage; StorageAccount: Text): Text
    var
        RequestHeaders: HttpHeaders;
        StringToSign: Text;
    begin
        Request.GetHeaders(RequestHeaders);

        StringToSign += GetHeaderValueOrEmpty(RequestHeaders, 'Date') + NewLine();
        StringToSign += GetCanonicalizedResource(StorageAccount, Request.GetRequestUri());

        exit(StringToSign);
    end;

    local procedure GetHeaderValueOrEmpty(Headers: HttpHeaders; HeaderKey: Text): Text
    var
        ReturnValue: array[1] of Text;
    begin
        if not Headers.GetValues(HeaderKey, ReturnValue) then
            exit('');

        if HeaderKey = 'Content-Length' then
            if ReturnValue[1] = '0' then
                exit('');

        exit(ReturnValue[1]);
    end;

    local procedure GetCanonicalizedResource(StorageAccount: Text; UriString: Text): Text
    var
        Uri: Codeunit Uri;
        UriBuider: Codeunit "Uri Builder";
        QueryString: Text;
        Segments: List of [Text];
        Segment: Text;
        StringBuilderResource: TextBuilder;
    begin
        Uri.Init(UriString);
        Uri.GetSegments(Segments);

        UriBuider.Init(UriString);
        QueryString := UriBuider.GetQuery();

        StringBuilderResource.Append('/');
        StringBuilderResource.Append(StorageAccount);
        foreach Segment in Segments do
            StringBuilderResource.Append(Segment);

        exit(StringBuilderResource.ToText());
    end;

    [NonDebuggable]
    local procedure GetAccessKeyHashCode(StringToSign: Text; AccessKey: Text): Text;
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
    begin
        exit(CryptographyManagement.GenerateBase64KeyedHashAsBase64String(StringToSign, AccessKey, HashAlgorithmType::HMACSHA256));
    end;

    local procedure NewLine(): Text
    var
        LF: Char;
    begin
        LF := 10;
        exit(Format(LF));
    end;

    [NonDebuggable]
    local procedure GetSharedKey(): Text
    var
        [NonDebuggable]
        SharedKeyTok: Label 'gbARNC2GqcDPDXtA/vEFIqnFzNFaafVleSSZ77qrOkfDIdXGsADjOuQ/IjBJ7gNacJyDXw77K2SLY8Z5tpTXnA==', Locked = true;
    begin
        exit(SharedKeyTok);
    end;
}