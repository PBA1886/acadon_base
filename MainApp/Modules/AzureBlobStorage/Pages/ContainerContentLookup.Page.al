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
                    ToolTip = 'The Parent Directory of the Container.';
                    Visible = false;
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    ToolTip = 'The count of parent directories.';
                    Visible = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'The Container name.';
                }
                field("Creation-Time"; Rec."Creation-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'The datetime when the Container was created.';
                    Visible = false;
                }
                field("Content-Length"; Rec."Content-Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Content-Length of the Container.';
                    BlankZero = true;
                    Visible = false;
                }
                field("Content-Type"; Rec."Content-Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Content-Type of the Container.';
                }
                field(BlobType; Rec.BlobType)
                {
                    ApplicationArea = All;
                    ToolTip = 'The BlobType of the Container.';
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
                ToolTip = 'Download the Blob.';
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
