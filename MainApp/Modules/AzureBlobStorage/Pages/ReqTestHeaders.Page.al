// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 5282622 "ACA Req. Test Headers"
{
    PageType = ListPart;
    Caption = 'Optional Request Headers';
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'The Request Header Name.';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'The Request Header Value.';
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.ID := xRec.ID + 1;
    end;

    procedure GetRecordAsDictionairy(var ReqHeaders: Dictionary of [Text, Text])
    begin
        Clear(ReqHeaders);
        if not Rec.FindSet(false, false) then
            exit;

        repeat
            ReqHeaders.Add(Rec.Name, Rec.Value);
        until Rec.Next() = 0;
    end;
}
