codeunit 5282633 "ACA Unknown Module Impl." implements "ACA IModule"
{
    Access = Internal;

    procedure GetName(): Text[100]
    var
        ModuleNameLbl: Label 'Unknown Module', MaxLength = 100;
    begin
        exit(ModuleNameLbl);
    end;

    procedure GetDescription(): Text
    var
        ModuleDescriptionLbl: Label 'Module is unknown. Probably App was removed';
    begin
        exit(ModuleDescriptionLbl);
    end;

    procedure GetAppName(): Text
    var
        UnknownLbl: Label 'Unknown';
    begin
        exit(UnknownLbl);
    end;

    procedure GetCategory(): Enum "ACA Module Category"
    begin
        exit("ACA Module Category"::Unknown);
    end;

    procedure CanBeInstalled(): Boolean
    begin
        exit(false);
    end;

    procedure CanBeUninstalled(): Boolean
    begin
        exit(false);
    end;

    procedure Install(): Boolean
    begin
    end;

    procedure MustBeInstalled(): Boolean
    begin
        exit(false);
    end;

    procedure Uninstall(): Boolean
    begin
    end;

    procedure RefreshApplicationArea(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
    end;
}
