table 5282624 "ACA Feature"
{
    Caption = 'Feature';
    DataClassification = SystemMetadata;
    Extensible = false;

    fields
    {
        field(1; Feature; Enum "ACA Features")
        {
            Caption = 'Feature';
            DataClassification = CustomerContent;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Feature)
        {
            Clustered = true;
        }
    }

    procedure Enable()
    var
        FeatureManagement: Codeunit "ACA Feature Management";
    begin
        FeatureManagement.Enable(Rec);
        RefreshExperienceTiers();
    end;

    procedure Disable()
    var
        FeatureManagement: Codeunit "ACA Feature Management";
    begin
        FeatureManagement.Disable(Rec);
        RefreshExperienceTiers();
    end;

    procedure FeatureEnabled(PassedFeature: Enum "ACA Features"): Boolean
    begin
        if not Rec.Get(PassedFeature) then
            exit(false);

        exit(Rec.Enabled);
    end;

    procedure UpdateFeatures()
    var
        i: Integer;
    begin
        foreach i in Enum::"ACA Features".Ordinals() do
            InsertFeature(Enum::"ACA Features".FromInteger(i));
    end;

    procedure CanBeInstalled(): Boolean
    var
        FeatureManagement: Codeunit "ACA Feature Management";
        IFeature: Interface "ACA IFeature";
    begin
        IFeature := Rec.Feature;
        exit(FeatureManagement.FeatureCanBeInstalled(IFeature));
    end;

    procedure CanBeUninstalled(): Boolean
    var
        FeatureManagement: Codeunit "ACA Feature Management";
        IFeature: Interface "ACA IFeature";
    begin
        IFeature := Rec.Feature;
        exit(FeatureManagement.FeatureCanBeUninstalled(IFeature));
    end;

    internal procedure IsUnkownFeature(): Boolean
    begin
        exit(not "ACA Features".Ordinals().Contains(Rec.Feature.AsInteger()));
    end;

    procedure InsertFeature(Feature: Enum "ACA Features")
    begin
        if Rec.Get(Feature) then
            exit;

        Rec.Init();
        Rec.Feature := Feature;
        Rec.Insert();
    end;


    local procedure RefreshExperienceTiers()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}
