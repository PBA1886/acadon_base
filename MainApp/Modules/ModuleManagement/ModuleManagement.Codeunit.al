codeunit 5282632 "ACA Module Management"
{
    procedure Enable(var Module: Record "ACA Module")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        IModule: Interface "ACA IModule";
        Question: Text;
        ModuleEnableQst: Label 'Do you want to enable Module %1?', Comment = ' %1 = Module Name';
        NotReversedMsg: Label 'This can not be reversed.';
        ModuleEnabledMsg: Label 'Module %1 is now enabled.', Comment = ' %1 = Module Name';
    begin
        if Module.Enabled then
            exit;

        IModule := Module.Module;
        Question := ModuleEnableQst;

        if not ModuleCanBeInstalled(IModule) then
            exit;

        if not ModuleCanBeUninstalled(IModule) then
            Question += '\' + NotReversedMsg;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(Question, IModule.GetName()), true) then
            exit;

        InstallModule(IModule);
        Module.Enabled := true;
        Module.Modify();

        Message(ModuleEnabledMsg, IModule.GetName());
    end;

    procedure Disable(var Module: Record "ACA Module")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ModuleDisableQst: Label 'Do you want to disable Module %1?', Comment = ' %1 = Module Name';
        ModuleDisabledMsg: Label 'Module %1 is now disabled.', Comment = ' %1 = Module Name';
        IModule: Interface "ACA IModule";
    begin
        if not Module.Enabled then
            exit;

        IModule := Module.Module;
        if not ModuleCanBeUninstalled(IModule) then
            exit;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ModuleDisableQst, IModule.GetName()), true) then
            exit;

        ModuleUninstall(IModule);
        Module.Enabled := false;
        Module.Modify();

        Message(ModuleDisabledMsg, IModule.GetName());
    end;

    procedure ModuleCanBeInstalled(var IModule: Interface "ACA IModule") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeModuleCanBeInstalled(IModule, Result, IsHandled);
        if IsHandled then
            exit;

        Result := IModule.CanBeInstalled();
    end;

    procedure ModuleCanBeUninstalled(var IModule: Interface "ACA IModule") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeModuleCanBeUnInstalled(IModule, Result, IsHandled);
        if IsHandled then
            exit;

        Result := IModule.CanBeUninstalled();
    end;

    procedure InstallModule(var IModule: Interface "ACA IModule")
    var
        IsHandled: Boolean;
        LogEventIdTok: Label 'ACAFI0001', Locked = true;
        LogDimensionTok: Label 'ModuleMgmt', Locked = true;
        LogDimension2Tok: Label 'Module', Locked = true;
        LogValueTok: Label 'ModuleInstall', Locked = true;
        MessageTok: Label 'Module %1 installed.', Locked = true;
    begin
        OnBeforeInstallModule(IModule, IsHandled);
        if IsHandled then
            exit;

        IModule.Install();

        LogMessage(LogEventIdTok, StrSubstNo(MessageTok, IModule.GetName()), Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, LogDimensionTok, LogValueTok, LogDimension2Tok, IModule.GetName());
    end;

    procedure ModuleUninstall(var IModule: Interface "ACA IModule")
    var
        IsHandled: Boolean;
        LogEventIdTok: Label 'ACAFU0001', Locked = true;
        LogDimensionTok: Label 'ModuleMgmt', Locked = true;
        LogDimension2Tok: Label 'Module', Locked = true;
        LogValueTok: Label 'ModuleUninstall', Locked = true;
        MessageTok: Label 'Module %1 uninstalled.', Locked = true;
    begin
        OnBeforeUninstallModule(IModule, IsHandled);
        if IsHandled then
            exit;

        IModule.Uninstall();

        LogMessage(LogEventIdTok, StrSubstNo(MessageTok, IModule.GetName()), Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, LogDimensionTok, LogValueTok, LogDimension2Tok, IModule.GetName());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModuleCanBeInstalled(var IModule: Interface "ACA IModule"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModuleCanBeUnInstalled(var IModule: Interface "ACA IModule"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInstallModule(var IModule: Interface "ACA IModule"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUninstallModule(var IModule: Interface "ACA IModule"; var IsHandled: Boolean)
    begin
    end;
}
