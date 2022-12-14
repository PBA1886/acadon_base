// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 5282624 "ACA Format Helper"
{
    Access = Internal;

    trigger OnRun()
    begin

    end;

    procedure AppendToUri(var Uri: Text; ParameterIdentifier: Text; ParameterValue: Text)
    var
        ConcatChar: Text;
        AppendType1Lbl: Label '%1%2=%3', Comment = '%1 = Concatenation character, %2 = Parameter Identifer, %3 = Parameter Value', Locked = true;
        AppendType2Lbl: Label '%1%2', Comment = '%1 = Concatenation character, %2 = Parameter Value', Locked = true;
    begin
        ConcatChar := '?';
        if Uri.Contains('?') then
            ConcatChar := '&';
        if ParameterIdentifier <> '' then
            Uri += StrSubstNo(AppendType1Lbl, ConcatChar, ParameterIdentifier, ParameterValue)
        else
            Uri += StrSubstNo(AppendType2Lbl, ConcatChar, ParameterValue)
    end;

    procedure RemoveSasTokenParameterFromUrl(Url: Text): Text
    begin
        if Url.Contains('&sv') then
            Url := Url.Substring(1, Url.LastIndexOf('&sv') - 1);
        exit(Url);
    end;

    procedure RemoveCurlyBracketsFromString("Value": Text): Text
    begin
        "Value" := "Value".Replace('{', '');
        "Value" := "Value".Replace('}', '');
        exit("Value");
    end;

    procedure TextToXmlDocument(SourceText: Text): XmlDocument
    var
        Document: XmlDocument;
    begin
        XmlDocument.ReadFrom(SourceText, Document);
        exit(Document);
    end;

    procedure ConvertToDateTime(PropertyValue: Text): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        NewDateTime: DateTime;
        ResultVariant: Variant;
    begin
        NewDateTime := 0DT;
        ResultVariant := NewDateTime;
        if TypeHelper.Evaluate(ResultVariant, PropertyValue, '', '') then
            NewDateTime := ResultVariant;
        exit(NewDateTime);
    end;

    procedure ConvertToInteger(PropertyValue: Text): Integer
    var
        NewInteger: Integer;
    begin
        if Evaluate(NewInteger, PropertyValue) then
            exit(NewInteger);
    end;

    procedure ConvertToBoolean(PropertyValue: Text): Boolean
    var
        NewBoolean: Boolean;
    begin
        if Evaluate(NewBoolean, PropertyValue) then
            exit(NewBoolean);
    end;

    procedure GetNewLineCharacter(): Text
    var
        LF: Char;
    begin
        LF := 10;
        exit(Format(LF));
    end;

    procedure GetRfc1123DateTime(): Text
    begin
        exit(GetRfc1123DateTime(CreateDateTime(Today(), Time())));
    end;

    procedure GetRfc1123DateTime(MyDateTime: DateTime): Text
    var
        Rfc1123FormatDateTime: Text;
        Rfc1123FormatLbl: Label '%1 GMT', Comment = '%1 = Correctly formatted Timestamp', Locked = true;
    begin
        // Target format is like this: Wed, 11 Nov 2020 08:50:07 GMT
        // Definition: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html "14.18 Date"
        MyDateTime := ConvertDateTimeToUtcDateTime(MyDateTime);
        Rfc1123FormatDateTime := GetDateFormatInEnglish(MyDateTime);
        // Adjust if current day-value is below 10 to add a leading "0"
        // API is expecting format to be like:
        //     Tue, 01 Dec 2020 17:05:07 GMT
        // Previous code would generate it like:
        //     Tue, 1 Dec 2020 17:05:07 GMT
        // Since the day is always a 3-letter string followed by a comma and a space we need to add a "0" (zero) on pos 6 in these cases
        if Date2DMY(DT2Date(MyDateTime), 1) < 10 then
            Rfc1123FormatDateTime := InsStr(Rfc1123FormatDateTime, '0', 6);
        Rfc1123FormatDateTime := StrSubstNo(Rfc1123FormatLbl, Rfc1123FormatDateTime);
        exit(Rfc1123FormatDateTime);
    end;

    local procedure ConvertDateTimeToUtcDateTime(MyDateTime: DateTime): DateTime
    var
        UtcDate: Date;
        UtcTime: Time;
        UtcDateTime: DateTime;
        DateTimeAsXmlString: Text;
        DatePartText: Text;
        TimePartText: Text;
    begin
        // AFAIK is formatting an AL DateTime as XML the only way to get the UTC-value, so this is used as a workaround                
        DateTimeAsXmlString := Format(MyDateTime, 0, 9); // Format as XML, e.g.: 2020-11-11T08:50:07.553Z
        DatePartText := CopyStr(DateTimeAsXmlString, 1, StrPos(DateTimeAsXmlString, 'T') - 1);
        TimePartText := CopyStr(DateTimeAsXmlString, StrPos(DateTimeAsXmlString, 'T') + 1);
        if (StrPos(TimePartText, '.') > 0) then
            TimePartText := CopyStr(TimePartText, 1, StrPos(TimePartText, '.') - 1);
        if (StrPos(TimePartText, 'Z') > 0) then
            TimePartText := CopyStr(TimePartText, 1, StrPos(TimePartText, 'Z') - 1);
        Evaluate(UtcDate, DatePartText);
        Evaluate(UtcTime, TimePartText);
        UtcDateTime := CreateDateTime(UtcDate, UtcTime);
        exit(UtcDateTime);
    end;

    local procedure GetDateFormatInEnglish(MyDateTime: DateTime): Text
    var
        TargetDateTimeFormatLbl: Label '%1, %2 %3 %4', Locked = true;
        DayFormatLbl: Label '<Day>', Locked = true;
        YearAndDateFormatLbl: Label '<Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>', Locked = true;
    begin
        exit(StrSubstNo(TargetDateTimeFormatLbl, GetWeekday(MyDateTime), Format(MyDateTime, 0, DayFormatLbl), GetMonth(MyDateTime), Format(MyDateTime, 0, YearAndDateFormatLbl)));
    end;

    local procedure GetWeekday(PassedDateTime: DateTime): Text
    var
        DaysInENULbl: Label 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', Locked = true;
    begin
        exit(SelectStr(Date2DWY(DT2Date(PassedDateTime), 1), DaysInENULbl));
    end;

    local procedure GetMonth(PassedDateTime: DateTime): Text
    var
        MonthInENULbl: Label 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec', Locked = true;
    begin
        exit(SelectStr(Date2DMY(DT2Date(PassedDateTime), 2), MonthInENULbl));
    end;
}
