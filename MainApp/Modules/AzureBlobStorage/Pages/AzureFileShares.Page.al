page 5282626 "ACA Azure File Shares"
{
    Caption = 'File Shares';
    PageType = List;
    SourceTable = "ACA Azure File Share";
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
                    ToolTip = 'File Share Name.';
                }
                field("Last-Modified"; Rec."Last-Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'File Share Last-Modified.';
                }
            }
        }
    }

    procedure InitializeFromTempRec(var FileShare: Record "ACA Azure File Share")
    begin
        if not FileShare.FindSet(false, false) then
            exit;

        repeat
            Rec.TransferFields(FileShare);
            Rec.Insert();
        until FileShare.Next() = 0;
    end;
}
