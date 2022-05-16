codeunit 5282631 "ACA Unknown Feature Impl." implements "ACA IFeature"
{
    Access = Internal;

    procedure GetName(): Text
    var
        FeatureNameLbl: Label 'Unknown Feature';
    begin
        exit(FeatureNameLbl);
    end;

    procedure GetDescription(): Text
    var
        FeatureDescriptionLbl: Label 'Feature is unknown. Probably App was removed';
    begin
        exit(FeatureDescriptionLbl);
    end;

    procedure GetMandantoryBy(): Text
    var
        MandantoryByTok: Label '-', Locked = true;
    begin
        exit(MandantoryByTok);
    end;

    procedure GetAppName(): Text
    var
        UnknownLbl: Label 'Unknown';
    begin
        exit(UnknownLbl);
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
