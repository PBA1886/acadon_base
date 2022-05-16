// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 5282619 "ACA Container"
{
    Caption = 'Container';
    PageType = List;
    SourceTable = "ACA Container";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Last-Modified"; Rec."Last-Modified")
                {
                    ApplicationArea = All;
                }
                field(DefaultEntryptionScope; Rec.DefaultEncryptionScope)
                {
                    ApplicationArea = All;
                }
                field(DenyEncryptionScopeOverride; Rec.DenyEncryptionScopeOverride)
                {
                    ApplicationArea = All;
                }
                field(HasImmutabilityPolicy; Rec.HasImmutabilityPolicy)
                {
                    ApplicationArea = All;
                }
                field(HasLegalHold; Rec.HasLegalHold)
                {
                    ApplicationArea = All;
                }
                field(LeaseState; Rec.LeaseState)
                {
                    ApplicationArea = All;
                }
                field(LeaseStatus; Rec.LeaseStatus)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(ShowEntryDetails)
            {
                Caption = 'Show Entry Details';
                Image = ViewDetails;
                ApplicationArea = All;
                // Promoted = true;
                // PromotedIsBig = true;
                // ApplicationArea = All;

                trigger OnAction()
                var
                    InStr: InStream;
                    OuterXml: Text;
                begin
                    if not Rec."XML Value".HasValue then
                        exit;

                    Rec.CalcFields("XML Value");
                    Rec."XML Value".CreateInStream(InStr);
                    InStr.Read(OuterXml);
                    Message(OuterXml);
                end;
            }
        }
    }

    procedure InitializeFromTempRec(var Container: Record "ACA Container")
    begin
        if not Container.FindSet(false, false) then
            exit;

        repeat
            Rec.TransferFields(Container);
            Rec.Insert();
        until Container.Next() = 0;
    end;
}
