page 5282625 "ACA Container Content Lookup"
{
    Caption = 'Container Contents';
    PageType = List;
    SourceTable = "ACA Container Content";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                IndentationColumn = Rec.Level;
                IndentationControls = Name;
                field("Parent Directory"; Rec."Parent Directory")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Creation-Time"; Rec."Creation-Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Content-Length"; Rec."Content-Length")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Visible = false;
                }
                field("Content-Type"; Rec."Content-Type")
                {
                    ApplicationArea = All;
                }
                field(BlobType; Rec.BlobType)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Download)
            {
                Caption = 'Download';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = MoveDown;

                trigger OnAction()
                begin
                    Rec.DownloadBlob(OriginalRequestObject);
                end;
            }
        }
    }

    var
        OriginalRequestObject: Codeunit "ACA Request Object";

    procedure InitializeFromTempRec(var ContainerContent: Record "ACA Container Content")
    begin
        if not ContainerContent.FindSet(false, false) then
            exit;

        ContainerContent.GetRequestObject(OriginalRequestObject);
        repeat
            ContainerContent.CalcFields("XML Value");
            Rec.TransferFields(ContainerContent);
            Rec.Insert();
        until ContainerContent.Next() = 0;
    end;
}
