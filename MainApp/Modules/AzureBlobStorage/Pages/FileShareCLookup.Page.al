page 5282628 "ACA File Share C. Lookup"
{
    Caption = 'File Share Content';
    PageType = List;
    SourceTable = "ACA Azure File Share Content";
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
                    ToolTip = 'The Container Name.';
                }
                field("Content-Length"; Rec."Content-Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'The Content-Length of the Container.';
                    BlankZero = true;
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
                    Rec.DownloadFile(OriginalRequestObject);
                end;
            }
        }
    }

    var
        OriginalRequestObject: Codeunit "ACA Request Object";

    procedure InitializeFromTempRec(var FileShareContent: Record "ACA Azure File Share Content")
    begin
        if not FileShareContent.FindSet(false, false) then
            exit;

        FileShareContent.GetRequestObject(OriginalRequestObject);
        repeat
            FileShareContent.CalcFields("XML Value");
            Rec.TransferFields(FileShareContent);
            Rec.Insert();
        until FileShareContent.Next() = 0;
    end;
}
