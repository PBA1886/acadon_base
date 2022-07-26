// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 5282621 "ACA Req. Test URI Params"
{
    PageType = ListPart;
    Caption = 'Optional URI Parameters';
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
                    ToolTip = 'The URI Parameter Name.';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'The URI Parameter Value.';
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.ID := xRec.ID + 1;
    end;

    procedure GetRecordAsDictionairy(var UriParameters: Dictionary of [Text, Text])
    begin
        Clear(UriParameters);
        if not Rec.FindSet(false, false) then
            exit;

        repeat
            UriParameters.Add(Rec.Name, Rec.Value);
        until Rec.Next() = 0;
    end;
}
