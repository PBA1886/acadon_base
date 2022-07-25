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
                    ToolTip = 'The Container name.';
                }
                field("Last-Modified"; Rec."Last-Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the last datetime when the container was edited.';
                }
                field(DefaultEntryptionScope; Rec.DefaultEncryptionScope)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows default encryption scope.';
                }
                field(DenyEncryptionScopeOverride; Rec.DenyEncryptionScopeOverride)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows default encryption scope override.';
                }
                field(HasImmutabilityPolicy; Rec.HasImmutabilityPolicy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows if the Container is Immutable.';
                }
                field(HasLegalHold; Rec.HasLegalHold)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows if the Container is classified for Legal Hold.';
                }
                field(LeaseState; Rec.LeaseState)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the Leasing State of the Container.';
                }
                field(LeaseStatus; Rec.LeaseStatus)
                {
                    ToolTip = 'Shows the Leasing Status of the Container.';
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
                ToolTip = 'Shows details that are stored in the field XML Value.';
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
