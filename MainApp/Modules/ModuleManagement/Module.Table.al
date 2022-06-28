table 5282616 "ACA Module"
{
    Caption = 'Module';
    DataClassification = SystemMetadata;
    Extensible = false;

    fields
    {
        field(1; Module; Enum "ACA Modules")
        {
            Caption = 'Module';
            DataClassification = CustomerContent;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(20; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Module)
        {
            Clustered = true;
        }
    }

    procedure Enable()
    var
        ModuleManagement: Codeunit "ACA Module Management";
    begin
        ModuleManagement.Enable(Rec);
        RefreshExperienceTiers();
    end;

    procedure Disable()
    var
        ModuleManagement: Codeunit "ACA Module Management";
    begin
        ModuleManagement.Disable(Rec);
        RefreshExperienceTiers();
    end;

    procedure ModuleEnabled(PassedModule: Enum "ACA Modules"): Boolean
    begin
        if not Rec.Get(PassedModule) then
            exit(false);

        exit(Rec.Enabled);
    end;

    procedure UpdateModules()
    var
        i: Integer;
    begin
        foreach i in Enum::"ACA Modules".Ordinals() do
            UpdateModule(Enum::"ACA Modules".FromInteger(i));
    end;

    procedure CanBeInstalled(): Boolean
    var
        ModuleManagement: Codeunit "ACA Module Management";
        IModule: Interface "ACA IModule";
    begin
        IModule := Rec.Module;
        exit(ModuleManagement.ModuleCanBeInstalled(IModule));
    end;

    procedure CanBeUninstalled(): Boolean
    var
        ModuleManagement: Codeunit "ACA Module Management";
        IModule: Interface "ACA IModule";
    begin
        IModule := Rec.Module;
        exit(ModuleManagement.ModuleCanBeUninstalled(IModule));
    end;

    internal procedure IsUnkownModule(): Boolean
    begin
        exit(not "ACA Modules".Ordinals().Contains(Rec.Module.AsInteger()));
    end;

    local procedure UpdateModule(Module: Enum "ACA Modules")
    var
        IModule: Interface "ACA IModule";
    begin
        if not Rec.Get(Module) then
            InsertModule(Module);

        IModule := Rec.Module;
        Rec.Name := IModule.GetName();
        Rec.Modify();
    end;

    procedure InsertModule(Module: Enum "ACA Modules")
    begin
        if Rec.Get(Module) then
            exit;

        Rec.Init();
        Rec.Module := Module;
        Rec.Insert();
    end;

    local procedure RefreshExperienceTiers()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}
