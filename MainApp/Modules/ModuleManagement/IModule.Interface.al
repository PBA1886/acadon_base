interface "ACA IModule"
{
    procedure GetName(): Text[100]
    procedure GetDescription(): Text
    procedure GetAppName(): Text
    procedure CanBeInstalled(): Boolean
    procedure CanBeUninstalled(): Boolean
    procedure Install(): Boolean
    procedure Uninstall(): Boolean
    procedure RefreshApplicationArea(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
}
