codeunit 5282621 "ACA Json Management"
{
    procedure GetValue(JsonPropertyName: Text; Object: JsonObject): JsonValue
    var
        DataToken: JsonToken;
    begin
        Object.Get(JsonPropertyName, DataToken);
        exit(DataToken.AsValue());
    end;

    procedure GetObject(JsonPropertyName: Text; Object: JsonObject): JsonObject
    var
        DataToken: JsonToken;
    begin
        Object.Get(JsonPropertyName, DataToken);
        exit(DataToken.AsObject());
    end;

    procedure GetArray(JsonPropertyName: Text; Object: JsonObject): JsonArray
    var
        DataToken: JsonToken;
    begin
        Object.Get(JsonPropertyName, DataToken);
        exit(DataToken.AsArray());
    end;

    procedure GetValueAsBoolean(JsonPropertyName: Text; Object: JsonObject): Boolean
    begin
        exit(GetValue(JsonPropertyName, Object).AsBoolean());
    end;

    procedure GetValueAsInteger(JsonPropertyName: Text; Object: JsonObject): Integer
    begin
        exit(GetValue(JsonPropertyName, Object).AsInteger());
    end;

    procedure GetValueAsDecimal(JsonPropertyName: Text; Object: JsonObject): Decimal
    begin
        exit(GetValue(JsonPropertyName, Object).AsDecimal());
    end;

    procedure GetValueAsDate(JsonPropertyName: Text; Object: JsonObject): Date
    begin
        exit(DT2Date(GetValueAsDateTime(JsonPropertyName, Object)));
    end;

    procedure GetValueAsDateTime(JsonPropertyName: Text; Object: JsonObject): DateTime
    begin
        exit(GetValue(JsonPropertyName, Object).AsDateTime());
    end;

    procedure GetValueAsText(JsonPropertyName: Text; Object: JsonObject): Text
    begin
        exit(GetValue(JsonPropertyName, Object).AsText());
    end;

}