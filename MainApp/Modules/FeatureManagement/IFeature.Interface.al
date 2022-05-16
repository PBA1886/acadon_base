interface "ACA IFeature"
{
    procedure GetName(): Text
    procedure GetDescription(): Text
    procedure GetMandantoryBy(): Text
    procedure GetAppName(): Text
    procedure CanBeInstalled(): Boolean
    procedure CanBeUninstalled(): Boolean
    procedure Install(): Boolean
    procedure Uninstall(): Boolean
    procedure RefreshApplicationArea(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
}
