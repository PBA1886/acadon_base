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
    var
        "Value": JsonValue;
    begin
        Value := GetValue(JsonPropertyName, Object);
        if Value.IsNull() or Value.IsUndefined() then
            exit;

        exit(Value.AsBoolean());
    end;

    procedure GetValueAsInteger(JsonPropertyName: Text; Object: JsonObject): Integer
    var
        "Value": JsonValue;
    begin
        Value := GetValue(JsonPropertyName, Object);
        if Value.IsNull() or Value.IsUndefined() then
            exit;

        exit(Value.AsInteger());
    end;

    procedure GetValueAsDecimal(JsonPropertyName: Text; Object: JsonObject): Decimal
    var
        Value: JsonValue;
    begin
        Value := GetValue(JsonPropertyName, Object);
        if Value.IsNull() or Value.IsUndefined() then
            exit;

        exit(Value.AsDecimal());
    end;

    procedure GetValueAsDate(JsonPropertyName: Text; Object: JsonObject): Date
    var
        "Value": JsonValue;
    begin
        Value := GetValue(JsonPropertyName, Object);
        if Value.IsNull() or Value.IsUndefined() then
            exit;

        exit(Value.AsDate());
    end;

    procedure GetValueAsDateTime(JsonPropertyName: Text; Object: JsonObject): DateTime
    var
        "Value": JsonValue;
    begin
        Value := GetValue(JsonPropertyName, Object);
        if Value.IsNull() or Value.IsUndefined() then
            exit;

        exit(Value.AsDateTime());
    end;

    procedure GetValueAsText(JsonPropertyName: Text; Object: JsonObject): Text
    var
        "Value": JsonValue;
    begin
        Value := GetValue(JsonPropertyName, Object);
        if Value.IsNull() or Value.IsUndefined() then
            exit;

        exit(Value.AsText());
    end;

}